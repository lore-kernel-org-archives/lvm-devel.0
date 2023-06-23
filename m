From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:40 +0000 (GMT)
Subject: main - tests: update test for automatic virtual size correction
Message-ID: <20230623160940.31D4B3858288@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d09124c6204d49f6bda833229c96e8a76665127
Commit:        8d09124c6204d49f6bda833229c96e8a76665127
Parent:        657dde6208ddc8172b7d0e1466751046c8ddaeaa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 18:03:25 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:06:22 2023 +0200

tests: update test for automatic virtual size correction

lvm_import_vdo will adjust the virtual size within conversion
so the volume can be use without any futher tweaking.
---
 test/shell/vdo-convert.sh | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index cb3dd7100..231939cf4 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -61,7 +61,6 @@ aux have_vdo 6 2 5 || skip
 #
 #  In this case we do not need to move any VDO headers.
 #
-if [ 1 -eq 0 ]; then
 vgcreate $vg "$dev1"
 
 lvcreate -L5G -n $lv1 $vg
@@ -139,7 +138,6 @@ lvm_import_vdo --vdo-config "$VDO_CONFIG" -y -v --name $vg1/$lv2 "$dev1"
 fsck -n "$DM_DEV_DIR/$vg1/$lv2"
 
 vgremove -f $vg1
-fi
 
 aux wipefs_a "$dev1"
 
@@ -189,6 +187,8 @@ dmsetup table
 # Get VDO table line
 dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
 
+mkfs.ext4 -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+
 # For conversion we
 aux lvmconf 'global/vdo_disabled_features = [ "version4" ]'
 
@@ -209,14 +209,22 @@ unset LVM_VDO_PREPARE
 
 #lvm_import_vdo --no-snapshot --vdo-config "$VDO_CONFIG" -v -y --name $vg/$lv "$TEST"
 lvm_import_vdo --vdo-config "$VDO_CONFIG" --uuid-prefix "$PREFIX" -v -y --name $vg/$lv "$TEST"
+dmsetup table
+
+# check our filesystem is OK
+fsck -n "$DM_DEV_DIR/$vg/$lv"
 
 # Compare converted LV uses same VDO table line
 dmsetup table "$vg-${lv}_vpool-vpool" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee new-vdo-lv
 
+tail -n+3 vdo-orig >vdo-orig-3
+tail -n+3 new-vdo-lv >new-vdo-lv-3
+
 # Check there is a match between VDO and LV managed volume
 # (when differentiating parameters are deleted first)
-diff -u vdo-orig new-vdo-lv || die "Found mismatching VDO table lines!"
+# we need to skip first 2 lines as the device size gets rounded to match VG extent size
+diff -u vdo-orig-3 new-vdo-lv-3 || die "Found mismatching VDO table lines!"
 
-check lv_field $vg/$lv size "<23.00g"
+check lv_field $vg/$lv size "23.00g"
 unset LVM_VDO_PREPARE
 

