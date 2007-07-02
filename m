From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Jul 2007 20:18:38 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh
Message-ID: <20070702201838.25506.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-07-02 20:18:38

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 

Log message:
	Add kernel and device-mapper targets versions report to lvmdump.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.644&r2=1.645
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2007/07/02 11:17:20	1.644
+++ LVM2/WHATS_NEW	2007/07/02 20:18:38	1.645
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Add kernel and device-mapper targets versions report to lvmdump.
   Don't use index and rindex functions marked by SUSv3 as legacy.
   Fix vgsplit if splitting all PVs from VG.
   Fix lvmdiskscan volume reporting when run in the lvm shell
--- LVM2/scripts/lvm_dump.sh	2007/04/25 14:49:27	1.5
+++ LVM2/scripts/lvm_dump.sh	2007/07/02 20:18:38	1.6
@@ -18,6 +18,7 @@
 CUT=cut
 DATE=date
 BASENAME=basename
+UNAME=uname
 
 # user may override lvm and dmsetup location by setting LVM_BINARY
 # and DMSETUP_BINARY respectively
@@ -131,6 +132,10 @@
 $LVM lvs --version >> $dir/versions 2>> $log
 echo "DEVICE MAPPER VERSION:" >> $dir/versions
 $DMSETUP --version >> $dir/versions 2>> $log
+echo "KERNEL VERSION:" >> $dir/versions
+$UNAME -a >> $dir/versions 2>> $log
+echo "DM TARGETS VERSIONS:" >> $dir/versions
+$DMSETUP targets >> $dir/versions 2>> $log
 
 myecho "Gathering dmsetup info..."
 log "$DMSETUP info -c > $dir/dmsetup_info 2>> $log"


