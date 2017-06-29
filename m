From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:24:57 -0400
Subject: master - fsadm: fix shell globbing
Message-ID: <201706292024.v5TKOvEx025587@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b68235c51970dc3e159ebf7aa0ac5f4928414574
Commit:        b68235c51970dc3e159ebf7aa0ac5f4928414574
Parent:        0021d707fb93a98526bd02c2192d0c1b4ec9cfa1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 13:15:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:15 2017 +0200

fsadm: fix shell globbing

Fixing reported issue for shellcheck.
Use "" properly to avoid having shell variables split.
---
 WHATS_NEW        |    1 +
 scripts/fsadm.sh |   70 +++++++++++++++++++++++++++---------------------------
 2 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f1ded2d..2c98f5e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Fix shellcheck reported issues for script files.
 
 Version 2.02.172 - 28th June 2017
 =================================
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index adf9b55..996cd1f 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2017 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -32,7 +32,7 @@
 TOOL=fsadm
 
 _SAVEPATH=$PATH
-PATH=/sbin:/usr/sbin:/bin:/usr/sbin:$PATH
+PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
 
 # utilities
 TUNE_EXT=tune2fs
@@ -152,11 +152,11 @@ cleanup() {
 		export _FSADM_YES _FSADM_EXTOFF
 		unset FSADM_RUNNING
 		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
-		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
+		dry exec "$LVM" lvresize $VERB $FORCE -r -L"${NEWSIZE}b" "$VOLUME_ORIG"
 	fi
 
 	# error exit status for break
-	exit ${1:-1}
+	exit "${1:-1}"
 }
 
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
@@ -173,9 +173,9 @@ decode_size() {
 	     *) NEWSIZE=$(( $1 * $2 )) ;;
 	esac
 	#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
-	NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
+	NEWBLOCKCOUNT=$(( NEWSIZE / $2 ))
 
-	if [ $DO_LVRESIZE -eq 1 ]; then
+	if [ "$DO_LVRESIZE" -eq 1 ]; then
 		# start lvresize, but first cleanup mounted dirs
 		DO_LVRESIZE=2
 		cleanup 0
@@ -204,13 +204,13 @@ detect_fs() {
 	case "$RVOLUME" in
 	  # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
-		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
-		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
+		read <"/sys/block/${RVOLUME#/dev/}/dm/name" SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
+		read <"/sys/block/${RVOLUME#/dev/}/dev" MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
 		MAJOR=${MAJORMINOR%%:*}
 		MINOR=${MAJORMINOR##*:}
 		;;
 	  *)
-		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" ${RVOLUME})
+		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$RVOLUME")
 		test -n "$STAT" || error "Cannot get major:minor for \"$VOLUME\"."
 		eval "$STAT"
 		MAJORMINOR="${MAJOR}:${MINOR}"
@@ -258,7 +258,7 @@ check_valid_mounted_device() {
 	case "$VOL" in
 	  # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
-		read </sys/block/${VOL#/dev/}/dev MOUNTEDMAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
+		read <"/sys/block/${VOL#/dev/}/dev" MOUNTEDMAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
 		;;
 	  *)
 		STAT=$(stat --format "MOUNTEDMAJORMINOR=\$((0x%t)):\$((0x%T))" "$VOL")
@@ -280,20 +280,20 @@ detect_mounted_with_proc_self_mountinfo() {
 	# Use 'find' to not fail on to long list of args with too many pids
 	# only 1st. line is needed
 	test -z "$MOUNTED" &&
-		test $(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR") -gt 0 &&
+		test "$(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR")" -gt 0 &&
 		MOUNTED=$(find "$PROCDIR" -maxdepth 2 -name mountinfo -print0 |  xargs -0 "$GREP" "^[0-9]* [0-9]* $MAJORMINOR " 2>/dev/null | head -1 2>/dev/null)
 
 	# TODO: for performance compare with sed and stop with 1st. match:
 	# sed -n "/$MAJORMINOR/ {;p;q;}"
 
 	# extract 2nd field after ' - ' separator as mouted device
-	MOUNTDEV=$(echo ${MOUNTED##* - } | cut -d ' ' -f 2)
-	MOUNTDEV=$(echo -n -e ${MOUNTDEV})
+	MOUNTDEV=$(echo "${MOUNTED##* - }" | cut -d ' ' -f 2)
+	MOUNTDEV=$(echo -n -e "$MOUNTDEV")
 
 	# extract 5th field as mount point
 	# echo -e translates \040 to spaces
-	MOUNTED=$(echo ${MOUNTED} | cut -d ' ' -f 5)
-	MOUNTED=$(echo -n -e ${MOUNTED})
+	MOUNTED=$(echo "$MOUNTED" | cut -d ' ' -f 5)
+	MOUNTED=$(echo -n -e "$MOUNTED")
 
 	test -n "$MOUNTED" || return 1   # Not seen mounted anywhere
 
@@ -310,11 +310,11 @@ detect_mounted_with_proc_mounts() {
 	# for empty string try again with real volume name
 	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
 
-	MOUNTDEV=$(echo -n -e ${MOUNTED%% *})
+	MOUNTDEV=$(echo -n -e "${MOUNTED%% *}")
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
 	MOUNTED=${MOUNTED#* }
-	MOUNTED=$(echo -n -e ${MOUNTED%% *})
+	MOUNTED=$(echo -n -e "${MOUNTED%% *}")
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
@@ -333,13 +333,13 @@ detect_mounted_with_proc_mounts() {
 
 	# If still nothing found and volume is in use
 	# check every known mount point against MAJOR:MINOR
-	if test $(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR") -gt 0 ; then
+	if test "$(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR")" -gt 0 ; then
 		while IFS=$'\n' read -r i ; do
-			MOUNTDEV=$(echo -n -e ${i%% *})
+			MOUNTDEV=$(echo -n -e "${i%% *}")
 			MOUNTED=${i#* }
-			MOUNTED=$(echo -n -e ${MOUNTED%% *})
-			STAT=$(stat --format "%d" $MOUNTED)
-			validate_mounted_major_minor $(decode_major_minor "$STAT")
+			MOUNTED=$(echo -n -e "${MOUNTED%% *}")
+			STAT=$(stat --format "%d" "$MOUNTED")
+			validate_mounted_major_minor "$(decode_major_minor "$STAT")"
 		done < "$PROCMOUNTS"
 	fi
 
@@ -370,7 +370,7 @@ detect_device_size() {
 		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
 		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME")
 		test -n "$SSSIZE" || error "Cannot read sector size of device \"$VOLUME\"."
-		DEVSIZE=$(($DEVSIZE * $SSSIZE))
+		DEVSIZE=$(("$DEVSIZE" * "$SSSIZE"))
 	fi
 }
 
@@ -438,11 +438,11 @@ resize_ext() {
 		esac
 	done
 	validate_parsing "$TUNE_EXT"
-	decode_size $1 $BLOCKSIZE
+	decode_size "$1" "$BLOCKSIZE"
 	FSFORCE=$FORCE
 
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
-		test $IS_MOUNTED -eq 1 && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
+		test "$IS_MOUNTED" -eq 1 && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
 		if test -n "$MOUNTED" ; then
 			# Forced fsck -f for umounted extX filesystem.
@@ -454,7 +454,7 @@ resize_ext() {
 	fi
 
 	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
-	dry "$RESIZE_EXT" $FSFORCE "$VOLUME" $NEWBLOCKCOUNT
+	dry "$RESIZE_EXT" $FSFORCE "$VOLUME" "$NEWBLOCKCOUNT"
 }
 
 #############################
@@ -473,12 +473,12 @@ resize_reiser() {
 		esac
 	done
 	validate_parsing "$TUNE_REISER"
-	decode_size $1 $BLOCKSIZE
+	decode_size "$1" "$BLOCKSIZE"
 	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs: $NEWBLOCKCOUNT)"
 	if [ -n "$YES" ]; then
-		echo y | dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
+		echo y | dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"
 	else
-		dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
+		dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"
 	fi
 }
 
@@ -503,11 +503,11 @@ resize_xfs() {
 	BLOCKSIZE=${BLOCKSIZE%%[^0-9]*}
 	BLOCKCOUNT=${BLOCKCOUNT%%[^0-9]*}
 	validate_parsing "$TUNE_XFS"
-	decode_size $1 $BLOCKSIZE
-	if [ $NEWBLOCKCOUNT -gt $BLOCKCOUNT ]; then
+	decode_size "$1" "$BLOCKSIZE"
+	if [ "$NEWBLOCKCOUNT" -gt "$BLOCKCOUNT" ]; then
 		verbose "Resizing Xfs mounted on \"$MOUNTPOINT\" to fill device \"$VOLUME\""
-		dry "$RESIZE_XFS" $MOUNTPOINT
-	elif [ $NEWBLOCKCOUNT -eq $BLOCKCOUNT ]; then
+		dry "$RESIZE_XFS" "$MOUNTPOINT"
+	elif [ "$NEWBLOCKCOUNT" -eq "$BLOCKCOUNT" ]; then
 		verbose "Xfs filesystem already has the right size"
 	else
 		error "Xfs filesystem shrinking is unsupported."
@@ -567,7 +567,7 @@ check() {
 		case "$LASTMOUNT" in
 		  *"n/a") ;; # nothing to do - system was not mounted yet
 		  *)
-			LASTDIFF=$(diff_dates $LASTMOUNT $LASTCHECKED)
+			LASTDIFF=$(diff_dates "$LASTMOUNT" "$LASTCHECKED")
 			if test "$LASTDIFF" -gt 0 ; then
 				verbose "Filesystem has not been checked after the last mount, using fsck -f"
 				FORCE="-f"
@@ -617,7 +617,7 @@ $("$READLINK" -e / >"$NULL" 2>&1) || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic."
 $(echo Y | "$GREP" Y >"$NULL") || error "Grep does not work properly."
-test $("$DATE" -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work."
+test "$("$DATE" -u -d"Jan 01 00:00:01 1970" +%s)" -eq 1 || error "Date translation does not work."
 
 
 if [ "$#" -eq 0 ] ; then


