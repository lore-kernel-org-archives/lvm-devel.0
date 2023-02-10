From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:34 +0000 (GMT)
Subject: main - tests: cleanup some shellcheck warns
Message-ID: <20230210165334.0AC053858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=773bc013778df631f9ee14e7a79d5f02211b1e67
Commit:        773bc013778df631f9ee14e7a79d5f02211b1e67
Parent:        cc2293f18ed14f4b306c7e5b92e508a6981b4826
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 16:04:54 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

tests: cleanup some shellcheck warns

Reduce shellcheck warnings about missing {} for possible array
dereference.

Make sure we are not loosing error code when assigning local vars
and explicitely ignore 'errors' from standalone lines when needed.

Add some missing quotes.

Use $() instead of ancient ``

Avoid writing some temporary data into /tmp - test need to store
files within its own 'testdir' - so it can be properly discarded.
---
 scripts/lvm_import_vdo.sh   |  4 ++--
 test/lib/aux.sh             | 48 ++++++++++++++++++++++++---------------------
 test/lib/get.sh             |  6 +++---
 test/lib/lvm_vdo_wrapper.sh |  4 +++-
 4 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index c4c1d152e..134c96513 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -255,11 +255,11 @@ convert2lvm_() {
 				# Find largest matching VG name to our 'default' vgname
 				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "${VGNAME}[0-9]? ?" | head -1 || true)
 				if test -n "$LASTVGNAME" ; then
-					LASTVGNAME=${LASTVGNAME#*${VGNAME}}
+					LASTVGNAME=${LASTVGNAME#*"${VGNAME}"}
 					# If the number is becoming too high, try some random number
 					test "$LASTVGNAME" -gt 99999999 2>/dev/null && LASTVGNAME=$RANDOM
 					# Generate new unused VG name
-					VGNAME="${VGNAME}$(( ${LASTVGNAME} + 1 ))"
+					VGNAME="${VGNAME}$(( LASTVGNAME + 1 ))"
 					verbose "Selected unused volume group name $VGNAME."
 				fi
 			fi
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 58439d62d..ccc787eca 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -387,7 +387,8 @@ teardown_devs_prefixed() {
 
 	wait
 
-	local mounts=( $(grep "$prefix" /proc/mounts | cut -d' ' -f1) )
+	local mounts
+	mounts=( $(grep "$prefix" /proc/mounts | cut -d' ' -f1) ) || true
 	if test ${#mounts[@]} -gt 0; then
 		test "$stray" -eq 0 || echo "## removing stray mounted devices containing $prefix:" "${mounts[@]}"
 		if umount -fl "${mounts[@]}"; then
@@ -464,7 +465,8 @@ teardown_devs() {
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
 	test "${LVM_TEST_PARALLEL:-0}" -eq 1 || test -z "$COMMON_PREFIX" || {
-		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
+		local stray_loops
+		stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) ) || true
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
 			echo "## removing stray loop devices containing $COMMON_PREFIX:" "${stray_loops[@]}"
@@ -626,7 +628,7 @@ prepare_loop() {
 	echo -n "## preparing loop device..."
 
 	# skip if prepare_scsi_debug_dev() was used
-	if test -f SCSI_DEBUG_DEV -a -f LOOP ; then
+	if test -f SCSI_DEBUG_DEV && test -f LOOP ; then
 		echo "(skipped)"
 		return 0
 	fi
@@ -689,7 +691,7 @@ prepare_real_devs() {
 	if test -n "$LVM_TEST_DEVICE_LIST"; then
 		local count=0
 		while read path; do
-			REAL_DEVICES[$count]=$path
+			REAL_DEVICES[count]=$path
 			count=$((  count + 1 ))
 			aux extend_filter "a|$path|"
 			dd if=/dev/zero of="$path" bs=32k count=1
@@ -901,13 +903,13 @@ cleanup_idm_context() {
 	local dev=$1
 
 	if [ -n "$LVM_TEST_LOCK_TYPE_IDM" ]; then
-		sg_dev=`sg_map26 ${dev}`
+		sg_dev=$(sg_map26 "${dev}")
 		echo "Cleanup IDM context for drive ${dev} ($sg_dev)"
-		sg_raw -v -r 512 -o /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -r 512 -o idm_tmp_data.bin "$sg_dev" \
 			88 00 01 00 00 00 00 20 FF 01 00 00 00 01 00 00
-		sg_raw -v -s 512 -i /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -s 512 -i idm_tmp_data.bin "$sg_dev" \
 			8E 00 FF 00 00 00 00 00 00 00 00 00 00 01 00 00
-		rm /tmp/idm_tmp_data.bin
+		rm idm_tmp_data.bin
 	fi
 }
 
@@ -976,12 +978,12 @@ prepare_devs() {
 	for i in $(seq 1 "$n"); do
 		local name="${PREFIX}$pvname$i"
 		local dev="$DM_DEV_DIR/mapper/$name"
-		DEVICES[$count]=$dev
+		DEVICES[count]=$dev
 		count=$((  count + 1 ))
 		# If the backing device number can meet the requirement for PV devices,
 		# then allocate a dedicated backing device for PV; otherwise, rollback
 		# to use single backing device for device-mapper.
-		if [ -n "$LVM_TEST_BACKING_DEVICE" ] && [ $n -le ${#BACKING_DEVICE_ARRAY[@]} ]; then
+		if [ -n "$LVM_TEST_BACKING_DEVICE" ] && [ "$n" -le ${#BACKING_DEVICE_ARRAY[@]} ]; then
 			echo 0 $size linear "${BACKING_DEVICE_ARRAY[$(( count - 1 ))]}" $(( header_shift * 2048 )) > "$name.table"
 		else
 			echo 0 $size linear "$BACKING_DEV" $(( ( i - 1 ) * size + ( header_shift * 2048 ) )) > "$name.table"
@@ -1005,7 +1007,7 @@ prepare_devs() {
 
 	if [ -n "$LVM_TEST_BACKING_DEVICE" ]; then
 		for d in "${BACKING_DEVICE_ARRAY[@]}"; do
-			cnt=$((`blockdev --getsize64 $d` / 1024 / 1024))
+			cnt=$(( $(blockdev --getsize64 "$d") / 1024 / 1024 ))
 			cnt=$(( cnt < 1000 ? cnt : 1000 ))
 			dd if=/dev/zero of="$d" bs=1MB count=$cnt
 			wipefs -a "$d" 2>/dev/null || true
@@ -1209,7 +1211,9 @@ throttle_dm_mirror() {
 	# if the kernel config file is present, validate whether the kernel uses HZ_1000
 	# and return failure for this 'throttling' when it does NOT as without this setting
 	# whole throttling is pointless on modern hardware
-	local kconfig="/boot/config-$(uname -r)"
+	local kconfig
+
+	kconfig="/boot/config-$(uname -r)"
 	if test -e "$kconfig" ; then
 		grep -q "CONFIG_HZ_1000=y" "$kconfig" 2>/dev/null || {
 			echo "WARNING: CONFIG_HZ_1000=y is NOT set in $kconfig -> throttling is unusable"
@@ -1218,7 +1222,7 @@ throttle_dm_mirror() {
 	fi
 	test -e "$throttle_sys" || return
 	test -f THROTTLE || cat "$throttle_sys" > THROTTLE
-	echo ${1-1} > "$throttle_sys"
+	echo "${1-1}" > "$throttle_sys"
 }
 
 # Restore original kcopyd throttle value and have mirroring fast again
@@ -1247,10 +1251,10 @@ restore_from_devtable() {
 		local name=${dev##*/}
 		dmsetup load "$name" "$name.devtable"
 		if not dmsetup resume "$name" ; then
-			dmsetup clear $name
-			dmsetup resume $name
+			dmsetup clear "$name"
+			dmsetup resume "$name"
 			finish_udev_transaction
-			echo "Device $name has unusable table \"$(cat $name.devtable)\""
+			echo "Device $name has unusable table \"$(cat "$name.devtable")\""
 			return 1
 		fi
 	done
@@ -1357,7 +1361,7 @@ extend_devices() {
 	test -z "$LVM_TEST_DEVICES_FILE" && return
 
 	for dev in "$@"; do
-		lvmdevices --adddev $dev
+		lvmdevices --adddev "$dev"
 	done
 }
 
@@ -1395,7 +1399,7 @@ hide_dev() {
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
 		for dev in "$@"; do
-			lvmdevices --deldev $dev
+			lvmdevices --deldev "$dev"
 		done
 	else
 		filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
@@ -1411,7 +1415,7 @@ unhide_dev() {
 
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
 		for dev in "$@"; do
-			lvmdevices -y --adddev $dev
+			lvmdevices -y --adddev "$dev"
 		done
 	else
 		filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
@@ -1844,13 +1848,13 @@ have_cache() {
 
 	declare -a CONF=()
 	# disable cache_check if not present in system
-	if test -n "$LVM_TEST_CACHE_CHECK_CMD" -a ! -x "$LVM_TEST_CACHE_CHECK_CMD" ; then
+	if test -n "$LVM_TEST_CACHE_CHECK_CMD" && test ! -x "$LVM_TEST_CACHE_CHECK_CMD" ; then
 		CONF[0]="global/cache_check_executable = \"\""
 	fi
-	if test -n "$LVM_TEST_CACHE_DUMP_CMD" -a ! -x "$LVM_TEST_CACHE_DUMP_CMD" ; then
+	if test -n "$LVM_TEST_CACHE_DUMP_CMD" && test ! -x "$LVM_TEST_CACHE_DUMP_CMD" ; then
 		CONF[1]="global/cache_dump_executable = \"\""
 	fi
-	if test -n "$LVM_TEST_CACHE_REPAIR_CMD" -a ! -x "$LVM_TEST_CACHE_REPAIR_CMD" ; then
+	if test -n "$LVM_TEST_CACHE_REPAIR_CMD" && test ! -x "$LVM_TEST_CACHE_REPAIR_CMD" ; then
 		CONF[2]="global/cache_repair_executable = \"\""
 	fi
 	if test ${#CONF[@]} -ne 0 ; then
diff --git a/test/lib/get.sh b/test/lib/get.sh
index afc10bce5..3b0d1f21a 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -23,8 +23,8 @@ test -z "$BASH" || set -e -o pipefail
 # trims only leading prefix and suffix
 trim_() {
 	rm -f debug.log             # drop log, command was ok
-	local var=${1%${1##*[! ]}}  # remove trailing space characters
-	echo "${var#${var%%[! ]*}}" # remove leading space characters
+	local var=${1%"${1##*[! ]}"}  # remove trailing space characters
+	echo "${var#"${var%%[! ]*}"}" # remove leading space characters
 }
 
 pv_field() {
@@ -68,7 +68,7 @@ lv_devices() {
 }
 
 lv_field_lv_() {
-	lv_field "$1" "$2" -a --unbuffered | tr -d []
+	lv_field "$1" "$2" -a --unbuffered | tr -d '[]'
 }
 
 lv_tree_devices_() {
diff --git a/test/lib/lvm_vdo_wrapper.sh b/test/lib/lvm_vdo_wrapper.sh
index d90ba8d42..bcc3781f7 100755
--- a/test/lib/lvm_vdo_wrapper.sh
+++ b/test/lib/lvm_vdo_wrapper.sh
@@ -87,8 +87,10 @@ local vdo_maxDiscardSize=${vdo_maxDiscardSize-4K}
 local vdo_name=${vdo_name-VDONAME}
 local vdo_physicalThreads=${vdo_physicalThreads-1}
 local vdo_slabSize=${vdo_slabSize-2G}
-local vdo_uuid="VDO-$(uuidgen || echo \"f7a3ecdc-40a0-4e43-814c-4a7039a75de4\")"
 local vdo_writePolicy=${vdo_writePolicy-auto}
+local vdo_uuid
+
+vdo_uuid="VDO-$(uuidgen || echo \"f7a3ecdc-40a0-4e43-814c-4a7039a75de4\")"
 
 while [ "$#" -ne 0 ]
 do

