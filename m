From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:44 +0100
Subject: [PATCH 21/24] Testing: remove -q from grep
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <56935a36945105a151999d7fed409100ec18c264.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

to avoid problems with pipe breaking

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-mirror-names.sh                  |    2 +-
 test/t-mirror-vgreduce-removemissing.sh |    2 +-
 test/t-pvcreate-operation.sh            |    2 +-
 test/t-snapshot-merge.sh                |    9 +++++----
 test/t-vgcreate-usage.sh                |    2 +-
 test/t-vgextend-usage.sh                |    2 +-
 6 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/test/t-mirror-names.sh b/test/t-mirror-names.sh
index aae7cf5..09ac9d3 100644
--- a/test/t-mirror-names.sh
+++ b/test/t-mirror-names.sh
@@ -27,7 +27,7 @@ lv_devices_() {
                sed 's/ //g' | sed 's/,/ /g')
 
   for d in $devs; do
-    (echo $devices | grep -q $d)  || return 1
+    (echo $devices | grep $d >/dev/null)  || return 1
     devices=$(echo $devices | sed "s/$d//")
   done
 
diff --git a/test/t-mirror-vgreduce-removemissing.sh b/test/t-mirror-vgreduce-removemissing.sh
index 146c2d4..f4f7567 100755
--- a/test/t-mirror-vgreduce-removemissing.sh
+++ b/test/t-mirror-vgreduce-removemissing.sh
@@ -65,7 +65,7 @@ lv_is_linear_()
 {
 	echo "Check if $1 is linear LV (i.e. not a mirror)"
 	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
-	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep -q '^1-'
+	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep '^1-' >/dev/null
 }
 
 rest_pvs_()
diff --git a/test/t-pvcreate-operation.sh b/test/t-pvcreate-operation.sh
index f9a9eb6..a1663d6 100755
--- a/test/t-pvcreate-operation.sh
+++ b/test/t-pvcreate-operation.sh
@@ -82,7 +82,7 @@ for i in 0 1 2 3
 do
 # pvcreate (lvm2) succeeds writing LVM label at sector $i
     pvcreate --labelsector $i $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     pvremove -f $dev1
 done
 
diff --git a/test/t-snapshot-merge.sh b/test/t-snapshot-merge.sh
index 2895c76..22babf8 100755
--- a/test/t-snapshot-merge.sh
+++ b/test/t-snapshot-merge.sh
@@ -47,7 +47,7 @@ aux prepare_vg 1 100
 # test full merge of a single LV
 setup_merge $vg $lv1
 # now that snapshot LV is created: test if snapshot-merge target is available
-$(dmsetup targets | grep -q snapshot-merge) || exit 200
+$(dmsetup targets | grep snapshot-merge >/dev/null) || exit 200
 lvs -a
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge 2>err
@@ -73,11 +73,12 @@ lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvchange --refresh $vg/$lv1
 umount test_mnt
 rm -r test_mnt
-dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+dmsetup table ${vg}-${lv1} | grep " snapshot-origin "
+
 # -- refresh LV to start merge (now that FS is unmounted),
 #    an active merge uses the 'snapshot-merge' target
 lvchange --refresh $vg/$lv1
-dmsetup table ${vg}-${lv1} | grep -q " snapshot-merge "
+dmsetup table ${vg}-${lv1} | grep " snapshot-merge "
 # -- don't care if merge is still active; lvremove at this point
 #    may test stopping an active merge
 lvremove -f $vg/$lv1
@@ -96,7 +97,7 @@ lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvchange --refresh $vg/$lv1
 umount test_mnt
 rm -r test_mnt
-dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+dmsetup table ${vg}-${lv1} | grep " snapshot-origin " >/dev/null
 lvremove -f $vg/$lv1
 
 
diff --git a/test/t-vgcreate-usage.sh b/test/t-vgcreate-usage.sh
index ab7ef54..916262e 100755
--- a/test/t-vgcreate-usage.sh
+++ b/test/t-vgcreate-usage.sh
@@ -102,7 +102,7 @@ for i in 0 1 2 3
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
     vgcreate -c n --labelsector $i $vg $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgremove -f $vg
     pvremove -f $dev1
 done
diff --git a/test/t-vgextend-usage.sh b/test/t-vgextend-usage.sh
index 4d13de5..07bca52 100644
--- a/test/t-vgextend-usage.sh
+++ b/test/t-vgextend-usage.sh
@@ -46,7 +46,7 @@ for i in 0 1 2 3
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
     vgextend --labelsector $i $vg $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgreduce $vg $dev1
     pvremove -f $dev1
 done
-- 
1.7.3.5


