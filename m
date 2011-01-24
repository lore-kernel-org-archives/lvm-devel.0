From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:35 +0100
Subject: [PATCH 11/15] Testing: Lower device size of pvmove test
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <80d86769680d5c785c6031f496411dd48da4e6d3.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Lower size of devices in test.
And check only once that  LVs are prepared properly.
Make the test faster a bit.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-pvmove-basic.sh |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/test/t-pvmove-basic.sh b/test/t-pvmove-basic.sh
index 56e1f99..89d24e2 100755
--- a/test/t-pvmove-basic.sh
+++ b/test/t-pvmove-basic.sh
@@ -43,30 +43,34 @@ check_dev_sum_() {
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-aux prepare_vg 5 80
+aux prepare_vg 5 40
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
+FIRST=""
 
 prepare_lvs_() {
   lvcreate -l2 -n $lv1 $vg $dev1 
-    lv_is_on_ $vg/$lv1 $dev1 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1
   lvcreate -l9 -i3 -n $lv2 $vg $dev2 $dev3 $dev4 
-    lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4
   lvextend -l+2 $vg/$lv1 $dev2 
-    lv_is_on_ $vg/$lv1 $dev1 $dev2 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2
   lvextend -l+2 $vg/$lv1 $dev3 
-    lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3
   lvextend -l+2 $vg/$lv1 $dev1 
-    lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1
   lvcreate -l1 -n $lv3 $vg $dev2 
-    lv_is_on_ $vg/$lv3 $dev2 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv3 $dev2
   save_dev_sum_ $(lvdev_ $vg $lv1) 
   save_dev_sum_ $(lvdev_ $vg $lv2) 
   save_dev_sum_ $(lvdev_ $vg $lv3) 
-  lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs 
-  lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs 
-  lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
+  if test -z "$FIRST" ; then
+    lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs
+    lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs
+    lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
+  fi
+  FIRST=done
 }
 
 lv_not_changed_() {
-- 
1.7.3.5


