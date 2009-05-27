From: agk@sourceware.org <agk@sourceware.org>
Date: 27 May 2009 16:30:31 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in tools/args. ...
Message-ID: <20090527163031.9547.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-27 16:30:30

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in 
	tools          : args.h commands.h lvcreate.c lvmcmdline.c 

Log message:
	Make --snapshot optional with lvcreate --virtualsize.
	Generalise --virtualoriginsize to --virtualsize.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1127&r2=1.1128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2009/05/27 13:23:41	1.1127
+++ LVM2/WHATS_NEW	2009/05/27 16:30:29	1.1128
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Make --snapshot optional with lvcreate --virtualsize.
+  Generalise --virtualoriginsize to --virtualsize.
   Skip virtual origins in process_each_lv_in_vg().
   Fix counting of virtual origin LVs in vg_validate.
   Attempt to load dm-zero module if zero target needed but not present.
--- LVM2/man/lvcreate.8.in	2009/04/29 20:14:21	1.6
+++ LVM2/man/lvcreate.8.in	2009/05/27 16:30:30	1.7
@@ -26,8 +26,10 @@
  \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-c|\-\-chunksize ChunkSize]
 \-n|\-\-name SnapshotLogicalVolumeName
-\-s|\-\-snapshot
-[OriginalLogicalVolumePath | VolumeGroupName \-\-virtualoriginsize VirtualOriginSize]
+{{\-s|\-\-snapshot}
+OriginalLogicalVolumePath | 
+[\-s|\-\-snapshot]
+VolumeGroupName \-\-virtualsize VirtualSize}
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .B vgcreate(8), vgchange(8)
@@ -152,11 +154,11 @@
 rate at which the snapshot data is growing so you can avoid running out
 of space.
 .TP
-.I \-\-virtualoriginsize VirtualOriginSize
-In conjunction with \-\-snapshot, create a sparse device of the given size
-(in MB by default).  Anything written to the device will be returned when
-reading from it.  Reading from other areas of the device will return
-blocks of zeros.  It is implemented by creating a hidden virtual device of the
+.I \-\-virtualsize VirtualSize
+Create a sparse device of the given size (in MB by default) using a snapshot.  
+Anything written to the device will be returned when reading from it.
+Reading from other areas of the device will return blocks of zeros.
+It is implemented by creating a hidden virtual device of the
 requested size using the zero target.  A suffix of _vorigin is used for
 this device.
 .TP
--- LVM2/tools/args.h	2009/04/25 01:18:00	1.63
+++ LVM2/tools/args.h	2009/05/27 16:30:30	1.64
@@ -59,6 +59,7 @@
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
+arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2009/04/25 01:18:00	1.125
+++ LVM2/tools/commands.h	2009/05/27 16:30:30	1.126
@@ -145,7 +145,9 @@
    "\t[--version]\n"
    "\tVolumeGroupName [PhysicalVolumePath...]\n\n"
 
-   "lvcreate -s|--snapshot\n"
+   "lvcreate \n"
+   "\t{ {-s|--snapshot} OriginalLogicalVolume[Path] |\n"
+   "\t  [-s|--snapshot] VolumeGroupName[Path] --virtualsize VirtualSize}\n"
    "\t[-c|--chunksize]\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"
@@ -163,15 +165,14 @@
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
-   "\t[OriginalLogicalVolume[Path] |\n"
-   "\t VolumeGroupName[Path] --virtualoriginsize VirtualOriginSize]]\n"
+
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, virtualoriginsize_ARG, zero_ARG)
+   test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- LVM2/tools/lvcreate.c	2009/05/27 13:07:37	1.190
+++ LVM2/tools/lvcreate.c	2009/05/27 16:30:30	1.191
@@ -66,7 +66,7 @@
 	if (arg_count(cmd, name_ARG))
 		lp->lv_name = arg_value(cmd, name_ARG);
 
-	if (lp->snapshot && !arg_count(cmd, virtualoriginsize_ARG)) {
+	if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		if (!argc) {
 			log_err("Please specify a logical volume to act as "
 				"the snapshot origin.");
@@ -178,12 +178,12 @@
 	}
 
 	/* Size returned in kilobyte units; held in sectors */
-	if (arg_count(cmd, virtualoriginsize_ARG)) {
-		if (arg_sign_value(cmd, virtualoriginsize_ARG, 0) == SIGN_MINUS) {
+	if (arg_count(cmd, virtualsize_ARG)) {
+		if (arg_sign_value(cmd, virtualsize_ARG, 0) == SIGN_MINUS) {
 			log_error("Negative virtual origin size is invalid");
 			return 0;
 		}
-		lp->voriginsize = arg_uint64_value(cmd, virtualoriginsize_ARG,
+		lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG,
 						   UINT64_C(0));
 		if (!lp->voriginsize) {
 			log_error("Virtual origin size may not be zero");
@@ -362,7 +362,8 @@
 	if (arg_count(cmd, stripes_ARG) && lp->stripes == 1)
 		log_print("Redundant stripes argument: default is 1");
 
-	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp))
+	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
+	    arg_count(cmd, virtualsize_ARG))
 		lp->snapshot = 1;
 
 	lp->mirrors = 1;
@@ -406,10 +407,6 @@
 			log_error("-c is only available with snapshots");
 			return 0;
 		}
-		if (arg_count(cmd, virtualoriginsize_ARG)) {
-			log_error("--virtualoriginsize is only available with snapshots");
-			return 0;
-		}
 	}
 
 	if (lp->mirrors > 1) {
@@ -722,7 +719,7 @@
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (arg_count(cmd, virtualoriginsize_ARG))
+		if (arg_count(cmd, virtualsize_ARG))
 			origin_active = 1;
 		else {
 
@@ -733,7 +730,7 @@
 			}
 			if (lv_is_virtual_origin(org)) {
 				log_error("Can't share virtual origins. "
-					  "Use --virtualoriginsize.");
+					  "Use --virtualsize.");
 				return 0;
 			}
 			if (lv_is_cow(org)) {
--- LVM2/tools/lvmcmdline.c	2009/04/02 14:59:48	1.95
+++ LVM2/tools/lvmcmdline.c	2009/05/27 16:30:30	1.96
@@ -816,7 +816,8 @@
 	/* Handle synonyms */
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
-	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG))
+	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
+	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG))
 		return EINVALID_CMD_LINE;
 
 	/* Zero indicates success */


