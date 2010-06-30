From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 14:04:17 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100630140417.2853.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 14:04:15

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	doc            : example.conf.in 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.242&r2=1.243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1641&r2=1.1642
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.383&r2=1.384
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/VERSION	2010/06/23 19:35:11	1.242
+++ LVM2/VERSION	2010/06/30 14:04:15	1.243
@@ -1 +1 @@
-2.02.69(2)-cvs (2010-06-23)
+2.02.69(2)-cvs (2010-06-30)
--- LVM2/VERSION_DM	2010/06/23 19:35:11	1.53
+++ LVM2/VERSION_DM	2010/06/30 14:04:15	1.54
@@ -1 +1 @@
-1.02.51-cvs (2010-06-23)
+1.02.51-cvs (2010-06-30)
--- LVM2/WHATS_NEW	2010/06/30 14:01:39	1.1641
+++ LVM2/WHATS_NEW	2010/06/30 14:04:15	1.1642
@@ -1,18 +1,16 @@
-Version 2.02.69 - 
+Version 2.02.69 - 30th June 2010
 ================================
   Fix vgremove to allow removal of VG with missing PVs. (2.02.52)
-  Add --metadataignore to pvcreate and vgextend and define in lvm.conf.
-  Add {pv|vg}_mda_used_count which displays a count of mdas w/ignored bit clear.
-  Add vg_mda_copies which displays the value of --vgmetadatacopies.
+  Add metadata/vgmetadatacopies to lvm.conf.
+  Add --metadataignore to pvcreate and vgextend.
+  Add vg_mda_copies, pv_mda_used_count and vg_mda_used_count to reports.
   Describe --vgmetadatacopies in lvm.conf and other man pages.
-  Interpret --metadatacopies based on PV or VG command.
-  Allow "all" and "unmanaged" values for --vgmetadatacopies in addition to #.
-  Add vgcreate/vgchange --vgmetadatacopies to select #mdas in a VG.
+  Add --[vg]metadatacopies to select number of mdas to use in a VG.
   Make the metadata ignore bit control read/write metadata areas in a PV.
   Add pvchange --metadataignore to set or clear a metadata ignore bit.
   Refactor metadata code to prepare for --metadataignore / --vgmetadatacopies.
   Ensure region_size of mirrored log does not exceed its full size.
-  Generate liblvm2app and libdevmapper exported symbols from header file.
+  Generate liblvm2app exported symbols from header file.
   Preload libc locale messages to prevent reading it in memory locked state.
   Fix handling of simultaneous mirror image and mirrored log image failure.
 
--- LVM2/WHATS_NEW_DM	2010/06/23 19:35:11	1.383
+++ LVM2/WHATS_NEW_DM	2010/06/30 14:04:15	1.384
@@ -1,5 +1,6 @@
-Version 1.02.51 - 
+Version 1.02.51 - 30th June 2010
 ================================
+  Generate libdevmapper exported symbols from header file.
 
 Version 1.02.50 - 23rd June 2010
 ================================
--- LVM2/doc/example.conf.in	2010/06/28 20:40:15	1.3
+++ LVM2/doc/example.conf.in	2010/06/30 14:04:15	1.4
@@ -456,7 +456,7 @@
 
     # pvmetadatacopies = 1
 
-    # Default number of copies of metadata to hold on each VG.
+    # Default number of copies of metadata to maintain for each VG.
     # If set to a non-zero value, LVM automatically manages the PV
     # 'metadataignore' flags (see pvchange) to achieve the requested
     # copies of metadata.  You may set a value larger than the


