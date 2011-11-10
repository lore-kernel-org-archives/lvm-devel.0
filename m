From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 10 Nov 2011 16:37:06 -0600
Subject: [PATCH] LVM: New lvconvert option, '--replace'
Message-ID: <1320964626.7209.3.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

Support the ability to replace specific devices in a RAID array.

RAID is not like traditional LVM mirroring.  LVM mirroring required failed
devices to be removed or the logical volume would simply hang.  RAID arrays can
keep on running with failed devices.  In fact, for RAID types other than RAID1,
removing a device would mean substituting an error target or converting to a
lower level RAID (e.g. RAID6 -> RAID5, or RAID4/5 to RAID0).  Therefore, rather
than removing a failed device unconditionally and potentially allocating a
replacement, RAID allows the user to "replace" a device with a new one.  This
approach is a 1-step solution vs the current 2-step solution.

example> lvconvert --replace <dev_to_remove> vg/lv [possible_replacement_PVs]

'--replace' can be specified more than once.

eg> lvconvert --replace /dev/sdb1 --replace /dev/sdc1 vg/lv


Index: LVM2/lib/metadata/raid_manip.c
===================================================================
--- LVM2.orig/lib/metadata/raid_manip.c
+++ LVM2/lib/metadata/raid_manip.c
@@ -1428,3 +1428,211 @@ int lv_raid_reshape(struct logical_volum
 		  seg->segtype->name, new_segtype->name);
 	return 0;
 }
+
+/*
+ * lv_raid_replace
+ * @lv
+ * @replace_pvs
+ * @allocatable_pvs
+ *
+ * Replace the specified PVs.
+ */
+int lv_raid_replace(struct logical_volume *lv,
+		    struct dm_list *remove_pvs,
+		    struct dm_list *allocate_pvs)
+{
+	uint32_t s, sd, match_count = 0;
+	struct dm_list old_meta_lvs, old_data_lvs;
+	struct dm_list new_meta_lvs, new_data_lvs;
+	struct lv_segment *raid_seg = first_seg(lv);
+	struct lv_list *lvl;
+	char *tmp_names[raid_seg->area_count * 2];
+
+	dm_list_init(&old_meta_lvs);
+	dm_list_init(&old_data_lvs);
+	dm_list_init(&new_meta_lvs);
+	dm_list_init(&new_data_lvs);
+
+	/*
+	 * How many sub-LVs are being removed?
+	 */
+	for (s = 0; s < raid_seg->area_count; s++) {
+		if ((seg_type(raid_seg, s) == AREA_UNASSIGNED) ||
+		    (seg_metatype(raid_seg, s) == AREA_UNASSIGNED)) {
+			log_error("Unable to replace RAID images while the "
+				  "array has unassigned areas");
+			return 0;
+		}
+
+		if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
+		    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
+			match_count++;
+	}
+
+	if (!match_count) {
+		log_verbose("%s/%s does not contain devices specified"
+			    " for replacement", lv->vg->name, lv->name);
+		return 1;
+	} else if (match_count == raid_seg->area_count) {
+		log_error("Unable to remove all PVs from %s/%s at once.",
+			  lv->vg->name, lv->name);
+		return 0;
+	} else if (raid_seg->segtype->parity_devs &&
+		   (match_count > raid_seg->segtype->parity_devs)) {
+		log_error("Unable to replace more than %u PVs from (%s) %s/%s",
+			  raid_seg->segtype->parity_devs,
+			  raid_seg->segtype->name, lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/*
+	 * Allocate the new image components first
+	 * - This makes it easy to avoid all currently used devs
+	 * - We can immediately tell if there is enough space
+	 *
+	 * - We need to change the LV names when we insert them.
+	 */
+	if (!_alloc_image_components(lv, allocate_pvs, match_count,
+				     &new_meta_lvs, &new_data_lvs)) {
+		log_error("Failed to allocate replacement images for %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/*
+	 * Remove the old images
+	 * - If we did this before the allocate, we wouldn't have to rename
+	 *   the allocated images, but it'd be much harder to avoid the right
+	 *   PVs during allocation.
+	 */
+	if (!_raid_extract_images(lv, raid_seg->area_count - match_count,
+				  remove_pvs, 0,
+				  &old_meta_lvs, &old_data_lvs)) {
+		log_error("Failed to remove the specified images from %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/*
+	 * Skip metadata operation normally done to clear the metadata sub-LVs.
+	 *
+	 * The LV_REBUILD flag is set on the new sub-LVs,
+	 * so they will be rebuilt and we don't need to clear the metadata dev.
+	 */
+
+	for (s = 0; s < raid_seg->area_count; s++) {
+		tmp_names[s] = NULL;
+		sd = s + raid_seg->area_count;
+		tmp_names[sd] = NULL;
+
+		if ((seg_type(raid_seg, s) == AREA_UNASSIGNED) &&
+		    (seg_metatype(raid_seg, s) == AREA_UNASSIGNED)) {
+			/* Adjust the new metadata LV name */
+			lvl = dm_list_item(dm_list_first(&new_meta_lvs),
+					   struct lv_list);
+			dm_list_del(&lvl->list);
+			tmp_names[s] = dm_pool_alloc(lv->vg->vgmem,
+						    strlen(lvl->lv->name) + 1);
+			if (!tmp_names[s])
+				return_0;
+			sprintf(tmp_names[s], "%s_rmeta_%u", lv->name, s);
+			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
+						    lvl->lv->status)) {
+				log_error("Failed to add %s to %s",
+					  lvl->lv->name, lv->name);
+				return 0;
+			}
+			lv_set_hidden(lvl->lv);
+
+			/* Adjust the new data LV name */
+			lvl = dm_list_item(dm_list_first(&new_data_lvs),
+					   struct lv_list);
+			dm_list_del(&lvl->list);
+			tmp_names[sd] = dm_pool_alloc(lv->vg->vgmem,
+						     strlen(lvl->lv->name) + 1);
+			if (!tmp_names[sd])
+				return_0;
+			sprintf(tmp_names[sd], "%s_rimage_%u", lv->name, s);
+			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
+						    lvl->lv->status)) {
+				log_error("Failed to add %s to %s",
+					  lvl->lv->name, lv->name);
+				return 0;
+			}
+			lv_set_hidden(lvl->lv);
+		}
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
+	if (!resume_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	sync_local_dev_names(lv->vg->cmd);
+	dm_list_iterate_items(lvl, &old_meta_lvs) {
+		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
+			return_0;
+		if (!lv_remove(lvl->lv))
+			return_0;
+	}
+	dm_list_iterate_items(lvl, &old_data_lvs) {
+		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
+			return_0;
+		if (!lv_remove(lvl->lv))
+			return_0;
+	}
+
+	/* Update new sub-LVs to correct name */
+	for (s = 0; s < raid_seg->area_count; s++) {
+		sd = s + raid_seg->area_count;
+		if (tmp_names[s] && tmp_names[sd]) {
+			seg_metalv(raid_seg, s)->name = tmp_names[s];
+			seg_lv(raid_seg, s)->name = tmp_names[sd];
+		}
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
+	if (!resume_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+}
Index: LVM2/tools/args.h
===================================================================
--- LVM2.orig/tools/args.h
+++ LVM2/tools/args.h
@@ -55,6 +55,7 @@ arg(corelog_ARG, '\0', "corelog", NULL, 
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
 arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0)
+arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -100,6 +100,7 @@ xx(lvconvert,
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[--type SegmentType]\n"
    "\t[--repair [--use-policies]]\n"
+   "\t[--replace PhysicalVolume]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -141,8 +142,8 @@ xx(lvconvert,
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
-   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, trackchanges_ARG,
-   type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
+   regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
+   trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -48,6 +48,10 @@ struct lvconvert_params {
 	char **pvs;
 	struct dm_list *pvh;
 
+	int replace_pv_count;
+	char **replace_pvs;
+	struct dm_list *replace_pvh;
+
 	struct logical_volume *lv_to_poll;
 };
 
@@ -122,6 +126,9 @@ static int _lvconvert_name_params(struct
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
+	int i;
+	const char *tmp_str;
+	struct arg_value_group_list *group;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
@@ -243,7 +250,27 @@ static int _read_params(struct lvconvert
 						 SEG_CANNOT_BE_ZEROED) ?
 						"n" : "y"), "n");
 
-	} else {	/* Mirrors */
+	} else if (arg_count(cmd, replace_ARG)) { /* RAID device replacement */
+		lp->replace_pv_count = arg_count(cmd, replace_ARG);
+		lp->replace_pvs = dm_pool_alloc(cmd->mem, sizeof(char *) * lp->replace_pv_count);
+		if (!lp->replace_pvs)
+			return_0;
+
+		i = 0;
+		dm_list_iterate_items(group, &cmd->arg_value_groups) {
+			if (!grouped_arg_is_set(group->arg_values, replace_ARG))
+				continue;
+			if (!(tmp_str = grouped_arg_str_value(group->arg_values,
+							      replace_ARG,
+							      NULL))) {
+				log_error("Failed to get '--replace' argument");
+				return 0;
+			}
+			if (!(lp->replace_pvs[i++] = dm_pool_strdup(cmd->mem,
+								    tmp_str)))
+				return_0;
+		}
+	} else { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with "
 				  "snapshots");
@@ -309,7 +336,7 @@ static int _read_params(struct lvconvert
 			return_0;
 	}
 
-	if (activation() && lp->segtype->ops->target_present &&
+	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
@@ -1455,6 +1482,9 @@ static int lvconvert_raid(struct logical
 	if (arg_count(cmd, type_ARG))
 		return lv_raid_reshape(lv, lp->segtype);
 
+	if (arg_count(cmd, replace_ARG))
+		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
+
 	log_error("Conversion operation not yet supported.");
 	return 0;
 }
@@ -1646,6 +1676,9 @@ static int _lvconvert_single(struct cmd_
 		return ECMD_FAILED;
 	}
 
+	if (!lp->segtype)
+		lp->segtype = first_seg(lv)->segtype;
+
 	if (lp->merge) {
 		if (!lv_is_cow(lv)) {
 			log_error("Logical volume \"%s\" is not a snapshot",
@@ -1785,6 +1818,12 @@ static int lvconvert_single(struct cmd_c
 	} else
 		lp->pvh = &lv->vg->pvs;
 
+	if (lp->replace_pv_count &&
+	    !(lp->replace_pvh = create_pv_list(cmd->mem, lv->vg,
+					       lp->replace_pv_count,
+					       lp->replace_pvs, 0)))
+			goto_bad;
+
 	lp->lv_to_poll = lv;
 	ret = _lvconvert_single(cmd, lv, lp);
 bad:
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -784,6 +784,8 @@ int lv_raid_split_and_track(struct logic
 int lv_raid_merge(struct logical_volume *lv);
 int lv_raid_reshape(struct logical_volume *lv,
 		    const struct segment_type *new_segtype);
+int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
+		    struct dm_list *allocate_pvs);
 
 /* --  metadata/raid_manip.c */
 
Index: LVM2/libdm/ioctl/libdm-iface.c
===================================================================
--- LVM2.orig/libdm/ioctl/libdm-iface.c
+++ LVM2/libdm/ioctl/libdm-iface.c
@@ -1644,10 +1644,10 @@ static struct dm_ioctl *_do_dm_ioctl(str
 				    	    _cmd_data_v4[dmt->type].name,
 					    strerror(errno));
 			else
-				log_error("device-mapper: %s ioctl "
+				log_error("device-mapper: %s ioctl on %s "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
-					  strerror(errno));
+					  dmi->name, strerror(errno));
 
 			/*
 			 * It's sometimes worth retrying after EBUSY in case
Index: LVM2/man/lvconvert.8.in
===================================================================
--- LVM2.orig/man/lvconvert.8.in
+++ LVM2/man/lvconvert.8.in
@@ -52,6 +52,14 @@ LogicalVolume[Path]...
 [\-\-version]
 LogicalVolume[Path] [PhysicalVolume[Path]...]
 
+.br
+.B lvconvert
+\-\-replace PhysicalVolume
+[\-h|\-?|\-\-help]
+[\-v|\-\-verbose]
+[\-\-version]
+LogicalVolume[Path] [PhysicalVolume[Path]...]
+
 .SH DESCRIPTION
 lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
 characteristics of a logical volume.  For example, it can add or remove the
@@ -181,6 +189,14 @@ Use \-f if you do not want any replaceme
 viz. activation/mirror_log_fault_policy or
 activation/mirror_device_fault_policy.
 .br
+
+.TP
+.I \-\-replace PhysicalVolume
+Remove the specified device (PhysicalVolume) and replace it with one that is
+available in the volume group or from the specific list provided.  This option
+is only available to RAID segment types (e.g. "raid1", "raid5", etc).
+.br
+
 .SH Examples
 "lvconvert -m1 vg00/lvol1"
 .br
@@ -270,6 +286,14 @@ Merge an image that was detached tempora
 the '\-\-trackchanges' argument back into its original mirror and
 bring its contents back up-to-date.
 
+.br
+"lvconvert --replace /dev/sdb1 vg00/my_raid1 /dev/sdf1"
+.br
+Replace the physical volume "/dev/sdb1" in the RAID1 logical volume "my_raid1"
+with the specified physical volume "/dev/sdf1".  Had the argument "/dev/sdf1"
+been left out, lvconvert would attempt to find a suitable device from those
+available in the volume group.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),



