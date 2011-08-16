From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 16 Aug 2011 09:17:35 -0500
Subject: [PATCH 3 of 5] LVM RAID: Add 'trackchanges' support to RAID1
In-Reply-To: <1313503895.11617.10.camel@f14.redhat.com>
References: <1313503895.11617.10.camel@f14.redhat.com>
Message-ID: <1313504255.11617.17.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the ability to split an image from the mirror and track changes.

	~> lvconvert --splitmirrors 1 --trackchanges vg/lv
The '--trackchanges' option allows a user the ability to use an image of
a RAID1 array for the purposes of temporary read-only access.  The image
can be merged back into the array at a later time and only the blocks that
have changed in the array since the split will be resync'ed.  This
operation can be thought of as a partial split.  The image is never completely
extracted from the array, in that the array reserves the position the device
occupied and tracks the differences between the array and the split image via
a bitmap.  The image itself is rendered read-only and the name (<LV>_rimage_*)
cannot be changed.  The user can complete the split (permanently splitting the
image from the array) by re-issuing the 'lvconvert' command without the
'--trackchanges' argument and specifying the '--name' argument.
	~> lvconvert --splitmirrors 1 --name my_split vg/lv
Merging the tracked image back into the array is done with the '--merge'
option (included in a follow-on patch).
	~> lvconvert --merge vg/lv_rimage_<n>

The internal mechanics of this are relatively simple.  The 'raid' device-
mapper target allows for the specification of an empty slot in an array
via '- -'.  This is what will be used if a partial activation of an array
is ever required.  (It would also be possible to use 'error' targets in
place of the '- -'.)  If a RAID image is found to be both read-only and
visible, then it is considered separate from the array and '- -' is used
to hold it's position in the array.  So, all that needs to be done to
temporarily split an image from the array /and/ cause the kernel target's
bitmap to track (aka "mark") changes made is to make the specified image
visible and read-only.  To merge the device back into the array, the image
needs to be returned to the read/write state of the top-level LV and made
visible.

Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -1226,17 +1226,39 @@ int add_areas_line(struct dev_manager *d
 			if (!dm_tree_node_add_target_area(node, dev_name(seg_dev(seg, s)), NULL,
 				    (seg_pv(seg, s)->pe_start + (extent_size * seg_pe(seg, s)))))
 				return_0;
-		} else if (seg_type(seg, s) == AREA_LV) {
-			if (seg_is_raid(seg)) {
-				dlid = build_dm_uuid(dm->mem,
-						     seg_metalv(seg, s)->lvid.s,
-						     NULL);
-				if (!dlid)
-					return_0;
-				if (!dm_tree_node_add_target_area(node, NULL, dlid,
-								  extent_size * seg_metale(seg, s)))
+		} else if (seg_is_raid(seg)) {
+			/*
+			 * RAID can handle unassigned areas.  It simple puts
+			 * '- -' in for the metadata/data device pair.  This
+			 * is a valid way to indicate to the RAID target that
+			 * the device is missing.
+			 *
+			 * If an image is marked as VISIBLE_LV and !LVM_WRITE,
+			 * it means the device has temporarily been extracted
+			 * from the array.  It may come back at a future date,
+			 * so the bitmap must track differences.  Again, '- -'
+			 * is used in the CTR table.
+			 */
+			if ((seg_type(seg, s) == AREA_UNASSIGNED) ||
+			    ((seg_lv(seg, s)->status & VISIBLE_LV) &&
+			     !(seg_lv(seg, s)->status & LVM_WRITE))) {
+				/* One each for metadata area and data area */
+				if (!dm_tree_node_add_null_area(node, 0) ||
+				    !dm_tree_node_add_null_area(node, 0))
 					return_0;
+				continue;
 			}
+			if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s)->lvid.s, NULL)))
+				return_0;
+			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_metale(seg, s)))
+				return_0;
+
+			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
+				return_0;
+			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
+				return_0;
+		} else if (seg_type(seg, s) == AREA_LV) {
+
 			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
 				return_0;
 			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -34,6 +34,22 @@ uint32_t lv_raid_image_count(const struc
 	return seg->area_count;
 }
 
+static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
+					   struct logical_volume *sub_lv)
+{
+	struct cmd_context *cmd = top_lv->vg->cmd;
+
+	/* If top RAID was EX, use EX */
+	if (lv_is_active_exclusive_locally(top_lv)) {
+		if (!activate_lv_excl(cmd, sub_lv))
+			return_0;
+	} else {
+		if (!activate_lv(cmd, sub_lv))
+			return_0;
+	}
+	return 1;
+}
+
 /*
  * lv_is_on_pv
  * @lv:
@@ -623,3 +639,83 @@ int lv_raid_split(struct logical_volume 
 
 	return 1;
 }
+
+/*
+ * lv_raid_split_and_track
+ * @lv
+ * @splittable_pvs
+ *
+ * Only allows a single image to be split while tracking.  The image
+ * never actually leaves the mirror.  It is simply made visible.  This
+ * action triggers two things: 1) users are able to access the (data) image
+ * and 2) lower layers replace images marked with a visible flag with
+ * error targets.
+ *
+ * Returns: 1 on success, 0 on error
+ */
+int lv_raid_split_and_track(struct logical_volume *lv,
+			    struct dm_list *splittable_pvs)
+{
+	int s;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_mirrored(seg)) {
+		log_error("Unable to split images from non-mirrored RAID");
+		return 0;
+	}
+
+	if (!raid_in_sync(lv)) {
+		log_error("Unable to split image from %s/%s while not in-sync",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	for (s = seg->area_count - 1; s >= 0; s--) {
+		if (!lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
+			continue;
+		lv_set_visible(seg_lv(seg, s));
+		seg_lv(seg, s)->status &= ~LVM_WRITE;
+		break;
+	}
+
+	if (s >= seg->area_count) {
+		log_error("Unable to find image to satisfy request");
+		return 0;
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
+	log_print("%s split from %s for read-only purposes.",
+		  seg_lv(seg, s)->name, lv->name);
+
+	/* Resume original LV */
+	if (!resume_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/* Activate the split (and tracking) LV */
+	if (!_activate_sublv_preserving_excl(lv, seg_lv(seg, s)))
+		return 0;
+
+	log_print("Use 'lvconvert --merge %s/%s' to merge back into %s",
+		  lv->vg->name, seg_lv(seg, s)->name, lv->name);
+	return 1;
+}
Index: LVM2/tools/args.h
===================================================================
--- LVM2.orig/tools/args.h
+++ LVM2/tools/args.h
@@ -54,6 +54,7 @@ arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
+arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -114,6 +114,7 @@ xx(lvconvert,
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
+   "[--splitmirrors Images --trackchanges]\n"
    "[--splitmirrors Images --name SplitLogicalVolumeName]\n"
    "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
 
@@ -139,7 +140,7 @@ xx(lvconvert,
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
-   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, trackchanges_ARG,
    stripes_long_ARG, stripesize_ARG, test_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -158,13 +158,15 @@ static int _read_params(struct lvconvert
 	 * discarding it.
 	 */
 	if (arg_count(cmd, splitmirrors_ARG)) {
-		if (!arg_count(cmd, name_ARG)) {
+		if (!arg_count(cmd, name_ARG) &&
+		    !arg_count(cmd, trackchanges_ARG)) {
 			log_error("Please name the new logical volume using '--name'");
 			return 0;
 		}
 
 		lp->lv_split_name = arg_value(cmd, name_ARG);
-		if (!apply_lvname_restrictions(lp->lv_split_name))
+		if (lp->lv_split_name &&
+		    !apply_lvname_restrictions(lp->lv_split_name))
 			return_0;
 
 		lp->keep_mimages = 1;
@@ -1146,6 +1148,11 @@ static int _lvconvert_mirrors_aux(struct
 
 		/* Reduce number of mirrors */
 		if (lp->keep_mimages) {
+			if (arg_count(cmd, trackchanges_ARG)) {
+				log_error("--trackchanges is not available "
+					  "to 'mirror' segment type");
+				return 0;
+			}
 			if (!lv_split_mirror_images(lv, lp->lv_split_name,
 						    nmc, operable_pvs))
 				return 0;
@@ -1417,7 +1424,9 @@ static int lvconvert_raid(struct logical
 			return 0;
 		}
 
-		if (arg_count(cmd, splitmirrors_ARG))
+		if (arg_count(cmd, trackchanges_ARG))
+			return lv_raid_split_and_track(lv, lp->pvh);
+		else if (arg_count(cmd, splitmirrors_ARG))
 			return lv_raid_split(lv, lp->lv_split_name,
 					     image_count, lp->pvh);
 		else
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -744,6 +744,8 @@ int lv_raid_change_image_count(struct lo
 			       uint32_t new_count, struct dm_list *pvs);
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs);
+int lv_raid_split_and_track(struct logical_volume *lv,
+			    struct dm_list *splittable_pvs);
 
 /* --  metadata/raid_manip.c */
 
Index: LVM2/libdm/libdevmapper.h
===================================================================
--- LVM2.orig/libdm/libdevmapper.h
+++ LVM2/libdm/libdevmapper.h
@@ -516,6 +516,7 @@ int dm_tree_node_add_target_area(struct 
 				    const char *dev_name,
 				    const char *dlid,
 				    uint64_t offset);
+int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset);
 
 /*
  * Set readahead (in sectors) after loading the node.
Index: LVM2/libdm/libdm-deptree.c
===================================================================
--- LVM2.orig/libdm/libdm-deptree.c
+++ LVM2/libdm/libdm-deptree.c
@@ -1484,11 +1484,11 @@ static int _emit_areas_line(struct dm_ta
 	unsigned log_parm_count;
 
 	dm_list_iterate_items(area, &seg->areas) {
-		if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
-			return_0;
-
 		switch (seg->type) {
 		case SEG_REPLICATOR_DEV:
+			if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
+				return_0;
+
 			EMIT_PARAMS(*pos, " %d 1 %s", area->rsite_index, devbuf);
 			if (first_time)
 				EMIT_PARAMS(*pos, " nolog 0");
@@ -1530,9 +1530,19 @@ static int _emit_areas_line(struct dm_ta
 		case SEG_RAID6_ZR:
 		case SEG_RAID6_NR:
 		case SEG_RAID6_NC:
+			if (!area->dev_node) {
+				EMIT_PARAMS(*pos, " -");
+				break;
+			}
+			if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
+				return_0;
+
 			EMIT_PARAMS(*pos, " %s", devbuf);
 			break;
 		default:
+			if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
+				return_0;
+
 			EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
 				    devbuf, area->offset);
 		}
@@ -2571,7 +2581,7 @@ int dm_tree_node_add_target_area(struct 
 		if (!_link_tree_nodes(node, dev_node))
 			return_0;
 	} else {
-        	if (stat(dev_name, &info) < 0) {
+		if (stat(dev_name, &info) < 0) {
 			log_error("Device %s not found.", dev_name);
 			return 0;
 		}
@@ -2600,6 +2610,18 @@ int dm_tree_node_add_target_area(struct 
 	return 1;
 }
 
+int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
+{
+	struct load_segment *seg;
+
+	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+
+	if (!_add_area(node, seg, NULL, offset))
+		return_0;
+
+	return 1;
+}
+
 void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie)
 {
 	node->dtree->cookie = cookie;



