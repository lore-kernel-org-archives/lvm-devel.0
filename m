From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:45:17 -0000
Subject: LVM2/tools args.h commands.h lvconvert.c
Message-ID: <20100113014517.7690.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:45:16

Modified files:
	tools          : args.h commands.h lvconvert.c 

Log message:
	Add --merge support to lvconvert to start merging a snapshot into its
	origin, example usage:  lvconvert --merge vg/snaplv

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/tools/args.h	2010/01/08 22:00:31	1.71
+++ LVM2/tools/args.h	2010/01/13 01:45:15	1.72
@@ -105,6 +105,7 @@
 arg(size_ARG, 'L', "size", size_mb_arg, 0)
 arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
 arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
+arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(major_ARG, 'j', "major", major_arg, 0)
 arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
 arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
--- LVM2/tools/commands.h	2010/01/12 14:00:52	1.139
+++ LVM2/tools/commands.h	2010/01/13 01:45:16	1.140
@@ -124,12 +124,21 @@
    "\t[-v|--verbose]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[--version]" "\n"
-   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
+   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n\n"
+
+   "lvconvert "
+   "--merge\n"
+   "\t[-b|--background]\n"
+   "\t[-i|--interval seconds]\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[-v|--verbose]\n"
+   "\tSnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   splitmirrors_ARG, name_ARG, mirrorlog_ARG, mirrors_ARG, noudevsync_ARG,
-   regionsize_ARG, repair_ARG, snapshot_ARG, test_ARG, use_policies_ARG,
-   yes_ARG, force_ARG, zero_ARG)
+   merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
+   regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, test_ARG,
+   use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
--- LVM2/tools/lvconvert.c	2010/01/12 14:00:52	1.109
+++ LVM2/tools/lvconvert.c	2010/01/13 01:45:16	1.110
@@ -18,6 +18,7 @@
 
 struct lvconvert_params {
 	int snapshot;
+	int merge;
 	int zero;
 
 	const char *origin;
@@ -52,7 +53,7 @@
 	char *ptr;
 	const char *vg_name = NULL;
 
-	if (lp->snapshot) {
+	if (lp->snapshot && !lp->merge) {
 		if (!*pargc) {
 			log_error("Please specify a logical volume to act as "
 				  "the snapshot origin.");
@@ -102,6 +103,11 @@
 	if (!apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
+	if (*pargc && (lp->snapshot || lp->merge)) {
+		log_error("Too many arguments provided for snapshots");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -113,10 +119,10 @@
 
 	memset(lp, 0, sizeof(*lp));
 
-	if (arg_count(cmd, snapshot_ARG) &&
+	if ((arg_count(cmd, snapshot_ARG) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
 	     arg_count(cmd, repair_ARG))) {
-		log_error("--snapshot argument cannot be mixed "
+		log_error("--snapshot or --merge argument cannot be mixed "
 			  "with --mirrors, --repair or --log");
 		return 0;
 	}
@@ -127,6 +133,11 @@
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
+	if (arg_count(cmd, snapshot_ARG) && arg_count(cmd, merge_ARG)) {
+		log_error("--snapshot and --merge are mutually exclusive");
+		return 0;
+	}
+
 	if (arg_count(cmd, splitmirrors_ARG) && arg_count(cmd, mirrors_ARG)) {
 		log_error("--mirrors and --splitmirrors are "
 			  "mutually exclusive");
@@ -163,6 +174,9 @@
 		return 0;
 	}
 
+	if (arg_count(cmd, merge_ARG))
+		lp->merge = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		/*
 		 * --splitmirrors has been chosen as the mechanism for
@@ -175,7 +189,18 @@
 
 	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
-	if (lp->snapshot) {
+	if (lp->merge) {
+		if (arg_count(cmd, regionsize_ARG) || arg_count(cmd, chunksize_ARG) ||
+		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG)) {
+			log_error("Only --background and --interval are valid "
+				  "arguments for snapshot merge");
+			return 0;
+		}
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+			return_0;
+
+	} else if (lp->snapshot) {
 		if (arg_count(cmd, regionsize_ARG)) {
 			log_error("--regionsize is only available with mirrors");
 			return 0;
@@ -1026,6 +1051,61 @@
 	return r;
 }
 
+static int lvconvert_merge(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   struct lvconvert_params *lp)
+{
+	int r = 0;
+	struct logical_volume *origin = origin_from_cow(lv);
+	struct lv_segment *cow_seg = find_cow(lv);
+
+	/* Check if merge is possible */
+	if (cow_seg->status & SNAPSHOT_MERGE) {
+		log_error("Snapshot %s is already merging", lv->name);
+		return 0;
+	}
+	if (origin->merging_snapshot) {
+		log_error("Snapshot %s is already merging into the origin",
+			  origin->merging_snapshot->cow->name);
+		return 0;
+	}
+
+	init_snapshot_merge(cow_seg, origin);
+
+	/* store vg on disk(s) */
+	if (!vg_write(lv->vg))
+		return_0;
+
+	/* Perform merge */
+	if (!suspend_lv(cmd, origin)) {
+		log_error("Failed to suspend origin %s", origin->name);
+		vg_revert(lv->vg);
+		goto out;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, origin))
+			stack;
+		goto_out;
+	}
+
+	if (!resume_lv(cmd, origin)) {
+		log_error("Failed to reactivate origin %s", origin->name);
+		goto out;
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_warn("WARNING: Unable to deactivate merging snapshot %s", lv->name);
+		/* merge is running regardless of this deactivation failure */
+	}
+
+	r = 1;
+	log_print("Merging of volume %s started.", lv->name);
+out:
+	backup(lv->vg);
+	return r;
+}
+
 static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			    void *handle)
 {
@@ -1036,7 +1116,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv)) {
+	if (lv_is_cow(lv) && !lp->merge) {
 		log_error("Can't convert snapshot logical volume \"%s\"",
 			  lv->name);
 		return ECMD_FAILED;
@@ -1052,7 +1132,21 @@
 		return ECMD_FAILED;
 	}
 
-	if (lp->snapshot) {
+	if (lp->merge) {
+		if (!lv_is_cow(lv)) {
+			log_error("Logical volume \"%s\" is not a snapshot",
+				  lv->name);
+			return ECMD_FAILED;
+		}
+		if (!archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		if (!lvconvert_merge(cmd, lv, lp)) {
+			stack;
+			return ECMD_FAILED;
+		}
+	} else if (lp->snapshot) {
 		if (lv->status & MIRRORED) {
 			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 			return ECMD_FAILED;


