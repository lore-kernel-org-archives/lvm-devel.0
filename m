From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 12:59:03 -0000
Subject: LVM2/test/lib aux.sh lvm-wrapper.sh
Message-ID: <20120316125903.23177.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 12:59:02

Modified files:
	test/lib       : aux.sh lvm-wrapper.sh 

Log message:
	Update aux.sh lvmwrapper
	
	Indent
	
	Add valgrind support:
	env LVM_TEST_VALGRIND={0123} (the higher level, more commands tested)
	env LVM_TEST_CLVMD=1   runs clvmd within valgrind.
	env VALGRIND  script name executed for each lvm command (def. is valg).
	
	Smarted teardown - should minimize occurence of left dev entries
	(using dmsetup remove -f only as last resort)
	sort removed devices by open count before actual removal
	
	Use "" around string that may contain spaces.
	
	Set log/verbose and activation/retry_deactivation to defined value.
	
	Remove  debug.log after successful lvm command (easier to check output).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/lvm-wrapper.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/lib/aux.sh	2012/03/16 12:57:28	1.43
+++ LVM2/test/lib/aux.sh	2012/03/16 12:59:02	1.44
@@ -11,69 +11,67 @@
 
 . lib/utils
 
+run_valgrind() {
+	# Execute script which may use $TESTNAME for creating individal
+	# log files for each execute command
+	exec "${VALGRIND:-valg}" "$@"
+}
+
 prepare_clvmd() {
-	if test -z "$LVM_TEST_LOCKING" || test "$LVM_TEST_LOCKING" -ne 3 ; then
-		return 0 # not needed
-	fi
+	test "${LVM_TEST_LOCKING:-0}" -ne 3 && return # not needed
 
 	if pgrep clvmd ; then
 		echo "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
-                skip
+		skip
 	fi
 
 	# skip if we don't have our own clvmd...
-	(which clvmd | grep $abs_builddir) || skip
+	(which clvmd 2>/dev/null | grep "$abs_builddir") || skip
 
 	# skip if we singlenode is not compiled in
-	(clvmd --help 2>&1 | grep "Available cluster managers" | grep singlenode) || skip
-
-	lvmconf "activation/monitoring = 1"
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep "singlenode") || skip
 
-	clvmd -Isinglenode -d 1 &
-	LOCAL_CLVMD="$!"
-
-	# check that it is really running now
+#	lvmconf "activation/monitoring = 1"
+	local run_valgrind=
+	test -z "$LVM_VALGRIND_CLVMD" || run_valgrind="run_valgrind"
+	$run_valgrind lib/clvmd -Isinglenode -d 1 -f &
+	local local_clvmd=$!
 	sleep .1
-	ps $LOCAL_CLVMD || die
-	echo "$LOCAL_CLVMD" > LOCAL_CLVMD
+	# extra sleep for slow valgrind
+	test -z "$LVM_VALGRIND_CLVMD" || sleep 5
+	# check that it is really running now
+	ps $local_clvmd || die
+	echo $local_clvmd > LOCAL_CLVMD
 }
 
 prepare_dmeventd() {
 	if pgrep dmeventd ; then
 		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
-                touch SKIP_THIS_TEST
-		exit 1
+		skip
 	fi
 
 	# skip if we don't have our own dmeventd...
-	(which dmeventd | grep $abs_builddir) || {
-            touch SKIP_THIS_TEST
-            exit 1
-        }
+	(which dmeventd 2>/dev/null | grep "$abs_builddir") || skip
 
-        lvmconf "activation/monitoring = 1"
+	lvmconf "activation/monitoring = 1"
 
 	dmeventd -f "$@" &
-	echo "$!" > LOCAL_DMEVENTD
+	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
 	sleep 1
 }
 
 prepare_lvmetad() {
-	echo preparing lvmetad...
-
 	# skip if we don't have our own lvmetad...
-	(which lvmetad | grep $abs_builddir) || {
-		touch SKIP_THIS_TEST
-		exit 1
-	}
+	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip
 
 	lvmconf "global/use_lvmetad = 1"
 	lvmconf "devices/md_component_detection = 0"
 
-	lvmetad -f "$@" -s $TESTDIR/lvmetad.socket &
-	echo "$!" > LOCAL_LVMETAD
+	echo "preparing lvmetad..."
+	lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" &
+	echo $! > LOCAL_LVMETAD
 
 	sleep 1
 }
@@ -85,120 +83,136 @@
 }
 
 teardown_devs() {
+	vgremove -ff $vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
+
 	# Delete any remaining dm/udev semaphores
 	teardown_udev_cookies
 
-	test -n "$PREFIX" && {
-		rm -rf $TESTDIR/dev/$PREFIX*
+	test -z "$PREFIX" || {
+		rm -rf "$TESTDIR/dev/$PREFIX"*
 
+		# Try unmount opened devices first
+		for s in $(dmsetup info -c -o open,name --sort -open --noheading | grep "$PREFIX"); do
+			test "${s%%:*}" -gt 0 || break
+			umount -fl "$DM_DEV_DIR/mapper/${s#[0..9]*:}" &>/dev/null || true
+		done
+
+		# Remove devices, start with closed (sorted by open count)
 		init_udev_transaction
-		while dmsetup table | grep -q $PREFIX; do
-			for s in `dmsetup info -c -o name --noheading | grep $PREFIX`; do
-				umount -fl $DM_DEV_DIR/mapper/$s >& /dev/null || true
-				dmsetup remove -f $s >& /dev/null || true
-			done
+		for s in $(dmsetup info -c -o name --sort open --noheading | grep "$PREFIX"); do
+			dmsetup remove "$s" &>/dev/null || true
 		done
 		finish_udev_transaction
+		udev_wait
 
+		# Brute force, and without udev transaction
+		while dmsetup table | grep -q "$PREFIX"; do
+			for s in $(dmsetup info -c -o name --sort open --noheading | grep "$PREFIX"); do
+				umount -fl "$DM_DEV_DIR/mapper/$s" &>/dev/null || true
+				dmsetup remove -f "$s" &>/dev/null || true
+			done
+			udev_wait
+		done
 	}
 
-	udev_wait
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
 		modprobe -r scsi_debug
 	else
-		test -f LOOP && losetup -d $(cat LOOP)
-		test -f LOOPFILE && rm -f $(cat LOOPFILE)
+		test ! -f LOOP || losetup -d $(cat LOOP)
+		test ! -f LOOPFILE || rm -f $(cat LOOPFILE)
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
-	test -n "$COMMON_PREFIX" && {
+	test -z "$COMMON_PREFIX" || {
 		# Resume any linears to be sure we do not deadlock
-		STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
+		STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep "$COMMON_PREFIX" | cut -d' '  -f 1)
 		for dm in $STRAY_DEVS ; do
 			# FIXME: only those really suspended
-			echo dmsetup resume $dm
-			dmsetup resume $dm || true
+			echo "dmsetup resume \"$dm\""
+			dmsetup resume "$dm" || true
 		done
 
-		STRAY_MOUNTS=`mount | grep $COMMON_PREFIX | cut -d\  -f1`
+		STRAY_MOUNTS=$(mount | grep "$COMMON_PREFIX" | cut -d' ' -f1)
 		if test -n "$STRAY_MOUNTS"; then
 			echo "Removing stray mounted devices containing $COMMON_PREFIX:"
-			mount | grep $COMMON_PREFIX
-			umount -fl $STRAY_MOUNTS || true
-			sleep 2
+			mount | grep "$COMMON_PREFIX"
+			umount -fl "$STRAY_MOUNTS" || true
+			udev_wait
 		fi
 
 		init_udev_transaction
 		NUM_REMAINING_DEVS=999
-		while NUM_DEVS=`dmsetup table | grep ^$COMMON_PREFIX | wc -l` && \
+		while NUM_DEVS=$(dmsetup table | grep "^$COMMON_PREFIX" | wc -l) && \
 		    test $NUM_DEVS -lt $NUM_REMAINING_DEVS -a $NUM_DEVS -ne 0; do
 			echo "Removing $NUM_DEVS stray mapped devices with names beginning with $COMMON_PREFIX:"
-			STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
-			dmsetup info -c | grep ^$COMMON_PREFIX
+			STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep "$COMMON_PREFIX" | cut -d' '  -f 1)
+			dmsetup info -c | grep "^$COMMON_PREFIX"
 			for dm in $STRAY_DEVS ; do
-				echo dmsetup remove $dm
-				dmsetup remove -f $dm || true
+				echo "dmsetup remove -f \"$dm\""
+				dmsetup remove -f "$dm" || true
 			done
 			NUM_REMAINING_DEVS=$NUM_DEVS
 		done
 		finish_udev_transaction
 		udev_wait
 
-        	STRAY_LOOPS=`losetup -a | grep $COMMON_PREFIX | cut -d: -f1`
-        	if test -n "$STRAY_LOOPS"; then
-                	echo "Removing stray loop devices containing $COMMON_PREFIX:"
-                	losetup -a | grep $COMMON_PREFIX
-                	losetup -d $STRAY_LOOPS || true
-        	fi
+		STRAY_LOOPS=$(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1)
+		if test -n "$STRAY_LOOPS"; then
+			echo "Removing stray loop devices containing $COMMON_PREFIX:"
+			losetup -a | grep "$COMMON_PREFIX"
+			losetup -d "$STRAY_LOOPS" || true
+		fi
 	}
 }
 
 teardown() {
-    echo -n "## teardown..."
+	echo -n "## teardown..."
 
-    test -f LOCAL_CLVMD && {
-	kill "$(cat LOCAL_CLVMD)"
-	sleep .1
-	kill -9 "$(cat LOCAL_CLVMD)" || true
-    }
+	test -f LOCAL_CLVMD && {
+		kill -INT "$(cat LOCAL_CLVMD)"
+		test -z "$LVM_VALGRIND_CLVMD" || sleep 1
+		sleep .1
+		kill -9 "$(cat LOCAL_CLVMD)" || true
+	}
+
+	echo -n .
 
-    echo -n .
+	test -f LOCAL_DMEVENTD && kill -9 $(cat LOCAL_DMEVENTD) || true
+	test -f LOCAL_LVMETAD && kill -9 $(cat LOCAL_LVMETAD) || true
 
-    test -f LOCAL_DMEVENTD && kill -9 "$(cat LOCAL_DMEVENTD)"
-    test -f LOCAL_LVMETAD && kill -9 "$(cat LOCAL_LVMETAD)"
+	echo -n .
 
-    echo -n .
+	test -d "$DM_DEV_DIR/mapper" && teardown_devs
 
-    test -d $DM_DEV_DIR/mapper && teardown_devs
+	echo -n .
 
-    echo -n .
+	test -n "$TESTDIR" && {
+		cd "$TESTOLDPWD"
+		rm -rf "$TESTDIR" || echo BLA
+	}
 
-    test -n "$TESTDIR" && {
-	cd $OLDPWD
-	rm -rf $TESTDIR || echo BLA
-    }
+	echo "ok"
 
-    echo "ok"
+	test -z "$RUNNING_DMEVENTD" && not pgrep dmeventd &>/dev/null
 }
 
 make_ioerror() {
 	echo 0 10000000 error | dmsetup create -u TEST-ioerror ioerror
-	ln -s $DM_DEV_DIR/mapper/ioerror $DM_DEV_DIR/ioerror
+	ln -s "$DM_DEV_DIR/mapper/ioerror" "$DM_DEV_DIR/ioerror"
 }
 
 prepare_loop() {
-	size=$1
-	test -n "$size" || size=32
+	local size=${1=32}
 
-        echo -n "## preparing loop device..."
+	echo -n "## preparing loop device..."
 
 	# skip if prepare_scsi_debug_dev() was used
-	if [ -f "SCSI_DEBUG_DEV" -a -f "LOOP" ]; then
-                echo "(skipped)"
+	if test -f SCSI_DEBUG_DEV -a -f LOOP ; then
+		echo "(skipped)"
 		return 0
 	fi
 
@@ -206,110 +220,100 @@
 	test -n "$DM_DEV_DIR"
 
 	for i in 0 1 2 3 4 5 6 7; do
-		test -e $DM_DEV_DIR/loop$i || mknod $DM_DEV_DIR/loop$i b 7 $i
+		test -e "$DM_DEV_DIR/loop$i" || mknod "$DM_DEV_DIR/loop$i" b 7 $i
 	done
 
-        echo -n .
+	echo -n .
 
-	LOOPFILE="$PWD/test.img"
+	local LOOPFILE="$PWD/test.img"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size-1)) 2> /dev/null
-	if LOOP=`losetup -s -f "$LOOPFILE" 2>/dev/null`; then
+	if LOOP=$(losetup -s -f "$LOOPFILE" 2>/dev/null); then
 		:
-	elif LOOP=`losetup -f` && losetup $LOOP "$LOOPFILE"; then
+	elif LOOP=$(losetup -f) && losetup "$LOOP" "$LOOPFILE"; then
 		# no -s support
 		:
 	else
-		# no -f support 
+		# no -f support
 		# Iterate through $DM_DEV_DIR/loop{,/}{0,1,2,3,4,5,6,7}
 		for slash in '' /; do
 			for i in 0 1 2 3 4 5 6 7; do
-				local dev=$DM_DEV_DIR/loop$slash$i
-				! losetup $dev >/dev/null 2>&1 || continue
+				local dev="$DM_DEV_DIR/loop$slash$i"
+				! losetup "$dev" >/dev/null 2>&1 || continue
 				# got a free
 				losetup "$dev" "$LOOPFILE"
 				LOOP=$dev
 				break
 			done
-			if [ -n "$LOOP" ]; then 
-				break
-			fi
+			test -z "$LOOP" || break
 		done
 	fi
 	test -n "$LOOP" # confirm or fail
-        echo "$LOOP" > LOOP
-        echo "ok ($LOOP)"
+	echo "$LOOP" > LOOP
+	echo "ok ($LOOP)"
 }
 
 # A drop-in replacement for prepare_loop() that uses scsi_debug to create
 # a ramdisk-based SCSI device upon which all LVM devices will be created
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
-prepare_scsi_debug_dev()
-{
-    local DEV_SIZE="$1"
-    shift
-    local SCSI_DEBUG_PARAMS="$@"
-
-    test -f "SCSI_DEBUG_DEV" && return 0
-    test -z "$LOOP"
-    test -n "$DM_DEV_DIR"
-
-    # Skip test if awk isn't available (required for get_sd_devs_)
-    which awk || skip
-
-    # Skip test if scsi_debug module is unavailable or is already in use
-    modprobe --dry-run scsi_debug || skip
-    lsmod | grep -q scsi_debug && skip
-
-    # Create the scsi_debug device and determine the new scsi device's name
-    # NOTE: it will _never_ make sense to pass num_tgts param;
-    # last param wins.. so num_tgts=1 is imposed
-    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || skip
-    sleep 2 # allow for async Linux SCSI device registration
-
-    local DEBUG_DEV=/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)
-    [ -b $DEBUG_DEV ] || exit 1 # should not happen
-
-    # Create symlink to scsi_debug device in $DM_DEV_DIR
-    SCSI_DEBUG_DEV="$DM_DEV_DIR/$(basename $DEBUG_DEV)"
-    echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
-    echo "$SCSI_DEBUG_DEV" > LOOP
-    # Setting $LOOP provides means for prepare_devs() override
-    test "$LVM_TEST_DEVDIR" != "/dev" && ln -snf $DEBUG_DEV $SCSI_DEBUG_DEV
-    return 0
-}
+prepare_scsi_debug_dev() {
+	local DEV_SIZE=$1
+	local SCSI_DEBUG_PARAMS=${@:2}
 
-cleanup_scsi_debug_dev()
-{
-    aux teardown_devs
-    rm -f SCSI_DEBUG_DEV
-    rm -f LOOP
+	test -f "SCSI_DEBUG_DEV" && return 0
+	test -z "$LOOP"
+	test -n "$DM_DEV_DIR"
+
+	# Skip test if awk isn't available (required for get_sd_devs_)
+	which awk || skip
+
+	# Skip test if scsi_debug module is unavailable or is already in use
+	modprobe --dry-run scsi_debug || skip
+	lsmod | grep -q scsi_debug && skip
+
+	# Create the scsi_debug device and determine the new scsi device's name
+	# NOTE: it will _never_ make sense to pass num_tgts param;
+	# last param wins.. so num_tgts=1 is imposed
+	modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || skip
+	sleep 2 # allow for async Linux SCSI device registration
+
+	local DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
+	test -b "$DEBUG_DEV" || return 1 # should not happen
+
+	# Create symlink to scsi_debug device in $DM_DEV_DIR
+	SCSI_DEBUG_DEV="$DM_DEV_DIR/$(basename $DEBUG_DEV)"
+	echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
+	echo "$SCSI_DEBUG_DEV" > LOOP
+	# Setting $LOOP provides means for prepare_devs() override
+	test "$LVM_TEST_DEVDIR" != "/dev" && ln -snf "$DEBUG_DEV" "$SCSI_DEBUG_DEV"
+}
+
+cleanup_scsi_debug_dev() {
+	aux teardown_devs
+	rm -f SCSI_DEBUG_DEV LOOP
 }
 
 prepare_devs() {
-	local n="$1"
-	test -z "$n" && n=3
-	local devsize="$2"
-	test -z "$devsize" && devsize=34
-	local pvname="$3"
-	test -z "$pvname" && pvname="pv"
+	local n=${1:-3}
+	local devsize=${2:-34}
+	local pvname=${3:-pv}
 
 	prepare_loop $(($n*$devsize))
-        echo -n "## preparing $n devices..."
+	echo -n "## preparing $n devices..."
 
-	if ! loopsz=`blockdev --getsz $LOOP 2>/dev/null`; then
-  		loopsz=`blockdev --getsize $LOOP 2>/dev/null`
+	if ! loopsz=$(blockdev --getsz "$LOOP" 2>/dev/null); then
+		loopsz=$(blockdev --getsize "$LOOP" 2>/dev/null)
 	fi
 
 	local size=$(($loopsz/$n))
-        devs=
+	devs=
 
 	init_udev_transaction
-	for i in `seq 1 $n`; do
+	for i in $(seq 1 $n); do
 		local name="${PREFIX}$pvname$i"
 		local dev="$DM_DEV_DIR/mapper/$name"
 		devs="$devs $dev"
-		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
-		dmsetup create -u TEST-$name $name $name.table
+		echo 0 $size linear "$LOOP" $((($i-1)*$size)) > "$name.table"
+		dmsetup create -u "TEST-$name" "$name" "$name.table"
 	done
 	finish_udev_transaction
 
@@ -322,50 +326,47 @@
 	#	dmsetup table $name
 	#done
 
-        echo $devs > DEVICES
-        echo "ok"
+	echo $devs > DEVICES
+	echo "ok"
 }
 
 disable_dev() {
-
 	init_udev_transaction
 	for dev in "$@"; do
-	    maj=$(($(stat --printf=0x%t $dev)))
-	    min=$(($(stat --printf=0x%T $dev)))
-	    echo "disabling device $dev ($maj:$min)"
-            dmsetup remove -f $dev || true
-	    notify_lvmetad --major $maj --minor $min
+		maj=$(($(stat --printf=0x%t "$dev")))
+		min=$(($(stat --printf=0x%T "$dev")))
+		echo "Disabling device $dev ($maj:$min)"
+		dmsetup remove -f "$dev" || true
+		notify_lvmetad --major "$maj" --minor "$min"
 	done
 	finish_udev_transaction
 
 }
 
 enable_dev() {
-
 	init_udev_transaction
 	for dev in "$@"; do
-		local name=`echo "$dev" | sed -e 's,.*/,,'`
-		dmsetup create -u TEST-$name $name $name.table || dmsetup load $name $name.table
+		local name=$(echo "$dev" | sed -e 's,.*/,,')
+		dmsetup create -u "TEST-$name" "$name" "$name.table" || \
+			dmsetup load "$name" "$name.table"
 		# using device name (since device path does not exists yes with udev)
-		dmsetup resume $name
-		notify_lvmetad $dev
+		dmsetup resume "$name"
+		notify_lvmetad "$dev"
 	done
 	finish_udev_transaction
 }
 
 backup_dev() {
 	for dev in "$@"; do
-		dd if=$dev of=$dev.backup bs=1024
+		dd if="$dev" of="$dev.backup" bs=1024
 	done
 }
 
 restore_dev() {
 	for dev in "$@"; do
-		test -e $dev.backup || {
-			echo "Internal error: $dev not backed up, can't restore!"
-			exit 1
-		}
-		dd of=$dev if=$dev.backup bs=1024
+		test -e "$dev.backup" || \
+			die "Internal error: $dev not backed up, can't restore!"
+		dd of="$dev" if="$dev.backup" bs=1024
 	done
 }
 
@@ -375,23 +376,21 @@
 }
 
 prepare_vg() {
-	vgremove -ff $vg >& /dev/null || true
 	teardown_devs
 
 	prepare_pvs "$@"
 	vgcreate -c n $vg $devs
-	#pvs -v
 }
 
 lvmconf() {
-    if test -z "$LVM_TEST_LOCKING"; then LVM_TEST_LOCKING=1; fi
-    if test "$DM_DEV_DIR" = "/dev"; then
-	LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0};
-    else
-	LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-1};
-    fi
-    test -f CONFIG_VALUES || {
-        cat > CONFIG_VALUES <<-EOF
+	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
+	if test "$DM_DEV_DIR" = "/dev"; then
+	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0}
+	else
+	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-1}
+	fi
+	test -f CONFIG_VALUES || {
+            cat > CONFIG_VALUES <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
 devices/filter = [ "a/dev\\\\/mirror/", "a/dev\\\\/mapper\\\\/.*pv[0-9_]*$/", "r/.*/" ]
@@ -405,6 +404,8 @@
 log/file = "$TESTDIR/debug.log"
 log/overwrite = 1
 log/activation = 1
+log/verbose = 0
+activation/retry_deactivation = 1
 backup/backup = 0
 backup/archive = 0
 global/abort_on_internal_errors = 1
@@ -423,34 +424,34 @@
 activation/snapshot_autoextend_threshold = 50
 activation/monitoring = 0
 EOF
-    }
+	}
 
-    for v in "$@"; do
-        echo "$v" >> CONFIG_VALUES
-    done
-
-    rm -f CONFIG
-    for s in `cat CONFIG_VALUES | cut -f1 -d/ | sort | uniq`; do
-        echo "$s {" >> CONFIG
-        for k in `grep ^$s/ CONFIG_VALUES | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq`; do
-            grep "^$k" CONFIG_VALUES | tail -n 1 | sed -e "s,^$s/,    ," >> CONFIG
-        done
-        echo "}" >> CONFIG
-        echo >> CONFIG
-    done
-    mv -f CONFIG $TESTDIR/etc/lvm.conf
+	for v in "$@"; do
+	    echo "$v" >> CONFIG_VALUES
+	done
+
+	rm -f CONFIG
+	for s in $(cat CONFIG_VALUES | cut -f1 -d/ | sort | uniq); do
+		echo "$s {" >> CONFIG
+		for k in $(grep ^$s/ CONFIG_VALUES | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
+			grep "^$k" CONFIG_VALUES | tail -n 1 | sed -e "s,^$s/,	  ," >> CONFIG
+		done
+		echo "}" >> CONFIG
+		echo >> CONFIG
+	done
+        mv -f CONFIG $TESTDIR/etc/lvm.conf
 }
 
 apitest() {
 	t=$1
-        shift
-	test -x $abs_top_builddir/test/api/$t.t || skip
-	$abs_top_builddir/test/api/$t.t "$@"
+	shift
+	test -x "$abs_top_builddir/test/api/$t.t" || skip
+	"$abs_top_builddir/test/api/$t.t" "$@" && rm -f debug.log
 }
 
 api() {
-	test -x $abs_top_builddir/test/api/wrapper || skip
-	$abs_top_builddir/test/api/wrapper "$@"
+	test -x "$abs_top_builddir/test/api/wrapper" || skip
+	"$abs_top_builddir/test/api/wrapper" "$@" && rm -f debug.log
 }
 
 udev_wait() {
@@ -479,24 +480,25 @@
 	version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
 	version=${version##* v}
 	shift
-	major=$(echo $version | cut -d. -f1)
-	minor=$(echo $version | cut -d. -f2)
-	revision=$(echo $version | cut -d. -f3)
+	major=$(echo "$version" | cut -d. -f1)
+	minor=$(echo "$version" | cut -d. -f2)
+	revision=$(echo "$version" | cut -d. -f3)
 
 	test -z "$1" && return 0
-	test -z "$major" && return 1
+	test -n "$major" || return 1
 	test "$major" -gt "$1" && return 0
-	test "$major" -lt "$1" && return 1
+	test "$major" -eq "$1" || return 1
 	test -z "$2" && return 0
-	test -z "$minor" && return 1
+	test -n "$minor" || return 1
 	test "$minor" -gt "$2" && return 0
-	test "$minor" -lt "$2" && return 1
+	test "$minor" -eq "$2" || return 1
 	test -z "$4" && return 0
-	test -z "$revision" && return 1
-	test "$revision" -lt "$3" && return 1
+	test -n "$revision" || return 1
+	test "$revision" -eq "$3" || return 1
 }
 
 test -f DEVICES && devs=$(cat DEVICES)
 test -f LOOP && LOOP=$(cat LOOP)
 
+unset LVM_VALGRIND
 "$@"
--- LVM2/test/lib/lvm-wrapper.sh	2011/01/05 00:16:21	1.1
+++ LVM2/test/lib/lvm-wrapper.sh	2012/03/16 12:59:02	1.2
@@ -1,7 +1,32 @@
 #!/bin/sh
+# Copyright (C) 2011-2012 Red Hat, Inc.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . lib/paths
-cmd=$(echo ./$0|sed "s,.*/,,")
 
-test "$cmd" = lvm && exec "$abs_top_builddir/tools/lvm" "$@"
-exec "$abs_top_builddir/tools/lvm" "$cmd" "$@"
+CMD=${0##*/}
+test "$CMD" != lvm || unset CMD
+
+# Multiple level of LVM_VALGRIND support
+# the higher level the more commands are traced
+if test -n "$LVM_VALGRIND"; then
+	RUN_VALGRIND="aux run_valgrind";
+	case "$CMD" in
+	  lvs|pvs|vgs|vgck|vgscan)
+		test "$LVM_VALGRIND" -gt 2 || unset RUN_VALGRIND ;;
+	  pvcreate|pvremove|lvremove|vgcreate|vgremove)
+		test "$LVM_VALGRIND" -gt 1 || unset RUN_VALGRIND ;;
+	  *)
+		test "$LVM_VALGRIND" -gt 0 || unset RUN_VALGRIND ;;
+	esac
+fi
+
+$RUN_VALGRIND "$abs_top_builddir/tools/lvm" $CMD "$@" && \
+	rm -f debug.log # Remove log for successful command


