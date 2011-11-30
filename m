From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 30 Nov 2011 02:02:14 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/flags.c lib/m ...
Message-ID: <20111130020214.21658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-11-30 02:02:12

Modified files:
	.              : WHATS_NEW 
	lib/format_text: flags.c 
	lib/metadata   : metadata-exported.h raid_manip.c 
	lib/raid       : raid.c 
	libdm/ioctl    : libdm-iface.c 
	man            : lvconvert.8.in 
	tools          : args.h commands.h lvconvert.c 

Log message:
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
	
	example> lvconvert --replace /dev/sdb1 --replace /dev/sdc1 vg/lv

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2198&r2=1.2199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.222&r2=1.223
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175

--- LVM2/WHATS_NEW	2011/11/28 20:37:51	1.2198
+++ LVM2/WHATS_NEW	2011/11/30 02:02:10	1.2199
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Support the ability to replace specific devices in a RAID array via lvconvert.
   Add activation/use_linear_target enabled by default.
   Use gcc warning options only with .c to .o compilation.
   Move y/n prompts to stderr and repeat if response has both 'n' and 'y'.
--- LVM2/lib/format_text/flags.c	2011/11/15 11:54:16	1.49
+++ LVM2/lib/format_text/flags.c	2011/11/30 02:02:11	1.50
@@ -57,6 +57,7 @@
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
+	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
--- LVM2/lib/metadata/metadata-exported.h	2011/11/04 22:43:10	1.222
+++ LVM2/lib/metadata/metadata-exported.h	2011/11/30 02:02:11	1.223
@@ -61,7 +61,9 @@
 //#define VIRTUAL		UINT64_C(0x00010000)	/* LV - internal use only */
 #define MIRROR_LOG		UINT64_C(0x00020000)	/* LV */
 #define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
+
 #define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
+#define LV_REBUILD		UINT64_C(0x00100000)	/* LV - internal use only */
 //#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define CONVERTING		UINT64_C(0x00400000)	/* LV */
 
@@ -788,6 +790,8 @@
 int lv_raid_merge(struct logical_volume *lv);
 int lv_raid_reshape(struct logical_volume *lv,
 		    const struct segment_type *new_segtype);
+int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
+		    struct dm_list *allocate_pvs);
 
 /* --  metadata/raid_manip.c */
 
--- LVM2/lib/metadata/raid_manip.c	2011/10/07 14:56:01	1.17
+++ LVM2/lib/metadata/raid_manip.c	2011/11/30 02:02:11	1.18
@@ -440,7 +440,7 @@
 		return 0;
 	}
 
-	status = LVM_READ | LVM_WRITE | LV_NOTSYNCED | type;
+	status = LVM_READ | LVM_WRITE | LV_REBUILD | type;
 	tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg);
 	if (!tmp_lv) {
 		log_error("Failed to allocate new raid component, %s", img_name);
@@ -569,6 +569,7 @@
 static int _raid_add_images(struct logical_volume *lv,
 			    uint32_t new_count, struct dm_list *pvs)
 {
+	int rebuild_flag_cleared = 0;
 	uint32_t s;
 	uint32_t old_count = lv_raid_image_count(lv);
 	uint32_t count = new_count - old_count;
@@ -588,7 +589,7 @@
 	 */
 	if (seg_is_linear(seg)) {
 		/* A complete resync will be done, no need to mark each sub-lv */
-		status_mask = ~(LV_NOTSYNCED);
+		status_mask = ~(LV_REBUILD);
 
 		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
 			log_error("Memory allocation failed");
@@ -751,6 +752,27 @@
 		return 0;
 	}
 
+	/*
+	 * Now that the 'REBUILD' has made its way to the kernel, we must
+	 * remove the flag so that the individual devices are not rebuilt
+	 * upon every activation.
+	 */
+	seg = first_seg(lv);
+	for (s = 0; s < seg->area_count; s++) {
+		if ((seg_lv(seg, s)->status & LV_REBUILD) ||
+		    (seg_metalv(seg, s)->status & LV_REBUILD)) {
+			seg_metalv(seg, s)->status &= ~LV_REBUILD;
+			seg_lv(seg, s)->status &= ~LV_REBUILD;
+			rebuild_flag_cleared = 1;
+		}
+	}
+	if (rebuild_flag_cleared &&
+	    (!vg_write(lv->vg) || !vg_commit(lv->vg))) {
+		log_error("Failed to clear REBUILD flag for %s/%s components",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	return 1;
 
 fail:
@@ -1335,8 +1357,8 @@
 		log_debug("Adding %s to %s", lvl->lv->name, lv->name);
 
 		/* Images are known to be in-sync */
-		lvl->lv->status &= ~LV_NOTSYNCED;
-		first_seg(lvl->lv)->status &= ~LV_NOTSYNCED;
+		lvl->lv->status &= ~LV_REBUILD;
+		first_seg(lvl->lv)->status &= ~LV_REBUILD;
 		lv_set_hidden(lvl->lv);
 
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
@@ -1428,3 +1450,216 @@
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
+			if (dm_snprintf(tmp_names[s], strlen(lvl->lv->name) + 1,
+					"%s_rmeta_%u", lv->name, s) < 0)
+				return_0;
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
+			if (dm_snprintf(tmp_names[sd], strlen(lvl->lv->name) + 1,
+					"%s_rimage_%u", lv->name, s) < 0)
+				return_0;
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
+	/* Update new sub-LVs to correct name and clear REBUILD flag */
+	for (s = 0; s < raid_seg->area_count; s++) {
+		sd = s + raid_seg->area_count;
+		if (tmp_names[s] && tmp_names[sd]) {
+			seg_metalv(raid_seg, s)->name = tmp_names[s];
+			seg_lv(raid_seg, s)->name = tmp_names[sd];
+			seg_metalv(raid_seg, s)->status &= ~LV_REBUILD;
+			seg_lv(raid_seg, s)->status &= ~LV_REBUILD;
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
--- LVM2/lib/raid/raid.c	2011/09/24 21:19:30	1.12
+++ LVM2/lib/raid/raid.c	2011/11/30 02:02:11	1.13
@@ -183,7 +183,7 @@
 	}
 
 	for (s = 0; s < seg->area_count; s++)
-		if (seg_lv(seg, s)->status & LV_NOTSYNCED)
+		if (seg_lv(seg, s)->status & LV_REBUILD)
 			rebuilds |= 1 << s;
 
 	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
--- LVM2/libdm/ioctl/libdm-iface.c	2011/11/18 19:34:03	1.129
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/11/30 02:02:12	1.130
@@ -1653,10 +1653,10 @@
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
--- LVM2/man/lvconvert.8.in	2011/10/25 13:24:23	1.23
+++ LVM2/man/lvconvert.8.in	2011/11/30 02:02:12	1.24
@@ -52,6 +52,14 @@
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
@@ -181,6 +189,14 @@
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
@@ -270,6 +286,14 @@
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
--- LVM2/tools/args.h	2011/11/04 22:43:11	1.85
+++ LVM2/tools/args.h	2011/11/30 02:02:12	1.86
@@ -55,6 +55,7 @@
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
 arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0)
+arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
--- LVM2/tools/commands.h	2011/11/04 22:43:11	1.166
+++ LVM2/tools/commands.h	2011/11/30 02:02:12	1.167
@@ -100,6 +100,7 @@
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[--type SegmentType]\n"
    "\t[--repair [--use-policies]]\n"
+   "\t[--replace PhysicalVolume]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -141,8 +142,8 @@
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
-   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, trackchanges_ARG,
-   type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
+   regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
+   trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
--- LVM2/tools/lvconvert.c	2011/10/07 14:56:01	1.174
+++ LVM2/tools/lvconvert.c	2011/11/30 02:02:12	1.175
@@ -48,6 +48,10 @@
 	char **pvs;
 	struct dm_list *pvh;
 
+	int replace_pv_count;
+	char **replace_pvs;
+	struct dm_list *replace_pvh;
+
 	struct logical_volume *lv_to_poll;
 };
 
@@ -122,6 +126,9 @@
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
+	int i;
+	const char *tmp_str;
+	struct arg_value_group_list *group;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
@@ -243,7 +250,27 @@
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
@@ -309,7 +336,7 @@
 			return_0;
 	}
 
-	if (activation() && lp->segtype->ops->target_present &&
+	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
@@ -1455,6 +1482,9 @@
 	if (arg_count(cmd, type_ARG))
 		return lv_raid_reshape(lv, lp->segtype);
 
+	if (arg_count(cmd, replace_ARG))
+		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
+
 	log_error("Conversion operation not yet supported.");
 	return 0;
 }
@@ -1646,6 +1676,9 @@
 		return ECMD_FAILED;
 	}
 
+	if (!lp->segtype)
+		lp->segtype = first_seg(lv)->segtype;
+
 	if (lp->merge) {
 		if (!lv_is_cow(lv)) {
 			log_error("Logical volume \"%s\" is not a snapshot",
@@ -1785,6 +1818,12 @@
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


