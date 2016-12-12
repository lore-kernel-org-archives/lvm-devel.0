From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Dec 2016 10:24:25 +0000 (UTC)
Subject: master - tests: use prepare_vg more often
Message-ID: <20161212102425.4B4EF60C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3dd6e2c7e13a8b04829ab6a9a9df29a46b532bf0
Commit:        3dd6e2c7e13a8b04829ab6a9a9df29a46b532bf0
Parent:        8c9c6ab66060cfc3383297a6baed229f9f341d4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 12 11:22:41 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 12 11:22:41 2016 +0100

tests: use prepare_vg more often

---
 test/shell/discards-thin.sh                 |    4 +---
 test/shell/error-usage.sh                   |    4 +---
 test/shell/lvconvert-mirror-basic.sh        |    3 +--
 test/shell/lvconvert-raid456.sh             |    3 +--
 test/shell/lvcreate-raid10.sh               |    4 +---
 test/shell/lvextend-thin-full.sh            |    4 +---
 test/shell/lvmetad-dump.sh                  |    4 +++-
 test/shell/lvresize-thin-external-origin.sh |    4 +---
 test/shell/lvresize-thin-metadata.sh        |    4 +---
 test/shell/pvmove-all-segtypes.sh           |    3 +--
 test/shell/thin-foreign-dmeventd.sh         |    4 +---
 test/shell/thin-resize-match.sh             |    4 +---
 test/shell/zero-usage.sh                    |    4 +---
 13 files changed, 15 insertions(+), 34 deletions(-)

diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index f85b22c..9a66dc8 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -25,12 +25,10 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 #
 aux have_thin 1 1 0 || skip
 
-aux prepare_pvs 2 64
+aux prepare_vg 2 64
 
 aux extend_filter_LVMTEST
 
-vgcreate $vg -s 64K $(cat DEVICES)
-
 # Create named pool only
 lvcreate -l1 --discards ignore -T $vg/pool
 check lv_field $vg/pool discards "ignore"
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 1f03071..c8765a6 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -16,9 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_pvs 1
-
-vgcreate -s 256k $vg $(cat DEVICES)
+aux prepare_vg 1
 
 lvcreate --type error -L1 -n $lv1 $vg
 lvextend -L+1 $vg/$lv1
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 81fb0c6..c32b5c1 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -123,8 +123,7 @@ test_lvconvert() {
 	fi
 }
 
-aux prepare_pvs 5 5
-vgcreate -s 32k $vg $(cat DEVICES)
+aux prepare_vg 5 5
 
 MIRRORED="mirrored"
 # FIXME: Cluster is not supporting exlusive activation of mirrored log
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 358ceec..8c87a03 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -28,8 +28,7 @@ get_image_pvs() {
 aux raid456_replace_works || skip
 aux have_raid 1 3 0 || skip
 
-aux prepare_pvs 7  # 7 devices for 2 dev replacement of 5-dev RAID6
-vgcreate -s 256k $vg $(cat DEVICES)
+aux prepare_vg 7  # 7 devices for 2 dev replacement of 5-dev RAID6
 
 levels="5 6"
 aux have_raid4 && levels="4 5 6"
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index bebe221..68b4f46 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -23,9 +23,7 @@ lv_devices() {
 ########################################################
 aux have_raid 1 3 0 || skip
 
-aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
-vgcreate -s 512k $vg $(cat DEVICES)
-
+aux prepare_vg 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 #
 # Create RAID10:
 #
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index 8fc89a8..3bafad4 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -27,9 +27,7 @@ test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_r
 
 aux have_thin 1 10 0 || skip
 
-aux prepare_pvs 3 256
-
-vgcreate -s 1M $vg $(cat DEVICES)
+aux prepare_vg 3 256
 
 aux lvmconf 'activation/thin_pool_autoextend_percent = 30' \
 	    'activation/thin_pool_autoextend_threshold = 70'
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 67ea01b..49cf9b7 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -15,11 +15,13 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# check we can talk to lvmetad
+(echo | aux lvmetad_talk) || skip
+
 aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n bar -l 1 $vg1
 
-(echo | aux lvmetad_talk) || skip
 aux lvmetad_dump | tee lvmetad.txt
 
 grep $vg1 lvmetad.txt
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index c1ebffe..686da39 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -23,9 +23,7 @@ aux have_thin 1 2 0 || skip
 # Pretend we miss the external_origin_extend feature
 aux lvmconf 'global/thin_disabled_features = [ "external_origin_extend" ]'
 
-aux prepare_pvs 2
-
-vgcreate -s 1M $vg $(cat DEVICES)
+aux prepare_vg 2
 
 lvcreate -L10 -n $lv1 $vg
 
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 2ef4fce..a08fb40 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -18,9 +18,7 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 aux have_thin 1 10 0 || skip
 
-aux prepare_pvs 3 1256
-
-vgcreate -s 1M $vg $(cat DEVICES)
+aux prepare_vg 3 1256
 
 for deactivate in true false; do
 # Create some thin volumes
diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index e5f3b74..6a34ecf 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -17,8 +17,7 @@ SKIP_WITH_LVMLOCKD=1
 
 which md5sum || skip
 
-aux prepare_pvs 5 20
-vgcreate -s 256k $vg $(cat DEVICES)
+aux prepare_vg 5 20
 
 # Each of the following tests does:
 # 1) Create two LVs - one linear and one other segment type
diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index 50ff44e..4ba3205 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -42,9 +42,7 @@ which mkfs.ext4 || skip
 export MKE2FS_CONFIG="$TESTOLDPWD/lib/mke2fs.conf"
 
 aux prepare_dmeventd
-aux prepare_pvs 2 64
-
-vgcreate $vg -s 64K $(cat DEVICES)
+aux prepare_vg 2 64
 
 # Create named pool only
 lvcreate --errorwhenfull y -L2 -T $vg/pool
diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index 047225b..c78842f 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -23,9 +23,7 @@ which md5sum || skip
 
 aux have_thin 1 0 0 || skip
 
-aux prepare_pvs 2 20
-
-vgcreate -s 512K $vg $(< DEVICES)
+aux prepare_vg 2 20
 
 lvcreate -L1M -V2M -n $lv1 -T $vg/pool
 
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index 768df28..5d393f5 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -18,9 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 
 which md5sum || skip
 
-aux prepare_pvs 1
-
-vgcreate -s 256k $vg $(cat DEVICES)
+aux prepare_vg 1
 
 lvcreate --type zero -L1 -n $lv1 $vg
 lvextend -L+1 $vg/$lv1


