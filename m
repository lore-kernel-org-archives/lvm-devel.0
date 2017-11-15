From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 15:00:51 -0500
Subject: master - pvmove: remove unusued code
Message-ID: <201711152000.vAFK0pWR029304@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f0dc1a2a5f779fbdae7bddd12c3e56397636833
Commit:        0f0dc1a2a5f779fbdae7bddd12c3e56397636833
Parent:        b978f505ff05c3581ccc633442b04c5d391add04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 10 21:48:33 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 21:00:29 2017 +0100

pvmove: remove unusued code

Support for snapshot and cache LVs should now work.
Remove protection rejecting pvmove for them.
---
 lib/locking/locking.c |   61 -------------------------------------------
 lib/locking/locking.h |    4 ---
 tools/pvmove.c        |   68 -------------------------------------------------
 3 files changed, 0 insertions(+), 133 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index acf3327..c68d4c7 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -371,67 +371,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	return 1;
 }
 
-/* Unlock list of LVs */
-int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs)
-{
-	struct lv_list *lvl;
-	int r = 1;
-
-	dm_list_iterate_items(lvl, lvs)
-		if (!resume_lv(cmd, lvl->lv)) {
-			r = 0;
-			stack;
-		}
-
-	return r;
-}
-
-/* Unlock and revert list of LVs */
-int revert_lvs(struct cmd_context *cmd, struct dm_list *lvs)
-{
-	struct lv_list *lvl;
-	int r = 1;
-
-	dm_list_iterate_items(lvl, lvs)
-		if (!revert_lv(cmd, lvl->lv)) {
-			r = 0;
-			stack;
-		}
-
-	return r;
-}
-/*
- * Lock a list of LVs.
- * On failure to lock any LV, calls vg_revert() if vg_to_revert is set and 
- * then unlocks any LVs on the list already successfully locked.
- */
-int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
-		struct volume_group *vg_to_revert)
-{
-	struct lv_list *lvl;
-
-	dm_list_iterate_items(lvl, lvs) {
-		if (!suspend_lv(cmd, lvl->lv)) {
-			log_error("Failed to suspend %s", display_lvname(lvl->lv));
-			if (vg_to_revert)
-				vg_revert(vg_to_revert);
-			/*
-			 * FIXME Should be
-			 * 	dm_list_uniterate(lvh, lvs, &lvl->list) {
-			 *	lvl = dm_list_item(lvh, struct lv_list);
-			 * but revert would need fixing to use identical tree deps first.
-			 */
-			dm_list_iterate_items(lvl, lvs)
-				if (!revert_lv(cmd, lvl->lv))
-					stack;
-
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
 /*
  * First try to activate exclusively locally.
  * Then if the VG is clustered and the LV is not yet active (e.g. due to 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 4b5490e..47841ed 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -262,10 +262,6 @@ int sync_dev_names(struct cmd_context* cmd);
 
 /* Process list of LVs */
 struct volume_group;
-int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
-		struct volume_group *vg_to_revert);
-int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs);
-int revert_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 
 #endif
diff --git a/tools/pvmove.c b/tools/pvmove.c
index ff36b55..7bf1713 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -303,32 +303,6 @@ static int _sub_lv_of(struct logical_volume *lv, const char *lv_name)
 	return _sub_lv_of(seg->lv, lv_name);
 }
 
-/*
- * parent_lv_is_cache_type
- *
- * FIXME: This function can be removed when 'pvmove' is supported for
- *        cache types.
- *
- * If this LV is below a cache LV (at any depth), return 1.
- */
-static int _parent_lv_is_cache_type(struct logical_volume *lv)
-{
-	struct lv_segment *seg;
-
-	/* Sub-LVs only ever have one segment using them */
-	if (dm_list_size(&lv->segs_using_this_lv) != 1)
-		return 0;
-
-	if (!(seg = get_only_segment_using_this_lv(lv)))
-		return_0;
-
-	if (lv_is_cache_type(seg->lv))
-		return 1;
-
-	/* Continue up the tree */
-	return _parent_lv_is_cache_type(seg->lv);
-}
-
 /* Create new LV with mirror segments for the required copies */
 static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						struct volume_group *vg,
@@ -450,48 +424,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
-		if (lv_is_cache_type(lv)) {
-			log_print_unless_silent("Skipping %s LV, %s.",
-						lv_is_cache(lv) ? "cache" :
-						lv_is_cache_pool(lv) ?
-						"cache-pool" : "cache-related",
-						lv->name);
-			lv_skipped = 1;
-			continue;
-		}
-
-		if (_parent_lv_is_cache_type(lv)) {
-			log_print_unless_silent("Skipping %s because a parent"
-						" is of cache type.", lv->name);
-			lv_skipped = 1;
-			continue;
-		}
-
-		/*
-		 * If the VG is clustered, we are unable to handle
-		 * snapshots, origins, thin types, RAID or mirror
-		 */
-		if ((vg_is_clustered(vg) || is_lockd_type(vg->lock_type)) &&
-		    (lv_is_origin(lv) || lv_is_cow(lv) ||
-		     lv_is_thin_type(lv) || lv_is_raid_type(lv))) {
-			log_print_unless_silent("Skipping %s LV %s.",
-						lv_is_origin(lv) ? "origin" :
-						lv_is_cow(lv) ?
-						"snapshot-related" :
-						lv_is_thin_volume(lv) ? "thin" :
-						lv_is_thin_pool(lv) ?
-						"thin-pool" :
-						lv_is_thin_type(lv) ?
-						"thin-related" :
-						seg_is_raid(first_seg(lv)) ?
-						"RAID" :
-						lv_is_raid_type(lv) ?
-						"RAID-related" : "",
-						lv->name);
-			lv_skipped = 1;
-			continue;
-		}
-
 		seg = first_seg(lv);
 		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
 		    lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {


