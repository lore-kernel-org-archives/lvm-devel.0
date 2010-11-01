From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Nov 2010 14:08:54 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101101140854.13044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-01 14:08:52

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Return different status code for fsadm check of mounted filesystem
	
	Return status code 3 for fsadm check of mounted filesystem - used later with
	lvresize update patch to better support online filesystem resize.
	
	Also makes a more consistent user interruption and returns status code 2
	in this case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1783&r2=1.1784
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2010/10/29 21:15:23	1.1783
+++ LVM2/WHATS_NEW	2010/11/01 14:08:51	1.1784
@@ -1,5 +1,6 @@
 Version 2.02.76 - 
 ===================================
+  Modify fsadm to return different status code for check of mounted filesystem.
   Update VG metadata only once in vgchange when making multiple changes.
   Allow independent vgchange arguments to be used together.
   Automatically unmount invalidated snapshots in dmeventd.
--- LVM2/scripts/fsadm.sh	2010/10/08 15:02:05	1.20
+++ LVM2/scripts/fsadm.sh	2010/11/01 14:08:52	1.21
@@ -23,6 +23,11 @@
 # reiserfs: resize_reiserfs, reiserfstune
 # xfs: xfs_growfs, xfs_info
 #
+# Return values:
+#   0 success
+#   1 error
+#   2 break detected
+#   3 unsupported online filesystem check for given mounted fs
 
 TOOL=fsadm
 
@@ -126,6 +131,8 @@
 	IFS=$IFS_OLD
 	trap 2
 
+	test "$1" -eq 2 && verbose "Break detected"
+
 	if [ "$DO_LVRESIZE" -eq 2 ]; then
 		# start LVRESIZE with the filesystem modification flag
 		# and allow recursive call of fsadm
@@ -349,7 +356,6 @@
 	# if the size parameter is missing use device size
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
-	trap cleanup 2
 	IFS=$NL
 	case "$FSTYPE" in
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
@@ -365,7 +371,10 @@
 ###################
 check() {
 	detect_fs "$1"
-	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
+	if detect_mounted ; then
+		verbose "Skipping filesystem check for device \"$VOLUME\" as the filesystem is mounted on $MOUNTED";
+		cleanup 3
+	fi
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment
@@ -380,6 +389,7 @@
 # start point of this script
 # - parsing parameters
 #############################
+trap "cleanup 2" 2
 
 # test if we are not invoked recursively
 test -n "$FSADM_RUNNING" && exit 0


