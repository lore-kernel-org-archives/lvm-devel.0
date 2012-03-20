From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Mar 2012 10:51:58 -0000
Subject: LVM2/test/lib aux.sh test.sh utils.sh
Message-ID: <20120320105158.7804.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-20 10:51:58

Modified files:
	test/lib       : aux.sh test.sh utils.sh 

Log message:
	Update testing scripts
	
	Make the teardown really usable - it will try down to remove all the left
	devices even from previous test runs
	(the only missing piece is probably proper mdadm teardown)
	Add few more local vars
	Try to setup PATH and LD_LIBRARY_PATH just once.
	Try shorter sleeps.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/lib/aux.sh	2012/03/16 19:08:09	1.46
+++ LVM2/test/lib/aux.sh	2012/03/20 10:51:57	1.47
@@ -12,7 +12,7 @@
 . lib/utils
 
 run_valgrind() {
-	# Execute script which may use $TESTNAME for creating individal
+	# Execute script which may use $TESTNAME for creating individual
 	# log files for each execute command
 	exec "${VALGRIND:-valg}" "$@"
 }
@@ -59,7 +59,7 @@
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
-	sleep 1
+	sleep .3
 }
 
 prepare_lvmetad() {
@@ -73,7 +73,7 @@
 	lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" &
 	echo $! > LOCAL_LVMETAD
 
-	sleep 1
+	sleep .3
 }
 
 notify_lvmetad() {
@@ -82,37 +82,63 @@
 	fi
 }
 
-teardown_devs() {
-	vgremove -ff $vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
-
-	# Delete any remaining dm/udev semaphores
-	teardown_udev_cookies
+teardown_devs_prefixed() {
+	local prefix=$1
+	local stray=${2:-0}
+	local IFS=$IFS_NL
+	local dm
+
+	# Resume suspended devices first
+	for dm in $(dmsetup info -c -o suspended,name --noheadings | grep "^Suspended:.*$prefix"); do
+		echo "dmsetup resume \"${dm#Suspended:}\""
+		dmsetup resume "${dm#Suspended:}" || true
+	done
 
-	test -z "$PREFIX" || {
-		rm -rf "$TESTDIR/dev/$PREFIX"*
+	local mounts=( $(grep "$prefix" /proc/mounts | cut -d' ' -f1) )
+	if test ${#mounts[@]} -gt 0; then
+		test "$stray" -eq 0 || echo "Removing stray mounted devices containing $prefix: ${mounts[@]}"
+		if umount -fl "${mounts[@]}"; then
+			udev_wait
+		fi
+	fi
 
-		# Try unmount opened devices first
-		for s in $(dmsetup info -c -o open,name --sort -open --noheading | grep "$PREFIX"); do
-			test "${s%%:*}" -gt 0 || break
-			umount -fl "$DM_DEV_DIR/mapper/${s#[0..9]*:}" &>/dev/null || true
-		done
+	if test "$stray" -eq 0; then
+		dmsetup table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || \
+			vgremove -ff $vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
+	fi
 
-		# Remove devices, start with closed (sorted by open count)
-		init_udev_transaction
-		for s in $(dmsetup info -c -o name --sort open --noheading | grep "$PREFIX"); do
-			dmsetup remove "$s" &>/dev/null || true
-		done
-		finish_udev_transaction
-		udev_wait
+	# Remove devices, start with closed (sorted by open count)
+	local remfail=no
+	local need_udev_wait=0
+	init_udev_transaction
+	for dm in $(dmsetup info -c -o name --sort open --noheadings | grep "$prefix"); do
+		dmsetup remove "$dm" &>/dev/null || remfail=yes
+		need_udev_wait=1
+	done
+	finish_udev_transaction
+	test $need_udev_wait -eq 0 || udev_wait
 
-		# Brute force, and without udev transaction
-		while dmsetup table | grep -q "$PREFIX"; do
-			for s in $(dmsetup info -c -o name --sort open --noheading | grep "$PREFIX"); do
-				umount -fl "$DM_DEV_DIR/mapper/$s" &>/dev/null || true
-				dmsetup remove -f "$s" &>/dev/null || true
+	if test $remfail = yes; then
+		local num_devs
+		local num_remaining_devs=999
+		while num_devs=$(dmsetup table | grep "$prefix" | wc -l) && \
+		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
+			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
+			for dm in $(dmsetup info -c -o name --sort open --noheadings | grep "$prefix") ; do
+				dmsetup remove -f "$dm" || true
 			done
-			udev_wait
+			num_remaining_devs=$num_devs
 		done
+	fi
+}
+
+teardown_devs() {
+	# Delete any remaining dm/udev semaphores
+	teardown_udev_cookies
+
+	test -z "$PREFIX" || {
+		rm -rf "$TESTDIR/dev/$PREFIX"*
+		teardown_devs_prefixed "$PREFIX"
 	}
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
@@ -120,7 +146,7 @@
 	if test -f SCSI_DEBUG_DEV; then
 		modprobe -r scsi_debug
 	else
-		test ! -f LOOP || losetup -d $(cat LOOP)
+		test ! -f LOOP || losetup -d $(cat LOOP) || true
 		test ! -f LOOPFILE || rm -f $(cat LOOPFILE)
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
@@ -128,44 +154,12 @@
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
 	test -z "$COMMON_PREFIX" || {
-		# Resume any linears to be sure we do not deadlock
-		STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep "$COMMON_PREFIX" | cut -d' '  -f 1)
-		for dm in $STRAY_DEVS ; do
-			# FIXME: only those really suspended
-			echo "dmsetup resume \"$dm\""
-			dmsetup resume "$dm" || true
-		done
-
-		STRAY_MOUNTS=$(mount | grep "$COMMON_PREFIX" | cut -d' ' -f1)
-		if test -n "$STRAY_MOUNTS"; then
-			echo "Removing stray mounted devices containing $COMMON_PREFIX:"
-			mount | grep "$COMMON_PREFIX"
-			umount -fl "$STRAY_MOUNTS" || true
-			udev_wait
-		fi
-
-		init_udev_transaction
-		NUM_REMAINING_DEVS=999
-		while NUM_DEVS=$(dmsetup table | grep "^$COMMON_PREFIX" | wc -l) && \
-		    test $NUM_DEVS -lt $NUM_REMAINING_DEVS -a $NUM_DEVS -ne 0; do
-			echo "Removing $NUM_DEVS stray mapped devices with names beginning with $COMMON_PREFIX:"
-			STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep "$COMMON_PREFIX" | cut -d' '  -f 1)
-			dmsetup info -c | grep "^$COMMON_PREFIX"
-			for dm in $STRAY_DEVS ; do
-				echo "dmsetup remove -f \"$dm\""
-				dmsetup remove -f "$dm" || true
-			done
-			NUM_REMAINING_DEVS=$NUM_DEVS
-		done
-		finish_udev_transaction
-		udev_wait
-
-		STRAY_LOOPS=$(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1)
-		if test -n "$STRAY_LOOPS"; then
-			echo "Removing stray loop devices containing $COMMON_PREFIX:"
-			losetup -a | grep "$COMMON_PREFIX"
-			losetup -d "$STRAY_LOOPS" || true
-		fi
+		teardown_devs_prefixed "$COMMON_PREFIX" 1
+		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
+		test ${#stray_loops[@]} -eq 0 || {
+			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
+			losetup -d "${stray_loops[@]}"
+		}
 	}
 }
 
@@ -181,6 +175,7 @@
 
 	echo -n .
 
+	pgrep dmeventd || true
 	test -f LOCAL_DMEVENTD && kill -9 $(cat LOCAL_DMEVENTD) || true
 	test -f LOCAL_LVMETAD && kill -9 $(cat LOCAL_LVMETAD) || true
 
@@ -201,13 +196,16 @@
 }
 
 make_ioerror() {
-	echo 0 10000000 error | dmsetup create -u TEST-ioerror ioerror
+	echo 0 10000000 error | dmsetup create -u ${PREFIX}-ioerror ioerror
 	ln -s "$DM_DEV_DIR/mapper/ioerror" "$DM_DEV_DIR/ioerror"
 }
 
 prepare_loop() {
 	local size=${1=32}
+	local i
+	local slash
 
+	test -f LOOP && LOOP=$(cat LOOP)
 	echo -n "## preparing loop device..."
 
 	# skip if prepare_scsi_debug_dev() was used
@@ -296,6 +294,7 @@
 	local n=${1:-3}
 	local devsize=${2:-34}
 	local pvname=${3:-pv}
+	local loopsz
 
 	prepare_loop $(($n*$devsize))
 	echo -n "## preparing $n devices..."
@@ -331,6 +330,8 @@
 }
 
 disable_dev() {
+	local dev
+
 	init_udev_transaction
 	for dev in "$@"; do
 		maj=$(($(stat --printf=0x%t "$dev")))
@@ -340,10 +341,11 @@
 		notify_lvmetad --major "$maj" --minor "$min"
 	done
 	finish_udev_transaction
-
 }
 
 enable_dev() {
+	local dev
+
 	init_udev_transaction
 	for dev in "$@"; do
 		local name=$(echo "$dev" | sed -e 's,.*/,,')
@@ -357,12 +359,16 @@
 }
 
 backup_dev() {
+	local dev
+
 	for dev in "$@"; do
 		dd if="$dev" of="$dev.backup" bs=1024
 	done
 }
 
 restore_dev() {
+	local dev
+
 	for dev in "$@"; do
 		test -e "$dev.backup" || \
 			die "Internal error: $dev not backed up, can't restore!"
@@ -426,24 +432,27 @@
 EOF
 	}
 
+	local v
 	for v in "$@"; do
 	    echo "$v" >> CONFIG_VALUES
 	done
 
 	rm -f CONFIG
+	local s
 	for s in $(cat CONFIG_VALUES | cut -f1 -d/ | sort | uniq); do
 		echo "$s {" >> CONFIG
-		for k in $(grep ^$s/ CONFIG_VALUES | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
+		local k
+		for k in $(grep ^"$s"/ CONFIG_VALUES | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
 			grep "^$k" CONFIG_VALUES | tail -n 1 | sed -e "s,^$s/,	  ," >> CONFIG
 		done
 		echo "}" >> CONFIG
 		echo >> CONFIG
 	done
-        mv -f CONFIG $TESTDIR/etc/lvm.conf
+	mv -f CONFIG etc/lvm.conf
 }
 
 apitest() {
-	t=$1
+	local t=$1
 	shift
 	test -x "$abs_top_builddir/test/api/$t.t" || skip
 	"$abs_top_builddir/test/api/$t.t" "$@" && rm -f debug.log
@@ -458,9 +467,9 @@
 	pgrep udev >/dev/null || return 0
 	which udevadm >/dev/null || return 0
 	if test -n "$1" ; then
-		udevadm settle --exit-if-exists=$1
+		udevadm settle --exit-if-exists="$1" || true
 	else
-		udevadm settle --timeout=15
+		udevadm settle --timeout=15 || true
 	fi
 }
 
@@ -477,28 +486,28 @@
 	  dm-*) modprobe "$1" ;;
 	esac
 
-	version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
+	local version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
 	version=${version##* v}
 	shift
-	major=$(echo "$version" | cut -d. -f1)
-	minor=$(echo "$version" | cut -d. -f2)
-	revision=$(echo "$version" | cut -d. -f3)
 
+	local major=$(echo "$version" | cut -d. -f1)
 	test -z "$1" && return 0
 	test -n "$major" || return 1
 	test "$major" -gt "$1" && return 0
 	test "$major" -eq "$1" || return 1
+
 	test -z "$2" && return 0
+	local minor=$(echo "$version" | cut -d. -f2)
 	test -n "$minor" || return 1
 	test "$minor" -gt "$2" && return 0
 	test "$minor" -eq "$2" || return 1
-	test -z "$4" && return 0
-	test -n "$revision" || return 1
-	test "$revision" -eq "$3" || return 1
+
+	test -z "$3" && return 0
+	local revision=$(echo "$version" | cut -d. -f3)
+	test "$revision" -ge "$3" 2>/dev/null || return 1
 }
 
 test -f DEVICES && devs=$(cat DEVICES)
-test -f LOOP && LOOP=$(cat LOOP)
 
 unset LVM_VALGRIND
 "$@"
--- LVM2/test/lib/test.sh	2012/03/16 12:59:43	1.9
+++ LVM2/test/lib/test.sh	2012/03/20 10:51:57	1.10
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,7 +17,7 @@
 # Put script name into variable, so it can used in external scripts
 TESTNAME=${0##*/}
 # Nice debug message
-PS4=' ${BASH_SOURCE[0]##*/}:${LINENO}+ '
+PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
 unset CDPATH
@@ -29,8 +29,8 @@
 COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
-TESTDIR=$(mkdtemp "${LVM_TEST_DIR-$TESTOLDPWD}" "$PREFIX.XXXXXXXXXX") || \
-	die "failed to create temporary directory in ${LVM_TEST_DIR-$TESTOLDPWD}"
+TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-$TESTOLDPWD}" "$PREFIX.XXXXXXXXXX") || \
+	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
 RUNNING_DMEVENTD=$(pgrep dmeventd) || true
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
@@ -57,9 +57,10 @@
 echo "$TESTNAME" >TESTNAME
 
 # Setting up symlink from $i to $TESTDIR/lib
-find "$abs_top_builddir/daemons/dmeventd/plugins/" -name \*.so \
-	-exec ln -s "{}" lib/ \;
-ln -s "$abs_top_builddir/test/lib/"* lib/
+find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
+	-exec ln -s -t lib "{}" +
+find "$abs_top_builddir/test/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
+	-o -name '*~' \)  -exec ln -s -t lib "{}" +
 
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars
--- LVM2/test/lib/utils.sh	2012/03/16 19:09:49	1.10
+++ LVM2/test/lib/utils.sh	2012/03/20 10:51:57	1.11
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -11,6 +11,8 @@
 
 set -e
 MAX_TRIES=4
+IFS_NL='
+'
 
 die() {
 	echo "$@" >&2
@@ -62,8 +64,7 @@
 	fail=0
 
 	# First, try to use mktemp.
-	d=$(env -u TMPDIR mktemp -d -t -p "$destdir" "$template" 2>/dev/null) \
-	  || fail=1
+	d=$(env -u TMPDIR mktemp -d -t -p "$destdir" "$template" 2>/dev/null) || fail=1
 
 	# The resulting name must be in the specified directory.
 	case "$d" in "${destdir}"*);; *) fail=1;; esac
@@ -165,15 +166,15 @@
 	local major=$(uname -r | cut -d. -f1)
 	local minor=$(uname -r | cut -d. -f2 | cut -d- -f1)
 
-	test $major -gt $1 && return 0
-	test $major -eq $1 || return 1
-	test $minor -gt $2 && return 0
-	test $minor -eq $2 || return 1
+	test "$major" -gt "$1" && return 0
+	test "$major" -eq "$1" || return 1
+	test "$minor" -gt "$2" && return 0
+	test "$minor" -eq "$2" || return 1
 	test -z "$3" && return 0
 
 	local minor2=$(uname -r | cut -d. -f3 | cut -d- -f1)
-	test -z "$minor2" -a $3 -ne 0 && return 1
-	test $minor2 -ge $3 2>/dev/null || return 1
+	test -z "$minor2" -a "$3" -ne 0 && return 1
+	test "$minor2" -ge "$3" 2>/dev/null || return 1
 }
 
 prepare_test_vars() {
@@ -189,13 +190,18 @@
 	done
 }
 
-. lib/paths || die "you must run make first"
+# check if $abs_top_builddir was already set via 'lib/paths'
+test -n "${abs_top_builddir+varset}" || . lib/paths || die "you must run make first"
 
-PATH="$abs_top_builddir/test/lib":$PATH
-for d in daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot \
-	daemons/dmeventd/plugins/lvm2 daemons/dmeventd liblvm tools libdm; do
-	LD_LIBRARY_PATH="$abs_top_builddir/$d":$LD_LIBRARY_PATH
-done
-export PATH LD_LIBRARY_PATH
+case "$PATH" in
+*"$abs_top_builddir/test/lib"*) ;;
+*)
+        PATH="$abs_top_builddir/test/lib":$PATH
+        for d in daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot \
+                daemons/dmeventd/plugins/lvm2 daemons/dmeventd liblvm tools libdm; do
+                LD_LIBRARY_PATH="$abs_top_builddir/$d":$LD_LIBRARY_PATH
+        done
+        export PATH LD_LIBRARY_PATH ;;
+esac
 
 test -z "$PREFIX" || prepare_test_vars


