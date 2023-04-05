From: David Teigland <teigland@sourceware.org>
Date: Wed,  5 Apr 2023 19:25:34 +0000 (GMT)
Subject: main - tests: integrity fixes
Message-ID: <20230405192534.BD4D53858D20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebbc3f7ab31e8026499bddd93cde4db4921d2132
Commit:        ebbc3f7ab31e8026499bddd93cde4db4921d2132
Parent:        300c8209a810f287992376e8a0561fdf878d1520
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 16 13:59:56 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 5 14:24:07 2023 -0500

tests: integrity fixes

wait_recalc was mistakenly being called on raid without integrity
wait_recalc loop was exiting without error
---
 test/shell/integrity.sh | 56 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 37 insertions(+), 19 deletions(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 293cde84a..a7dd5b565 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -157,12 +157,13 @@ _wait_recalc() {
 	# TODO: There is some strange bug, first leg of RAID with integrity
 	# enabled never gets in sync. I saw this in BB, but not when executing
 	# the commands manually
-	if test -z "$sync"; then
-		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
-                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
-		exit
-	fi
+#	if test -z "$sync"; then
+#		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
+#                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+#		exit
+#	fi
 	echo "timeout waiting for recalc"
+	dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
 	return 1
 }
 
@@ -171,6 +172,7 @@ _wait_recalc() {
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -186,6 +188,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -202,6 +205,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -219,6 +223,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -236,6 +241,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -257,6 +263,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -278,6 +285,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -293,6 +301,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -309,6 +318,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -325,6 +335,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -343,6 +354,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -360,6 +372,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
@@ -375,6 +388,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid4 -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
@@ -390,6 +404,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
@@ -405,11 +420,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
-_wait_recalc $vg/${lv1}_rimage_2
-_wait_recalc $vg/${lv1}_rimage_3
-_wait_recalc $vg/${lv1}_rimage_4
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
@@ -425,6 +436,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid10 -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --raidintegrity y $vg/$lv1
@@ -442,10 +454,10 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
-lvs -a -o+devices $vg
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1
@@ -455,7 +467,7 @@ mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 xfs_growfs $mnt
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
-lvs -a -o+devices $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -466,13 +478,13 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,sync_percent,devices $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/${lv1}_rimage_3
 _wait_recalc $vg/${lv1}_rimage_4
 _wait_recalc $vg/$lv1
-lvs -a -o+devices $vg
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1
@@ -482,7 +494,7 @@ mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 xfs_growfs $mnt
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
-lvs -a -o+devices $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt
@@ -495,6 +507,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -515,6 +528,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -536,6 +550,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -558,6 +573,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -580,11 +596,11 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
 _wait_recalc $vg/$lv1
-lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvconvert -y -m-1 $vg/$lv1
 lvs -a -o+devices $vg
@@ -600,10 +616,10 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
-lvs -a -o+devices $vg
 _add_new_data_to_mnt
 not lvconvert -y -m-1 $vg/$lv1
 not lvconvert --splitmirrors 1 -n tmp -y $vg/$lv1
@@ -624,6 +640,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/$lv1
@@ -639,6 +656,7 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
@@ -661,6 +679,7 @@ vgremove -ff $vg
 # remove from active lv
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _add_new_data_to_mnt
@@ -691,9 +710,9 @@ vgremove -ff $vg
 # lvextend active
 _prepare_vg
 lvcreate --type raid1 --raidintegrity y --raidintegritymode bitmap -m1 -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
-lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvextend -l 16 $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
@@ -710,15 +729,14 @@ vgremove -ff $vg
 # add image to raid1
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+lvs -a -o name,segtype,devices,sync_percent $vg
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
-lvs -a -o+devices $vg
 _add_new_data_to_mnt
 lvconvert -y -m+1 $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 _wait_recalc $vg/${lv1}_rimage_2
-lvs -a -o+devices $vg
 _add_more_data_to_mnt
 _verify_data_on_mnt
 umount $mnt

