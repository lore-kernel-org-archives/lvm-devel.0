From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 12:06:15 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100629120615.13861.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 12:06:15

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for --metadataignore and --vgmetadatacopies changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1638&r2=1.1639

--- LVM2/WHATS_NEW	2010/06/28 14:19:41	1.1638
+++ LVM2/WHATS_NEW	2010/06/29 12:06:14	1.1639
@@ -1,5 +1,14 @@
 Version 2.02.69 - 
 ================================
+  Add {pv|vg}_mda_used_count which displays a count of mdas w/ignored bit clear.
+  Add vg_mda_copies which displays the value of --vgmetadatacopies.
+  Describe --vgmetadatacopies in lvm.conf and other man pages.
+  Interpret --metadatacopies based on PV or VG command.
+  Allow "all" and "unmanaged" values for --vgmetadatacopies in addition to #.
+  Add vgcreate/vgchange --vgmetadatacopies to select #mdas in a VG.
+  Make the metadata ignore bit control read/write metadata areas in a PV.
+  Add pvchange --metadataignore to set or clear a metadata ignore bit.
+  Refactor metadata code to prepare for --metadataignore / --vgmetadatacopies.
   Ensure region_size of mirrored log does not exceed its full size.
   Generate liblvm2app and libdevmapper exported symbols from header file.
   Preload libc locale messages to prevent reading it in memory locked state.


