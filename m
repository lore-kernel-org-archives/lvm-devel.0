From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Oct 2020 16:33:09 +0000 (GMT)
Subject: master - tests: enable writecache test that uses cleaner
Message-ID: <20201001163309.BB4DA398B88B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff3945777ba6cb093174b99a9870df2494f4c29b
Commit:        ff3945777ba6cb093174b99a9870df2494f4c29b
Parent:        c32d7fed4f78b4537f4ada4318866786a9fab493
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 22 11:52:14 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 11:33:02 2020 -0500

tests: enable writecache test that uses cleaner

---
 test/shell/writecache.sh | 48 ++++++++++++++++++++++--------------------------
 1 file changed, 22 insertions(+), 26 deletions(-)

diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 99be31e6b..e549b113c 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -236,34 +236,30 @@ _verify_data_on_lv
 lvremove $vg/$lv1
 lvremove $vg/$lv2
 
-# FIXME: test depends on unpushed commit
-# that enables two stage flush using cleaner
-#
 # Test attach while active, detach while active,
 # skip cleaner so flush message is used instead
-# 
-# lvcreate -n $lv1 -l 8 -an $vg "$dev1"
-# lvcreate -n $lv2 -l 4 -an $vg "$dev2"
-# lvchange -ay $vg/$lv1
-# _add_new_data_to_mnt
-# lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
-# blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-# blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-# _add_more_data_to_mnt
-# _verify_data_on_mnt
-# lvconvert --splitcache --cachesettings cleaner=0 $vg/$lv1
-# check lv_field $vg/$lv1 segtype linear
-# check lv_field $vg/$lv2 segtype linear
-# blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
-# blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
-# _verify_data_on_mnt
-# _verify_more_data_on_mnt
-# umount $mnt
-# lvchange -an $vg/$lv1
-# lvchange -an $vg/$lv2
-# _verify_data_on_lv
-# lvremove $vg/$lv1
-# lvremove $vg/$lv2
+lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+lvchange -ay $vg/$lv1
+_add_new_data_to_mnt
+lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
+blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
+blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
+_add_more_data_to_mnt
+_verify_data_on_mnt
+lvconvert --splitcache --cachesettings cleaner=0 $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
+blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
+_verify_data_on_mnt
+_verify_more_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+_verify_data_on_lv
+lvremove $vg/$lv1
+lvremove $vg/$lv2
  
 vgremove -ff $vg
  


