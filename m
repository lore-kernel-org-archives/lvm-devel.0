From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:34 +0200
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-2-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This commit adds new functionality in the form of new commands. Namely
it is create, list, add and remove. This commit also changes the way how
are commands recognised an executed. The new approach is more suitable
for bigger number of commands.

Resize command is also significantly reworked. Unlike in the old
approach fsadm will always attempt to resize the logical volume as well,
since this is what it is expected. Leave the --lvresize option for
backwards compatibility, but remove it from the help. If no file system
resides on the logical volume, only the volume will be resized.

* Create command provides the functionality of creating a new logical
  volumes including defined file system.
* List command provides the functionality of listing useful information
  about the logical volumes, file systems and devices.
* Add command allows to add devices into volume groups (pool).
* Remove command allows to remove the volumes or volume groups from the
  system.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |  978 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 908 insertions(+), 70 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index c8cc5e0..f0da586 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -14,10 +14,16 @@
 #
 # Author: Zdenek Kabelac <zkabelac@redhat.com>
 #
-# Script for resizing devices (usable for LVM resize)
+# Author: Lukas Czerner <lczerner@redhat.com>
+#    - Significantly extended fsadm functionality
+#    - Implemented new commands "add", "create", "list", "remove"
+#    - Rework of "resize" command
+#
+# Utility to manage logical volumes
 #
 # Needed utilities:
-#   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check
+#   mount, umount, grep, readlink, blockdev, blkid, fsck, xfs_check, bc, df
+#   xfs_db, mktemp
 #
 # ext2/ext3/ext4: resize2fs, tune2fs
 # reiserfs: resize_reiserfs, reiserfstune
@@ -29,7 +35,7 @@
 #   2 break detected
 #   3 unsupported online filesystem check for given mounted fs
 
-TOOL=fsadm
+TOOL=$(basename "$0")
 
 _SAVEPATH=$PATH
 PATH=/sbin:/usr/sbin:/bin:/usr/sbin:$PATH
@@ -54,6 +60,8 @@ READLINK=readlink
 READLINK_E="-e"
 FSCK=fsck
 XFS_CHECK=xfs_check
+BC=bc
+DF=df
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -63,7 +71,6 @@ DRY=0
 VERB=
 FORCE=
 EXTOFF=0
-DO_LVRESIZE=0
 FSTYPE=unknown
 VOLUME=unknown
 TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$/m"
@@ -73,10 +80,16 @@ BLOCKCOUNT=
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
+IN_GROUP=
+NOT_IN_GROUP=
+GROUP=
 PROCMOUNTS="/proc/mounts"
+PROCDEVICES="/proc/devices"
+PROCPARTITIONS="/proc/partitions"
 NULL="$DM_DEV_DIR/null"
 
-IFS_OLD=$IFS
+MAX_VGS=999
+
 # without bash $'\n'
 NL='
 '
@@ -96,7 +109,6 @@ tool_usage() {
 	echo "    -e | --ext-offline  unmount filesystem before ext2/ext3/ext4 resize"
 	echo "    -f | --force        Bypass sanity checks"
 	echo "    -n | --dry-run      Print commands without running them"
-	echo "    -l | --lvresize     Resize given device (if it is LVM device)"
 	echo "    -y | --yes          Answer \"yes\" at any prompts"
 	echo
 	echo "  new_size - Absolute number of filesystem blocks to be in the filesystem,"
@@ -115,13 +127,37 @@ error() {
 	cleanup 1
 }
 
-dry() {
+warn() {
+	echo "$TOOL: $@" >&2
+}
+
+dry_nofail() {
 	if [ "$DRY" -ne 0 ]; then
 		verbose "Dry execution $@"
 		return 0
 	fi
 	verbose "Executing $@"
-	$@
+	local IFS=" "
+	eval "$*"
+}
+
+dry() {
+	dry_nofail "$@" || error "FAILED. Exitting!"
+}
+
+float_math() {
+	if [ $# -le 0 ]; then
+		return
+	fi
+	result=$(LANG=C echo "scale=2; $@" | "$BC" -q 2> /dev/null)
+	echo "$result"
+}
+
+is_natural() {
+	case "$1" in
+		"" | *[!0-9]*) return 1;;
+		*) return 0;;
+	esac
 }
 
 cleanup() {
@@ -132,54 +168,140 @@ cleanup() {
 		verbose "Remounting unmounted filesystem back"
 		dry "$MOUNT" "$VOLUME" "$MOUNTED"
 	fi
-	IFS=$IFS_OLD
 	trap 2
 
 	test "$1" -eq 2 && verbose "Break detected"
 
-	if [ "$DO_LVRESIZE" -eq 2 ]; then
-		# start LVRESIZE with the filesystem modification flag
-		# and allow recursive call of fsadm
-		_FSADM_YES=$YES
-		export _FSADM_YES
-		unset FSADM_RUNNING
-		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
-		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
-	fi
-
 	# error exit status for break
 	exit ${1:-1}
 }
 
+#####################################
+# Convet the size into human readable
+# form. size in Bytes expected
+#####################################
+humanize_size() {
+	size="$1"
+	count=0
+	while [ ${size%%.*} -ge 1024 ] && [ $count -lt 7 ]; do
+		size=$(float_math $size/1024)
+		count=$(($count+1))
+	done
+	case $count in
+		0) unit="B" ;;
+		1) unit="KiB" ;;
+		2) unit="MiB" ;;
+		3) unit="GiB" ;;
+		4) unit="TiB" ;;
+		5) unit="PiB" ;;
+		6) unit="EiB" ;;
+		7) unit="ZiB" ;;
+		8) unit="YiB" ;;
+		*) unit="???" ;;
+	esac
+	echo "$size $unit"
+}
+
+#############################
+# Get size of entN filesystem
+# by reading tune2fs output
+#############################
+get_ext_size() {
+	local IFS=$NL
+	for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
+		case "$i" in
+			"Block size"*) bsize=${i##*  } ;;
+			"Block count"*) bcount=${i##*  } ;;
+			"Reserved block count"*) rbcount=${i##*  } ;;
+			"Free blocks"*) fbcount=${i##*  } ;;
+		esac
+	done
+
+	total=$(($bcount*$bsize))
+	TOTAL=$(humanize_size $total)
+	used=$((($bcount-$fbcount)*$bsize))
+	USED=$(humanize_size $used)
+	free=$((($fbcount-$rbcount)*$bsize))
+	FREE=$(humanize_size $free)
+}
+
+############################
+# Get size of xfs file system
+# by reading the df output or
+# examine file system with
+# xfs_db tool
+#############################
+get_xfs_size() {
+	local IFS=$NL
+	if [ -z "$MOUNTED" ]; then
+
+		for i in $(LANG=C xfs_db -c 'sb' -c 'print blocksize fdblocks dblocks logblocks agcount' $VOLUME); do
+			case "$i" in
+				"blocksize ="*) bsize=${i##* } ;;
+				"fdblocks ="*) fbcount=${i##* } ;;
+				"dblocks ="*) bcount=${i##* } ;;
+				"logblocks ="*) lbcount=${i##* } ;;
+				"agcount ="*) agcount=${i##* } ;;
+			esac
+		done
+		bcount=$(($bcount-$lbcount))
+		fbcount=$(($fbcount-(4+(4*$agcount))))
+
+		total=$(($bcount*$bsize))
+		TOTAL=$(humanize_size $total)
+		used=$((($bcount-$fbcount)*$bsize))
+		USED=$(humanize_size $used)
+		free=$(($fbcount*$bsize))
+		FREE=$(humanize_size $free)
+		return
+	fi
+	line=$("$DF" -k "$VOLUME" | "$GREP" -e "$MOUNTED$" | sed -e 's/  */ /g')
+	line=${line#* }
+	total=$(echo $line | cut -d' ' -f1)
+	TOTAL=$(humanize_size $total)
+	free=$(echo $line | cut -d' ' -f3)
+	FREE=$(humanize_size $free)
+	used=$(echo $line | cut -d' ' -f2)
+	USED=$(humanize_size $used)
+}
+
+detect_fs_size() {
+	if [ -z "$FSTYPE" ]; then
+		return
+	fi
+	case "$FSTYPE" in
+		ext[234]) get_ext_size ;;
+		xfs) get_xfs_size ;;
+		*) return 1 ;;
+	esac
+	return 0
+}
+
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
 # (2^(60/50/40/30/20/10/0))
 decode_size() {
 	case "$1" in
-	 *[eE]) NEWSIZE=$(( ${1%[eE]} * 1152921504606846976 )) ;;
-	 *[pP]) NEWSIZE=$(( ${1%[pP]} * 1125899906842624 )) ;;
-	 *[tT]) NEWSIZE=$(( ${1%[tT]} * 1099511627776 )) ;;
-	 *[gG]) NEWSIZE=$(( ${1%[gG]} * 1073741824 )) ;;
-	 *[mM]) NEWSIZE=$(( ${1%[mM]} * 1048576 )) ;;
-	 *[kK]) NEWSIZE=$(( ${1%[kK]} * 1024 )) ;;
+	 *[eE]) NEWSIZE=$(float_math "${1%[eE]} * 1152921504606846976") ;;
+	 *[pP]) NEWSIZE=$(float_math "${1%[pP]} * 1125899906842624") ;;
+	 *[tT]) NEWSIZE=$(float_math "${1%[tT]} * 1099511627776") ;;
+	 *[gG]) NEWSIZE=$(float_math "${1%[gG]} * 1073741824") ;;
+	 *[mM]) NEWSIZE=$(float_math "${1%[mM]} * 1048576") ;;
+	 *[kK]) NEWSIZE=$(float_math "${1%[kK]} * 1024") ;;
 	 *[bB]) NEWSIZE=${1%[bB]} ;;
 	     *) NEWSIZE=$(( $1 * $2 )) ;;
 	esac
-	#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
-	NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
 
-	if [ $DO_LVRESIZE -eq 1 ]; then
-		# start lvresize, but first cleanup mounted dirs
-		DO_LVRESIZE=2
-		cleanup 0
-	fi
+	NEWSIZE=${NEWSIZE%%.*}
+	NEWBLOCKCOUNT=$(float_math "$NEWSIZE / $2")
+	NEWBLOCKCOUNT=${NEWBLOCKCOUNT%%.*}
 }
 
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-	VOLUME_ORIG=$1
+	VOLUME_ORIG="$1"
 	VOLUME=${1/#"${DM_DEV_DIR}/"/}
-	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
+	VOLUME=$("$READLINK" "$READLINK_E" "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
           # hardcoded /dev  since udev does not create these entries elsewhere
@@ -189,10 +311,10 @@ detect_fs() {
 	esac
 	# use null device as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
-	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
+	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME") || return 1
 	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
 	FSTYPE=${FSTYPE%%\"*}
-	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
+	return 0
 }
 
 # check if the given device is already mounted and where
@@ -200,10 +322,10 @@ detect_fs() {
 detect_mounted()  {
 	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
 
-	MOUNTED=$("$GREP" ^"$VOLUME" "$PROCMOUNTS")
+	MOUNTED=$("$GREP" -e "^$VOLUME " "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$("$GREP" ^"$RVOLUME" "$PROCMOUNTS")
+	test -z "$MOUNTED" && MOUNTED=$("$GREP" -e "^$RVOLUME " "$PROCMOUNTS")
 
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
@@ -212,8 +334,8 @@ detect_mounted()  {
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
-		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" ^"$VOLUME")
-		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" ^"$RVOLUME")
+		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" -e "^$VOLUME ")
+		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" -e "^$RVOLUME ")
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
 	fi
@@ -295,17 +417,19 @@ resize_ext() {
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
 		detect_mounted && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
-		if test -n "$MOUNTED" ; then
-			# Forced fsck -f for umounted extX filesystem.
-			case "$-" in
-			  *i*) dry "$FSCK" $YES -f "$VOLUME" ;;
-			  *) dry "$FSCK" -f -p "$VOLUME" ;;
-			esac
-		fi
+	fi
+
+	# We should really do the fsck before every resize.
+	if [ -z "$MOUNTED" ] || [ "$REMOUNT" ]; then
+		# Forced fsck -f for umounted extX filesystem.
+		case "$-" in
+		  *i*) dry "$FSCK" "$YES" -f "$VOLUME" ;;
+		  *) dry "$FSCK" -f -p "$VOLUME" ;;
+		esac
 	fi
 
 	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
-	dry "$RESIZE_EXT" $FSFORCE "$VOLUME" $NEWBLOCKCOUNT
+	dry "$RESIZE_EXT" "$FSFORCE" "$VOLUME" "$NEWBLOCKCOUNT"
 }
 
 #############################
@@ -327,9 +451,9 @@ resize_reiser() {
 	decode_size $1 $BLOCKSIZE
 	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs: $NEWBLOCKCOUNT)"
 	if [ -n "$YES" ]; then
-		echo y | dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
+		echo y | dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"
 	else
-		dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
+		dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"
 	fi
 }
 
@@ -357,7 +481,7 @@ resize_xfs() {
 	decode_size $1 $BLOCKSIZE
 	if [ $NEWBLOCKCOUNT -gt $BLOCKCOUNT ]; then
 		verbose "Resizing Xfs mounted on \"$MOUNTPOINT\" to fill device \"$VOLUME\""
-		dry "$RESIZE_XFS" $MOUNTPOINT
+		dry "$RESIZE_XFS" "$MOUNTPOINT"
 	elif [ $NEWBLOCKCOUNT -eq $BLOCKCOUNT ]; then
 		verbose "Xfs filesystem already has the right size"
 	else
@@ -365,25 +489,736 @@ resize_xfs() {
 	fi
 }
 
+#####################################
+# Create extN filesystem with respect
+# to the striped volume
+#####################################
+make_ext() {
+	device="$1"
+	fstyp="$2"
+	bsize=4
+
+	if [ "$YES" ]; then
+		force="-F"
+	fi
+
+	dry "mkfs.$fstyp" "$force" -b "$(($bsize*1024))" $device
+}
+
+############################################
+# Create a file system just using mkfs.fstyp
+############################################
+generic_make_fs() {
+	device=$1
+	fstyp=$2
+	bsize=4096
+
+	if [ "$YES" ]; then
+		force="-f"
+	fi
+
+	dry "mkfs.$fstyp" $force "$device"
+}
+
 ####################
 # Resize filesystem
 ####################
-resize() {
+resize_fs() {
 	NEWSIZE=$2
-	detect_fs "$1"
+	detect_fs "$1" ||  error "Cannot get FSTYPE of \"$VOLUME\""
+	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
+	if [ "$NEWSIZE" ]; then
+		is_natural $NEWSIZE ||  error "$NEWSIZE is not valid number for file system size"
+	fi
 	detect_device_size
 	verbose "Device \"$VOLUME\" size is $DEVSIZE bytes"
 	# if the size parameter is missing use device size
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
-	IFS=$NL
+	local IFS=$NL
 	case "$FSTYPE" in
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
 	esac || error "Resize $FSTYPE failed"
-	cleanup 0
+}
+
+resize_lvolume() {
+	lvname=$1
+	newsize=$2
+	lvsize=$(LANG=C "$LVM" lvs -o lv_size --separator ' ' --noheadings --nosuffix --units b $lvname 2> /dev/null | sed -e 's/^ *//')
+	if [ $lvsize != $newsize ]; then
+		dry "$LVM" lvresize "$VERB" "$FORCE" -L"${newsize}"b "$lvname"
+	else
+		verbose "Logical volume already is of the size you're trying to resize it to"
+	fi
+}
+
+resize() {
+	local size=
+
+	# Special case for the situation we have been called from within the lvresize code.
+	if [ "$RESIZE_FS_ONLY" ]; then
+		resize_fs "$@"
+		return
+	fi
+
+	for i in "$@"; do
+		if [ -b "$i" ]; then
+			if [ -z "$devcount" ]; then
+				"$LVM" lvs "$i" &> /dev/null || error "$i is not valid logical volume"
+				lvname=$i
+				devcount=0
+				continue
+			fi
+			devices="$devices $i"
+			devcount=$(($devcount+1))
+			continue
+		fi
+		case $i in
+			"size="*)		[ -z "$size" ] && size=${i##*=};;
+			[[:digit:]]*)		[ -z "$size" ] && size=${i##*=};;
+			+[[:digit:]]*)		[ -z "$size" ] && size=${i##*=};;
+			-[[:digit:]]*)		[ -z "$size" ] && size=${i##*=};;
+			*) error "Wrong option $i. (see: $TOOL --help)";;
+		esac
+	done
+
+	if [ -z "$size" ]; then
+		error "Please provide the size argument. (see: $TOOL --help )"
+	fi
+
+	[ -z $lvname ] && error "Logical volume to resize was not specified"
+	[ $devcount -gt 0 ] && [ "$shrink" ] && warn "While shrinking the file system we "\
+						     "do not need additional devices. "\
+						     "Those provided will be ignored"
+
+	# We need to add provided devices into particular group
+	if [ $devcount -gt 0 ] && [ -z $shrink ]; then
+		# Get the volume group of the logical volume
+		vgname=$(detect_volume_group $lvname)
+		[ -z $vgname ] && error "Wrong argument $lvname. (see: $TOOL --help)"
+
+		# Determine whether the devices are in the group
+		detect_device_group $devices ||
+			error "Devices are in different groups. Please run "\
+				"\"$TOOL list\" to get more information on layout."
+
+		[ "$GROUP" ] && [ "$GROUP" != "$vgname" ] && error "Some devices are in different"\
+								   "group than the logical volume"\
+								   "($lvname). Please provide unused"\
+								   "devices"
+		# Add missing devices into the group
+		if [ "$NOT_IN_GROUP" ]; then
+			dry "$LVM" vgextend "$VERB" $vgname $NOT_IN_GROUP
+		fi
+	fi
+
+	resizefs=
+	detect_fs $lvname
+	[ "$FSTYPE" ] && resizefs="-r"
+
+	# Avoid callinf lvresize in recurse
+	if [ "$FSADM_RESIZE_RECURSE" ]; then
+		error "Recursive lvresize call detected! Exiting."
+	fi
+
+	# We are going to call lvresize with -r parameter which will not only
+	# resize the logical volume, but also the file system (if present)
+	# by calling fsadm recursively with --resize-fs-only argument.
+	# To be able to do this we should set some appropriate variables.
+	export _FSADM_YES=$YES
+	export FSADM_RESIZE_RECURSE=1
+	unset FSADM_RUNNING
+
+	dry exec "$LVM" lvresize $VERB $FORCE $resizefs -L${size} "$lvname"
+
+}
+
+#################################
+# Check the device list to detect
+# if there is not multiple groups
+#################################
+detect_device_group() {
+	ret=0
+	prev_vgname=""
+	vgs=""
+	tmp=$(mktemp)
+
+	LANG=C "$LVM" vgs -o vg_name,pv_name --separator ' ' --noheadings --nosuffix 2> /dev/null | sed -e 's/^ *//' | sort | uniq > $tmp
+	NOT_IN_GROUP=
+	IN_GROUP=
+	for i in "$@"; do
+		cur_vgname=$("$GREP" -e "$i$" "$tmp" | cut -d' ' -f1)
+
+		if [ -z "$cur_vgname" ]; then
+			NOT_IN_GROUP+="$i "
+			continue
+		else
+			IN_GROUP+="$i "
+		fi
+
+		if [ -z "$prev_vgname" ]; then
+			prev_vgname=$cur_vgname
+			vgs=$cur_vgname
+			continue;
+		fi
+
+		if [ "$cur_vgname" != "$prev_vgname" ]; then
+			ret=1
+			vgs+=" $cur_vgname"
+		fi
+	done
+	rm -f $tmp
+	GROUP=$vgs
+	return $ret
+}
+
+#############################
+# Create a new logical volume
+#############################
+create() {
+	devcount=0
+	vg_create=0
+
+	for i in "$@"; do
+		if [ -b $i ]; then
+			devices="$devices $i"
+			devcount=$(($devcount+1))
+			continue
+		fi
+		case $i in
+			"stripesize"*) stripesize=${i##*=} ;;
+			"name"*) name=${i##*=} ;;
+			"fstyp"* | "fs"*) fstyp=${i##*=} ;;
+			"size"*) size=${i##*=} ;;
+			"stripes"*) stripes=${i##*=} ;;
+			*) if [ -z $vgname ]; then vgname=$i; else
+				error "Wrong option $i. (see: $TOOL --help)"
+			   fi ;;
+		esac
+	done
+
+	detect_device_group $devices ||
+		error "Devices are in different groups. Please run "\
+			"\"$TOOL list\" to get more information on layout."
+
+	if [ "$GROUP" ] && [ "$vgname" ];then
+		if [ "$vgname" != "$GROUP" ]; then
+			error "You specified group ($vgname) and devices which does "\
+				"belong to a different group ($GROUP). Either remove "\
+				"devices first, or specify devices which are free."
+		fi
+	elif [ "$GROUP" ]; then
+		vgname=$GROUP
+	fi
+
+	# Devices are not in any group so we should find some.
+	# Either create a new one, or use the existing one, if
+	# there is only one vgroup, or use the one with enough
+	# free space in it
+	if [ -z "$vgname" ]; then
+		vgroups=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units b 2> /dev/null)
+		lines=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units b 2> /dev/null | wc -l)
+
+		if [ $lines -eq 1 ]; then
+			vgname=$(echo $vgroups | sed -e 's/^ *//' | cut -d' ' -f1)
+		elif [ $lines -gt 1 ]; then
+			if [ -z $size ]; then
+				error "Not enough information to create" \
+					"logical volume"
+			fi
+			decode_size $size 1
+			new_size=$NEWBLOCKCOUNT
+			IFS=$NL
+			for i in $vgroups; do
+				vgsize=$(echo $i | sed -e 's/^ *//' | cut -d' ' -f2)
+				vgsize=${vgsize%%B}
+				if [ $vgsize -ge $new_size ]; then
+					vgname=$(echo $i | sed -e 's/^ *//' | cut -d' ' -f1)
+					break;
+				fi
+			done
+		fi
+	fi
+	IFS=$IFS_OLD
+
+	if [ -z "$vgname" ]; then
+		[ $devcount -eq 0 ] && error "No suitable device specified."
+		for i in $(seq -w $MAX_VGS); do
+			"$LVM" vgs vg${i} &> /dev/null
+			if [ $? -ne 0 ]; then
+				vgname="vg${i}"
+				break;
+			fi
+		done
+		vg_create=1
+	fi
+
+	[ -z "$vgname" ] && error "No suitable name for volume group found."
+
+	if [ "$stripesize" ] || [ "$stripes" ]; then
+		if [ -z "$stripes" ] && [ $devcount -eq 0 ]; then
+			error "Stripe size specified ($stripesize), but " \
+			      "neither devices, nor number of stripes " \
+			      "has been provided"
+		fi
+		[ $devcount -gt 0 ] && [ -z "$stripes" ] && stripes=$devcount
+		if [ "$stripesize" ]; then
+			striped="-i $stripes -I $stripesize"
+		else
+			striped="-i $stripes"
+		fi
+	fi
+
+	if [ "$name" ]; then
+		lvname="--name $name"
+	else
+		tmp=$(mktemp)
+		"$LVM" lvs "$vgname" --separator ' ' --noheadings > $tmp
+		for i in $(seq -w $MAX_VGS); do
+			"$GREP" -e " lvol${i} " $tmp &> /dev/null
+			if [ $? -ne 0 ]; then
+				name="lvol${i}"
+				lvname="--name $name"
+				break;
+			fi
+		done
+		rm -f $tmp
+	fi
+
+	[ -z "$lvname" ] && error "No suitable name for the logical volume."
+
+	if [ $vg_create -eq 1 ]; then
+		dry "$LVM" vgcreate "$VERB" $vgname $devices
+	elif [ ! -z "$NOT_IN_GROUP" ]; then
+		dry "$LVM" vgextend "$VERB" $vgname $NOT_IN_GROUP
+	fi
+
+
+	if [ -z $size ] && [ -n "$devices" ]; then
+		size="-l 100%PVS"
+	elif [ -z $size ]; then
+		size="-l 100%FREE"
+	else
+		size="-L $size"
+	fi
+	dry "$LVM" lvcreate "$VERB" $lvname $size $striped "$vgname" $devices
+	device="/dev/${vgname}/${name}"
+
+	guess=0
+	if [ -z $fstyp ]; then
+		fstyp=$(echo $TOOL | sed 's/^.*\.//g')
+		guess=1
+	fi
+
+	case $fstyp in
+		ext[234]) make_ext $device $fstyp;;
+		xfs|reiserfs) generic_make_fs $device $fstyp;;
+		*)	if [ $guess -eq 1 ]; then
+				return 0
+			else
+				error "Filesystem $fstyp is not supported"
+			fi
+			;;
+	esac
+}
+
+###############################
+# Remove device form the group
+###############################
+remove_device() {
+	vgname=$("$LVM" pvs "$1" -o vg_name --separator ' ' --noheadings) 2> /dev/null || return 1
+	vgname=$(echo $vgname | sed 's/[ \t]*//')
+	if [ "$vgname" ]; then
+		dry_nofail "$LVM" vgreduce "$vgname" "$device"
+	else
+		warn "Device $1 is not in any pool."
+	fi
+	return 0
+}
+
+#############################
+# Remove the logical volume
+# volume group, or the device
+# from the group
+#############################
+do_remove() {
+	item="${1%% }"
+	device=
+	MOUNTED=
+
+	# Block device has been given
+	if [ -b "$item" ]; then
+		device=$item
+	fi
+
+	# Mount point has been given
+	if [ -z "$device" ] && [ -d "$item" ]; then
+		mp=$(echo "$item" | sed -e 's/\/$//')
+
+		count=$("$GREP" " $mp " "$PROCMOUNTS" | wc -l)
+
+		if [ $count -eq 1 ]; then
+			device=$("$GREP" " $mp " "$PROCMOUNTS" | cut -d' ' -f1)
+		else
+			count=$(LANG=C "$MOUNT" | "$GREP" " $mp " | wc -l)
+			[ $count -ne 1 ] && warn "Could not find device mounted at $mp" && return
+			device=$(LANG=C "$MOUNT" | "$GREP" " $mp " | cut -d' ' -f1)
+		fi
+		VOLUME=$device
+	fi
+
+	if [ -z "$device" ]; then
+		"$LVM" vgs "$item" &> /dev/null
+		# Volume group has been given
+		if [ $? -eq 0 ]; then
+			dry "$LVM" vgremove "$FORCE" "$item"
+			return
+		fi
+	fi
+
+	[ -z "$device" ] && warn "$item is not a valid mount point, dm device nor volume group name."&& return
+
+	# Try to remove device from the group
+	remove_device "$device" && return 0
+
+	detect_mounted && try_umount
+	dry "$LVM" lvremove "$FORCE" "$device"
+	return
+}
+
+###############################
+# Iterate through the arguments
+# and do_remove on them
+###############################
+remove() {
+	if [ $# -eq 0 ]; then
+		error "Please specify what do you want to remove"\
+		      "(see $TOOL remove --help)."
+	fi
+	# help
+	if [ "$1" == "help" ]; then
+		echo "Usage: $TOOL remove [mount point | dm device | voulume group | device | --all]"
+		exit 0
+	elif [ "$1" == "--all" ]; then
+		list="$(LANG=C $LVM vgs -o vg_name --separator ' ' --noheadings --nosuffix --units b 2> /dev/null)"
+	else
+		list="$@"
+	fi
+
+	for item in $list; do
+		do_remove "$item"
+	done
+}
+
+#############################
+# List all file systems built
+# on top of DM device
+#############################
+list_filesystems() {
+	local IFS=$NL
+	local c=0
+	for line in $(LANG=C "$LVM" lvs -o lv_path,lv_size,segtype --noheadings --separator ' ' --nosuffix --units b 2> /dev/null); do
+		line=$(echo $line | sed -e 's/^ *\//\//')
+		volume=$(echo $line | cut -d' ' -f1)
+		[ "$volume" == "$last_volume" ] && continue
+		c=$((c+1))
+		local volumes[$c]=$volume
+		local segtype[$c]=$(echo $line | cut -d' ' -f3)
+		local lvsize[$c]=$(humanize_size $(echo $line | cut -d' ' -f2))
+		detect_fs "$volume"
+		detect_mounted
+		detect_fs_size
+		local total[$c]=$TOTAL
+		local fstype[$c]=$FSTYPE
+		local free[$c]=$FREE
+		local used[$c]=$USED
+		local mounted[$c]=$MOUNTED
+		FSTYPE=
+		FREE=
+		USED=
+		TOTAL=
+		MOUNTED=
+		last_volume=$volume
+	done
+
+	if [ $c -eq 0 ]; then
+		warn " No file systems suitable for managing by $TOOL found."
+		return
+	fi
+
+	len_volume=6
+	len_fstype=2
+	len_free=4
+	len_used=4
+	len_total=5
+	len_mounted=11
+	len_segtype=4
+	len_lvsize=4
+	for i in $(seq $c); do
+		local _volume=${volumes[$i]}
+		local _fstype=${fstype[$i]}
+		local _total=${total[$i]}
+		local _free=${free[$i]}
+		local _used=${used[$i]}
+		local _segtype=${segtype[$i]}
+		local _lvsize=${lvsize[$i]}
+		local _mounted=${mounted[$i]}
+		[ ${#_volume} -gt "0$len_volume" ] && len_volume=${#_volume}
+		[ ${#_fstype} -gt "0$len_fstype" ] && len_fstype=${#_fstype}
+		[ ${#_total} -gt "0$len_total" ] && len_total=${#_total}
+		[ ${#_free} -gt "0$len_free" ] && len_free=${#_free}
+		[ ${#_used} -gt "0$len_used" ] && len_used=${#_used}
+		[ ${#_segtype} -gt "0$len_segtype" ] && len_segtype=${#_segtype}
+		[ ${#_lvsize} -gt "0$len_lvsize" ] && len_lvsize=${#_lvsize}
+		[ ${#_mounted} -gt "0$len_mounted" ] && len_mounted=${#_mounted}
+	done
+
+	format="%-$(($len_volume+2))s %$(($len_lvsize))s  %-$(($len_fstype+2))s%$(($len_free))s  %$(($len_used))s  %$(($len_total))s  %-$(($len_segtype+2))s%-$(($len_mounted))s\n"
+	header=$(printf "$format" "Volume" "LV size" "FS" "Free" "Used" "Total" "Type" "Mount point")
+	separator=""
+	for i in $(seq ${#header}); do
+		separator+="-"
+	done
+	echo $separator
+	printf "$format" "Volume" "LV size" "FS" "Free" "Used" "Total" "Type" "Mount point"
+	echo $separator
+
+	for i in $(seq $c); do
+		printf "$format" "${volumes[$i]}" "${lvsize[$i]}" "${fstype[$i]}" "${free[$i]}" "${used[$i]}" "${total[$i]}" "${segtype[$i]}" "${mounted[$i]}"
+	done
+
+	echo $separator
+}
+
+###########################
+# List all non DM devices
+###########################
+list_devices() {
+	local IFS=$NL
+	tmp=$(mktemp)
+
+	c=0
+	dmnumber=$(cat "$PROCDEVICES" | "$GREP" device-mapper | sed -e 's/^  *//')
+	dmnumber=${dmnumber%% *}
+	LANG=C "$LVM" pvs -o pv_name,vg_name,pv_size,pv_free,pv_used --separator ' ' --noheadings --nosuffix --units b > $tmp
+	for line in $(cat "$PROCPARTITIONS" | tail -n +3 | sed -e 's/^  *//' | "$GREP" -v -e "^$dmnumber"); do
+		c=$((c+1))
+		line=$(echo $line | sed -e 's/  */ /g')
+		_total=$(($(echo $line | cut -d' ' -f3)*1024))
+		local total[$c]=$(humanize_size ${_total%%.*})
+		VOLUME=$(echo $line | cut -d' ' -f4)
+		RVOLUME="/dev/$(echo $line | cut -d' ' -f4)"
+		line=$("$GREP" -e " $RVOLUME " $tmp)
+		detect_mounted
+		if [ -z $MOUNTED ]; then
+			count=$("$GREP" "$VOLUME" "$PROCPARTITIONS" | wc -l)
+			[ $count -gt 1 ] && MOUNTED="PARTITIONED"
+		fi
+
+		if [ ! -z $line ]; then
+			line=$(echo $line | sed -e 's/^ *\//\//')
+			local group[$c]=$(echo $line | cut -d' ' -f2)
+			_total=$(echo $line | cut -d' ' -f3)
+			local total[$c]=$(humanize_size ${_total%%.*})
+			_free=$(echo $line | cut -d' ' -f4)
+			local free[$c]=$(humanize_size ${_free%%.*})
+			_used=$(echo $line | cut -d' ' -f5)
+			local used[$c]=$(humanize_size ${_used%%.*})
+		fi
+		local volumes[$c]=$RVOLUME
+		local mounted[$c]=$MOUNTED
+		free=
+		used=
+		total=
+		MOUNTED=
+	done
+	rm -f $tmp
+
+	if [ $c -eq 0 ]; then
+		warn " No devices found."
+		return
+	fi
+
+	len_volume=6
+	len_free=4
+	len_used=4
+	len_total=5
+	len_group=5
+	len_mounted=11
+	for i in $(seq $c); do
+		local _volume=${volumes[$i]}
+		local _free=${free[$i]}
+		local _used=${used[$i]}
+		local _total=${total[$i]}
+		local _group=${group[$i]}
+		local _mounted=${mounted[$i]}
+		[ ${#_volume} -gt "0$len_volume" ] && len_volume=${#_volume}
+		[ ${#_free} -gt "0$len_free" ] && len_free=${#_free}
+		[ ${#_used} -gt "0$len_used" ] && len_used=${#_used}
+		[ ${#_total} -gt "0$len_total" ] && len_total=${#_total}
+		[ ${#_group} -gt "0$len_group" ] && len_group=${#_group}
+		[ ${#_mounted} -gt "0$len_mounted" ] && len_mounted=${#_mounted}
+	done
+
+	format="%-$(($len_volume+2))s%$(($len_free))s  %$(($len_used))s  %$(($len_total))s  %-$(($len_group+2))s%-$(($len_mounted))s\n"
+	header=$(printf "$format" "Device" "Free" "Used" "Total" "Group" "Mount point")
+	separator=""
+	for i in $(seq ${#header}); do
+		separator+="-"
+	done
+	echo $separator
+	printf "$format" "Device" "Free" "Used" "Total" "Group" "Mount point"
+	echo $separator
+
+	for i in $(seq $c); do
+		printf "$format" "${volumes[$i]}" "${free[$i]}" "${used[$i]}" "${total[$i]}" "${group[$i]}" "${mounted[$i]}"
+	done
+
+	echo $separator
+}
+
+################################
+# List all pools (volume groups)
+################################
+list_pool() {
+	local IFS=$NL
+	c=0
+	for line in $(LANG=C "$LVM" vgs -o vg_name,pv_count,vg_size,vg_free --separator ' ' --noheadings --nosuffix --units b 2> /dev/null); do
+		c=$((c+1))
+		line=$(echo $line | sed -e 's/^ *//')
+		local group[$c]=$(echo $line | cut -d' ' -f1)
+		local devices[$c]=$(echo $line | cut -d' ' -f2)
+		_total=$(echo $line | cut -d' ' -f3)
+		_free=$(echo $line | cut -d' ' -f4)
+		_used=$((${_total%%.*}-${_free%%.*}))
+		local used[$c]=$(humanize_size ${_used%%.*})
+		local total[$c]=$(humanize_size ${_total%%.*})
+		local free[$c]=$(humanize_size ${_free%%.*})
+	done
+
+	if [ $c -eq 0 ]; then
+		warn " No pools found on the system."
+		return
+	fi
+
+	len_group=5
+	len_devices=6
+	len_free=4
+	len_used=4
+	len_total=5
+	for i in $(seq $c); do
+		local _group=${group[$i]}
+		local _devices=${devices[$i]}
+		local _free=${free[$i]}
+		local _used=${used[$i]}
+		local _total=${total[$i]}
+		[ ${#_group} -gt "0$len_group" ] && len_group=${#_group}
+		[ ${#_devices} -gt "0$len_devices" ] && len_devices=${#_devices}
+		[ ${#_free} -gt "0$len_free" ] && len_free=${#_free}
+		[ ${#_used} -gt "0$len_used" ] && len_used=${#_used}
+		[ ${#_total} -gt "0$len_total" ] && len_total=${#_total}
+	done
+
+	format="%-$(($len_group+2))s%-$(($len_devices+2))s%$(($len_free))s  %$(($len_used))s  %$(($len_total))s\n"
+	header=$(printf "$format" "Group" "Devices" "Free" "Used" "Total")
+	separator=""
+	for i in $(seq ${#header}); do
+		separator+="-"
+	done
+	echo $separator
+	printf "$format" "Group" "Devices" "Free" "Used" "Total"
+	echo $separator
+
+	for i in $(seq $c); do
+		printf "$format" "${group[$i]}" "${devices[$i]}" "${free[$i]}" "${used[$i]}" "${total[$i]}"
+	done
+	echo $separator
+}
+
+#############################
+# List the available storage
+# and file systems
+#############################
+list() {
+	for i in "$@"; do
+		case "$i" in
+			"filesystems" | "fs") list_filesystems ;;
+			"devices" | "dev") list_devices ;;
+			"pool") list_pool ;;
+			*) error "Wrong option $i. (see: $TOOL --help)"
+		esac
+	done
+
+	if [ $# -eq 0 ]; then
+		list_devices
+		echo ""
+		list_pool
+		echo ""
+		list_filesystems
+	fi
+}
+
+detect_volume_group() {
+	_vg=$("$LVM" lvs -o vg_name --separator ' ' --noheadings $1 2> /dev/null)
+	ret=$?
+	echo "$_vg" | sed -e 's/^ *//'
+	return $ret
+}
+
+############################
+# Add devices into the group
+############################
+add() {
+	vg_create=0
+	devcount=0
+	tmp=$(mktemp)
+
+	for i in "$@"; do
+		if [ -b "$i" ]; then
+			devices="$devices $i"
+			devcount=$(($devcount+1))
+			continue
+		elif [ -z "$vgname" ]; then vgname=$i; else
+			error "Wrong argument $i. (see: $TOOL --help)"
+		fi
+	done
+
+	[ $devcount -eq 0 ] && error "No suitable device specified."
+	"$LVM" vgs -o vg_name --separator ' ' --noheadings | sed -e 's/^ *//' > $tmp
+
+	if [ -z "$vgname" ]; then
+		lines=$(wc -l $tmp)
+		lines=${lines%% *}
+
+		if [ $lines -eq 1 ]; then
+			vgname=$(cut -d' ' -f1 $tmp)
+		elif [ $lines -gt 1 ]; then
+			list_pool
+			rm -f $tmp
+			error "Please, specify group you want to add the device into"
+		elif [ $lines -eq 0 ]; then
+			vgname="vg001"
+			vg_create=1
+		fi
+	else
+		"$GREP" -e "$vgname" $tmp &> /dev/null
+		vg_create=$?
+	fi
+	rm -f $tmp
+
+	[ -z "$vgname" ] && error "No suitable name for volume group found."
+	detect_device_group $devices
+
+	if [ $vg_create -eq 1 ]; then
+		dry "$LVM" vgcreate "$VERB" "$vgname" $devices
+	elif [ ! -z "$NOT_IN_GROUP" ]; then
+		dry "$LVM" vgextend "$VERB" "$vgname" $NOT_IN_GROUP
+	else
+		warn "Nothing to do"
+	fi
 }
 
 ####################################
@@ -399,7 +1234,8 @@ diff_dates() {
 # Check filesystem
 ###################
 check() {
-	detect_fs "$1"
+	detect_fs "$1" || error "Cannot get FSTYPE of \"$VOLUME\""
+	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 	if detect_mounted ; then
 		verbose "Skipping filesystem check for device \"$VOLUME\" as the filesystem is mounted on $MOUNTED";
 		cleanup 3
@@ -407,8 +1243,7 @@ check() {
 
 	case "$FSTYPE" in
 	  "ext2"|"ext3"|"ext4")
-		IFS_CHECK=$IFS
-		IFS=$NL
+		local IFS=$NL
 		for i in $(LANG=C "$TUNE_EXT" -l "$VOLUME"); do
 			case "$i" in
 			  "Last mount"*) LASTMOUNT=${i##*: } ;;
@@ -425,15 +1260,14 @@ check() {
 			fi
 			;;
 		esac
-		IFS=$IFS_CHECK
 	esac
 
 	case "$FSTYPE" in
 	  "xfs") dry "$XFS_CHECK" "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
-		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
-		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
+		  *i*) dry "$FSCK" "$YES" "$FORCE" "$VOLUME" ;;
+		  *) dry "$FSCK" "$FORCE" -p "$VOLUME" ;;
 		esac
 	esac
 }
@@ -475,20 +1309,24 @@ do
 	  "-n"|"--dry-run") DRY=1 ;;
 	  "-f"|"--force") FORCE="-f" ;;
 	  "-e"|"--ext-offline") EXTOFF=1 ;;
+	  "-o"|"--resize-fs-only") RESIZE_FS_ONLY=1 ;;
 	  "-y"|"--yes") YES="-y" ;;
-	  "-l"|"--lvresize") DO_LVRESIZE=1 ;;
-	  "check") CHECK="$2" ; shift ;;
-	  "resize") RESIZE="$2"; NEWSIZE="$3" ; shift 2 ;;
+	  "-l"|"--lvresize") ;;
+	  "check") COMMAND=$1; shift; ARGS="$@"; break ;;
+	  "resize") COMMAND=$1; shift; ARGS="$@"; break ;;
+	  "create") COMMAND=$1; shift; ARGS="$@"; break ;;
+	  "list") COMMAND=$1; shift; ARGS="$@"; break ;;
+	  "add") COMMAND=$1; shift; ARGS="$@"; break ;;
+	  "remove") COMMAND=$1; shift; ARGS="$@"; break ;;
 	  *) error "Wrong argument \"$1\". (see: $TOOL --help)"
 	esac
 	shift
 done
 
-if [ -n "$CHECK" ]; then
-	check "$CHECK"
-elif [ -n "$RESIZE" ]; then
-	export FSADM_RUNNING="fsadm"
-	resize "$RESIZE" "$NEWSIZE"
-else
+if [ -z "$COMMAND" ]; then
 	error "Missing command. (see: $TOOL --help)"
 fi
+
+export FSADM_RUNNING="fsadm"
+$COMMAND $ARGS
+cleanup 0
-- 
1.7.4.4


