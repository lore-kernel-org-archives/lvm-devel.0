From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 15:18:49 -0400
Subject: master - raid: avoid superfluous reload on takeover
Message-ID: <201704201918.v3KJInep009666@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fb571740224a1a7670d20f23c444c602ef5cf85
Commit:        5fb571740224a1a7670d20f23c444c602ef5cf85
Parent:        c7fb0cb861104e99c11e8b4e031d981dab7891a1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 20 21:17:08 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 20 21:18:27 2017 +0200

raid: avoid superfluous reload on takeover

Allow any reset rebuild flags to trigger the second update on takeover.
Use descriptive callback names.
Fix typo and add comments.
---
 lib/metadata/raid_manip.c |   39 ++++++++++++++++++++++++---------------
 1 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 173b5bf..9114f60 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -518,7 +518,8 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 			fn_pre_data = va_arg(ap, void *);
 	}
 
-	/* Call any efn_pre_on_lv before the first update and reload call (e.g. to rename LVs) */
+	/* Call any fn_pre_on_lv before the first update and reload call (e.g. to rename LVs) */
+	/* returns 1: ok+ask caller to update, 2: metadata commited+ask caller to resume */
 	if (fn_pre_on_lv && !(r = fn_pre_on_lv(lv, fn_pre_data))) {
 		log_error(INTERNAL_ERROR "Pre callout function failed.");
 		goto err;
@@ -2100,7 +2101,7 @@ static int _activate_sub_lvs_excl_local(struct logical_volume *lv, uint32_t star
 	for (s = start_idx; s < seg->area_count; s++)
 		if (!_activate_sub_lv_excl_local(seg_lv(seg, s)) ||
 		    (seg->meta_areas && !_activate_sub_lv_excl_local(seg_metalv(seg, s))))
-			return 0;
+			return_0;
 
 	return 1;
 }
@@ -2123,17 +2124,18 @@ static int _activate_sub_lvs_excl_local_list(struct logical_volume *lv, struct d
 	return r;
 }
 
-/* Helper: callback function to activate any new image component pairs @lv */
-static int _pre_raid_add_legs(struct logical_volume *lv, void *data)
+/* Helper: callback function to activate image component pairs of @lv to update size after reshape space allocation */
+static int _pre_raid_reactivate_legs(struct logical_volume *lv, void *data)
 {
 	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
 		return 0;
 
-	/* Reload any changed image component pairs for out-of-place reshape apace */
+	/* Reload any changed image component pairs for out-of-place reshape space */
 	if (!_activate_sub_lvs_excl_local(lv, 0))
 		return 0;
 
-	return 2; /* 1: ok, 2: metadata commited */
+	/* 1: ok+ask caller to update, 2: metadata commited+ask caller to resume */
+	return 2;
 }
 
 /* Helper: callback function to activate any rmetas on @data list */
@@ -2145,16 +2147,24 @@ static int _pre_raid0_remove_rmeta(struct logical_volume *lv, void *data)
 	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
 		return 0;
 
-	/* 1: ok, 2: metadata commited */
+	/* 1: ok+ask caller to update, 2: metadata commited+ask caller to resume */
 	return _activate_sub_lvs_excl_local_list(lv, lv_list) ? 2 : 0;
 }
 
-/* Helper: callback dummy needed for */
-static int _post_raid_dummy(struct logical_volume *lv, void *data)
+/* Helper: callback dummy needed for takeover+reshape */
+static int _post_raid_reshape(struct logical_volume *lv, void *data)
 {
+	/* 1: ask caller to update, 2: don't ask caller to update */
 	return 1;
 }
 
+/* Helper: callback dummy needed for takeover+reshape */
+static int _post_raid_takeover(struct logical_volume *lv, void *data)
+{
+	/* 1: ask caller to update, 2: don't ask caller to update */
+	return 2;
+}
+
 /*
  * Reshape logical volume @lv by adding/removing stripes
  * (absolute new stripes given in @new_stripes), changing
@@ -2317,8 +2327,8 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	if (seg->area_count != 2 || old_image_count != seg->area_count) {
 		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
-							       _post_raid_dummy, NULL,
-							       _pre_raid_add_legs, NULL))
+							       _post_raid_reshape, NULL,
+							       _pre_raid_reactivate_legs, NULL))
 			return 0;
 	} if (!_vg_write_commit_backup(lv->vg))
 		return 0;
@@ -5106,7 +5116,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role change issues in the kernel */
 	}
 
-	if (seg_is_raid0_meta(seg) &&
+	if (segtype_is_raid0_meta(initial_segtype) &&
 	    segtype_is_raid4(new_segtype) &&
 	    !_clear_meta_lvs(lv))
 		return_0;
@@ -5155,7 +5165,6 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		seg = first_seg(lv);
 	}
 
-
 	seg->data_copies = new_data_copies;
 
 	if (segtype_is_raid4(new_segtype) &&
@@ -5193,8 +5202,8 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
-						       _post_raid_dummy, NULL,
-						       _pre_raid_add_legs, NULL))
+						       _post_raid_takeover, NULL,
+						       _pre_raid_reactivate_legs, NULL))
 		return 0;
 
 	if (segtype_is_raid4(new_segtype) &&


