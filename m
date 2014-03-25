From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:24:02 +0000 (UTC)
Subject: master - tests: wipe signature
Message-ID: <20140325102402.070DF60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8471fb01d885aab5c46b61602352ca90814f8a8e
Commit:        8471fb01d885aab5c46b61602352ca90814f8a8e
Parent:        3c9204a75a31324f661a3a2d7d9ad5494b0c3e35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 09:59:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:23:00 2014 +0100

tests: wipe signature

Check for usable blkid.
---
 test/shell/lvcreate-signature-wiping.sh |  100 ++++++++++++++++++------------
 1 files changed, 60 insertions(+), 40 deletions(-)

diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index be06bce..f45a372 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -13,81 +13,101 @@
 
 . lib/test
 
+init_lv_() {
+	mkswap "$DM_DEV_DIR/$vg/$lv1"
+}
+
+test_blkid_() {
+	local type=$(blkid -s TYPE -o value -c /dev/null "$DM_DEV_DIR/$vg/$lv1")
+	test "$type" = "swap"
+}
+
+test_msg_() {
+	grep "Wiping swap signature" out
+}
+
 aux prepare_vg
 
 # lvcreate wipes signatures when found on newly created LV - test this on "swap".
 # Test all combinatios with -Z{y|n} and -W{y|n} and related lvm.conf settings.
 
 lvcreate -l1 -n $lv1 $vg
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+init_lv_
+# This system has unusable blkid (does not recognize small swap, needs fix...)
+test_blkid_ || skip
 lvremove -f $vg/$lv1
 
-wiping_msg="Wiping swap signature"
-
 aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 0"
 
-lvcreate -y -Zn -l1 -n $lv1 $vg | not grep "$wiping_msg"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zn -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+test_blkid_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zn -Wn -l1 -n $lv1 $vg | not grep "$wiping_msg"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zn -Wn -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+test_blkid_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zn -Wy -l1 -n $lv1 $vg | grep "$wiping_msg"
-(blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" || true) | not grep "swap"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zn -Wy -l1 -n $lv1 $vg 2>&1 | tee out
+test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zy -l1 -n $lv1 $vg | not grep "$wiping_msg"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zy -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zy -Wn -l1 -n $lv1 $vg | not grep "$wiping_msg"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zy -Wn -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zy -Wy -l1 -n $lv1 $vg | grep "$wiping_msg"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zy -Wy -l1 -n $lv1 $vg 2>&1 | tee out
+test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
 
 aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 1"
 
-lvcreate -y -Zn -l1 -n $lv1 $vg | not grep "$wiping_msg"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zn -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+test_blkid_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zn -Wn -l1 -n $lv1 $vg | not grep "$wiping_msg"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zn -Wn -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+test_blkid_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zn -Wy -l1 -n $lv1 $vg | grep "$wiping_msg"
-(blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" || true) | not grep "swap"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zn -Wy -l1 -n $lv1 $vg 2>&1 | tee out
+test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zy -l1 -n $lv1 $vg | grep "$wiping_msg"
-(blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" || true) | not grep "swap"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zy -l1 -n $lv1 $vg 2>&1 | tee out
+test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zy -Wn -l1 -n $lv1 $vg | not grep "$wiping_msg"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zy -Wn -l1 -n $lv1 $vg 2>&1 | tee out
+not test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
-lvcreate -y -Zy -Wy -l1 -n $lv1 $vg | grep "$wiping_msg"
-(blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" || true) | not grep "swap"
-mkswap "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
+lvcreate -y -Zy -Wy -l1 -n $lv1 $vg 2>&1 | tee out
+test_msg_
+not test_blkid_
+init_lv_
 lvremove -f $vg/$lv1
 
 vgremove -f $vg


