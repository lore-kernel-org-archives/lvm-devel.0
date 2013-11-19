From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Nov 2013 09:56:03 +0000 (UTC)
Subject: master - tests: on 32bit test with <16T devs
Message-ID: <20131119095603.41DD8610A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe609141a894d33b92a6eb5fb9b5ee62bdc6c4ee
Commit:        fe609141a894d33b92a6eb5fb9b5ee62bdc6c4ee
Parent:        c697f501c7d9f29b6e0b32225b962d1632654004
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 15 23:47:14 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 19 10:55:14 2013 +0100

tests: on 32bit test with <16T devs

Add  'can_use_16T' to detect systems where we could
safely use 16T devices without causing system deadlocks.

16T size leads on those to endless loops in udevd
- it calls blkid which tries cached read from such device
- this ends in endless loop.

Related problems:
https://bugzilla.redhat.com/show_bug.cgi?id=1015028
---
 test/lib/aux.sh                     |    6 ++++++
 test/shell/lvconvert-thin.sh        |    9 ++++++++-
 test/shell/lvcreate-large-raid.sh   |    3 +++
 test/shell/lvcreate-large-raid10.sh |    3 +++
 test/shell/lvcreate-large.sh        |    3 +++
 test/shell/snapshot-usage.sh        |   11 ++++++++++-
 6 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f51fc0d..6f21e8b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -670,6 +670,12 @@ wait_for_sync() {
 	return 1
 }
 
+# Check if tests are running on 64bit architecture
+can_use_16T()
+{
+	test "$(getconf LONG_BIT)" -eq 64
+}
+
 #
 # Check wheter kernel [dm module] target exist
 #@least in expected version
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 0081e45..d177f9a 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -28,7 +28,11 @@ aux prepare_pvs 4 64
 
 # build one large PV
 vgcreate $vg1 $(cut -d ' ' -f -3 DEVICES)
-lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize 64T
+# 32bit linux kernels are fragille with device size >= 16T
+# maybe  uname -m    [ x86_64 | i686 ]
+TSIZE=64T
+aux can_use_16T || TSIZE=15T
+lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
@@ -97,10 +101,13 @@ lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
 grep "WARNING: Maximum size" err
 
 lvremove -f $vg
+
+if test "$TSIZE" -eq 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
 lvconvert -c 64 --thinpool $vg/$lv1 |& tee err
 grep "WARNING: Chunk size is too small" err
+fi
 
 #lvs -a -o+chunk_size,stripe_size,seg_pe_ranges
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index a91da05..395cf2b 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -13,6 +13,9 @@
 
 . lib/test
 
+# FIXME  update test to make something useful on <16T
+aux can_use_16T || skip
+
 aux target_at_least dm-raid 1 1 0 || skip
 
 aux prepare_vg 5
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index d971d74..4f97997 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -13,6 +13,9 @@
 
 . lib/test
 
+# FIXME  update test to make something useful on <16T
+aux can_use_16T || skip
+
 aux target_at_least dm-raid 1 3 0 || skip
 
 aux prepare_vg 5
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 63b2b03..c8790f1 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -13,6 +13,9 @@
 
 . lib/test
 
+# FIXME  update test to make something useful on <16T
+aux can_use_16T || skip
+
 aux prepare_vg 4
 
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 3d4d308..9e6a14f 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -27,7 +27,10 @@ cleanup_tail()
 aux prepare_pvs 1
 vgcreate -s 4M $vg $(cat DEVICES)
 
-lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 15P
+TSIZE=15P
+aux can_use_16T || TSIZE=15T
+
+lvcreate -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
 
 aux extend_filter_LVMTEST
 aux lvmconf "activation/snapshot_autoextend_percent = 20" \
@@ -106,6 +109,9 @@ check lv_field $vg1/lvol1 size "28.00k"
 fill 20K
 vgremove -ff $vg1
 
+# Can't test >= 16T devices on 32bit
+if test "$TSIZE" -eq 15P ; then
+
 # Check usability with largest extent size
 pvcreate $DM_DEV_DIR/$vg/$lv
 vgcreate -s 4G $vg1 $DM_DEV_DIR/$vg/$lv
@@ -119,4 +125,7 @@ lvcreate -aey -V15E -l1 -n $lv1 -s $vg1
 check lv_field $vg1/$lv1 origin_size "15.00e"
 
 vgremove -ff $vg1
+
+fi
+
 vgremove -ff $vg


