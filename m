From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:13 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063213.64D0B60AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=929cf4b73ca6112e59e5e85cf3a2f3992747883b
Commit:        929cf4b73ca6112e59e5e85cf3a2f3992747883b
Parent:        4de0e692dba592206c8bb1f5000b4a6e445914a5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 02:39:04 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- add vg metadata update functions
- add pre and post activation callback functions for
  proper sequencing of sub lv activations during reshaping
- move and enhance _lv_update_reload_fns_reset_eliminate_lvs()
  to support pre and post activation callbacks
- add _reset_flags_passed_to_kernel() which resets anyxi
  rebuild/reshape flags after they have been passed into the kernel
  and sets the SubLV remove after reshape flags on legs to be removed

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |  345 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 269 insertions(+), 76 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1cee8c3..63588ad 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -22,6 +22,11 @@
 #include "lv_alloc.h"
 #include "lvm-string.h"
 
+typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
+static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
+						      struct dm_list *removal_lvs,
+						      int vg_write_requested);
+
 static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 {
 	if (new_stripes && new_stripes != first_seg(lv)->area_count) {
@@ -404,6 +409,141 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	return 1;
 }
 
+/* Reset any rebuild or reshape disk flags on @lv, first segment already passed to the kernel */
+static int _reset_flags_passed_to_kernel(struct logical_volume *lv, int *flags_reset)
+{
+	uint32_t lv_count = 0, s;
+	struct logical_volume *slv;
+	struct lv_segment *seg = first_seg(lv);
+	uint64_t reset_flags = LV_REBUILD | LV_RESHAPE_DELTA_DISKS_PLUS | LV_RESHAPE_DELTA_DISKS_MINUS;
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) == AREA_PV)
+			continue;
+
+		if (!(slv = seg_lv(seg, s)))
+			return_0;
+
+		/* Recurse into sub LVs */
+		if (!_reset_flags_passed_to_kernel(slv, flags_reset))
+			return 0;
+
+		if (slv->status & LV_RESHAPE_DELTA_DISKS_MINUS) {
+			*flags_reset = 1;
+			slv->status |= LV_REMOVE_AFTER_RESHAPE;
+			seg_metalv(seg, s)->status |= LV_REMOVE_AFTER_RESHAPE;
+		}
+
+		if (slv->status & reset_flags) {
+			*flags_reset = 1;
+			slv->status &= ~reset_flags;
+		}
+
+		lv_count++;
+	}
+
+	/* Reset passed in data offset (reshaping) */
+	if (lv_count)
+		seg->data_offset = 0;
+
+	return 1;
+}
+
+/*
+ * HM Helper:
+ *
+ * Minimum 4 arguments!
+ *
+ * Updates and reloads metadata, clears any flags passed to the kernel,
+ * eliminates any residual LVs and updates and reloads metadata again.
+ *
+ * @lv mandatory argument, rest variable:
+ *
+ * @lv @origin_only @removal_lvs/NULL @fn_post_on_lv/NULL [ @fn_post_data/NULL [ @fn_post_on_lv/NULL @fn_post_data/NULL ] ]
+ *
+ * Run optional variable args function fn_post_on_lv with fn_post_data on @lv before second metadata update
+ * Run optional variable args function fn_pre_on_lv with fn_pre_data on @lv before first metadata update
+ *
+ * This minimaly involves 2 metadata commits or more, depending on
+ * pre and post functions carrying out any additional ones or not.
+ *
+ * WARNING: needs to be called with at least 4 arguments to suit va_list processing!
+ */
+static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv, int origin_only, ...)
+{
+	int flags_reset = 0, r = 0;
+	va_list ap;
+	fn_on_lv_t fn_pre_on_lv = NULL, fn_post_on_lv;
+	void *fn_pre_data, *fn_post_data;
+	struct dm_list *removal_lvs;
+
+	va_start(ap, origin_only);
+	removal_lvs = va_arg(ap, struct dm_list *);
+
+	/* Retrieve post/pre functions and post/pre data reference from variable arguments, if any */
+	if ((fn_post_on_lv = va_arg(ap, fn_on_lv_t))) {
+		fn_post_data = va_arg(ap, void *);
+		if ((fn_pre_on_lv = va_arg(ap, fn_on_lv_t)))
+			fn_pre_data = va_arg(ap, void *);
+	}
+
+	/* Call any efn_pre_on_lv before the first update and reload call (e.g. to rename LVs) */
+	if (fn_pre_on_lv && !(r = fn_pre_on_lv(lv, fn_pre_data))) {
+		log_error(INTERNAL_ERROR "Pre callout function failed.");
+		goto err;
+	}
+
+	if (r == 2) {
+		/*
+		 * Returning 2 from pre function -> lv is suspended and
+		 * metadata got updated, don't need to do it again
+		 */
+		if (!(origin_only ? resume_lv_origin(lv->vg->cmd, lv_lock_holder(lv)) :
+				    resume_lv(lv->vg->cmd, lv_lock_holder(lv)))) {
+			log_error("Failed to resume %s.", display_lvname(lv));
+			goto err;
+		}
+
+	/* Update metadata and reload mappings including flags (e.g. LV_REBUILD, LV_RESHAPE_DELTA_DISKS_PLUS) */
+	} else if (!(origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))
+		goto err;
+
+	/* Eliminate any residual LV and don't commit the metadata */
+	if (!_eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0))
+		goto err;
+
+	/*
+	 * Now that any 'REBUILD' or 'RESHAPE_DELTA_DISKS' etc.
+	 * has/have made its/their way to the kernel, we must
+	 * remove the flag(s) so that the individual devices are
+	 * not rebuilt/reshaped/taken over upon every activation.
+	 *
+	 * Writes and commits metadata if any flags have been reset
+	 * and if successful, performs metadata backup.
+	 */
+	log_debug_metadata("Clearing any flags for %s passed to the kernel.", display_lvname(lv));
+	if (!_reset_flags_passed_to_kernel(lv, &flags_reset))
+		goto err;
+
+	/* Call any @fn_post_on_lv before the second update call (e.g. to rename LVs back) */
+	if (fn_post_on_lv && !(r = fn_post_on_lv(lv, fn_post_data))) {
+		log_error("Post callout function failed.");
+		goto err;
+	}
+
+	/* Update and reload to clear out reset flags in the metadata and in the kernel */
+	log_debug_metadata("Updating metadata mappings for %s.", display_lvname(lv));
+	if ((r != 2 || flags_reset) && !(origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))) {
+		log_error(INTERNAL_ERROR "Update of LV %s failed.", display_lvname(lv));
+		goto err;
+	}
+
+	r = 1;
+err:
+	va_end(ap);
+	return r;
+}
+
 /*
  * Assisted excl_local activation of lvl listed LVs before resume
  *
@@ -1852,6 +1992,131 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 	return 1;
 }
 
+/* HM Helper: write, optionally suspend @lv (origin), commit and optionally backup metadata of @vg */
+static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
+					      struct logical_volume *lv,
+					      int origin_only, int do_backup)
+{
+	int r = 1;
+
+	if (!vg_write(vg)) {
+		log_error("Write of VG %s failed.", vg->name);
+		return_0;
+	}
+
+	if (lv && !(r = (origin_only ? suspend_lv_origin(vg->cmd, lv_lock_holder(lv)) :
+				       suspend_lv(vg->cmd, lv_lock_holder(lv))))) {
+		log_error("Failed to suspend %s before committing changes.",
+			  display_lvname(lv));
+		vg_revert(lv->vg);
+	} else if (!(r = vg_commit(vg)))
+		stack; /* !vg_commit() has implicit vg_revert() */
+
+	if (r && do_backup && !backup(vg))
+		log_error("Backup of VG %s failed; continuing.", vg->name);
+
+	return r;
+}
+
+__attribute__ ((__unused__))
+static int _vg_write_commit_backup(struct volume_group *vg)
+{
+	return _vg_write_lv_suspend_commit_backup(vg, NULL, 1, 1);
+}
+
+__attribute__ ((__unused__))
+static int _vg_write_commit(struct volume_group *vg)
+{
+	return _vg_write_lv_suspend_commit_backup(vg, NULL, 1, 0);
+}
+
+/* Write vg of @lv, suspend @lv and commit the vg */
+static int _vg_write_lv_suspend_vg_commit(struct logical_volume *lv, int origin_only)
+{
+	return _vg_write_lv_suspend_commit_backup(lv->vg, lv, origin_only, 0);
+}
+
+/* Helper: function to activate @lv exclusively local */
+static int _activate_sub_lv_excl_local(struct logical_volume *lv)
+{
+	if (lv && !activate_lv_excl_local(lv->vg->cmd, lv)) {
+		log_error("Failed to activate %s.", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
+/* Helper: function to activate any sub LVs of @lv exclusively local starting with area indexed by @start_idx */
+static int _activate_sub_lvs_excl_local(struct logical_volume *lv, uint32_t start_idx)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+
+	/* seg->area_count may be 0 here! */
+	log_debug_metadata("Activating %u image component%s of LV %s.",
+			   seg->area_count - start_idx, seg->meta_areas ? " pairs" : "s",
+			   display_lvname(lv));
+	for (s = start_idx; s < seg->area_count; s++)
+		if (!_activate_sub_lv_excl_local(seg_lv(seg, s)) ||
+		    !_activate_sub_lv_excl_local(seg_metalv(seg, s)))
+			return 0;
+
+	return 1;
+}
+
+/* Helper: function to activate any sub LVs of @lv exclusively local starting with area indexed by @start_idx */
+static int _activate_sub_lvs_excl_local_list(struct logical_volume *lv, struct dm_list *lv_list)
+{
+	int r = 1;
+	struct lv_list *lvl;
+
+	if (lv_list) {
+		dm_list_iterate_items(lvl, lv_list) {
+			log_very_verbose("Activating logical volume %s before %s in kernel.",
+					 display_lvname(lvl->lv), display_lvname(lv_lock_holder(lv)));
+			if (!_activate_sub_lv_excl_local(lvl->lv))
+				r = 0; /* But lets try with the rest */
+		}
+	}
+
+	return r;
+}
+
+/* Helper: callback function to activate any new image component pairs @lv */
+__attribute__ ((__unused__))
+static int _pre_raid_add_legs(struct logical_volume *lv, void *data)
+{
+	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
+		return 0;
+
+	/* Reload any changed image component pairs for out-of-place reshape apace */
+	if (!_activate_sub_lvs_excl_local(lv, 0))
+		return 0;
+
+	return 2; /* 1: ok, 2: metadata commited */
+}
+
+/* Helper: callback function to activate any rmetas on @data list */
+__attribute__ ((__unused__))
+static int _pre_raid0_remove_rmeta(struct logical_volume *lv, void *data)
+{
+	struct dm_list *lv_list = data;
+
+	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
+		return 0;
+
+	/* 1: ok, 2: metadata commited */
+	return _activate_sub_lvs_excl_local_list(lv, lv_list) ? 2 : 0;
+}
+
+/* Helper: callback dummy needed for */
+__attribute__ ((__unused__))
+static int _post_raid_dummy(struct logical_volume *lv, void *data)
+{
+	return 1;
+}
+
 /*
  * _alloc_rmeta_for_lv
  * @lv
@@ -3077,78 +3342,6 @@ static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
 }
 
 /*
- * Clear any rebuild disk flags on lv.
- * If any flags were cleared, *flags_were_cleared is set to 1.
- */
-/* FIXME Generalise into foreach_underlying_lv_segment_area. */
-static void _clear_rebuild_flags(struct logical_volume *lv, int *flags_were_cleared)
-{
-	struct lv_segment *seg = first_seg(lv);
-	struct logical_volume *sub_lv;
-	uint32_t s;
-	uint64_t flags_to_clear = LV_REBUILD;
-
-	for (s = 0; s < seg->area_count; s++) {
-		if (seg_type(seg, s) == AREA_PV)
-			continue;
-
-		sub_lv = seg_lv(seg, s);
-
-		/* Recurse into sub LVs */
-		_clear_rebuild_flags(sub_lv, flags_were_cleared);
-
-		if (sub_lv->status & flags_to_clear) {
-			sub_lv->status &= ~flags_to_clear;
-			*flags_were_cleared = 1;
-		}
-	}
-}
-
-/*
- * Updates and reloads metadata, clears any flags passed to the kernel,
- * eliminates any residual LVs and updates and reloads metadata again.
- *
- * lv removal_lvs
- *
- * This minimally involves 2 metadata commits.
- */
-static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv, struct dm_list *removal_lvs)
-{
-	int flags_were_cleared = 0, r = 0;
-
-	if (!_lv_update_and_reload_list(lv, 1, removal_lvs))
-		return_0;
-
-	/* Eliminate any residual LV and don't commit the metadata */
-	if (!_eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0))
-		return_0;
-
-	/*
-	 * Now that any 'REBUILD' or 'RESHAPE_DELTA_DISKS' etc.
-	 * has/have made its/their way to the kernel, we must
-	 * remove the flag(s) so that the individual devices are
-	 * not rebuilt/reshaped/taken over upon every activation.
-	 *
-	 * Writes and commits metadata if any flags have been reset
-	 * and if successful, performs metadata backup.
-	 */
-	/* FIXME This needs to be done through hooks in the metadata */
-	log_debug_metadata("Clearing any flags for %s passed to the kernel.",
-			   display_lvname(lv));
-	_clear_rebuild_flags(lv, &flags_were_cleared);
-
-	log_debug_metadata("Updating metadata and reloading mappings for %s.",
-			   display_lvname(lv));
-	if ((r != 2 || flags_were_cleared) && !lv_update_and_reload(lv)) {
-		log_error("Update and reload of LV %s failed.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
  * Adjust all data sub LVs of lv to mirror
  * or raid name depending on direction
  * adjusting their LV status
@@ -3357,7 +3550,7 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	if (!attach_mirror_log(first_seg(lv), log_lv))
 		return_0;
 
-	return update_and_reload ? _lv_update_reload_fns_reset_eliminate_lvs(lv, removal_lvs) : 1;
+	return update_and_reload ? _lv_update_reload_fns_reset_eliminate_lvs(lv, 0, removal_lvs, NULL) : 1;
 }
 
 /*
@@ -4288,7 +4481,7 @@ static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 	seg->region_size = new_region_size ?: region_size;
 
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 		return_0;
 
 	if (rename_sublvs) {
@@ -4365,7 +4558,7 @@ static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 	seg->region_size = new_region_size ?: region_size;
 	seg->segtype = new_segtype;
 
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 		return_0;
 
 	init_mirror_in_sync(0);
@@ -4486,7 +4679,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, NULL))
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, NULL, NULL))
 		return_0;
 
 	if (segtype_is_raid4(new_segtype)) {


