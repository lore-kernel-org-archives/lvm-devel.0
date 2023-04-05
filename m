From: David Teigland <teigland@sourceware.org>
Date: Wed,  5 Apr 2023 19:25:35 +0000 (GMT)
Subject: main - raidintegrity: allow writecache and cache
Message-ID: <20230405192535.DFC313858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=390ff5be2fd9dda47f2bfd2db96de64acc925002
Commit:        390ff5be2fd9dda47f2bfd2db96de64acc925002
Parent:        ebbc3f7ab31e8026499bddd93cde4db4921d2132
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 17 16:39:48 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 5 14:24:07 2023 -0500

raidintegrity: allow writecache and cache

Allow writecache|cache over raid+integrity LV.
---
 lib/metadata/snapshot_manip.c   |   9 +
 test/shell/integrity-caching.sh | 561 ++++++++++++++++++++++++++++++++++++++++
 tools/command-lines.in          |   5 -
 tools/pvmove.c                  |   8 +
 4 files changed, 578 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 99eb9c30d..822b8da77 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -391,6 +391,14 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 {
 	const char *err = NULL; /* For error string */
 
+	if (lv_is_cache(origin_lv) || lv_is_writecache(origin_lv)) {
+		struct logical_volume *lv = seg_lv(first_seg(origin_lv), 0);
+		if (lv_is_raid(lv) && lv_raid_has_integrity(lv)) {
+			err = "raid with integrity";
+			goto out;
+		}
+	}
+
 	if (lv_is_cow(origin_lv))
 		err = "snapshots";
 	else if (lv_is_locked(origin_lv))
@@ -419,6 +427,7 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 		err = "raid with integrity";
 	}
 
+ out:
 	if (err) {
 		log_error("Snapshots of %s are not supported.", err);
 		return 0;
diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
new file mode 100644
index 000000000..158a31932
--- /dev/null
+++ b/test/shell/integrity-caching.sh
@@ -0,0 +1,561 @@
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
+which mkfs.xfs || skip
+which xfs_growfs || skip
+aux have_integrity 1 5 0 || skip
+# Avoid 4K ramdisk devices on older kernels
+aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
+
+mnt="mnt"
+mkdir -p $mnt
+
+aux prepare_devs 6 80
+
+# Use awk instead of anoyingly long log out from printf
+#printf "%0.sA" {1..16384} >> fileA
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
+
+# generate random data
+dd if=/dev/urandom of=randA bs=512K count=2
+dd if=/dev/urandom of=randB bs=512K count=3
+dd if=/dev/urandom of=randC bs=512K count=4
+
+_prepare_vg() {
+	# zero devs so we are sure to find the correct file data
+	# on the underlying devs when corrupting it
+	dd if=/dev/zero of="$dev1" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev2" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev3" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev4" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev5" bs=1M oflag=direct || true
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+	pvs
+}
+
+_test_fs_with_read_repair() {
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	cp randA $mnt
+	cp randB $mnt
+	cp randC $mnt
+	cp fileA $mnt
+	cp fileB $mnt
+	cp fileC $mnt
+
+	# The files written above are in the writecache so reading
+	# them back later will come from the writecache and not from the
+	# corrupted dev.  Write a bunch of new data to the fs to clear
+	# the original files from the writecache, so when they are read
+	# back the data will hopefully come from the underlying disk and
+	# trigger reading the corrupted data.
+	mkdir $mnt/new1
+	cat randA > $mnt/new1/randA
+	cat randB > $mnt/new1/randB
+	cat randC > $mnt/new1/randC
+	sync
+	du -h $mnt/new1
+	cp -r $mnt/new1 $mnt/new2 || true
+	cp -r $mnt/new1 $mnt/new3 || true
+	cp -r $mnt/new1 $mnt/new4 || true
+	sync
+	du -h $mnt
+	df -h
+	# hopefully fileA is no longer in the writecache.
+
+	umount $mnt
+	lvchange -an $vg/$lv1
+
+	for dev in "$@"; do
+		xxd "$dev" > dev.txt
+		# corrupt fileB
+		sed -e 's/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev.txt > dev.bad
+		rm -f dev.txt
+		xxd -r dev.bad > "$dev"
+		rm -f dev.bad
+	done
+
+	lvchange -ay $vg/$lv1
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	cmp -b $mnt/fileA fileA
+	cmp -b $mnt/fileB fileB
+	cmp -b $mnt/fileC fileC
+	umount $mnt
+}
+
+_add_new_data_to_mnt() {
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# add original data
+	cp randA $mnt
+	cp randB $mnt
+	cp randC $mnt
+	mkdir $mnt/1
+	cp fileA $mnt/1
+	cp fileB $mnt/1
+	cp fileC $mnt/1
+	mkdir $mnt/2
+	cp fileA $mnt/2
+	cp fileB $mnt/2
+	cp fileC $mnt/2
+}
+
+_add_more_data_to_mnt() {
+	mkdir $mnt/more
+	cp fileA $mnt/more
+	cp fileB $mnt/more
+	cp fileC $mnt/more
+	cp randA $mnt/more
+	cp randB $mnt/more
+	cp randC $mnt/more
+}
+
+_verify_data_on_mnt() {
+	cmp -b randA $mnt/randA
+	cmp -b randB $mnt/randB
+	cmp -b randC $mnt/randC
+	cmp -b fileA $mnt/1/fileA
+	cmp -b fileB $mnt/1/fileB
+	cmp -b fileC $mnt/1/fileC
+	cmp -b fileA $mnt/2/fileA
+	cmp -b fileB $mnt/2/fileB
+	cmp -b fileC $mnt/2/fileC
+}
+
+_verify_data_on_lv() {
+	lvchange -ay $vg/$lv1
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+	_verify_data_on_mnt
+	rm $mnt/randA
+	rm $mnt/randB
+	rm $mnt/randC
+	rm -rf $mnt/1
+	rm -rf $mnt/2
+	umount $mnt
+	lvchange -an $vg/$lv1
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
+#	if test -z "$sync"; then
+#		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
+#               dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+#		exit
+#	fi
+	echo "timeout waiting for recalc"
+	dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+	return 1
+}
+
+# lv1 is a raid+integrity LV
+# three variations of caching on lv1:
+#
+# 1. lvcreate --type cache-pool -n fast -l 4 $vg $dev6
+#    lvconvert --type cache --cachepool fast $vg/$lv1
+#
+# 2. lvcreate --type linear -n fast -l 4 $vg $dev6
+#    lvconvert --type cache --cachvol fast $vg/$lv1
+#
+# 3. lvcreate --type linear -n fast -l 4 $vg $dev6
+#    lvconvert --type writecache --cachvol fast $vg/$lv1
+
+do_test() {
+
+# --cachepool | --cachevol
+local create_type=$1
+
+# cache | writecache
+local convert_type=$2
+
+# --type cache-pool | --type linear
+local convert_option=$3
+
+# corig | wcorig
+local suffix=$4
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}
+_test_fs_with_read_repair "$dev1"
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0 |tee mismatch
+not grep ' 0 ' mismatch
+lvs -o integritymismatches $vg/${lv1}_${suffix} |tee mismatch
+not grep ' 0 ' mismatch
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/${lv1}_${suffix}
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}_rimage_2
+_wait_recalc $vg/${lv1}_${suffix}
+_test_fs_with_read_repair "$dev1" "$dev2"
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0 |tee mismatch
+not grep ' 0 ' mismatch
+lvs -o integritymismatches $vg/${lv1}_${suffix} |tee mismatch
+not grep ' 0 ' mismatch
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/${lv1}_${suffix}
+lvconvert --splitcache $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}_rimage_2
+_wait_recalc $vg/${lv1}_${suffix}
+_test_fs_with_read_repair "$dev1" "$dev2" "$dev3"
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_${suffix} |tee mismatch
+not grep ' 0 ' mismatch
+lvconvert --splitcache $vg/$lv1
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test removing integrity from an active LV
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/${lv1}_${suffix}
+_add_more_data_to_mnt
+lvconvert --splitcache $vg/$lv1
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test adding integrity to an active LV
+
+_prepare_vg
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+# Can only be enabled while raid is top level lv (for now.)
+not lvconvert --raidintegrity y $vg/${lv1}_${suffix}
+#_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+#_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test lvextend while inactive
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvextend -l 16 $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test lvextend while active
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+lvextend -l 16 $vg/$lv1
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+lvextend -l 16 $vg/$lv1
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test adding image to raid1
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+# currently only allowed while raid is top level lv
+not lvconvert -y -m+1 $vg/${lv1}_${suffix}
+#_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+#_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+#_wait_recalc $vg/${lv1}_${suffix}_rimage_2
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test removing image from raid1
+
+_prepare_vg
+lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+lvconvert -y -m-1 $vg/${lv1}_${suffix}
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test disallowed operations on raid+integrity
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+not lvconvert -y -m-1 $vg/$lv1
+not lvconvert -y -m-1 $vg/${lv1}_${suffix}
+not lvconvert --splitmirrors 1 -n tmp -y $vg/$lv1
+not lvconvert --splitmirrors 1 -n tmp -y $vg/${lv1}_${suffix}
+not lvconvert --splitmirrors 1 --trackchanges -y $vg/$lv1
+not lvconvert --splitmirrors 1 --trackchanges -y $vg/${lv1}_${suffix}
+not lvchange --syncaction repair $vg/$lv1
+not lvchange --syncaction repair $vg/${lv1}_${suffix}
+not lvreduce -L4M $vg/$lv1
+not lvreduce -L4M $vg/${lv1}_${suffix}
+not lvcreate -s -n snap -L4M $vg/${lv1}_${suffix}
+# plan to enable snap on top level raid+integrity, so then
+# snap+writecache+raid+integrity should be allowed.
+not lvcreate -s -n snap -L4M $vg/$lv1
+lvs -a -o name,size,segtype,devices
+not pvmove -n $vg/$lv1 "$dev1"
+not pvmove -n $vg/${lv1}_${suffix} "$dev1"
+not pvmove "$dev1"
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Repeat many of the tests above using bitmap mode
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}
+_test_fs_with_read_repair "$dev1"
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0 |tee mismatch
+not grep ' 0 ' mismatch
+lvs -o integritymismatches $vg/${lv1}_${suffix} |tee mismatch
+not grep ' 0 ' mismatch
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/${lv1}_${suffix}
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}_rimage_2
+_wait_recalc $vg/${lv1}_${suffix}_rimage_3
+_wait_recalc $vg/${lv1}_${suffix}_rimage_4
+_wait_recalc $vg/${lv1}_${suffix}
+_test_fs_with_read_repair "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_3
+lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_4
+lvs -o integritymismatches $vg/${lv1}_${suffix} |tee mismatch
+not grep ' 0 ' mismatch
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/${lv1}_${suffix}
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# remove from active lv
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/${lv1}_${suffix}
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# add to active lv
+_prepare_vg
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y --raidintegritymode bitmap $vg/$lv1
+lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
+lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+lvs -a -o name,size,segtype,devices,sync_percent $vg
+_wait_recalc $vg/${lv1}_${suffix}_rimage_0
+_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+_wait_recalc $vg/${lv1}_${suffix}
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+}
+
+do_test cache-pool cache --cachepool corig
+do_test linear cache --cachevol corig
+do_test linear writecache --cachevol wcorig
+
+# TODO: add do_test() variant that skips adding the cache to lv1.
+# This would be equivalent to integrity.sh which could be dropped.
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1cf6bba23..3d311288f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -480,7 +480,6 @@ OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
-RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type cache
@@ -489,7 +488,6 @@ OO: OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV.
 RULE: all and lv_is_visible
-RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
 AUTOTYPE: cache
@@ -501,7 +499,6 @@ OO: OO_LVCONVERT, --cachesettings String
 ID: lvconvert_to_writecache
 DESC: Attach a writecache to an LV, converts the LV to type writecache.
 RULE: all and lv_is_visible
-RULE: all not lv_is_raid_with_integrity
 
 ---
 
@@ -510,7 +507,6 @@ OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT, --poolmetadatasize SizeMB, --chun
 ID: lvconvert_to_cache_with_cachevol
 DESC: Attach a cache to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
-RULE: all not lv_is_raid_with_integrity
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachevol LV LV_linear_striped_raid_thinpool
@@ -518,7 +514,6 @@ OO: OO_LVCONVERT_CACHE, OO_LVCONVERT, --poolmetadatasize SizeMB, --chunksize Siz
 ID: lvconvert_to_cache_with_cachevol
 DESC: Attach a cache to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
-RULE: all not lv_is_raid_with_integrity
 FLAGS: SECONDARY_SYNTAX
 
 ---
diff --git a/tools/pvmove.c b/tools/pvmove.c
index ed92f3ce4..ebffe9acd 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -645,6 +645,14 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 			log_error("pvmove not allowed on raid LV with integrity.");
 			return ECMD_FAILED;
 		}
+
+		if (lv_is_cache(lv) || lv_is_writecache(lv)) {
+			struct logical_volume *lv_orig = seg_lv(first_seg(lv), 0);
+			if (lv_is_raid(lv_orig) && lv_raid_has_integrity(lv_orig)) {
+				log_error("pvmove not allowed on raid LV with integrity.");
+				return ECMD_FAILED;
+			}
+		}
 	}
 
 	/*

