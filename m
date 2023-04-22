From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Apr 2023 09:26:27 +0000 (GMT)
Subject: main - test: use aux wait_recalc
Message-ID: <20230422092627.96C893858C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f4e3832e0b6c877857e26f50aaa7196d9034cca
Commit:        1f4e3832e0b6c877857e26f50aaa7196d9034cca
Parent:        2043bb0e387ddec2f2b1ad4cd0a93cfeb272bf85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 22:30:50 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 22 11:25:39 2023 +0200

test: use aux wait_recalc

Use aux function.
---
 test/shell/integrity-misc.sh | 61 +++++++++++---------------------------------
 1 file changed, 15 insertions(+), 46 deletions(-)

diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index 37f272cd0..3ab0c2ba2 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -94,43 +94,12 @@ _verify_data_on_lv() {
         lvchange -an $vg/$lv1
 }
 
-_sync_percent() {
-	local checklv=$1
-	get lv_field "$checklv" sync_percent | cut -d. -f1
-}
-
-_wait_sync() {
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
 # lvrename
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_sync $vg/${lv1}_rimage_0
-_wait_sync $vg/${lv1}_rimage_1
-_wait_sync $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 umount $mnt
 lvrename $vg/$lv1 $vg/$lv2
@@ -146,9 +115,9 @@ vgremove -ff $vg
 # lv must be active
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_sync $vg/${lv1}_rimage_0
-_wait_sync $vg/${lv1}_rimage_1
-_wait_sync $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvs -o raidintegritymode $vg/$lv1 | grep journal
 _add_new_data_to_mnt
 lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
@@ -169,9 +138,9 @@ vgremove -ff $vg
 # same as prev but with bitmap mode
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_sync $vg/${lv1}_rimage_0
-_wait_sync $vg/${lv1}_rimage_1
-_wait_sync $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 lvs -o raidintegritymode $vg/$lv1 | grep bitmap
 _add_new_data_to_mnt
 lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
@@ -194,9 +163,9 @@ vgremove -ff $vg
 # (like lvconvert --replace does for a dev that's not missing).
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_sync $vg/${lv1}_rimage_0
-_wait_sync $vg/${lv1}_rimage_1
-_wait_sync $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 aux disable_dev "$dev2"
 lvs -a -o+devices $vg > out
@@ -223,9 +192,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_sync $vg/${lv1}_rimage_0
-_wait_sync $vg/${lv1}_rimage_1
-_wait_sync $vg/$lv1
+aux wait_recalc $vg/${lv1}_rimage_0
+aux wait_recalc $vg/${lv1}_rimage_1
+aux wait_recalc $vg/$lv1
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1

