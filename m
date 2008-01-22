From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jan 2008 02:48:53 -0000
Subject: LVM2 lib/metadata/metadata.c man/vgsplit.8 tes ...
Message-ID: <20080122024853.24323.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-22 02:48:53

Modified files:
	lib/metadata   : metadata.c 
	man            : vgsplit.8 
	test           : t-vgsplit-operation.sh 
	tools          : commands.h vgsplit.c 

Log message:
	Fix vgsplit - print error if vgcreate option given w/existing vg destination
	Fix vgsplit - reject split if metadata types or clustered attributes differ
	Fix vgsplit - remove physicalextentsize option
	Add vgsplit test cases

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/lib/metadata/metadata.c	2008/01/17 17:17:09	1.152
+++ LVM2/lib/metadata/metadata.c	2008/01/22 02:48:52	1.153
@@ -1124,6 +1124,20 @@
 		return 0;
 	}
 
+	/* Metadata types must be the same */
+	if (vg_to->fid->fmt != vg_from->fid->fmt) {
+		log_error("Metadata types differ for \"%s\" and \"%s\"",
+			  vg_to->name, vg_from->name);
+		return 0;
+	}
+
+	/* Clustering attribute must be the same */
+	if ((vg_to->status & CLUSTERED) != (vg_from->status & CLUSTERED)) {
+		log_error("Clustered attribute differs for \"%s\" and \"%s\"",
+			  vg_to->name, vg_from->name);
+		return 0;
+	}
+
 	/* Check no conflicts with LV names */
 	list_iterate_items(lvl1, &vg_to->lvs) {
 		name1 = lvl1->lv->name;
--- LVM2/man/vgsplit.8	2008/01/17 03:18:18	1.6
+++ LVM2/man/vgsplit.8	2008/01/22 02:48:52	1.7
@@ -15,8 +15,6 @@
 .IR type ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
-.RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 SourceVolumeGroupName DestinationVolumeGroupName
@@ -35,17 +33,18 @@
 does not exist, a new volume group will be created.  The default attributes
 for the new volume group can be specified with \fB\-\-alloc\fR,
 \fB\-\-clustered\fR, \fB\-\-maxlogicalvolumes\fR, \fB\-\-metadatatype\fR,
-\fB\-\-maxphysicalvolumes\fR, and \fB\-\-physicalextentsize\fR
-(see \fBvgcreate(8)\fR for a description of these options).
-If any of these options are not given, the default attribute(s) are taken
-from
+and \fB\-\-maxphysicalvolumes\fR (see \fBvgcreate(8)\fR for a description
+of these options).  If any of these options are not given, default
+attribute(s) are taken from
 .I SourceVolumeGroupName\fP.
 
 If
 .I DestinationVolumeGroupName
 does exist, it will be checked for compatibility with
 .I SourceVolumeGroupName
-before the physical volumes are moved.
+before the physical volumes are moved. Specifying any of the above default
+volume group attributes with an existing destination volume group is an error,
+and no split will occur.
 
 Logical Volumes cannot be split between Volume Groups.
 Each existing Logical Volume must be entirely on the Physical Volumes forming
--- LVM2/test/t-vgsplit-operation.sh	2008/01/16 21:21:22	1.4
+++ LVM2/test/t-vgsplit-operation.sh	2008/01/22 02:48:53	1.5
@@ -23,6 +23,9 @@
   rm -f "$f1" "$f2" "$f3" "$f4"
 }
 
+# FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
+# fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
+# metadata
 test_expect_success \
   'set up temp files, loopback devices, PVs, vgnames' \
   'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
@@ -48,20 +51,6 @@
    vgremove $vg1 &&
    vgremove $vg2'
 
-#test_expect_success \
-# 'vgcreate accepts 8.00M physicalextentsize for VG' \
-#  'vgcreate $vg --physicalextentsize 8.00M $d1 $d2 &&
-#   check_vg_field_ $vg vg_extent_size 8.00M &&
-#   vgremove $vg'
-
-test_expect_success \
-  'vgsplit accepts 8.00M physicalextentsize for new VG' \
-  'vgcreate $vg1 $d1 $d2 &&
-   vgsplit --physicalextentsize 8.00M $vg1 $vg2 $d1 &&
-   check_vg_field_ $vg2 vg_extent_size 8.00M &&
-   vgremove $vg1 &&
-   vgremove $vg2'
-
 test_expect_success \
   'vgsplit accepts --maxphysicalvolumes 128 on new VG' \
   'vgcreate $vg1 $d1 $d2 &&
@@ -79,22 +68,64 @@
    vgremove $vg2'
 
 test_expect_success \
-  'vgsplit rejects vgs with incompatible extent_size' \
-  'vgcreate --physicalextentsize 4M $vg1 $d1 $d2 &&
-   vgcreate --physicalextentsize 8M $vg2 $d3 $d4 &&
+  'vgsplit rejects split because max_pv of destination would be exceeded' \
+  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Extent sizes differ" err &&
+   grep "^  Maximum number of physical volumes (2) exceeded" err &&
    vgremove $vg2 &&
    vgremove $vg1'
 
 test_expect_success \
-  'vgsplit rejects split because max_pv of destination would be exceeded' \
+  'vgsplit rejects split because maxphysicalvolumes given with existing vg' \
   'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
-   vgsplit $vg1 $vg2 $d1 2>err;
+   vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $d1 2>err;
    status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Maximum number of physical volumes (2) exceeded" err &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because maxlogicalvolumes given with existing vg' \
+  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+   vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because alloc given with existing vg' \
+  'vgcreate --alloc cling $vg1 $d1 $d2 &&
+   vgcreate --alloc cling $vg2 $d3 $d4 &&
+   vgsplit --alloc cling $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because clustered given with existing vg' \
+  'vgcreate --clustered n $vg1 $d1 $d2 &&
+   vgcreate --clustered n $vg2 $d3 $d4 &&
+   vgsplit --clustered n $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because metadata types differ' \
+  'pvcreate -ff -M1 $d3 $d4 &&
+   pvcreate -ff -M2 $d1 $d2 &&
+   vgcreate -M1 $vg1 $d3 $d4 &&
+   vgcreate -M2 $vg2 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d3 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Metadata types differ" err &&
    vgremove $vg2 &&
    vgremove $vg1'
 
--- LVM2/tools/commands.h	2008/01/16 17:14:56	1.107
+++ LVM2/tools/commands.h	2008/01/22 02:48:53	1.108
@@ -871,7 +871,7 @@
    ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
 
 xx(vgsplit,
-   "Move physical volumes into a new volume group",
+   "Move physical volumes into a new or existing volume group",
    "vgsplit " "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
@@ -881,7 +881,6 @@
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]" "\n"
@@ -890,7 +889,7 @@
 
    alloc_ARG, autobackup_ARG, clustered_ARG,
    maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
-   metadatatype_ARG, physicalextentsize_ARG, test_ARG)
+   metadatatype_ARG, test_ARG)
 
 xx(version,
    "Display software and driver version information",
--- LVM2/tools/vgsplit.c	2008/01/16 19:54:39	1.46
+++ LVM2/tools/vgsplit.c	2008/01/22 02:48:53	1.47
@@ -210,6 +210,17 @@
 	return 1;
 }
 
+/*
+ * Has the user given an option related to a new vg as the split destination?
+ */
+static int new_vg_option_specified(struct cmd_context *cmd)
+{
+	return(arg_count(cmd, clustered_ARG) ||
+	       arg_count(cmd, alloc_ARG) ||
+	       arg_count(cmd, maxphysicalvolumes_ARG) ||
+	       arg_count(cmd, maxlogicalvolumes_ARG));
+}
+
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct vgcreate_params vp_new;
@@ -253,7 +264,11 @@
 	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
 				      LCK_VG_WRITE | LCK_NONBLOCK,
 				      0, 0))) {
-		log_warn("Volume group \"%s\" already exists", vg_name_to);
+		if (new_vg_option_specified(cmd)) {
+			log_error("Volume group \"%s\" exists, but new VG "
+				    "option specified", vg_name_to);
+			goto error;
+		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto error;
 	} else {


