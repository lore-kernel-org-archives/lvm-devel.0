From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  7 Jun 2022 15:15:56 +0000 (GMT)
Subject: main - tests: update for wrapper
Message-ID: <20220607151556.6102238133ED@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a498512077b4fe5cf6b806a91228bd23e513123
Commit:        4a498512077b4fe5cf6b806a91228bd23e513123
Parent:        2ecfd503edadaf5d46115826c629754bf9fd573f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 7 16:52:30 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 7 17:14:09 2022 +0200

tests: update for wrapper

Update calling vdo manager since our vdo wrapper has a simple shell
arg parser so it needs args without '='

Also correct using  DM_DEV_DIR for 'pvcreate'
---
 test/shell/vdo-convert.sh | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 2a2026c2e..8b03344a7 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -54,7 +54,7 @@ vgcreate $vg "$dev1"
 
 lvcreate -L5G -n $lv1 $vg
 
-vdo create $VDOCONF --name "$VDONAME" --device="$DM_DEV_DIR/$vg/$lv1" --vdoLogicalSize=10G
+vdo create $VDOCONF --name "$VDONAME" --device "$DM_DEV_DIR/$vg/$lv1" --vdoSlabSize 128M --vdoLogicalSize 10G
 
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
 
@@ -75,7 +75,7 @@ lvremove -f $vg
 # Test user can specify different VDO LV name (so the original LV is renamed)
 lvcreate -y -L5G -n $lv1 $vg
 
-vdo create $VDOCONF --name "$VDONAME" --device="$DM_DEV_DIR/$vg/$lv1" --vdoLogicalSize=10G
+vdo create $VDOCONF --name "$VDONAME" --device "$DM_DEV_DIR/$vg/$lv1" --vdoSlabSize 128M --vdoLogicalSize 10G
 
 lvm_import_vdo -y --name $vg/$lv2 "$DM_DEV_DIR/$vg/$lv1"
 
@@ -95,7 +95,7 @@ vgcreate $vg2 "$dev2"
 #
 # Check conversion of VDO volume on non-LV device and with >2T size
 #
-vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=3T
+vdo create $VDOCONF --name "$VDONAME" --device "$dev1" --vdoSlabSize 128M --vdoLogicalSize 3T
 
 # Fail with an already existing volume group $vg2
 not lvm_import_vdo --dry-run -y -v --name $vg2/$lv1 "$dev1" |& tee err
@@ -117,7 +117,7 @@ vgremove -f $vg
 aux teardown_devs
 aux prepare_devs 1 23456
 
-vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=23G
+vdo create $VDOCONF --name "$VDONAME" --device "$dev1" --vdoSlabSize 128M --vdoLogicalSize 23G
 
 mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
 
@@ -137,6 +137,7 @@ aux prepare_loop 60000 || skip
 
 test -f LOOP
 LOOP=$(< LOOP)
+LOOP="${DM_DEV_DIR}/${LOOP##/dev/}"
 
 aux extend_filter "a|$LOOP|"
 aux extend_devices "$LOOP"
@@ -155,7 +156,7 @@ aux extend_devices "$LOOP"
 #
 # automate...
 #
-vdo create $VDOCONF --name "$VDONAME" --device="$LOOP" --vdoLogicalSize=23G \
+vdo create $VDOCONF --name "$VDONAME" --device "$LOOP" --vdoSlabSize 128M --vdoLogicalSize 23G\
 	--blockMapCacheSize 192 \
 	--blockMapPeriod 2048 \
 	--emulate512 disabled \
@@ -173,7 +174,7 @@ vdo create $VDOCONF --name "$VDONAME" --device="$LOOP" --vdoLogicalSize=23G \
 # Get VDO table line
 dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
 
-DM_DEV_DIR="" lvm_import_vdo -y --name $vg/$lv "$LOOP"
+lvm_import_vdo -y --name $vg/$lv "$LOOP"
 lvs -a $vg
 
 dmsetup table "$vg-${lv}_vpool-vpool" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee new-vdo-lv

