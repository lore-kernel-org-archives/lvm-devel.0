From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:00:21 +0000 (UTC)
Subject: master - tests: lowering disc usage
Message-ID: <20160909190021.86A28605B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5ec348d680ff8ea0aa1e751d13cdab5812eb672
Commit:        e5ec348d680ff8ea0aa1e751d13cdab5812eb672
Parent:        454b891f6d0c482cd6c1655dc4e5c7eeee321d32
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 17:12:10 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 20:55:00 2016 +0200

tests: lowering disc usage

Correction for aux test result  ([] -> if;then;fi)

Use issue_discard to lower memory demands on discardable test devices
Use large devices directly through prepare_pvs

I'm still observing more then 0.5G of data usage through.

Particullary:

'lvcreate' followed by 'lvconvert' (which doesn't yet support --nosync
option)  is quite demanging, and resume returns quite 'late' when
a lot of data has been already written on PV.
---
 test/shell/lvcreate-large-raid.sh |   59 ++++++++++++++++--------------------
 1 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 24f4fb8..c2e9b7e 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -21,27 +21,17 @@ aux can_use_16T || skip
 
 aux have_raid 1 3 0 || skip
 
-aux prepare_vg 5 32
+# Prepare 5x ~1P sized devices
+aux prepare_pvs 5 1000000000
 
-# Fake 5 PiB volume group $vg1 via snapshot LVs
-for device in "$lv1" "$lv2" "$lv3" "$lv4" "$lv5"
-do
-	lvcreate --type snapshot -s -l 20%FREE -n $device $vg --virtualsize 1P
-done
-
-#FIXME this should be 1024T
-#check lv_field $vg/$lv size "128.00m"
-
-aux extend_filter_LVMTEST
+vgcreate $vg1 $(< DEVICES)
 
-pvcreate "$DM_DEV_DIR"/$vg/$lv[12345]
-vgcreate -s 2M $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
+aux lvmconf 'devices/issue_discards = 1'
 
-# Delay PVs so that resynchronization doesn't fill
-# the snapshots before removal of the RaidLV
-for device in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+# Delay PVs so that resynchronization doesn't fill too much space
+for device in $(< DEVICES)
 do
-	aux delay_dev "$device" 0 1
+	aux delay_dev "$device" 0 10  $(get first_extent_sector "$device")
 done
 
 # bz837927 START
@@ -70,15 +60,30 @@ for segtype in raid4 raid5; do
         lvremove -ff $vg1
 done
 
-# 750 TiB raid6 (with --nosync rejection check)
-[ aux have_raid 1 9 0 ] && not lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1 --nosync
+#
+# Extending large 200 TiB RAID LV to 400 TiB (belong in different script?)
+#
+lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
+check lv_field $vg1/$lv1 size "200.00t"
+aux check_status_chars $vg1 $lv1 "AA"
+lvextend -L +200T $vg1/$lv1
+check lv_field $vg1/$lv1 size "400.00t"
+aux check_status_chars $vg1 $lv1 "AA"
+lvremove -ff $vg1
+
+
+# Check --nosync is rejected for raid6
+if aux have_raid 1 9 0 ; then
+	not lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1 --nosync
+fi
+
+# 750 TiB raid6
 lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "750.00t"
 aux check_status_chars $vg1 $lv1 "aaaaa"
 lvremove -ff $vg1
 
-# 1 PiB raid6 (with --nosync rejection check), then extend up to 2 PiB
-[ aux have_raid 1 9 0 ] && not lvcreate --type raid6 -i 3 -L -L 1P -n $lv1 $vg1 --nosync
+# 1 PiB raid6, then extend up to 2 PiB
 lvcreate --type raid6 -i 3 -L 1P -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "1.00p"
 aux check_status_chars $vg1 $lv1 "aaaaa"
@@ -96,18 +101,6 @@ check lv_field $vg1/$lv1 size "200.00t"
 aux check_status_chars $vg1 $lv1 "aa"
 lvremove -ff $vg1
 
-#
-# Extending large 200 TiB RAID LV to 400 TiB (belong in different script?)
-#
-lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
-check lv_field $vg1/$lv1 size "200.00t"
-aux check_status_chars $vg1 $lv1 "AA"
-lvextend -L +200T $vg1/$lv1
-check lv_field $vg1/$lv1 size "400.00t"
-aux check_status_chars $vg1 $lv1 "AA"
-lvremove -ff $vg1
-
 # bz837927 END
 
 vgremove -ff $vg1
-vgremove -ff $vg


