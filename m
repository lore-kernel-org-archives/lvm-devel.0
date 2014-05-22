From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 May 2014 10:02:31 +0000 (UTC)
Subject: master - tests: check more things with vgchange
Message-ID: <20140522100231.98767611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec9da34d86f7d573b3925b0f33ed9d19afa4d846
Commit:        ec9da34d86f7d573b3925b0f33ed9d19afa4d846
Parent:        65b0948c1e9baf65e7f1bffe0f01c355d094cf9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 22 12:00:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 22 12:01:44 2014 +0200

tests: check more things with vgchange

---
 test/shell/vgchange-usage.sh |   80 +++++++++++++++++++++++++++++++++++++----
 1 files changed, 72 insertions(+), 8 deletions(-)

diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 0ae9c14..0d57913 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -13,33 +13,97 @@ test_description='Exercise some vgchange diagnostics'
 
 . lib/test
 
-aux prepare_pvs 3
+aux prepare_pvs 4
+
 pvcreate --metadatacopies 0 "$dev1"
-vgcreate $vg $(cat DEVICES)
+vgcreate -s 4M $vg "$dev1" "$dev2" "$dev3"
+
+# cannot change anything in exported vg
+vgexport $vg
+fail vgchange -ay $vg
+fail vgchange -p 8 $vg
+fail vgchange -x n $vg
+fail vgchange --addtag tag $vg
+fail vgchange --deltag tag $vg
+fail vgchange -s 4k $vg
+fail vgchange --uuid $vg
+fail vgchange --alloc anywhere $vg
+fail vgchange -c y $vg
+vgimport $vg
+
+# unsupported combinations of options...
+invalid vgchange --ignorelockingfailure --uuid $vg
+invalid vgchange --sysinit --alloc normal $vg
+invalid vgchange --sysinit --poll y $vg
+invalid vgchange -an --poll y $vg
+invalid vgchange -an --monitor y $vg
+invalid vgchange -ay --refresh $vg
 
 vgdisplay $vg
 
 # vgchange -p MaxPhysicalVolumes (bz202232)
-aux check vg_field $vg max_pv 0
+check vg_field $vg max_pv 0
 vgchange -p 128 $vg
-aux check vg_field $vg max_pv 128
+check vg_field $vg max_pv 128
 
 pv_count=$(get vg_field $vg pv_count)
 not vgchange -p 2 $vg 2>err
 grep "MaxPhysicalVolumes is less than the current number $pv_count of PVs for" err
-aux check vg_field $vg max_pv 128
+check vg_field $vg max_pv 128
 
 # vgchange -l MaxLogicalVolumes
-aux check vg_field $vg max_lv 0
+check vg_field $vg max_lv 0
+invalid vgchange -l -128 $vg
 vgchange -l 128 $vg
-aux check vg_field $vg max_lv 128
+check vg_field $vg max_lv 128
 
+# vgchange -s
 lvcreate -l4 -n $lv1 $vg
 lvcreate -l4 -n $lv2 $vg
+SIZELV2=$(get lv_field $vg/$lv2 size)
+check lv_field $vg/$lv2 seg_size_pe "4"
+vgchange -s 4K $vg
+check vg_field $vg vg_extent_size "4.00k"
+check lv_field $vg/$lv2 size "$SIZELV2"
+check lv_field $vg/$lv2 seg_size_pe "4096"
+
 
 lv_count=$(get vg_field $vg lv_count)
 not vgchange -l 1 $vg 2>err
 grep "MaxLogicalVolume is less than the current number $lv_count of LVs for"  err
-aux check vg_field $vg max_lv 128
+check vg_field $vg max_lv 128
+
+# check non-resizebility
+fail vgchange -x y $vg
+check vg_attr_bit resizeable $vg "z"
+vgchange -x n $vg
+check vg_attr_bit resizeable $vg "-"
+fail vgchange -x n $vg
+fail vgextend $vg "$dev4"
+vgremove -ff $vg
+
+# set cluster bit
+vgcreate -cn $vg "$dev1" "$dev2" "$dev3"
+# check prompt to change cluster bit without giving explicit vg name
+fail vgchange -cy |& tee out
+grep "y/n" out
+check vg_attr_bit cluster $vg "-"
+vgchange -cy $vg
+fail vgchange -cy $vg
+
+# check on cluster
+# either skipped as clustered (non-cluster), or already clustered (on cluster)
+if test -e LOCAL_CLVMD ; then
+	check vg_attr_bit cluster $vg "c"
+	vgchange -cn $vg
+else
+	fail vgs $vg |& tee out
+	grep "Skipping clustered volume group" out
+	vgs --ignoreskippedcluster $vg |& tee out
+	not grep "Skipping clustered volume group" out
+	# reset back to non-clustered VG with disabled locking
+	vgchange -cn --config 'global{locking_type=0}' $vg
+fi
+check vg_attr_bit cluster $vg "-"
 
 vgremove -ff $vg


