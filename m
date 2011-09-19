From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 13:47:39 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20110919134739.29958.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 13:47:38

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Surround all executed commands with quotes
	
	In case someone would use filename paths with spaces when changing
	this script surround commands with '"'.
	
	With default settings there is no change in behavior.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2118&r2=1.2119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2011/09/19 13:43:50	1.2118
+++ LVM2/WHATS_NEW	2011/09/19 13:47:37	1.2119
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Surround all executed commands with quotes in fsadm script.
   Fix missing '$' in test for content of "$LVM" in fsadm script.
   Move debug message in exec_cmd after sync_local_dev_names.
   Fix clvmd processing of invalid request on local socket.
--- LVM2/scripts/fsadm.sh	2011/09/19 13:43:50	1.25
+++ LVM2/scripts/fsadm.sh	2011/09/19 13:47:38	1.26
@@ -127,7 +127,7 @@
 	test "$MOUNTPOINT" = "$TEMPDIR" && MOUNTPOINT="" temp_umount
 	if [ -n "$REMOUNT" ]; then
 		verbose "Remounting unmounted filesystem back"
-		dry $MOUNT "$VOLUME" "$MOUNTED"
+		dry "$MOUNT" "$VOLUME" "$MOUNTED"
 	fi
 	IFS=$IFS_OLD
 	trap 2
@@ -140,7 +140,7 @@
 		_FSADM_YES=$YES
 		export _FSADM_YES
 		unset FSADM_RUNNING
-		dry exec $LVM lvresize $VERB $FORCE -r -L${NEWSIZE}b $VOLUME_ORIG
+		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
 	fi
         
 	# error exit status for break
@@ -175,7 +175,7 @@
 detect_fs() {
 	VOLUME_ORIG=$1
 	VOLUME=${1#/dev/}
-	VOLUME=$($READLINK $READLINK_E "/dev/$VOLUME") || error "Cannot get readlink $1"
+	VOLUME=$("$READLINK" $READLINK_E "/dev/$VOLUME") || error "Cannot get readlink $1"
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
 	  /dev/dm-[0-9]*)
@@ -184,7 +184,7 @@
 	esac
 	# use /dev/null as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
-	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
+	FSTYPE=$("$BLKID" -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
 	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
 	FSTYPE=${FSTYPE%%\"*}
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
@@ -193,12 +193,12 @@
 # check if the given device is already mounted and where
 # FIXME: resolve swap usage and device stacking
 detect_mounted()  {
-	test -e $PROCMOUNTS || error "Cannot detect mounted device $VOLUME"
+	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
 
-	MOUNTED=$($GREP ^"$VOLUME" $PROCMOUNTS)
+	MOUNTED=$("$GREP" ^"$VOLUME" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$($GREP ^"$RVOLUME" $PROCMOUNTS)
+	test -z "$MOUNTED" && MOUNTED=$("$GREP" ^"$RVOLUME" "$PROCMOUNTS")
 
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
@@ -207,8 +207,8 @@
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
-		MOUNTED=$(LANG=C $MOUNT | $GREP ^"$VOLUME")
-		test -z "$MOUNTED" && MOUNTED=$(LANG=C $MOUNT | $GREP ^"$RVOLUME")
+		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" ^"$VOLUME")
+		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" ^"$RVOLUME")
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
 	fi
@@ -219,12 +219,12 @@
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64
-	$BLOCKDEV 2>&1 | $GREP getsize64 >/dev/null
+	"$BLOCKDEV" 2>&1 | "$GREP" getsize64 >/dev/null
 	if test $? -eq 0; then
-		DEVSIZE=$($BLOCKDEV --getsize64 "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
+		DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
 	else
-		DEVSIZE=$($BLOCKDEV --getsize "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
-		SSSIZE=$($BLOCKDEV --getss "$VOLUME") || error "Cannot block size read device \"$VOLUME\""
+		DEVSIZE=$("$BLOCKDEV" --getsize "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
+		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME") || error "Cannot block size read device \"$VOLUME\""
 		DEVSIZE=$(($DEVSIZE * $SSSIZE))
 	fi
 }
@@ -237,14 +237,14 @@
 }
 
 temp_mount() {
-	dry $MKDIR -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR"
-	dry $MOUNT "$VOLUME" "$TEMPDIR" || error "Failed to mount $TEMPDIR"
+	dry "$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR"
+	dry "$MOUNT" "$VOLUME" "$TEMPDIR" || error "Failed to mount $TEMPDIR"
 }
 
 temp_umount() {
-	dry $UMOUNT "$TEMPDIR" || error "Failed to umount $TEMPDIR"
-	dry $RMDIR "${TEMPDIR}" || error "Failed to remove $TEMPDIR"
-	dry $RMDIR "${TEMPDIR%%m}" || error "Failed to remove ${TEMPDIR%%m}"
+	dry "$UMOUNT" "$TEMPDIR" || error "Failed to umount \"$TEMPDIR\""
+	dry "$RMDIR" "${TEMPDIR}" || error "Failed to remove \"$TEMPDIR\""
+	dry "$RMDIR" "${TEMPDIR%%m}" || error "Failed to remove \"${TEMPDIR%%m}\""
 }
 
 yes_no() {
@@ -263,7 +263,7 @@
 }
 
 try_umount() {
-	yes_no "Do you want to unmount \"$MOUNTED\"" && dry $UMOUNT "$MOUNTED" && return 0
+	yes_no "Do you want to unmount \"$MOUNTED\"" && dry "$UMOUNT" "$MOUNTED" && return 0
 	error "Cannot proceed with mounted filesystem \"$MOUNTED\""
 }
 
@@ -277,13 +277,13 @@
 ####################################
 resize_ext() {
 	verbose "Parsing $TUNE_EXT -l \"$VOLUME\""
-	for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
+	for i in $(LANG=C "$TUNE_EXT" -l "$VOLUME"); do
 		case "$i" in
 		  "Block size"*) BLOCKSIZE=${i##*  } ;;
 		  "Block count"*) BLOCKCOUNT=${i##*  } ;;
 		esac
 	done
-	validate_parsing $TUNE_EXT
+	validate_parsing "$TUNE_EXT"
 	decode_size $1 $BLOCKSIZE
 	FSFORCE=$FORCE
 
@@ -293,14 +293,14 @@
 		if test -n "$MOUNTED" ; then
 			# Forced fsck -f for umounted extX filesystem.
 			case "$-" in
-			  *i*) dry $FSCK $YES -f "$VOLUME" ;;
-			  *) dry $FSCK -f -p "$VOLUME" ;;
+			  *i*) dry "$FSCK" $YES -f "$VOLUME" ;;
+			  *) dry "$FSCK" -f -p "$VOLUME" ;;
 			esac
 		fi
 	fi
 
 	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
-	dry $RESIZE_EXT $FSFORCE "$VOLUME" $NEWBLOCKCOUNT
+	dry "$RESIZE_EXT" $FSFORCE "$VOLUME" $NEWBLOCKCOUNT
 }
 
 #############################
@@ -312,19 +312,19 @@
 	detect_mounted && verbose "ReiserFS resizes only unmounted filesystem" && try_umount
 	REMOUNT=$MOUNTED
 	verbose "Parsing $TUNE_REISER \"$VOLUME\""
-	for i in $(LANG=C $TUNE_REISER "$VOLUME"); do
+	for i in $(LANG=C "$TUNE_REISER" "$VOLUME"); do
 		case "$i" in
 		  "Blocksize"*) BLOCKSIZE=${i##*: } ;;
 		  "Count of blocks"*) BLOCKCOUNT=${i##*: } ;;
 		esac
 	done
-	validate_parsing $TUNE_REISER
+	validate_parsing "$TUNE_REISER"
 	decode_size $1 $BLOCKSIZE
 	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs: $NEWBLOCKCOUNT)"
 	if [ -n "$YES" ]; then
-		echo y | dry $RESIZE_REISER -s $NEWSIZE "$VOLUME"
+		echo y | dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
 	else
-		dry $RESIZE_REISER -s $NEWSIZE "$VOLUME"
+		dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
 	fi
 }
 
@@ -341,18 +341,18 @@
 		temp_mount || error "Cannot mount Xfs filesystem"
 	fi
 	verbose "Parsing $TUNE_XFS \"$MOUNTPOINT\""
-	for i in $(LANG=C $TUNE_XFS "$MOUNTPOINT"); do
+	for i in $(LANG=C "$TUNE_XFS" "$MOUNTPOINT"); do
 		case "$i" in
 		  "data"*) BLOCKSIZE=${i##*bsize=} ; BLOCKCOUNT=${i##*blocks=} ;;
 		esac
 	done
 	BLOCKSIZE=${BLOCKSIZE%%[^0-9]*}
 	BLOCKCOUNT=${BLOCKCOUNT%%[^0-9]*}
-	validate_parsing $TUNE_XFS
+	validate_parsing "$TUNE_XFS"
 	decode_size $1 $BLOCKSIZE
 	if [ $NEWBLOCKCOUNT -gt $BLOCKCOUNT ]; then
 		verbose "Resizing Xfs mounted on \"$MOUNTPOINT\" to fill device \"$VOLUME\""
-		dry $RESIZE_XFS $MOUNTPOINT
+		dry "$RESIZE_XFS" $MOUNTPOINT
 	elif [ $NEWBLOCKCOUNT -eq $BLOCKCOUNT ]; then
 		verbose "Xfs filesystem already has the right size"
 	else
@@ -387,7 +387,7 @@
 #  only one supported
 ####################################
 diff_dates() {
-         echo $(( $($DATE -u -d"$1" +%s 2>/dev/null) - $($DATE -u -d"$2" +%s 2>/dev/null) ))
+         echo $(( $("$DATE" -u -d"$1" +%s 2>/dev/null) - $("$DATE" -u -d"$2" +%s 2>/dev/null) ))
 }
 
 ###################
@@ -404,7 +404,7 @@
 	  "ext2"|"ext3"|"ext4")
 		IFS_CHECK=$IFS
 		IFS=$NL
-		for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
+		for i in $(LANG=C "$TUNE_EXT" -l "$VOLUME"); do
 			case "$i" in
 			  "Last mount"*) LASTMOUNT=${i##*: } ;;
 			  "Last checked"*) LASTCHECKED=${i##*: } ;;
@@ -424,11 +424,11 @@
 	esac
 
 	case "$FSTYPE" in
-	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
+	  "xfs") dry "$XFS_CHECK" "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
-		  *i*) dry $FSCK $YES $FORCE "$VOLUME" ;;
-		  *) dry $FSCK $FORCE -p "$VOLUME" ;;
+		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
+		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
 		esac
 	esac
 }
@@ -449,12 +449,12 @@
   -a -n "$DATE" -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "$LVM" \
   || error "Required command definitions in the script are missing!"
 
-$LVM version >/dev/null 2>&1 || error "Could not run lvm binary '$LVM'"
-$($READLINK -e / >/dev/null 2>&1) || READLINK_E="-f"
+"$LVM" version >/dev/null 2>&1 || error "Could not run lvm binary \"$LVM\""
+$("$READLINK" -e / >/dev/null 2>&1) || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
-test $TEST64BIT -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
-$(echo Y | $GREP Y >/dev/null) || error "Grep does not work properly"
-test $($DATE -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work"
+test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
+$(echo Y | "$GREP" Y >/dev/null) || error "Grep does not work properly"
+test $("$DATE" -u -d"Jan 01 00:00:01 1970" +%s) -eq 1 || error "Date translation does not work"
 
 
 if [ "$#" -eq 0 ] ; then


