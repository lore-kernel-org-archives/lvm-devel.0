From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jan 2009 18:02:58 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20090106180258.24201.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-01-06 18:02:58

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Fix lvmdump /sys listing to include virtual devices directory.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1015&r2=1.1016
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2008/12/22 09:04:35	1.1015
+++ LVM2/WHATS_NEW	2009/01/06 18:02:57	1.1016
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix lvmdump /sys listing to include virtual devices directory.
   Add "--refresh" functionality to vgchange and vgmknodes.
   Check for maximal LV size when wiping device.
   Calculate mirror log size instead of using 1 extent.
--- LVM2/scripts/lvm_dump.sh	2008/08/28 10:40:44	1.13
+++ LVM2/scripts/lvm_dump.sh	2009/01/06 18:02:58	1.14
@@ -197,7 +197,8 @@
 log "$LS -laR /dev > \"$dir/dev_listing\" 2>> \"$log\""
 
 myecho "Gathering /sys/block listing..."
-log "$LS -laR /sys/block > \"$dir/sysblock_listing\""
+log "$LS -laR /sys/block > \"$dir/sysblock_listing\"  2>> \"$log\""
+log "$LS -laR /sys/devices/virtual/block >> \"$dir/sysblock_listing\"  2>> \"$log\""
 
 if (( $metadata )); then
 	myecho "Gathering LVM metadata from Physical Volumes..."


