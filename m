From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Apr 2023 12:53:37 +0000 (GMT)
Subject: main - aux: add wait_recalc
Message-ID: <20230421125337.CBDB73858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80ebec099dbb20e46655958e1ca7fcfd466b78d8
Commit:        80ebec099dbb20e46655958e1ca7fcfd466b78d8
Parent:        4e0aab74288390b633c25c1bcf3efdb127e3a364
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 20 17:08:42 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 14:52:43 2023 +0200

aux: add wait_recalc

Share function across tests.
---
 test/lib/aux.sh                     |  25 ++++
 test/shell/integrity-blocksize-2.sh |  43 +-----
 test/shell/integrity-blocksize-3.sh |  67 +++------
 test/shell/integrity-caching.sh     | 154 ++++++++------------
 test/shell/integrity-dmeventd.sh    |  61 ++------
 test/shell/integrity-large.sh       |  43 +-----
 test/shell/integrity-syncaction.sh  |  55 ++-----
 test/shell/integrity.sh             | 282 ++++++++++++++++--------------------
 8 files changed, 268 insertions(+), 462 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 33710a007..62635ce84 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1757,6 +1757,31 @@ wait_for_sync() {
 	return 1
 }
 
+wait_recalc() {
+	local checklv=$1
+
+	for i in {1..100} ; do
+		sync=$(get lv_field "$checklv" sync_percent | cut -d. -f1)
+		echo "sync_percent is $sync"
+
+		test "$sync" = "100" && return
+
+		sleep .1
+	done
+
+	# TODO: There is some strange bug, first leg of RAID with integrity
+	# enabled never gets in sync. I saw this in BB, but not when executing
+	# the commands manually
+#	if test -z "$sync"; then
+#		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
+#                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+#		exit
+#	fi
+	echo "Timeout waiting for recalc"
+	dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+	return 1
+}
+
 # Check if tests are running on 64bit architecture
 can_use_16T() {
 	test "$(getconf LONG_BIT)" -eq 64
diff --git a/test/shell/integrity-blocksize-2.sh b/test/shell/integrity-blocksize-2.sh
index b2e0fb06e..14c3bb17d 100644
--- a/test/shell/integrity-blocksize-2.sh
+++ b/test/shell/integrity-blocksize-2.sh
@@ -21,37 +21,6 @@ aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 mnt="mnt"
 mkdir -p $mnt
 
-_sync_percent() {
-        local checklv=$1
-        get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-        local checklv=$1
-
-        for i in $(seq 1 10) ; do
-                sync=$(_sync_percent "$checklv")
-                echo "sync_percent is $sync"
-
-                if test "$sync" = "100"; then
-                        return
-                fi
-
-                sleep 1
-        done
-
-        # TODO: There is some strange bug, first leg of RAID with integrity
-        # enabled never gets in sync. I saw this in BB, but not when executing
-        # the commands manually
-        if test -z "$sync"; then
-                echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-                exit
-        fi
-        echo "timeout waiting for recalc"
-        return 1
-}
-
 # prepare_devs uses ramdisk backing which has 512 LBS and 4K PBS
 # This should cause mkfs.xfs to use 4K sector size,
 # and integrity to use 4K block size
@@ -74,8 +43,8 @@ umount $mnt
 lvchange -an $vg
 lvconvert --raidintegrity y $vg/$lv1
 lvchange -ay $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello
@@ -95,8 +64,8 @@ umount $mnt
 lvchange -an $vg
 lvchange -ay $vg
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello | grep "hello world"
@@ -113,8 +82,8 @@ mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 cat $mnt/hello | grep "hello world"
 umount $mnt
diff --git a/test/shell/integrity-blocksize-3.sh b/test/shell/integrity-blocksize-3.sh
index 300cc1895..f86d7f7da 100644
--- a/test/shell/integrity-blocksize-3.sh
+++ b/test/shell/integrity-blocksize-3.sh
@@ -19,37 +19,6 @@ aux have_integrity 1 5 0 || skip
 mnt="mnt"
 mkdir -p $mnt
 
-_sync_percent() {
-        local checklv=$1
-        get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-        local checklv=$1
-
-        for i in $(seq 1 10) ; do
-                sync=$(_sync_percent "$checklv")
-                echo "sync_percent is $sync"
-
-                if test "$sync" = "100"; then
-                        return
-                fi
-
-                sleep 1
-        done
-
-        # TODO: There is some strange bug, first leg of RAID with integrity
-        # enabled never gets in sync. I saw this in BB, but not when executing
-        # the commands manually
-        if test -z "$sync"; then
-                echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-                exit
-        fi
-        echo "timeout waiting for recalc"
-        return 1
-}
-
 # scsi_debug devices with 512 LBS 512 PBS
 aux prepare_scsi_debug_dev 256
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "512"
@@ -73,8 +42,8 @@ umount $mnt
 lvchange -an $vg
 lvconvert --raidintegrity y $vg/$lv1
 lvchange -ay $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello
@@ -93,8 +62,8 @@ umount $mnt
 lvchange -an $vg
 lvchange -ay $vg
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello | grep "hello world"
@@ -110,8 +79,8 @@ mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 cat $mnt/hello | grep "hello world"
 umount $mnt
@@ -150,8 +119,8 @@ umount $mnt
 lvchange -an $vg
 lvconvert --raidintegrity y $vg/$lv1
 lvchange -ay $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello
@@ -170,8 +139,8 @@ umount $mnt
 lvchange -an $vg
 lvchange -ay $vg
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello | grep "hello world"
@@ -187,8 +156,8 @@ mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 cat $mnt/hello | grep "hello world"
 umount $mnt
@@ -227,8 +196,8 @@ umount $mnt
 lvchange -an $vg
 lvconvert --raidintegrity y $vg/$lv1
 lvchange -ay $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello
@@ -248,8 +217,8 @@ umount $mnt
 lvchange -an $vg
 lvchange -ay $vg
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 cat $mnt/hello | grep "hello world"
@@ -266,8 +235,8 @@ mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 echo "hello world" > $mnt/hello
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 cat $mnt/hello | grep "hello world"
 umount $mnt
diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 71740dfb5..52aec98ce 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -145,38 +145,6 @@ _verify_data_on_lv() {
 	lvchange -an $vg/$lv1
 }
 
-_sync_percent() {
-	local checklv=$1
-	get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-	local checklv=$1
-
-	for i in $(seq 1 10) ; do
-		sync=$(_sync_percent "$checklv")
-		echo "sync_percent is $sync"
-
-		if test "$sync" = "100"; then
-			return
-		fi
-
-		sleep 1
-	done
-
-	# TODO: There is some strange bug, first leg of RAID with integrity
-	# enabled never gets in sync. I saw this in BB, but not when executing
-	# the commands manually
-#	if test -z "$sync"; then
-#		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-#               dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-#		exit
-#	fi
-	echo "timeout waiting for recalc"
-	dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-	return 1
-}
-
 # lv1 is a raid+integrity LV
 # three variations of caching on lv1:
 #
@@ -208,9 +176,9 @@ lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}
 _test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0 |tee mismatch
 not grep ' 0 ' mismatch
@@ -227,10 +195,10 @@ lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$d
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}_rimage_2
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_2
+aux wait_recalc $vg/${lv1}_${suffix}
 _test_fs_with_read_repair "$dev1" "$dev2"
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0 |tee mismatch
 not grep ' 0 ' mismatch
@@ -247,10 +215,10 @@ lvcreate --type raid5 --raidintegrity y -n $lv1 -I4 -l 8 $vg "$dev1" "$dev2" "$d
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}_rimage_2
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_2
+aux wait_recalc $vg/${lv1}_${suffix}
 _test_fs_with_read_repair "$dev1" "$dev2" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_1
@@ -270,9 +238,9 @@ lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/${lv1}_${suffix}
 _add_more_data_to_mnt
@@ -288,15 +256,15 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 # Can only be enabled while raid is top level lv (for now.)
 not lvconvert --raidintegrity y $vg/${lv1}_${suffix}
-#_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-#_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+#aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+#aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -309,9 +277,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
@@ -322,8 +290,8 @@ lvextend -l 16 $vg/$lv1
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -336,17 +304,17 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -357,18 +325,18 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -I4 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -381,18 +349,18 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 # currently only allowed while raid is top level lv
 not lvconvert -y -m+1 $vg/${lv1}_${suffix}
-#_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-#_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-#_wait_recalc $vg/${lv1}_${suffix}_rimage_2
+#aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+#aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+#aux wait_recalc $vg/${lv1}_${suffix}_rimage_2
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -405,10 +373,10 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
@@ -427,9 +395,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
@@ -466,9 +434,9 @@ lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}
 _test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0 |tee mismatch
 not grep ' 0 ' mismatch
@@ -484,12 +452,12 @@ lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -I4 -
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}_rimage_2
-_wait_recalc $vg/${lv1}_${suffix}_rimage_3
-_wait_recalc $vg/${lv1}_${suffix}_rimage_4
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_2
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_3
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_4
+aux wait_recalc $vg/${lv1}_${suffix}
 _test_fs_with_read_repair "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_${suffix}_rimage_1
@@ -506,9 +474,9 @@ vgremove -ff $vg
 # remove from active lv
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
@@ -530,9 +498,9 @@ lvconvert --raidintegrity y --raidintegritymode bitmap $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
 lvs -a -o name,size,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_${suffix}_rimage_0
-_wait_recalc $vg/${lv1}_${suffix}_rimage_1
-_wait_recalc $vg/${lv1}_${suffix}
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
+aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
+aux wait_recalc $vg/${lv1}_${suffix}
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index 44121a186..dc944c0e9 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -94,37 +94,6 @@ _verify_data_on_lv() {
         lvchange -an $vg/$lv1
 }
 
-_sync_percent() {
-	local checklv=$1
-	get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-	local checklv=$1
-
-	for i in $(seq 1 10) ; do
-		sync=$(_sync_percent "$checklv")
-		echo "sync_percent is $sync"
-
-		if test "$sync" = "100"; then
-			return
-		fi
-
-		sleep 1
-	done
-
-	# TODO: There is some strange bug, first leg of RAID with integrity
-	# enabled never gets in sync. I saw this in BB, but not when executing
-	# the commands manually
-	if test -z "$sync"; then
-		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-		exit
-	fi
-	echo "timeout waiting for recalc"
-	return 1
-}
-
 aux lvmconf \
         'activation/raid_fault_policy = "allocate"'
 
@@ -136,9 +105,9 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lvcreate --type raid1 -m 2 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 lvchange --monitor y $vg/$lv1
 lvs -a -o+devices $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
 aux wait_for_sync $vg $lv1
 _add_new_data_to_mnt
 
@@ -176,9 +145,9 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvcreate --type raid1 -m 2 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 lvchange --monitor y $vg/$lv1
 lvs -a -o+devices $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
 aux wait_for_sync $vg $lv1
 _add_new_data_to_mnt
 
@@ -222,11 +191,11 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 lvcreate --type raid6 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvchange --monitor y $vg/$lv1
 lvs -a -o+devices $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/${lv1}_rimage_4
 aux wait_for_sync $vg $lv1
 _add_new_data_to_mnt
 
@@ -262,10 +231,10 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvcreate --type raid10 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lvchange --monitor y $vg/$lv1
 lvs -a -o+devices $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
 aux wait_for_sync $vg $lv1
 _add_new_data_to_mnt
 
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 16e28fb9d..68822e3ef 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -92,37 +92,6 @@ _verify_data_on_lv() {
 	umount $mnt
 }
 
-_sync_percent() {
-	local checklv=$1
-	get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-	local checklv=$1
-
-	for i in $(seq 1 20) ; do
-		sync=$(_sync_percent "$checklv")
-		echo "sync_percent is $sync"
-
-		if test "$sync" = "100"; then
-			return
-		fi
-
-		sleep 1
-	done
-
-	# TODO: There is some strange bug, first leg of RAID with integrity
-	# enabled never gets in sync. I saw this in BB, but not when executing
-	# the commands manually
-	if test -z "$sync"; then
-		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-		exit
-	fi
-	echo "timeout waiting for recalc"
-	return 1
-}
-
 # lvextend to 512MB is needed for the imeta LV to
 # be extended from 4MB to 8MB.
 
@@ -135,8 +104,8 @@ _add_data_to_lv
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity y $vg/$lv1
 lvchange -ay $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 _verify_data_on_lv
 lvchange -an $vg/$lv1
@@ -144,8 +113,8 @@ lvextend -L 512M $vg/$lv1
 lvs -a -o+devices $vg
 lvchange -ay $vg/$lv1
 _verify_data_on_lv
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 check lv_field $vg/${lv1}_rimage_0_imeta size "12.00m"
 check lv_field $vg/${lv1}_rimage_1_imeta size "12.00m"
@@ -166,8 +135,8 @@ lvs -a -o+devices $vg
 # adding integrity again will allocate new 12MB imeta LVs
 # on dev3,dev4
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 check lv_field $vg/${lv1}_rimage_0_imeta size "20.00m"
 check lv_field $vg/${lv1}_rimage_1_imeta size "20.00m"
diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index 03f0de8f4..ededda010 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -65,7 +65,7 @@ _test1() {
 
 	lvchange --syncaction check $vg/$lv1
 
-	_wait_recalc $vg/$lv1
+	aux wait_recalc $vg/$lv1
 
 	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 	not grep 0 mismatch
@@ -111,7 +111,7 @@ _test2() {
 
 	lvchange --syncaction check $vg/$lv1
 
-	_wait_recalc $vg/$lv1
+	aux wait_recalc $vg/$lv1
 
 	lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 	not grep 0 mismatch
@@ -125,42 +125,11 @@ _test2() {
 	umount $mnt
 }
 
-_sync_percent() {
-	local checklv=$1
-	get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-	local checklv=$1
-
-	for i in $(seq 1 10) ; do
-		sync=$(_sync_percent "$checklv")
-		echo "sync_percent is $sync"
-
-		if test "$sync" = "100"; then
-			return
-		fi
-
-		sleep 1
-	done
-
-	# TODO: There is some strange bug, first leg of RAID with integrity
-	# enabled never gets in sync. I saw this in BB, but not when executing
-	# the commands manually
-	if test -z "$sync"; then
-		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-		exit
-	fi
-	echo "timeout waiting for recalc"
-	return 1
-}
-
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _test1
 lvs -o integritymismatches $vg/$lv1 |tee mismatch
 not grep 0 mismatch
@@ -171,9 +140,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 6 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _test2
 lvs -o integritymismatches $vg/$lv1 |tee mismatch
 not grep 0 mismatch
@@ -184,10 +153,10 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -I 4K -l 6 $vg "$dev1" "$dev2" "$dev3"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _test1
 lvs -o integritymismatches $vg/$lv1 |tee mismatch
 not grep 0 mismatch
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 96237632e..c649bef11 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -126,47 +126,15 @@ _verify_data_on_lv() {
 	lvchange -an $vg/$lv1
 }
 
-_sync_percent() {
-	local checklv=$1
-	get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_recalc() {
-	local checklv=$1
-
-	for i in $(seq 1 10) ; do
-		sync=$(_sync_percent "$checklv")
-		echo "sync_percent is $sync"
-
-		if test "$sync" = "100"; then
-			return
-		fi
-
-		sleep 1
-	done
-
-	# TODO: There is some strange bug, first leg of RAID with integrity
-	# enabled never gets in sync. I saw this in BB, but not when executing
-	# the commands manually
-#	if test -z "$sync"; then
-#		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-#                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-#		exit
-#	fi
-	echo "timeout waiting for recalc"
-	dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-	return 1
-}
-
 # Test corrupting data on an image and verifying that
 # it is detected by integrity and corrected by raid.
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
@@ -180,10 +148,10 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev2"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
@@ -197,10 +165,10 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid4 --raidintegrity y -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev2" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -215,10 +183,10 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev2" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -233,12 +201,12 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/${lv1}_rimage_4
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -255,11 +223,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev3"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -277,9 +245,9 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -293,10 +261,10 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -310,10 +278,10 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -327,12 +295,12 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/${lv1}_rimage_4
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -346,9 +314,9 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -364,11 +332,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -380,11 +348,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid4 -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -396,11 +364,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid5 -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -412,11 +380,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid6 -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -428,11 +396,11 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid10 -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -446,9 +414,9 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1
@@ -456,8 +424,8 @@ lvextend -l 16 $vg/$lv1
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o name,segtype,devices,sync_percent $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -470,12 +438,12 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,sync_percent,devices $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/${lv1}_rimage_4
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1
@@ -483,8 +451,8 @@ lvextend -l 16 $vg/$lv1
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o name,segtype,devices,sync_percent $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -499,15 +467,15 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -520,16 +488,16 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -542,15 +510,15 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -565,15 +533,15 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvconvert -y -m+1 $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
 lvs -a -o+devices $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -588,10 +556,10 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert -y -m-1 $vg/$lv1
 lvs -a -o+devices $vg
@@ -608,9 +576,9 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 not lvconvert -y -m-1 $vg/$lv1
 not lvconvert --splitmirrors 1 -n tmp -y $vg/$lv1
@@ -632,9 +600,9 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
@@ -648,12 +616,12 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -I 4K -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
-_wait_recalc $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_3
+aux wait_recalc $vg/${lv1}_rimage_4
+aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvs -o integritymismatches $vg/${lv1}_rimage_0
 lvs -o integritymismatches $vg/${lv1}_rimage_1
@@ -671,8 +639,8 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_new_data_to_mnt
 lvconvert --raidintegrity n $vg/$lv1
 _add_more_data_to_mnt
@@ -688,8 +656,8 @@ _prepare_vg
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 _add_new_data_to_mnt
 lvconvert --raidintegrity y --raidintegritymode bitmap $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -702,12 +670,12 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 --raidintegrity y --raidintegritymode bitmap -m1 -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
 _add_more_data_to_mnt
 _verify_data_on_mnt
@@ -721,13 +689,13 @@ vgremove -ff $vg
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
 lvs -a -o name,segtype,devices,sync_percent $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
 _add_new_data_to_mnt
 lvconvert -y -m+1 $vg/$lv1
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/${lv1}_rimage_2
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt

