From: bmr@sourceware.org <bmr@sourceware.org>
Date: 25 Apr 2007 14:49:27 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20070425144927.6140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-04-25 15:49:27

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Make lvm_dump.sh capture a listing of /sys/block entries.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.600&r2=1.601
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2007/04/24 15:13:13	1.600
+++ LVM2/WHATS_NEW	2007/04/25 14:49:27	1.601
@@ -1,5 +1,7 @@
 Version 2.02.25 -
 =================================
+  Add /sys/block listings to lvm_dump.sh
+  Make lvm_dump.sh list /dev recursively
   Fix thread race in clvmd.
   Add scan_sector param to label_read and _find_labeller.
   Make clvmd cope with quorum devices on RHEL5
@@ -11,7 +13,6 @@
   Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
   Split metadata areas in vgsplit properly.
   Add extra internal error checking to clvmd
-  Make lvm_dump.sh list /dev recursively
 
 Version 2.02.24 - 19th March 2007
 =================================
--- LVM2/scripts/lvm_dump.sh	2007/04/19 23:06:05	1.4
+++ LVM2/scripts/lvm_dump.sh	2007/04/25 14:49:27	1.5
@@ -149,6 +149,9 @@
 myecho "Gathering /dev listing..."
 log "$LS -laR /dev > $dir/dev_listing 2>> $log"
 
+myecho "Gathering /sys/block listing..."
+log "$LS -laR /sys/block > $dir/sysblock_listing"
+
 if (( $metadata )); then
 	myecho "Gathering LVM metadata from Physical Volumes..."
 


