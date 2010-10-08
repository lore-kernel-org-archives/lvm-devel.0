From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 11:18:30 -0000
Subject: LVM2/scripts fsadm.sh
Message-ID: <20101008111830.29768.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 11:18:29

Modified files:
	scripts        : fsadm.sh 

Log message:
	Replace  "can not" with "cannot"

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/scripts/fsadm.sh	2010/05/14 11:33:21	1.12
+++ LVM2/scripts/fsadm.sh	2010/10/08 11:18:29	1.13
@@ -227,7 +227,7 @@
 
 try_umount() {
 	yes_no "Do you want to unmount \"$MOUNTED\"" && dry $UMOUNT "$MOUNTED" && return 0
-	error "Can not proceed with mounted filesystem \"$MOUNTED\""
+	error "Cannot proceed with mounted filesystem \"$MOUNTED\""
 }
 
 validate_parsing() {
@@ -289,7 +289,7 @@
 ########################
 # Resize XFS filesystem
 # - mounted for upsize
-# - can not downsize
+# - cannot downsize
 ########################
 resize_xfs() {
 	detect_mounted
@@ -345,7 +345,7 @@
 ###################
 check() {
 	detect_fs "$1"
-	detect_mounted && error "Can not fsck device \"$VOLUME\", filesystem mounted on $MOUNTED"
+	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
 	  *) dry $FSCK $YES "$VOLUME" ;;


