From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 05 Nov 2009 11:42:11 -0600
Subject: [PATCH] LVM: add split capability
Message-ID: <1257442931.23525.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've removed some of the superfluous changes that were in the patch,
s/0/NULL/ where necessary, and put the patch in front of the 'redundant
mirror log' patch set.

 brassow

This patch adds the capability to split off a mirror leg.
Essentially, we replace the function that pulls a leg
from a mirror and frees it with just the function that
pulls it.

The following command line interface is enforced:
  prompt> lvconvert --splitmirror <n> -n <name> <VG>/<LV>
where 'n' is the number of legs to split off, and
where 'name' is the name of the newly split off logical volume.

It can be seen that '--splitmirror <n>' is exactly the same
as '--mirrors -<n>' (note the minus sign), except there is the
additional notion to keep the image being detached from the
mirror instead of just throwing it away.  So, we _could_ have
a '--keep' argument or something that could be used in
conjunction with '--mirrors' to denote the fact that we wish
to keep the image being detached.  It has been suggested that
we could have two ways of specifying this action.  I have
not implemented that here.  I am strictly choosing '--splitmirror'
and purposefully choosing not to have something additional
for '--mirrors'.  I think this prevents confusion.  The
additional argument for '--mirrors' will have to come by way
of another patch.

Also, I have chosen to make the '-n <name>' argument manditory.
Perhaps in the future when we decide on a useful default name
we can relax this enforcement.  There is no reason to withhold
the capability because we haven't formed a concensous on what
a default name should be.  [Perhaps we will make a better
informed decision on that when we begin to implement
'--track_deltas'.]

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -472,6 +472,9 @@ static int _is_mirror_image_removable(st
  *                  mirror layer and merge mirrors to the original LV.
  *                  removable_pvs should be NULL and num_removed should be
  *                  seg->area_count - 1.
+ *   split:	    if non-NULL, split the mimage off rather than removing
+ *		    it, making this argument its name (only one leg can be
+ *                  split off at a time).
  *   removed:       if non NULL, the number of removed mirror images is set
  *                  as a result
  *
@@ -487,6 +490,7 @@ static int _remove_mirror_images(struct 
 				 uint32_t num_removed,
 				 struct dm_list *removable_pvs,
 				 unsigned remove_log, unsigned collapse,
+				 const char *split,
 				 uint32_t *removed)
 {
 	uint32_t m;
@@ -537,6 +541,21 @@ static int _remove_mirror_images(struct 
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		lv_set_visible(seg_lv(mirrored_seg, m));
+
+		if (split) {
+			remove_seg_from_segs_using_this_lv(seg_lv(mirrored_seg, m),
+							   mirrored_seg);
+
+			sub_lv = seg_lv(mirrored_seg, m);
+			sub_lv->name = dm_pool_strdup(lv->vg->cmd->mem, split);
+			if (!sub_lv->name) {
+				log_error("Unable to rename newly split LV");
+				return 0;
+			}
+
+			break;
+		}
+
 		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
 			log_error("lv_list alloc failed");
 			return 0;
@@ -671,7 +690,8 @@ int remove_mirror_images(struct logical_
 			removed_once = first_seg(next_lv)->area_count - 1;
 
 		if (!_remove_mirror_images(next_lv, removed_once,
-					   removable_pvs, remove_log, 0, &r))
+					   removable_pvs, remove_log,
+					   0, NULL, &r))
 			return_0;
 
 		if (r < removed_once) {
@@ -745,7 +765,7 @@ int collapse_mirrored_lv(struct logical_
 
 		if (!_remove_mirror_images(mirror_seg->lv,
 					   mirror_seg->area_count - 1,
-					   NULL, 1, 1, NULL)) {
+					   NULL, 1, 1, NULL, NULL)) {
 			log_error("Failed to release mirror images");
 			return 0;
 		}
@@ -866,7 +886,7 @@ int reconfigure_mirror_images(struct lv_
 	init_mirror_in_sync(in_sync);
 
 	r = _remove_mirror_images(mirrored_seg->lv, old_num_mirrors - num_mirrors,
-				  removable_pvs, remove_log, 0, NULL);
+				  removable_pvs, remove_log, 0, NULL, NULL);
 	if (!r)
 		/* Unable to remove bad devices */
 		return 0;
@@ -1586,6 +1606,49 @@ int lv_add_mirrors(struct cmd_context *c
 	return 0;
 }
 
+int lv_split_mirror_images(struct logical_volume *lv, const char *split_lv_name,
+			   uint32_t split_count, struct dm_list *removable_pvs)
+{
+	int r;
+
+	/*
+	 * FIXME: Need ability to split off more than one mirror leg
+	 *
+	 * Right now, we only allow the user to split a single
+	 * leg off at a time.  In the future, we might allow a
+	 * 4-way mirror to be split into 2 2-way mirrors, but
+	 * not right now.
+	 */
+	if (split_count != 1) {
+		log_error("Unable to split more than one leg from a mirror.");
+		return_0;
+	}
+
+	/* Can't split a mirror that is not in-sync... unless force? */
+	if (!_mirrored_lv_in_sync(lv)) {
+		log_error("Unable to split mirror that is not in-sync.");
+		return_0;
+	}
+
+	/*
+	 * FIXME: Generate default name when not supplied.
+	 *
+	 * If we were going to generate a default name, we would
+	 * do it here.  Better to wait for a decision on the form
+	 * of the default name when '--track_deltas' (the ability
+	 * to merge a split leg back in and only copy the changes)
+	 * is being implemented.  For now, we force the user to
+	 * come up with a name for their LV.
+	 */
+	r = _remove_mirror_images(lv, split_count,
+				  removable_pvs, 0, 0,
+				  split_lv_name, NULL);
+	if (!r)
+		return 0;
+
+	return 1;
+}
+
 /*
  * Generic interface for removing mirror and/or mirror log.
  * 'mirror' is the number of mirrors to be removed.
Index: LVM2/man/lvconvert.8.in
===================================================================
--- LVM2.orig/man/lvconvert.8.in
+++ LVM2/man/lvconvert.8.in
@@ -16,6 +16,13 @@ LogicalVolume[Path] [PhysicalVolume[Path
 
 .br
 .B lvconvert
+\-\-splitmirrors Images \-n SplitLogicalVolumeName
+.br
+MirrorLogicalVolume[Path] [SplittablePhysicalVolume[Path][:PE[-PE]]...]
+.br
+
+.br
+.B lvconvert
 \-s|\-\-snapshot [\-c|\-\-chunksize ChunkSize]
 [\-h|\-?|\-\-help]
 [\-\-noudevsync]
@@ -47,7 +54,7 @@ the freed extents come first from the sp
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
-Exactly one of \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
+Exactly one of \-\-splitmirrors, \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
 .br
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -85,16 +92,23 @@ process will not wait for notification f
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
+.br
+
+
 .TP
-.I \-\-repair
-Repair a mirror after suffering a disk failure. The mirror will be brought back
-into a consistent state.  By default, the original number of mirrors will be
-restored if possible.  Specify \-y on the command line to skip the prompts.
-Use \-f if you do not want any replacement.  Additionally, you may use
-\-\-use-policies to use the device replacement policy specified in lvm.conf,
-viz. activation/mirror_log_fault_policy or
-activation/mirror_device_fault_policy.
+.I \-\-splitmirrors Images
+Specifies how many Images, or legs, of a mirror you wish to split
+off and form a new logical volume from.  A name must be supplied
+for the newly-split-off logical volume using the \-\-name argument.
+Only one image can be split off at this time (i.e. \-\-splitmirrors 1).
+
+.TP
+.I \-n Name
+The name to apply to a logical volume which has been split off from
+a mirror logical volume.
 .br
+
+
 .TP
 .I \-s, \-\-snapshot
 Create a snapshot from existing logical volume using another
@@ -107,6 +121,18 @@ Power of 2 chunk size for the snapshot l
 Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
 .br
+
+
+.TP
+.I \-\-repair
+Repair a mirror after suffering a disk failure. The mirror will be brought back
+into a consistent state.  By default, the original number of mirrors will be
+restored if possible.  Specify \-y on the command line to skip the prompts.
+Use \-f if you do not want any replacement.  Additionally, you may use
+\-\-use-policies to use the device replacement policy specified in lvm.conf,
+viz. activation/mirror_log_fault_policy or
+activation/mirror_device_fault_policy.
+.br
 .SH Examples
 "lvconvert -m1 vg00/lvol1"
 .br
Index: LVM2/tools/args.h
===================================================================
--- LVM2.orig/tools/args.h
+++ LVM2/tools/args.h
@@ -50,6 +50,7 @@ arg(nosync_ARG, '\0', "nosync", NULL, 0)
 arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -96,6 +96,7 @@ xx(lvconvert,
    0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "[--splitmirrors Images -n SplitLogicalVolumeName]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -122,8 +123,9 @@ xx(lvconvert,
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG, repair_ARG,
-   snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   splitmirrors_ARG, name_ARG, mirrorlog_ARG, mirrors_ARG, noudevsync_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, test_ARG, use_policies_ARG,
+   yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -22,6 +22,7 @@ struct lvconvert_params {
 
 	const char *origin;
 	const char *lv_name;
+	const char *lv_split_name;
 	const char *lv_name_full;
 	const char *vg_name;
 	int wait_completion;
@@ -32,6 +33,7 @@ struct lvconvert_params {
 
 	uint32_t mirrors;
 	sign_t mirrors_sign;
+	uint32_t keep_mimages;
 
 	struct segment_type *segtype;
 
@@ -124,7 +126,48 @@ static int _read_params(struct lvconvert
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
+	if (arg_count(cmd, splitmirrors_ARG) && arg_count(cmd, mirrors_ARG)) {
+		log_error("--mirrors (-m) and --splitmirrors are "
+			  "mutually exclusive");
+		return 0;
+	}
+
+	/*
+	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
+	 * (note the minus sign), except that it signifies the additional
+	 * intent to keep the mimage that is detached, rather than
+	 * discarding it.
+	 */
+	if (arg_count(cmd, splitmirrors_ARG)) {
+		if (!arg_count(cmd, name_ARG)) {
+			log_error("The split off mirror image requires a name");
+			return 0;
+		}
+
+		lp->lv_split_name = arg_value(cmd, name_ARG);
+		if (!apply_lvname_restrictions(lp->lv_split_name))
+			return_0;
+
+		lp->keep_mimages = 1;
+		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
+			log_error("Argument to --splitmirrors"
+				  " cannot be negative");
+			return 0;
+		}
+		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
+		lp->mirrors_sign = SIGN_MINUS;
+	} else if (arg_count(cmd, name_ARG)) {
+		log_error("The 'name' argument is only valid"
+			  " with --splitmirrors");
+		return 0;
+	}
+
 	if (arg_count(cmd, mirrors_ARG)) {
+		/*
+		 * --splitmirrors has been chosen as the mechanism for
+		 * specifying the intent of detaching and keeping a mimage
+		 * versus an argument such as '--keep' being added here.
+		 */
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
 	}
@@ -545,7 +588,7 @@ static int _lvconvert_mirrors(struct cmd
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
-	    !repair) {
+	    !arg_count(cmd, splitmirrors_ARG) && !repair) {
 		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
 			lp->need_polling = 1;
 		return 1;
@@ -564,7 +607,7 @@ static int _lvconvert_mirrors(struct cmd
 	 * count to remain the same.  They may be changing
 	 * the logging type.
 	 */
-	if (!arg_count(cmd, mirrors_ARG))
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirrors_ARG))
 		lp->mirrors = existing_mirrors;
 	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = existing_mirrors + lp->mirrors;
@@ -670,10 +713,17 @@ static int _lvconvert_mirrors(struct cmd
 		/* Reduce number of mirrors */
 		if (repair || lp->pv_count)
 			remove_pvs = lp->pvh;
-		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-				       (corelog || lp->mirrors == 1) ? 1U : 0U,
-				       remove_pvs, 0))
+
+		if (lp->keep_mimages) {
+			if (!lv_split_mirror_images(lv, lp->lv_split_name,
+						    existing_mirrors - lp->mirrors,
+						    remove_pvs))
+				return 0;
+		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
+					      (corelog || lp->mirrors == 1) ? 1U : 0U,
+					      remove_pvs, 0))
 			return_0;
+
 		if (lp->mirrors > 1 &&
 		    !_lv_update_log_type(cmd, lp, lv, corelog))
 			return_0;



