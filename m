From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Jun 2020 17:31:35 +0000 (GMT)
Subject: master - integrity: wait for raid sync to complete
Message-ID: <20200616173135.6D5A4388E81C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=950d2d59c140c82fea35e56d34c92289562d4d6f
Commit:        950d2d59c140c82fea35e56d34c92289562d4d6f
Parent:        48872b0369af5ee048c947586d7da82d9769f5c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 12:29:41 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 12:29:41 2020 -0500

integrity: wait for raid sync to complete

---
 test/shell/integrity-misc.sh | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index 0d056890c..2dae25f59 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -95,7 +95,7 @@ _sync_percent() {
 	get lv_field "$checklv" sync_percent | cut -d. -f1
 }
 
-_wait_recalc() {
+_wait_sync() {
 	local checklv=$1
 
 	for i in $(seq 1 10) ; do
@@ -124,8 +124,9 @@ _wait_recalc() {
 # lvrename
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+_wait_sync $vg/$lv1
 _add_new_data_to_mnt
 umount $mnt
 lvrename $vg/$lv1 $vg/$lv2
@@ -141,8 +142,9 @@ vgremove -ff $vg
 # lv must be active
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+_wait_sync $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
 lvs -a -o+devices $vg > out
@@ -162,8 +164,9 @@ vgremove -ff $vg
 # same as prev but with bitmap mode
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+_wait_sync $vg/$lv1
 _add_new_data_to_mnt
 lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
 lvs -a -o+devices $vg > out
@@ -185,8 +188,9 @@ vgremove -ff $vg
 # (like lvconvert --replace does for a dev that's not missing).
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+_wait_sync $vg/$lv1
 _add_new_data_to_mnt
 aux disable_dev "$dev2"
 lvs -a -o+devices $vg > out
@@ -213,8 +217,9 @@ vgremove -ff $vg
 
 _prepare_vg
 lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
-_wait_recalc $vg/${lv1}_rimage_0
-_wait_recalc $vg/${lv1}_rimage_1
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+_wait_sync $vg/$lv1
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1


