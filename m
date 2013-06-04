From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:44 +0000 (UTC)
Subject: dev-mornfall-activate - tests: drop testing of raids in cluster
Message-ID: <20130604192744.4C1F761095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd9350198e3178251a54c442183465e8b7719251
Commit:        cd9350198e3178251a54c442183465e8b7719251
Parent:        e4dfa785d14643e1efd298af1040f461704b0a67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:48:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:35:23 2013 +0200

tests: drop testing of raids in cluster

Since raid is not clustered yet - drop it from testing in cluster phase.
(saving running some time)
---
 test/shell/lvconvert-raid.sh   |    4 +++-
 test/shell/lvconvert-raid10.sh |    4 +++-
 test/shell/lvcreate-large.sh   |    2 +-
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 59c8bdb..61345da 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -11,6 +11,8 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
+
 get_image_pvs() {
 	local d
 	local images
@@ -26,7 +28,7 @@ aux target_at_least dm-raid 1 2 0 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80
-vgcreate -c n -s 256k $vg $(cat DEVICES)
+vgcreate -s 256k $vg $(cat DEVICES)
 
 ###########################################
 # RAID1 convert tests
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index 2e4381d..b2d4afd 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -11,6 +11,8 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
+
 get_image_pvs() {
 	local d
 	local images
@@ -28,7 +30,7 @@ aux target_at_least dm-raid 1 3 1 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80
-vgcreate -c n -s 256k $vg $(cat DEVICES)
+vgcreate -s 256k $vg $(cat DEVICES)
 
 lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index b61ccca..09e323a 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -23,7 +23,7 @@ lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
 aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 
 pvcreate $DM_DEV_DIR/$vg/$lv
-vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv
+vgcreate $vg1 $DM_DEV_DIR/$vg/$lv
 
 lvcreate -l 100%FREE -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "1024.00t"


