From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 23 Sep 2020 12:59:36 +0000 (GMT)
Subject: master - tests: add check for rename of cached vdopool
Message-ID: <20200923125936.B5985398E490@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39cdc1469d192e48bf5e1b39fc51a42c64e46ab6
Commit:        39cdc1469d192e48bf5e1b39fc51a42c64e46ab6
Parent:        cfc4dd4c7cb39354525866c9cd1b3c6442a6f558
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 13:22:08 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 23 14:47:30 2020 +0200

tests: add check for rename of cached vdopool

---
 test/shell/lvcreate-vdo-cache.sh | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-vdo-cache.sh b/test/shell/lvcreate-vdo-cache.sh
index b502986b4..c31ccccda 100644
--- a/test/shell/lvcreate-vdo-cache.sh
+++ b/test/shell/lvcreate-vdo-cache.sh
@@ -32,10 +32,22 @@ export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
 aux prepare_vg 1 9000
 
-lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool
+lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool1
 
 # Test caching VDOPoolLV
-lvcreate -H -L10 $vg/vpool
+lvcreate -H -L10 $vg/vpool1
+
+# Current VDO target driver cannot handle online rename
+# once this will be supported - update this test
+not lvrename $vg/vpool1 $vg/vpool 2>&1 | tee out
+grep "Cannot rename" out
+
+lvchange -an $vg
+
+# Ofline should work
+lvrename $vg/vpool1 $vg/vpool
+
+lvchange -ay $vg
 
 mkfs.ext4 -E nodiscard "$DM_DEV_DIR/$vg/$lv1"
 


