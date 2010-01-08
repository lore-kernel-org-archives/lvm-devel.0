From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Jan 2010 22:00:35 -0000
Subject: LVM2 lib/metadata/mirror.c man/lvconvert.8.in ...
Message-ID: <20100108220035.29143.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-08 22:00:31

Modified files:
	lib/metadata   : mirror.c 
	man            : lvconvert.8.in 
	tools          : args.h commands.h lvconvert.c 

Log message:
	This patch adds the capability to split off a mirror legs.
	It is pretty much the same as reducing the number of
	mirror legs, but we just don't delete them afterwards.
	
	The following command line interface is enforced:
	prompt> lvconvert --splitmirror <n> -n <name> <VG>/<LV>
	where 'n' is the number of images to split off, and
	where 'name' is the name of the newly split off logical volume.
	
	If more than one leg is split off, a new mirror will be the
	result.  The newly split off mirror will have a 'core' log.
	Example:
	[root at bp-01 LVM2]# !lvs
	lvs -a -o name,copy_percent,devices
	LV            Copy%  Devices
	lv            100.00 lv_mimage_0(0),lv_mimage_1(0),lv_mimage_2(0),lv_mimage_3(0)
	[lv_mimage_0]        /dev/sdb1(0)
	[lv_mimage_1]        /dev/sdc1(0)
	[lv_mimage_2]        /dev/sdd1(0)
	[lv_mimage_3]        /dev/sde1(0)
	[lv_mlog]            /dev/sdi1(0)
	[root at bp-01 LVM2]# lvconvert --splitmirrors 2 --name split vg/lv /dev/sd[ce]1
	Logical volume lv converted.
	[root at bp-01 LVM2]# !lvs
	lvs -a -o name,copy_percent,devices
	LV               Copy%  Devices
	lv               100.00 lv_mimage_0(0),lv_mimage_2(0)
	[lv_mimage_0]           /dev/sdb1(0)
	[lv_mimage_2]           /dev/sdd1(0)
	[lv_mlog]               /dev/sdi1(0)
	split            100.00 split_mimage_0(0),split_mimage_1(0)
	[split_mimage_0]        /dev/sde1(0)
	[split_mimage_1]        /dev/sdc1(0)
	
	It can be seen that '--splitmirror <n>' is exactly the same
	as '--mirrors -<n>' (note the minus sign), except there is the
	additional notion to keep the image being detached from the
	mirror instead of just throwing it away.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/lib/metadata/mirror.c	2010/01/08 10:50:11	1.104
+++ LVM2/lib/metadata/mirror.c	2010/01/08 22:00:31	1.105
@@ -468,6 +468,243 @@
 }
 
 /*
+ * _move_removable_mimages_to_end
+ *
+ * We always detach mimage LVs from the end of the areas array.
+ * This function will push 'count' mimages to the end of the array
+ * based on if their PVs are removable.
+ *
+ * This is an all or nothing function.  Either the user specifies
+ * enough removable PVs to satisfy count, or they don't specify
+ * any removable_pvs at all (in which case all PVs in the mirror
+ * are considered removable).
+ */
+static int _move_removable_mimages_to_end(struct logical_volume *lv,
+					  uint32_t count,
+					  struct dm_list *removable_pvs)
+{
+	int i, images;
+	struct logical_volume *sub_lv;
+	struct lv_segment *mirrored_seg = first_seg(lv);
+
+	if (!removable_pvs)
+		return 1;
+
+	/*
+	 * When we shift an image to the end, we must start from
+	 * the begining of the list again.  We must visit the
+	 * images up to the last one we just moved.
+	 */
+	for (images = mirrored_seg->area_count; images && count; images--) {
+		for (i = 0; i < images; i++) {
+			sub_lv = seg_lv(mirrored_seg, i);
+
+			if (!is_temporary_mirror_layer(sub_lv) &&
+			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
+				if (!shift_mirror_images(mirrored_seg, i))
+					return_0;
+				count--;
+				break;
+			}
+		}
+
+		/* Did we shift any images? */
+		if (i == images)
+			return 0;
+	}
+
+	return !count;
+}
+
+/*
+ * Split off 'split_count' legs from a mirror
+ *
+ * Returns: 0 on error, 1 on success
+ */
+static int _split_mirror_images(struct logical_volume *lv,
+				const char *split_name,
+				uint32_t split_count,
+				struct dm_list *removable_pvs)
+{
+	uint32_t i;
+	struct logical_volume *sub_lv, *new_lv = NULL;
+	struct logical_volume *detached_log_lv = NULL;
+	struct logical_volume *lv1 = NULL;
+	struct lv_segment *mirrored_seg = first_seg(lv);
+	struct dm_list split_images;
+	struct lv_list *lvl;
+
+	if (!(lv->status & MIRRORED)) {
+		log_error("Unable to split non-mirrored LV, %s",
+			  lv->name);
+		return 0;
+	}
+
+	if (!split_count) {
+		log_error("split_count is zero!");
+		return 0;
+	}
+
+	log_verbose("Detaching %d images from mirror, %s",
+		    split_count, lv->name);
+
+	if (!_move_removable_mimages_to_end(lv, split_count, removable_pvs)) {
+		/*
+		 * FIXME: Allow incomplete specification of removable PVs?
+		 *
+		 * I am forcing the user to either specify no
+		 * removable PVs or all of them.  Should we allow
+		 * them to just specify some - making us pick the rest?
+		 */
+		log_error("Insufficient removable PVs given"
+			  " to satisfy request");
+		return 0;
+	}
+
+	dm_list_init(&split_images);
+	for (i = 0; i < split_count; i++) {
+		mirrored_seg->area_count--;
+		sub_lv = seg_lv(mirrored_seg, mirrored_seg->area_count);
+
+		sub_lv->status &= ~MIRROR_IMAGE;
+		lv_set_visible(sub_lv);
+		release_lv_segment_area(mirrored_seg, mirrored_seg->area_count,
+					mirrored_seg->area_len);
+
+		if (!new_lv) {
+			new_lv = sub_lv;
+			new_lv->name = dm_pool_strdup(lv->vg->cmd->mem,
+						      split_name);
+			if (!new_lv->name) {
+				log_error("Unable to rename newly split LV");
+				return 0;
+			}
+		} else {
+			lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
+			if (!lvl) {
+				log_error("lv_list alloc failed");
+				return 0;
+			}
+			lvl->lv = sub_lv;
+			dm_list_add(&split_images, &lvl->list);
+		}
+	}
+
+	if (!dm_list_empty(&split_images)) {
+		size_t len = strlen(new_lv->name) + 32;
+		char *layer_name, format[len];
+
+		if (!insert_layer_for_lv(lv->vg->cmd, new_lv,
+					 0, "_mimage_%d")) {
+			log_error("Failed to build new mirror, %s",
+				  new_lv->name);
+			return 0;
+		}
+
+		first_seg(new_lv)->region_size = mirrored_seg->region_size;
+
+		dm_list_iterate_items(lvl, &split_images) {
+			sub_lv = lvl->lv;
+
+			dm_snprintf(format, len, "%s_mimage_%%d",
+				    new_lv->name);
+
+			layer_name = dm_pool_alloc(lv->vg->cmd->mem, len);
+			if (!layer_name) {
+				log_error("Unable to allocate memory");
+				return 0;
+			}
+			if (!generate_lv_name(lv->vg, format, layer_name, len)||
+			    sscanf(layer_name, format, &i) != 1) {
+				log_error("Failed to generate new image names");
+				return 0;
+			}
+			sub_lv->name = layer_name;
+		}
+
+		if (!_merge_mirror_images(new_lv, &split_images)) {
+			log_error("Failed to group split "
+				  "images into new mirror");
+			return 0;
+		}
+
+		/*
+		 * We don't allow splitting a mirror that is not in-sync,
+		 * so we can bring the newly split mirror up without a
+		 * resync.  (It will be a 'core' log mirror after all.)
+		 */
+		init_mirror_in_sync(1);
+	}
+
+	/* If no more mirrors, remove mirror layer */
+	if (mirrored_seg->area_count == 1) {
+		lv1 = seg_lv(mirrored_seg, 0);
+		lv1->status &= ~MIRROR_IMAGE;
+		lv_set_visible(lv1);
+		detached_log_lv = detach_mirror_log(mirrored_seg);
+		if (!remove_layer_from_lv(lv, lv1))
+			return_0;
+		lv->status &= ~MIRRORED;
+		lv->status &= ~MIRROR_NOTSYNCED;
+	}
+
+	if (!vg_write(mirrored_seg->lv->vg)) {
+		log_error("Intermediate VG metadata write failed.");
+		return 0;
+	}
+
+	if (!suspend_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
+		log_error("Failed to lock %s", mirrored_seg->lv->name);
+		vg_revert(mirrored_seg->lv->vg);
+		return 0;
+	}
+
+	if (!vg_commit(mirrored_seg->lv->vg)) {
+		resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv);
+		return 0;
+	}
+
+	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
+
+	/*
+	 * If we have split off a mirror instead of linear (i.e. the
+	 * split_images list is not empty), then we must perform a
+	 * resume to get the mirror started.
+	 */
+	if (!dm_list_empty(&split_images) && !resume_lv(lv->vg->cmd, new_lv)) {
+		log_error("Failed to resume newly split LV, %s", new_lv->name);
+		return 0;
+	}
+
+	/*
+	 * Avoid having same mirror target loaded twice simultaneously by first
+	 * resuming the removed LV which now contains an error segment.
+	 * As it's now detached from mirrored_seg->lv we must resume it
+	 * explicitly.
+	 */
+	if (lv1 && !resume_lv(lv1->vg->cmd, lv1)) {
+		log_error("Problem resuming temporary LV, %s", lv1->name);
+		return 0;
+	}
+
+	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
+		log_error("Problem reactivating %s", mirrored_seg->lv->name);
+		return 0;
+	}
+
+	if (lv1 && !_delete_lv(lv, lv1))
+		return_0;
+
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
+		return_0;
+
+	log_very_verbose("%" PRIu32 " image(s) detached from %s",
+			 split_count, lv->name);
+
+	return 1;
+}
+
+/*
  * Remove num_removed images from mirrored_seg
  *
  * Arguments:
@@ -1611,6 +1848,34 @@
 	return 0;
 }
 
+int lv_split_mirror_images(struct logical_volume *lv, const char *split_name,
+			   uint32_t split_count, struct dm_list *removable_pvs)
+{
+	int r;
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
+	r = _split_mirror_images(lv, split_name, split_count, removable_pvs);
+	if (!r)
+		return 0;
+
+	return 1;
+}
+
 /*
  * Generic interface for removing mirror and/or mirror log.
  * 'mirror' is the number of mirrors to be removed.
--- LVM2/man/lvconvert.8.in	2009/10/26 13:41:13	1.9
+++ LVM2/man/lvconvert.8.in	2010/01/08 22:00:31	1.10
@@ -16,6 +16,13 @@
 
 .br
 .B lvconvert
+\-\-splitmirrors Images \-\-name SplitLogicalVolumeName
+.br
+MirrorLogicalVolume[Path] [SplittablePhysicalVolume[Path][:PE[-PE]]...]
+.br
+
+.br
+.B lvconvert
 \-s|\-\-snapshot [\-c|\-\-chunksize ChunkSize]
 [\-h|\-?|\-\-help]
 [\-\-noudevsync]
@@ -47,7 +54,7 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
-Exactly one of \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
+Exactly one of \-\-splitmirrors, \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
 .br
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -85,16 +92,22 @@
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
+The number of redundant Images of a mirror to be split off and used
+to form a new logical volume.  A name must be supplied for the
+newly-split-off logical volume using the \-\-name argument.
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
@@ -107,6 +120,18 @@
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
--- LVM2/tools/args.h	2010/01/05 20:56:52	1.70
+++ LVM2/tools/args.h	2010/01/08 22:00:31	1.71
@@ -50,6 +50,7 @@
 arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
--- LVM2/tools/commands.h	2010/01/05 20:56:52	1.136
+++ LVM2/tools/commands.h	2010/01/08 22:00:31	1.137
@@ -112,6 +112,10 @@
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
+   "[--splitmirrors Images --name SplitLogicalVolumeName]\n"
+   "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
+
+   "lvconvert "
    "[-s|--snapshot]\n"
    "\t[-c|--chunksize]\n"
    "\t[-d|--debug]\n"
@@ -123,8 +127,9 @@
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG, repair_ARG,
-   snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   splitmirrors_ARG, name_ARG, mirrorlog_ARG, mirrors_ARG, noudevsync_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, test_ARG, use_policies_ARG,
+   yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
--- LVM2/tools/lvconvert.c	2010/01/08 21:53:08	1.104
+++ LVM2/tools/lvconvert.c	2010/01/08 22:00:31	1.105
@@ -22,6 +22,7 @@
 
 	const char *origin;
 	const char *lv_name;
+	const char *lv_split_name;
 	const char *lv_name_full;
 	const char *vg_name;
 	int wait_completion;
@@ -32,6 +33,7 @@
 
 	uint32_t mirrors;
 	sign_t mirrors_sign;
+	uint32_t keep_mimages;
 
 	struct segment_type *segtype;
 
@@ -125,7 +127,48 @@
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
+	if (arg_count(cmd, splitmirrors_ARG) && arg_count(cmd, mirrors_ARG)) {
+		log_error("--mirrors and --splitmirrors are "
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
+			log_error("Please name the new logical volume using '--name'");
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
+		 * versus an additional qualifying argument being added here.
+		 */
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
 	}
@@ -586,7 +629,7 @@
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
-	    !repair) {
+	    !arg_count(cmd, splitmirrors_ARG) && !repair) {
 		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
 			lp->need_polling = 1;
 		return 1;
@@ -605,7 +648,7 @@
 	 * count to remain the same.  They may be changing
 	 * the logging type.
 	 */
-	if (!arg_count(cmd, mirrors_ARG))
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirrors_ARG))
 		lp->mirrors = existing_mirrors;
 	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = existing_mirrors + lp->mirrors;
@@ -729,10 +772,17 @@
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


