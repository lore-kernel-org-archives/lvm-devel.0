From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 11:51:47 -0400
Subject: master - tests: remove use of vgcreate -c option
Message-ID: <201806081551.w58FplC6007258@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8266b7e951427de997b5b89d8ac8af8bf011c52e
Commit:        8266b7e951427de997b5b89d8ac8af8bf011c52e
Parent:        ae961a192a85c54bcf193a132bcb7c91c8dd8a79
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 10:51:07 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 10:51:07 2018 -0500

tests: remove use of vgcreate -c option

---
 test/shell/vgchange-partial.sh |    3 --
 test/shell/vgchange-usage.sh   |   46 ----------------------------------------
 2 files changed, 0 insertions(+), 49 deletions(-)

diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index 5f5920f..854b8aa 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -41,9 +41,6 @@ not vgchange -u $vg
 # physicalextentsize_ARG
 not vgchange -s 2M $vg
 
-# clustered_ARG
-not vgchange -c y $vg
-
 # alloc_ARG
 not vgchange --alloc anywhere $vg
 
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 9fe9bc5..f6fc842 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -31,7 +31,6 @@ fail vgchange --deltag tag $vg
 fail vgchange -s 4k $vg
 fail vgchange --uuid $vg
 fail vgchange --alloc anywhere $vg
-fail vgchange -c y $vg
 vgimport $vg
 
 # unsupported combinations of options...
@@ -96,48 +95,3 @@ check vg_attr_bit resizeable $vg "-"
 fail vgchange -x n $vg
 fail vgextend $vg "$dev4"
 vgremove -ff $vg
-
-# skip cluster tests with lvmlockd
-test -n "$LVM_TEST_LVMLOCKD" && exit 0
-
-# set cluster bit
-vgcreate $vg "$dev1" "$dev2" "$dev3"
-# check prompt to change cluster bit without giving explicit vg name
-fail vgchange -cy 2>&1 | tee out
-grep "y/n" out
-check vg_attr_bit cluster $vg "-"
-
-lvcreate -l1 -n $lv1 $vg
-
-# check on cluster
-# either skipped as clustered (non-cluster), or already clustered (on cluster)
-if test -e LOCAL_CLVMD ; then
-	# can switch with active LV
-	vgchange -cy $vg
-	fail vgchange -cy $vg
-	# check volume is active locally exclusively
-	check lv_field $vg/$lv1 lv_active "local exclusive"
-	check vg_attr_bit cluster $vg "c"
-	# check we do not support conversion of just locally active LVs
-	lvchange -an $vg
-	lvchange -ay $vg
-	not vgchange $vg
-	lvchange -an $vg
-	lvchange -aey $vg
-	vgchange $vg
-else
-	# no clvmd is running
-	fail vgchange -cy $vg
-	# can't switch with active LV
-	vgchange --yes -cy $vg
-	fail vgchange --yes -cy $vg
-	fail vgs $vg 2>&1 | tee out
-	grep "Skipping clustered volume group" out
-	vgs --ignoreskippedcluster $vg 2>&1 | tee out
-	not grep "Skipping clustered volume group" out
-	# reset back to non-clustered VG with disabled locking
-	vgchange $vg --config 'global{locking_type=0}' $vg
-fi
-check vg_attr_bit cluster $vg "-"
-
-vgremove -ff $vg


