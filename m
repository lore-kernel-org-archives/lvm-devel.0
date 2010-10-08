From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 14:55:22 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008145522.31858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 14:55:20

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Fix detection of mounted filesystem.
	
	Update the way how fsadm detects mounted filesystem.
	With udev /dev/dm-XXX paths are now returned - but mount or /proc/mounts
	prints names in form of /dev/mapper/vg-lv - so the match was not found.
	Fixex RHBZ #638050.
	
	Current solution uses same trick as mount and detects vg-lv name through
	/sys where available - this should be reasonable safe.
	
	Instead of calling mount without parameter to get actual mount table,
	switch to use /proc/mounts directly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1751&r2=1.1752
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2010/10/08 14:49:25	1.1751
+++ LVM2/WHATS_NEW	2010/10/08 14:55:19	1.1752
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix detection of mounted filesystems for fsadm when udev is used.
   Fix assignment of default value to LVM variable is fsadm.
   Fix support for --yes flag for fsadm.
   Do not execute lvresize with --dry-run option for fsadm.
--- LVM2/scripts/fsadm.sh	2010/10/08 14:49:26	1.17
+++ LVM2/scripts/fsadm.sh	2010/10/08 14:55:20	1.18
@@ -65,6 +65,7 @@
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
+PROCMOUNTS="/proc/mounts"
 
 IFS_OLD=$IFS
 # without bash $'\n'
@@ -164,10 +165,15 @@
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-        VOLUME=${1#/dev/}
+	VOLUME_ORIG=$1
+	VOLUME=${1#/dev/}
 	VOLUME=$($READLINK $READLINK_E "/dev/$VOLUME") || error "Cannot get readlink $1"
-	# strip newline from volume name
-	VOLUME=${VOLUME%%$NL}
+	RVOLUME=$VOLUME
+	case "$RVOLUME" in
+	  /dev/dm-[0-9]*)
+		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="/dev/mapper/$SYSVOLUME"
+		;;
+	esac
 	# use /dev/null as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
 	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
@@ -177,11 +183,19 @@
 }
 
 # check if the given device is already mounted and where
+# FIXME: resolve swap usage and device stacking
 detect_mounted()  {
-	$MOUNT >/dev/null || error "Cannot detect mounted device $VOLUME"
-	MOUNTED=$($MOUNT | $GREP "$VOLUME")
-	MOUNTED=${MOUNTED##* on }
-	MOUNTED=${MOUNTED% type *} # allow type in the mount name
+	test -e $PROCMOUNTS || error "Cannot detect mounted device $VOLUME"
+
+	MOUNTED=$($GREP ^"$VOLUME" $PROCMOUNTS)
+
+	# for empty string try again with real volume name
+	test -z "$MOUNTED" && MOUNTED=$($GREP ^"$RVOLUME" $PROCMOUNTS)
+
+	# cut device name prefix and trim everything past mountpoint
+	# echo translates \040 to spaces
+	MOUNTED=${MOUNTED#* }
+	MOUNTED=$(echo -n -e ${MOUNTED%% *})
 	test -n "$MOUNTED"
 }
 


