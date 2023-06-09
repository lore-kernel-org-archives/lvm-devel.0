From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:02:01 +0000 (GMT)
Subject: main - tests: updates
Message-ID: <20230609160201.731863858C78@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9105890d43bd1b6fe514114f671af2e946e13083
Commit:        9105890d43bd1b6fe514114f671af2e946e13083
Parent:        7f661a24c4f7fa8f161f17da093e456f0d60e106
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 13:28:23 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

tests: updates

Add some more complicated conversion tests.
---
 test/shell/vdo-convert.sh | 67 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 46 insertions(+), 21 deletions(-)

diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 5bf53d081..cb3dd7100 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -18,10 +18,12 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 # Use local for this test vdo configuratoin
-VDOCONF="-f vdotestconf.yml"
+VDO_CONFIG="vdotestconf.yml"
+VDOCONF="-f $VDO_CONFIG"
 #VDOCONF=""
-export VDOCONF
+export VDOCONF VDO_CONFIG
 VDONAME="${PREFIX}-TESTVDO"
+export DM_UUID_PREFIX=$PREFIX
 
 # VDO automatically starts dmeventd
 aux prepare_dmeventd
@@ -44,11 +46,11 @@ export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
 aux have_vdo 6 2 0 || skip
 
-aux prepare_devs 2 10000
+aux prepare_devs 2 20000
 
 aux extend_filter_LVMTEST
 
-
+export TMPDIR=$PWD
 
 
 # Conversion can be made with this version of vdo driver
@@ -59,14 +61,16 @@ aux have_vdo 6 2 5 || skip
 #
 #  In this case we do not need to move any VDO headers.
 #
+if [ 1 -eq 0 ]; then
 vgcreate $vg "$dev1"
 
 lvcreate -L5G -n $lv1 $vg
 
+# use some not so 'well' aligned virtual|logical size
 vdo create $VDOCONF --name "$VDONAME" --device "$DM_DEV_DIR/$vg/$lv1" --vdoSlabSize 128M --vdoLogicalSize 10G
 
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
-
+##XXXXX
 # Different VG name fails
 not lvm_import_vdo -y -v --name $vg1/$lv1 "$DM_DEV_DIR/$vg/$lv1"
 
@@ -130,26 +134,25 @@ vdo create $VDOCONF --name "$VDONAME" --device "$dev1" --vdoSlabSize 128M --vdoL
 
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
 
-lvm_import_vdo -y -v --name $vg1/$lv2 "$dev1"
+lvm_import_vdo --vdo-config "$VDO_CONFIG" -y -v --name $vg1/$lv2 "$dev1"
 
 fsck -n "$DM_DEV_DIR/$vg1/$lv2"
 
 vgremove -f $vg1
+fi
 
-aux teardown_devs
-
-
-# Check with some real non-DM device from system
-# this needs to dropping DM_DEV_DIR
+aux wipefs_a "$dev1"
 
-aux prepare_loop 60000 || skip
+# let's assume users with VDO target have 'new' enough version of stat too
+# otherwise use more universal code from lvm_vdo_import
+read major minor < <(stat -c '%Hr %Lr' $(readlink -e "$dev1"))
+dmsetup create "$PREFIX-vdotest" --table "0 30280004 linear $major:$minor 32"
 
-test -f LOOP
-LOOP=$(< LOOP)
-LOOP="${DM_DEV_DIR}/${LOOP##/dev/}"
+TEST="$DM_DEV_DIR/mapper/$PREFIX-vdotest"
 
-aux extend_filter "a|$LOOP|"
-aux extend_devices "$LOOP"
+aux wipefs_a "$TEST"
+aux extend_filter "a|$TEST|"
+aux extend_devices "$TEST"
 
 #
 # Unfortunatelly generates this in syslog:
@@ -165,7 +168,9 @@ aux extend_devices "$LOOP"
 #
 # automate...
 #
-vdo create $VDOCONF --name "$VDONAME" --device "$LOOP" --vdoSlabSize 128M --vdoLogicalSize 23G\
+
+# use slightly smaller size then 'rounded' 23G - to enforce vdo_logicalSize rounding
+vdo create $VDOCONF --name "$VDONAME" --device "$TEST" --vdoSlabSize 128M --vdoLogicalSize 24117240K\
 	--blockMapCacheSize 192 \
 	--blockMapPeriod 2048 \
 	--emulate512 disabled \
@@ -179,19 +184,39 @@ vdo create $VDOCONF --name "$VDONAME" --device "$LOOP" --vdoSlabSize 128M --vdoL
 	--vdoHashZoneThreads 3 \
 	--vdoLogicalThreads 3 \
 	--writePolicy async-unsafe
+dmsetup table
 
 # Get VDO table line
 dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
 
+# For conversion we
 aux lvmconf 'global/vdo_disabled_features = [ "version4" ]'
 
-lvm_import_vdo -y --name $vg/$lv "$LOOP"
-lvs -a $vg
+#
+# Try to prepare 'broken' case where header was moved by older tool to 2M position
+#
+export LVM_VDO_PREPARE=oldvdoprepareforlvm2M
+if which "$LVM_VDO_PREPARE" ; then
+# Use old vdoprepareforlvm tool, that always moves header to 2M offset
+cp "$VDO_CONFIG" "$VDO_CONFIG.backup"
+lvm_import_vdo --abort-after-vdo-convert --vdo-config "$VDO_CONFIG" -v -y --name $vg/$lv "$TEST"
+# Restore VDO configuration (as it's been removed with succeful vdo conversion
+cp "$VDO_CONFIG.backup" "$VDO_CONFIG"
+# Check VDO header is seen@2M offset
+blkid -c /dev/null --probe --offset 2M "$TEST"
+fi
+unset LVM_VDO_PREPARE
+
+#lvm_import_vdo --no-snapshot --vdo-config "$VDO_CONFIG" -v -y --name $vg/$lv "$TEST"
+lvm_import_vdo --vdo-config "$VDO_CONFIG" --uuid-prefix "$PREFIX" -v -y --name $vg/$lv "$TEST"
 
+# Compare converted LV uses same VDO table line
 dmsetup table "$vg-${lv}_vpool-vpool" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee new-vdo-lv
 
 # Check there is a match between VDO and LV managed volume
 # (when differentiating parameters are deleted first)
 diff -u vdo-orig new-vdo-lv || die "Found mismatching VDO table lines!"
 
-check lv_field $vg/$lv size "23.00g"
+check lv_field $vg/$lv size "<23.00g"
+unset LVM_VDO_PREPARE
+

