From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jul 2021 13:57:20 +0000 (GMT)
Subject: main - test
Message-ID: <20210721135720.D15683858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b70c341c9e9526cc21f590af73ccce2369755736
Commit:        b70c341c9e9526cc21f590af73ccce2369755736
Parent:        2132fdc11f7bc285638765e001bef6a3e595b286
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 20 22:37:54 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 21 15:56:33 2021 +0200

test

---
 test/shell/vgsplit-cache.sh | 47 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/test/shell/vgsplit-cache.sh b/test/shell/vgsplit-cache.sh
index eba85befe..202e4b562 100644
--- a/test/shell/vgsplit-cache.sh
+++ b/test/shell/vgsplit-cache.sh
@@ -75,6 +75,53 @@ lvremove -y $vg
 vgremove -ff $vg
 vgremove -ff $vg1
 
+#
+# Check we handle pmspare for splitted VGs
+#
+aux prepare_vg 7
+
+# Create cache-pool and pmspare on single PV1
+lvcreate -L10 --type cache-pool $vg/cpool "$dev1"
+# Move spare to separate PV3
+pvmove -n $vg/lvol0_pmspare "$dev1" "$dev3"
+# Create origin on PV2
+lvcreate -L10 -n orig $vg  "$dev2"
+lvconvert -H -y --cachepool $vg/cpool $vg/orig
+
+vgchange -an $vg
+
+# Check we do not create new _pmspare
+vgsplit --poolmetadataspare n  $vg $vg1 "$dev2" "$dev1"
+
+check lv_exists $vg/lvol0_pmspare
+check lv_not_exists $vg1/lvol0_pmspare
+
+vgremove $vg
+vgremove -f $vg1
+
+
+aux prepare_vg 7
+
+# Again - now with handling _pmspare by vgsplit
+lvcreate -L10 --type cache-pool $vg/cpool "$dev1"
+# Move spare to separate PV3
+pvmove -n $vg/lvol0_pmspare "$dev1" "$dev3"
+# Create origin on PV2
+lvcreate -L10 -n orig $vg  "$dev2"
+lvconvert -H -y --cachepool $vg/cpool $vg/orig
+
+vgchange -an $vg
+
+# Handle _pmspare  (default)
+vgsplit --poolmetadataspare y  $vg $vg1 "$dev2" "$dev1"
+
+check lv_not_exists $vg/lvol0_pmspare
+check lv_exists $vg1/lvol0_pmspare
+
+vgremove $vg
+vgremove -f $vg1
+
+
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 lvcreate -L6 -n $lv1 -an $vg "$dev2"


