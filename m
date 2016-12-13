From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:43 +0000 (UTC)
Subject: master - raid: improve table reload sequence
Message-ID: <20161213210943.659DF60973@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=069039204002e5c8514050fe541bbd378c383a02
Commit:        069039204002e5c8514050fe541bbd378c383a02
Parent:        7dff632c11e6ddce77dc9cde8f9011bb22970589
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 12:31:28 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

raid: improve table reload sequence

This is another place for 'common' use pattern or
reload and activation of deleted devices.
(Moving the exclusive activation to _deactivate_and_remove_lvs()).

TODO: looks like halve of raid function is reloading
just 'origin' - and the other full LV.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   60 ++++++--------------------------------------
 2 files changed, 10 insertions(+), 51 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ea15903..a75183e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Reusing exiting code for raid image removal.
   Fix pvmove leaving -pvmove0 error device in clustered VG.
   Avoid adding extra '_' at end of raid extracted images or metadata.
   Optimize another _rmeta clearing code.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 98f30e2..f2c0b26 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -248,11 +248,10 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 {
 	struct lv_list *lvl;
 
-	if (vg_is_clustered(vg))
-		/* Need to take lock for proper deactivation */
-		dm_list_iterate_items(lvl, removal_lvs)
-			if (!activate_lv_excl_local(vg->cmd, lvl->lv))
-				return_0;
+	/* Need to take lock/resume for proper deactivation */
+	dm_list_iterate_items(lvl, removal_lvs)
+		if (!activate_lv_excl_local(vg->cmd, lvl->lv))
+			return_0;
 
 	dm_list_iterate_items(lvl, removal_lvs) {
 		if (!deactivate_lv(vg->cmd, lvl->lv))
@@ -1214,15 +1213,14 @@ static int _raid_remove_images(struct logical_volume *lv,
 			       struct dm_list *removal_lvs, int commit)
 {
 	struct dm_list removed_lvs;
-	struct lv_list *lvl;
-
-	dm_list_init(&removed_lvs);
 
 	if (!archive(lv->vg))
 		return_0;
 
-	if (!removal_lvs)
+	if (!removal_lvs) {
+		dm_list_init(&removed_lvs);
 		removal_lvs = &removed_lvs;
+	}
 
 	if (!_raid_extract_images(lv, 0, new_count, allocate_pvs, 1,
 				 removal_lvs, removal_lvs)) {
@@ -1245,48 +1243,8 @@ static int _raid_remove_images(struct logical_volume *lv,
 	if (!commit)
 		return 1;
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes for %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if (!suspend_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to suspend %s before committing changes.",
-			  display_lvname(lv));
-		vg_revert(lv->vg);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes for %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	/*
-	 * We activate the extracted sub-LVs first so they are renamed
-	 * and won't conflict with the remaining (possibly shifted)
-	 * sub-LVs.
-	 */
-	dm_list_iterate_items(lvl, removal_lvs) {
-		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv)) {
-			log_error("Failed to resume extracted LVs.");
-			return 0;
-		}
-	}
-
-	if (!resume_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s after committing changes.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if (!sync_local_dev_names(lv->vg->cmd)) {
-		log_error("Failed to sync local devices after committing changes for %s.",
-			  display_lvname(lv));
-		return 0;
-	}
+	if (!lv_update_and_reload(lv))
+		return_0;
 
 	/*
 	 * Eliminate the extracted LVs


