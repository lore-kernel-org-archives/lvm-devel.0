From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 12 Sep 2023 12:45:49 +0000
Subject: [Git][lvmteam/lvm2][main] 4 commits: vdo: lvm_import_vdo enhancements
Message-ID: <65005d7d9562e_27a459c12065@gitlab-sidekiq-low-urgency-cpu-bound-v2-6b46947f6d-lf79w.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
d9cebeaf by Zdenek Kabelac at 2023-09-12T14:30:48+02:00
vdo: lvm_import_vdo enhancements

Work also with devices that may have &#39;:&#39; inside their generated
/dev/disk/by-id

Ensure there is no race with systems&#39; auto activation while using
the snapshot for conversion.

Update system&#39;s vdoconf.yml after the use of snapshot for conversion.

Skip unnecesary prompt for &#39;convert&#39; while using snapshot and query only
for final snaphot merge.

Prohibit conversion for a device with the PV header.

Enhance &#39;trap&#39; protection for more signals.

Improve clean() recovery path.

Replace bash &#39;test&#39; command with [].

Correct some output message to print $TOOL.

Support also options without &#39;-&#39; in the middle i.e. --nosnapshot.

For shellcheck predefine all variables extracted from vdoconf.yml.

- - - - -
b1b60887 by Zdenek Kabelac at 2023-09-12T14:39:14+02:00
debug: missing dots

- - - - -
ab73ad4e by Mikulas Patocka at 2023-09-12T14:41:22+02:00
gcc: fix warnings for x32 architecture

Warning from x32 ABI compilation.

- - - - -
8cbfd72f by Zdenek Kabelac at 2023-09-12T14:44:32+02:00
WHATS_NEW: updates

- - - - -


5 changed files:

- WHATS_NEW
- lib/log/log.c
- lib/metadata/vdo_manip.c
- scripts/lvm_import_vdo.sh
- tools/vgchange.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,7 +1,8 @@
 version 2.03.23 - 
 ==================================
+  Enhance error detection for lvm_import_vdo.
   Support PV lists with thin lvconvert.
-  Fix support for lvm_import_vdo and SCSI VDO volumes.
+  Fix support for lvm_import_vdo with SCSI VDO volumes.
   Recognize lvm.conf report/headings=2 for full column names in report headings.
   Add --headings none|abbrev|full cmd line option to set report headings type.
   Require writable LV for convertion to vdo pool.


=====================================
lib/log/log.c
=====================================
@@ -515,7 +515,7 @@ static void _set_time_prefix(char *prefix, int buflen)
 	if (!len)
 		goto fail;
 
-	len = dm_snprintf(prefix + len, buflen - len, ".%06ld ", ts.tv_nsec/1000);
+	len = dm_snprintf(prefix + len, buflen - len, ".%06d ", (int)ts.tv_nsec/1000);
 	if (len < 0)
 		goto fail;
 


=====================================
lib/metadata/vdo_manip.c
=====================================
@@ -522,9 +522,9 @@ static int _get_sysinfo_memory(uint64_t *total_mb, uint64_t *available_mb)
 	if (sysinfo(&si) != 0)
 		return 0;
 
-	log_debug("Sysinfo free:%lu  bufferram:%lu  sharedram:%lu  freehigh:%lu  unit:%u.",
-		  si.freeram >> 20, si.bufferram >> 20, si.sharedram >> 20,
-		  si.freehigh >> 20, si.mem_unit);
+	log_debug("Sysinfo free:%llu  bufferram:%llu  sharedram:%llu  freehigh:%llu  unit:%u.",
+		  (unsigned long long)si.freeram >> 20, (unsigned long long)si.bufferram >> 20, (unsigned long long)si.sharedram >> 20,
+		  (unsigned long long)si.freehigh >> 20, si.mem_unit);
 
 	*available_mb = ((uint64_t)(si.freeram + si.bufferram) * si.mem_unit) >> 30;
 	*total_mb = si.totalram >> 30;


=====================================
scripts/lvm_import_vdo.sh
=====================================
@@ -36,6 +36,9 @@ TEMPDIR="${TMPDIR:-/tmp}/$IMPORT_NAME"
 _SAVEPATH=$PATH
 PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
 
+# Set of trapped signals
+declare -a SIGNALS=("HUP" "INT" "QUIT" "ABRT" "TERM" "EXIT")
+
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
 VDO=${VDO_BINARY:-vdo}
@@ -52,7 +55,9 @@ DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 DM_UUID_PREFIX="${DM_UUID_PREFIX:-}"
 DM_VG_NAME=
 DM_LV_NAME=
+DEFAULT_VDO_CONFIG="/etc/vdoconf.yml" # Default location of vdo's manager config file
 VDO_CONFIG=${VDO_CONFIG:-}   # can be overridden with --vdo-config
+VDO_CONFIG_RESTORE=
 VDOCONF=
 test -n "$VDO_CONFIG" && VDOCONF="-f $VDO_CONFIG"
 
@@ -61,16 +66,17 @@ VGNAME=
 LVNAME=
 DEVMAJOR=0
 DEVMINOR=0
-PROMPTING=""
-USE_VDO_DM_SNAPSHOT=1
+PROMPTING=
+USE_VDO_DM_SNAPSHOT="--yes"
 VDO_DM_SNAPSHOT_NAME=
 VDO_DM_SNAPSHOT_DEVICE=
 VDO_SNAPSHOT_LOOP=
+VDO_INCONSISTENT=
 
 DRY=0
-VERB=""
-FORCE=""
-YES=""
+VERB=
+FORCE=
+YES=
 ABORT_AFTER_VDO_CONVERT=0
 VDO_ALLOCATION_PARAMS=
 
@@ -78,6 +84,25 @@ VDO_ALLOCATION_PARAMS=
 DEFAULT_NAME="vdovg/vdolvol"
 NAME=""
 
+# predefine empty
+vdo_ackThreads=
+vdo_bioRotationInterval=
+vdo_bioThreads=
+vdo_blockMapCacheSize=
+vdo_blockMapPeriod=
+vdo_compression=
+vdo_cpuThreads=
+vdo_deduplication=
+vdo_hashZoneThreads=
+vdo_indexMemory=
+vdo_indexSparse=
+vdo_logicalBlockSize=
+vdo_logicalThreads=
+vdo_maxDiscardSize=
+vdo_physicalThreads=
+vdo_slabSize=
+vdo_writePolicy=
+
 # help message
 tool_usage() {
 	echo "${TOOL}: Utility to convert VDO volume to VDO LV."
@@ -107,7 +132,11 @@ error() {
 	for i in "$@" ;  do
 		echo "$TOOL: $i" >&2
 	done
-	cleanup 1
+	return 1
+}
+
+warn() {
+	echo "$TOOL: WARNING: $i" >&2
 }
 
 dry() {
@@ -120,20 +149,31 @@ dry() {
 }
 
 cleanup() {
-	trap '' 2
-	test -n "$VDO_DM_SNAPSHOT_NAME" && {
+	RC=$?	# Return code + 128  of the last command eg INT=2 + 128 -> 130
+
+	trap '' "${SIGNALS[@]}" # mute trap for all signals to not interrupt cleanup() on any next signal
+
+	[ -z "$PROMPTING" ] || echo "No"
+
+	[ -e "$VDO_CONFIG_RESTORE" ] && { dry cp -a "$VDO_CONFIG_RESTORE" "${VDO_CONFIG:-"$DEFAULT_VDO_CONFIG"}" || true ; }
+
+	if [ -n "$VDO_DM_SNAPSHOT_NAME" ]; then
+		dry "$LVM" vgchange -an --devices "$VDO_DM_SNAPSHOT_DEVICE" "$VGNAME" &>/dev/null || true
 		for i in {1..20} ; do
-			test "$("$DMSETUP" info --noheading -co open "$VDO_DM_SNAPSHOT_NAME")" = "0" && break
+			[ "$(dry "$DMSETUP" info --noheading -co open "$VDO_DM_SNAPSHOT_NAME")" = "0" ] && break
 			sleep .1
 		done
-		"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || true
-	}
-	test -n "$VDO_SNAPSHOT_LOOP" && { "$LOSETUP" -d "$VDO_SNAPSHOT_LOOP" || true ; }
+		dry "$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" &>/dev/null || true
+	fi
+
+
+	[ -n "$VDO_SNAPSHOT_LOOP" ] && { dry "$LOSETUP" -d "$VDO_SNAPSHOT_LOOP" || true ; }
+
+	[ -z "$VDO_INCONSISTENT" ] || echo "$TOOL: VDO volume import process exited unexpectedly!" >&2
 
-	test -z "$PROMPTING" || echo "No"
 	rm -rf "$TEMPDIR" || true
-	# error exit status for break
-	exit "${1:-1}"
+
+	exit "$RC"
 }
 
 # Create snapshot target like for persistent snapshot with 16KiB chunksize
@@ -148,7 +188,7 @@ snapshot_create_() {
 	# TODO: maybe use ramdisk via 'brd' device ?)
 	"$TRUNCATE" -s 20M "$file"
 	VDO_SNAPSHOT_LOOP=$("$LOSETUP" -f --show "$file")
-	"$DMSETUP" create "$VDO_DM_SNAPSHOT_NAME" -u "${DM_UUID_PREFIX}-${VDO_DM_SNAPSHOT_NAME}-priv" --table "$(snapshot_target_line_ "$1" "$VDO_SNAPSHOT_LOOP")"
+	"$DMSETUP" create "$VDO_DM_SNAPSHOT_NAME" -u "${DM_UUID_PREFIX}${VDO_DM_SNAPSHOT_NAME}-priv" --table "$(snapshot_target_line_ "$1" "$VDO_SNAPSHOT_LOOP")"
 	VDO_DM_SNAPSHOT_DEVICE="$DM_DEV_DIR/mapper/$VDO_DM_SNAPSHOT_NAME"
 	verbose "Snapshot of VDO device $1 created: $VDO_DM_SNAPSHOT_DEVICE."
 }
@@ -164,6 +204,8 @@ snapshot_merge_() {
 	}
 
 	verbose "Merging converted VDO volume..."
+	VDO_INCONSISTENT=1
+
 	# Running merging
 	"$DMSETUP" resume "$VDO_DM_SNAPSHOT_NAME"
 
@@ -171,24 +213,28 @@ snapshot_merge_() {
 
 	# Loop for a while, till the snapshot is merged.
 	# Should be nearly instantaneous.
-        # FIXME: Recovery when something prevents merging is hard
+	# FIXME: Recovery when something prevents merging is hard
 	for i in $(seq 1 20) ; do
 		status=( $("$DMSETUP" status "$VDO_DM_SNAPSHOT_NAME") )
 		# Check if merging is finished
-		test "${status[3]%/*}" = "${status[4]}" && break
+		[ "${status[3]%/*}" = "${status[4]}" ] && break
 		# Wait a bit and retry
 		sleep .2
 	done
-	test "${status[3]%/*}" = "${status[4]}" || {
+
+	if [ "${status[3]%/*}" != "${status[4]}" ]; then
 		# FIXME: Now what shall we do ??? Help....
-		# Keep snapshot in table for possible analysis...
+		# Keep snapshot in DM table for possible analysis...
 		VDO_DM_SNAPSHOT_NAME=
 		VDO_SNAPSHOT_LOOP=
-		echo "Initial snapshot status ${initial_status[*]}"
-		echo "Failing merge snapshot status ${status[*]}"
+		echo "$TOOL: Initial snapshot status ${initial_status[*]}"
+		echo "$TOOL: Failing merge snapshot status ${status[*]}"
 		error "ABORTING: Snapshot failed to merge! (Administrator required...)"
-	}
-	sync
+	fi
+
+	VDO_INCONSISTENT=
+	VDO_CONFIG_RESTORE=
+
 	"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || {
 		sleep 1 # sleep and retry once more
 		"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || {
@@ -227,9 +273,9 @@ get_largest_extent_size_() {
 
 	for i in 8 16 32 64 128 256 512 1024 2048 4096 ; do
 		d=$(( $1 / i ))
-		test $(( d * i )) -eq "$1" || break
+		[ $(( d * i )) -eq "$1" ] || break
 		d=$(( $2 / i ))
-		test $(( d * i )) -eq "$2" || break
+		[ $(( d * i )) -eq "$2" ] || break
 		max=$i
 	done
 	echo "$max"
@@ -244,7 +290,7 @@ detect_lv_() {
 
 	DEVICE=${1/#"${DM_DEV_DIR}/"/}
 	DEVICE=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$DEVICE" || true)
-	test -n "$DEVICE" || error "Readlink cannot access device \"$1\"."
+	[ -n "$DEVICE" ] || error "Readlink cannot access device \"$1\"."
 	RDEVICE=$DEVICE
 	case "$RDEVICE" in
 	  # hardcoded /dev  since udev does not create these entries elsewhere
@@ -256,12 +302,12 @@ detect_lv_() {
 		;;
 	  *)
 		RSTAT=$("$STAT" --format "DEVMAJOR=\$((0x%t)) DEVMINOR=\$((0x%T))" "$RDEVICE" || true)
-		test -n "$RSTAT" || error "Cannot get major:minor for \"$DEVICE\"."
+		[ -n "$RSTAT" ] || error "Cannot get major:minor for \"$DEVICE\"."
 		eval "$RSTAT"
 		;;
 	esac
 
-	test "$DEVMAJOR" != "$(grep device-mapper /proc/devices | cut -f1 -d' ')" && return
+	[ "$DEVMAJOR" != "$(grep device-mapper /proc/devices | cut -f1 -d' ')" ] && return
 
 	DEV="$("$DMSETUP" info -c -j "$DEVMAJOR" -m "$DEVMINOR" -o uuid,name --noheadings --nameprefixes --separator ' ')"
 	case "$DEV" in
@@ -337,9 +383,10 @@ convert_lv_() {
 	vg_extent_size=$("$LVM" vgs -o vg_extent_size --units b --nosuffix --noheadings "$VGNAME")
 	vg_extent_size=$(( vg_extent_size / 1024 ))
 
-	test "$vg_extent_size" -le "$extent_size" || {
+	[ "$vg_extent_size" -le "$extent_size" ] || {
 		error "Please vgchange extent_size to at most $extent_size KiB or extend and align virtual size of VDO device on $vg_extent_size KiB before retrying conversion."
 	}
+
 	verbose "Renaming existing LV to be used as _vdata volume for VDO pool LV."
 	dry "$LVM" lvrename $YES $VERB "$VGNAME/$DM_LV_NAME" "$VGNAME/${LVNAME}_vpool" || {
 		error "Rename of LV \"$VGNAME/$DM_LV_NAME\" failed, while VDO header has been already moved!"
@@ -367,25 +414,39 @@ convert_non_lv_() {
 	local output
 	local pvfree
 
-	if [ "$USE_VDO_DM_SNAPSHOT" = "1" ]; then
+	if [ -n "$USE_VDO_DM_SNAPSHOT" ]; then
 		dry snapshot_create_ "$DEVICE"
-		sed "s:$DEVICE:$VDO_DM_SNAPSHOT_DEVICE:" "$TEMPDIR/vdoconf.yml" > "$TEMPDIR/vdo_snap.yml"
+		sed "s|$DEVICE|$VDO_DM_SNAPSHOT_DEVICE|" "$TEMPDIR/vdoconf.yml" > "$TEMPDIR/vdo_snap.yml"
+		# In case of error in the middle of conversion restore original config file
+		VDO_CONFIG_RESTORE="$TEMPDIR/vdoconf.yml"
 		# Let VDO manager operate on snapshot volume
-		VDOCONF="-f $TEMPDIR/vdo_snap.yml"
+		dry cp -a "$TEMPDIR/vdo_snap.yml" "${VDO_CONFIG:-"$DEFAULT_VDO_CONFIG"}"
+	else
+		# If error in the following section, report possible problems ahead
+		VDO_INCONSISTENT=1
 	fi
 
-	verbose "Moving VDO header."
+	# In case we operate with snapshot, all lvm2 operation will also run on top of snapshot
+	local device=${VDO_DM_SNAPSHOT_DEVICE:-$DEVICE}
+
+	# Check if there is not already an existing PV header, this would have fail on pvcreate after conversion
+	"$LVM" pvs --devices "$device" "$device" 2>/dev/null && {
+		error "Cannot convert volume \"$DEVICE\" with existing PV header."
+	}
+
+	verbose "Moving VDO header on \"$device\"."
 
 	output=$(dry "$VDO" convert $VDOCONF $VERB --force --name "$VDONAME" 2>&1) || {
+		local rc=$?
 		echo "$output"
-		error "Failed to convert VDO volume \"$DEVICE\" (exit code $?)."
+		error "Failed to convert VDO volume \"$DEVICE\" (exit code $rc)."
 	}
 
 	echo "$output"
 
-	if [ "$ABORT_AFTER_VDO_CONVERT" != "0" ] ; then
-		verbose "Aborting VDO conversion after moving VDO header, volume is useless!"
-		cleanup 0
+	if [ "$ABORT_AFTER_VDO_CONVERT" != "0" ]; then
+		warn "Aborting VDO conversion after moving VDO header, volume is useless!"
+		return 0
 	fi
 
 	# Parse result from VDO preparation/conversion tool
@@ -410,12 +471,7 @@ convert_non_lv_() {
 		esac
 	done <<< "$output"
 
-	# In case we operation with snapshot, all lvm2 operation will also run on top of snapshot
-	local devices=${VDO_DM_SNAPSHOT_DEVICE:-$DEVICE}
-
-	dry "$LVM" pvcreate $YES --devices "$devices" --dataalignment "$vdo_offset"b "$devices" || {
-		error "Creation of PV on \"$DEVICE\" failed, while VDO header has been already moved!"
-	}
+	dry "$LVM" pvcreate $YES $VERB $FORCE --devices "$device" --dataalignment "$vdo_offset"b "$device"
 
 	# Obtain free space in this new PV
 	# after 'vdo convert' call there is ~(1-2)M free space@the front of the device
@@ -432,54 +488,57 @@ convert_non_lv_() {
 	# To precisely byte-synchronize the size of VDO LV, user can lvresize such VDO LV later.
 	vdo_logicalSizeRounded=$(( ( vdo_logicalSize / extent_size ) * extent_size ))
 
-	verbose "Creating VG \"${NAME%/*}\" with extent size $extent_size KiB."
-	dry "$LVM" vgcreate $YES $VERB --devices "$devices" -s "${extent_size}k" "$VGNAME" "$devices" || {
-		error "Creation of VG \"$VGNAME\" failed, while VDO header has been already moved!"
-	}
+	verbose "Creating volume group \"$VGNAME\" with the extent size $extent_size KiB."
+	dry "$LVM" vgcreate $YES $VERB --devices "$device" -s "${extent_size}k" "$VGNAME" "$device"
 
-	verbose "Creating VDO pool data LV from all extents in volume group $VGNAME."
-	dry "$LVM" lvcreate -Zn -Wn -an $YES $VERB --devices "$devices" -l100%VG -n "${LVNAME}_vpool" "$VGNAME" "$devices"
+	verbose "Creating VDO pool data LV from all extents in the volume group \"$VGNAME\"."
+	dry "$LVM" lvcreate -Zn -Wn -an $YES $VERB --devices "$device" -l100%VG -n "${LVNAME}_vpool" "$VGNAME" "$device"
 
 	verbose "Converting to VDO pool."
-	dry "$LVM" lvconvert $YES $VERB $FORCE --devices "$devices" --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSizeRounded}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
-	if [ "$vdo_logicalSizeRounded" -lt "$vdo_logicalSize" ] ; then
+	dry "$LVM" lvconvert ${USE_VDO_DM_SNAPSHOT:-"$YES"} $VERB $FORCE --devices "$device" --config "$VDO_ALLOCATION_PARAMS" -Zn -V "${vdo_logicalSizeRounded}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
+
+	if [ "$vdo_logicalSizeRounded" -lt "$vdo_logicalSize" ]; then
 		# need to extend virtual size to be covering all the converted area
 		# let lvm2 to round to the proper virtual size of VDO LV
-		dry "$LVM" lvextend $YES $VERB --fs ignore --devices "$devices" -L "$vdo_logicalSize"k "$VGNAME/$LVNAME"
+		dry "$LVM" lvextend $YES $VERB --fs ignore --devices "$device" -L "$vdo_logicalSize"k "$VGNAME/$LVNAME"
 	fi
 
-	dry "$LVM" vgchange -an $VERB $FORCE --devices "$devices" "$VGNAME"
+	VDO_INCONSISTENT=
+
+	if [ -n "$USE_VDO_DM_SNAPSHOT" ]; then
+		dry "$LVM" vgchange -an $VERB $FORCE --devices "$device" "$VGNAME"
+
+		# Prevent unwanted auto activation when VG is merged
+		dry "$LVM" vgchange --setautoactivation n $VERB $FORCE --devices "$device" "$VGNAME"
 
-	if [ "$USE_VDO_DM_SNAPSHOT" = "1" ]; then
 		if [ -z "$YES" ]; then
 			PROMPTING=yes
-			echo "Warning: Do not interrupt merging process once it starts (VDO data may become irrecoverable)!"
-			echo -n "Do you want to merge converted VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
+			warn "Do not interrupt merging process once it starts (VDO data may become irrecoverable)!"
+			echo -n "$TOOL: Do you want to merge converted VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
 			read -r -n 1 -s ANSWER
 			case "${ANSWER:0:1}" in
 			  y|Y )  echo "Yes" ;;
-			    * )  echo "No" ; PROMPTING=""; cleanup 1 ;;
+			    * )  echo "No" ; PROMPTING=""; return 1 ;;
 			esac
 			PROMPTING=""
 			YES="-y" # From now, now prompting
 		fi
 
 		dry snapshot_merge_ "$DEVICE"
-		if [ -e "$TEMPDIR/vdo_snap.yml" ]; then
-			dry cp "$TEMPDIR/vdo_snap.yml" "$VDO_CONFIG"
-		elif [ -e "$VDO_CONFIG" ]; then
-			dry rm -f "$VDO_CONFIG"
-		fi
+
 		verbose "Merging of VDO device finished."
 	fi
 
-	output=$(dry "$LVM" pvs "$DEVICE" 2>&1) || {
+	output=$("$LVM" pvs "$DEVICE" 2>&1) || {
 		if echo "$output" | grep -q "not in devices file" ; then
 			verbose "Adding \"$DEVICE\" to devices file."
 			dry "$LVM" lvmdevices --adddev "$DEVICE"
 		fi
 	}
 
+	# Restore auto activation for a VG
+	[ -n "$USE_VDO_DM_SNAPSHOT" ] && dry "$LVM" vgchange --setautoactivation y $VERB $FORCE "$VGNAME"
+
 	dry "$LVM" lvchange -ay $VERB $FORCE "$VGNAME/$LVNAME"
 }
 
@@ -497,43 +556,43 @@ convert2lvm_() {
 	detect_lv_ "$DEVICE"
 	case "$DM_UUID" in
 		LVM-*)	eval "$("$DMSETUP" splitname --nameprefixes --noheadings --separator ' ' "$DM_NAME")"
-			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
+			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ]; then
 				VGNAME=$DM_VG_NAME
 				verbose "Using existing volume group name \"$VGNAME\"."
-				test -n "$LVNAME" || LVNAME=$DM_LV_NAME
+				[ -n "$LVNAME" ] || LVNAME=$DM_LV_NAME
 			elif [ "$VGNAME" != "$DM_VG_NAME" ]; then
 				error "Volume group name \"$VGNAME\" does not match name \"$DM_VG_NAME\" for VDO device \"$DEVICE\"."
 			fi
 			;;
 		*)
 			# Check if we need to generate unused $VGNANE
-			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
+			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ]; then
 				VGNAME=${DEFAULT_NAME%/*}
 				# Find largest matching VG name to our 'default' vgname
-				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~"${VGNAME}" | grep -E "${VGNAME}[0-9]? ?" | head -1 || true)
+				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~"${VGNAME}" | grep -m 1 -E "${VGNAME}[0-9]? ?" || true)
 				if [ -n "$LASTVGNAME" ]; then
 					LASTVGNAME=${LASTVGNAME#*"${VGNAME}"}
 					# If the number is becoming too high, try some random number
-					test "$LASTVGNAME" -gt 99999999 2>/dev/null && LASTVGNAME=$RANDOM
+					[ -n "$LASTVGNAME" ] && [ "$LASTVGNAME" -gt 99999999 ] && LASTVGNAME=$RANDOM
 					# Generate new unused VG name
 					VGNAME="${VGNAME}$(( LASTVGNAME + 1 ))"
 					verbose "Selected unused volume group name \"$VGNAME\"."
 				fi
 			fi
 			# New VG is created, LV name should be always unused.
-			test -n "$LVNAME" || LVNAME=${DEFAULT_NAME#*/}
+			[ -n "$LVNAME" ] || LVNAME=${DEFAULT_NAME#*/}
 			"$LVM" vgs "$VGNAME" >/dev/null 2>&1 && error "Cannot use already existing volume group name \"$VGNAME\"."
 			;;
 	esac
 
 	verbose "Checked whether device \"$DEVICE\" is already logical volume."
 
-	"$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR."
+	"$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create \"$TEMPDIR\"."
 
 	# TODO: might use directly  /etc/vdoconf.yml (avoiding need of 'vdo' manager)
 	verbose "Getting YAML VDO configuration."
 	"$VDO" printConfigFile $VDOCONF >"$TEMPDIR/vdoconf.yml"
-	test -s "$TEMPDIR/vdoconf.yml" || error "Cannot work without VDO configuration"
+	[ -s "$TEMPDIR/vdoconf.yml" ] || error "Cannot work without VDO configuration."
 
 	# Check list of devices in VDO configure file for their major:minor
 	# and match with given $DEVICE devmajor:devminor
@@ -542,13 +601,13 @@ convert2lvm_() {
 		DEV=$("$READLINK" $READLINK_E "$i") || continue
 		RSTAT=$("$STAT" --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$DEV" 2>/dev/null) || continue
 		eval "$RSTAT"
-		test "$MAJOR" = "$DEVMAJOR" && test "$MINOR" = "$DEVMINOR" && {
-			test -z "$FOUND" || error "VDO configuration contains duplicate entries $FOUND and $i"
+		if [ "$MAJOR" = "$DEVMAJOR" ] && [ "$MINOR" = "$DEVMINOR" ]; then
+			[ -z "$FOUND" ] || error "VDO configuration contains duplicate entries $FOUND and $i."
 			FOUND=$i
-		}
+		fi
 	done
 
-	test -n "$FOUND" || error "Can't find matching device in VDO configuration file."
+	[ -n "$FOUND" ] || error "Can't find matching device in VDO configuration file."
 	verbose "Found matching device $FOUND  $MAJOR:$MINOR."
 
 	VDONAME=$(awk -v DNAME="$FOUND" '/.*VDOService$/ {VNAME=substr($1, 0, length($1) - 1)} /[[:space:]]*device:/ { if ($2 ~ DNAME) {print VNAME}}' "$TEMPDIR/vdoconf.yml")
@@ -559,7 +618,7 @@ convert2lvm_() {
 	case "$DM_OPEN" in
 	Device*) ;; # no devices
 	*)	eval "$DM_OPEN"
-		test "${DM_OPEN:-0}" -eq 0 || error "Cannot convert in use VDO volume \"$VDONAME\"!"
+		[ "${DM_OPEN:-0}" -eq 0 ] || error "Cannot convert in use VDO volume \"$VDONAME\"!"
 		;;
 	esac
 
@@ -601,20 +660,20 @@ EOF
 	dry "$VDO" stop $VDOCONF --name "$VDONAME" $VERB
 
 	# If user has not provided '--yes', prompt before conversion
-	if [ -z "$YES" ] && [ "$USE_VDO_DM_SNAPSHOT" != "1" ]; then
+	if [ -z "$YES" ] && [ -z "$USE_VDO_DM_SNAPSHOT" ]; then
 		PROMPTING=yes
-		echo -n "Convert VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
+		echo -n "$TOOL: Convert VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
 		read -r -n 1 -s ANSWER
 		case "${ANSWER:0:1}" in
 		  y|Y )  echo "Yes" ;;
-		    * )  echo "No" ; PROMPTING=""; cleanup 1 ;;
+		    * )  echo "No" ; PROMPTING=""; return 1 ;;
 		esac
 		PROMPTING=""
 		YES="-y" # From now, no prompting
 	fi
 
 	# Make a backup of the existing VDO yaml configuration file
-	test -e "$VDO_CONFIG" && dry cp -a "$VDO_CONFIG" "${VDO_CONFIG}.backup"
+	[ -e "$VDO_CONFIG" ] && dry cp -a "$VDO_CONFIG" "${VDO_CONFIG}.backup"
 
 	DEVICE=$FOUND
 	case "$DM_UUID" in
@@ -627,9 +686,9 @@ EOF
 # start point of this script
 # - parsing parameters
 #############################
-trap "cleanup 2" 2
+trap "cleanup" "${SIGNALS[@]}"
 
-test "$#" -eq 0 && tool_usage
+[ "$#" -eq 0 ] && tool_usage
 
 while [ "$#" -ne 0 ]
 do
@@ -640,19 +699,17 @@ do
 	  "-n"|"--name"   ) shift; NAME=$1 ;;
 	  "-v"|"--verbose") VERB="--verbose" ;;
 	  "-y"|"--yes"    ) YES="-y" ;;
-	  "--abort-after-vdo-convert" ) ABORT_AFTER_VDO_CONVERT=1; USE_VDO_DM_SNAPSHOT=0 ;; # For testing only
-	  "--dry-run"     ) DRY="1" ; VERB="-v" ;;
-	  "--no-snapshot" ) USE_VDO_DM_SNAPSHOT=0 ;;
-	  "--uuid-prefix" ) shift; DM_UUID_PREFIX=$1 ;; # For testing only
-	  "--vdo-config"  ) shift; VDO_CONFIG=$1 ; VDOCONF="-f $VDO_CONFIG" ;;
-	  "-*") error "Wrong argument \"$1\". (see: $TOOL --help)" ;;
+	  "--abort-after-vdo-convert"|"--abortaftervdoconvert" ) ABORT_AFTER_VDO_CONVERT=1; USE_VDO_DM_SNAPSHOT= ;; # For testing only
+	  "--dry-run"|"--dryrun" ) DRY="1" ; VERB="-v" ;;
+	  "--no-snapshot"|"--nosnapshot" ) USE_VDO_DM_SNAPSHOT= ;;
+	  "--uuid-prefix"|"--uuidprefix" ) shift; DM_UUID_PREFIX=$1 ;; # For testing only
+	  "--vdo-config"|"--vdoconfig" ) shift; VDO_CONFIG=$1 ; VDOCONF="-f $VDO_CONFIG" ;;
+	  -* ) error "Wrong argument \"$1\". (see: $TOOL --help)" ;;
 	  *) DEVICE=$1 ;;  # device name does not start with '-'
 	esac
 	shift
 done
 
-test -n "$DEVICE" || error "Device name is not specified. (see: $TOOL --help)"
+[ -n "$DEVICE" ] || error "Device name is not specified. (see: $TOOL --help)"
 
 convert2lvm_
-
-cleanup 0


=====================================
tools/vgchange.c
=====================================
@@ -428,7 +428,7 @@ static int _vgchange_uuid(struct cmd_context *cmd __attribute__((unused)),
 	struct id old_vg_id;
 
 	if (lvs_in_vg_activated(vg)) {
-		log_error("Volume group has active logical volumes");
+		log_error("Volume group has active logical volumes.");
 		return 0;
 	}
 
@@ -588,12 +588,12 @@ static int _passes_lock_start_filter(struct cmd_context *cmd,
 		if (cv->type == DM_CFG_EMPTY_ARRAY)
 			break;
 		if (cv->type != DM_CFG_STRING) {
-			log_error("Ignoring invalid string in lock_start list");
+			log_error("Ignoring invalid string in lock_start list.");
 			continue;
 		}
 		str = cv->v.str;
 		if (!*str) {
-			log_error("Ignoring empty string in config file");
+			log_error("Ignoring empty string in config file.");
 			continue;
 		}
 
@@ -709,7 +709,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		if (!vg_write(vg) || !vg_commit(vg))
 			return_ECMD_FAILED;
 
-		log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
+		log_print_unless_silent("Volume group \"%s\" successfully changed.", vg->name);
 	}
 
 	if (arg_is_set(cmd, activate_ARG)) {
@@ -921,7 +921,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if ((arg_is_set(cmd, ignorelockingfailure_ARG) ||
 	     arg_is_set(cmd, sysinit_ARG)) && update) {
-		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
+		log_error("Only -a permitted with --ignorelockingfailure and --sysinit.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -940,13 +940,13 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_is_set(cmd, maxphysicalvolumes_ARG) &&
 	    arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("MaxPhysicalVolumes may not be negative");
+		log_error("MaxPhysicalVolumes may not be negative.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_is_set(cmd, physicalextentsize_ARG) &&
 	    arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Physical extent size may not be negative");
+		log_error("Physical extent size may not be negative.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -1216,7 +1216,7 @@ static int _vgchange_locktype_single(struct cmd_context *cmd, const char *vg_nam
 		}
 	}
 
-	log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
+	log_print_unless_silent("Volume group \"%s\" successfully changed.", vg->name);
 
 	return ECMD_PROCESSED;
 }
@@ -1347,7 +1347,7 @@ int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv)
 		cmd->lockd_vg_disable = 1;
 
 		if (!lockd_global(cmd, "sh"))
-			log_debug("No global lock for lock start");
+			log_debug("No global lock for lock start.");
 
 		/* Disable the lockd_gl in process_each_vg. */
 		cmd->lockd_gl_disable = 1;
@@ -1399,7 +1399,7 @@ static int _vgchange_systemid_single(struct cmd_context *cmd, const char *vg_nam
 				found_pvs++;
 		}
 		if (found_pvs <= missing_pvs) {
-			log_error("Cannot change system ID without the majority of PVs (found %d of %d)",
+			log_error("Cannot change system ID without the majority of PVs (found %d of %d).",
 				  found_pvs, found_pvs+missing_pvs);
 			return ECMD_FAILED;
 		}
@@ -1411,7 +1411,7 @@ static int _vgchange_systemid_single(struct cmd_context *cmd, const char *vg_nam
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_ECMD_FAILED;
 
-	log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
+	log_print_unless_silent("Volume group \"%s\" successfully changed.", vg->name);
 
 	return ECMD_PROCESSED;
 }



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/fa496513010976aac21584b5081529b76462f9a9...8cbfd72f6894fe8668477f96281eaecfadacb505

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/fa496513010976aac21584b5081529b76462f9a9...8cbfd72f6894fe8668477f96281eaecfadacb505
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230912/0372915b/attachment-0001.htm>
