From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Nov 2010 12:17:16 -0000
Subject: LVM2/scripts fsadm.sh
Message-ID: <20101111121716.12701.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-11 12:17:15

Modified files:
	scripts        : fsadm.sh 

Log message:
	Add date configurable variable DATE
	
	Follow the rule to run every command through variable dereference.
	Add a runtime check of translated date to seconds.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/scripts/fsadm.sh	2010/11/10 16:14:03	1.23
+++ LVM2/scripts/fsadm.sh	2010/11/11 12:17:15	1.24
@@ -47,6 +47,7 @@
 RMDIR=rmdir
 BLOCKDEV=blockdev
 BLKID=blkid
+DATE=date
 GREP=grep
 READLINK=readlink
 READLINK_E="-e"
@@ -386,7 +387,7 @@
 #  only one supported
 ####################################
 diff_dates() {
-         echo $(( $(date -u -d"$1" +%s 2>/dev/null) - $(date -u -d"$2" +%s 2>/dev/null) ))
+         echo $(( $($DATE -u -d"$1" +%s 2>/dev/null) - $($DATE -u -d"$2" +%s 2>/dev/null) ))
 }
 
 ###################
@@ -445,7 +446,7 @@
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVM" \
+  -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVM" \
   || error "Required command definitions in the script are missing!"
 
 $LVM version >/dev/null 2>&1 || error "Could not run lvm binary '$LVM'"
@@ -453,6 +454,7 @@
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test $TEST64BIT -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
 $(echo Y | $GREP Y >/dev/null) || error "Grep does not work properly"
+test $($DATE -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work"
 
 
 if [ "$#" -eq 0 ] ; then


