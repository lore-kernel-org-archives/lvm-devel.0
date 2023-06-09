From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:01:55 +0000 (GMT)
Subject: main - vdo: enhance lvm_vdo_import
Message-ID: <20230609160155.C06193858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=be6c34212b05d8c59c0ba68e26c56cddf61c9f04
Commit:        be6c34212b05d8c59c0ba68e26c56cddf61c9f04
Parent:        00633f8b668d94a58756d96f5927fd690b8f41d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 11 20:07:37 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

vdo: enhance lvm_vdo_import

Add support for usage of 'dm-snapshot' for doing whole device conversion
in a snapshot which could be merged once the whole conversion has been
made.
This helps with cases where there would be any unexpected failure in the
middle of conversion process and user can continue using original
device until problem in conversion is fixed.

Import tool now uses 'truncate' tool to create a small backend file (20M) for loop device
to hold COW exception store.

Option  --vdo-config has been added to allow specifing location of vdo
configuration file.

Option --no-snapshot allows to use import tool without creation of
snapshot, however recovery after finished VDO conversion and unfinished
lvm2 conversion is then very difficult.

Option --uuid-prefix allow to specify DM UUID prefix for snapshot
device.

Use read with -r.
---
 scripts/lvm_import_vdo.sh | 375 ++++++++++++++++++++++++++++++++++------------
 1 file changed, 282 insertions(+), 93 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 134c96513..bae4b52d1 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2021-2023 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -19,7 +19,7 @@
 # Needed utilities:
 #  lvm, dmsetup,
 #  vdo,
-#  grep, awk, sed, blockdev, readlink, stat, mkdir
+#  grep, awk, sed, blockdev, readlink, stat, mkdir, truncate
 #
 # Conversion is using  'vdo convert' support from VDO manager to move
 # existing VDO header by 2M which makes space to place in PV header
@@ -29,6 +29,9 @@
 set -euE -o pipefail
 
 TOOL=lvm_import_vdo
+IMPORT_NAME="VDO_${TOOL}_${RANDOM}$$"
+test ${#IMPORT_NAME} -lt 100 || error "Random name \"$IMPORT_NAME\" is too long!"
+TEMPDIR="${TMPDIR:-/tmp}/$IMPORT_NAME"
 
 _SAVEPATH=$PATH
 PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
@@ -36,26 +39,40 @@ PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
 VDO=${VDO_BINARY:-vdo}
-VDOCONF=${VDOCONF:-}
 BLOCKDEV="blockdev"
+LOSETUP="losetup"
 READLINK="readlink"
 READLINK_E="-e"
 STAT="stat"
 MKDIR="mkdir"
+TRUNCATE="truncate"
 DMSETUP="dmsetup"
 
-TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$"
 DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
-
-DEVICENAME=""
+DM_UUID_PREFIX="${DM_UUID_PREFIX:-}"
+DM_VG_NAME=
+DM_LV_NAME=
+VDO_CONFIG=${VDO_CONFIG:-}   # can be overriden with --vdo-config
+VDOCONF=
+test -n "$VDO_CONFIG" && VDOCONF="-f $VDO_CONFIG"
+
+DEVICE=
+VGNAME=
+LVNAME=
 DEVMAJOR=0
 DEVMINOR=0
 PROMPTING=""
+USE_VDO_DM_SNAPSHOT=1
+VDO_DM_SNAPSHOT_NAME=
+VDO_DM_SNAPSHOT_DEVICE=
+VDO_SNAPSHOT_LOOP=
 
 DRY=0
 VERB=""
 FORCE=""
 YES=""
+ABORT_AFTER_VDO_CONVERT=0
+VDO_ALLOCATION_PARAMS=
 
 # default name for converted VG and its VDO LV
 DEFAULT_NAME="vdovg/vdolvol"
@@ -74,6 +91,9 @@ tool_usage() {
 	echo "	  -v | --verbose      Be verbose"
 	echo "	  -y | --yes	      Answer \"yes\" at any prompts"
 	echo "	       --dry-run      Print verbosely commands without running them"
+	echo "	       --no-snapshot  Do not use snapshot for converted VDO device"
+	echo "	       --uuid-prefix  Prefix for DM snapshot uuid"
+	echo "	       --vdo-config   Configuration file for VDO manager"
 
 	exit
 }
@@ -102,12 +122,79 @@ dry() {
 cleanup() {
 	trap '' 2
 
+	test -n "$VDO_DM_SNAPSHOT_NAME" && { "$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || true ; }
+	test -n "$VDO_SNAPSHOT_LOOP" && { "$LOSETUP" -d "$VDO_SNAPSHOT_LOOP" || true ; }
+
 	test -z "$PROMPTING" || echo "No"
-	rm -rf "$TEMPDIR"
+	rm -rf "$TEMPDIR" || true
 	# error exit status for break
 	exit "${1:-1}"
 }
 
+# Create snapshot target like for persistent snapshot with 16KiB chunksize
+snapshot_target_line_() {
+	echo "0 $("$BLOCKDEV" --getsize "$1") snapshot${3:-} $1 $2 P 32"
+}
+
+snapshot_create_() {
+	VDO_DM_SNAPSHOT_NAME="${IMPORT_NAME}_snap"
+	local file="$TEMPDIR/$VDO_DM_SNAPSHOT_NAME"
+
+	# TODO: maybe use ramdisk via 'brd' device ?)
+	"$TRUNCATE" -s 20M "$file"
+	VDO_SNAPSHOT_LOOP=$("$LOSETUP" -f --show "$file")
+	"$DMSETUP" create "$VDO_DM_SNAPSHOT_NAME" -u "${DM_UUID_PREFIX}-${VDO_DM_SNAPSHOT_NAME}-priv" --table "$(snapshot_target_line_ "$1" "$VDO_SNAPSHOT_LOOP")"
+	VDO_DM_SNAPSHOT_DEVICE="$DM_DEV_DIR/mapper/$VDO_DM_SNAPSHOT_NAME"
+	verbose "Snapshot of VDO device $1 created: $VDO_DM_SNAPSHOT_DEVICE."
+}
+
+snapshot_merge_() {
+	local status
+	local inital_status
+
+	initial_status=( $("$DMSETUP" status "$VDO_DM_SNAPSHOT_NAME") )
+	"$DMSETUP" reload "$VDO_DM_SNAPSHOT_NAME" --table "$(snapshot_target_line_ "$1" "$VDO_SNAPSHOT_LOOP" -merge)"
+	"$DMSETUP" suspend "$VDO_DM_SNAPSHOT_NAME" || {
+		error "ABORTING: Failed to initialize snapshot merge! Origin volume is unchanged."
+	}
+
+	verbose "Merging converted VDO volume..."
+	# Running merging
+	"$DMSETUP" resume "$VDO_DM_SNAPSHOT_NAME"
+
+	#du -h "$TEMPDIR/$VDO_DM_SNAPSHOT_NAME"
+
+	# Loop for a while, till the snapshot is merged.
+	# Should be nearly instantenious.
+        # FIXME: Recovery when something prevents merging is hard
+	for i in $(seq 1 20) ; do
+		status=( $("$DMSETUP" status "$VDO_DM_SNAPSHOT_NAME") )
+		# Check if merging is finished
+		test "${status[3]%/*}" = "${status[4]}" && break
+		# Wait a bit and retry
+		sleep .2
+	done
+	test "${status[3]%/*}" = "${status[4]}" || {
+		# FIXME: Now what shall we do ??? Help....
+		# Keep snapshot in table for possible analysis...
+		VDO_DM_SNAPSHOT_NAME=
+		VDO_SNAPSHOT_LOOP=
+		echo "Initial snapshot status ${initial_status[*]}"
+		echo "Failing merge snapshot status ${status[*]}"
+		error "ABORTING: Snapshot failed to merge! (Administrator required...)"
+	}
+	sync
+	"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || {
+		sleep 1 # sleep and retry once more
+		"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || {
+			error "ABORTING: Cannot remove snapshot $VDO_DM_SNAPSHOT_NAME! (check volume autoactivation...)"
+		}
+	}
+	VDO_DM_SNAPSHOT_NAME=
+	"$LOSETUP" -d "$VDO_SNAPSHOT_LOOP"
+	VDO_SNAPSHOT_LOOP=
+}
+
 get_enabled_value_() {
 	case "$1" in
 	enabled) echo "1" ;;
@@ -221,46 +308,191 @@ parse_yaml_() {
 	) < "$yaml_file"
 }
 
-# convert existing VDO volume into lvm2 volume
+#
+# Convert VDO volume on LV to VDOPool within this VG
+#
+# This conversion requires the size of VDO virtual volume has to be expressed in the VG's extent size.
+# Currently this enforces a user to reduce the VG extent size to the smaller size (up to 4KiB).
+#
+# TODO: We may eventually relax this condition just like we are doing rounding for convert_non_lv_()
+#       Let's if there would be any singly user requiring this feauture.
+#       It may allow to better use larger VDO volume size (in TiB ranges).
+#
+convert_lv_() {
+	local vdo_logicalSize=$1
+	local extent_size
+	local pvfree
+
+	pvfree=$("$LVM" lvs -o size --units b --nosuffix --noheadings "$DM_VG_NAME/$DM_LV_NAME")
+	pvfree=$(( pvfree / 1024 ))		# to KiB
+	# select largest possible extent size that can exactly express both sizes
+	extent_size=$(get_largest_extent_size_ "$pvfree" "$vdo_logicalSize")
+
+	# validate existing  VG extent_size can express virtual VDO size
+	vg_extent_size=$("$LVM" vgs -o vg_extent_size --units b --nosuffix --noheadings "$VGNAME")
+	vg_extent_size=$(( vg_extent_size / 1024 ))
+
+	test "$vg_extent_size" -le "$extent_size" || {
+		error "Please vgchange extent_size to@most $extent_size KiB or extend and align virtual size of VDO device on $vg_extent_size KiB before retrying conversion."
+	}
+	verbose "Renaming existing LV to be used as _vdata volume for VDO pool LV."
+	dry "$LVM" lvrename $YES $VERB "$VGNAME/$DM_LV_NAME" "$VGNAME/${LVNAME}_vpool" || {
+		error "Rename of LV \"$VGNAME/$DM_LV_NAME\" failed, while VDO header has been already moved!"
+	}
+
+	verbose "Converting to VDO pool."
+	dry "$LVM" lvconvert $YES $VERB $FORCE --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSize}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
+
+	verbose "Removing now unused VDO entry from VDO configuration."
+	dry "$VDO" remove $VDOCONF $VERB --force --name "$VDONAME"
+}
+
+#
+# Convert VDO volume on a device to VG with VDOPool LV
+#
+# Convert device with the use of snapshot on top of original VDO volume (can be optionally disabled)
+# Once the whole conversion is finished, snapshot is merged (During the short periof time of merging
+# user must ensure there will be no power-off!)
+#
+# For best use the latest version of  vdoprepareforlvm tool is required.
+convert_non_lv_() {
+	local vdo_logicalSize=$1
+	local extent_size
+	local output
+	local pvfree
+
+	if [ "$USE_VDO_DM_SNAPSHOT" = "1" ]; then
+		dry snapshot_create_ "$DEVICE"
+		sed "s:$DEVICE:$VDO_DM_SNAPSHOT_DEVICE:" "$TEMPDIR/vdoconf.yml" > "$TEMPDIR/vdo_snap.yml"
+		# Let VDO manager operate on snapshot volume
+		VDOCONF="-f $TEMPDIR/vdo_snap.yml"
+	fi
+
+	verbose "Moving VDO header."
+	output=$(dry "$VDO" convert $VDOCONF --force --name "$VDONAME")
+
+	if [ "$ABORT_AFTER_VDO_CONVERT" != "0" ] ; then
+		verbose "Aborting VDO coversion after moving VDO, volume is useless!"
+		cleanup 0
+	fi
+
+	# Parse result from VDO preparation/conversion tool
+	# New version of the tool provides output with alingment and offset
+	local vdo_length=0
+	local vdo_aligned=0
+	local vdo_offset=0
+	local vdo_non_converted=0
+	while IFS=  read -r line ; do
+		case "$line" in
+		"Non converted"*) vdo_non_converted=1 ;;
+		"Length"*) vdo_length=${line##* = } ;;
+		"Conversion completed"*)
+			   vdo_aligned=${line##*aligned on }
+			   vdo_aligned=${vdo_aligned%%[!0-9]*}
+			   vdo_offset=${line##*offset }
+			   # backward compatibility with report from older version
+			   vdo_offset=${vdo_offset##*by }
+			   vdo_offset=${vdo_offset%%[!0-9]*}
+			   ;;
+		esac
+	done <<< "$output"
+
+	# In case we operation with snapshot, all lvm2 operation will also run on top of snapshot
+	local devices=${VDO_DM_SNAPSHOT_DEVICE:-$DEVICE}
+
+	dry "$LVM" pvcreate $YES --devices "$devices" --dataalignment "$vdo_offset"b "$devices" || {
+		error "Creation of PV on \"$DEVICE\" failed, while VDO header has been already moved!"
+	}
+
+	# Obtain free space in this new PV
+	# after 'vdo convert' call there is ~(1-2)M free space@the front of the device
+	pvfree=$("$BLOCKDEV" --getsize64 "$DEVICE")
+	pvfree=$(( ( pvfree - vdo_offset ) / 1024 ))	# to KiB
+	if [ -n "$vdo_aligned" ] && [ "$vdo_aligned" != "0" ]; then
+		extent_size=$(( vdo_aligned / 1024 ))
+	else
+		extent_size=$(get_largest_extent_size_ "$pvfree" "$vdo_logicalSize")
+	fi
+
+	# Round virtual size to the LOWER size expressed in extent units.
+	# lvm is parsing VDO metadata and can read real full size and use it instead of this smaller value.
+	# To precisely byte-synchronize the size of VDO LV, user can lvresize such VDO LV later.
+	vdo_logicalSize=$(( ( vdo_logicalSize / extent_size ) * extent_size ))
+
+	verbose "Creating VG \"${NAME%/*}\" with extent size $extent_size KiB."
+	dry "$LVM" vgcreate $YES $VERB --devices "$devices" -s "${extent_size}k" "$VGNAME" "$devices" || {
+		error "Creation of VG \"$VGNAME\" failed, while VDO header has been already moved!"
+	}
+
+	verbose "Creating VDO pool data LV from all extents in volume group $VGNAME."
+	dry "$LVM" lvcreate -Zn -Wn -an $YES $VERB --devices "$devices" -l100%VG -n "${LVNAME}_vpool" "$VGNAME" "$devices"
+
+	verbose "Converting to VDO pool."
+	dry "$LVM" lvconvert $YES $VERB $FORCE --devices "$devices" --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSize}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
+
+	dry "$LVM" vgchange -an $VERB $FORCE --devices "$devices" "$VGNAME"
+
+	if [ "$USE_VDO_DM_SNAPSHOT" = "1" ]; then
+		if [ -z "$YES" ]; then
+			PROMPTING=yes
+			echo "Warning: Do not interrupt merging process once it starts (VDO data may become irrecoverable)!"
+			echo -n "Do you want to merge converted VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
+			read -r -n 1 -s ANSWER
+			case "${ANSWER:0:1}" in
+			  y|Y )  echo "Yes" ;;
+			    * )  echo "No" ; PROMPTING=""; cleanup 1 ;;
+			esac
+			PROMPTING=""
+			YES="-y" # From now, now prompting
+		fi
+
+		dry snapshot_merge_ "$DEVICE"
+		if [ -e "$TEMPDIR/vdo_snap.yml" ]; then
+			dry cp "$TEMPDIR/vdo_snap.yml" "$VDO_CONFIG"
+		else
+			dry rm -f "$VDO_CONFIG"
+		fi
+		verbose "Merging of VDO device finished."
+	fi
+
+	dry "$LVM" lvchange -ay $VERB $FORCE "$VGNAME/$LVNAME"
+}
+
+# Convert existing VDO volume into lvm2 volume
 convert2lvm_() {
-	local DEVICE=$1
-	local VGNAME=${NAME%/*}
-	local LVNAME=${NAME#*/}
 	local VDONAME
 	local TRVDONAME
-	local EXTENTSZ
-	local IS_LV=1
 	local FOUND=""
 	local MAJOR=0
 	local MINOR=0
-	local DM_VG_NAME
-	local DM_LV_NAME
 
+	VGNAME=${NAME%/*}
+	LVNAME=${NAME#*/}
 	DM_UUID=""
 	detect_lv_ "$DEVICE"
 	case "$DM_UUID" in
 		LVM-*)	eval "$("$DMSETUP" splitname --nameprefixes --noheadings --separator ' ' "$DM_NAME")"
 			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
 				VGNAME=$DM_VG_NAME
-				verbose "Using existing volume group name $VGNAME."
+				verbose "Using existing volume group name \"$VGNAME\"."
 				test -n "$LVNAME" || LVNAME=$DM_LV_NAME
-			elif test "$VGNAME" != "$DM_VG_NAME" ; then
+			elif [ "$VGNAME" != "$DM_VG_NAME" ]; then
 				error "Volume group name \"$VGNAME\" does not match name \"$DM_VG_NAME\" for VDO device \"$DEVICE\"."
 			fi
 			;;
-		*)	IS_LV=0
+		*)
 			# Check if we need to generate unused $VGNANE
 			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
 				VGNAME=${DEFAULT_NAME%/*}
 				# Find largest matching VG name to our 'default' vgname
-				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "${VGNAME}[0-9]? ?" | head -1 || true)
-				if test -n "$LASTVGNAME" ; then
+				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~"${VGNAME}" | grep -E "${VGNAME}[0-9]? ?" | head -1 || true)
+				if [ -n "$LASTVGNAME" ]; then
 					LASTVGNAME=${LASTVGNAME#*"${VGNAME}"}
 					# If the number is becoming too high, try some random number
 					test "$LASTVGNAME" -gt 99999999 2>/dev/null && LASTVGNAME=$RANDOM
 					# Generate new unused VG name
 					VGNAME="${VGNAME}$(( LASTVGNAME + 1 ))"
-					verbose "Selected unused volume group name $VGNAME."
+					verbose "Selected unused volume group name \"$VGNAME\"."
 				fi
 			fi
 			# New VG is created, LV name should be always unused.
@@ -269,13 +501,14 @@ convert2lvm_() {
 			;;
 	esac
 
-	verbose "Checked whether device $1 is already LV ($IS_LV)."
+	verbose "Checked whether device \"$DEVICE\" is already logical volume."
 
 	"$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR."
 
 	# TODO: might use directly  /etc/vdoconf.yml (avoding need of 'vdo' manager)
 	verbose "Getting YAML VDO configuration."
 	"$VDO" printConfigFile $VDOCONF >"$TEMPDIR/vdoconf.yml"
+	test -s "$TEMPDIR/vdoconf.yml" || error "Cannot work without VDO configuration"
 
 	# Check list of devices in VDO configure file for their major:minor
 	# and match with given $DEVICE devmajor:devminor
@@ -290,8 +523,8 @@ convert2lvm_() {
 		}
 	done
 
-	test -n "$FOUND" || error "Can't find matching device in vdo configuration file."
-	verbose "Found matching device $FOUND  $MAJOR:$MINOR"
+	test -n "$FOUND" || error "Can't find matching device in VDO configuration file."
+	verbose "Found matching device $FOUND  $MAJOR:$MINOR."
 
 	VDONAME=$(awk -v DNAME="$FOUND" '/.*VDOService$/ {VNAME=substr($1, 0, length($1) - 1)} /[[:space:]]*device:/ { if ($2 ~ DNAME) {print VNAME}}' "$TEMPDIR/vdoconf.yml")
 	TRVDONAME=$(echo "$VDONAME" | tr '-' '_')
@@ -313,7 +546,7 @@ convert2lvm_() {
 
 	verbose "Converted VDO device has logical/physical size $vdo_logicalSize/$vdo_physicalSize KiB."
 
-	PARAMS=$(cat <<EOF
+	VDO_ALLOCATION_PARAMS=$(cat <<EOF
 allocation {
 	vdo_use_compression = $(get_enabled_value_ "$vdo_compression")
 	vdo_use_deduplication = $(get_enabled_value_ "$vdo_deduplication")
@@ -338,80 +571,31 @@ allocation {
 }
 EOF
 )
-	verbose "VDO conversion paramaters: $PARAMS"
+	verbose "VDO conversion parameters: $VDO_ALLOCATION_PARAMS"
+
+	verbose "Stopping VDO volume."
+	dry "$VDO" stop $VDOCONF --name "$VDONAME"
 
 	# If user has not provided '--yes', prompt before conversion
-	if test -z "$YES" ; then
+	if [ -z "$YES" ] && [ "$USE_VDO_DM_SNAPSHOT" != "1" ]; then
 		PROMPTING=yes
 		echo -n "Convert VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
-		read -n 1 -s ANSWER
+		read -r -n 1 -s ANSWER
 		case "${ANSWER:0:1}" in
-			y|Y )  echo "Yes" ;;
-			* )    echo "No" ; PROMPTING=""; exit 1 ;;
+		  y|Y )  echo "Yes" ;;
+		    * )  echo "No" ; PROMPTING=""; cleanup 1 ;;
 		esac
 		PROMPTING=""
-		YES="-y" # From now, now prompting
+		YES="-y" # From now, no prompting
 	fi
 
-	verbose "Stopping VDO volume."
-	dry "$VDO" stop $VDOCONF --name "$VDONAME"
-
-	if [ "$IS_LV" = "0" ]; then
-		verbose "Moving VDO header by 2MiB."
-		dry "$VDO" convert $VDOCONF --force --name "$VDONAME"
+	# Make a backup of the existing VDO yaml configuration file
+	test -e "$VDO_CONFIG" && dry cp -a "$VDO_CONFIG" "${VDO_CONFIG}.backup"
 
-		dry "$LVM" pvcreate $YES --dataalignment 2M "$DEVICE" || {
-			error "Creation of PV on \"$DEVICE\" failed, while VDO header has been already moved!"
-		}
-
-		# Obtain free space in this new PV
-		# after 'vdo convert' call there is +2M free space at the front of the device
-		case "$DRY" in
-		0) pvfree=$("$LVM" pvs -o devsize --units b --nosuffix --noheadings "$DEVICE") ;;
-		*) pvfree=$("$BLOCKDEV" --getsize64 "$DEVICE") ;;
-		esac
-
-		pvfree=$(( pvfree / 1024 - 2048 ))	# to KiB
-	else
-		pvfree=$("$LVM" lvs -o size --units b --nosuffix --noheadings "$DM_VG_NAME/$DM_LV_NAME")
-		pvfree=$(( pvfree / 1024 ))		# to KiB
-	fi
-
-	# select largest possible extent size that can exactly express both sizes
-	EXTENTSZ=$(get_largest_extent_size_ "$pvfree" "$vdo_logicalSize")
-
-	if [ "$IS_LV" = "0" ]; then
-		verbose "Creating VG \"${NAME%/*}\" with extent size $EXTENTSZ KiB."
-		dry "$LVM" vgcreate $YES $VERB -s "${EXTENTSZ}k" "$VGNAME" "$DEVICE" || {
-			error "Creation of VG \"$VGNAME\" failed, while VDO header has been already moved!"
-		}
-
-		verbose "Creating VDO pool data LV from all extents in volume group $VGNAME."
-		dry "$LVM" lvcreate -Zn -Wn $YES $VERB -l100%VG -n "${LVNAME}_vpool" "$VGNAME"
-	else
-		# validate existing  VG extent_size can express virtual VDO size
-		vg_extent_size=$("$LVM" vgs -o vg_extent_size --units b --nosuffix --noheadings "$VGNAME" || true)
-		vg_extent_size=$(( vg_extent_size / 1024 ))
-
-		test "$vg_extent_size" -le "$EXTENTSZ" || {
-			error "Please vgchange extent_size to@most $EXTENTSZ KiB or extend and align virtual size of VDO device on $vg_extent_size KiB."
-		}
-		verbose "Renaming existing LV to be used as _vdata volume for VDO pool LV."
-		dry "$LVM" lvrename $YES $VERB "$VGNAME/$DM_LV_NAME" "$VGNAME/${LVNAME}_vpool" || {
-			error "Rename of LV \"$VGNAME/$DM_LV_NAME\" failed, while VDO header has been already moved!"
-		}
-	fi
-
-	verbose "Converting to VDO pool."
-	dry "$LVM" lvconvert $YES $VERB $FORCE --config "$PARAMS" -Zn -V "${vdo_logicalSize}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
-
-	# Note: that this is spelled OPPOSITE the other $IS_LV checks.
-	if [ "$IS_LV" = "1" ]; then
-		verbose "Removing now-unused VDO entry from VDO config."
-		dry "$VDO" remove $VDOCONF $VERB --force --name "$VDONAME"
-	fi
-
-	rm -fr "$TEMPDIR"
+	case "$DM_UUID" in
+		LVM-*) convert_lv_ "$vdo_logicalSize" ;;
+		*)     convert_non_lv_ "$vdo_logicalSize" ;;
+	esac
 }
 
 #############################
@@ -431,14 +615,19 @@ do
 	  "-n"|"--name"   ) shift; NAME=$1 ;;
 	  "-v"|"--verbose") VERB="-v" ;;
 	  "-y"|"--yes"    ) YES="-y" ;;
+	  "--abort-after-vdo-convert" ) ABORT_AFTER_VDO_CONVERT=1; USE_VDO_DM_SNAPSHOT=0 ;; # For testing only
 	  "--dry-run"     ) DRY="1" ; VERB="-v" ;;
+	  "--no-snapshot" ) USE_VDO_DM_SNAPSHOT=0 ;;
+	  "--uuid-prefix" ) shift; DM_UUID_PREFIX=$1 ;; # For testing only
+	  "--vdo-config"  ) shift; VDO_CONFIG=$1 ; VDOCONF="-f $VDO_CONFIG" ;;
 	  "-*") error "Wrong argument \"$1\". (see: $TOOL --help)" ;;
-	  *) DEVICENAME=$1 ;;  # device name does not start with '-'
+	  *) DEVICE=$1 ;;  # device name does not start with '-'
 	esac
 	shift
 done
 
-test -n "$DEVICENAME" || error "Device name is not specified. (see: $TOOL --help)"
+test -n "$DEVICE" || error "Device name is not specified. (see: $TOOL --help)"
+
+convert2lvm_
 
-# do conversion
-convert2lvm_ "$DEVICENAME"
+cleanup 0

