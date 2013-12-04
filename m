From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Dec 2013 02:10:51 +0000 (UTC)
Subject: master - lvconvert: Implement --splitsnapshot.
Message-ID: <20131204021051.C7B8D60CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b65363bf781cd58d45e2d9f12fdfed59b9dee55
Commit:        7b65363bf781cd58d45e2d9f12fdfed59b9dee55
Parent:        ff769ecfe7cdd704ee1e11aa9b6b7a92f932a0c1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Dec 4 02:09:37 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Dec 4 02:09:37 2013 +0000

lvconvert: Implement --splitsnapshot.

---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |   21 +++++++-
 tools/args.h       |    1 +
 tools/commands.h   |   15 ++++-
 tools/lvconvert.c  |  142 ++++++++++++++++++++++++++++++++++++++++++++-------
 5 files changed, 155 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c96acce..553edfd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add --splitsnapshot to lvconvert to separate out cow LV.
   Reinstate origin reload to complete lvconvert -s with active LVs. (2.02.98)
   Select only active volume groups if vgdisplay -A is used.
   Add -p and LVM_LVMETAD_PID env var to lvmetad to change pid file.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 0fe5ab3..30e9809 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -38,6 +38,14 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RI [ SplittablePhysicalVolume [ Path ][ :PE [ -PE ]]...]
 .sp
 .B lvconvert
+.BR \-\-splitsnapshot
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR SnapshotLogicalVolume [ Path ]
+.sp
+.B lvconvert
 .BR \-s | \-\-snapshot
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkK ]]
@@ -128,6 +136,7 @@ Exactly one of
 .BR \-\-mirrors ,
 .BR \-\-repair ,
 .BR \-\-replace ,
+.BR \-\-splitsnapshot ,
 .BR \-\-snapshot ,
 .BR \-\-splitmirrors
 or
@@ -200,9 +209,17 @@ the data changed get resynchronized.
 Please note that this feature is only supported with the new md-based mirror
 implementation and not with the original device-mapper mirror implementation.
 .TP
+.B \-\-splitsnapshot
+Separates SnapshotLogicalVolume from its origin.
+The volume that is split off contains the chunks that differ from the origin
+along with the metadata describing them.  This volume can be wiped and then
+destroyed with lvremove.
+The inverse of \-\-snapshot.
+.TP
 .B \-s, \-\-snapshot
-Creates a snapshot from existing logical volume using another
-existing logical volume as its origin.
+Recreates a snapshot from constituent logical volumes (or copies of them) after
+having been separated using \-\-splitsnapshot.  For this to work correctly, no
+changes may be made to the contents of either volume after the split.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot and thin pool logical volumes.
diff --git a/tools/args.h b/tools/args.h
index 8ca73a3..1207189 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -101,6 +101,7 @@ arg(profile_ARG, '\0', "profile", string_arg, 0)
 arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
+arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index c54e812..938898b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -172,6 +172,15 @@ xx(lvconvert,
    "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
+   "--splitsnapshot\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[--noudevsync]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]" "\n"
+   "\tSnapshotLogicalVolume[Path]\n\n"
+   
+   "lvconvert "
    "[-s|--snapshot]\n"
    "\t[-c|--chunksize]\n"
    "\t[-d|--debug]\n"
@@ -209,9 +218,9 @@ xx(lvconvert,
    force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG,
    noudevsync_ARG, originname_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
    poolmetadataspare_ARG, readahead_ARG, regionsize_ARG, repair_ARG,
-   replace_ARG, snapshot_ARG, splitmirrors_ARG, stripes_long_ARG,
-   stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, trackchanges_ARG,
-   type_ARG, use_policies_ARG, zero_ARG)
+   replace_ARG, snapshot_ARG, splitmirrors_ARG, splitsnapshot_ARG,
+   stripes_long_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
+   trackchanges_ARG, type_ARG, use_policies_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b040e33..ab1d5a3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -19,6 +19,7 @@
 struct lvconvert_params {
 	int force;
 	int snapshot;
+	int splitsnapshot;
 	int merge;
 	int merge_mirror;
 	int poolmetadataspare;
@@ -170,6 +171,11 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		return 0;
 	}
 
+	if (lp->splitsnapshot && *pargc) {
+		log_error("Too many arguments provided with --splitsnapshot.");
+		return 0;
+	}
+
 	if (lp->pool_data_lv_name && lp->lv_name && lp->poolmetadata_size) {
 		log_error("Please specify either metadata logical volume or its size.");
 		return 0;
@@ -223,6 +229,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (!_check_conversion_type(cmd, type_str))
 		return_0;
 
+	if (arg_count(cmd, splitsnapshot_ARG))
+		lp->splitsnapshot = 1;
+
 	if ((snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || mirror_or_raid_type_requested(cmd, type_str) ||
 	     arg_count(cmd, repair_ARG) || arg_count(cmd, thinpool_ARG))) {
@@ -348,9 +357,24 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, SIGN_NONE);
 	}
 
+	if (lp->splitsnapshot &&
+	    (lp->snapshot || lp->thin || lp->merge || lp->merge_mirror || arg_count(cmd, thinpool_ARG) ||
+	     arg_count(cmd, mirrors_ARG) || arg_count(cmd, repair_ARG) || arg_count(cmd, replace_ARG) ||
+	     arg_count(cmd, chunksize_ARG) || arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG) ||
+	     arg_count(cmd, poolmetadata_ARG) || arg_count(cmd, poolmetadatasize_ARG) ||
+	     arg_count(cmd, readahead_ARG) || arg_count(cmd, stripes_long_ARG) ||
+	     arg_count(cmd, stripesize_ARG) || arg_count(cmd, background_ARG) ||
+	     arg_count(cmd, interval_ARG) || arg_count(cmd, type_ARG) || arg_count(cmd, alloc_ARG) ||
+	     arg_count(cmd, corelog_ARG) || arg_count(cmd, mirrorlog_ARG) ||
+	     arg_count(cmd, splitmirrors_ARG) || arg_count(cmd, originname_ARG) ||
+	     arg_count(cmd, trackchanges_ARG) || arg_count(cmd, use_policies_ARG))) {
+		log_error("Incompatible arguments supplied with --splitsnapshot.");
+		return 0;
+	}
+
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
-	/* There are three types of lvconvert. */
+	/* There are six types of lvconvert. */
 	if (lp->merge) {	/* Snapshot merge */
 		if (arg_count(cmd, regionsize_ARG) || arg_count(cmd, chunksize_ARG) ||
 		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG) ||
@@ -364,8 +388,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
-
-	} else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
+	} else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
+		;
+	else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
 		if (arg_count(cmd, regionsize_ARG)) {
 			log_error("--regionsize is only available with mirrors");
 			return 0;
@@ -1648,7 +1673,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	return 1;
 }
 
-static int is_valid_raid_conversion(const struct segment_type *from_segtype,
+static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
 				    const struct segment_type *to_segtype)
 {
 	if (from_segtype == to_segtype)
@@ -1695,7 +1720,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev
 	}
 }
 
-static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
+static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
 	int replace = 0;
 	int uninitialized_var(image_count);
@@ -1718,7 +1743,7 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 	if (!_lvconvert_validate_thin(lv, lp))
 		return_0;
 
-	if (!is_valid_raid_conversion(seg->segtype, lp->segtype)) {
+	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype)) {
 		log_error("Unable to convert %s/%s from %s to %s",
 			  lv->vg->name, lv->name,
 			  seg->segtype->ops->name(seg), lp->segtype->name);
@@ -1819,9 +1844,83 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 	return 0;
 }
 
-static int lvconvert_snapshot(struct cmd_context *cmd,
-			      struct logical_volume *lv,
-			      struct lvconvert_params *lp)
+static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow,
+				    struct lvconvert_params *lp)
+{
+	struct lvinfo info;
+	struct volume_group *vg = cow->vg;
+
+	if (!lv_is_cow(cow)) {
+		log_error("%s/%s is not a snapshot.", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_origin(cow) || lv_is_external_origin(cow)) {
+		log_error("Unable to split LV %s/%s that is a snapshot origin.", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_merging_cow(cow)) {
+		log_error("Unable to split off snapshot %s/%s being merged into its origin.", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_virtual_origin(origin_from_cow(cow))) {
+		log_error("Unable to split off snapshot %s/%s with virtual origin.", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_thin_pool(cow) || lv_is_pool_metadata_spare(cow)) {
+		log_error("Unable to split off LV %s/%s needed by thin volume(s).", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_MDAS)) {
+		log_error("Unable to split off snapshot %s/%s using old LVM1-style metadata.", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+	if (!vg_check_status(vg, LVM_WRITE))
+		return_ECMD_FAILED;
+
+	if (lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
+		log_error("LV %s/%s type is unsupported with --splitsnapshot.", vg->name, cow->name);
+		return ECMD_FAILED;
+	}
+
+        if (lv_info(cmd, cow, 0, &info, 1, 0)) {
+                if (!lv_check_not_in_use(cmd, cow, &info))
+                        return_0;
+
+                if ((lp->force == PROMPT) &&
+                    lv_is_visible(cow) &&
+                    lv_is_active(cow)) {
+                        if (yes_no_prompt("Do you really want to split off active "
+                                          "logical volume %s? [y/n]: ", cow->name) == 'n') {
+                                log_error("Logical volume %s not split.", cow->name);
+                                return ECMD_FAILED;
+                        }
+                }
+        }
+
+	if (!archive(vg))
+		return_ECMD_FAILED;
+
+	log_verbose("Splitting snapshot %s/%s from its origin.", vg->name, cow->name);
+
+	if (!vg_remove_snapshot(cow))
+		return_ECMD_FAILED;
+
+	backup(vg);
+
+	log_print_unless_silent("Logical Volume %s/%s split from its origin.", vg->name, cow->name);
+
+	return ECMD_PROCESSED;
+}
+
+static int _lvconvert_snapshot(struct cmd_context *cmd,
+			       struct logical_volume *lv,
+			       struct lvconvert_params *lp)
 {
 	struct logical_volume *org;
 
@@ -2602,7 +2701,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv) && !lp->merge) {
+	if (lv_is_cow(lv) && !lp->merge && !lp->splitsnapshot) {
 		log_error("Can't convert snapshot logical volume \"%s\"",
 			  lv->name);
 		return ECMD_FAILED;
@@ -2613,6 +2712,9 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
+	if (lp->splitsnapshot)
+		return _lvconvert_splitsnapshot(cmd, lv, lp);
+
 	if (arg_count(cmd, repair_ARG) && lv_is_thin_pool(lv))
 		return _lvconvert_thinpool_repair(cmd, lv, lp);
 
@@ -2652,7 +2754,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 
-		if (!lvconvert_snapshot(cmd, lv, lp))
+		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 
 	} else if (arg_count(cmd, thinpool_ARG)) {
@@ -2667,7 +2769,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 
-		if (!lvconvert_raid(lv, lp))
+		if (!_lvconvert_raid(lv, lp))
 			return_ECMD_FAILED;
 
 		if (!(failed_pvs = _failed_pv_list(lv->vg)))
@@ -2698,7 +2800,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 /*
  * FIXME move to toollib along with the rest of the drop/reacquire
- * VG locking that is used by lvconvert_merge_single()
+ * VG locking that is used by _lvconvert_merge_single()
  */
 static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context *cmd,
 							     const char *vg_name,
@@ -2727,7 +2829,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 	return lv;
 }
 
-static int poll_logical_volume(struct cmd_context *cmd, struct logical_volume *lv,
+static int _poll_logical_volume(struct cmd_context *cmd, struct logical_volume *lv,
 			       int wait_completion)
 {
 	struct lvinfo info;
@@ -2783,7 +2885,7 @@ bad:
 	unlock_vg(cmd, lp->vg_name);
 
 	if (ret == ECMD_PROCESSED && lp->need_polling)
-		ret = poll_logical_volume(cmd, lp->lv_to_poll,
+		ret = _poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
 
 	release_vg(lv->vg);
@@ -2792,7 +2894,7 @@ out:
 	return ret;
 }
 
-static int lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
+static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
 				  void *handle)
 {
 	struct lvconvert_params *lp = handle;
@@ -2802,10 +2904,10 @@ static int lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume
 
 	/*
 	 * FIXME can't trust lv's VG to be current given that caller
-	 * is process_each_lv() -- poll_logical_volume() may have
+	 * is process_each_lv() -- _poll_logical_volume() may have
 	 * already updated the VG's metadata in an earlier iteration.
 	 * - preemptively drop the VG lock, as is needed for
-	 *   poll_logical_volume(), refresh LV (and VG in the process).
+	 *   _poll_logical_volume(), refresh LV (and VG in the process).
 	 */
 	vg_name = lv->vg->name;
 	unlock_vg(cmd, vg_name);
@@ -2825,7 +2927,7 @@ static int lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume
 		 */
 		unlock_vg(cmd, vg_name);
 
-		ret = poll_logical_volume(cmd, lp->lv_to_poll,
+		ret = _poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
 
 		/* use LCK_VG_WRITE to match lvconvert()'s READ_FOR_UPDATE */
@@ -2856,7 +2958,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &lp,
-				       &lvconvert_merge_single);
+				       &_lvconvert_merge_single);
 	}
 
 	return lvconvert_single(cmd, &lp);


