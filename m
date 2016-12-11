From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:43 +0000 (UTC)
Subject: master - raid: optimize clearing of lvs
Message-ID: <20161211223443.14EDF60C4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55ca8043d4bb0ef4435a24728cad34f8b0ff6c8c
Commit:        55ca8043d4bb0ef4435a24728cad34f8b0ff6c8c
Parent:        8831a541a831a2d25cb96ee09f6739526d29e5c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 20:53:17 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:19:41 2016 +0100

raid: optimize clearing of lvs

Activate whole list of metadata lvs first before clearing them.
(Similar to commit ada5733c5652d456ffa138b0d07e6897824813b0)

TODO: make this clearing in a single common function.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   92 ++++++++++++++++++++++----------------------
 2 files changed, 47 insertions(+), 46 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b6f74ec..9e95792 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Optimize another _rmeta clearing code.
   Fix deactivation of raid orphan devices for clustered VG.
   Fix lvconvert raid1 to mirror table reload order.
   Add internal function for separate mirror log preparation.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 661c39b..159bfa2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -379,10 +379,7 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	return 1;
 }
 
-/*
- * _clear_lv
- * @lv
- *
+/* Makes on-disk metadata changes
  * If LV is active:
  *	clear first block of device
  * otherwise:
@@ -390,50 +387,15 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
  *
  * Returns: 1 on success, 0 on failure
  */
-static int _clear_lv(struct logical_volume *lv)
-{
-	int was_active = lv_is_active_locally(lv);
-
-	if (test_mode())
-		return 1;
-
-	lv->status |= LV_TEMPORARY;
-	if (!was_active && !activate_lv_local(lv->vg->cmd, lv)) {
-		log_error("Failed to activate localy %s for clearing.",
-			  display_lvname(lv));
-		return 0;
-	}
-	lv->status &= ~LV_TEMPORARY;
-
-	log_verbose("Clearing metadata area of %s",
-		    display_lvname(lv));
-	/*
-	 * Rather than wiping lv->size, we can simply
-	 * wipe the first sector to remove the superblock of any previous
-	 * RAID devices.  It is much quicker.
-	 */
-	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .zero_sectors = 1 })) {
-		log_error("Failed to zero %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if (!was_active && !deactivate_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to deactivate %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	return 1;
-}
-
-/* Makes on-disk metadata changes */
 static int _clear_lvs(struct dm_list *lv_list)
 {
 	struct lv_list *lvl;
 	struct volume_group *vg = NULL;
+	unsigned i = 0, sz = dm_list_size(lv_list);
+	char *was_active;
+	int r = 1;
 
-	if (dm_list_empty(lv_list)) {
+	if (!sz) {
 		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing.");
 		return 1;
 	}
@@ -447,6 +409,9 @@ static int _clear_lvs(struct dm_list *lv_list)
 		vg = lvl->lv->vg;
 	}
 
+	if (test_mode())
+		return 1;
+
 	/*
 	 * FIXME: only vg_[write|commit] if LVs are not already written
 	 * as visible in the LVM metadata (which is never the case yet).
@@ -454,11 +419,46 @@ static int _clear_lvs(struct dm_list *lv_list)
 	if (!vg || !vg_write(vg) || !vg_commit(vg))
 		return_0;
 
+	was_active = alloca(sz);
+
 	dm_list_iterate_items(lvl, lv_list)
-		if (!_clear_lv(lvl->lv))
-			return 0;
+		if (!(was_active[i++] = lv_is_active_locally(lvl->lv))) {
+			lvl->lv->status |= LV_TEMPORARY;
+			if (!activate_lv_excl_local(vg->cmd, lvl->lv)) {
+				log_error("Failed to activate localy %s for clearing.",
+					  display_lvname(lvl->lv));
+				r = 0;
+				goto out;
+			}
+			lvl->lv->status &= ~LV_TEMPORARY;
+		}
 
-	return 1;
+	dm_list_iterate_items(lvl, lv_list) {
+		log_verbose("Clearing metadata area %s.", display_lvname(lvl->lv));
+		/*
+		 * Rather than wiping lv->size, we can simply
+		 * wipe the first sector to remove the superblock of any previous
+		 * RAID devices.  It is much quicker.
+		 */
+		if (!wipe_lv(lvl->lv, (struct wipe_params) { .do_zero = 1, .zero_sectors = 1 })) {
+			log_error("Failed to zero %s.", display_lvname(lvl->lv));
+			r = 0;
+			goto out;
+		}
+	}
+out:
+	/* TODO:   deactivation is only needed with clustered locking
+	 *         in normal case we should keep device active
+	 */
+	sz = 0;
+	dm_list_iterate_items(lvl, lv_list)
+		if ((i > sz) && !was_active[sz++] &&
+		    !deactivate_lv(vg->cmd, lvl->lv)) {
+			log_error("Failed to deactivate %s.", display_lvname(lvl->lv));
+			r = 0; /* continue deactivating */
+		}
+
+	return r;
 }
 
 /*


