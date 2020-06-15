From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 Jun 2020 21:05:12 +0000 (GMT)
Subject: master - tests: integrity and block size
Message-ID: <20200615210512.98CD2388B026@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a014c4f3411f6b2f6c4c721a84253eed46cc3de6
Commit:        a014c4f3411f6b2f6c4c721a84253eed46cc3de6
Parent:        8e2938c963bb8226b72297647bef89895e5ae548
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 15 14:08:28 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 15 16:04:40 2020 -0500

tests: integrity and block size

---
 test/shell/integrity-blocksize-2.sh | 127 ++++++++++++++++
 test/shell/integrity-blocksize-3.sh | 284 ++++++++++++++++++++++++++++++++++++
 test/shell/integrity-blocksize.sh   |  46 ++++--
 test/shell/integrity-large.sh       |   3 +
 4 files changed, 445 insertions(+), 15 deletions(-)

diff --git a/test/shell/integrity-blocksize-2.sh b/test/shell/integrity-blocksize-2.sh
new file mode 100644
index 000000000..a7bb71f9a
--- /dev/null
+++ b/test/shell/integrity-blocksize-2.sh
@@ -0,0 +1,127 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+_sync_percent() {
+        local checklv=$1
+        get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+        local checklv=$1
+
+        for i in $(seq 1 10) ; do
+                sync=$(_sync_percent "$checklv")
+                echo "sync_percent is $sync"
+
+                if test "$sync" = "100"; then
+                        return
+                fi
+
+                sleep 1
+        done
+
+        # TODO: There is some strange bug, first leg of RAID with integrity
+        # enabled never gets in sync. I saw this in BB, but not when executing
+        # the commands manually
+        if test -z "$sync"; then
+                echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+                exit
+        fi
+        echo "timeout waiting for recalc"
+        return 1
+}
+
+# prepare_devs uses ramdisk backing which has 512 LBS and 4K PBS
+# This should cause mkfs.xfs to use 4K sector size,
+# and integrity to use 4K block size
+aux prepare_devs 2 64
+
+vgcreate $vg "$dev1" "$dev2"
+blockdev --getss "$dev1"
+blockdev --getpbsz "$dev1"
+blockdev --getss "$dev2"
+blockdev --getpbsz "$dev2"
+
+# add integrity while LV is inactive
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvconvert --raidintegrity y $vg/$lv1
+lvchange -ay $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# FIXME: the second xfs mount fails related to block size and converting active LV, bug 1847180
+# add integrity while LV is active, fs unmounted
+#lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+#lvchange -an $vg/$lv1
+#lvchange -ay $vg/$lv1
+#mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+#echo "hello world" > $mnt/hello
+#umount $mnt
+#lvchange -an $vg
+#lvchange -ay $vg
+#lvconvert --raidintegrity y $vg/$lv1
+#_wait_recalc $vg/${lv1}_rimage_0
+#_wait_recalc $vg/${lv1}_rimage_1
+#lvs -a -o+devices $vg
+#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+#cat $mnt/hello | grep "hello world"
+#umount $mnt
+#lvchange -an $vg/$lv1
+#lvremove $vg/$lv1
+
+# add integrity while LV is active, fs mounted
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+vgremove -ff $vg
+
diff --git a/test/shell/integrity-blocksize-3.sh b/test/shell/integrity-blocksize-3.sh
new file mode 100644
index 000000000..7170aa907
--- /dev/null
+++ b/test/shell/integrity-blocksize-3.sh
@@ -0,0 +1,284 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+_sync_percent() {
+        local checklv=$1
+        get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+        local checklv=$1
+
+        for i in $(seq 1 10) ; do
+                sync=$(_sync_percent "$checklv")
+                echo "sync_percent is $sync"
+
+                if test "$sync" = "100"; then
+                        return
+                fi
+
+                sleep 1
+        done
+
+        # TODO: There is some strange bug, first leg of RAID with integrity
+        # enabled never gets in sync. I saw this in BB, but not when executing
+        # the commands manually
+        if test -z "$sync"; then
+                echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+                exit
+        fi
+        echo "timeout waiting for recalc"
+        return 1
+}
+
+# scsi_debug devices with 512 LBS 512 PBS
+aux prepare_scsi_debug_dev 256
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "512"
+aux prepare_devs 2 64
+
+vgcreate $vg "$dev1" "$dev2"
+blockdev --getss "$dev1"
+blockdev --getpbsz "$dev1"
+blockdev --getss "$dev2"
+blockdev --getpbsz "$dev2"
+
+# add integrity while LV is inactive
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvconvert --raidintegrity y $vg/$lv1
+lvchange -ay $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# add integrity while LV is active, fs unmounted
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvchange -ay $vg
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# add integrity while LV is active, fs mounted
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+vgremove -ff $vg
+aux cleanup_scsi_debug_dev
+sleep 1
+
+# scsi_debug devices with 4K LBS and 4K PBS
+aux prepare_scsi_debug_dev 256 sector_size=4096
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "4096"
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "4096"
+aux prepare_devs 2 64
+
+vgcreate $vg "$dev1" "$dev2"
+blockdev --getss "$dev1"
+blockdev --getpbsz "$dev1"
+blockdev --getss "$dev2"
+blockdev --getpbsz "$dev2"
+
+# add integrity while LV is inactive
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvconvert --raidintegrity y $vg/$lv1
+lvchange -ay $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# add integrity while LV is active, fs unmounted
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvchange -ay $vg
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# add integrity while LV is active, fs mounted
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+vgremove -ff $vg
+aux cleanup_scsi_debug_dev
+sleep 1
+
+# scsi_debug devices with 512 LBS and 4K PBS
+aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size "4096"
+aux prepare_devs 2 64
+
+vgcreate $vg "$dev1" "$dev2"
+blockdev --getss "$dev1"
+blockdev --getpbsz "$dev1"
+blockdev --getss "$dev2"
+blockdev --getpbsz "$dev2"
+
+# add integrity while LV is inactive
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+umount $mnt
+lvchange -an $vg
+lvconvert --raidintegrity y $vg/$lv1
+lvchange -ay $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# FIXME: second xfs mount fails related to block size and converting active LV, bug 1847180
+# add integrity while LV is active, fs unmounted
+#lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+#lvchange -an $vg/$lv1
+#lvchange -ay $vg/$lv1
+#mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+#echo "hello world" > $mnt/hello
+#umount $mnt
+#lvchange -an $vg
+#lvchange -ay $vg
+#lvconvert --raidintegrity y $vg/$lv1
+#_wait_recalc $vg/${lv1}_rimage_0
+#_wait_recalc $vg/${lv1}_rimage_1
+#lvs -a -o+devices $vg
+#mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+#cat $mnt/hello | grep "hello world"
+#umount $mnt
+#lvchange -an $vg/$lv1
+#lvremove $vg/$lv1
+
+# add integrity while LV is active, fs mounted
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+echo "hello world" > $mnt/hello
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+cat $mnt/hello | grep "hello world"
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+vgremove -ff $vg
+aux cleanup_scsi_debug_dev
+sleep 1
+
diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 8c4b94d49..a829502d1 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -54,6 +54,18 @@ mkdir -p $mnt
 vgcreate $vg1 $LOOP1 $LOOP2
 vgcreate $vg2 $LOOP3 $LOOP4
 
+# LOOP1/LOOP2 have LBS 512 and PBS 512
+# LOOP3/LOOP4 have LBS 4K and PBS 4K
+
+blockdev --getss $LOOP1
+blockdev --getpbsz $LOOP1
+blockdev --getss $LOOP2
+blockdev --getpbsz $LOOP2
+blockdev --getss $LOOP3
+blockdev --getpbsz $LOOP3
+blockdev --getss $LOOP4
+blockdev --getpbsz $LOOP4
+
 # lvcreate on dev512, result 512
 lvcreate --type raid1 -m1 --raidintegrity y -l 8 -n $lv1 $vg1
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -164,18 +176,22 @@ umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvremove -y $vg1/$lv1
 
-# FIXME: kernel error reported, disallow this combination?
+# FIXME: if lv is active while integrity is added, then xfs mount fails related to block size, bug 1847180
 # lvconvert --bs 1024 on dev512, xfs 4096, result 1024
-#lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
-#aux wipefs_a /dev/$vg1/$lv1
-#mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
-#blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
-#lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
-#blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
-#mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
-#umount $mnt
-#pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
-#lvremove -y $vg1/$lv1
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+# TODO: also test adding integrity when the lv is active,
+# and also when the lv is active and fs is mounted?
+lvchange -an $vg1/$lv1
+lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
+lvchange -ay $vg1/$lv1
+blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
+umount $mnt
+pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
+lvremove -y $vg1/$lv1
 
 # lvconvert --bs 512 on dev512, ext4 1024, result 512
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
@@ -196,10 +212,10 @@ mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
 not lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg2/$lv1
 lvremove -y $vg2/$lv1
 
-# FIXME: need to use scsi_debug to create devs with LBS 512 PBS 4k
-# FIXME: lvconvert, fsunknown, LBS 512, PBS 4k: result 512
-# FIXME: lvconvert --bs 512, fsunknown, LBS 512, PBS 4k: result 512
-# FIXME: lvconvert --bs 4k, fsunknown, LBS 512, PBS 4k: result 4k
+# TODO: need to use scsi_debug to create devs with LBS 512 PBS 4k
+# TODO: lvconvert, fsunknown, LBS 512, PBS 4k: result 512
+# TODO: lvconvert --bs 512, fsunknown, LBS 512, PBS 4k: result 512
+# TODO: lvconvert --bs 4k, fsunknown, LBS 512, PBS 4k: result 4k
 
 # lvconvert on dev512, xfs 512, result 512, (detect fs with LV inactive)
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 5aba80e6a..016d100d9 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -115,7 +115,10 @@ lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
 _add_data_to_lv
+lvchange -an $vg/$lv1
+# FIXME: if lv remains active during convert, then xfs mount fails related to block size, bug 1847180
 lvconvert --raidintegrity y $vg/$lv1
+lvchange -ay $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg


