From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 19:51:31 +0000 (GMT)
Subject: main - tests: adjust for check_devicesfile
Message-ID: <20210820195131.C1AD03858024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4df6931c4cb49af27aa5298b95736a53e83860a9
Commit:        4df6931c4cb49af27aa5298b95736a53e83860a9
Parent:        b0bda7c25b19d9254f65dec4a8e1011204de98e6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 18 16:23:48 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 20 14:06:55 2021 -0500

tests: adjust for check_devicesfile

---
 test/lib/aux.sh                            | 51 +++++++++++++-----
 test/lib/inittest.sh                       |  2 +
 test/shell/allow-mixed-block-sizes.sh      |  1 +
 test/shell/devicesfile-basic.sh            | 87 ++++++++++++++++++++----------
 test/shell/duplicate-pvs-md0.sh            |  6 +++
 test/shell/hints.sh                        |  9 ++++
 test/shell/integrity-blocksize.sh          |  4 ++
 test/shell/losetup-partscan.sh             |  2 +
 test/shell/process-each-duplicate-pvs.sh   | 10 ++++
 test/shell/pv-duplicate-uuid.sh            |  6 +--
 test/shell/pv-ext-flags.sh                 |  2 +
 test/shell/pvcreate-restore.sh             |  4 ++
 test/shell/pvremove-thin.sh                |  3 ++
 test/shell/scan-lvs.sh                     |  3 +-
 test/shell/snapshot-remove-dmsetup.sh      |  3 +-
 test/shell/snapshot-usage-exa.sh           |  3 ++
 test/shell/snapshot-usage.sh               |  2 +
 test/shell/system_id.sh                    | 53 +++++++++++++++++-
 test/shell/vg-check-devs-used.sh           |  2 +-
 test/shell/vgsplit-stacked.sh              |  4 ++
 test/shell/writecache-cache-blocksize-2.sh |  1 +
 21 files changed, 209 insertions(+), 49 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bb189f466..25e8c2ca5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1023,8 +1023,9 @@ prepare_devs() {
 	if test -n "$LVM_TEST_DEVICES_FILE"; then
 		mkdir -p "$TESTDIR/etc/lvm/devices" || true
 		rm "$TESTDIR/etc/lvm/devices/system.devices" || true
+		touch "$TESTDIR/etc/lvm/devices/system.devices"
 		for d in "${DEVICES[@]}"; do
-			lvmdevices --adddev "$dev" || true
+			lvmdevices --adddev "$d" || true
 		done
 	fi
 
@@ -1342,9 +1343,19 @@ prepare_vg() {
 	vgcreate $SHARED -s 512K "$vg" "${DEVICES[@]}"
 }
 
+extend_devices() {
+	test -z "$LVM_TEST_DEVICES_FILE" && return
+
+	for dev in "$@"; do
+		lvmdevices --adddev $dev
+	done
+}
+
 extend_filter() {
 	local filter
 
+	test -n "$LVM_TEST_DEVICES_FILE" && return
+
 	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
@@ -1355,6 +1366,8 @@ extend_filter() {
 extend_filter_md() {
 	local filter
 
+	test -n "$LVM_TEST_DEVICES_FILE" && return
+
 	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
@@ -1370,21 +1383,33 @@ extend_filter_LVMTEST() {
 hide_dev() {
 	local filter
 
-	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
-	for dev in "$@"; do
-		filter=$(echo "$filter" | sed -e "s:\\[:[ \"r|$dev|\", :")
-	done
-	lvmconf "$filter"
+	if test -n "$LVM_TEST_DEVICES_FILE"; then
+		for dev in "$@"; do
+			lvmdevices --deldev $dev
+		done
+	else
+		filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+		for dev in "$@"; do
+			filter=$(echo "$filter" | sed -e "s:\\[:[ \"r|$dev|\", :")
+		done
+		lvmconf "$filter"
+	fi
 }
 
 unhide_dev() {
 	local filter
 
-	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
-	for dev in "$@"; do
-		filter=$(echo "$filter" | sed -e "s:\"r|$dev|\", ::")
-	done
-	lvmconf "$filter"
+	if test -n "$LVM_TEST_DEVICES_FILE"; then
+		for dev in "$@"; do
+			lvmdevices -y --adddev $dev
+		done
+	else
+		filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+		for dev in "$@"; do
+			filter=$(echo "$filter" | sed -e "s:\"r|$dev|\", ::")
+		done
+		lvmconf "$filter"
+	fi
 }
 
 mkdev_md5sum() {
@@ -1433,13 +1458,13 @@ backup/backup = 0
 devices/cache_dir = "$TESTDIR/etc"
 devices/default_data_alignment = 1
 devices/dir = "$DM_DEV_DIR"
-devices/filter = "a|.*|"
-devices/global_filter = [ "a|$DM_DEV_DIR/mapper/${PREFIX}.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection = 0
 devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1
 devices/write_cache_state = 0
 devices/use_devicesfile = $LVM_TEST_DEVICES_FILE
+devices/filter = "a|.*|"
+devices/global_filter = [ "a|$DM_DEV_DIR/mapper/${PREFIX}.*pv[0-9_]*$|", "r|.*|" ]
 global/abort_on_internal_errors = 1
 global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
 global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 4ca8ac59e..9f2713062 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -63,6 +63,8 @@ test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && test -z "$LVM_T
 
 test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
 
+test -n "$SKIP_WITH_DEVICES_FILE" && test -n "$LVM_TEST_DEVICES_FILE" && initskip
+
 unset CDPATH
 
 export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG LVM_TEST_FAILURE
diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index 171942e4b..912f87781 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -45,6 +45,7 @@ for i in "$LOOP1" "$LOOP2"; do
 done
 
 aux extend_filter "a|$dev1|" "a|$dev2|"
+aux extend_devices "$dev1" "$dev2"
 
 not vgcreate --config 'devices/allow_mixed_block_sizes=0' $vg "$dev1" "$dev2"
 vgcreate --config 'devices/allow_mixed_block_sizes=1' $vg "$dev1" "$dev2"
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index 8ad96e37d..53be895e7 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -287,35 +287,6 @@ pvscan --devices "$dev4" --cache -aay "$dev4"
 check lv_field $vg2/$lv2 lv_active "active"
 vgchange -an $vg2
 
-
-# verify --devicesfile and --devices are not affected by a filter
-# hide_dev excludes using existing filter
-aux hide_dev "$dev2"
-aux hide_dev "$dev4"
-pvs --devicesfile test.devices "$dev1"
-pvs --devicesfile test.devices "$dev2"
-not pvs --devicesfile test.devices "$dev3"
-not pvs --devicesfile test.devices "$dev4"
-pvs --devices "$dev1" "$dev1"
-pvs --devices "$dev2" "$dev2"
-pvs --devices "$dev3" "$dev3"
-pvs --devices "$dev4" "$dev4"
-pvs --devices "$dev5" "$dev5"
-pvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5" "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" | tee out
-grep "$dev1" out
-grep "$dev2" out
-grep "$dev3" out
-grep "$dev4" out
-grep "$dev5" out
-vgchange --devices "$dev1","$dev2" -ay $vg1
-check lv_field $vg1/$lv1 lv_active "active"
-lvchange --devices "$dev1","$dev2" -an $vg1/$lv1
-vgchange --devices "$dev3","$dev4" -ay $vg2
-check lv_field $vg2/$lv2 lv_active "active"
-lvchange --devices "$dev3","$dev4" -an $vg2/$lv2
-aux unhide_dev "$dev2"
-aux unhide_dev "$dev4"
-
 vgchange --devicesfile "" -an
 vgremove --devicesfile "" -y $vg1
 vgremove --devicesfile "" -y $vg2
@@ -636,3 +607,61 @@ grep "$dev2" "$DFDIR/test.devices"
 rm "$DFDIR/test.devices"
 vgcreate --devicesfile test.devices $vg3 "$dev3"
 grep "$dev3" "$DFDIR/test.devices"
+
+#
+# verify --devicesfile and --devices are not affected by a filter
+# This is last because it sets lvm.conf filter and
+# I haven't found a way of removing the filter from
+# the config after setting it.
+#
+
+aux lvmconf 'devices/use_devicesfile = 0'
+wipe_all
+rm -f "$DF"
+rm -f "$DFDIR/test.devices"
+
+vgcreate --devicesfile test.devices $vg1 "$dev1" "$dev2"
+grep "$dev1" "$DFDIR/test.devices"
+grep "$dev2" "$DFDIR/test.devices"
+not ls "$DFDIR/system.devices"
+
+# create two VGs outside the special devices file
+vgcreate $vg2 "$dev3" "$dev4"
+vgcreate $vg3 "$dev5" "$dev6"
+not grep "$dev3" "$DFDIR/test.devices"
+not grep "$dev5" "$DFDIR/test.devices"
+not ls "$DFDIR/system.devices"
+
+lvcreate -l4 -an -i2 -n $lv1 $vg1
+lvcreate -l4 -an -i2 -n $lv2 $vg2
+lvcreate -l4 -an -i2 -n $lv3 $vg3
+
+aux lvmconf "devices/filter = [ \"r|$dev2|\" \"r|$dev4|\" ]"
+
+pvs --devicesfile test.devices "$dev1"
+pvs --devicesfile test.devices "$dev2"
+not pvs --devicesfile test.devices "$dev3"
+not pvs --devicesfile test.devices "$dev4"
+pvs --devices "$dev1" "$dev1"
+pvs --devices "$dev2" "$dev2"
+pvs --devices "$dev3" "$dev3"
+pvs --devices "$dev4" "$dev4"
+pvs --devices "$dev5" "$dev5"
+pvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5" "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" | tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+grep "$dev4" out
+grep "$dev5" out
+vgchange --devices "$dev1","$dev2" -ay $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange --devices "$dev1","$dev2" -an $vg1/$lv1
+vgchange --devices "$dev3","$dev4" -ay $vg2
+check lv_field $vg2/$lv2 lv_active "active"
+lvchange --devices "$dev3","$dev4" -an $vg2/$lv2
+
+vgchange -an --devicesfile test.devices $vg1
+vgremove -y --devicesfile test.devices $vg1
+vgremove -y $vg2
+vgremove -y $vg3
+
diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index 82a179915..9156494e3 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -60,6 +60,7 @@ for pass in "auto" "start" ; do
 #
 aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 mddev=$(< MD_DEV)
+lvmdevices --adddev $mddev || true
 
 pvcreate "$mddev"
 PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
@@ -118,6 +119,7 @@ check inactive $vg $lv1
 
 vgchange -an $vg
 vgremove -f $vg
+lvmdevices --deldev $mddev || true
 aux cleanup_md_dev
 
 
@@ -129,6 +131,7 @@ aux cleanup_md_dev
 
 aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 mddev=$(< MD_DEV)
+lvmdevices --adddev $mddev || true
 
 pvcreate "$mddev"
 PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
@@ -188,6 +191,7 @@ aux udev_wait
 
 aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 mddev=$(< MD_DEV)
+lvmdevices --adddev $mddev || true
 
 pvcreate "$mddev"
 PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
@@ -235,6 +239,7 @@ test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
 test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 aux enable_dev "$dev2"
+lvmdevices --deldev $mddev || true
 aux cleanup_md_dev
 
 aux wipefs_a "$dev1"
@@ -250,6 +255,7 @@ if [ "$MD_LEVEL" = "1" ] ; then
 #
 aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
 mddev=$(< MD_DEV)
+lvmdevices --adddev $mddev || true
 
 pvcreate "$mddev"
 PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 3df875418..4fba5cae4 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -141,6 +141,12 @@ not cat $NEWHINTS
 # Test that adding a new device and removing a device
 # causes hints to be recreated.
 #
+# with a devices file the appearance of a new device on
+# the system does not disturb lvm, so this test doesn't
+# apply
+#
+
+if ! lvmdevices; then
 
 not pvs "$dev5"
 
@@ -183,6 +189,9 @@ grep devs_hash $PREV > devs_hash1
 grep devs_hash $HINTS > devs_hash2
 not diff devs_hash1 devs_hash2
 
+# end of new device test for non-devicesfile case
+fi
+
 #
 # Test that hints don't change from a bunch of commands
 # that use hints and shouldn't change it.
diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index a85070cc5..bf8def4ac 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -72,6 +72,10 @@ aux extend_filter "a|$LOOP1|"
 aux extend_filter "a|$LOOP2|"
 aux extend_filter "a|$LOOP3|"
 aux extend_filter "a|$LOOP4|"
+aux extend_devices "$LOOP1"
+aux extend_devices "$LOOP2"
+aux extend_devices "$LOOP3"
+aux extend_devices "$LOOP4"
 
 aux lvmconf 'devices/scan = "/dev"'
 
diff --git a/test/shell/losetup-partscan.sh b/test/shell/losetup-partscan.sh
index aa752064c..99f552ad1 100644
--- a/test/shell/losetup-partscan.sh
+++ b/test/shell/losetup-partscan.sh
@@ -34,6 +34,7 @@ ls -la "${LOOP}"*
 test -e "${LOOP}p1"
 
 aux extend_filter "a|$LOOP|"
+aux extend_devices "$LOOP"
 
 # creation should fail for 'partitioned' loop device
 not pvcreate -y "$LOOP"
@@ -57,6 +58,7 @@ ls -la "${LOOP}"*
 test ! -e "${LOOP}p1"
 
 aux extend_filter "a|$LOOP|"
+aux extend_devices "$LOOP"
 
 # creation should pass for 'non-partitioned' loop device
 pvcreate -y "$LOOP"
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index ffd085a9a..bf86c141f 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -11,6 +11,16 @@ test_description='Test duplicate PVs'
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_CLVMD=1
 
+# This test should work with real device ids (not devnames).
+# When PVs are being overwritten by the test, the devices file is
+# excluding them since with idtype=devname the devices file falls
+# back to including devs based on PVIDs in the devices file,
+# but the 'dd' is clobbering the PVIDs so those devs aren't included
+# so the 'pvs' commands below don't report them. 
+# In general this is better behavior, but needs to be tested
+# with proper device ids.
+SKIP_WITH_DEVICES_FILE=1
+
 . lib/inittest
 
 aux prepare_devs 6 16
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index 37d851401..ac2b866f5 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -20,8 +20,8 @@ aux prepare_devs 3
 
 pvcreate "$dev1"
 UUID1=$(get pv_field "$dev1" uuid)
-pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
-pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
+pvcreate --devices "$dev2" -u "$UUID1" --norestorefile "$dev2"
+pvcreate --devices "$dev3" -u "$UUID1" --norestorefile "$dev3"
 
 pvscan --cache 2>&1 | tee out
 
@@ -35,7 +35,7 @@ test "$(grep -c $UUID1 main)" -eq 1
 COUNT=$(grep --count "Not using device" warn)
 [ "$COUNT" -eq 2 ]
 
-pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" 2>&1 | tee out
+pvs -o+uuid --devices $dev2 2>&1 | tee out
 
 rm warn main || true
 grep    WARNING out > warn || true
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index 22e9b3aac..3e6bcff76 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -64,6 +64,7 @@ dd if=dev1_backup of="$dev1" bs=1M
 # prepare a VG with $dev1 and $dev both having 1 MDA
 aux enable_dev "$dev2"
 vgremove -ff $vg1
+pvremove -ff -y "$dev1"
 pvcreate --metadatacopies 1 "$dev1"
 vgcreate $vg1 "$dev1" "$dev2"
 
@@ -122,6 +123,7 @@ dd if=dev1_backup of="$dev1" bs=1M
 # prepare a VG with $dev1 and $dev both having 1 MDA
 aux enable_dev "$dev2"
 vgremove -ff $vg1
+pvremove -ff -y "$dev1"
 pvcreate --metadatacopies 1 "$dev1"
 vgcreate $vg1 "$dev1" "$dev2"
 
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
index d0b46eb2b..45c27bfc2 100644
--- a/test/shell/pvcreate-restore.sh
+++ b/test/shell/pvcreate-restore.sh
@@ -22,6 +22,10 @@ lvcreate --type snapshot -s -L10 -n $lv2 $vg --virtualsize 4T
 lvcreate --type snapshot -s -L10 -n $lv3 $vg --virtualsize 4194300M
 
 aux extend_filter_LVMTEST
+aux lvmconf "devices/scan_lvs = 1"
+aux extend_devices "$DM_DEV_DIR/$vg/$lv1"
+aux extend_devices "$DM_DEV_DIR/$vg/$lv2"
+aux extend_devices "$DM_DEV_DIR/$vg/$lv3"
 
 vgcreate $vg1 "$DM_DEV_DIR/$vg/$lv2"
 
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 9859b6cad..451255746 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -26,6 +26,9 @@ aux extend_filter_LVMTEST
 
 lvcreate -L10 -V10 -n $lv1 -T $vg/pool1
 
+aux extend_devices "$DM_DEV_DIR/$vg/$lv1"
+aux lvmconf "devices/scan_lvs = 1"
+
 pvcreate "$DM_DEV_DIR/$vg/$lv1"
 pvremove "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/scan-lvs.sh b/test/shell/scan-lvs.sh
index f49bf4df5..fe11201f5 100644
--- a/test/shell/scan-lvs.sh
+++ b/test/shell/scan-lvs.sh
@@ -15,8 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-# Sets 'scan_lvs = 1'
 aux extend_filter_LVMTEST
+aux lvmconf "devices/scan_lvs = 1"
 
 aux prepare_pvs 1
 
@@ -24,6 +24,7 @@ vgcreate $SHARED $vg1 "$dev1"
 
 lvcreate -l1 -n $lv1 $vg1
 
+aux extend_devices "$DM_DEV_DIR/$vg1/$lv1"
 pvcreate "$DM_DEV_DIR/$vg1/$lv1"
 
 pvs "$DM_DEV_DIR/$vg1/$lv1"
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 2ef65a596..ab5e2e9ff 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -23,10 +23,11 @@ aux prepare_vg 5
 
 # Create stacked device
 lvcreate --type snapshot -s -L10 -n $lv1 $vg --virtualsize 100M
+aux lvmconf "devices/scan_lvs = 1"
 aux extend_filter_LVMTEST
+aux extend_devices "$DM_DEV_DIR"/$vg/$lv1
 vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv1
 
-
 lvcreate -L20 -n $lv1 $vg1
 lvcreate -L10 -n snap -s $vg1/$lv1
 
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index 5d666bf43..475960df7 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -26,7 +26,10 @@ get_devs
 # Prepare large enough backend device
 vgcreate -s 4M "$vg" "${DEVICES[@]}"
 lvcreate --type snapshot -s -l 100%FREE -n $lv $vg --virtualsize 15P
+
+aux lvmconf "devices/scan_lvs = 1"
 aux extend_filter_LVMTEST
+aux extend_devices "$DM_DEV_DIR/$vg/$lv"
 
 # Check usability with largest extent size
 pvcreate "$DM_DEV_DIR/$vg/$lv"
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index bcfa16a3e..0f14dd6e0 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -77,6 +77,8 @@ lvremove -f $vg
 lvcreate --type snapshot -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
 
 aux extend_filter_LVMTEST
+aux extend_devices "$DM_DEV_DIR/$vg/$lv"
+aux lvmconf "devices/scan_lvs = 1"
 aux lvmconf "activation/snapshot_autoextend_percent = 20" \
             "activation/snapshot_autoextend_threshold = 50"
 
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 8814d5497..ee51ca179 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -27,6 +27,19 @@ aux prepare_devs 1
 SIDFILE="etc/lvm_test.conf"
 LVMLOCAL="etc/lvmlocal.conf"
 
+DFDIR="$LVM_SYSTEM_DIR/devices"
+DF="$DFDIR/system.devices"
+
+# Avoid system id validation in the devices file
+# which gets in the way of the test switching the
+# local system id.
+clear_df_systemid() {
+	if [[ -f $DF ]]; then
+		sed -e "s|SYSTEMID=.||" "$DF" > tmpdf
+		cp tmpdf $DF
+	fi
+}
+
 # create vg with system_id using each source
 
 ## none
@@ -38,7 +51,8 @@ check vg_field $vg1 systemid "$SID"
 vgremove $vg1
 
 # FIXME - print 'life' config data
-eval "$(lvmconfig global/etc 2>/dev/null || lvmconfig --type default global/etc)"
+#eval "$(lvmconfig global/etc 2>/dev/null || lvmconfig --type default global/etc)"
+etc="/etc"
 
 ## machineid
 if [ -e "$etc/machine-id" ]; then
@@ -77,6 +91,7 @@ rm -f "$LVMLOCAL"
 
 SID=sidfoofile
 echo "$SID" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg1 "$dev1"
@@ -89,6 +104,7 @@ vgremove $vg1
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg, overriding the local system_id so the vg looks foreign
@@ -108,6 +124,7 @@ vgs --foreign $vg1 >err
 grep $vg1 err
 # change the local system_id to the second value, making the vg not foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # we can now see and remove the vg
 vgs $vg1 >err
 grep $vg1 err
@@ -118,6 +135,7 @@ vgremove $vg1
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -127,6 +145,7 @@ vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -135,6 +154,7 @@ vgs --foreign >err
 grep $vg1 err
 # change the local system_id back to the first value, making the vg not foreign
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 vgs >err
 grep $vg1 err
 vgremove $vg1
@@ -144,6 +164,7 @@ vgremove $vg1
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -161,6 +182,7 @@ vgs --foreign >err
 grep $vg1 err
 # change the local system_id to the second system_id so we can remove the vg
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 vgs >err
 grep $vg1 err
 vgremove $vg1
@@ -172,6 +194,7 @@ vgremove $vg1
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -183,6 +206,7 @@ grep $vg1 err
 check lv_exists $vg1 $lv1
 # change our system_id, making the vg foreign, but accessible
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 vgs >err
 grep $vg1 err
 check lv_exists $vg1 $lv1
@@ -193,6 +217,7 @@ not lvremove $vg1/$lv1
 not vgremove $vg1
 # change our system_id back to match the vg so it's not foreign
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 vgs >err
 grep $vg1 err
 lvremove $vg1/$lv1
@@ -202,6 +227,7 @@ vgremove $vg1
 
 SID1=sidfoofile1
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -220,12 +246,14 @@ vgremove $vg1
 
 SID1=sidfoofile1
 rm -f "$SIDFILE"
+clear_df_systemid
 # create a vg with no system_id
 aux lvmconf "global/system_id_source = none"
 vgcreate $vg1 "$dev1"
 check vg_field $vg1 systemid ""
 # set a local system_id
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # check we can see and use the vg with no system_id
@@ -239,6 +267,7 @@ vgremove $vg1
 
 SID1=sidfoofile1
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -269,6 +298,7 @@ SID2=012345678901234567890123456789012345678901234567890123456789012345678901234
 
 # max len system_id should appear normally
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -281,6 +311,7 @@ vgremove $vg1
 
 # max+1 len system_id should be missing the last character
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -300,6 +331,7 @@ SID1=012345678901234567890123456789012345678901234567890123456789012345678901234
 # The string is truncated to max length (128) before the invalid character is omitted
 SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefg
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -316,6 +348,7 @@ SID1="?%$&A. at 1]"
 # SID1 without the invalid characters
 SID2=A.1
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -334,6 +367,7 @@ vgremove $vg1
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -344,6 +378,7 @@ grep $vg1 err
 grep "$dev1" err
 # change the local system_id, making the vg foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # normal pvs does not see the vg or pv
 pvs >err
 not grep $vg1 err
@@ -354,6 +389,7 @@ grep $vg1 err
 grep "$dev1" err
 # change the local system_id back so the vg can be removed
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 vgremove $vg1
 rm -f "$SIDFILE"
 
@@ -363,6 +399,7 @@ rm -f "$SIDFILE"
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -375,6 +412,7 @@ grep $vg1 err
 grep $lv1 err
 # change the local system_id, making the vg foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # normal lvs does not see the vg or lv
 lvs >err
 not grep $vg1 err
@@ -385,6 +423,7 @@ grep $vg1 err
 grep $lv1 err
 # change the local system_id back so the vg can be removed
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 lvremove $vg1/$lv1
 vgremove $vg1
 rm -f "$SIDFILE"
@@ -395,6 +434,7 @@ SID1=sidfoofile1
 SID2=sidfoofile2
 rm -f "$LVMLOCAL"
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -404,6 +444,7 @@ vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -420,6 +461,7 @@ rm -f "$LVMLOCAL"
 # vgcreate --systemid "" creates a vg without a system_id even if source is set
 SID1=sidfoofile1
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -436,6 +478,7 @@ rm -f "$SIDFILE"
 # vgchange --systemid "" clears the system_id on owned vg
 SID1=sidfoofile1
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -461,6 +504,7 @@ SID1=sidfoofile1
 SID2=sidfoofile2
 rm -f "$LVMLOCAL"
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -470,6 +514,7 @@ vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -482,6 +527,7 @@ not vgchange --yes --systemid "" $vg1
 not vgchange --yes --systemid foo $vg1
 # change our system_id back so we can remove the vg
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 vgremove $vg1
 
 # vgcfgbackup backs up foreign vg with --foreign
@@ -489,6 +535,7 @@ SID1=sidfoofile1
 SID2=sidfoofile2
 rm -f "$LVMLOCAL"
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -498,6 +545,7 @@ vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
 echo "$SID2" > "$SIDFILE"
+clear_df_systemid
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -506,6 +554,7 @@ not vgcfgbackup $vg1
 vgcfgbackup --foreign $vg1
 # change our system_id back so we can remove the vg
 echo "$SID1" > "$SIDFILE"
+clear_df_systemid
 vgremove $vg1
 rm -f "$SIDFILE"
 
@@ -562,6 +611,7 @@ rm -f $LVMLOCAL
 # vgcreate with source file, but no system_id_file config
 SID=""
 rm -f "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file"
 vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
@@ -572,6 +622,7 @@ vgremove $vg1
 # vgcreate with source file, but system_id_file does not exist
 SID=""
 rm -f "$SIDFILE"
+clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg1 "$dev1" 2>&1 | tee err
diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index 3b911bc10..15cdff624 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -23,7 +23,7 @@ aux prepare_devs 3 8
 vgcreate $SHARED "$vg" "$dev1" "$dev2"
 lvcreate -l100%FREE -n $lv $vg
 dd if="$dev1" of="$dev3" bs=1M oflag=direct
-pvs --config "devices/global_filter = [ \"a|$dev2|\", \"a|$dev3|\", \"r|.*|\" ]" 2>err
+pvs --devices $dev2,$dev3 2>err
 grep "WARNING: Device mismatch detected for $vg/$lv which is accessing $dev1 instead of $dev3" err
 
 dd if=/dev/zero of="$dev3" bs=1M count=8 oflag=direct
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 331ee8e86..2f99a2ea7 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -16,11 +16,15 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux extend_filter_LVMTEST
+aux lvmconf "devices/scan_lvs = 1"
+
 aux prepare_pvs 3
 
 vgcreate $SHARED $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 100%FREE $vg1
 
+aux extend_devices "$DM_DEV_DIR/$vg1/$lv1"
+
 #top VG
 pvcreate "$DM_DEV_DIR/$vg1/$lv1"
 vgcreate $SHARED $vg "$DM_DEV_DIR/$vg1/$lv1" "$dev3"
diff --git a/test/shell/writecache-cache-blocksize-2.sh b/test/shell/writecache-cache-blocksize-2.sh
index dfb4f19a1..9b5d15365 100644
--- a/test/shell/writecache-cache-blocksize-2.sh
+++ b/test/shell/writecache-cache-blocksize-2.sh
@@ -201,6 +201,7 @@ blockdev --getpbsz "$LOOP1" | grep 512
 blockdev --getpbsz "$LOOP2" | grep 512
 
 aux extend_filter "a|$dev3|" "a|$dev4|"
+aux extend_devices "$dev3" "$dev4"
 
 # place main LV on dev1 with LBS 512, PBS 4096
 # and the cache on dev3 with LBS 512, PBS 512


