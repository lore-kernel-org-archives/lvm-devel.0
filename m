From: David Teigland <teigland@sourceware.org>
Date: Wed,  8 Mar 2023 22:34:42 +0000 (GMT)
Subject: main - tests: vg-raid-takeover
Message-ID: <20230308223442.C509F3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=937f1d320980b78b0d70cd778310bf31356ec6da
Commit:        937f1d320980b78b0d70cd778310bf31356ec6da
Parent:        aa85ed1784b2b8e731ac7bd05a8988bac30405f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 7 15:25:46 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 16:31:28 2023 -0600

tests: vg-raid-takeover

Different sequences of steps that could be used to handle raid LVs
after VG takeover (what would happen in cluster failover) combined
with the loss of a disk.
---
 test/shell/vg-raid-takeover-1.sh | 197 +++++++++++++++++++++++++++++++++++++++
 test/shell/vg-raid-takeover-2.sh | 188 +++++++++++++++++++++++++++++++++++++
 test/shell/vg-raid-takeover-3.sh | 171 +++++++++++++++++++++++++++++++++
 test/shell/vg-raid-takeover-4.sh | 151 ++++++++++++++++++++++++++++++
 4 files changed, 707 insertions(+)

diff --git a/test/shell/vg-raid-takeover-1.sh b/test/shell/vg-raid-takeover-1.sh
new file mode 100644
index 000000000..f186606a6
--- /dev/null
+++ b/test/shell/vg-raid-takeover-1.sh
@@ -0,0 +1,197 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test VG takeover with raid LVs'
+
+# test does not apply to lvmlockd
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+print_lvmlocal() {
+	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
+}
+
+. lib/inittest
+
+aux prepare_devs 3 1024
+
+SIDFILE="etc/lvm_test.conf"
+LVMLOCAL="etc/lvmlocal.conf"
+
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
+SID1=sidfoofile1
+SID2=sidfoofile2
+echo "$SID1" > "$SIDFILE"
+clear_df_systemid
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
+vgcreate $vg "$dev1" "$dev2" "$dev3"
+vgs -o+systemid,partial $vg
+check vg_field $vg systemid "$SID1"
+
+lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
+
+# give some time for raid init
+sleep 2
+lvs -a -o+devices $vg
+
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
+
+dd if=/dev/urandom of=pattern1 bs=512K count=1
+
+mount_dir="mnt_takeover"
+mkdir -p "$mount_dir"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+vgchange -an $vg
+
+# make the vg foreign
+vgchange --yes --systemid $SID2 $vg
+not vgs $vg
+
+# make one dev missing
+aux hide_dev "$dev1"
+
+# take over the vg, like cluster failover would do
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+lvchange -ay --activationmode degraded $vg/$lv1
+lvchange -ay --activationmode degraded $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# fails because the missing dev is used by lvs
+not vgreduce --removemissing $vg
+# works because lvs can be used with missing leg
+vgreduce --removemissing --mirrorsonly --force $vg
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# decline to repair (answer no)
+lvconvert --repair $vg/$lv1
+# fails to find another disk to use to repair
+not lvconvert -y --repair $vg/$lv2
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+aux unhide_dev "$dev1"
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+vgck --updatemetadata $vg
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# remove the failed unused leg, leaving 2 legs
+lvconvert -y -m-1 $vg/$lv2
+# remove the failed unused leg, leaving 1 leg
+lvconvert -y -m-1 $vg/$lv1
+
+pvs -o+missing
+vgs -o+systemid,partial,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+vgextend $vg "$dev1"
+lvconvert -y -m+1 $vg/$lv1 "$dev1"
+lvconvert -y -m+1 $vg/$lv2 "$dev1"
+
+# let raid sync new leg
+sleep 3
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+vgchange -an $vg
+vgremove -f $vg
diff --git a/test/shell/vg-raid-takeover-2.sh b/test/shell/vg-raid-takeover-2.sh
new file mode 100644
index 000000000..e0b46dece
--- /dev/null
+++ b/test/shell/vg-raid-takeover-2.sh
@@ -0,0 +1,188 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test VG takeover with raid LVs'
+
+# test does not apply to lvmlockd
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+print_lvmlocal() {
+	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
+}
+
+. lib/inittest
+
+aux prepare_devs 4 1024
+
+SIDFILE="etc/lvm_test.conf"
+LVMLOCAL="etc/lvmlocal.conf"
+
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
+SID1=sidfoofile1
+SID2=sidfoofile2
+echo "$SID1" > "$SIDFILE"
+clear_df_systemid
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
+vgcreate $vg "$dev1" "$dev2" "$dev3"
+vgs -o+systemid,partial $vg
+check vg_field $vg systemid "$SID1"
+
+lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
+
+# give some time for raid init
+sleep 2
+lvs -a -o+devices $vg
+
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
+
+dd if=/dev/urandom of=pattern1 bs=512K count=1
+
+mount_dir="mnt_takeover"
+mkdir -p "$mount_dir"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+vgchange -an $vg
+
+# make the vg foreign
+vgchange --yes --systemid $SID2 $vg
+not vgs $vg
+
+# make one dev missing
+aux hide_dev "$dev1"
+
+# take over the vg, like cluster failover would do
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+lvchange -ay --activationmode degraded $vg/$lv1
+lvchange -ay --activationmode degraded $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# fails because the missing dev is used by lvs
+not vgreduce --removemissing $vg
+# works because lvs can be used with missing leg
+vgreduce --removemissing --mirrorsonly --force $vg
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# unhide_dev before lvconvert --repair
+# i.e. the device reappears before the LVs are repaired
+
+aux unhide_dev "$dev1"
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# this repairs lv1 by using dev3 in place of dev1
+lvconvert -y --repair $vg/$lv1
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# add a new disk to use for replacing dev1 in lv2
+vgextend $vg "$dev4"
+
+lvconvert -y --repair $vg/$lv2
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+# let the new legs sync
+sleep 3
+
+vgck --updatemetadata $vg
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+vgchange -an $vg
+vgremove -f $vg
diff --git a/test/shell/vg-raid-takeover-3.sh b/test/shell/vg-raid-takeover-3.sh
new file mode 100644
index 000000000..5df53d1d7
--- /dev/null
+++ b/test/shell/vg-raid-takeover-3.sh
@@ -0,0 +1,171 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test VG takeover with raid LVs'
+
+# test does not apply to lvmlockd
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+print_lvmlocal() {
+	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
+}
+
+. lib/inittest
+
+aux prepare_devs 3 1024
+
+SIDFILE="etc/lvm_test.conf"
+LVMLOCAL="etc/lvmlocal.conf"
+
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
+SID1=sidfoofile1
+SID2=sidfoofile2
+echo "$SID1" > "$SIDFILE"
+clear_df_systemid
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
+vgcreate $vg "$dev1" "$dev2" "$dev3"
+vgs -o+systemid,partial $vg
+check vg_field $vg systemid "$SID1"
+
+lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
+
+# give some time for raid init
+sleep 2
+lvs -a -o+devices $vg
+
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
+
+dd if=/dev/urandom of=pattern1 bs=512K count=1
+
+mount_dir="mnt_takeover"
+mkdir -p "$mount_dir"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+vgchange -an $vg
+
+# make the vg foreign
+vgchange --yes --systemid $SID2 $vg
+not vgs $vg
+
+# make one dev missing
+aux hide_dev "$dev1"
+
+# take over the vg, like cluster failover would do
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+lvchange -ay --activationmode degraded $vg/$lv1
+lvchange -ay --activationmode degraded $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# replaces dev1 with dev3
+lvconvert -y --repair $vg/$lv1
+
+# no other disk to replace dev1 so remove the leg,
+# but that's not allowed until the missing disk is removed from the vg
+not lvconvert -y -m-1 $vg/$lv2
+vgreduce --removemissing --mirrorsonly --force $vg
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+lvconvert -y -m-1 $vg/$lv2
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+aux unhide_dev "$dev1"
+
+# put dev1 back into lv2,
+# requires clearing outdated metadata and putting dev1 back in vg
+vgck --updatemetadata $vg
+pvs -o+missing
+vgextend $vg "$dev1"
+pvs -o+missing
+lvconvert -y -m+1 $vg/$lv2 "$dev1"
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+vgchange -an $vg
+vgremove -f $vg
diff --git a/test/shell/vg-raid-takeover-4.sh b/test/shell/vg-raid-takeover-4.sh
new file mode 100644
index 000000000..bdb78a215
--- /dev/null
+++ b/test/shell/vg-raid-takeover-4.sh
@@ -0,0 +1,151 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test VG takeover with raid LVs'
+
+# test does not apply to lvmlockd
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+print_lvmlocal() {
+	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
+}
+
+. lib/inittest
+
+aux prepare_devs 4 1024
+
+SIDFILE="etc/lvm_test.conf"
+LVMLOCAL="etc/lvmlocal.conf"
+
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
+SID1=sidfoofile1
+SID2=sidfoofile2
+echo "$SID1" > "$SIDFILE"
+clear_df_systemid
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
+vgcreate $vg "$dev1" "$dev2" "$dev3"
+vgs -o+systemid,partial $vg
+check vg_field $vg systemid "$SID1"
+
+lvcreate --type raid1 -L 400 -m1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 400 -m2 -n $lv2 $vg "$dev1" "$dev2" "$dev3"
+
+# give some time for raid init
+sleep 2
+lvs -a -o+devices $vg
+
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv2"
+
+dd if=/dev/urandom of=pattern1 bs=512K count=1
+
+mount_dir="mnt_takeover"
+mkdir -p "$mount_dir"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd if=/dev/zero of=$mount_dir/file1 bs=4096 count=1024
+cp pattern1 $mount_dir/pattern1a
+cp pattern1 $mount_dir/pattern1b
+umount $mount_dir
+
+vgchange -an $vg
+
+# make the vg foreign
+vgchange --yes --systemid $SID2 $vg
+not vgs $vg
+
+# make one dev missing
+aux hide_dev "$dev1"
+
+# take over the vg, like cluster failover would do
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID2}\"]" --systemid $SID1 $vg
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+lvchange -ay --activationmode degraded $vg/$lv1
+lvchange -ay --activationmode degraded $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+dd of=/dev/null if=$mount_dir/file1 bs=4096 count=1024
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1b
+rm $mount_dir/pattern1b
+rm $mount_dir/file1
+cp pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+# unhide_dev
+# the device reappears before the LVs are repaired
+# and before the missing dev is removed from the vg
+
+aux unhide_dev "$dev1"
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+vgextend --restoremissing $vg "$dev1"
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+mount "$DM_DEV_DIR/$vg/$lv2" $mount_dir
+diff pattern1 $mount_dir/pattern1a
+diff pattern1 $mount_dir/pattern1c
+umount $mount_dir
+
+pvs -o+missing
+vgs -o+systemid,partial $vg
+lvs -a -o+devices $vg
+
+vgchange -an $vg
+vgremove -f $vg

