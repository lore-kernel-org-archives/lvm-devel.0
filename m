From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 14:04:06 +0000 (UTC)
Subject: master - cleanup: add some dots and use display_lvname
Message-ID: <20161125140406.B4B52607B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a4f13eb6e4de75884f7950a5feeff90614b93cf
Commit:        1a4f13eb6e4de75884f7950a5feeff90614b93cf
Parent:        1d58074d9fc4a01c5ca99af0ba26a5521a541092
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 14:08:39 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:01:27 2016 +0100

cleanup: add some dots and use display_lvname

Just some more VG/LV printing.
---
 lib/activate/dev_manager.c |    6 ++--
 lib/metadata/lv_manip.c    |   62 +++++++++++++++++++++++--------------------
 lib/metadata/metadata.c    |    6 ++--
 lib/metadata/raid_manip.c  |   12 ++++----
 tools/lvcreate.c           |    2 +-
 tools/toollib.c            |   11 +++----
 tools/vgreduce.c           |   22 ++++++++--------
 7 files changed, 62 insertions(+), 59 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 642e6a1..b8b1235 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -424,7 +424,7 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 		return_0;
 
 	if (!dm_task_run(dmt)) {
-		log_error("Failed to get state of snapshot or snapshot origin device");
+		log_error("Failed to get state of snapshot or snapshot origin device.");
 		goto out;
 	}
 
@@ -432,13 +432,13 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 		if (!target_type || !strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
 			if (!params || sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
-				log_error("Incorrect snapshot table found");
+				log_error("Incorrect snapshot table found.");
 				goto out;
 			}
 			r = r || _device_is_suspended(major1, minor1) || _device_is_suspended(major2, minor2);
 		} else if (!strcmp(target_type, TARGET_NAME_SNAPSHOT_ORIGIN)) {
 			if (!params || sscanf(params, "%d:%d", &major1, &minor1) != 2) {
-				log_error("Incorrect snapshot-origin table found");
+				log_error("Incorrect snapshot-origin table found.");
 				goto out;
 			}
 			r = r || _device_is_suspended(major1, minor1);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e86fb04..615632d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -736,11 +736,11 @@ int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
 		}
 	}
 
-	log_very_verbose("Adding %s:%" PRIu32 " as an user of %s",
-			 seg->lv->name, seg->le, lv->name);
+	log_very_verbose("Adding %s:" FMTu32 " as an user of %s.",
+			 display_lvname(seg->lv), seg->le, display_lvname(lv));
 
 	if (!(sl = dm_pool_zalloc(lv->vg->vgmem, sizeof(*sl)))) {
-		log_error("Failed to allocate segment list");
+		log_error("Failed to allocate segment list.");
 		return 0;
 	}
 
@@ -762,16 +762,16 @@ int remove_seg_from_segs_using_this_lv(struct logical_volume *lv,
 		if (sl->count > 1)
 			sl->count--;
 		else {
-			log_very_verbose("%s:%" PRIu32 " is no longer a user "
-					 "of %s", seg->lv->name, seg->le,
-					 lv->name);
+			log_very_verbose("%s:" FMTu32 " is no longer a user of %s.",
+					 display_lvname(seg->lv), seg->le,
+					 display_lvname(lv));
 			dm_list_del(&sl->list);
 		}
 		return 1;
 	}
 
-	log_error(INTERNAL_ERROR "Segment %s:%u is not a user of %s.",
-                  seg->lv->name, seg->le, lv->name);
+	log_error(INTERNAL_ERROR "Segment %s:" FMTu32 " is not a user of %s.",
+		  display_lvname(seg->lv), seg->le, display_lvname(lv));
 	return 0;
 }
 
@@ -798,8 +798,9 @@ struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *l
 
 		if (sl->count != 1) {
 			log_error("%s is expected to have only one segment using it, "
-				  "while %s:%" PRIu32 " uses it %d times.",
-				  display_lvname(lv), sl->seg->lv->name, sl->seg->le, sl->count);
+				  "while %s:" FMTu32 " uses it %d times.",
+				  display_lvname(lv), display_lvname(sl->seg->lv),
+				  sl->seg->le, sl->count);
 			return NULL;
 		}
 
@@ -890,7 +891,7 @@ static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t exte
 	/* Round up extents to stripe divisible amount */
 	if ((size_rest = extents % stripes)) {
 		new_extents += extend ? stripes - size_rest : -size_rest;
-		log_print_unless_silent("Rounding size %s (%d extents) up to stripe boundary size %s (%d extents).",
+		log_print_unless_silent("Rounding size %s (%u extents) up to stripe boundary size %s (%u extents).",
 					display_size(vg->cmd, (uint64_t) extents * vg->extent_size), extents,
 					display_size(vg->cmd, (uint64_t) new_extents * vg->extent_size), new_extents);
 	}
@@ -1017,8 +1018,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 			return 0;
 		} else {
 			if (!lv_remove(lv)) {
-				log_error("Failed to remove RAID image %s",
-					  lv->name);
+				log_error("Failed to remove RAID image %s.",
+					  display_lvname(lv));
 				return 0;
 			}
 		}
@@ -1027,8 +1028,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		if (seg->meta_areas && seg_metalv(seg, s) && (area_reduction == seg->area_len)) {
 			if (!lv_reduce(seg_metalv(seg, s),
 				       seg_metalv(seg, s)->le_count)) {
-				log_error("Failed to remove RAID meta-device %s",
-					  seg_metalv(seg, s)->name);
+				log_error("Failed to remove RAID meta-device %s.",
+					  display_lvname(seg_metalv(seg, s)));
 				return 0;
 			}
 		}
@@ -1036,13 +1037,14 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	}
 
 	if (area_reduction == seg->area_len) {
-		log_very_verbose("Remove %s:%" PRIu32 "[%" PRIu32 "] from "
-				 "the top of LV %s:%" PRIu32,
-				 seg->lv->name, seg->le, s,
-				 lv->name, seg_le(seg, s));
+		log_very_verbose("Remove %s:" FMTu32 "[" FMTu32 "] from "
+				 "the top of LV %s:" FMTu32 ".",
+				 display_lvname(seg->lv), seg->le, s,
+				 display_lvname(lv), seg_le(seg, s));
 
 		if (!remove_seg_from_segs_using_this_lv(lv, seg))
 			return_0;
+
 		seg_lv(seg, s) = NULL;
 		seg_le(seg, s) = 0;
 		seg_type(seg, s) = AREA_UNASSIGNED;
@@ -3480,7 +3482,7 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 					seg->area_count, seg->area_len,
 					seg->chunk_size, region_size,
 					seg->extents_copied, NULL))) {
-		log_error("Couldn't allocate converted LV segment");
+		log_error("Couldn't allocate converted LV segment.");
 		return NULL;
 	}
 
@@ -3513,13 +3515,14 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 
 	if (!lv_is_pvmove(lv)) {
 		log_error(INTERNAL_ERROR
-			  "Non-pvmove LV, %s, passed as argument", lv->name);
+			  "Non-pvmove LV, %s, passed as argument.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (seg_type(first_seg(lv), 0) != AREA_PV) {
 		log_error(INTERNAL_ERROR
-			  "Bad segment type for first segment area");
+			  "Bad segment type for first segment area.");
 		return 0;
 	}
 
@@ -3530,8 +3533,8 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 	 */
 	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
 		if (!(seg = find_seg_by_le(lv, current_le))) {
-			log_error("Failed to find segment for %s extent %"
-				  PRIu32, lv->name, current_le);
+			log_error("Failed to find segment for %s extent " FMTu32 ".",
+				  display_lvname(lv), current_le);
 			return 0;
 		}
 
@@ -3539,7 +3542,8 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 		if (aa[0].len < seg->area_len) {
 			if (!lv_split_segment(lv, seg->le + aa[0].len)) {
 				log_error("Failed to split segment at %s "
-					  "extent %" PRIu32, lv->name, le);
+					  "extent " FMTu32 ".",
+					  display_lvname(lv), le);
 				return 0;
 			}
 		}
@@ -3549,8 +3553,8 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 	current_le = le;
 
 	if (!insert_layer_for_lv(lv->vg->cmd, lv, PVMOVE, "_mimage_0")) {
-		log_error("Failed to build pvmove LV-type mirror, %s",
-			  lv->name);
+		log_error("Failed to build pvmove LV-type mirror %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 	orig_lv = seg_lv(first_seg(lv), 0);
@@ -3571,8 +3575,8 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 
 	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
 		if (!(seg = find_seg_by_le(orig_lv, current_le))) {
-			log_error("Failed to find segment for %s extent %"
-				  PRIu32, lv->name, current_le);
+			log_error("Failed to find segment for %s extent " FMTu32 ".",
+				  display_lvname(lv), current_le);
 			return 0;
 		}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 78028cf..ad6cb2a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -828,18 +828,18 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 	struct pv_list *pvl;
 	unsigned int max_phys_block_size = 0;
 
-	log_debug_metadata("Adding PVs to VG %s", vg->name);
+	log_debug_metadata("Adding PVs to VG %s.", vg->name);
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return_0;
 
 	dm_list_iterate_items(pvl, &pp->pvs) {
-		log_debug_metadata("Adding PV %s to VG %s", pv_dev_name(pvl->pv), vg->name);
+		log_debug_metadata("Adding PV %s to VG %s.", pv_dev_name(pvl->pv), vg->name);
 
 		if (!(check_dev_block_size_for_vg(pvl->pv->dev,
 						  (const struct volume_group *) vg,
 						  &max_phys_block_size))) {
-			log_error("PV %s has wrong block size", pv_dev_name(pvl->pv));
+			log_error("PV %s has wrong block size.", pv_dev_name(pvl->pv));
 			return 0;
 		}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index dfe1adf..0793017 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1860,24 +1860,24 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 
 	dm_list_init(&meta_lvs);
 
-	log_debug_metadata("Allocating metadata LVs for %s", display_lvname(lv));
+	log_debug_metadata("Allocating metadata LVs for %s.", display_lvname(lv));
 	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs, &seg_meta_areas)) {
-		log_error("Failed to allocate metadata LVs for %s", display_lvname(lv));
+		log_error("Failed to allocate metadata LVs for %s.", display_lvname(lv));
 		return 0;
 	}
 
 	/* Metadata LVs must be cleared before being added to the array */
-	log_debug_metadata("Clearing newly allocated metadata LVs for %s", display_lvname(lv));
+	log_debug_metadata("Clearing newly allocated metadata LVs for %s.", display_lvname(lv));
 	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs for %s", display_lvname(lv));
+		log_error("Failed to initialize metadata LVs for %s.", display_lvname(lv));
 		return 0;
 	}
 
 	/* Set segment areas for metadata sub_lvs */
 	seg->meta_areas = seg_meta_areas;
-	log_debug_metadata("Adding newly allocated metadata LVs to %s", display_lvname(lv));
+	log_debug_metadata("Adding newly allocated metadata LVs to %s.", display_lvname(lv));
 	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
-		log_error("Failed to add newly allocated metadata LVs to %s", display_lvname(lv));
+		log_error("Failed to add newly allocated metadata LVs to %s.", display_lvname(lv));
 		return 0;
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f70984a..0512585 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1596,7 +1596,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (seg_is_thin_volume(lp))
-		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
+		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s.",
 			    lp->lv_name ? : "with generated name",
 			    lp->pool_name ? : "with generated name", lp->vg_name,
 			    lp->snapshot ? " as snapshot of " : "",
diff --git a/tools/toollib.c b/tools/toollib.c
index 3562937..8c76291 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -451,17 +451,16 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 {
 	struct pe_range *per;
 
-	log_debug("Adding PE range: start PE %" PRIu32 " length %" PRIu32
-		  " on %s.", start, count, pvname);
+	log_debug("Adding PE range: start PE " FMTu32 " length " FMTu32 " on %s.",
+		  start, count, pvname);
 
 	/* Ensure no overlap with existing areas */
 	dm_list_iterate_items(per, pe_ranges) {
 		if (((start < per->start) && (start + count - 1 >= per->start)) ||
 		    ((start >= per->start) &&
 			(per->start + per->count - 1) >= start)) {
-			log_error("Overlapping PE ranges specified (%" PRIu32
-				  "-%" PRIu32 ", %" PRIu32 "-%" PRIu32 ")"
-				  " on %s.",
+			log_error("Overlapping PE ranges specified (" FMTu32
+				  "-" FMTu32 ", " FMTu32 "-" FMTu32 ") on %s.",
 				  start, start + count - 1, per->start,
 				  per->start + per->count - 1, pvname);
 			return 0;
@@ -637,7 +636,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 
 	/* Build up list of PVs */
 	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
-		log_error("Allocation of list failed");
+		log_error("Allocation of list failed.");
 		return NULL;
 	}
 	dm_list_init(r);
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 7b9f506..42893df 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -26,19 +26,19 @@ static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 	char uuid[64] __attribute__((aligned(8)));
 
 	if (vg->pv_count == 1) {
-		log_error("Volume Groups must always contain at least one PV");
+		log_error("Volume Groups must always contain at least one PV.");
 		return 0;
 	}
 
 	if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
 		return_0;
 
-	log_verbose("Removing PV with UUID %s from VG %s", uuid, vg->name);
+	log_verbose("Removing PV with UUID %s from VG %s.", uuid, vg->name);
 
 	if (pvl->pv->pe_alloc_count) {
 		if (!silent)
 			log_error("LVs still present on PV with UUID %s: "
-				  "Can't remove from VG %s", uuid, vg->name);
+				  "Can't remove from VG %s.", uuid, vg->name);
 		return 0;
 	}
 
@@ -183,33 +183,33 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!argc && !repairing) {
 		log_error("Please give volume group name and "
-			  "physical volume paths");
+			  "physical volume paths.");
 		return EINVALID_CMD_LINE;
 	}
 	
 	if (!argc) { /* repairing */
-		log_error("Please give volume group name");
+		log_error("Please give volume group name.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_is_set(cmd, mirrorsonly_ARG) && !repairing) {
-		log_error("--mirrorsonly requires --removemissing");
+		log_error("--mirrorsonly requires --removemissing.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc == 1 && !arg_is_set(cmd, all_ARG) && !repairing) {
-		log_error("Please enter physical volume paths or option -a");
+		log_error("Please enter physical volume paths or option -a.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc > 1 && arg_is_set(cmd, all_ARG)) {
 		log_error("Option -a and physical volume paths mutually "
-			  "exclusive");
+			  "exclusive.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc > 1 && repairing) {
-		log_error("Please only specify the volume group");
+		log_error("Please only specify the volume group.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -250,10 +250,10 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 			0, handle, &_vgreduce_repair_single);
 
 	if (vp.already_consistent) {
-		log_print_unless_silent("Volume group \"%s\" is already consistent", vg_name);
+		log_print_unless_silent("Volume group \"%s\" is already consistent.", vg_name);
 		ret = ECMD_PROCESSED;
 	} else if (vp.fixed) {
-		log_print_unless_silent("Wrote out consistent volume group %s", vg_name);
+		log_print_unless_silent("Wrote out consistent volume group %s.", vg_name);
 		ret = ECMD_PROCESSED;
 	} else
 		ret = ECMD_FAILED;


