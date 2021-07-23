From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jul 2021 14:38:21 +0000 (GMT)
Subject: main - tests: extend vgmerge testing
Message-ID: <20210723143821.9D19A383582C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ebcbe9ace6e5c88a35cf62cd04b853ca7551a2b
Commit:        8ebcbe9ace6e5c88a35cf62cd04b853ca7551a2b
Parent:        4b856476e96777842ea6c9b42654c369a6b22db4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 23 16:34:50 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 23 16:36:31 2021 +0200

tests: extend vgmerge testing

---
 test/shell/vgmerge-operation.sh | 42 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 21889e95d..0bf517d38 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -80,3 +80,45 @@ grep "Duplicate logical volume name \"$lv1\" in \"$vg2\" and \"$vg1" err
 check pvlv_counts $vg1 2 1 0
 check pvlv_counts $vg2 2 1 0
 vgremove -f $vg1 $vg2
+
+
+# 'vgmerge' handle pmspare for merged VG
+if aux have_thin 1 5 0; then
+
+# With disabled pmspare nothing is created
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
+lvcreate -T -L8M $vg1/pool1 --poolmetadatasize 8M --poolmetadataspare n
+lvcreate -T -L8M $vg2/pool2 --poolmetadatasize 4M --poolmetadataspare n
+vgchange -an $vg1 $vg2
+
+vgmerge --poolmetadataspare n $vg1 $vg2
+check lv_not_exists $vg/lvol0_pmspare
+vgremove -ff $vg1
+
+
+# With pmspare handling there are one created
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
+lvcreate -T -L8M $vg1/pool1 --poolmetadatasize 8M --poolmetadataspare n
+lvcreate -T -L8M $vg2/pool2 --poolmetadatasize 4M --poolmetadataspare n
+vgchange -an $vg1 $vg2
+
+vgmerge $vg1 $vg2
+check lv_field $vg1/lvol0_pmspare size "8.00m"
+vgremove -ff $vg1
+
+
+# When merged, bigger pmspare is preserved
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
+lvcreate -T -L8M $vg1/pool1 --poolmetadatasize 8M
+lvcreate -T -L8M $vg2/pool2 --poolmetadatasize 4M
+vgchange -an $vg1 $vg2
+
+vgmerge $vg1 $vg2
+
+check lv_field $vg1/lvol0_pmspare size "8.00m"
+vgremove -ff $vg1
+
+fi


