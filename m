From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:34:04 +0000 (UTC)
Subject: master - tests: lvconvert thin pool
Message-ID: <20141006133404.EF4E060905@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=742d250cc52dcbd965310b1bf5357d4793254f4d
Commit:        742d250cc52dcbd965310b1bf5357d4793254f4d
Parent:        c243cf6581904c2628294d342ba1380208985e49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 11:56:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:31:44 2014 +0200

tests: lvconvert thin pool

More tests.
---
 test/shell/lvconvert-thin.sh |   53 +++++++++++++++++++++++++++++++----------
 1 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 4aee7d2..bd43d58 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -27,6 +27,7 @@ aux prepare_pvs 4 64
 
 # build one large PV
 vgcreate $vg1 $(head -n 3 DEVICES)
+
 # 32bit linux kernels are fragille with device size >= 16T
 # maybe  uname -m    [ x86_64 | i686 ]
 TSIZE=64T
@@ -63,12 +64,25 @@ lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 prepare_lvs
 lvconvert --yes -c 64 --stripes 2 --thinpool $vg/$lv1 --readahead 48
-
 lvremove -f $vg
-lvcreate -L1T -n $lv1 $vg
-lvconvert --yes -c 8M --type thin-pool $vg/$lv1
 
+
+# Swaping of metadata volume
+lvcreate -L1T -n $lv1 $vg
+lvcreate -L32 -n $lv2 $vg
+lvconvert --yes -c 8M --type thin-pool $vg/$lv1 |& tee err
+# Check tther is warning for large chunk size and zeroing enabled
+grep "Pool zeroing and large" err
+UUID=$(get lv_field $vg/$lv2 uuid)
+# Fail is pool is active
+# TODO  maybe detect inactive pool and deactivate
+fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
+lvchange -an $vg
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
+check lv_field $vg/${lv1}_tmeta uuid "$UUID"
 lvremove -f $vg
+
+
 # test with bigger sizes
 lvcreate -L1T -n $lv1 $vg
 lvcreate -L8M -n $lv2 $vg
@@ -81,39 +95,52 @@ invalid lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too small metadata (<2M)
 fail lvconvert --yes -c 64 --thinpool $vg/$lv1 --poolmetadata $vg/$lv3
 # too small chunk size fails
-# 'fail' because profiles need to read VG
-fail lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+invalid lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too big chunk size fails
-fail lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+invalid lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # negative chunk size fails
 invalid lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
-# non power of 2 fails
-fail lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# non multiple of 64KiB fails
+invalid lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 # Warning about smaller then suggested
 lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
 grep "WARNING: Chunk size is smaller" err
-
 lvremove -f $vg
+
+
 lvcreate -L1T -n $lv1 $vg
 lvcreate -L32G -n $lv2 $vg
 # Warning about bigger then needed
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
 grep "WARNING: Maximum" err
-
 lvremove -f $vg
 
+
 if test "$TSIZE" = 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
 lvconvert --yes -c 64 --thinpool $vg/$lv1 |& tee err
 grep "WARNING: Chunk size is too small" err
+lvremove -f $vg
 fi
 
 #lvs -a -o+chunk_size,stripe_size,seg_pe_ranges
 
-# Convertions of pool to mirror or RAID is unsupported
-fail lvconvert --type mirror -m1 $vg/$lv1
-fail lvconvert --type raid1 -m1 $vg/$lv1
+####################################
+# Prohibites thin pool conversions #
+####################################
+lvcreate -L32 -n $lv1 $vg
+lvcreate -L16 -n $lv2 $vg
+lvconvert --yes --thinpool $vg/$lv1
+
+fail lvconvert --yes --type cache-pool $vg/$lv1
+fail lvconvert --yes --type mirror -m1 $vg/$lv1
+fail lvconvert --yes --type raid1 -m1 $vg/$lv1
+fail lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
+fail lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
+fail lvconvert --yes --type thin-pool $vg/$lv1
+
+lvremove -f $vg
 
 vgremove -ff $vg


