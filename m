From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:45 -0400
Subject: master - tests: aux.sh double quote
Message-ID: <201706292027.v5TKRjir026683@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72a58ce4b0f68f6e45ae30606fe5af21caa42b43
Commit:        72a58ce4b0f68f6e45ae30606fe5af21caa42b43
Parent:        191dadc623e6fe07c380744c5a88b29d0f868a30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 00:02:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

tests: aux.sh double quote

---
 test/lib/aux.sh |  132 +++++++++++++++++++++++++++---------------------------
 1 files changed, 66 insertions(+), 66 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6217c4c..680adb2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -217,7 +217,7 @@ prepare_lvmetad() {
 	local run_valgrind=
 	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
-	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
+	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
 
 	# Avoid reconfiguring, if already set to use_lvmetad
 	(grep use_lvmetad CONFIG_VALUES 2>/dev/null | tail -n 1 | grep -q 1) || \
@@ -226,7 +226,7 @@ prepare_lvmetad() {
 	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
 	echo "preparing lvmetad..."
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
-		${LVM_TEST_LVMETAD_DEBUG_OPTS--l all} "$@" &
+		"${LVM_TEST_LVMETAD_DEBUG_OPTS--l all}" "$@" &
 	echo $! > LOCAL_LVMETAD
 	while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
 	echo ok
@@ -256,7 +256,7 @@ lvmetad_dump() {
 notify_lvmetad() {
 	if test -e LOCAL_LVMETAD; then
 		# Ignore results here...
-		LVM_LOG_FILE_EPOCH= pvscan --cache "$@" || true
+		LVM_LOG_FILE_EPOCH="" pvscan --cache "$@" || true
 		rm -f debug.log
 	fi
 }
@@ -271,7 +271,7 @@ prepare_lvmpolld() {
 	local run_valgrind=
 	test "${LVM_VALGRIND_LVMPOLLD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
-	kill_sleep_kill_ LOCAL_LVMPOLLD ${LVM_VALGRIND_LVMPOLLD:-0}
+	kill_sleep_kill_ LOCAL_LVMPOLLD "${LVM_VALGRIND_LVMPOLLD:-0}"
 
 	echo "preparing lvmpolld..."
 	$run_valgrind lvmpolld -f "$@" -s "$TESTDIR/lvmpolld.socket" -B "$TESTDIR/lib/lvm" -l all &
@@ -332,7 +332,7 @@ prepare_lvmdbusd() {
 	# Copy the needed file to run on the system bus if it doesn't
 	# already exist
 	if [ ! -f /etc/dbus-1/system.d/com.redhat.lvmdbus1.conf ]; then
-		install -m 644 $abs_top_builddir/scripts/com.redhat.lvmdbus1.conf /etc/dbus-1/system.d/
+		install -m 644 "$abs_top_builddir/scripts/com.redhat.lvmdbus1.conf" /etc/dbus-1/system.d/
 	fi
 
 	echo "preparing lvmdbusd..."
@@ -369,10 +369,10 @@ prepare_thin_metadata() {
 	local nr_data_blocks=${4:-3200}
 	local i
 
-	echo '<superblock uuid="" time="1" transaction="'$transaction_id'" data_block_size="'$data_block_size'" nr_data_blocks="'$nr_data_blocks'">'
-	for i in $(seq 1 $devices)
+	echo '<superblock uuid="" time="1" transaction="'"$transaction_id"'" data_block_size="'"$data_block_size"'" nr_data_blocks="'"$nr_data_blocks"'">'
+	for i in $(seq 1 "$devices")
 	do
-		echo ' <device dev_id="'$i'" mapped_blocks="37" transaction="'$i'" creation_time="0" snap_time="1">'
+		echo ' <device dev_id="'"$i"'" mapped_blocks="37" transaction="'"$i"'" creation_time="0" snap_time="1">'
 		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
 		echo ' </device>'
 	done
@@ -418,13 +418,13 @@ teardown_devs_prefixed() {
 	done
 	wait
 	finish_udev_transaction
-	test $need_udev_wait -eq 0 || udev_wait
+	test "$need_udev_wait" -eq 0 || udev_wait
 
 	if test -f REMOVE_FAILED; then
 		local num_devs
 		local num_remaining_devs=999
 		while num_devs=$(dm_table | grep "$prefix" | wc -l) && \
-		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
+		    test "$num_devs" -lt "$num_remaining_devs" -a "$num_devs" -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			for dm in $(dm_info name --sort open,-minor | grep "$prefix") ; do
@@ -449,8 +449,8 @@ teardown_devs() {
 	if test -f SCSI_DEBUG_DEV; then
 		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || modprobe -r scsi_debug
 	else
-		test ! -f LOOP || losetup -d $(< LOOP) || true
-		test ! -f LOOPFILE || rm -f $(< LOOPFILE)
+		test ! -f LOOP || losetup -d "$(< LOOP)" || true
+		test ! -f LOOPFILE || rm -f "$(< LOOPFILE)"
 	fi
 
 	not diff LOOP BACKING_DEV >/dev/null 2>&1 || rm -f BACKING_DEV
@@ -462,7 +462,7 @@ teardown_devs() {
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
 			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
-			for i in "${stray_loops[@]}" ; do test ! -b $i || losetup -d $i || true ; done
+			for i in "${stray_loops[@]}" ; do test ! -b "$i" || losetup -d "$i" || true ; done
 			# Leave test when udev processed all removed devices
 			udev_wait
 		}
@@ -472,14 +472,14 @@ teardown_devs() {
 kill_sleep_kill_() {
 	pidfile=$1
 	slow=$2
-	if test -s $pidfile ; then
-		pid=$(< $pidfile)
-		rm -f $pidfile
-		kill -TERM $pid 2>/dev/null || return 0
-		if test $slow -eq 0 ; then sleep .1 ; else sleep 1 ; fi
-		kill -KILL $pid 2>/dev/null || true
+	if test -s "$pidfile" ; then
+		pid=$(< "$pidfile")
+		rm -f "$pidfile"
+		kill -TERM "$pid" 2>/dev/null || return 0
+		if test "$slow" -eq 0 ; then sleep .1 ; else sleep 1 ; fi
+		kill -KILL "$pid" 2>/dev/null || true
 		wait=0
-		while ps $pid > /dev/null && test $wait -le 10; do
+		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .5
 			wait=$(($wait + 1))
 		done
@@ -503,7 +503,7 @@ kill_tagged_processes() {
 	print_procs_by_tag_ "$@" | while read -r pid wait; do
 		if test -n "$pid" ; then
 			echo "Killing tagged process: $pid ${wait:0:120}..."
-			kill -TERM $pid 2>/dev/null || true
+			kill -TERM "$pid" 2>/dev/null || true
 		fi
 		pids="$pids $pid"
 	done
@@ -511,11 +511,11 @@ kill_tagged_processes() {
 	# wait if process exited and eventually -KILL
 	wait=0
 	for pid in $pids ; do
-		while ps $pid > /dev/null && test $wait -le 10; do
+		while ps "$pid" > /dev/null && test "$wait" -le 10; do
 			sleep .2
 			wait=$(($wait + 1))
 		done
-		test $wait -le 10 || kill -KILL $pid 2>/dev/null || true
+		test "$wait" -le 10 || kill -KILL "$pid" 2>/dev/null || true
 	done
 }
 
@@ -542,7 +542,7 @@ teardown() {
 		killall -9 lvmlockd || true
 	fi
 
-	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
+	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
 
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
@@ -550,8 +550,8 @@ teardown() {
 		if echo "$(dm_info suspended,name)" | grep -q "^Suspended:.*$prefix" ; then
 			echo "Skipping vgremove, suspended devices detected."
 		else
-			vgremove -ff $cfg  \
-			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log strace.log
+			vgremove -ff "$cfg"  \
+			"$vg" "$vg1" "$vg2" "$vg3" "$vg4" &>/dev/null || rm -f debug.log strace.log
 		fi
 	}
 
@@ -559,15 +559,15 @@ teardown() {
 
 	echo -n .
 
-	kill_sleep_kill_ LOCAL_LVMPOLLD ${LVM_VALGRIND_LVMPOLLD:-0}
+	kill_sleep_kill_ LOCAL_LVMPOLLD "${LVM_VALGRIND_LVMPOLLD:-0}"
 
 	echo -n .
 
-	kill_sleep_kill_ LOCAL_CLVMD ${LVM_VALGRIND_CLVMD:-0}
+	kill_sleep_kill_ LOCAL_CLVMD "${LVM_VALGRIND_CLVMD:-0}"
 
 	echo -n .
 
-	kill_sleep_kill_ LOCAL_DMEVENTD ${LVM_VALGRIND_DMEVENTD:-0}
+	kill_sleep_kill_ LOCAL_DMEVENTD "${LVM_VALGRIND_DMEVENTD:-0}"
 
 	echo -n .
 
@@ -668,7 +668,7 @@ prepare_scsi_debug_dev() {
 	# NOTE: it will _never_ make sense to pass num_tgts param;
 	# last param wins.. so num_tgts=1 is imposed
 	touch SCSI_DEBUG_DEV
-	modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || skip
+	modprobe scsi_debug dev_size_mb="$DEV_SIZE" $SCSI_DEBUG_PARAMS num_tgts=1 || skip
 	
 	for i in {1..20} ; do
 		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
@@ -678,7 +678,7 @@ prepare_scsi_debug_dev() {
 	test -b "$DEBUG_DEV" || return 1 # should not happen
 
 	# Create symlink to scsi_debug device in $DM_DEV_DIR
-	SCSI_DEBUG_DEV="$DM_DEV_DIR/$(basename $DEBUG_DEV)"
+	SCSI_DEBUG_DEV="$DM_DEV_DIR/$(basename "$DEBUG_DEV")"
 	echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
 	echo "$SCSI_DEBUG_DEV" > BACKING_DEV
 	# Setting $LOOP provides means for prepare_devs() override
@@ -713,7 +713,7 @@ prepare_md_dev() {
 		mddev=/dev/md/md_lvm_test0 || \
 		mddev=/dev/md_lvm_test0
 
-	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --bitmap=internal $coption=$rchunk --raid-devices=$rdevs "${@:4}" || {
+	mdadm --create --metadata=1.0 "$mddev" --auto=md --level "$level" --bitmap=internal "$coption"="$rchunk" --raid-devices="$rdevs" "${@:4}" || {
 		# Some older 'mdadm' version managed to open and close devices internaly
 		# and reporting non-exclusive access on such device
 		# let's just skip the test if this happens.
@@ -735,7 +735,7 @@ prepare_md_dev() {
 		echo "$DM_DEV_DIR/md_lvm_test0" ;;
 	esac > MD_DEV_PV
 	echo "$mddev" > MD_DEV
-	notify_lvmetad $(< MD_DEV_PV)
+	notify_lvmetad "$(< MD_DEV_PV)"
 	printf "%s\n" "${@:4}" > MD_DEVICES
 	for mddev in "${@:4}"; do
 		notify_lvmetad "$mddev"
@@ -750,8 +750,8 @@ cleanup_md_dev() {
 
 	udev_wait
 	mdadm --stop "$dev" || true
-	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename $dev)"
-	notify_lvmetad $(< MD_DEV_PV)
+	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/$(basename "$dev")"
+	notify_lvmetad "$(< MD_DEV_PV)"
 	udev_wait  # wait till events are process, not zeroing to early
 	for dev in $(< MD_DEVICES); do
 		mdadm --zero-superblock "$dev" || true
@@ -801,7 +801,7 @@ prepare_devs() {
 	local count=0
 	rm -f CREATE_FAILED
 	init_udev_transaction
-	for i in $(seq 1 $n); do
+	for i in $(seq 1 "$n"); do
 		local name="${PREFIX}$pvname$i"
 		local dev="$DM_DEV_DIR/mapper/$name"
 		DEVICES[$count]=$dev
@@ -821,7 +821,7 @@ prepare_devs() {
 	fi
 
 	# non-ephemeral devices need to be cleared between tests
-	test -f LOOP || for d in ${DEVICES[@]}; do
+	test -f LOOP || for d in "${DEVICES[@]}"; do
 		blkdiscard "$d" 2>/dev/null || true
 		# ensure disk header is always zeroed
 		dd if=/dev/zero of="$d" bs=32k count=1
@@ -878,7 +878,7 @@ common_dev_() {
 
 	read pos size type pvdev offset < "$name.table"
 
-	for fromlen in ${offsets[@]}; do
+	for fromlen in "${offsets[@]}"; do
 		from=${fromlen%%:*}
 		len=${fromlen##*:}
 		test -n "$len" || len=$(($size - $from))
@@ -955,8 +955,8 @@ disable_dev() {
 	done
 
 	test -n "$silent" || for num in $notify; do
-		notify_lvmetad --major $(echo $num | sed -e "s,:.*,,") \
-		               --minor $(echo $num | sed -e "s,.*:,,")
+		notify_lvmetad --major "$(echo "$num" | sed -e "s,:.*,,")" \
+		               --minor "$(echo "$num" | sed -e "s,.*:,,")"
 	done
 }
 
@@ -1057,13 +1057,13 @@ prepare_vg() {
 	teardown_devs
 
 	prepare_devs "$@"
-	vgcreate -s 512K $vg "${DEVICES[@]}"
+	vgcreate -s 512K "$vg" "${DEVICES[@]}"
 }
 
 extend_filter() {
 	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for rx in "$@"; do
-		filter=$(echo $filter | sed -e "s:\[:[ \"$rx\", :")
+		filter=$(echo "$filter" | sed -e "s:\[:[ \"$rx\", :")
 	done
 	lvmconf "$filter"
 }
@@ -1074,16 +1074,16 @@ extend_filter_LVMTEST() {
 
 hide_dev() {
 	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
-	for dev in $@; do
-		filter=$(echo $filter | sed -e "s:\[:[ \"r|$dev|\", :")
+	for dev in "$@"; do
+		filter=$(echo "$filter" | sed -e "s:\[:[ \"r|$dev|\", :")
 	done
 	lvmconf "$filter"
 }
 
 unhide_dev() {
 	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
-	for dev in $@; do
-		filter=$(echo $filter | sed -e "s:\"r|$dev|\", ::")
+	for dev in "$@"; do
+		filter=$(echo "$filter" | sed -e "s:\"r|$dev|\", ::")
 	done
 	lvmconf "$filter"
 }
@@ -1096,9 +1096,9 @@ mkdev_md5sum() {
 
 generate_config() {
 	if test -n "$profile_name"; then
-		config_values=PROFILE_VALUES_$profile_name
-		config=PROFILE_$profile_name
-		touch $config_values
+		config_values="PROFILE_VALUES_$profile_name"
+		config="PROFILE_$profile_name"
+		touch "$config_values"
 	else
 		config_values=CONFIG_VALUES
 		config=CONFIG
@@ -1201,11 +1201,11 @@ EOF
 	# read sequential list and put into associative array
 	while IFS=$IFS_NL read -r v; do
 		# trim white-space-chars via echo when inserting
-		CONF[$(echo ${v%%[={]*})]=${v#*/}
+		CONF["$(echo ${v%%[={]*})"]=${v#*/}
 	done < "$config_values"
 
 	# sort by section and iterate through them
-	printf "%s\n" ${!CONF[@]} | sort | while read -r v ; do
+	printf "%s\n" "${!CONF[@]}" | sort | while read -r v ; do
 		sec=${v%%/*} # split on section'/'param_name
 		test "$sec" = "$last_sec" || {
 			test -z "$last_sec" || echo "}"
@@ -1230,14 +1230,14 @@ profileconf() {
 	profile_name="$1"
 	shift
 	generate_config "$@"
-	mkdir -p $pdir
+	mkdir -p "$pdir"
 	mv -f "PROFILE_$profile_name" "$pdir/$profile_name.profile"
 }
 
 prepare_profiles() {
 	local pdir="$LVM_SYSTEM_DIR/profile"
-	mkdir -p $pdir
-	for profile_name in $@; do
+	mkdir -p "$pdir"
+	for profile_name in "$@"; do
 		test -L "lib/$profile_name.profile" || skip
 		cp "lib/$profile_name.profile" "$pdir/$profile_name.profile"
 	done
@@ -1328,7 +1328,7 @@ udev_wait() {
 wait_for_sync() {
 	local i
 	for i in {1..100} ; do
-		check in_sync $1 $2 $3 && return
+		check in_sync "$1" "$2" "$3" && return
 		sleep .2
 	done
 
@@ -1492,7 +1492,7 @@ have_readline() {
 
 have_multi_core() {
 	which nproc &>/dev/null || return 0
-	[ $(nproc) -ne 1 ]
+	[ "$(nproc)" -ne 1 ]
 }
 
 dmsetup_wrapped() {
@@ -1515,8 +1515,8 @@ awk_parse_init_count_in_lvmpolld_dump() {
 }
 
 check_lvmpolld_init_rq_count() {
-	local ret=$(awk -v vvalue="$2" -v vkey=${3:-lvname} "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
-	test $ret -eq $1 || {
+	local ret=$(awk -v vvalue="$2" -v vkey="${3:-lvname}" "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
+	test "$ret" -eq "$1" || {
 		echo "check_lvmpolld_init_rq_count failed. Expected $1, got $ret"
 		return 1
 	}
@@ -1529,23 +1529,23 @@ wait_pvmove_lv_ready() {
 	if [ -e LOCAL_LVMPOLLD ]; then
 		local lvid
 		while : ; do
-			test $retries -le 0 && die "Waiting for lvmpolld timed out"
+			test "$retries" -le 0 && die "Waiting for lvmpolld timed out"
 			test -n "$lvid" || {
-				lvid=$(get lv_field ${1//-/\/} vg_uuid,lv_uuid -a 2>/dev/null)
+				lvid=$(get lv_field "${1//-/\/}" vg_uuid,lv_uuid -a 2>/dev/null)
 				lvid=${lvid//\ /}
 				lvid=${lvid//-/}
 			}
 			test -z "$lvid" || {
 				lvmpolld_dump > lvmpolld_dump.txt
-				! check_lvmpolld_init_rq_count 1 $lvid lvid || break;
+				! check_lvmpolld_init_rq_count 1 "$lvid" lvid || break;
 			}
 			sleep .1
 			retries=$((retries-1))
 		done
 	else
 		while : ; do
-			test $retries -le 0 && die "Waiting for pvmove LV to get activated has timed out"
-			dmsetup info -c -o tables_loaded $1 > out 2>/dev/null|| true;
+			test "$retries" -le 0 && die "Waiting for pvmove LV to get activated has timed out"
+			dmsetup info -c -o tables_loaded "$1" >out 2>/dev/null|| true;
 			not grep Live out >/dev/null || break
 			sleep .1
 			retries=$((retries-1))
@@ -1560,11 +1560,11 @@ hold_device_open() {
 	local lvname=$2
 	local sec=${3:-20} # default 20sec
 
-	sleep $sec < "$DM_DEV_DIR/$vgname/$lvname" >/dev/null 2>&1 &
+	sleep "$sec" < "$DM_DEV_DIR/$vgname/$lvname" >/dev/null 2>&1 &
 	SLEEP_PID=$!
 	# wait till device is openned
 	for i in $(seq 1 50) ; do
-		if test "$(dmsetup info --noheadings -c -o open $vgname-$lvname)" -ne 0 ; then
+		if test "$(dmsetup info --noheadings -c -o open "$vgname"-"$lvname")" -ne 0 ; then
 			echo "$SLEEP_PID"
 			return
 		fi
@@ -1577,7 +1577,7 @@ hold_device_open() {
 # return total memory size in kB units
 total_mem() {
 	while IFS=":" read -r a b ; do
-		case "$a" in MemTotal*) echo ${b%% kB} ; break ;; esac
+		case "$a" in MemTotal*) echo "${b%% kB}" ; break ;; esac
 	done < /proc/meminfo
 }
 


