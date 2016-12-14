From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Dec 2016 10:42:38 +0000 (UTC)
Subject: master - raid: activation with list
Message-ID: <20161214104238.08A6760C8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77e09c3fb4d019ab3a0472059481ef990c64b415
Commit:        77e09c3fb4d019ab3a0472059481ef990c64b415
Parent:        4a05f83278a1b1967b91d8f47fa1f7ce18341439
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 14 11:16:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 14 11:37:02 2016 +0100

raid: activation with list

Commit 069039204002e5c8514050fe541bbd378c383a02 revealed a problem
in raid metadata manipulation.

We do two operations in one table reload:
- raid leg/image extraction
- rename remaining raid legs

This should be made in separate steps. Otherwise we do an
uncorrectable table change on error path (leaving tables
for admin and dmsetup).

As a hotfix - restore the previous logic and use a single
new function _lv_update_and_reload_list which activates exclusively
extracted LVs on the list before resuming suspended raid LV.
This restore 'rename' functionality upon resume.

Also still preserve the 'origin_only' logic - although we know
it's not working properly for cluster and LV stacking.

Further fixes are needed.
---
 lib/metadata/raid_manip.c |   67 +++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 59 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 049102a..ed48239 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -233,11 +233,6 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 {
 	struct lv_list *lvl;
 
-	/* Need to take lock/resume for proper deactivation */
-	dm_list_iterate_items(lvl, removal_lvs)
-		if (!activate_lv_excl_local(vg->cmd, lvl->lv))
-			return_0;
-
 	dm_list_iterate_items(lvl, removal_lvs) {
 		if (!deactivate_lv(vg->cmd, lvl->lv))
 			return_0;
@@ -363,6 +358,62 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	return 1;
 }
 
+/*
+ * Assisted excl_local activation of lvl listed LVs before resume
+ *
+ * FIXME: code which needs to use this function is usually unsafe
+ *	  againt crashes as it's doing more then 1 operation per commit
+ *	  and as such is currently irreversible on error path.
+ *
+ * Function is not making backup as this is usually not the last
+ * metadata changing operation.
+ *
+ * Also we should take 'struct lv_list'...
+ */
+static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only, struct dm_list *lv_list)
+{
+	struct volume_group *vg = lv->vg;
+	const struct logical_volume *lock_lv = lv_lock_holder(lv);
+	struct lv_list *lvl;
+	int r;
+
+	log_very_verbose("Updating logical volume %s on disk(s)%s.",
+			 display_lvname(lock_lv), origin_only ? " (origin only)": "");
+
+	if (!vg_write(vg))
+		return_0;
+
+	if (!(r = (origin_only ? suspend_lv_origin(vg->cmd, lock_lv) : suspend_lv(vg->cmd, lock_lv)))) {
+		log_error("Failed to lock logical volume %s.",
+			  display_lvname(lock_lv));
+		vg_revert(vg);
+	} else if (!(r = vg_commit(vg)))
+		stack; /* !vg_commit() has implict vg_revert() */
+
+	if (r && lv_list) {
+		dm_list_iterate_items(lvl, lv_list) {
+			log_very_verbose("Activating logical volume %s before %s in kernel.",
+					 display_lvname(lvl->lv), display_lvname(lock_lv));
+			if (!activate_lv_excl_local(vg->cmd, lvl->lv)) {
+				log_error("Failed to activate %s before resuming %s.",
+					  display_lvname(lvl->lv), display_lvname(lock_lv));
+				r = 0; /* But lets try with the rest */
+			}
+		}
+	}
+
+	log_very_verbose("Updating logical volume %s in kernel.",
+			 display_lvname(lock_lv));
+
+	if (!(origin_only ? resume_lv_origin(vg->cmd, lock_lv) : resume_lv(vg->cmd, lock_lv))) {
+		log_error("Problem reactivating logical volume %s.",
+			  display_lvname(lock_lv));
+		r = 0;
+	}
+
+	return r;
+}
+
 /* Makes on-disk metadata changes
  * If LV is active:
  *	clear first block of device
@@ -1233,7 +1284,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 	if (!commit)
 		return 1;
 
-	if (!lv_update_and_reload(lv))
+	if (!_lv_update_and_reload_list(lv, 0, removal_lvs))
 		return_0;
 
 	/*
@@ -1927,7 +1978,7 @@ static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
 		return_0;
 
 	if (update_and_reload) {
-		if (!lv_update_and_reload_origin(lv))
+		if (!_lv_update_and_reload_list(lv, 1, removal_lvs))
 			return_0;
 
 		/* If any residual LVs, eliminate them, write VG, commit it and take a backup */
@@ -1977,7 +2028,7 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 {
 	int flags_were_cleared = 0, r = 0;
 
-	if (!lv_update_and_reload_origin(lv))
+	if (!_lv_update_and_reload_list(lv, 1, removal_lvs))
 		return_0;
 
 	/* Eliminate any residual LV and don't commit the metadata */


