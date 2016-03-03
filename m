From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Mar 2016 20:56:06 +0000 (UTC)
Subject: master - tests: direct control of lvm1 usage in tests
Message-ID: <20160303205606.5006460F47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad9cbe271458741f87dca834c16078f181612d76
Commit:        ad9cbe271458741f87dca834c16078f181612d76
Parent:        5764c484ea1eeef1c2726347ba2f93bb21fa4121
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 2 16:49:32 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 3 14:43:19 2016 -0600

tests: direct control of lvm1 usage in tests

Using lvm1 metadata with lvmetad is not generally allowed,
but nothing has prevented creating new lvm1 metadata with
lvmetad (missing error checking in pvcreate/vgcreate.)
Various tests are using lvm1 with lvmetad and happen to
work because of the missing error checks.

This commit fixes the tests so they won't fail when the
lvm1/lvmetad error checking is fixed.  A new variable
LVM_TEST_LVM1 is defined and is used in the scripts to
decide if lvm1 metadata should be tested.  LVM_TEST_LVM1
is not defined when lvmetad is being tested, and the
combination of LVM_TEST_LVM1 and LVM_TEST_LVMETAD can
be used to verify the desired lvmetad+lvm1 behavior.
---
 test/lib/flavour-ndev-cluster.sh |    1 +
 test/lib/flavour-ndev-vanilla.sh |    1 +
 test/lib/flavour-udev-cluster.sh |    1 +
 test/lib/flavour-udev-vanilla.sh |    1 +
 test/shell/format-lvm1.sh        |   35 +++++++++++++++++++++++++++++++++++
 test/shell/metadata.sh           |   11 +++++++----
 test/shell/pvchange-usage.sh     |    3 +++
 test/shell/pvcreate-operation.sh |    8 +++++++-
 test/shell/pvcreate-usage.sh     |   16 +++++-----------
 test/shell/vgcfgbackup-usage.sh  |    3 +++
 test/shell/vgcreate-usage.sh     |    8 +++++++-
 test/shell/vgextend-usage.sh     |    8 +++++++-
 test/shell/vgreduce-usage.sh     |    8 +++++++-
 test/shell/vgsplit-usage.sh      |   10 +++++++++-
 14 files changed, 94 insertions(+), 20 deletions(-)

diff --git a/test/lib/flavour-ndev-cluster.sh b/test/lib/flavour-ndev-cluster.sh
index 3629069..3082b11 100644
--- a/test/lib/flavour-ndev-cluster.sh
+++ b/test/lib/flavour-ndev-cluster.sh
@@ -1 +1,2 @@
 export LVM_TEST_LOCKING=3
+export LVM_TEST_LVM1=1
diff --git a/test/lib/flavour-ndev-vanilla.sh b/test/lib/flavour-ndev-vanilla.sh
index 1899c94..c106e61 100644
--- a/test/lib/flavour-ndev-vanilla.sh
+++ b/test/lib/flavour-ndev-vanilla.sh
@@ -1 +1,2 @@
 export LVM_TEST_LOCKING=1
+export LVM_TEST_LVM1=1
diff --git a/test/lib/flavour-udev-cluster.sh b/test/lib/flavour-udev-cluster.sh
index a9025a6..1cab558 100644
--- a/test/lib/flavour-udev-cluster.sh
+++ b/test/lib/flavour-udev-cluster.sh
@@ -1,2 +1,3 @@
 export LVM_TEST_LOCKING=3
 export LVM_TEST_DEVDIR=/dev
+export LVM_TEST_LVM1=1
diff --git a/test/lib/flavour-udev-vanilla.sh b/test/lib/flavour-udev-vanilla.sh
index ca778a6..6fbdafe 100644
--- a/test/lib/flavour-udev-vanilla.sh
+++ b/test/lib/flavour-udev-vanilla.sh
@@ -1,2 +1,3 @@
 export LVM_TEST_LOCKING=1
 export LVM_TEST_DEVDIR=/dev
+export LVM_TEST_LVM1=1
diff --git a/test/shell/format-lvm1.sh b/test/shell/format-lvm1.sh
new file mode 100644
index 0000000..2b6e1a2
--- /dev/null
+++ b/test/shell/format-lvm1.sh
@@ -0,0 +1,35 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test lvm1 format'
+
+. lib/inittest
+
+aux prepare_devs 1
+
+if test -n "$LVM_TEST_LVM1" ; then
+pvcreate -M1 "$dev1"
+vgcreate -M1 $vg "$dev1"
+check vg_field $vg fmt "lvm1"
+fi
+
+# TODO: if we decide to make using lvm1 with lvmetad an error,
+# then if lvmetad is being used, then verify:
+# not pvcreate -M1 "$dev1"
+# not vgcreate -M1 $vg "$dev1"
+#
+# TODO: if we decide to allow using lvm1 with lvmetad, but disable lvmetad
+# when it happens, then verify:
+# pvcreate -M1 "$dev1" | tee err
+# grep "disabled" err
+# vgcreate -M1 $vg "$dev1" | tee err
+# grep "disabled" err
+
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 9f4aa1f..273e2d1 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -46,7 +46,9 @@ for mdacp in 1 0; do
 done
 not grep "Cached VG .* incorrect PV list" out0
 
-# some M1 metadata tests
+# begin M1 metadata tests
+if test -n "$LVM_TEST_LVM1" ; then
+
 pvcreate -M1 "$dev1" "$dev2" "$dev3"
 pv3_uuid=$(get pv_field "$dev3" pv_uuid)
 vgcreate -M1 $vg "$dev1" "$dev2" "$dev3"
@@ -60,9 +62,6 @@ check pv_field "$dev3" pe_start $pv_align
 
 pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
 
-# vgconvert -M does not work with lvmetad
-test -e LOCAL_LVMETAD && exit 0
-
 # upgrade from v1 to v2 metadata
 vgconvert -M2 $vg
 
@@ -80,3 +79,7 @@ vgcfgrestore -f $TESTDIR/bak-$vg $vg
 
 # verify pe_start of $dev3
 check pv_field "$dev3" pe_start $pv_align
+
+fi
+# end M1 metadata tests
+
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index df7893e..0a0a9c1 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -113,7 +113,10 @@ vgremove -f $vg1
 fail pvchange "$dev1" --addtag test
 fail pvchange "$dev1" --deltag test
 
+if test -n "$LVM_TEST_LVM1" ; then
 # cannot add PV tag to lvm1 format
 pvcreate -M1 "$dev1"
 vgcreate -M1 $vg1 "$dev1"
 fail pvchange "$dev1" --addtag test
+fi
+
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index e2895ad..e8c05c4 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -17,7 +17,13 @@ aux lvmconf 'devices/md_component_detection = 1'
 
 aux prepare_devs 4
 
-for mdatype in 1 2
+if test -n "$LVM_TEST_LVM1" ; then
+mdatypes='1 2'
+else
+mdatypes='2'
+fi
+
+for mdatype in $mdatypes
 do
 # pvcreate (lvm$mdatype) refuses to overwrite an mounted filesystem (bz168330)
 	test ! -d mnt && mkdir mnt
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index ef59639..0a913d4 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -93,8 +93,10 @@ not pvcreate --labelsector 1000000000000 "$dev1"
 
 #COMM 'pvcreate basic dataalignment sanity checks'
 not pvcreate --dataalignment -1 "$dev1"
-not pvcreate -M 1 --dataalignment 1 "$dev1"
 not pvcreate --dataalignment 1e "$dev1"
+if test -n "$LVM_TEST_LVM1" ; then
+not pvcreate -M1 --dataalignment 1 "$dev1"
+fi
 
 #COMM 'pvcreate always rounded up to page size for start of device'
 #pvcreate --metadatacopies 0 --dataalignment 1 "$dev1"
@@ -142,7 +144,7 @@ check pv_field "$dev1" pv_mda_count 2
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
-if test ! -e LOCAL_LVMETAD; then
+if test -n "$LVM_TEST_LVM1" ; then
 pvcreate --dataalignment 256k "$dev1"
 vgcreate -s 1m $vg "$dev1"
 vgconvert -M1 $vg
@@ -152,21 +154,13 @@ vgremove $vg
 fi
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
-if test ! -e LOCAL_LVMETAD; then
+if test -n "$LVM_TEST_LVM1" ; then
 pvcreate --dataalignment 10k "$dev1"
 vgcreate -s 1m $vg "$dev1"
 not vgconvert -M1 $vg
 vgremove $vg
 fi
 
-#COMM 'vgconvert -M is disallowed with lvmetad'
-if test -e LOCAL_LVMETAD; then
-pvcreate "$dev1"
-vgcreate $vg "$dev1"
-not vgconvert -M1 $vg
-vgremove $vg
-fi
-
 #COMM 'vgcfgrestore allows pe_start=0'
 #basically it produces nonsense, but it tests vgcfgrestore,
 #not that final cfg is usable...
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index e763178..31b0a6f 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -78,6 +78,7 @@ vgremove -f $vg
 # vgcfgbackup correctly stores metadata LVM1 with missing PVs
 # FIXME: clvmd seems to have problem with metadata format change here
 # fix it and remove this vgscan
+if test -n "$LVM_TEST_LVM1" ; then
 vgscan
 pvcreate -M1 $(cat DEVICES)
 vgcreate -M1 -c n $vg $(cat DEVICES)
@@ -85,3 +86,5 @@ lvcreate -l1 -n $lv1 $vg "$dev1"
 pvremove -ff -y "$dev2"
 not lvcreate -l1 -n $lv1 $vg "$dev3"
 vgcfgbackup -f "backup.$$" $vg
+fi
+
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index 5648675..4161268 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -142,8 +142,14 @@ check pv_field "$dev1" pe_start ${pv_align}B --units b
 vgremove -f $vg
 pvremove -f "$dev1"
 
+if test -n "$LVM_TEST_LVM1" ; then
+mdatypes='1 2'
+else
+mdatypes='2'
+fi
+
 # metadatatype
-for i in 1 2
+for i in $mdatypes
 do
     vgcreate -M $i $vg "$dev1"
     check vg_field $vg vg_fmt lvm$i
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index 18a7dce..a470f71 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -20,7 +20,13 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 5
 
-for mdatype in 1 2
+if test -n "$LVM_TEST_LVM1" ; then
+mdatypes='1 2'
+else
+mdatypes='2'
+fi
+
+for mdatype in $mdatypes
 do
 
 # Explicit pvcreate
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 7feed2d..37a27a0 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -16,7 +16,13 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 4
 
-for mdatype in 1 2
+if test -n "$LVM_TEST_LVM1" ; then
+mdatypes='1 2'
+else
+mdatypes='2'
+fi
+
+for mdatype in $mdatypes
 do
     # setup PVs
     pvcreate -M$mdatype "$dev1" "$dev2"
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index 743a969..4f5c6d4 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -18,7 +18,13 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 5
 
-for mdatype in 1 2
+if test -n "$LVM_TEST_LVM1" ; then
+mdatypes='1 2'
+else
+mdatypes='2'
+fi
+
+for mdatype in $mdatypes
 do
 
 pvcreate -M$mdatype $(cat DEVICES)
@@ -162,6 +168,7 @@ check pvlv_counts $vg1 2 1 0
 vgremove -f $vg1
 
 # vgsplit rejects split because metadata types differ
+if test -n "$LVM_TEST_LVM1" ; then
 pvcreate -ff -M1 "$dev3" "$dev4"
 pvcreate -ff "$dev1" "$dev2"
 vgcreate -M1 $vg1 "$dev3" "$dev4"
@@ -169,3 +176,4 @@ vgcreate $vg2 "$dev1" "$dev2"
 not vgsplit $vg1 $vg2 "$dev3" 2>err;
 grep "Metadata types differ" err
 vgremove -f $vg1 $vg2
+fi


