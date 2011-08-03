From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 03 Aug 2011 09:44:27 -0500
Subject: [PATCH 4 of 5] LVM RAID: Add down-convert support for RAID1
In-Reply-To: <1312381844.1169.8.camel@f14.redhat.com>
References: <1312381844.1169.8.camel@f14.redhat.com>
Message-ID: <1312382667.1169.22.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -39,7 +39,7 @@ struct lvconvert_params {
 	uint32_t stripes;
 	uint32_t stripe_size;
 
-	struct segment_type *segtype;
+	const struct segment_type *segtype;
 
 	alloc_policy_t alloc;
 
@@ -1366,6 +1366,62 @@ static int _lvconvert_mirrors(struct cmd
 	return 1;
 }
 
+static int is_valid_raid_conversion(const struct segment_type *from_segtype,
+				    const struct segment_type *to_segtype)
+{
+	if (from_segtype == to_segtype)
+		return 1;
+
+	if (!segtype_is_raid(from_segtype) && !segtype_is_raid(to_segtype))
+		return_0;  /* Not converting to or from RAID? */
+
+	return 0;
+}
+
+static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
+{
+	int image_count;
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!arg_count(cmd, type_ARG))
+		lp->segtype = seg->segtype;
+
+	if (arg_count(cmd, mirrors_ARG) && !seg_is_mirrored(seg)) {
+		log_error("'--mirrors/-m' is not compatible with %s",
+			  seg->segtype->name);
+		return 0;
+	}
+
+	if (!is_valid_raid_conversion(seg->segtype, lp->segtype)) {
+		log_error("Unable to convert %s/%s from %s to %s",
+			  lv->vg->name, lv->name,
+			  seg->segtype->name, lp->segtype->name);
+		return 0;
+	}
+
+	/* Change number of RAID1 images */
+	if (arg_count(cmd, mirrors_ARG)) {
+		image_count = lv_raid_image_count(lv);
+		if (lp->mirrors_sign == SIGN_PLUS)
+			image_count += lp->mirrors;
+		else if (lp->mirrors_sign == SIGN_MINUS)
+			image_count -= lp->mirrors;
+		else
+			image_count = lp->mirrors + 1;
+
+		if (image_count < 1) {
+			log_error("Unable to reduce images by specified amount");
+			return 0;
+		}
+
+		return lv_raid_change_image_count(lv, image_count, lp->pvh);
+	}
+
+	log_error("Conversion operation not yet supported.");
+	return 0;
+}
+
 static int lvconvert_snapshot(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
@@ -1580,6 +1636,24 @@ static int _lvconvert_single(struct cmd_
 			stack;
 			return ECMD_FAILED;
 		}
+	} else if (segtype_is_raid(lp->segtype) || (lv->status & RAID)) {
+		if (!archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		if (!lvconvert_raid(lv, lp)) {
+			stack;
+			return ECMD_FAILED;
+		}
+
+		if (!(failed_pvs = _failed_pv_list(lv->vg))) {
+			stack;
+			return ECMD_FAILED;
+		}
+
+		/* If repairing and using policies, remove missing PVs from VG */
+		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
+			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	} else if (arg_count(cmd, mirrors_ARG) ||
 		   arg_count(cmd, splitmirrors_ARG) ||
 		   (lv->status & MIRRORED)) {
Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- /dev/null
+++ LVM2/lib/metadata/raid_manip.c
@@ -0,0 +1,418 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "metadata.h"
+#include "toolcontext.h"
+#include "segtype.h"
+#include "display.h"
+#include "archiver.h"
+#include "activate.h"
+#include "lv_alloc.h"
+#include "lvm-string.h"
+#include "str_list.h"
+#include "memlock.h"
+
+/* Useful macros that I don't think would be useful elsewhere */
+#define seg_metatype(seg, s) (seg)->meta_areas[(s)].type
+
+uint32_t lv_raid_image_count(const struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_raid(seg))
+		return 1;
+
+	return seg->area_count;
+}
+
+static int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, pvs)
+		if (pv_is_in_lv(lv, pvl->pv)) {
+			log_very_verbose("%s is on %s", lv->name,
+					 pv_dev_name(pvl->pv));
+			return 1;
+		} else
+			log_very_verbose("%s is not on %s", lv->name,
+					 pv_dev_name(pvl->pv));
+	return 0;
+}
+
+static int raid_in_sync(struct logical_volume *lv)
+{
+	percent_t sync_percent;
+
+	if (!lv_raid_percent(lv, &sync_percent)) {
+		log_error("Unable to determine sync status of %s/%s.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return (sync_percent == PERCENT_100) ? 1 : 0;
+}
+
+/*
+ * _shift_and_rename_image_components
+ * @seg: Top-level RAID segment
+ *
+ * Shift all higher indexed segment areas down to fill in gaps where
+ * there are 'AREA_UNASSIGNED' areas and rename data/metadata LVs so
+ * that their names match their new index.  When finished, set
+ * seg->area_count to new reduced total.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int _shift_and_rename_image_components(struct lv_segment *seg)
+{
+	int len;
+	char *shift_name;
+	uint32_t s, missing;
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+
+	/*
+	 * All LVs must be properly named for their index before
+	 * shifting begins.  (e.g.  Index '0' must contain *_rimage_0 and
+	 * *_rmeta_0.  Index 'n' must contain *_rimage_n and *_rmeta_n.)
+	 */
+
+	if (!seg_is_raid(seg))
+		return_0;
+
+	if (seg->area_count > 10) {
+		/* Handling more would mean I'd have to handle double digits */
+		log_error("Unable handle arrays with more than 10 devices");
+		return 0;
+	}
+
+	log_very_verbose("Shifting images in %s", seg->lv->name);
+
+	for (s = 0, missing = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) == AREA_UNASSIGNED) {
+			if (seg_metatype(seg, s) != AREA_UNASSIGNED) {
+				log_error(INTERNAL_ERROR "Metadata segment area"
+					  " #%d should be AREA_UNASSIGNED", s);
+				return 0;
+			}
+			missing++;
+			continue;
+		}
+		if (!missing)
+			continue;
+
+		log_very_verbose("Shifting %s and %s by %u",
+				 seg_metalv(seg, s)->name,
+				 seg_lv(seg, s)->name, missing);
+
+		/* Alter rmeta name */
+		shift_name = dm_pool_strdup(cmd->mem, seg_metalv(seg, s)->name);
+		if (!shift_name)
+			return_0;
+		len = strlen(shift_name) - 1;
+		shift_name[len] -= missing;
+		seg_metalv(seg, s)->name = shift_name;
+
+		/* Alter rimage name */
+		shift_name = dm_pool_strdup(cmd->mem, seg_lv(seg, s)->name);
+		if (!shift_name)
+			return_0;
+		len = strlen(shift_name) - 1;
+		shift_name[len] -= missing;
+		seg_lv(seg, s)->name = shift_name;
+
+		seg->areas[s - missing] = seg->areas[s];
+		seg->meta_areas[s - missing] = seg->meta_areas[s];
+	}
+
+	seg->area_count -= missing;
+	return 1;
+}
+
+static int raid_add_images(struct logical_volume *lv,
+			   uint32_t new_count, struct dm_list *pvs)
+{
+	/* Not implemented */
+	log_error("Unable to add images to LV, %s/%s",
+		  lv->vg->name, lv->name);
+
+	return 0;
+}
+
+/*
+ * _extract_image_components
+ * @seg
+ * @idx:  The index in the areas array to remove
+ * @extracted_rmeta:  The displaced metadata LV
+ * @extracted_rimage:  The displaced data LV
+ *
+ * This function extracts the image components - setting the respective
+ * 'extracted' pointers.  It appends 'EXTRACTED' to the LVs' names, so that
+ * there are not future conflicts.  It does /not/ commit the results.
+ * (IOW, erroring-out requires no unwinding of operations.)
+ *
+ * This function does /not/ attempt to:
+ *    1) shift the 'areas' or 'meta_areas' arrays.
+ *       The '[meta_]areas' are left as AREA_UNASSIGNED.
+ *    2) Adjust the seg->area_count
+ *    3) Name the extracted LVs appropriately (appends 'EXTRACTED' to names)
+ * These actions must be performed by the caller.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
+				     struct logical_volume **extracted_rmeta,
+				     struct logical_volume **extracted_rimage)
+{
+	int len;
+	char *tmp_name;
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	struct logical_volume *data_lv = seg_lv(seg, idx);
+	struct logical_volume *meta_lv = seg_metalv(seg, idx);
+
+	log_very_verbose("Extracting image components %s and %s from %s",
+			 data_lv->name, meta_lv->name, seg->lv->name);
+
+	data_lv->status &= ~RAID_IMAGE;
+	meta_lv->status &= ~RAID_META;
+	lv_set_visible(data_lv);
+	lv_set_visible(meta_lv);
+
+	/* release removes data and meta areas */
+	remove_seg_from_segs_using_this_lv(data_lv, seg);
+	remove_seg_from_segs_using_this_lv(meta_lv, seg);
+
+	seg_type(seg, idx) = AREA_UNASSIGNED;
+	seg_metatype(seg, idx) = AREA_UNASSIGNED;
+
+	len = strlen(meta_lv->name) + strlen("EXTRACTED") + 1;
+	tmp_name = dm_pool_alloc(cmd->mem, len);
+	if (!tmp_name)
+		return_0;
+	sprintf(tmp_name, "%sEXTRACTED", meta_lv->name);
+	meta_lv->name = tmp_name;
+
+	len = strlen(data_lv->name) + strlen("EXTRACTED") + 1;
+	tmp_name = dm_pool_alloc(cmd->mem, len);
+	if (!tmp_name)
+		return_0;
+	sprintf(tmp_name, "%sEXTRACTED", data_lv->name);
+	data_lv->name = tmp_name;
+
+	*extracted_rmeta = meta_lv;
+	*extracted_rimage = data_lv;
+
+	return 1;
+}
+
+/*
+ * raid_extract_images
+ * @lv
+ * @new_count:  The absolute count of images (e.g. '2' for a 2-way mirror)
+ * @target_pvs:  The list of PVs that are candidates for removal
+ * @shift:  If set, use _shift_and_rename_image_components().
+ *          Otherwise, leave the [meta_]areas as AREA_UNASSIGNED and
+ *          seg->area_count unchanged.
+ * @extracted_[meta|data]_lvs:  The LVs removed from the array.  If 'shift'
+ *                              is set, then there will likely be name conflicts.
+ *
+ * This function extracts _both_ portions of the indexed image.  It
+ * does /not/ commit the results.  (IOW, erroring-out requires no unwinding
+ * of operations.)
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int raid_extract_images(struct logical_volume *lv, uint32_t new_count,
+			       struct dm_list *target_pvs, int shift,
+			       struct dm_list *extracted_meta_lvs,
+			       struct dm_list *extracted_data_lvs)
+{
+	int s, extract, lvl_idx = 0;
+	struct lv_list *lvl_array;
+	struct lv_segment *seg = first_seg(lv);
+	struct logical_volume *rmeta_lv, *rimage_lv;
+
+	extract = seg->area_count - new_count;
+	log_verbose("Extracting %u %s from %s/%s", extract,
+		    (extract > 1) ? "images" : "image",
+		    lv->vg->name, lv->name);
+
+	lvl_array = dm_pool_alloc(lv->vg->cmd->mem,
+				  sizeof(*lvl_array) * extract * 2);
+	if (!lvl_array)
+		return_0;
+
+	for (s = seg->area_count - 1; (s >= 0) && extract; s--) {
+		if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+		    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
+			continue;
+		if (!raid_in_sync(lv) &&
+		    (!seg_is_mirrored(seg) || (s == 0))) {
+			log_error("Unable to extract %sRAID image"
+				  " while RAID array is not in-sync",
+				  seg_is_mirrored(seg) ? "primary " : "");
+			return 0;
+		}
+
+		if (!_extract_image_components(seg, s, &rmeta_lv, &rimage_lv)) {
+			log_error("Failed to extract %s from %s",
+				  seg_lv(seg, s)->name, lv->name);
+			return 0;
+		}
+
+		if (shift && !_shift_and_rename_image_components(seg)) {
+			log_error("Failed to shift and rename image components");
+			return 0;
+		}
+
+		lvl_array[lvl_idx].lv = rmeta_lv;
+		lvl_array[lvl_idx + 1].lv = rimage_lv;
+		dm_list_add(extracted_meta_lvs, &(lvl_array[lvl_idx++].list));
+		dm_list_add(extracted_data_lvs, &(lvl_array[lvl_idx++].list));
+
+		extract--;
+	}
+	if (extract) {
+		log_error("Unable to extract enough images to satisfy request");
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * lv_raid_change_image_count
+ * @lv
+ * @new_count: The absolute count of images (e.g. '2' for a 2-way mirror)
+ * @pvs: The list of PVs that are candidates for removal (or empty list)
+ *
+ * RAID arrays have 'images' which are composed of two parts, they are:
+ *    - 'rimage': The data/parity holding portion
+ *    - 'rmeta' : The metadata holding portion (i.e. superblock/bitmap area)
+ * This function adds or removes _both_ portions of the image and commits
+ * the results.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+int lv_raid_change_image_count(struct logical_volume *lv,
+			       uint32_t new_count, struct dm_list *pvs)
+{
+	int r;
+	uint32_t old_count = lv_raid_image_count(lv);
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list removal_list;
+	struct lv_list *lvl_array, *lvl;
+
+	dm_list_init(&removal_list);
+
+	if (!seg_is_mirrored(seg)) {
+		log_error("Unable to change image count of non-mirrored RAID.");
+		return 0;
+	}
+
+	if (old_count == new_count) {
+		log_verbose("%s/%s already has image count of %d",
+			    lv->vg->name, lv->name, new_count);
+		return 1;
+	}
+
+	if (old_count > new_count)
+		r = raid_extract_images(lv, new_count, pvs, 1,
+					&removal_list, &removal_list);
+	else
+		r = raid_add_images(lv, new_count, pvs);
+	if (!r)
+		return 0;
+
+	/* Convert to linear? */
+	if (new_count == 1) {
+		/* Add last metadata area to removal_list */
+		lvl_array = dm_pool_alloc(lv->vg->cmd->mem, 2 * sizeof(*lvl));
+		if (!lvl_array)
+			return_0;
+		lvl_array[0].lv = seg_metalv(seg, 0);
+		remove_seg_from_segs_using_this_lv(seg_metalv(seg, 0), seg);
+		seg_metatype(seg, 0) = AREA_UNASSIGNED;
+		dm_list_add(&removal_list, &(lvl_array[0].list));
+
+		/* Remove RAID layer */
+		seg_lv(seg, 0)->status &= ~RAID_IMAGE;
+		lv_set_visible(seg_lv(seg, 0));
+		lvl_array[1].lv = seg_lv(seg, 0);
+		dm_list_add(&removal_list, &(lvl_array[1].list));
+
+		if (!remove_layer_from_lv(lv, seg_lv(seg, 0)))
+			return_0;
+		lv->status &= ~(MIRRORED | RAID);
+	}
+
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to suspend %s/%s before committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		log_error("Failed to commit changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	/*
+	 * Bring extracted LVs into existance, so there are no
+	 * conflicts for the main RAID device's resume
+	 */
+	if (!dm_list_empty(&removal_list)) {
+		dm_list_iterate_items(lvl, &removal_list) {
+			/* If top RAID was EX, use EX */
+			if (lv_is_active_exclusive_locally(lv)) {
+				if (!activate_lv_excl(lv->vg->cmd, lvl->lv))
+					return_0;
+			} else {
+				if (!activate_lv(lv->vg->cmd, lvl->lv))
+					return_0;
+			}
+		}
+	}
+
+	if (!resume_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/*
+	 * Eliminate the extracted LVs
+	 */
+	if (!dm_list_empty(&removal_list)) {
+		dm_list_iterate_items(lvl, &removal_list) {
+			if (!deactivate_lv(lv->vg->cmd, lvl->lv))
+				return_0;
+			if (!lv_remove(lvl->lv))
+				return_0;
+		}
+
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+			return_0;
+	}
+
+	return 1;
+}
Index: LVM2/lib/Makefile.in
===================================================================
--- LVM2.orig/lib/Makefile.in
+++ LVM2/lib/Makefile.in
@@ -85,6 +85,7 @@ SOURCES =\
 	metadata/pv.c \
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
+	metadata/raid_manip.c \
 	metadata/replicator_manip.c \
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -743,6 +743,13 @@ int lv_is_rlog(const struct logical_volu
 int lv_is_slog(const struct logical_volume *lv);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
+
+/* ++  metadata/raid_manip.c */
+uint32_t lv_raid_image_count(const struct logical_volume *lv);
+int lv_raid_change_image_count(struct logical_volume *lv,
+			       uint32_t new_count, struct dm_list *pvs);
+/* --  metadata/raid_manip.c */
+
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
 			  const char *vg_name, const char *vgid,
 			  uint32_t flags);




