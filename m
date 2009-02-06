From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Feb 2009 14:28:07 -0000
Subject: LVM2 scripts/fsadm.sh ./WHATS_NEW
Message-ID: <20090206142807.15458.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-02-06 14:28:07

Modified files:
	scripts        : fsadm.sh 
	.              : WHATS_NEW 

Log message:
	Remove external dependency on the 'cut' command in fsadm

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1036&r2=1.1037

--- LVM2/scripts/fsadm.sh	2009/02/04 12:47:05	1.8
+++ LVM2/scripts/fsadm.sh	2009/02/06 14:28:06	1.9
@@ -43,7 +43,6 @@
 BLOCKDEV=blockdev
 BLKID=blkid
 GREP=grep
-CUT=cut
 READLINK=readlink
 READLINK_E="-e"
 FSCK=fsck
@@ -158,8 +157,10 @@
         VOLUME=${1#/dev/}
 	VOLUME=$($READLINK $READLINK_E -n "/dev/$VOLUME") || error "Cannot get readlink $1"
 	# use /dev/null as cache file to be sure about the result
-	# use 'cut' to be compatible with older version of blkid that does not provide option '-o value'
-	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME" | $CUT -d \" -f 2) || error "Cannot get FSTYPE of \"$VOLUME\""
+	# not using option '-o value' to be compatible with older version of blkid
+	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
+	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
+	FSTYPE=${FSTYPE%%\"*}
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
@@ -360,7 +361,7 @@
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVRESIZE" -a -n "$CUT" \
+  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVRESIZE" \
   || error "Required command definitions in the script are missing!"
 
 $($READLINK -e -n / >/dev/null 2>&1) || READLINK_E="-f"
--- LVM2/WHATS_NEW	2009/02/06 12:41:51	1.1036
+++ LVM2/WHATS_NEW	2009/02/06 14:28:07	1.1037
@@ -1,7 +1,8 @@
 Version 2.02.45 - 
 ===================================
+  Remove external dependency on the 'cut' command in fsadm.
   Fix pvs segfault when pv mda attributes requested for not available PV.
-  Add support for ext4 resize in fsadm
+  Add support for ext4 resize in fsadm.
   Move locking_type reading inside init_locking().
   Rename get_vgs() to get_vgnames() and clarify related error messages.
   Allow clvmd to be built with all cluster managers & select one on cmdline.


