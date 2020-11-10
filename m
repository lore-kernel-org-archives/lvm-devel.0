From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Nov 2020 23:43:29 +0000 (GMT)
Subject: main - tests: update integrity tests
Message-ID: <20201110234329.5CBDC3851C2B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2317ba393459a8848a83b43891188520c6a06559
Commit:        2317ba393459a8848a83b43891188520c6a06559
Parent:        d7058cfa989762ad33f115528d572cda80918cca
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 10 17:41:04 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 10 17:41:04 2020 -0600

tests: update integrity tests

simplified the method of corrupting data, the old method
was not working reliably.  moved syncation tests to a
different file
---
 test/shell/integrity-syncaction.sh | 206 ++++++++++++++++++++++++++
 test/shell/integrity.sh            | 286 +++++++++----------------------------
 2 files changed, 275 insertions(+), 217 deletions(-)

diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
new file mode 100644
index 000000000..d26855665
--- /dev/null
+++ b/test/shell/integrity-syncaction.sh
@@ -0,0 +1,206 @@
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
+which mkfs.xfs || skip
+which xfs_growfs || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+aux prepare_devs 3 40
+
+# Use awk instead of anoyingly long log out from printf
+#printf "%0.sA" {1..16384} >> fileA
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
+
+_prepare_vg() {
+	# zero devs so we are sure to find the correct file data
+	# on the underlying devs when corrupting it
+	dd if=/dev/zero of="$dev1" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev2" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev3" bs=1M oflag=direct || true
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+	pvs
+}
+
+_test1() {
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# we don't want fileA to be located too early in the fs,
+	# otherwise activating the LV will trigger the corruption
+	# to be found and corrected, leaving nothing for syncaction
+	# to find and correct.
+	dd if=/dev/urandom of=$mnt/rand16M bs=1M count=16
+
+	cp fileA $mnt
+	cp fileB $mnt
+	cp fileC $mnt
+
+	umount $mnt
+	lvchange -an $vg/$lv1
+
+	xxd "$dev1" > dev1.txt
+	# corrupt fileB
+	sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.txt > dev1.bad
+	rm -f dev1.txt
+	xxd -r dev1.bad > "$dev1"
+	rm -f dev1.bad
+
+	lvchange -ay $vg/$lv1
+
+	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+	grep 0 mismatch
+
+	lvchange --syncaction check $vg/$lv1
+
+	_wait_recalc $vg/$lv1
+
+	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+	not grep 0 mismatch
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+	cmp -b $mnt/fileA fileA
+	cmp -b $mnt/fileB fileB
+	cmp -b $mnt/fileC fileC
+	umount $mnt
+}
+
+_test2() {
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# we don't want fileA to be located too early in the fs,
+	# otherwise activating the LV will trigger the corruption
+	# to be found and corrected, leaving nothing for syncaction
+	# to find and correct.
+	dd if=/dev/urandom of=$mnt/rand16M bs=1M count=16
+
+	cp fileA $mnt
+	cp fileB $mnt
+	cp fileC $mnt
+
+	umount $mnt
+	lvchange -an $vg/$lv1
+
+	# corrupt fileB and fileC on dev1
+	xxd "$dev1" > dev1.txt
+	sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.txt > dev1.bad
+	sed -e 's/4343 4343 4343 4343 4343 4343 4343 4343/4444 4444 4444 4444 4444 4444 4444 4444/' dev1.txt > dev1.bad
+	rm -f dev1.txt
+	xxd -r dev1.bad > "$dev1"
+	rm -f dev1.bad
+
+	# corrupt fileA on dev2
+	xxd "$dev2" > dev2.txt
+	sed -e 's/4141 4141 4141 4141 4141 4141 4141 4141/4141 4141 4141 4141 4141 4141 4145 4141/' dev2.txt > dev2.bad
+	rm -f dev2.txt
+	xxd -r dev2.bad > "$dev2"
+	rm -f dev2.bad
+
+	lvchange -ay $vg/$lv1
+
+	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+	grep 0 mismatch
+	lvs -o integritymismatches $vg/${lv1}_rimage_1 |tee mismatch
+	grep 0 mismatch
+
+	lvchange --syncaction check $vg/$lv1
+
+	_wait_recalc $vg/$lv1
+
+	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+	not grep 0 mismatch
+	lvs -o integritymismatches $vg/${lv1}_rimage_1 |tee mismatch
+	not grep 0 mismatch
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+	cmp -b $mnt/fileA fileA
+	cmp -b $mnt/fileB fileB
+	cmp -b $mnt/fileC fileC
+	umount $mnt
+}
+
+_sync_percent() {
+	local checklv=$1
+	get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+	local checklv=$1
+
+	for i in $(seq 1 10) ; do
+		sync=$(_sync_percent "$checklv")
+		echo "sync_percent is $sync"
+
+		if test "$sync" = "100"; then
+			return
+		fi
+
+		sleep 1
+	done
+
+	# TODO: There is some strange bug, first leg of RAID with integrity
+	# enabled never gets in sync. I saw this in BB, but not when executing
+	# the commands manually
+	if test -z "$sync"; then
+		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+		exit
+	fi
+	echo "timeout waiting for recalc"
+	return 1
+}
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+_test1
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+_test2
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2" "$dev3"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
+_test1
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 7dd237b93..e17862595 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -46,109 +46,14 @@ _prepare_vg() {
 	pvs
 }
 
-_test_fs_with_error() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
-
-	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-
-	# add original data
-	cp fileA $mnt
-	cp fileB $mnt
-	cp fileC $mnt
-
-	umount $mnt
-	lvchange -an $vg/$lv1
-
-	# corrupt the original data on the underying dev
-	# flip one bit in fileB, changing a 0x42 to 0x43
-	# the bit is changed in the last 4096 byte block
-	# of the file, so when reading back the file we
-	# will get the first three 4096 byte blocks, for
-	# a total of 12288 bytes before getting an error
-	# on the last 4096 byte block.
-	xxd "$dev1" > dev1.txt
-	tac dev1.txt > dev1.rev
-	rm -f dev1.txt
-	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
-	rm -f dev1.rev
-	tac dev1.rev.bad > dev1.bad
-	rm -f dev1.rev.bad
-	xxd -r dev1.bad > "$dev1"
-	rm -f dev1.bad
-
-	lvchange -ay $vg/$lv1
-	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-
-	# read complete fileA which was not corrupted
-	dd if=$mnt/fileA of=tmp bs=1k
-	ls -l tmp
-	stat -c %s tmp
-	cmp -b fileA tmp
-	rm tmp
-
-	# read partial fileB which was corrupted
-	not dd if=$mnt/fileB of=tmp bs=1k
-	ls -l tmp
-	stat -c %s tmp | grep 12288
-	not cmp -b fileB tmp
-	rm tmp
-
-	umount $mnt
-}
-
 _test_fs_with_read_repair() {
 	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
-	# add original data
-	cp fileA $mnt
-	cp fileB $mnt
-	cp fileC $mnt
-
-	umount $mnt
-	lvchange -an $vg/$lv1
-
-	# FIXME: this is only finding/corrupting the bit with raid1
-	# other raid levels may require looking at a different dev.
-	# (Attempt this xxd/tac/sed/xxd on each dev in the LV?)
-
-	xxd "$dev1" > dev1.txt
-	tac dev1.txt > dev1.rev
-	rm -f dev1.txt
-	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
-	rm -f dev1.rev
-	tac dev1.rev.bad > dev1.bad
-	rm -f dev1.rev.bad
-	xxd -r dev1.bad > "$dev1"
-	rm -f dev1.bad
-
-	lvchange -ay $vg/$lv1
-	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-
-	# read complete fileA which was not corrupted
-	dd if=$mnt/fileA of=tmp bs=1k
-	ls -l tmp
-	stat -c %s tmp | grep 16384
-	cmp -b fileA tmp
-	rm tmp
-
-	# read complete fileB, corruption is corrected by raid
-	dd if=$mnt/fileB of=tmp bs=1k
-	ls -l tmp
-	stat -c %s tmp | grep 16384
-	cmp -b fileB tmp
-	rm tmp
-
-	umount $mnt
-}
-
-_test_fs_with_syncaction_check() {
-	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
-
-	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
-
-	# add original data
+	cp randA $mnt
+	cp randB $mnt
+	cp randC $mnt
 	cp fileA $mnt
 	cp fileB $mnt
 	cp fileC $mnt
@@ -156,40 +61,23 @@ _test_fs_with_syncaction_check() {
 	umount $mnt
 	lvchange -an $vg/$lv1
 
-	# FIXME: this is only finding/corrupting the bit with raid1
-	# other raid levels may require looking at a different dev.
-	# (Attempt this xxd/tac/sed/xxd on each dev in the LV?)
-
 	xxd "$dev1" > dev1.txt
-	tac dev1.txt > dev1.rev
+	# corrupt fileB
+	sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.txt > dev1.bad
 	rm -f dev1.txt
-	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
-	rm -f dev1.rev
-	tac dev1.rev.bad > dev1.bad
-	rm -f dev1.rev.bad
 	xxd -r dev1.bad > "$dev1"
 	rm -f dev1.bad
 
 	lvchange -ay $vg/$lv1
 
-	lvchange --syncaction check $vg/$lv1
+	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+	grep 0 mismatch
 
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 
-	# read complete fileA which was not corrupted
-	dd if=$mnt/fileA of=tmp bs=1k
-	ls -l tmp
-	stat -c %s tmp | grep 16384
-	cmp -b fileA tmp
-	rm tmp
-
-	# read complete fileB
-	dd if=$mnt/fileB of=tmp bs=1k
-	ls -l tmp
-	stat -c %s tmp | grep 16384
-	cmp -b fileB tmp
-	rm tmp
-
+	cmp -b $mnt/fileA fileA
+	cmp -b $mnt/fileB fileB
+	cmp -b $mnt/fileC fileC
 	umount $mnt
 }
 
@@ -282,36 +170,38 @@ _wait_recalc() {
 # it is detected by integrity and corrected by raid.
 
 _prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
-lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -322,10 +212,11 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -336,12 +227,13 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/${lv1}_rimage_4
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -354,11 +246,12 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -369,94 +262,13 @@ lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
 vgremove -ff $vg
 
-# Test corrupting data on an image and verifying that
-# it is detected and corrected using syncaction check
-
-_prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_test_fs_with_syncaction_check
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
-check lv_field $vg/${lv1}_rimage_0 integritymismatches "1"
-check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
-lvchange -an $vg/$lv1
-lvconvert --raidintegrity n $vg/$lv1
-lvremove $vg/$lv1
-vgremove -ff $vg
-
-_prepare_vg
-lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_test_fs_with_syncaction_check
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
-lvs -o integritymismatches $vg/${lv1}_rimage_2
-check lv_field $vg/${lv1}_rimage_0 integritymismatches "2"
-check lv_field $vg/${lv1}_rimage_1 integritymismatches "0"
-check lv_field $vg/${lv1}_rimage_2 integritymismatches "0"
-lvchange -an $vg/$lv1
-lvconvert --raidintegrity n $vg/$lv1
-lvremove $vg/$lv1
-vgremove -ff $vg
-
-_prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_test_fs_with_syncaction_check
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
-lvs -o integritymismatches $vg/${lv1}_rimage_2
-lvchange -an $vg/$lv1
-lvconvert --raidintegrity n $vg/$lv1
-lvremove $vg/$lv1
-vgremove -ff $vg
-
-_prepare_vg
-lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
-_test_fs_with_syncaction_check
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
-lvs -o integritymismatches $vg/${lv1}_rimage_2
-lvs -o integritymismatches $vg/${lv1}_rimage_3
-lvs -o integritymismatches $vg/${lv1}_rimage_4
-lvchange -an $vg/$lv1
-lvconvert --raidintegrity n $vg/$lv1
-lvremove $vg/$lv1
-vgremove -ff $vg
-
-_prepare_vg
-lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_test_fs_with_syncaction_check
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
-lvs -o integritymismatches $vg/${lv1}_rimage_2
-lvs -o integritymismatches $vg/${lv1}_rimage_3
-lvchange -an $vg/$lv1
-lvconvert --raidintegrity n $vg/$lv1
-lvremove $vg/$lv1
-vgremove -ff $vg
-
 # Test removing integrity from an active LV
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -471,6 +283,8 @@ _prepare_vg
 lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -485,6 +299,8 @@ _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -499,6 +315,10 @@ _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -513,6 +333,7 @@ _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -527,6 +348,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
@@ -541,6 +363,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid4 -n $lv1 -l 8 $vg
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
@@ -555,6 +378,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 -n $lv1 -l 8 $vg
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
@@ -569,6 +393,12 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
@@ -583,6 +413,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid10 -n $lv1 -l 8 $vg
+_wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
@@ -601,6 +432,7 @@ _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 umount $mnt
@@ -624,6 +456,10 @@ _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 umount $mnt
@@ -649,6 +485,7 @@ _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
@@ -668,6 +505,8 @@ _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
@@ -687,6 +526,7 @@ _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
@@ -708,6 +548,7 @@ _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvconvert -y -m+1 $vg/$lv1
@@ -730,6 +571,7 @@ lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvconvert -y -m-1 $vg/$lv1
@@ -748,6 +590,7 @@ _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 not lvconvert -y -m-1 $vg/$lv1
@@ -769,9 +612,12 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
-lvs -o integritymismatches $vg/${lv1}_rimage_0
-lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
+not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -779,6 +625,12 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
+_wait_recalc $vg/$lv1
 _test_fs_with_read_repair
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1


