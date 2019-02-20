From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 17:47:14 -0500
Subject: stable-2.02 - tests: set scan_lvs=1 in tests that stack PVs on LVs
Message-ID: <201902202247.x1KMlERK005106@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f56908c2beb6161256af4ccdbeaf86309a9b6cf
Commit:        7f56908c2beb6161256af4ccdbeaf86309a9b6cf
Parent:        427e8ba3e3186e291ff26f014003d149da6ec2a8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 20 13:31:30 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 14:32:01 2019 -0600

tests: set scan_lvs=1 in tests that stack PVs on LVs

---
 test/shell/discards-thin.sh           |    2 ++
 test/shell/lvconvert-thin.sh          |    2 ++
 test/shell/lvcreate-large-raid10.sh   |    1 +
 test/shell/lvcreate-large.sh          |    2 ++
 test/shell/pvcreate-restore.sh        |    2 ++
 test/shell/pvremove-thin.sh           |    2 ++
 test/shell/snapshot-remove-dmsetup.sh |    2 ++
 test/shell/snapshot-usage-exa.sh      |    2 ++
 test/shell/snapshot-usage.sh          |    2 ++
 test/shell/vgsplit-stacked.sh         |    2 ++
 10 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index f27d4c3..3564a87 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -25,6 +25,8 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 #
 aux have_thin 1 1 0 || skip
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 aux prepare_vg 2 64
 get_devs
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 1f8d2ed..731c45b 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -17,6 +17,8 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 prepare_lvs() {
 	lvremove -f $vg
 	lvcreate -L10M -n $lv1 $vg
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index a46be37..1ad09aa 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -20,6 +20,7 @@ SKIP_WITH_LVMPOLLD=1
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 aux have_raid 1 3 0 || skip
+aux lvmconf 'devices/scan_lvs = 1'
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 473b0ed..b1cb0b0 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -17,6 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
index d0b46eb..789f45c 100644
--- a/test/shell/pvcreate-restore.sh
+++ b/test/shell/pvcreate-restore.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 aux prepare_vg 4
 
 lvcreate --type snapshot -s -L10 -n $lv1 $vg --virtualsize 2T
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 9859b6c..84a2a55 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -18,6 +18,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 aux prepare_vg
 
 aux have_thin 1 8 0 || skip
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index a7925d5..a234e5a 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -19,6 +19,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 which mkfs.ext2 || skip
 
 aux prepare_vg 5
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index 5d666bf..f537f0d 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -18,6 +18,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 aux can_use_16T || skip
 
 aux prepare_pvs 1
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index bcfa16a..5cfdae6 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -17,6 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 MKFS=mkfs.ext2
 which $MKFS || skip
 
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 331ee8e..09af3f7 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/scan_lvs = 1'
+
 aux extend_filter_LVMTEST
 aux prepare_pvs 3
 


