From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 19:36:54 -0000
Subject: LVM2 ./WHATS_NEW man/fsadm.8.in scripts/fsadm.sh
Message-ID: <20110919193654.18353.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 19:36:53

Modified files:
	.              : WHATS_NEW 
	man            : fsadm.8.in 
	scripts        : fsadm.sh 

Log message:
	Add support for DM_DEV_DIR
	
	Follow other commands support this directory setting.
	Useful for test suite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2123&r2=1.2124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2011/09/19 18:38:43	1.2123
+++ LVM2/WHATS_NEW	2011/09/19 19:36:52	1.2124
@@ -1,6 +1,6 @@
 Version 2.02.89 - 
 ==================================
-  Add support for non /dev device paths into fsadm script.
+  Add support for DM_DEV_DIR device path into fsadm script.
   Support different PATH setting for fsadm script testing.
   Surround all executed commands with quotes in fsadm script.
   Fix missing '$' in test for content of "$LVM" in fsadm script.
--- LVM2/man/fsadm.8.in	2011/09/07 08:50:35	1.5
+++ LVM2/man/fsadm.8.in	2011/09/19 19:36:53	1.6
@@ -63,6 +63,10 @@
 .TP
 .B TMPDIR
 The temporary directory name for mount points. Defaults to "/tmp". 
+.TP
+.B DM_DEV_DIR
+The device directory name.
+Defaults to "/dev" and must be an absolute path.
 
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/scripts/fsadm.sh	2011/09/19 14:52:33	1.28
+++ LVM2/scripts/fsadm.sh	2011/09/19 19:36:53	1.29
@@ -67,12 +67,14 @@
 FSTYPE=unknown
 VOLUME=unknown
 TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$/m"
+DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 BLOCKSIZE=
 BLOCKCOUNT=
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
 PROCMOUNTS="/proc/mounts"
+NULL="$DM_DEV_DIR/null"
 
 IFS_OLD=$IFS
 # without bash $'\n'
@@ -176,17 +178,18 @@
 # dereference device name if it is symbolic link
 detect_fs() {
 	VOLUME_ORIG=$1
-	VOLUME=${1#/dev/}
-	VOLUME=$("$READLINK" $READLINK_E "/dev/$VOLUME") || VOLUME=$("$READLINK" $READLINK_E "$VOLUME_ORIG") || error "Cannot get readlink \"$1\""
+	VOLUME=${1/#"${DM_DEV_DIR}/"/}
+	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
+          # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
-		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="/dev/mapper/$SYSVOLUME"
+		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
 		;;
 	esac
-	# use /dev/null as cache file to be sure about the result
+	# use null device as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
-	FSTYPE=$("$BLKID" -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
+	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
 	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
 	FSTYPE=${FSTYPE%%\"*}
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
@@ -221,7 +224,7 @@
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64
-	"$BLOCKDEV" 2>&1 | "$GREP" getsize64 >/dev/null
+	"$BLOCKDEV" 2>&1 | "$GREP" getsize64 >"$NULL"
 	if test $? -eq 0; then
 		DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
 	else
@@ -389,7 +392,7 @@
 #  only one supported
 ####################################
 diff_dates() {
-         echo $(( $("$DATE" -u -d"$1" +%s 2>/dev/null) - $("$DATE" -u -d"$2" +%s 2>/dev/null) ))
+         echo $(( $("$DATE" -u -d"$1" +%s 2>"$NULL") - $("$DATE" -u -d"$2" +%s 2>"$NULL") ))
 }
 
 ###################
@@ -451,11 +454,11 @@
   -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$LVM" \
   || error "Required command definitions in the script are missing!"
 
-"$LVM" version >/dev/null 2>&1 || error "Could not run lvm binary \"$LVM\""
-$("$READLINK" -e / >/dev/null 2>&1) || READLINK_E="-f"
+"$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\""
+$("$READLINK" -e / >"$NULL" 2>&1) || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
-$(echo Y | "$GREP" Y >/dev/null) || error "Grep does not work properly"
+$(echo Y | "$GREP" Y >"$NULL") || error "Grep does not work properly"
 test $("$DATE" -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work"
 
 


