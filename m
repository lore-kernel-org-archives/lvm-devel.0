From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 12 Aug 2010 04:09:03 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
Message-ID: <20100812040903.8618.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-12 04:09:00

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	man            : pvcreate.8.in 
	test           : t-covercmd.sh t-pvcreate-operation.sh 
	                 t-vgcfgbackup-usage.sh 
	tools          : args.h commands.h pvcreate.c 

Log message:
	Require --restorefile when using pvcreate --uuid.
	
	Introduce --norestorefile to allow user to override the new requirement.
	
	This can also be overridden with "devices/require_restorefile_with_uuid"
	in lvm.conf -- however the default is 1.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1699&r2=1.1700
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2010/08/11 12:14:23	1.1699
+++ LVM2/WHATS_NEW	2010/08/12 04:08:59	1.1700
@@ -1,5 +1,7 @@
 Version 2.02.73 - 
 ================================
+  Add --norestorefile option to pvcreate.
+  Require --restorefile when using pvcreate --uuid.
   Recognise and give preference to md device partitions (blkext major).
   Never scan internal LVM devices.
   Split-mirror operations were ignoring user-specified PVs.
--- LVM2/doc/example.conf.in	2010/07/02 02:09:57	1.5
+++ LVM2/doc/example.conf.in	2010/08/12 04:08:59	1.6
@@ -130,6 +130,9 @@
     # Set this to 1 to skip such devices.  This should only be needed
     # in recovery situations.
     ignore_suspended_devices = 0
+
+    # Allow use of pvcreate --uuid without requiring --restorefile.
+    require_restorefile_with_uuid = 1
 }
 
 # This section that allows you to configure the nature of the
--- LVM2/lib/config/defaults.h	2010/06/30 12:49:28	1.63
+++ LVM2/lib/config/defaults.h	2010/08/12 04:08:59	1.64
@@ -30,6 +30,7 @@
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 
--- LVM2/man/pvcreate.8.in	2010/07/13 15:04:23	1.8
+++ LVM2/man/pvcreate.8.in	2010/08/12 04:09:00	1.9
@@ -17,6 +17,7 @@
 .RB [ \-\-dataalignment alignment ]
 .RB [ \-\-dataalignmentoffset alignment_offset ]
 .RB [ \-\-restorefile file ]
+.RB [ \-\-norestorefile ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
 .RB [ \-\-version ]
@@ -60,7 +61,9 @@
 Without this option, \fBpvcreate\fP generates a random uuid.
 All of your physical volumes must have unique uuids.
 You need to use this option before restoring a backup of LVM metadata 
-onto a replacement device - see \fBvgcfgrestore\fP(8).
+onto a replacement device - see \fBvgcfgrestore\fP(8).  As such, use of
+\fB--restorefile\fP is compulsory unless the \fB--norestorefile\fP is
+used.
 .TP
 .BR \-y ", " \-\-yes
 Answer yes to all questions.
@@ -138,6 +141,10 @@
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care. See also \fBvgconvert\fP(8).
 .TP
+.BR \-\-norestorefile
+In conjunction with \fB--uuid\fP, this allows a uuid to be specified
+without also requiring that a backup of the metadata be provided.
+.TP
 .BR \-\-labelsector " sector"
 By default the PV is labelled with an LVM2 identifier in its second 
 sector (sector 1).  This lets you use a different sector near the
--- LVM2/test/t-covercmd.sh	2010/06/28 21:49:31	1.8
+++ LVM2/test/t-covercmd.sh	2010/08/12 04:09:00	1.9
@@ -30,7 +30,7 @@
 pvcreate --metadatacopies 0 $dev2
 pvcreate --metadatacopies 0 $dev3
 pvcreate $dev4
-pvcreate -u $TEST_UUID --metadatacopies 0 $dev5
+pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 $dev5
 vgcreate -c n $vg $devs
 lvcreate -n $lv -l 5 -i5 -I256 $vg
 
--- LVM2/test/t-pvcreate-operation.sh	2010/04/07 14:46:26	1.18
+++ LVM2/test/t-pvcreate-operation.sh	2010/08/12 04:09:00	1.19
@@ -95,17 +95,20 @@
 bogusuuid=fred
 
 # pvcreate rejects uuid option with less than 32 characters
-not pvcreate --uuid $bogusuuid $dev1
+not pvcreate --norestorefile --uuid $bogusuuid $dev1
+
+# pvcreate rejects uuid option without restorefile
+not pvcreate --uuid $uuid1 $dev1
 
 # pvcreate rejects uuid already in use
-pvcreate --uuid $uuid1 $dev1
-not pvcreate --uuid $uuid1 $dev2
+pvcreate --norestorefile --uuid $uuid1 $dev1
+not pvcreate --norestorefile --uuid $uuid1 $dev2
 
 # pvcreate rejects non-existent file given with restorefile
 not pvcreate --uuid $uuid1 --restorefile $backupfile $dev1
 
 # pvcreate rejects restorefile with uuid not found in file
-pvcreate --uuid $uuid1 $dev1
+pvcreate --norestorefile --uuid $uuid1 $dev1
 vgcfgbackup -f $backupfile
 not pvcreate --uuid $uuid2 --restorefile $backupfile $dev2
 
--- LVM2/test/t-vgcfgbackup-usage.sh	2010/04/12 19:00:23	1.3
+++ LVM2/test/t-vgcfgbackup-usage.sh	2010/08/12 04:09:00	1.4
@@ -37,6 +37,6 @@
 pvcreate -ff -y $dev2
 vgcfgbackup -f "$(pwd)/backup.$$" $vg
 sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
-pvcreate -ff -y -u $pv1_uuid $dev1
-pvcreate -ff -y -u $pv2_uuid $dev2
+pvcreate -ff -y --norestorefile -u $pv1_uuid $dev1
+pvcreate -ff -y --norestorefile -u $pv2_uuid $dev2
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
--- LVM2/tools/args.h	2010/06/30 20:21:03	1.78
+++ LVM2/tools/args.h	2010/08/12 04:09:00	1.79
@@ -27,6 +27,7 @@
 arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
+arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
--- LVM2/tools/commands.h	2010/07/07 19:14:58	1.153
+++ LVM2/tools/commands.h	2010/08/12 04:09:00	1.154
@@ -497,6 +497,7 @@
    "Initialize physical volume(s) for use by LVM",
    0,
    "pvcreate " "\n"
+   "\t[--norestorefile]\n"
    "\t[--restorefile file]\n"
    "\t[-d|--debug]" "\n"
    "\t[-f[f]|--force [--force]] " "\n"
@@ -517,8 +518,9 @@
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
-   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
-   metadatasize_ARG, metadataignore_ARG, physicalvolumesize_ARG,
+   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
+   metadatasize_ARG, metadataignore_ARG, norestorefile_ARG,
+   physicalvolumesize_ARG, pvmetadatacopies_ARG,
    restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
--- LVM2/tools/pvcreate.c	2010/03/16 15:48:27	1.90
+++ LVM2/tools/pvcreate.c	2010/08/12 04:09:00	1.91
@@ -36,6 +36,16 @@
 		return 0;
 	}
 
+	if (!arg_count(cmd, restorefile_ARG) && arg_count(cmd, uuidstr_ARG)) {
+		if (!arg_count(cmd, norestorefile_ARG) &&
+		    find_config_tree_bool(cmd,
+					  "devices/require_restorefile_with_uuid",
+					  DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID)) {
+			log_error("--restorefile is required with --uuid");
+			return 0;
+		}
+	}
+
 	if (arg_count(cmd, uuidstr_ARG) && argc != 1) {
 		log_error("Can only set uuid on one volume at once");
 		return 0;


