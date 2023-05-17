From: David Teigland <teigland@sourceware.org>
Date: Wed, 17 May 2023 19:17:55 +0000 (GMT)
Subject: main - tests: integrity-caching: ensure raid redundancy
Message-ID: <20230517191755.95A5A3882642@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24e4b6df1182d0d41763176c175e98e5fa6153ab
Commit:        24e4b6df1182d0d41763176c175e98e5fa6153ab
Parent:        3a757047560d75a28d7e4c7d9a5253a72d786544
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 17 14:15:25 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 17 14:15:25 2023 -0500

tests: integrity-caching: ensure raid redundancy

The recent fix 05c2b10c5d0a9 ensures that raid LV images are not
using the same devices.  This was happening in the lvextend commands
used by this test, so fix the test to use more devices to ensue
redundancy.
---
 lib/metadata/lv_manip.c         |  5 ++++-
 test/shell/integrity-caching.sh | 23 ++++++++++++++++-------
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9a9e547be..fa3661739 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4471,8 +4471,11 @@ static int _lv_raid_redundant(struct logical_volume *lv,
 		for (s = 0; s < seg->area_count; s++) {
 			struct logical_volume *slv = meta ? seg_metalv(seg, s) : seg_lv(seg, s);
 
-			if (slv && lv_is_on_pv(slv, pvl->pv) && nlvs++)
+			if (slv && lv_is_on_pv(slv, pvl->pv) && nlvs++) {
+				log_error("LV %s using PV %s is not redundant.",
+					  display_lvname(slv), dev_name(pvl->pv->dev));
 				return 0;
+			}
 		}
 	}
 
diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 838bbded0..72fb4af4a 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -23,7 +23,7 @@ aux kernel_at_least  5 10 || export LVM_TEST_PREFER_BRD=0
 mnt="mnt"
 mkdir -p $mnt
 
-aux prepare_devs 6 80
+aux prepare_devs 9 80
 
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
@@ -276,7 +276,7 @@ vgremove -ff $vg
 # Test lvextend while inactive
 
 _prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
@@ -286,7 +286,11 @@ lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
 umount $mnt
 lvchange -an $vg/$lv1
-lvextend -l 16 $vg/$lv1
+# use two new devs for raid extend to ensure redundancy
+vgextend $vg "$dev7" "$dev8"
+lvs -a -o name,segtype,devices $vg
+lvextend -l 16 $vg/$lv1 "$dev7" "$dev8"
+lvs -a -o name,segtype,devices $vg
 lvchange -ay $vg/$lv1
 mount "$DM_DEV_DIR/$vg/$lv1" $mnt
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
@@ -303,15 +307,18 @@ vgremove -ff $vg
 # Test lvextend while active
 
 _prepare_vg
-lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
 aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+# use two new devs for raid extend to ensure redundancy
+vgextend $vg "$dev7" "$dev8"
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
-lvextend -l 16 $vg/$lv1
+lvextend -l 16 $vg/$lv1 "$dev7" "$dev8"
+lvs -a -o name,size,segtype,devices,sync_percent $vg
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
 aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
 aux wait_recalc $vg/${lv1}_${suffix}_rimage_1
@@ -324,16 +331,18 @@ lvremove $vg/$lv1
 vgremove -ff $vg
 
 _prepare_vg
-lvcreate --type raid5 --raidintegrity y -n $lv1 -I4 -l 8 $vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -I4 -l 8 $vg "$dev1" "$dev2" "$dev3"
 aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/${lv1}_rimage_2
 aux wait_recalc $vg/$lv1
 lvcreate --type $create_type -n fast -l 4 -an $vg "$dev6"
 lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+vgextend $vg "$dev7" "$dev8" "$dev9"
 lvs -a -o name,size,segtype,devices,sync_percent $vg
 _add_new_data_to_mnt
-lvextend -l 16 $vg/$lv1
+lvextend -l 16 $vg/$lv1 "$dev7" "$dev8" "$dev9"
+lvs -a -o name,size,segtype,devices,sync_percent $vg
 resize2fs "$DM_DEV_DIR/$vg/$lv1"
 aux wait_recalc $vg/${lv1}_${suffix}_rimage_0
 aux wait_recalc $vg/${lv1}_${suffix}_rimage_1

