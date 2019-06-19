From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Jun 2019 18:06:25 -0400
Subject: stable-2.02 - tests: simplify some var settings
Message-ID: <201906192206.x5JM6PDr013898@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78c937552a60e8e61cb9f1aca22095f28a39c174
Commit:        78c937552a60e8e61cb9f1aca22095f28a39c174
Parent:        a311684c4ab0ec2cf3a3d11412295da52df63c88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 00:03:18 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 00:05:46 2019 +0200

tests: simplify some var settings

scan_lvs now automatically comes with extend_filter_LVMTEST
---
 test/lib/aux.sh                       |    2 +-
 test/shell/discards-thin.sh           |    2 --
 test/shell/lvconvert-thin.sh          |    2 --
 test/shell/lvcreate-large-raid10.sh   |    1 -
 test/shell/lvcreate-large.sh          |    2 --
 test/shell/pvcreate-operation-md.sh   |    3 +--
 test/shell/pvcreate-restore.sh        |    2 --
 test/shell/pvremove-thin.sh           |    2 --
 test/shell/scan-lvs.sh                |    4 +---
 test/shell/snapshot-remove-dmsetup.sh |    2 --
 test/shell/snapshot-usage-exa.sh      |    2 --
 test/shell/snapshot-usage.sh          |    2 --
 test/shell/vgsplit-stacked.sh         |    2 --
 13 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1db6fbf..804200d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1246,7 +1246,7 @@ devices/default_data_alignment = 1
 devices/dir = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
 devices/global_filter = [ "a|$DM_DEV_DIR/mapper/${PREFIX}.*pv[0-9_]*$|", "r|.*|" ]
-devices/md_component_detection  = 0
+devices/md_component_detection = 0
 devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1
 devices/write_cache_state = 0
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 3564a87..f27d4c3 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -25,8 +25,6 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 #
 aux have_thin 1 1 0 || skip
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 aux prepare_vg 2 64
 get_devs
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 731c45b..1f8d2ed 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -17,8 +17,6 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 prepare_lvs() {
 	lvremove -f $vg
 	lvcreate -L10M -n $lv1 $vg
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 1ad09aa..a46be37 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -20,7 +20,6 @@ SKIP_WITH_LVMPOLLD=1
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 aux have_raid 1 3 0 || skip
-aux lvmconf 'devices/scan_lvs = 1'
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index b1cb0b0..473b0ed 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -17,8 +17,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 11f0887..4b51932 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -22,8 +22,7 @@ test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
-aux extend_filter_LVMTEST
-aux extend_filter "a|/dev/md.*|"
+aux extend_filter_LVMTEST "a|/dev/md|"
 
 aux prepare_devs 2
 
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
index 789f45c..d0b46eb 100644
--- a/test/shell/pvcreate-restore.sh
+++ b/test/shell/pvcreate-restore.sh
@@ -15,8 +15,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 aux prepare_vg 4
 
 lvcreate --type snapshot -s -L10 -n $lv1 $vg --virtualsize 2T
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 84a2a55..9859b6c 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -18,8 +18,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 aux prepare_vg
 
 aux have_thin 1 8 0 || skip
diff --git a/test/shell/scan-lvs.sh b/test/shell/scan-lvs.sh
index 8e8a77d..f49bf4d 100644
--- a/test/shell/scan-lvs.sh
+++ b/test/shell/scan-lvs.sh
@@ -15,10 +15,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# Sets 'scan_lvs = 1'
 aux extend_filter_LVMTEST
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 aux prepare_pvs 1
 
 vgcreate $SHARED $vg1 "$dev1"
@@ -44,4 +43,3 @@ lvchange -an "$vg1/$lv1"
 lvremove "$vg1/$lv1"
 
 vgremove $vg1
-
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index a234e5a..a7925d5 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -19,8 +19,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 which mkfs.ext2 || skip
 
 aux prepare_vg 5
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index f537f0d..5d666bf 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -18,8 +18,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 aux can_use_16T || skip
 
 aux prepare_pvs 1
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 5cfdae6..bcfa16a 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -17,8 +17,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 MKFS=mkfs.ext2
 which $MKFS || skip
 
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 09af3f7..331ee8e 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -15,8 +15,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux lvmconf 'devices/scan_lvs = 1'
-
 aux extend_filter_LVMTEST
 aux prepare_pvs 3
 


