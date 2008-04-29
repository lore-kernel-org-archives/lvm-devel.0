From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Apr 2008 15:25:32 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh tools/lvresize.c
Message-ID: <20080429152532.21263.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-04-29 15:25:28

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 
	tools          : lvresize.c 

Log message:
	fixing fsadm usage with older blockdev,blkid,readline tools
	fixing lvresize extension code path where size was not set for fsadm

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.863&r2=1.864
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2008/04/29 08:55:19	1.863
+++ LVM2/WHATS_NEW	2008/04/29 15:25:25	1.864
@@ -11,6 +11,8 @@
   Fix metadata corruption writing lvm1-formatted metadata with snapshots.
   Add --prefixes to reporting tools for field name prefix output format.
   Fix lvconvert -m0 allocatable space check.
+  Fix fsadm.sh to work with older blockdev,blkid,readlink
+  Fix lvresize - extension was not passing new size to fsadm
 
 Version 2.02.35 - 15th April 2008
 =================================
--- LVM2/scripts/fsadm.sh	2008/02/06 12:45:32	1.5
+++ LVM2/scripts/fsadm.sh	2008/04/29 15:25:27	1.6
@@ -43,7 +43,9 @@
 BLOCKDEV=blockdev
 BLKID=blkid
 GREP=grep
+CUT=cut
 READLINK=readlink
+READLINK_E="-e"
 FSCK=fsck
 XFS_CHECK=xfs_check
 
@@ -154,9 +156,10 @@
 # dereference device name if it is symbolic link
 detect_fs() {
         VOLUME=${1#/dev/}
-	VOLUME=$($READLINK -e -n "/dev/$VOLUME") || error "Cannot get readlink $1"
+	VOLUME=$($READLINK $READLINK_E -n "/dev/$VOLUME") || error "Cannot get readlink $1"
 	# use /dev/null as cache file to be sure about the result
-	FSTYPE=$($BLKID -c /dev/null -o value -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
+	# use 'cut' to be compatible with older version of blkid that does not provide option '-o value'
+	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME" | cut -d \" -f 2) || error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
@@ -171,7 +174,15 @@
 
 # get the full size of device in bytes
 detect_device_size() {
-	DEVSIZE=$($BLOCKDEV --getsize64 "$VOLUME") || error "Cannot read device \"$VOLUME\""
+	# check if blockdev supports getsize64
+	$BLOCKDEV 2>&1 | $GREP getsize64 >/dev/null 
+	if test $? -eq 0; then 
+		DEVSIZE=$($BLOCKDEV --getsize64 "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
+	else
+		DEVSIZE=$($BLOCKDEV --getsize "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
+		SSSIZE=$($BLOCKDEV --getss "$VOLUME") || error "Cannot block size read device \"$VOLUME\""
+		DEVSIZE=$(($DEVSIZE * $SSSIZE))
+	fi
 }
 
 # round up $1 / $2
@@ -349,9 +360,10 @@
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVRESIZE" \
+  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVRESIZE" -a -n "$CUT" \
   || error "Required command definitions in the script are missing!"
-$($READLINK -e -n / >/dev/null 2>&1) || error "$READLINK does not support options -e -n"
+
+$($READLINK -e -n / >/dev/null 2>&1) || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test $TEST64BIT -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
 $(echo Y | $GREP Y >/dev/null) || error "Grep does not work properly"
--- LVM2/tools/lvresize.c	2008/04/10 19:59:43	1.96
+++ LVM2/tools/lvresize.c	2008/04/29 15:25:28	1.97
@@ -630,6 +630,11 @@
 				  lp->lv_name);
 			return ECMD_FAILED;
 		}
+		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64,
+				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
+		    log_error("Couldn't generate new LV size string");
+		    return ECMD_FAILED;
+		}
 		if (!exec_cmd("fsadm", "resize", lv_path, size_buf)) {
 			stack;
 			return ECMD_FAILED;


