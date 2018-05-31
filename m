From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:57 -0400
Subject: master - tests: process-each-duplicate-pvs update for lvmlockd
Message-ID: <201805311414.w4VEEvZC031254@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=abba06fb3b3b813e55ab7f27c6ac8274115083e4
Commit:        abba06fb3b3b813e55ab7f27c6ac8274115083e4
Parent:        3759a1f62bf314fbe2f25b2365c1aebca8071e31
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 15:59:17 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: process-each-duplicate-pvs update for lvmlockd

---
 test/shell/process-each-duplicate-pvs.sh |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 9ce4e14..b8a8774 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -8,7 +8,6 @@
 
 test_description='Test duplicate PVs'
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_CLVMD=1
 
@@ -25,8 +24,8 @@ aux lvmconf 'devices/allow_changes_with_duplicate_pvs = 0'
 
 pvcreate "$dev1"
 pvcreate "$dev2"
-vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev2"
+vgcreate $SHARED $vg1 "$dev1"
+vgcreate $SHARED $vg2 "$dev2"
 pvresize --setphysicalvolumesize 8m -y "$dev2"
 lvcreate -an -l1 -n $lv1 $vg1
 
@@ -378,7 +377,16 @@ dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
 dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
 pvscan --cache
 
-vgcreate "$vg2" "$dev3" "$dev4"
+# The previous steps prevent us from nicely cleaning up
+# the vg lockspace in lvmlockd, so just restart it;
+# what follows could also just be split into a separate test.
+if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
+	killall -9 lvmlockd
+	sleep 2
+	aux prepare_lvmlockd
+fi
+
+vgcreate $SHARED "$vg2" "$dev3" "$dev4"
 lvcreate -l1 -n $lv1 $vg2 "$dev3"
 lvcreate -l1 -n $lv2 $vg2 "$dev4"
 
@@ -457,7 +465,7 @@ pvscan --cache
 # Reverse devs in the previous in case dev3/dev4 would be
 # preferred even without an active LV using them.
 
-vgcreate $vg2 "$dev5" "$dev6"
+vgcreate $SHARED $vg2 "$dev5" "$dev6"
 lvcreate -l1 -n $lv1 $vg2 "$dev5"
 lvcreate -l1 -n $lv2 $vg2 "$dev6"
 


