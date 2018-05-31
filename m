From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:43 -0400
Subject: master - tests: vgcreate-usage update for lvmlockd
Message-ID: <201805311414.w4VEEhjX031211@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=95cf127134c93882f78d13d26a87e28f2c256d34
Commit:        95cf127134c93882f78d13d26a87e28f2c256d34
Parent:        595196bc29e97cded7b4654db6824c5276f25eee
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 14:28:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: vgcreate-usage update for lvmlockd

---
 test/shell/vgcreate-usage.sh |   89 +++++++++++++++++++++--------------------
 1 files changed, 46 insertions(+), 43 deletions(-)

diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index 40eb99b..1959313 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise some vgcreate diagnostics'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -22,87 +22,90 @@ pvcreate --metadatacopies 0 "$dev3"
 
 vg=${PREFIX}vg
 
-#COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
-vgcreate $vg --physicalextentsize 8.00m "$dev1" "$dev2"
+#COMM 'vgcreate $SHARED accepts 8.00m physicalextentsize for VG'
+vgcreate $SHARED $vg --physicalextentsize 8.00m "$dev1" "$dev2"
 check vg_field  $vg vg_extent_size 8.00m
 vgremove $vg
 # try vgck and to remove it again - should fail (but not segfault)
 not vgremove $vg
 not vgck $vg
 
-#COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
-vgcreate $vg --maxlogicalvolumes 128 "$dev1" "$dev2"
+#COMM 'vgcreate $SHARED accepts smaller (128) maxlogicalvolumes for VG'
+vgcreate $SHARED $vg --maxlogicalvolumes 128 "$dev1" "$dev2"
 check vg_field $vg max_lv 128 
 vgremove $vg
 
-#COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
-vgcreate $vg --maxphysicalvolumes 128 "$dev1" "$dev2"
+#COMM 'vgcreate $SHARED accepts smaller (128) maxphysicalvolumes for VG'
+vgcreate $SHARED $vg --maxphysicalvolumes 128 "$dev1" "$dev2"
 check vg_field $vg max_pv 128
 vgremove $vg
 
-#COMM 'vgcreate rejects a zero physical extent size'
-not vgcreate --physicalextentsize 0 $vg "$dev1" "$dev2" 2>err
+#COMM 'vgcreate $SHARED rejects a zero physical extent size'
+not vgcreate $SHARED --physicalextentsize 0 $vg "$dev1" "$dev2" 2>err
 grep "Physical extent size may not be zero" err
 
-#COMM 'vgcreate rejects "inherit" allocation policy'
-not vgcreate --alloc inherit $vg "$dev1" "$dev2" 2>err
+#COMM 'vgcreate $SHARED rejects "inherit" allocation policy'
+not vgcreate $SHARED --alloc inherit $vg "$dev1" "$dev2" 2>err
 grep "Volume Group allocation policy cannot inherit from anything" err
 
-#COMM 'vgcreate rejects vgname "."'
+#COMM 'vgcreate $SHARED rejects vgname "."'
 vginvalid=.; 
-not vgcreate $vginvalid "$dev1" "$dev2" 2>err
+not vgcreate $SHARED $vginvalid "$dev1" "$dev2" 2>err
 grep "New volume group name \"$vginvalid\" is invalid" err
 
-#COMM 'vgcreate rejects vgname greater than 128 characters'
+#COMM 'vgcreate $SHARED rejects vgname greater than 128 characters'
 vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome
-not vgcreate $vginvalid "$dev1" "$dev2" 2>err
+not vgcreate $SHARED $vginvalid "$dev1" "$dev2" 2>err
 grep "New volume group name \"$vginvalid\" is invalid" err
 
-#COMM 'vgcreate rejects already existing vgname "/tmp/$vg"'
+#COMM 'vgcreate $SHARED rejects already existing vgname "/tmp/$vg"'
 #touch /tmp/$vg
-#not vgcreate $vg "$dev1" "$dev2" 2>err
+#not vgcreate $SHARED $vg "$dev1" "$dev2" 2>err
 #grep "New volume group name \"$vg\" is invalid\$" err
 
-#COMM "vgcreate rejects repeated invocation (run 2 times) (bz178216)"
-vgcreate $vg "$dev1" "$dev2"
-not vgcreate $vg "$dev1" "$dev2"
+#COMM "vgcreate $SHARED rejects repeated invocation (run 2 times) (bz178216)"
+vgcreate $SHARED $vg "$dev1" "$dev2"
+not vgcreate $SHARED $vg "$dev1" "$dev2"
 vgremove -ff $vg
 
-#COMM "vgcreate fails when the only pv has --metadatacopies 0"
-not vgcreate $vg "$dev3"
+#COMM "vgcreate $SHARED fails when the only pv has --metadatacopies 0"
+not vgcreate $SHARED $vg "$dev3"
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
-not vgcreate --physicalextentsize 0k $vg "$dev1" "$dev2"
-vgcreate --physicalextentsize 4k $vg "$dev1" "$dev2"
+not vgcreate $SHARED --physicalextentsize 0k $vg "$dev1" "$dev2"
+vgcreate $SHARED --physicalextentsize 4k $vg "$dev1" "$dev2"
 check vg_field $vg vg_extent_size 4.00k
 vgremove -ff $vg
-not vgcreate --physicalextentsize 7K $vg "$dev1" "$dev2"
-not vgcreate --physicalextentsize 1024t $vg "$dev1" "$dev2"
-#not vgcreate --physicalextentsize 1T $vg "$dev1" "$dev2"
-# FIXME: vgcreate allows physicalextentsize larger than pv size!
+not vgcreate $SHARED --physicalextentsize 7K $vg "$dev1" "$dev2"
+not vgcreate $SHARED --physicalextentsize 1024t $vg "$dev1" "$dev2"
+#not vgcreate $SHARED --physicalextentsize 1T $vg "$dev1" "$dev2"
+# FIXME: vgcreate $SHARED allows physicalextentsize larger than pv size!
 
 # Test default max_lv, max_pv, extent_size, alloc_policy, clustered
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 check vg_field $vg vg_extent_size 4.00m
 check vg_field $vg max_lv 0
 check vg_field $vg max_pv 0
 ATTRS="wz--n-"
 test -e LOCAL_CLVMD && ATTRS="wz--nc"
+if test -n "$LVM_TEST_LVMLOCKD"; then
+ATTRS="wz--ns"
+fi
 check vg_field $vg vg_attr $ATTRS
 vgremove -ff $vg
 
-# Implicit pvcreate tests, test pvcreate options on vgcreate
+# Implicit pvcreate tests, test pvcreate options on vgcreate $SHARED
 # --force, --yes, --metadata{size|copies|type}, --zero
 # --dataalignment[offset]
 pvremove "$dev1" "$dev2"
-vgcreate --force --yes --zero y $vg "$dev1" "$dev2"
+vgcreate $SHARED --force --yes --zero y $vg "$dev1" "$dev2"
 vgremove -f $vg
 pvremove -f "$dev1"
 
 for i in 0 1 2 3
 do
-# vgcreate (lvm2) succeeds writing LVM label at sector $i
-    vgcreate --labelsector $i $vg "$dev1"
+# vgcreate $SHARED (lvm2) succeeds writing LVM label at sector $i
+    vgcreate $SHARED --labelsector $i $vg "$dev1"
     dd if="$dev1" bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgremove -f $vg
     pvremove -f "$dev1"
@@ -111,14 +114,14 @@ done
 # pvmetadatacopies
 for i in 1 2
 do
-    vgcreate --pvmetadatacopies $i $vg "$dev1"
+    vgcreate $SHARED --pvmetadatacopies $i $vg "$dev1"
     check pv_field "$dev1" pv_mda_count $i
     vgremove -f $vg
     pvremove -f "$dev1"
 done
-not vgcreate --pvmetadatacopies 0 $vg "$dev1"
+not vgcreate $SHARED --pvmetadatacopies 0 $vg "$dev1"
 pvcreate --metadatacopies 1 "$dev2"
-vgcreate --pvmetadatacopies 0 $vg "$dev1" "$dev2"
+vgcreate $SHARED --pvmetadatacopies 0 $vg "$dev1" "$dev2"
 check pv_field "$dev1" pv_mda_count 0
 check pv_field "$dev2" pv_mda_count 1
 vgremove -f $vg
@@ -126,7 +129,7 @@ pvremove -f "$dev1"
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
-vgcreate --metadatasize 100k --dataalignment 100k $vg "$dev1"
+vgcreate $SHARED --metadatasize 100k --dataalignment 100k $vg "$dev1"
 check pv_field "$dev1" pe_start 200.00k
 vgremove -f $vg
 pvremove -f "$dev1"
@@ -134,7 +137,7 @@ pvremove -f "$dev1"
 # data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
 pv_align=1052160 # 1048576 + (7*512)
-vgcreate --metadatasize 128k --dataalignmentoffset 7s $vg "$dev1"
+vgcreate $SHARED --metadatasize 128k --dataalignmentoffset 7s $vg "$dev1"
 check pv_field "$dev1" pe_start ${pv_align}B --units b
 vgremove -f $vg
 pvremove -f "$dev1"
@@ -148,21 +151,21 @@ fi
 # metadatatype
 for i in $mdatypes
 do
-    vgcreate -M $i $vg "$dev1"
+    vgcreate $SHARED -M $i $vg "$dev1"
     check vg_field $vg vg_fmt lvm$i
     vgremove -f $vg
     pvremove -f "$dev1"
 done
 
-# vgcreate fails if pv belongs to existing vg
-vgcreate $vg1 "$dev1" "$dev2"
-not vgcreate $vg2 "$dev2"
+# vgcreate $SHARED fails if pv belongs to existing vg
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
+not vgcreate $SHARED $vg2 "$dev2"
 vgremove -f $vg1
 pvremove -f "$dev1" "$dev2"
 
 # all PVs exist in the VG after created
 pvcreate "$dev1"
-vgcreate $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED $vg1 "$dev1" "$dev2" "$dev3"
 check pv_field "$dev1" vg_name $vg1
 check pv_field "$dev2" vg_name $vg1
 check pv_field "$dev3" vg_name $vg1


