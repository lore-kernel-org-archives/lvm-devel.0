From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 13 Sep 2023 23:46:37 +0000
Subject: [Git][lvmteam/lvm2][main] 8 commits: vdo: avoid using of valuesonly
Message-ID: <650249dd1be4d_28a4740515a1@gitlab-sidekiq-low-urgency-cpu-bound-v2-f6bdb45d-gth5p.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
f9688335 by Zdenek Kabelac at 2023-09-14T01:44:27+02:00
vdo: avoid using of valuesonly

To retain backward compatibility with some older version of lvm
avoid using --valuesonly option with lvmconfig.

- - - - -
4276c703 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: aux try with extra sleep

Since udev_wait is not really adding any major delay to wait
for any udev worker processing - add extra sleep .1.

- - - - -
de4cb219 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: aux using singl lvmconf call

lvmconf can handle multiple options in a single pass.

- - - - -
738c4b84 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: missing to check for writecache support

Ono more case requires writecache presence.

- - - - -
fba81cf3 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: pvmove large disk area

With some faster test hw machine we need to make this test
a bit more resource consuming.

- - - - -
fac2e073 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: enforce full fs check

- - - - -
f9d17f1f by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: update for work in fake dev environment

No write outside of $LVM_TEST_DIR  (removed /test access).
Use &#39;aux prepare_scsi_debug_dev&#39; for automated scsi_debug handling
Properly use &quot;&quot; around shell vars.
Smarter read of PVS values.
Relax requirement to only work with real /dev dir.

- - - - -
9d7061f1 by Zdenek Kabelac at 2023-09-14T01:45:34+02:00
tests: skip test when lvmdbusd runs on the system

lvmdbusd changes $RUNDIR results.

- - - - -


7 changed files:

- scripts/lvm_import_vdo.sh
- test/lib/aux.sh
- test/shell/caching-snapshot.sh
- test/shell/devicesfile-vpd-ids.sh
- test/shell/duplicate-pvs-md0.sh
- test/shell/lvresize-fs-crypt.sh
- test/shell/pvmove-abort-all.sh


Changes:

=====================================
scripts/lvm_import_vdo.sh
=====================================
@@ -531,9 +531,9 @@ convert_non_lv_() {
 	dry snapshot_merge_ "$DEVICE"
 
 	# For systems using devicesfile add 'merged' PV into system.devices.
-	if [ "$("$LVM" lvmconfig --valuesonly devices/use_devicesfile --typeconfig full)" = "1" ]; then
-		dry "$LVM" lvmdevices --adddev "$DEVICE"
-	fi
+	# Bypassing use of --valuesonly to keep compatibility with older lvm.
+	local usedev=$("$LVM" lvmconfig --typeconfig full devices/use_devicesfile || true)
+	[ "${usedev#*=" = "1" ] && dry "$LVM" lvmdevices --adddev "$DEVICE"
 
 	# Restore auto activation for a VG
 	dry "$LVM" vgchange --setautoactivation y $VERB $FORCE "$VGNAME"


=====================================
test/lib/aux.sh
=====================================
@@ -430,6 +430,7 @@ teardown_devs_prefixed() {
 
 			test "$progress" = 1 || break
 
+			sleep .1
 			udev_wait
 			wait
 			progress=0
@@ -1453,8 +1454,7 @@ extend_filter_md() {
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
 	done
-	lvmconf "$filter"
-	lvmconf "devices/scan = [ \"$DM_DEV_DIR\", \"/dev\" ]"
+	lvmconf "$filter" "devices/scan = [ \"$DM_DEV_DIR\", \"/dev\" ]"
 }
 
 extend_filter_LVMTEST() {


=====================================
test/shell/caching-snapshot.sh
=====================================
@@ -72,7 +72,8 @@ test_snap_create() {
 
 test_snap_create cache --cachepool
 test_snap_create cache --cachevol
-test_snap_create writecache --cachevol
+
+[ "$HAVE_WRITECACHE" = "1" ] && test_snap_create writecache --cachevol
 
 # removing cache|writecache while snapshot exists
 
@@ -109,9 +110,7 @@ test_snap_remove() {
 test_snap_remove cache --cachepool
 test_snap_remove cache --cachevol
 
-if [ "$HAVE_WRITECACHE" = "1" ]; then
-test_snap_remove writecache --cachevol
-fi
+[ "$HAVE_WRITECACHE" = "1" ] && test_snap_remove writecache --cachevol
 
 # adding cache|writecache to an LV that has a snapshot
 
@@ -150,9 +149,7 @@ test_caching_with_snap() {
 test_caching_with_snap cache --cachepool
 test_caching_with_snap cache --cachevol
 
-if [ "$HAVE_WRITECACHE" = "1" ]; then
-test_caching_with_snap writecache --cachevol
-fi
+[ "$HAVE_WRITECACHE" = "1" ] && test_caching_with_snap writecache --cachevol
 
 # adding cache|writecache to a snapshot is not allowed
 


=====================================
test/shell/devicesfile-vpd-ids.sh
=====================================
@@ -16,12 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"
-
-aux lvmconf 'devices/use_devicesfile = 1'
+SYS_DIR="sys"
 # requires trailing / to match dm
-aux lvmconf 'devices/device_id_sysfs_dir = "/test/sys/"'
-SYS_DIR="/test/sys"
+aux lvmconf "devices/device_id_sysfs_dir = \"$PWD/$SYS_DIR/\"" \
+	"devices/use_devicesfile = 1"
 
 # These values match the values encoded in the binary blob
 # written to dev1_vpd_pg83
@@ -34,7 +32,7 @@ DEV1_NAA2=naa.600a098000000002ac18542400000dbd
 DEV1_NAA3=naa.553b13644430344b4e3f486d32647962
 
 create_base() {
-	mkdir -p $SYS_DIR/dev/block
+	mkdir -p "$SYS_DIR/dev/block"
 
 	echo -n "0083 009c 0201 0020 4c56 4d54 5354 2020 \
 	204c 554e 2038 3039 7741 4c56 4d54 5354 \
@@ -45,39 +43,36 @@ create_base() {
 	0000 0dbd 0114 0004 0101 0005 0115 0004 \
 	0000 03ec 0328 0028 6e61 612e 3535 3342 \
 	3133 3634 3434 3330 3334 3442 3445 3346 \
-	3438 3644 3332 3634 3739 3632 0000 0000" | xxd -r -p > $SYS_DIR/dev1_vpd_pg83
+	3438 3644 3332 3634 3739 3632 0000 0000" | xxd -r -p > "$SYS_DIR/dev1_vpd_pg83"
 }
 
 remove_base() {
-	rm $SYS_DIR/dev1_vpd_pg83
-	rmdir $SYS_DIR/dev/block
-	rmdir $SYS_DIR/dev
-	rmdir $SYS_DIR
+	rm "$SYS_DIR/dev1_vpd_pg83"
+	rmdir "$SYS_DIR/dev/block"
+	rmdir "$SYS_DIR/dev"
+	rmdir "$SYS_DIR"
 }
 
 setup_sysfs() {
-	mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
-	echo $1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
-	cp $SYS_DIR/dev1_vpd_pg83 $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg83
+	mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+	echo "$1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+	cp "$SYS_DIR/dev1_vpd_pg83" "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg83"
 }
 
 cleanup_sysfs() {
-	rm -f $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
-	rm -f $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg83
-	rmdir $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device || true
-	rmdir $SYS_DIR/dev/block/$MAJOR1:$MINOR1 || true
+	rm -f "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+	rm -f "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg83"
+	rmdir "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device" || true
+	rmdir "$SYS_DIR/dev/block/$MAJOR1:$MINOR1" || true
 }
 
+aux prepare_scsi_debug_dev 16 || skip
 
-modprobe scsi_debug dev_size_mb=16 num_tgts=1
-sleep 2
 # Get scsi device name created by scsi_debug.
 # SD = sdh
 # DEV1 = /dev/sdh
-SD=$(grep -H scsi_debug /sys/block/sd*/device/model | cut -f4 -d /);
-echo $SD
-DEV1=/dev/$SD
-echo $DEV1
+DEV1=$(< SCSI_DEBUG_DEV)
+echo "Using scsi_debug device: $DEV1"
 
 DFDIR="$LVM_SYSTEM_DIR/devices"
 mkdir -p "$DFDIR" || true
@@ -87,22 +82,23 @@ touch $DF
 
 pvcreate "$DEV1"
 vgcreate $vg "$DEV1"
-MAJOR1=`pvs "$DEV1" --noheading -o major | tr -d - | awk '{print $1}'`
-MINOR1=`pvs "$DEV1" --noheading -o minor | tr -d - | awk '{print $1}'`
-PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+eval "$(pvs --noheading --nameprefixes -o major,minor,uuid "$DEV1")"
+MAJOR1=$LVM2_PV_MAJOR
+MINOR1=$LVM2_PV_MINOR
+PVID1=${LVM2_PV_UUID//-/}
 
 create_base
 
 # No sys/wwid, lvm uses wwid from sys/vpd
 
-setup_sysfs $DEV1_NAA
+setup_sysfs "$DEV1_NAA"
 # no sys/wwid is reported
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
-rm $DF
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
+cat "$DF"
 pvs "$DEV1"
-grep $DEV1_NAA $DF
+grep "$DEV1_NAA" "$DF"
 cleanup_sysfs
 
 # Kernel changes the type printed from sys/wwid from t10 to naa
@@ -113,15 +109,15 @@ cleanup_sysfs
 # reporting pvs should still find the dev based on using vpd data
 #  and find the t10 value there
 
-setup_sysfs $DEV1_T10
-rm $DF
+setup_sysfs "$DEV1_T10"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
-grep sys_wwid $DF
-grep $DEV1_T10 $DF
+cat "$DF"
+grep sys_wwid "$DF"
+grep "$DEV1_T10" "$DF"
 pvs "$DEV1"
 # kernel changes what it reports from sys/wwid
-echo $DEV1_NAA > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+echo "$DEV1_NAA" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 # lvm finds the original t10 id in vpd
 pvs "$DEV1"
 cleanup_sysfs
@@ -132,229 +128,231 @@ cleanup_sysfs
 # df entry uses the specified type
 # reporting pvs should show the pv
 
-setup_sysfs $DEV1_T10
-rm $DF
+setup_sysfs "$DEV1_T10"
+rm "$DF"
 lvmdevices --adddev "$DEV1" --deviceidtype wwid_naa
-cat $DF
-grep wwid_naa $DF
-grep $DEV1_NAA $DF
+cat "$DF"
+grep wwid_naa "$DF"
+grep "$DEV1_NAA" "$DF"
 pvs "$DEV1"
 lvmdevices --deldev "$DEV1"
 lvmdevices --addpvid "$PVID1" --deviceidtype wwid_naa
-cat $DF
-grep $DEV1_NAA $DF
+cat "$DF"
+grep "$DEV1_NAA" "$DF"
 pvs "$DEV1"
 lvmdevices --deldev "$DEV1"
 lvmdevices --adddev "$DEV1" --deviceidtype wwid_eui
-cat $DF
-grep wwid_eui $DF
-grep $DEV1_EUI $DF
+cat "$DF"
+grep wwid_eui "$DF"
+grep "$DEV1_EUI" "$DF"
 pvs "$DEV1"
 cleanup_sysfs
 
-# Any of the vpd wwids can be used in the devices file 
+# Any of the vpd wwids can be used in the devices file
 # with type sys_wwid and the device will be matched to
 # it by finding that wwid in the vpd data.
 
-setup_sysfs $DEV1_NAA
-rm $DF
+setup_sysfs "$DEV1_NAA"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat "$DF"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 pvs "$DEV1"
 cleanup_sysfs
 
-setup_sysfs $DEV1_NAA2
-rm $DF
+setup_sysfs "$DEV1_NAA2"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat "$DF"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 pvs "$DEV1"
 cleanup_sysfs
 
-setup_sysfs $DEV1_NAA3
-rm $DF
+setup_sysfs "$DEV1_NAA3"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat "$DF"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 pvs "$DEV1"
 cleanup_sysfs
 
-setup_sysfs $DEV1_EUI
-rm $DF
+setup_sysfs "$DEV1_EUI"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat "$DF"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 pvs "$DEV1"
 cleanup_sysfs
 
-setup_sysfs $DEV1_T10
-rm $DF
+setup_sysfs "$DEV1_T10"
+rm "$DF"
 lvmdevices --adddev "$DEV1"
-cat $DF
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat "$DF"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 pvs "$DEV1"
 cleanup_sysfs
 
 # Test nvme wwid that starts with "nvme" instead of naa/eui/t10
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
-echo "nvme.111111111111111111122222222222333333333333333-44444444444444444445555555555556666666666666666662-00000001" > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1"
+echo "nvme.111111111111111111122222222222333333333333333-44444444444444444445555555555556666666666666666662-00000001" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid"
 lvmdevices --adddev "$DEV1"
-cat $DF
+cat "$DF"
 vgcreate $vg "$DEV1"
 lvcreate -l1 -an $vg
-cat $DF
+cat "$DF"
 pvs -o+deviceidtype,deviceid "$DEV1" |tee out
 grep sys_wwid out
 grep nvme.111 out
-grep sys_wwid $DF
-grep nvme.111 $DF
+grep sys_wwid "$DF"
+grep nvme.111 "$DF"
 lvmdevices --deldev "$DEV1"
 not lvmdevices --adddev "$DEV1" --deviceidtype wwid_eui
 lvmdevices --adddev "$DEV1" --deviceidtype sys_wwid
 lvmdevices | grep nvme.111
 lvremove -y $vg
-sleep 1
+sleep .1
 lvs $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid"
 cleanup_sysfs
 
 # Test t10 wwid containing quote
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
-echo "t10.ATA_2.5\"_SATA_SSD_1112-A___111111111111" > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+echo "t10.ATA_2.5\"_SATA_SSD_1112-A___111111111111" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
-cat $DF
+cat "$DF"
 vgcreate $vg "$DEV1"
 lvcreate -l1 -an $vg
-cat $DF
+cat "$DF"
 # check wwid string in metadata output
 pvs -o+deviceidtype,deviceid "$DEV1" |tee out
 grep sys_wwid out
 # the quote is removed after the 5
 grep 2.5_SATA_SSD out
 # check wwid string in system.devices
-grep sys_wwid $DF
+grep sys_wwid "$DF"
 # the quote is removed after the 5
-grep 2.5_SATA_SSD $DF
+grep 2.5_SATA_SSD "$DF"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
 # Test t10 wwid with trailing space and line feed at the end
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
 echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
 2048 4152 4444 4953 4b20 2020 2020 2020 \
 2020 2020 2020 2020 2020 2020 2020 2020 \
 2020 2020 5642 3963 3130 6433 3138 2d31 \
-3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
-cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+3838 6439 6562 6320 0a" | xxd -r -p > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+cat "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
-cat $DF
+cat "$DF"
 vgcreate $vg "$DEV1"
 lvcreate -l1 -an $vg
-cat $DF
+cat "$DF"
 # check wwid string in metadata output
 pvs -o+deviceidtype,deviceid "$DEV1" |tee out
 grep sys_wwid out
 # check wwid string in system.devices
-grep sys_wwid $DF
+grep sys_wwid "$DF"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
 # Test t10 wwid with trailing space at the end that was created by 9.0/9.1
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
 echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
 2048 4152 4444 4953 4b20 2020 2020 2020 \
 2020 2020 2020 2020 2020 2020 2020 2020 \
 2020 2020 5642 3963 3130 6433 3138 2d31 \
-3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
-cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+3838 6439 6562 6320 0a" | xxd -r -p > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+cat "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
-cat $DF
+cat "$DF"
 vgcreate $vg "$DEV1"
-PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+eval "$(pvs --noheading --nameprefixes -o uuid "$DEV1")"
+PVID1=${LVM2_PV_UUID//-/}
 T10_WWID_RHEL91="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc_"
 lvcreate -l1 -an $vg
-cat $DF
+cat "$DF"
 # check wwid string in metadata output
 pvs -o+deviceidtype,deviceid "$DEV1" |tee out
 grep sys_wwid out
 # check wwid string in system.devices
-grep sys_wwid $DF
+grep sys_wwid "$DF"
 # Replace IDNAME with the IDNAME that 9.0/9.1 created from this wwid
-cat $DF | grep -v IDNAME > $DFTMP
-cat $DFTMP
-echo "IDTYPE=sys_wwid IDNAME=t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc_ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
-cp $DFTMP $DF
-cat $DF
+cat "$DF" | grep -v IDNAME > "$DFTMP"
+cat "$DFTMP"
+echo "IDTYPE=sys_wwid IDNAME=t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc_ DEVNAME=${DEV1} PVID=${PVID1}" >> "$DFTMP"
+cp "$DFTMP" "$DF"
+cat "$DF"
 vgs
 pvs
 pvs -o+deviceidtype,deviceid "$DEV1"
 # Removing the trailing _ which should then work
-cat $DF | grep -v IDNAME > $DFTMP
-cat $DFTMP
-echo "IDTYPE=sys_wwid IDNAME=t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
-cp $DFTMP $DF
-cat $DF
+cat "$DF" | grep -v IDNAME > "$DFTMP"
+cat "$DFTMP"
+echo "IDTYPE=sys_wwid IDNAME=t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc DEVNAME=${DEV1} PVID=${PVID1}" >> "$DFTMP"
+cp "$DFTMP" "$DF"
+cat "$DF"
 vgs
 pvs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
 # test a t10 wwid that has actual trailing underscore which
 # is followed by a trailing space.
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
 echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
 2048 4152 4444 4953 4b20 2020 2020 2020 \
 2020 2020 2020 2020 2020 2020 2020 2020 \
 2020 2020 5642 3963 3130 6433 3138 2d31 \
-3838 6439 6562 5f20 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
-cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+3838 6439 6562 5f20 0a" | xxd -r -p > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+cat "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 # The wwid has an actual underscore char (5f) followed by a space char (20)
 # 9.1 converts the trailing space to an underscore
 T10_WWID_RHEL91="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9eb__"
 # 9.2 ignores the trailing space
 T10_WWID_RHEL92="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9eb_"
 lvmdevices --adddev "$DEV1"
-cat $DF
+cat "$DF"
 vgcreate $vg "$DEV1"
-PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+eval "$(pvs --noheading --nameprefixes -o uuid "$DEV1")"
+PVID1=${LVM2_PV_UUID//-/}
 lvcreate -l1 -an $vg
-cat $DF
+cat "$DF"
 # check wwid string in metadata output
 pvs -o+deviceidtype,deviceid "$DEV1" |tee out
 grep sys_wwid out
 # check wwid string in system.devices
-grep sys_wwid $DF
+grep sys_wwid "$DF"
 # Replace IDNAME with the IDNAME that 9.0/9.1 created from this wwid
-cat $DF | grep -v IDNAME > $DFTMP
-cat $DFTMP
-echo "IDTYPE=sys_wwid IDNAME=${T10_WWID_RHEL91} DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
-cp $DFTMP $DF
-cat $DF
+cat "$DF" | grep -v IDNAME > "$DFTMP"
+cat "$DFTMP"
+echo "IDTYPE=sys_wwid IDNAME=${T10_WWID_RHEL91} DEVNAME=${DEV1} PVID=${PVID1}" >> "$DFTMP"
+cp "$DFTMP" "$DF"
+cat "$DF"
 vgs
 pvs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
 #
@@ -363,67 +361,70 @@ cleanup_sysfs
 # underscores are understood.
 #
 
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
-echo -n "  s123  456  " > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+echo -n "  s123  456  " > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
 lvmdevices --adddev "$DEV1"
-cat $DF
-grep "IDNAME=s123__456 DEVNAME" $DF
+cat "$DF"
+grep "IDNAME=s123__456 DEVNAME" "$DF"
 vgcreate $vg "$DEV1"
-PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
-cat $DF | grep -v IDNAME > $DFTMP
-cat $DFTMP
-echo "IDTYPE=sys_serial IDNAME=__s123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
-cp $DFTMP $DF
-cat $DF
+eval "$(pvs --noheading --nameprefixes -o uuid "$DEV1")"
+PVID1=${LVM2_PV_UUID//-/}
+cat "$DF" | grep -v IDNAME > "$DFTMP"
+cat "$DFTMP"
+echo "IDTYPE=sys_serial IDNAME=__s123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> "$DFTMP"
+cp "$DFTMP" "$DF"
+cat "$DF"
 vgs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
 cleanup_sysfs
 
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
-echo -n "  t10.123  456  " > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+echo -n "  t10.123  456  " > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
-cat $DF
-grep "IDNAME=t10.123_456 DEVNAME" $DF
+cat "$DF"
+grep "IDNAME=t10.123_456 DEVNAME" "$DF"
 vgcreate $vg "$DEV1"
-PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
-cat $DF | grep -v IDNAME > $DFTMP
-cat $DFTMP
-echo "IDTYPE=sys_wwid IDNAME=__t10.123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
-cp $DFTMP $DF
-cat $DF
+eval "$(pvs --noheading --nameprefixes -o uuid "$DEV1")"
+PVID1=${LVM2_PV_UUID//-/}
+cat "$DF" | grep -v IDNAME > "$DFTMP"
+cat "$DFTMP"
+echo "IDTYPE=sys_wwid IDNAME=__t10.123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> "$DFTMP"
+cp "$DFTMP" "$DF"
+cat "$DF"
 vgs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
-rm $DF
+rm "$DF"
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
-echo -n "  naa.123  456  " > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+echo -n "  naa.123  456  " > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
-cat $DF
-grep "IDNAME=naa.123__456 DEVNAME" $DF
+cat "$DF"
+grep "IDNAME=naa.123__456 DEVNAME" "$DF"
 vgcreate $vg "$DEV1"
-PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
-cat $DF | grep -v IDNAME > $DFTMP
-cat $DFTMP
-echo "IDTYPE=sys_wwid IDNAME=__naa.123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
-cp $DFTMP $DF
-cat $DF
+eval "$(pvs --noheading --nameprefixes -o uuid "$DEV1")"
+PVID1=${LVM2_PV_UUID//-/}
+cat "$DF" | grep -v IDNAME > "$DFTMP"
+cat "$DFTMP"
+echo "IDTYPE=sys_wwid IDNAME=__naa.123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> "$DFTMP"
+cp "$DFTMP" "$DF"
+cat "$DF"
 vgs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
 
@@ -433,4 +434,3 @@ cleanup_sysfs
 # This would let the user specify the second naa wwid.
 
 remove_base
-rmmod scsi_debug || true


=====================================
test/shell/duplicate-pvs-md0.sh
=====================================
@@ -27,6 +27,9 @@ _clear_online_files() {
 
 . lib/inittest
 
+# Running lvmdbusd with its fullreport scannnig changes $RUNDIR results
+pgrep lvmdbusd && skip "Test cannot work, while there is running lvmdbusd."
+
 MD_LEVEL=${MD_LEVEL-0}
 
 aux prepare_devs 4 10


=====================================
test/shell/lvresize-fs-crypt.sh
=====================================
@@ -139,7 +139,7 @@ dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # resize only the fs (to 256M), not the crypt dev or LV
 umount "$mount_dir"
-fsck -n /dev/mapper/$cr
+fsck -fn /dev/mapper/$cr
 resize2fs /dev/mapper/$cr 262144k
 mount /dev/mapper/$cr "$mount_dir"
 # this lvresize will not resize the fs (which is already reduced


=====================================
test/shell/pvmove-abort-all.sh
=====================================
@@ -26,7 +26,7 @@ aux target_at_least dm-mirror 1 10 0 || skip
 # Throttle mirroring
 aux throttle_dm_mirror || skip
 
-aux prepare_pvs 6 60
+aux prepare_pvs 6 90
 
 vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
@@ -41,9 +41,9 @@ for backgroundarg in "-b" "" ;
 do
 
 # Create multisegment LV
-lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
-lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
-lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
+lvcreate -an -Zn -l60 -n $lv1 $vg "$dev1"
+lvcreate -an -Zn -l60 -n $lv2 $vg "$dev2"
+lvcreate -an -Zn -l60 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
 cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/1885655e9a8fc305e70982b2e7992d06e7b0a474...9d7061f1a3b5795a4beccd0e285a5b9d32980a52

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/1885655e9a8fc305e70982b2e7992d06e7b0a474...9d7061f1a3b5795a4beccd0e285a5b9d32980a52
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230913/adb499d0/attachment-0001.htm>
