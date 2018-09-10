From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Sep 2018 12:49:58 -0400
Subject: master - tests: drop lvmetad bits
Message-ID: <201809101649.w8AGnwZL021556@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bcc6c7e6064bd9632557f9678d9d88526d9bbdc
Commit:        3bcc6c7e6064bd9632557f9678d9d88526d9bbdc
Parent:        989626926c98cd00f0236c4fcac883107d76899d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 10 11:10:55 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 10 11:49:11 2018 -0500

tests: drop lvmetad bits

---
 test/Makefile.in                               |    3 -
 test/lib/aux.sh                                |   83 ------------------------
 test/lib/flavour-ndev-lvmetad-lvmpolld.sh      |    3 -
 test/lib/flavour-ndev-lvmetad.sh               |    2 -
 test/lib/flavour-udev-lvmetad-lvmpolld.sh      |    4 -
 test/lib/flavour-udev-lvmetad.sh               |    3 -
 test/lib/flavour-udev-lvmlockd-test-lvmetad.sh |    9 ---
 test/lib/inittest.sh                           |   18 +-----
 test/shell/dmsetup-integrity-keys.sh           |    2 -
 test/shell/dmsetup-keyring.sh                  |    2 -
 test/shell/lvconvert-mirror-basic.sh           |    3 -
 test/shell/lvconvert-mirror.sh                 |    3 -
 test/shell/lvconvert-raid-status-validation.sh |    2 -
 test/shell/lvconvert-raid.sh                   |    2 -
 test/shell/lvcreate-repair.sh                  |    1 -
 test/shell/mirror-vgreduce-removemissing.sh    |    3 -
 test/shell/name-mangling.sh                    |    2 -
 test/shell/pool-labels.sh                      |    4 -
 test/shell/process-each-lv.sh                  |    3 -
 test/shell/pv-duplicate-uuid.sh                |    8 +--
 test/shell/pv-ext-update.sh                    |    3 -
 test/shell/pvmove-basic.sh                     |    3 -
 test/shell/pvmove-restart.sh                   |    2 -
 test/shell/pvmove-resume-1.sh                  |    2 -
 test/shell/pvmove-resume-2.sh                  |    2 -
 test/shell/pvmove-resume-multiseg.sh           |    3 -
 test/shell/relative-sign-options.sh            |    4 -
 test/shell/report-fields.sh                    |    2 -
 test/shell/report-hidden.sh                    |    2 -
 test/shell/snapshot-remove-dmsetup.sh          |    2 -
 test/shell/system_id.sh                        |    5 --
 test/shell/test-partition.sh                   |    1 -
 test/shell/thin-dmeventd-warns.sh              |    2 -
 test/shell/vgchange-many.sh                    |    2 -
 test/shell/vgck.sh                             |    7 +--
 test/shell/vgcreate-many-pvs.sh                |    2 -
 test/shell/vgimportclone.sh                    |   12 ----
 test/shell/vgremove-corrupt-vg.sh              |    1 -
 test/shell/vgsplit-operation.sh                |    3 -
 test/unit/Makefile                             |    2 +-
 test/unit/unit-test.sh                         |    2 -
 41 files changed, 6 insertions(+), 218 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index a9bb083..bb736a6 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -96,7 +96,6 @@ help:
 	@echo "  LVM_TEST_PREFER_BRD	Prefer using brd (ramdisk) over loop for testing [1]."
 	@echo "  LVM_TEST_DIR		Where to create test files  [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
-	@echo "  LVM_TEST_LVMETAD_DEBUG_OPTS  Allows to override debug opts [-l all]."
 	@echo "  LVM_TEST_LVMPOLLD	Start lvmpolld"
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
@@ -252,7 +251,6 @@ lib/flavour-%: $(srcdir)/lib/flavour-%.sh .lib-dir-stamp
 
 lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
-	echo 'LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
 	echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
 	echo 'LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
@@ -264,7 +262,6 @@ lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
 	echo 'LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION THIN RAID CACHE\' >> $@-t
-	echo ' LVMETAD_PIDFILE LVMPOLLD_PIDFILE DMEVENTD_PIDFILE \' >> $@-t
 	echo ' LVM_TEST_THIN_CHECK_CMD LVM_TEST_THIN_DUMP_CMD LVM_TEST_THIN_REPAIR_CMD LVM_TEST_THIN_RESTORE_CMD\' >> $@-t
 	echo ' LVM_TEST_CACHE_CHECK_CMD LVM_TEST_CACHE_DUMP_CMD LVM_TEST_CACHE_REPAIR_CMD LVM_TEST_CACHE_RESTORE_CMD' >> $@-t
 	mv $@-t $@
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f72c851..c3aeb43 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -214,62 +214,7 @@ prepare_dmeventd() {
 	echo ok
 }
 
-prepare_lvmetad() {
-	check_daemon_in_builddir lvmetad
-
-	local run_valgrind=""
-	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
-
-	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
-
-	lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
-	# Default debug is "-l all" and could be override
-	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
-	echo -n "## preparing lvmetad..."
-	# shellcheck disable=SC2086
-	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
-		${LVM_TEST_LVMETAD_DEBUG_OPTS--l all} &
-	echo $! > LOCAL_LVMETAD
-	for i in {200..0} ; do
-		test "$i" -eq 0 && die "Startup of lvmetad is too slow."
-		test -e "$TESTDIR/lvmetad.socket" && break
-		echo -n .
-		sleep .1;
-	done
-	echo ok
-}
-
-lvmetad_talk() {
-	local use=nc
-	if type -p socat >& /dev/null; then
-		use=socat
-	elif echo | not nc -U "$TESTDIR/lvmetad.socket" ; then
-		echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
-		echo "## failed to contact lvmetad."
-		return 1
-	fi
-
-	if test "$use" = nc ; then
-		nc -U "$TESTDIR/lvmetad.socket"
-	else
-		socat "unix-connect:$TESTDIR/lvmetad.socket" -
-	fi | tee -a lvmetad-talk.txt
-}
-
-lvmetad_dump() {
-	(echo 'request="dump"'; echo '##') | lvmetad_talk "$@"
-}
-
-notify_lvmetad() {
-	if test -e LOCAL_LVMETAD; then
-		# Ignore results here...
-		LVM_LOG_FILE_EPOCH="" pvscan --cache "$@" || true
-		rm -f debug.log
-	fi
-}
-
 prepare_lvmpolld() {
-	check_daemon_in_builddir lvmetad
 	lvmconf "global/use_lvmpolld = 1"
 
 	local run_valgrind=""
@@ -583,8 +528,6 @@ teardown() {
 		killall -9 lvmlockd || true
 	fi
 
-	kill_sleep_kill_ LOCAL_LVMETAD "${LVM_VALGRIND_LVMETAD:-0}"
-
 	dm_table | not grep -E -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
@@ -802,11 +745,7 @@ prepare_md_dev() {
 		echo "${mddevdir}${mdname}" > MD_DEV_PV ;;
 	esac
 	echo "$mddev" > MD_DEV
-	notify_lvmetad "$(< MD_DEV_PV)"
 	printf "%s\n" "${@:4}" > MD_DEVICES
-	for mddev in "${@:4}"; do
-		notify_lvmetad "$mddev"
-	done
 }
 
 cleanup_md_dev() {
@@ -820,12 +759,10 @@ cleanup_md_dev() {
 	mddev_pv=$(< MD_DEV_PV)
 	udev_wait
 	mdadm --stop "$mddev" || true
-	notify_lvmetad "$mddev_pv"
 	udev_wait  # wait till events are process, not zeroing to early
 	test "$DM_DEV_DIR" != "/dev" && rm -rf "${mddev_pv%/*}"
 	for dev in $(< MD_DEVICES); do
 		mdadm --zero-superblock "$dev" || true
-		notify_lvmetad "$dev"
 	done
 	udev_wait
 	if [ -b "$mddev" ]; then
@@ -929,12 +866,6 @@ prepare_devs() {
 	printf "%s\\n" "${DEVICES[@]}" > DEVICES
 #	( IFS=$'\n'; echo "${DEVICES[*]}" ) >DEVICES
 	echo "ok"
-
-	if test -e LOCAL_LVMETAD; then
-		for dev in "${DEVICES[@]}"; do
-			notify_lvmetad "$dev"
-		done
-	fi
 }
 
 
@@ -1041,10 +972,6 @@ disable_dev() {
 		    dmsetup remove -f "$dev" 2>/dev/null || true
 		fi
 	done
-
-	test -n "$silent" || for num in $notify; do
-		notify_lvmetad --major "${num%%:*}" --minor "${num##*:}"
-	done
 }
 
 enable_dev() {
@@ -1066,10 +993,6 @@ enable_dev() {
 		dmsetup resume "$name"
 	done
 	finish_udev_transaction
-
-	test -n "$silent" || for dev in "$@"; do
-		notify_lvmetad "$dev"
-	done
 }
 
 # Throttle down performance of kcopyd when mirroring i.e. disk image
@@ -1108,10 +1031,6 @@ restore_from_devtable() {
 		dmsetup resume "$name"
 	done
 	finish_udev_transaction
-
-	test -n "$silent" || for dev in "$@"; do
-		notify_lvmetad "$dev"
-	done
 }
 
 #
@@ -1215,7 +1134,6 @@ generate_config() {
 	fi
 
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
-	LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD:-0}
 	LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD:-0}
 	LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD:-0}
         # FIXME:dct: This is harmful! Variables are unused here and are tested not being empty elsewhere:
@@ -1264,7 +1182,6 @@ global/si_unit_consistency = 1
 global/thin_check_executable = "$LVM_TEST_THIN_CHECK_CMD"
 global/thin_dump_executable = "$LVM_TEST_THIN_DUMP_CMD"
 global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
-global/use_lvmetad = $LVM_TEST_LVMETAD
 global/use_lvmpolld = $LVM_TEST_LVMPOLLD
 global/use_lvmlockd = $LVM_TEST_LVMLOCKD
 log/activation = 1
diff --git a/test/lib/flavour-ndev-lvmetad-lvmpolld.sh b/test/lib/flavour-ndev-lvmetad-lvmpolld.sh
deleted file mode 100644
index 496b3bc..0000000
--- a/test/lib/flavour-ndev-lvmetad-lvmpolld.sh
+++ /dev/null
@@ -1,3 +0,0 @@
-export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
-export LVM_TEST_LVMPOLLD=1
diff --git a/test/lib/flavour-ndev-lvmetad.sh b/test/lib/flavour-ndev-lvmetad.sh
deleted file mode 100644
index cb3c49e..0000000
--- a/test/lib/flavour-ndev-lvmetad.sh
+++ /dev/null
@@ -1,2 +0,0 @@
-export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
diff --git a/test/lib/flavour-udev-lvmetad-lvmpolld.sh b/test/lib/flavour-udev-lvmetad-lvmpolld.sh
deleted file mode 100644
index 64253d1..0000000
--- a/test/lib/flavour-udev-lvmetad-lvmpolld.sh
+++ /dev/null
@@ -1,4 +0,0 @@
-export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
-export LVM_TEST_LVMPOLLD=1
-export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmetad.sh b/test/lib/flavour-udev-lvmetad.sh
deleted file mode 100644
index 13be32e..0000000
--- a/test/lib/flavour-udev-lvmetad.sh
+++ /dev/null
@@ -1,3 +0,0 @@
-export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
-export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmlockd-test-lvmetad.sh b/test/lib/flavour-udev-lvmlockd-test-lvmetad.sh
deleted file mode 100644
index d2a7b4a..0000000
--- a/test/lib/flavour-udev-lvmlockd-test-lvmetad.sh
+++ /dev/null
@@ -1,9 +0,0 @@
-export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
-export LVM_TEST_LVMPOLLD=1
-export LVM_TEST_LVMLOCKD=1
-export LVM_TEST_LVMLOCKD_TEST=1
-export LVM_TEST_DEVDIR=/dev
-
-# FIXME:dct: add option to allow --test with sanlock
-export LVM_TEST_LVMLOCKD_TEST_DLM=1
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 967fc1f..a6cefa8 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -34,7 +34,6 @@ LVM_TEST_LVM1=${LVM_TEST_LVM1-}
 # TODO: LVM_TEST_SHARED
 SHARED=${SHARED-}
 
-LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD-}
 LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD-}
 LVM_TEST_LVMLOCKD_TEST=${LVM_TEST_LVMLOCKD_TEST-}
 LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD-}
@@ -44,9 +43,6 @@ LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK-}
 SKIP_WITHOUT_CLVMD=${SKIP_WITHOUT_CLVMD-}
 SKIP_WITH_CLVMD=${SKIP_WITH_CLVMD-}
 
-SKIP_WITHOUT_LVMETAD=${SKIP_WITHOUT_LVMETAD-}
-SKIP_WITH_LVMETAD=${SKIP_WITH_LVMETAD-}
-
 SKIP_WITH_LVMPOLLD=${SKIP_WITH_LVMPOLLD-}
 SKIP_WITH_LVMLOCKD=${SKIP_WITH_LVMLOCKD-}
 SKIP_ROOT_DM_CHECK=${SKIP_ROOT_DM_CHECK-}
@@ -58,9 +54,6 @@ test -f "lib/flavour-$LVM_TEST_FLAVOUR" || { echo "NOTE: Flavour '$LVM_TEST_FLAV
 test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && initskip
 test -n "$SKIP_WITH_CLVMD" && test "$LVM_TEST_LOCKING" = 3 && initskip
 
-test -n "$SKIP_WITHOUT_LVMETAD" && test -z "$LVM_TEST_LVMETAD" && initskip
-test -n "$SKIP_WITH_LVMETAD" && test -n "$LVM_TEST_LVMETAD" && initskip
-
 test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && test -z "$LVM_TEST_LVMLOCKD" && initskip
 
 test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
@@ -68,7 +61,7 @@ test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
 unset CDPATH
 
 export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG
-export LVM_TEST_LVMETAD LVM_TEST_LVMLOCKD LVM_TEST_LVMLOCKD_TEST
+export LVM_TEST_LVMLOCKD LVM_TEST_LVMLOCKD_TEST
 export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK
 # grab some common utilities
 . lib/utils
@@ -157,15 +150,8 @@ test -n "$BASH" && set -euE -o pipefail
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
 
-if test -n "$LVM_TEST_LVMETAD" ; then
-	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
-	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
-	aux prepare_lvmetad
-elif test -z "$SKIP_ROOT_DM_CHECK" ; then
-	# lvmetad prepares its own lvmconf
-	export LVM_LVMETAD_PIDFILE="$TESTDIR/non-existing-file"
+if test -z "$SKIP_ROOT_DM_CHECK" ; then
 	aux lvmconf
-	aux prepare_clvmd
 fi
 
 test -n "$LVM_TEST_LVMPOLLD" && {
diff --git a/test/shell/dmsetup-integrity-keys.sh b/test/shell/dmsetup-integrity-keys.sh
index 6a7172f..cd98ead 100644
--- a/test/shell/dmsetup-integrity-keys.sh
+++ b/test/shell/dmsetup-integrity-keys.sh
@@ -13,8 +13,6 @@
 # unrelated to lvm2 daemons
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_CLVMD=1
-SKIP_WITH_LVMETAD=1
 
 . lib/inittest
 
diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
index 0f730a9..3c0b867 100644
--- a/test/shell/dmsetup-keyring.sh
+++ b/test/shell/dmsetup-keyring.sh
@@ -13,8 +13,6 @@
 # unrelated to lvm2 daemons
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_CLVMD=1
-SKIP_WITH_LVMETAD=1
 
 . lib/inittest
 
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 2378d48..8166613 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -12,9 +12,6 @@
 
 
 
-# disable lvmetad logging as it bogs down test systems
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 log_name_to_count() {
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 87993da..8f37645 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -12,9 +12,6 @@
 
 
 
-# disable lvmetad logging as it bogs down test systems
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 aux prepare_pvs 5
diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index c5396d7..2d3b5b9 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -18,8 +18,6 @@
 
 SKIP_WITH_LVMPOLLD=1
 
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 # check for version 1.9.0
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index ce60b6b..3b7af97 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -14,8 +14,6 @@
 
 SKIP_WITH_LVMPOLLD=1
 
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 get_image_pvs() {
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index cff0018..07263a3 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -88,7 +88,6 @@ dd if=backup_i of="$dev1" bs=256K count=1
 
 # dirty game
 dd if=/dev/zero of="$dev3" bs=256K count=1
-aux notify_lvmetad "$dev3" # udev be watching you
 
 vgreduce --removemissing --force $vg
 
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 69d9fe8..d95a0ac 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -15,9 +15,6 @@ test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
 SKIP_WITH_LVMPOLLD=1
 
-# disable lvmetad logging as it bogs down test systems
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 list_pvs=()
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 8382ad1..4287939 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -13,8 +13,6 @@
 # This test is not using any lvm command
 # so skip duplicate CLMVD and lvmetad test
 
-SKIP_WITH_CLVMD=1
-SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index 3f9b942..88978e8 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -10,9 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-# lvmetad does not handle pool labels so skip test.
-
-SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -27,7 +24,6 @@ create_pool_label_()
   # printf comes from coreutils, and is probably not posix either
   env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of="$2" bs=5 seek=1 conv=notrunc
   env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
-  aux notify_lvmetad "$2"
 }
 
 
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 9482a08..f28988c 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -14,9 +14,6 @@ test_description='Exercise toollib process_each_lv'
 
 SKIP_WITH_LVMPOLLD=1
 
-# disable lvmetad logging as it bogs down test systems
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index a076812..37d8514 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -20,15 +20,11 @@ aux prepare_devs 3
 
 pvcreate "$dev1"
 UUID1=$(get pv_field "$dev1" uuid)
-pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]} global/use_lvmetad=0" -u "$UUID1" --norestorefile "$dev2"
-pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]} global/use_lvmetad=0" -u "$UUID1" --norestorefile "$dev3"
+pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
+pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
 
 pvscan --cache 2>&1 | tee out
 
-if test -e LOCAL_LVMETAD; then
-	grep "WARNING: Disabling lvmetad cache which does not support duplicate PVs." out
-fi
-
 pvs -o+uuid 2>&1 | tee out
 
 grep    WARNING out > warn || true
diff --git a/test/shell/pv-ext-update.sh b/test/shell/pv-ext-update.sh
index 9059a22..bd66c02 100644
--- a/test/shell/pv-ext-update.sh
+++ b/test/shell/pv-ext-update.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-# lvmetad does not handle pool labels so skip test.
 SKIP_WITH_LVMPOLLD=1
 
 
@@ -166,8 +165,6 @@ create_pv_with_ext_vsn1_and_vg()
 "\x75\x6c\x20\x32\x37\x20\x31\x31\x3a\x32\x35\x3a\x31\x30\x20\x32"\
 "\x30\x31\x36\x0a\x0a\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
 "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" | dd of="$1" bs=5632 seek=1 conv=notrunc
-
-  aux notify_lvmetad "$1"
 }
 
 aux prepare_devs 1 8
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 2fc71e2..c02354d 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -15,9 +15,6 @@ test_description="ensure that pvmove works with basic options"
 
 SKIP_WITH_LVMLOCKD=1
 
-# disable lvmetad logging as it bogs down test systems
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 which md5sum || skip
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index dcf4c37..115ce14 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -81,8 +81,6 @@ if test -e LOCAL_CLVMD ; then
 	aux prepare_clvmd
 fi
 
-aux notify_lvmetad "$dev1" "$dev2" "$dev3"
-
 # Only PVs should be left in table...
 dmsetup table
 
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index ddebcb9..6b4cbe5 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -86,8 +86,6 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-	aux notify_lvmetad "$dev1" "$dev2" "$dev3" "$dev4"
-
 	# call resume function (see below)
 	# with expected number of spawned
 	# bg polling as parameter
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 5e9ad81..803e6ef 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -75,8 +75,6 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-	aux notify_lvmetad "$dev1" "$dev2"
-
 	# call resume function (see below)
 	# with expected number of spawned
 	# bg polling as parameter
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index ce54061..89c2f74 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -16,7 +16,6 @@
 # Multisegment variant w/ 2 pvmoves LVs per VG
 
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
@@ -79,8 +78,6 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-	aux notify_lvmetad "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-
 	# call resume function (see below)
 	# with expected number of spawned
 	# bg polling as parameter
diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 82a5ed2..8333998 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -13,10 +13,6 @@
 test_description='Exercise toollib process_each_lv'
 SKIP_WITH_LVMPOLLD=1
 
-
-# disable lvmetad logging as it bogs down test systems
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 aux prepare_vg 1 256
diff --git a/test/shell/report-fields.sh b/test/shell/report-fields.sh
index 8260610..949e5a5 100644
--- a/test/shell/report-fields.sh
+++ b/test/shell/report-fields.sh
@@ -11,9 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 
-SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
index 24a11c8..621eefc 100644
--- a/test/shell/report-hidden.sh
+++ b/test/shell/report-hidden.sh
@@ -11,8 +11,6 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 
-SKIP_WITH_LVMETAD=1
-SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index a7925d5..19411ce 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -13,8 +13,6 @@
 # check if 'dmsetup --noflush' will work properly for mounted snapshot
 
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_CLVMD=1
-SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index ec7953d..c3fc311 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -597,11 +597,6 @@ grep "No system ID found from system_id_source" err
 vgremove $vg1
 
 
-# Test cases where lvmetad cache of a foreign VG are out of date
-# because the foreign owner has changed the VG.
-
-test ! -e LOCAL_LVMETAD && exit 0
-
 # When a foreign vg is newer on disk than in lvmetad, using --foreign
 # should find the newer version.  This simulates a foreign host changing
 # foreign vg by turning off lvmetad when we create an lv in the vg.
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index 083cd98..0e92f00 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -32,5 +32,4 @@ pvs "$dev1"
 # create small partition table
 echo "1 2" | sfdisk --force "$dev1"
 
-aux notify_lvmetad "$dev1"
 not pvs "$dev1"
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
index a8002ae..2e97fb1 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -14,8 +14,6 @@
 
 
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_CLVMD=1
-SKIP_WITH_LVMETAD=1
 
 . lib/inittest
 
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index debfdc4..389877a 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -16,8 +16,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-# FIXME: lvmetad fails with i.e. 1500 device on memory failure...
-
 # Number of LVs to create
 TEST_DEVS=1000
 # On low-memory boxes let's not stress too much
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index c9d29bb..3288d1b 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -24,14 +24,9 @@ dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 
 vgscan 2>&1 | tee vgscan.out || true
 
-if test -e LOCAL_LVMETAD; then
-    not grep "Failed" vgscan.out
-else
-    grep "Failed" vgscan.out
-fi
+grep "Failed" vgscan.out
 
 dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
-aux notify_lvmetad "$dev2"
 
 vgck $vg 2>&1 | tee vgck.out || true
 grep Incorrect vgck.out
diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
index 9598f91..c68afeb 100644
--- a/test/shell/vgcreate-many-pvs.sh
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -26,12 +26,10 @@ SKIP_WITH_LVMPOLLD=1
 # export LVM_TEST_PVS=300
 #
 # make check_local   ~52sec  (U:29s, S:13s)
-# make check_lvmetad ~20sec  (U: 4s, S: 5s)
 #
 # With patch from 2015-03-06:
 #
 # make check_local   ~30sec  (U:10s, S:12s)
-# make check_lvmetad ~20sec  (U: 4s, S: 5s)
 #
 
 # TODO: extend test suite to monitor performance and report regressions...
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 48a666e..2245d65 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -45,7 +45,6 @@ vgchange -ay $vg1
 
 # Clone the LUN
 dd if="$dev1" of="$dev2" bs=256K count=1
-aux notify_lvmetad "$dev2"
 
 # Verify pvs works on each device to give us vgname
 aux hide_dev "$dev2"
@@ -59,14 +58,6 @@ aux unhide_dev "$dev1"
 # Import the cloned PV to a new VG
 vgimportclone --basevgname $vg2 "$dev2"
 
-# We need to re-scan *both* $dev1 and $dev2 since a PV, as far as lvmetad is
-# concerned, can only live on a single device. With the last pvscan, we told it
-# that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
-# since we wrote a different PV over $dev2.
-rm -f "$TESTDIR/etc/.cache"
-aux notify_lvmetad "$dev2"
-aux notify_lvmetad "$dev1"
-
 # Verify we can activate / deactivate the LV from both VGs
 lvchange -ay $vg1/$lv1 $vg2/$lv1
 vgchange -an $vg1 $vg2
@@ -79,19 +70,16 @@ vgcreate $SHARED --metadatasize 128k A${vg1}B "$dev1"
 
 # vg1B is not the same as Avg1B - we don't need number suffix
 dd if="$dev1" of="$dev2" bs=256K count=1
-aux notify_lvmetad "$dev2"
 vgimportclone -n ${vg1}B "$dev2"
 check pv_field "$dev2" vg_name ${vg1}B
 
 # Avg1 is not the same as Avg1B - we don't need number suffix
 dd if="$dev1" of="$dev2" bs=256K count=1
-aux notify_lvmetad "$dev2"
 vgimportclone -n A${vg1} "$dev2"
 check pv_field "$dev2" vg_name A${vg1}
 
 # Avg1B is the same as Avg1B - we need to add the number suffix
 dd if="$dev1" of="$dev2" bs=256K count=1
-aux notify_lvmetad "$dev2"
 vgimportclone -n A${vg1}B "$dev2"
 aux vgs
 check pv_field "$dev2" vg_name A${vg1}B1
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index 1de77e4..3b17746 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -19,6 +19,5 @@ aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg -an --zero n
 
 dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
-aux notify_lvmetad "$dev2"
 
 vgremove -f $vg
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 2ec140b..ab88866 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -12,12 +12,9 @@
 
 # Test vgsplit operation, including different LV types
 
-# disable lvmetad logging as it bogs down test systems
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
-
 . lib/inittest
 
 COMM() {
diff --git a/test/unit/Makefile b/test/unit/Makefile
index c2f992b..bf85354 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -45,7 +45,7 @@ run-unit-test: test/unit/unit-test
 
 ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
- help check check_local check_cluster check_lvmetad check_lvmpolld run-unit-test))
+ help check check_local check_lvmpolld run-unit-test))
 	-include $(UNIT_DEPENDS)
 endif
 endif
diff --git a/test/unit/unit-test.sh b/test/unit/unit-test.sh
index e8332d6..f545f14 100644
--- a/test/unit/unit-test.sh
+++ b/test/unit/unit-test.sh
@@ -13,8 +13,6 @@
 
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMETAD=1
-SKIP_WITH_CLVMD=1
 
 SKIP_ROOT_DM_CHECK=1
 


