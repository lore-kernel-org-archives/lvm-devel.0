From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 21:38:32 +0000 (UTC)
Subject: master - tests: increase min version for raid testing
Message-ID: <20140523213832.74D0660303@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5c3995ed587aee6aaa15ea69df81c69a5bfbcd8
Commit:        c5c3995ed587aee6aaa15ea69df81c69a5bfbcd8
Parent:        3f8048f28c45101fde391c3609a97ca116b8e92c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 22:35:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 23:35:42 2014 +0200

tests: increase min version for raid testing

Seems smaller version are causing weird kernel lookups.
---
 test/shell/lvchange-partial.sh               |    2 +-
 test/shell/lvconvert-raid.sh                 |    2 +-
 test/shell/lvconvert-raid456.sh              |    2 +-
 test/shell/lvconvert-repair-raid-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-raid.sh          |    2 +-
 test/shell/lvcreate-large-raid.sh            |    2 +-
 test/shell/lvcreate-raid.sh                  |    2 +-
 test/shell/lvresize-raid.sh                  |    2 +-
 test/shell/vgsplit-raid.sh                   |    2 +-
 9 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index c3d7217..3db1b4f 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -15,7 +15,7 @@
 aux prepare_vg 4
 
 TYPE=raid1
-aux have_raid 1 1 0 || TYPE=mirror
+aux have_raid 1 3 0 || TYPE=mirror
 
 lvcreate -aey --type $TYPE -m 1 -l 2 -n $lv1 $vg
 lvchange -an $vg/$lv1
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 2a498b2..e17d90e 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -22,7 +22,7 @@ get_image_pvs() {
 ########################################################
 # MAIN
 ########################################################
-aux have_raid 1 2 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 5
 vgcreate -s 256k $vg $(cat DEVICES)
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index b9386c9..38f8ed5 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -23,7 +23,7 @@ get_image_pvs() {
 # MAIN
 ########################################################
 aux raid456_replace_works || skip
-aux have_raid 1 2 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 6
 vgcreate -s 256k $vg $(cat DEVICES)
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index f83e722..6766faa 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -12,7 +12,7 @@
 . lib/test
 
 which mkfs.ext3 || skip
-aux have_raid 1 1 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_dmeventd
 aux prepare_vg 5
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index df64f3b..8ba27b8 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux have_raid 1 1 0 || skip
+aux have_raid 1 3 0 || skip
 aux raid456_replace_works || skip
 
 aux lvmconf 'allocation/maximise_cling = 0'
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 84110ab..57a7765 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -16,7 +16,7 @@
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
-aux have_raid 1 1 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index d9c949a..76a606f 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -18,7 +18,7 @@ lv_devices() {
 ########################################################
 # MAIN
 ########################################################
-aux have_raid 1 1 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 vgcreate -s 512k $vg $(cat DEVICES)
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index e13a08d..d5288f8 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux have_raid 1 1 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 6 80
 
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index 6454556..3174e88 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -21,7 +21,7 @@ create_vg_() {
 	vgcreate -s 64k "$@"
 }
 
-aux have_raid 1 1 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 5 10
 


