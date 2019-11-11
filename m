From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:39 -0500
Subject: master - tests: add test of resize of different segtypes
Message-ID: <97361.119111116463600783@us-mta-301.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38617213f080492e03f324a73cd8f912ae557349
Commit:        38617213f080492e03f324a73cd8f912ae557349
Parent:        08f36dd093c708f0d4a4edd1fd1d84e9a2316313
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 11 17:43:24 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

tests: add test of resize of different segtypes

---
 test/shell/lvextend-thin-raid.sh |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-thin-raid.sh b/test/shell/lvextend-thin-raid.sh
index afbc630..a706887 100644
--- a/test/shell/lvextend-thin-raid.sh
+++ b/test/shell/lvextend-thin-raid.sh
@@ -20,7 +20,7 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 aux have_thin 1 0 0 || skip
 aux have_raid 1 3 0 || skip
 
-aux prepare_vg 6
+aux prepare_vg 6 600
 
 lvcreate --type raid1 -l2 --nosync -n pool $vg
 lvconvert --yes --thinpool $vg/pool "$dev3"
@@ -49,4 +49,15 @@ lvextend --poolmetadatasize +1 --size +1 $vg/pool
 check lv_field $vg/pool_tdata lv_size "7.50m" -a
 check lv_field $vg/pool_tmeta lv_size "4.50m" -a
 
+lvremove -f $vg
+
+# check resize of pool and metadata being a different segtype
+# https://bugzilla.redhat.com/1722666
+lvcreate -L4 -n pool $vg
+lvcreate --type raid1 -m1 -L2 --nosync -n meta $vg
+lvconvert --yes --thinpool $vg/pool --poolmetadata $vg/meta
+# using big enough pool so resize of pool metadata is enforced
+# (and it's using a differnt segtype)
+lvextend -L3G $vg/pool
+
 vgremove -ff $vg



