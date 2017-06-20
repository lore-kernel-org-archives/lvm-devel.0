From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 20 Jun 2017 12:57:37 -0400
Subject: master - raid: avoid explicit activation of SubLVs on reshape/takeover
Message-ID: <201706201657.v5KGvbLk019170@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76314183e28321741bec1cb769a7d8a77e5faa81
Commit:        76314183e28321741bec1cb769a7d8a77e5faa81
Parent:        0dfe1bc29d0ba4da31e83e25d338bfe46209c96c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 20 18:56:45 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 20 18:56:45 2017 +0200

raid: avoid explicit activation of SubLVs on reshape/takeover

Remove explicit activation of SubLVs and let lv_update_and_reload()
perform the proper (pre-)loading sequencing of tables.
This avoids related callback functions which are removed.

Related: rhbz1448116
Related: rhbz1461526
Related: rhbz1448123
---
 lib/metadata/raid_manip.c |   54 +-------------------------------------------
 1 files changed, 2 insertions(+), 52 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a832f7b..8a5ae32 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2160,24 +2160,6 @@ static int _activate_sub_lv_excl_local(struct logical_volume *lv)
 	return 1;
 }
 
-/* Helper: function to activate any sub LVs of @lv exclusively local starting with area indexed by @start_idx */
-static int _activate_sub_lvs_excl_local(struct logical_volume *lv, uint32_t start_idx)
-{
-	uint32_t s;
-	struct lv_segment *seg = first_seg(lv);
-
-	/* seg->area_count may be 0 here! */
-	log_debug_metadata("Activating %u image component%s of LV %s.",
-			   seg->area_count - start_idx, seg->meta_areas ? " pairs" : "s",
-			   display_lvname(lv));
-	for (s = start_idx; s < seg->area_count; s++)
-		if (!_activate_sub_lv_excl_local(seg_lv(seg, s)) ||
-		    (seg->meta_areas && !_activate_sub_lv_excl_local(seg_metalv(seg, s))))
-			return_0;
-
-	return 1;
-}
-
 /* Helper: function to activate any LVs on @lv_list */
 static int _activate_sub_lvs_excl_local_list(struct logical_volume *lv, struct dm_list *lv_list)
 {
@@ -2196,20 +2178,6 @@ static int _activate_sub_lvs_excl_local_list(struct logical_volume *lv, struct d
 	return r;
 }
 
-/* Helper: callback function to activate image component pairs of @lv to update size after reshape space allocation */
-static int _pre_raid_reactivate_legs(struct logical_volume *lv, void *data)
-{
-	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
-		return 0;
-
-	/* Reload any changed image component pairs for out-of-place reshape space */
-	if (!_activate_sub_lvs_excl_local(lv, 0))
-		return 0;
-
-	/* 1: ok+ask caller to update, 2: metadata commited+ask caller to resume */
-	return 2;
-}
-
 /* Helper: callback function to activate any rmetas on @data list */
 __attribute__ ((__unused__))
 static int _pre_raid0_remove_rmeta(struct logical_volume *lv, void *data)
@@ -2223,20 +2191,6 @@ static int _pre_raid0_remove_rmeta(struct logical_volume *lv, void *data)
 	return _activate_sub_lvs_excl_local_list(lv, lv_list) ? 2 : 0;
 }
 
-/* Helper: callback dummy needed for takeover+reshape */
-static int _post_raid_reshape(struct logical_volume *lv, void *data)
-{
-	/* 1: ask caller to update, 2: don't ask caller to update */
-	return 1;
-}
-
-/* Helper: callback dummy needed for takeover+reshape */
-static int _post_raid_takeover(struct logical_volume *lv, void *data)
-{
-	/* 1: ask caller to update, 2: don't ask caller to update */
-	return 2;
-}
-
 /*
  * Reshape logical volume @lv by adding/removing stripes
  * (absolute new stripes given in @new_stripes), changing
@@ -2404,9 +2358,7 @@ static int _raid_reshape(struct logical_volume *lv,
 		return 0;
 
 	if (seg->area_count != 2 || old_image_count != seg->area_count) {
-		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
-							       _post_raid_reshape, NULL,
-							       _pre_raid_reactivate_legs, NULL))
+		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 			return 0;
 	} if (!_vg_write_commit_backup(lv->vg))
 		return 0;
@@ -5454,9 +5406,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 
 	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
-						       _post_raid_takeover, NULL,
-						       _pre_raid_reactivate_legs, NULL))
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 		return 0;
 
 	if (segtype_is_raid4(new_segtype) &&


