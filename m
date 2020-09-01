From: David Teigland <teigland@sourceware.org>
Date: Tue,  1 Sep 2020 22:14:30 +0000 (GMT)
Subject: master - tests: add new integrity reporting fields
Message-ID: <20200901221430.BC8E3385E005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=739827ef1c1a256114aa0b2a385baa0983fac289
Commit:        739827ef1c1a256114aa0b2a385baa0983fac289
Parent:        ed249a2c539098aa4451b475cbf461212a93f77d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 1 17:07:36 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 1 17:13:46 2020 -0500

tests: add new integrity reporting fields

---
 test/shell/integrity-blocksize.sh |  3 +++
 test/shell/integrity-misc.sh      |  2 ++
 test/shell/integrity.sh           | 31 +++++++++++++++++++++++++++++++
 3 files changed, 36 insertions(+)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index eb6a364f2..61d58e2a3 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -81,6 +81,7 @@ not lvcreate --type raid1 -m1 --raidintegrity y --raidintegrityblocksize 512 -l
 
 # lvcreate --bs 4096 on dev512, result 4k
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegrityblocksize 4096 -l 8 -n $lv1 $vg1
+lvs -o raidintegrityblocksize $vg1/$lv1 | grep 4096
 pvck --dump metadata $LOOP1 | grep 'block_size = 4096'
 lvremove -y $vg1/$lv1
 
@@ -184,6 +185,7 @@ aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
 blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
+lvs -o raidintegrityblocksize $vg1/$lv1 | grep 512
 blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
@@ -198,6 +200,7 @@ blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg1/$lv1
 # lv needs to be inactive to increase LBS from 512
 lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
+lvs -o raidintegrityblocksize $vg1/$lv1 | grep 1024
 lvchange -ay $vg1/$lv1
 blkid "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index 2dae25f59..c8ec3bf49 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -145,6 +145,7 @@ lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 _wait_sync $vg/${lv1}_rimage_0
 _wait_sync $vg/${lv1}_rimage_1
 _wait_sync $vg/$lv1
+lvs -o raidintegritymode $vg/$lv1 | grep journal
 _add_new_data_to_mnt
 lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
 lvs -a -o+devices $vg > out
@@ -167,6 +168,7 @@ lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -
 _wait_sync $vg/${lv1}_rimage_0
 _wait_sync $vg/${lv1}_rimage_1
 _wait_sync $vg/$lv1
+lvs -o raidintegritymode $vg/$lv1 | grep bitmap
 _add_new_data_to_mnt
 lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
 lvs -a -o+devices $vg > out
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 0143129e6..f8740bc4f 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -104,6 +104,10 @@ _test_fs_with_raid() {
 	umount $mnt
 	lvchange -an $vg/$lv1
 
+	# FIXME: this is only finding/corrupting the bit with raid1
+	# other raid levels may require looking at a different dev.
+	# (Attempt this xxd/tac/sed/xxd on each dev in the LV?)
+
 	xxd "$dev1" > dev1.txt
 	tac dev1.txt > dev1.rev
 	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
@@ -224,6 +228,8 @@ lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -235,6 +241,9 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -246,6 +255,9 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -257,6 +269,9 @@ _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -270,6 +285,11 @@ _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/${lv1}_rimage_4
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_rimage_3
+lvs -o integritymismatches $vg/${lv1}_rimage_4
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -282,6 +302,10 @@ _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_rimage_3
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -607,6 +631,8 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -615,6 +641,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
 _test_fs_with_raid
+lvs -o integritymismatches $vg/${lv1}_rimage_0
+lvs -o integritymismatches $vg/${lv1}_rimage_1
+lvs -o integritymismatches $vg/${lv1}_rimage_2
+lvs -o integritymismatches $vg/${lv1}_rimage_3
+lvs -o integritymismatches $vg/${lv1}_rimage_4
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1


