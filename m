From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:38 +0000 (GMT)
Subject: main - tests: lower demand for disk resources
Message-ID: <20230406114738.B58683857704@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b5291a8ed7917a396232024880b252ecf6ab23f
Commit:        7b5291a8ed7917a396232024880b252ecf6ab23f
Parent:        e8e6347ba3f59cbd2f7e92aa707543b90fa607a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 4 14:44:47 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 13:34:26 2023 +0200

tests: lower demand for disk resources

Convert test to use a single skeleton and only different pieces
keep in separate tests.

Lower raid disk usage to smaller size and switch to ext4
as way less demanding fileystem.
---
 test/shell/vg-raid-takeover-1.sh | 149 ++++++++++++++++++++-------------------
 test/shell/vg-raid-takeover-2.sh | 139 +++---------------------------------
 test/shell/vg-raid-takeover-3.sh | 133 ++--------------------------------
 test/shell/vg-raid-takeover-4.sh | 124 ++------------------------------
 4 files changed, 97 insertions(+), 448 deletions(-)

diff --git a/test/shell/vg-raid-takeover-1.sh b/test/shell/vg-raid-takeover-1.sh
index f186606a6..98e043aae 100644
--- a/test/shell/vg-raid-takeover-1.sh
+++ b/test/shell/vg-raid-takeover-1.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,13 +16,10 @@ test_description='Test VG takeover with raid LVs'
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-print_lvmlocal() {
-	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
-}
-
 . lib/inittest
 
-aux prepare_devs 3 1024
+aux have_raid 1 9 0 || skip
+aux prepare_devs ${PREPARE_DEVS-3}
 
 SIDFILE="etc/lvm_test.conf"
 LVMLOCAL="etc/lvmlocal.conf"
@@ -30,6 +27,10 @@ LVMLOCAL="etc/lvmlocal.conf"
 DFDIR="$LVM_SYSTEM_DIR/devices"
 DF="$DFDIR/system.devices"
 
+print_lvmlocal() {
+	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
+}
+
 # Avoid system id validation in the devices file
 # which gets in the way of the test switching the
 # local system id.
@@ -40,54 +41,74 @@ clear_df_systemid() {
 	fi
 }
 
+test_check_mount() {
+	pvs -o+missing
+	vgs -o+systemid,partial $vg
+	lvs -a -o+devices $vg
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	diff pattern1 "$mount_dir/pattern1a"
+	diff pattern1 "$mount_dir/pattern1c"
+	umount "$mount_dir"
+	fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv2" "$mount_dir"
+	diff pattern1 "$mount_dir/pattern1a"
+	diff pattern1 "$mount_dir/pattern1c"
+	umount "$mount_dir"
+	fsck -n "$DM_DEV_DIR/$vg/$lv2"
+}
+
+
 SID1=sidfoofile1
 SID2=sidfoofile2
 echo "$SID1" > "$SIDFILE"
 clear_df_systemid
 aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
+            "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg "$dev1" "$dev2" "$dev3"
 vgs -o+systemid,partial $vg
 check vg_field $vg systemid "$SID1"
 
-lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
-lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid1 -L 8 -m1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 8 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
 
 # give some time for raid init
-sleep 2
+aux wait_for_sync $vg $lv1
+aux wait_for_sync $vg $lv2
 lvs -a -o+devices $vg
 
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv2"
 
 dd if=/dev/urandom of=pattern1 bs=512K count=1
 
 mount_dir="mnt_takeover"
 mkdir -p "$mount_dir"
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/file1" bs=1M count=4 oflag=direct
+cp pattern1 "$mount_dir/pattern1a"
+cp pattern1 "$mount_dir/pattern1b"
+umount "$mount_dir"
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv2" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/file1" bs=1M count=4 oflag=direct
+cp pattern1 "$mount_dir/pattern1a"
+cp pattern1 "$mount_dir/pattern1b"
+umount "$mount_dir"
 
 vgchange -an $vg
 
 # make the vg foreign
-vgchange --yes --systemid $SID2 $vg
+vgchange --yes --systemid "$SID2" $vg
 not vgs $vg
 
 # make one dev missing
 aux hide_dev "$dev1"
 
 # take over the vg, like cluster failover would do
-vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid "$SID1" $vg
 pvs -o+missing
 vgs -o+systemid,partial $vg
 lvs -a -o+devices $vg
@@ -95,28 +116,37 @@ lvs -a -o+devices $vg
 lvchange -ay --activationmode degraded $vg/$lv1
 lvchange -ay --activationmode degraded $vg/$lv2
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+dd of=/dev/null if="$mount_dir/file1" bs=1M count=4
+diff pattern1 "$mount_dir/pattern1a"
+diff pattern1 "$mount_dir/pattern1b"
+rm "$mount_dir/pattern1b"
+rm "$mount_dir/file1"
+cp pattern1 "$mount_dir/pattern1c"
+umount "$mount_dir"
+
+mount "$DM_DEV_DIR/$vg/$lv2" "$mount_dir"
+dd of=/dev/null if="$mount_dir/file1" bs=1M count=4
+diff pattern1 "$mount_dir/pattern1a"
+diff pattern1 "$mount_dir/pattern1b"
+rm "$mount_dir/pattern1b"
+rm "$mount_dir/file1"
+cp pattern1 "$mount_dir/pattern1c"
+umount "$mount_dir"
 
 pvs -o+missing
 vgs -o+systemid,partial $vg
 lvs -a -o+devices $vg
 
+
+
+#----------------------------------------------------------
+# test will continue differently when var OTHER_TEST is set
+#----------------------------------------------------------
+test -n "${CONTINUE_ELSEWHERE-}" && return 0
+
+
+
 # fails because the missing dev is used by lvs
 not vgreduce --removemissing $vg
 # works because lvs can be used with missing leg
@@ -131,19 +161,9 @@ lvconvert --repair $vg/$lv1
 # fails to find another disk to use to repair
 not lvconvert -y --repair $vg/$lv2
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
 aux unhide_dev "$dev1"
 
@@ -162,36 +182,21 @@ lvconvert -y -m-1 $vg/$lv2
 # remove the failed unused leg, leaving 1 leg
 lvconvert -y -m-1 $vg/$lv1
 
-pvs -o+missing
-vgs -o+systemid,partial,partial $vg
-lvs -a -o+devices $vg
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
 vgextend $vg "$dev1"
 lvconvert -y -m+1 $vg/$lv1 "$dev1"
 lvconvert -y -m+1 $vg/$lv2 "$dev1"
 
 # let raid sync new leg
-sleep 3
+aux wait_for_sync $vg $lv1
+aux wait_for_sync $vg $lv2
+
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
 vgchange -an $vg
 vgremove -f $vg
diff --git a/test/shell/vg-raid-takeover-2.sh b/test/shell/vg-raid-takeover-2.sh
index e0b46dece..afc8db432 100644
--- a/test/shell/vg-raid-takeover-2.sh
+++ b/test/shell/vg-raid-takeover-2.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,110 +12,10 @@
 
 test_description='Test VG takeover with raid LVs'
 
-# test does not apply to lvmlockd
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-print_lvmlocal() {
-	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
-}
-
-. lib/inittest
-
-aux prepare_devs 4 1024
-
-SIDFILE="etc/lvm_test.conf"
-LVMLOCAL="etc/lvmlocal.conf"
-
-DFDIR="$LVM_SYSTEM_DIR/devices"
-DF="$DFDIR/system.devices"
-
-# Avoid system id validation in the devices file
-# which gets in the way of the test switching the
-# local system id.
-clear_df_systemid() {
-	if [[ -f $DF ]]; then
-		sed -e "s|SYSTEMID=.||" "$DF" > tmpdf
-		cp tmpdf $DF
-	fi
-}
-
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-clear_df_systemid
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-vgcreate $vg "$dev1" "$dev2" "$dev3"
-vgs -o+systemid,partial $vg
-check vg_field $vg systemid "$SID1"
-
-lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
-lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
-
-# give some time for raid init
-sleep 2
-lvs -a -o+devices $vg
-
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
-
-dd if=/dev/urandom of=pattern1 bs=512K count=1
-
-mount_dir="mnt_takeover"
-mkdir -p "$mount_dir"
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
+CONTINUE_ELSEWHERE=y
+PREPARE_DEVS=4
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
-
-vgchange -an $vg
-
-# make the vg foreign
-vgchange --yes --systemid $SID2 $vg
-not vgs $vg
-
-# make one dev missing
-aux hide_dev "$dev1"
-
-# take over the vg, like cluster failover would do
-vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
-
-lvchange -ay --activationmode degraded $vg/$lv1
-lvchange -ay --activationmode degraded $vg/$lv2
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
+. ./shell/vg-raid-takeover-1.sh
 
 # fails because the missing dev is used by lvs
 not vgreduce --removemissing $vg
@@ -147,42 +47,19 @@ vgextend $vg "$dev4"
 
 lvconvert -y --repair $vg/$lv2
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
 # let the new legs sync
-sleep 3
+aux wait_for_sync $vg $lv1
+aux wait_for_sync $vg $lv2
 
 vgck --updatemetadata $vg
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
 vgchange -an $vg
 vgremove -f $vg
diff --git a/test/shell/vg-raid-takeover-3.sh b/test/shell/vg-raid-takeover-3.sh
index 5df53d1d7..0050c1918 100644
--- a/test/shell/vg-raid-takeover-3.sh
+++ b/test/shell/vg-raid-takeover-3.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,111 +12,11 @@
 
 test_description='Test VG takeover with raid LVs'
 
-# test does not apply to lvmlockd
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-print_lvmlocal() {
-	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
-}
-
-. lib/inittest
-
-aux prepare_devs 3 1024
-
-SIDFILE="etc/lvm_test.conf"
-LVMLOCAL="etc/lvmlocal.conf"
-
-DFDIR="$LVM_SYSTEM_DIR/devices"
-DF="$DFDIR/system.devices"
-
-# Avoid system id validation in the devices file
-# which gets in the way of the test switching the
-# local system id.
-clear_df_systemid() {
-	if [[ -f $DF ]]; then
-		sed -e "s|SYSTEMID=.||" "$DF" > tmpdf
-		cp tmpdf $DF
-	fi
-}
-
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-clear_df_systemid
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-vgcreate $vg "$dev1" "$dev2" "$dev3"
-vgs -o+systemid,partial $vg
-check vg_field $vg systemid "$SID1"
-
-lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
-lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
-
-# give some time for raid init
-sleep 2
-lvs -a -o+devices $vg
-
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
-
-dd if=/dev/urandom of=pattern1 bs=512K count=1
-
-mount_dir="mnt_takeover"
-mkdir -p "$mount_dir"
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
-
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
-
-vgchange -an $vg
-
-# make the vg foreign
-vgchange --yes --systemid $SID2 $vg
-not vgs $vg
-
-# make one dev missing
-aux hide_dev "$dev1"
-
-# take over the vg, like cluster failover would do
-vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
-
-lvchange -ay --activationmode degraded $vg/$lv1
-lvchange -ay --activationmode degraded $vg/$lv2
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
+CONTINUE_ELSEWHERE=y
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
+. ./shell/vg-raid-takeover-1.sh
 
+#-----------------------
 # replaces dev1 with dev3
 lvconvert -y --repair $vg/$lv1
 
@@ -124,24 +24,15 @@ lvconvert -y --repair $vg/$lv1
 # but that's not allowed until the missing disk is removed from the vg
 not lvconvert -y -m-1 $vg/$lv2
 vgreduce --removemissing --mirrorsonly --force $vg
+
 pvs -o+missing
 vgs -o+systemid,partial $vg
 lvs -a -o+devices $vg
 lvconvert -y -m-1 $vg/$lv2
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
 aux unhide_dev "$dev1"
 
@@ -153,19 +44,9 @@ vgextend $vg "$dev1"
 pvs -o+missing
 lvconvert -y -m+1 $vg/$lv2 "$dev1"
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
 
 vgchange -an $vg
 vgremove -f $vg
diff --git a/test/shell/vg-raid-takeover-4.sh b/test/shell/vg-raid-takeover-4.sh
index bdb78a215..8e29f2d7b 100644
--- a/test/shell/vg-raid-takeover-4.sh
+++ b/test/shell/vg-raid-takeover-4.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,110 +12,10 @@
 
 test_description='Test VG takeover with raid LVs'
 
-# test does not apply to lvmlockd
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
+CONTINUE_ELSEWHERE=y
+PREPARE_DEVS=4
 
-print_lvmlocal() {
-	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
-}
-
-. lib/inittest
-
-aux prepare_devs 4 1024
-
-SIDFILE="etc/lvm_test.conf"
-LVMLOCAL="etc/lvmlocal.conf"
-
-DFDIR="$LVM_SYSTEM_DIR/devices"
-DF="$DFDIR/system.devices"
-
-# Avoid system id validation in the devices file
-# which gets in the way of the test switching the
-# local system id.
-clear_df_systemid() {
-	if [[ -f $DF ]]; then
-		sed -e "s|SYSTEMID=.||" "$DF" > tmpdf
-		cp tmpdf $DF
-	fi
-}
-
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-clear_df_systemid
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-vgcreate $vg "$dev1" "$dev2" "$dev3"
-vgs -o+systemid,partial $vg
-check vg_field $vg systemid "$SID1"
-
-lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
-lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
-
-# give some time for raid init
-sleep 2
-lvs -a -o+devices $vg
-
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
-
-dd if=/dev/urandom of=pattern1 bs=512K count=1
-
-mount_dir="mnt_takeover"
-mkdir -p "$mount_dir"
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
-
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
-cp pattern1 $mount_dir/pattern1a
-cp pattern1 $mount_dir/pattern1b
-umount $mount_dir
-
-vgchange -an $vg
-
-# make the vg foreign
-vgchange --yes --systemid $SID2 $vg
-not vgs $vg
-
-# make one dev missing
-aux hide_dev "$dev1"
-
-# take over the vg, like cluster failover would do
-vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
-
-lvchange -ay --activationmode degraded $vg/$lv1
-lvchange -ay --activationmode degraded $vg/$lv2
-
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1b
-rm $mount_dir/pattern1b
-rm $mount_dir/file1
-cp pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
+. ./shell/vg-raid-takeover-1.sh
 
 # unhide_dev
 # the device reappears before the LVs are repaired
@@ -129,23 +29,9 @@ lvs -a -o+devices $vg
 
 vgextend --restoremissing $vg "$dev1"
 
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
+test_check_mount
 
-mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
-diff pattern1 $mount_dir/pattern1a
-diff pattern1 $mount_dir/pattern1c
-umount $mount_dir
-
-pvs -o+missing
-vgs -o+systemid,partial $vg
-lvs -a -o+devices $vg
 
 vgchange -an $vg
 vgremove -f $vg

