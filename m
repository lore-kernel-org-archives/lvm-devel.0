From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 30 Oct 2009 16:50:56 -0500
Subject: [PATCH 2 of 2] LVM: use new split capability
Message-ID: <200910302150.n9ULou5a005346@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-use-new-split-capability.patch

Percolate the ability split off a leg up to the user.

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
@@ -541,24 +541,36 @@ static int _remove_mirror_images(struct 
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		lv_set_visible(seg_lv(mirrored_seg, m));
-		if (!split) {
-			lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
-			if (!lvl) {
-				log_error("lv_list alloc failed");
+
+		if (split) {
+			remove_seg_from_segs_using_this_lv(seg_lv(mirrored_seg, m),
+							   mirrored_seg);
+
+			sub_lv = seg_lv(mirrored_seg, m);
+			sub_lv->name = dm_pool_strdup(lv->vg->cmd->mem, split);
+			if (!sub_lv->name) {
+				log_error("Unable to rename newly split LV");
 				return 0;
 			}
-			lvl->lv = seg_lv(mirrored_seg, m);
-			dm_list_add(&tmp_orphan_lvs, &lvl->list);
-			release_lv_segment_area(mirrored_seg, m,
-						mirrored_seg->area_len);
-			continue;
+
+			/*
+			 * By putting this 'break' here, it should be
+			 * obvious that only one leg can be split off
+			 * with the code as written - consistent with
+			 * the level of functionality currently offered.
+			 */
+			break;
 		}
-		remove_seg_from_segs_using_this_lv(seg_lv(mirrored_seg, m),
-						   mirrored_seg);
-		if (!lv_rename(lv->vg->cmd, seg_lv(mirrored_seg, m), split)) {
-			log_error("Unable to rename newly split LV");
+
+		lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
+		if (!lvl) {
+			log_error("lv_list alloc failed");
 			return 0;
 		}
+		lvl->lv = seg_lv(mirrored_seg, m);
+		dm_list_add(&tmp_orphan_lvs, &lvl->list);
+		release_lv_segment_area(mirrored_seg, m,
+					mirrored_seg->area_len);
 	}
 	mirrored_seg->area_count = new_area_count;
 
@@ -1611,6 +1623,42 @@ int lv_add_mirrors(struct cmd_context *c
 	return 0;
 }
 
+int lv_split_mirror_images(struct logical_volume *lv, const char *split_lv_name,
+			   uint32_t split_count, struct dm_list *removable_pvs)
+{
+	int r;
+
+	/*
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
+	 * If we were going to generate a default name, we would
+	 * do it here, but I am not interested in default names.
+	 */
+	r = _remove_mirror_images(lv, split_count,
+				  removable_pvs, 0, 0,
+				  split_lv_name, NULL);
+	if (!r)
+		return 0;
+
+	/* Rename split leg here? */
+	return 1;
+}
+
 /*
  * Generic interface for removing mirror and/or mirror log.
  * 'mirror' is the number of mirrors to be removed.
Index: LVM2/tools/args.h
===================================================================
--- LVM2.orig/tools/args.h
+++ LVM2/tools/args.h
@@ -50,6 +50,7 @@ arg(nosync_ARG, '\0', "nosync", NULL, 0)
 arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(splitmirror_ARG, '\0', "splitmirror", int_arg, 0)
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
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|redundant}|--corelog}]]\n"
+   "[--splitmirror Count -n SplitLogicalVolumeName]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -122,8 +123,9 @@ xx(lvconvert,
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG, repair_ARG,
-   snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   splitmirror_ARG, name_ARG, mirrorlog_ARG, mirrors_ARG, noudevsync_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, test_ARG, use_policies_ARG,
+   yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -16,12 +16,16 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 
+#define MIRROR_FLAG_KEEP_IMAGES  0x1
+#define MIRROR_FLAG_TRACK_DELTAS 0x2
+
 struct lvconvert_params {
 	int snapshot;
 	int zero;
 
 	const char *origin;
 	const char *lv_name;
+	const char *lv_split_name;
 	const char *lv_name_full;
 	const char *vg_name;
 	int wait_completion;
@@ -30,8 +34,10 @@ struct lvconvert_params {
 	uint32_t chunk_size;
 	uint32_t region_size;
 
+	int track_deltas;
 	uint32_t mirrors;
 	sign_t mirrors_sign;
+	uint32_t mirror_flags;
 
 	struct segment_type *segtype;
 
@@ -124,14 +130,53 @@ static int _read_params(struct lvconvert
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
+	if (arg_count(cmd, splitmirror_ARG) && arg_count(cmd, mirrors_ARG)) {
+		log_error("--mirrors (-m) argument and --splitmirror arguments"
+			  " are mutually exclusive");
+		return 0;
+	}
+
+	/*
+	 * The --splitmirror argument is essentially the inverse of
+	 * the --mirrors argument with the additional intention of keeping
+	 * the leg that is split off.
+	 */
+	if (arg_count(cmd, splitmirror_ARG)) {
+		if (!arg_count(cmd, name_ARG)) {
+			log_error("The split off mirror image requires a name");
+			return 0;
+		}
+
+		lp->lv_split_name = arg_value(cmd, name_ARG);
+		if (!apply_lvname_restrictions(lp->lv_split_name))
+			return_0;
+
+		lp->mirror_flags |= MIRROR_FLAG_KEEP_IMAGES;
+		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
+			log_error("Argument to --splitmirror"
+				  " cannot be negative");
+			return 0;
+		}
+		lp->mirrors = arg_uint_value(cmd, splitmirror_ARG, 0);
+		lp->mirrors_sign = SIGN_MINUS;
+	} else if (arg_count(cmd, name_ARG)) {
+		log_error("The 'name' argument is only valid"
+			  " with --splitmirror");
+		return 0;
+	}
+
 	if (arg_count(cmd, mirrors_ARG)) {
+		/*
+		 * We could also add an argument that would compliment the
+		 * meaning of --mirrors to also keep removed legs, but I'm
+		 * not going to do that.
+		 */
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
 	}
 
-	lp->alloc = ALLOC_INHERIT;
 	if (arg_count(cmd, alloc_ARG))
-		lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
+		lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 	if (lp->snapshot) {
 		if (arg_count(cmd, regionsize_ARG)) {
@@ -545,7 +590,7 @@ static int _lvconvert_mirrors(struct cmd
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
-	    !repair) {
+	    !arg_count(cmd, splitmirror_ARG) && !repair) {
 		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
 			lp->need_polling = 1;
 		return 1;
@@ -564,7 +609,7 @@ static int _lvconvert_mirrors(struct cmd
 	 * count to remain the same.  They may be changing
 	 * the logging type.
 	 */
-	if (!arg_count(cmd, mirrors_ARG))
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirror_ARG))
 		lp->mirrors = existing_mirrors;
 	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = existing_mirrors + lp->mirrors;
@@ -681,10 +726,17 @@ static int _lvconvert_mirrors(struct cmd
 		/* Reduce number of mirrors */
 		if (repair || lp->pv_count)
 			remove_pvs = lp->pvh;
-		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-				       (!log_count || lp->mirrors == 1) ? 1U : 0U,
-				       remove_pvs, 0))
+
+		if (lp->mirror_flags & MIRROR_FLAG_KEEP_IMAGES) {
+			if (!lv_split_mirror_images(lv, lp->lv_split_name,
+						    existing_mirrors - lp->mirrors,
+						    remove_pvs))
+				return 0;
+		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
+					      (!log_count || lp->mirrors == 1) ? 1U : 0U,
+					      remove_pvs, 0))
 			return_0;
+
 		if (lp->mirrors > 1 &&
 		    !_lv_update_log_type(cmd, lp, lv, log_count))
 			return_0;
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -651,6 +651,8 @@ int lv_add_mirrors(struct cmd_context *c
 		   uint32_t mirrors, uint32_t stripes,
 		   uint32_t region_size, uint32_t log_count,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
+int lv_split_mirror_images(struct logical_volume *lv, const char *split_lv_name,
+			   uint32_t split_count, struct dm_list *removable_pvs);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      struct dm_list *pvs, uint32_t status_mask);
Index: LVM2/man/lvconvert.8.in
===================================================================
--- LVM2.orig/man/lvconvert.8.in
+++ LVM2/man/lvconvert.8.in
@@ -16,6 +16,13 @@ LogicalVolume[Path] [PhysicalVolume[Path
 
 .br
 .B lvconvert
+\-\-splitmirror Images \-n SplitLogicalVolumeName
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
+Exactly one of \-\-splitmirror, \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
 .br
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -86,16 +93,22 @@ process will not wait for notification f
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
+.I \-\-splitmirror Images
+Specifies how many images, or legs, of a mirror you wish to split
+off and form a new logical volume from.  It is required that a user
+provide a name for the newly split off logical volume, using the \-n
+argument.
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
@@ -108,6 +121,18 @@ Power of 2 chunk size for the snapshot l
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


