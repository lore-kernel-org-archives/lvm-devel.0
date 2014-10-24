From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:20 +0000 (UTC)
Subject: master - tests: lvcreate usage
Message-ID: <20141024144120.D69E760CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9642f013a104590b575badc024b887a02c7ad750
Commit:        9642f013a104590b575badc024b887a02c7ad750
Parent:        11ea72cfd872d4a54e7db52e347688039378bc72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 11 09:12:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

tests: lvcreate usage

---
 test/shell/lvcreate-usage.sh |  159 ++++++++++++++++++++++++++----------------
 1 files changed, 98 insertions(+), 61 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 7ae6d25..c2b7112 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -17,62 +17,70 @@ aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 "$dev1"
 vgcreate $vg $(cat DEVICES)
 
-# "lvcreate rejects repeated invocation (run 2 times) (bz178216)" 
-lvcreate -n $lv -l 4 $vg 
+invalid lvcreate --type free -l1 -n $lv1 $vg 2>err
+grep "Invalid argument for --type" err
+invalid lvcreate --type $RANDOM -l1 -n $lv1 $vg
+invalid lvcreate --type unknown -l1 -n $lv1 $vg
+
+lvcreate --type linear -aey -l1 -n $lv1 $vg
+lvcreate --type snapshot -l1 -n $lv2 $vg/$lv1
+
+# Reject repeated invocation (run 2 times) (bz178216)
+lvcreate -n $lv -l 4 $vg
 not lvcreate -n $lv -l 4 $vg
 lvremove -ff $vg/$lv
-# try to remove it again - should fail (but not segfault)
+# Try to remove it again - should fail (but not segfault)
 not lvremove -ff $vg/$lv
 
-# "lvcreate rejects a negative stripe_size"
-not lvcreate -L 64m -n $lv -i2 --stripesize -4 $vg 2>err;
-grep "Negative stripesize is invalid" err
+# Reject a negative stripe_size
+invalid lvcreate -L 64m -n $lv -i2 --stripesize -4 $vg 2>err;
+grep "may not be negative" err
 
-# 'lvcreate rejects a too-large stripesize'
-not lvcreate -L 64m -n $lv -i2 --stripesize 4294967291 $vg 2>err
+# Reject a too-large stripesize
+invalid lvcreate -L 64m -n $lv -i2 --stripesize 4294967291 $vg 2>err
 grep "Stripe size cannot be larger than" err
 
-# 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
+# w/single stripe succeeds with diagnostics to stdout
 lvcreate -L 64m -n $lv -i1 --stripesize 4 $vg 2> err | tee out
 grep "Ignoring stripesize argument with single stripe" out
-lvdisplay $vg 
+lvdisplay $vg
 lvremove -ff $vg
 
-# 'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout'
+# w/default (64KB) stripe size succeeds with diagnostics to stdout
 lvcreate -L 64m -n $lv -i2 $vg > out
 grep "Using default stripesize" out
-lvdisplay $vg 
+lvdisplay $vg
 check lv_field $vg/$lv stripesize "64.00k"
 lvremove -ff $vg
 
-# 'lvcreate rejects an invalid number of stripes' 
-not lvcreate -L 64m -n $lv -i129 $vg 2>err
+# Reject an invalid number of stripes
+invalid lvcreate -L 64m -n $lv -i129 $vg 2>err
 grep "Number of stripes (129) must be between 1 and 128" err
 
-# The case on lvdisplay output is to verify that the LV was not created.
-# 'lvcreate rejects an invalid stripe size'
-not lvcreate -L 64m -n $lv -i2 --stripesize 3 $vg 2>err
+# Reject an invalid stripe size
+invalid lvcreate -L 64m -n $lv -i2 --stripesize 3 $vg 2>err
 grep "Invalid stripe size" err
+# Verify that the LV was not created via lvdisplay empty output
 test -z "$(lvdisplay $vg)"
 
 # Setting max_lv works. (bz490298)
-lvremove -ff $vg
+check vg_field $vg max_lv "0"
 vgchange -l 3 $vg
+check vg_field $vg max_lv "3"
 lvcreate -aey -l1 -n $lv1 $vg
 lvcreate -l1 -s -n $lv2 $vg/$lv1
 lvcreate -l1 -n $lv3 $vg
-not lvcreate -l1 -n $lv4 $vg
-
+fail lvcreate -l1 -n $lv4 $vg
 lvremove -ff $vg/$lv3
-# check snapshot of inactive origin
+
+# Check snapshot of inactive origin
 lvchange -an $vg/$lv1
 lvcreate -l1 -s -n $lv3 $vg/$lv1
-not lvcreate -l1 -n $lv4 $vg
-not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
+fail lvcreate -l1 -n $lv4 $vg
+fail lvcreate -l1 --type mirror -m1 -n $lv4 $vg
 
 lvremove -ff $vg/$lv3
 lvcreate -aey -l1 --type mirror -m1 -n $lv3 $vg
-vgs -o +max_lv $vg
 not lvcreate -l1 -n $lv4 $vg
 not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
 
@@ -80,17 +88,17 @@ lvconvert -m0 $vg/$lv3
 lvconvert -m2 --type mirror -i 1 $vg/$lv3
 lvconvert -m1 $vg/$lv3
 
-not vgchange -l 2
+fail vgchange -l 2
+check vg_field $vg max_lv "3"
 vgchange -l 4
-vgs $vg
+check vg_field $vg max_lv "4"
 
 lvremove -ff $vg
 vgchange -l 0 $vg
+check vg_field $vg max_lv "0"
 
-# lvcreate rejects invalid chunksize, accepts between 4K and 512K
-# validate origin_size
-vgremove -ff $vg
-vgcreate $vg $(cat DEVICES)
+# Rejects invalid chunksize, accepts between 4K and 512K
+# and validate origin_size
 lvcreate -aey -L 32m -n $lv1 $vg
 not lvcreate -L 8m -n $lv2 -s --chunksize 3k $vg/$lv1
 not lvcreate -L 8m -n $lv2 -s --chunksize 1024k $vg/$lv1
@@ -100,25 +108,29 @@ check lv_field $vg/$lv2 origin_size "32.00m"
 lvcreate -L 8m -n $lv3 -s --chunksize 512k $vg/$lv1
 check lv_field $vg/$lv3 chunk_size "512.00k"
 check lv_field $vg/$lv3 origin_size "32.00m"
-lvremove -ff $vg
-vgchange -l 0 $vg
+lvremove -f $vg
 
-# regionsize must be
+# Mirror regionsize must be
 # - nonzero (bz186013)
 # - a power of 2 and a multiple of page size
 # - <= size of LV
-not lvcreate -L 32m -n $lv -R0 $vg 2>err
-grep "Non-zero region size must be supplied." err
-not lvcreate -L 32m -n $lv -R 11k $vg
-not lvcreate -L 32m -n $lv -R 1k $vg
+invalid lvcreate -m 1 -L 32m -n $lv -R 0 $vg 2>err
+grep "may not be zero" err
+invalid lvcreate -m 1 -L 32m -n $lv -R 11k $vg
+invalid lvcreate -m 1 -L 32m -n $lv -R 1k $vg
 lvcreate -aey -L 32m -n $lv --regionsize 128m  --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "32.00m"
-lvremove -ff $vg
+lvremove -f $vg
 lvcreate -aey -L 32m -n $lv --regionsize 4m --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "4.00m"
+
+# -m0 is creating non-mirrored segment and give info about redundant option
+lvcreate -m 0 -l1 -n $lv1 $vg |& tee err
+grep "Redundant" err
+check lv_field $vg/$lv1 segtype "linear"
 lvremove -ff $vg
 
-# snapshot with virtual origin works
+# Snapshot with virtual origin works
 lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvrename $vg/$lv1 $vg/$lv2
 lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
@@ -127,30 +139,50 @@ lvremove -ff $vg/$lv1
 lvremove -ff $vg
 
 # readahead default (auto), none, #, auto
-lvcreate -L 32m -n $lv $vg
-check lv_field $vg/$lv lv_read_ahead "auto"
-lvremove -ff $vg
-lvcreate -L 32m -n $lv --readahead none $vg
-check lv_field $vg/$lv lv_read_ahead "0"
-check lv_field $vg/$lv lv_kernel_read_ahead "0"
-lvremove -ff $vg
-lvcreate -L 32m -n $lv --readahead 8k $vg
-check lv_field $vg/$lv lv_read_ahead "8.00k"
-check lv_field $vg/$lv lv_kernel_read_ahead "8.00k"
-lvremove -ff $vg
-lvcreate -L 32m -n $lv --readahead auto $vg
-check lv_field $vg/$lv lv_read_ahead "auto"
-check lv_field $vg/$lv lv_kernel_read_ahead "128.00k"
-lvremove -ff $vg
-lvcreate -L 32m -n $lv -i2 --stripesize 16k --readahead auto $vg
-check lv_field $vg/$lv lv_read_ahead "auto"
-check lv_field $vg/$lv lv_kernel_read_ahead "128.00k"
-lvremove -ff $vg
-lvcreate -L 32m -n $lv -i2 --stripesize 128k --readahead auto $vg
-check lv_field $vg/$lv lv_read_ahead "auto"
-check lv_field $vg/$lv lv_kernel_read_ahead "512.00k"
+lvcreate -L 8 -n $lv1 $vg
+check lv_field $vg/$lv1 lv_read_ahead "auto"
+lvcreate -L 8 -n $lv2 --readahead none $vg
+check lv_field $vg/$lv2 lv_read_ahead "0"
+check lv_field $vg/$lv2 lv_kernel_read_ahead "0"
+lvcreate -L 8 -n $lv3 --readahead 8k $vg
+check lv_field $vg/$lv3 lv_read_ahead "8.00k"
+check lv_field $vg/$lv3 lv_kernel_read_ahead "8.00k"
+lvcreate -L 8 -n $lv4 --readahead auto $vg
+check lv_field $vg/$lv4 lv_read_ahead "auto"
+check lv_field $vg/$lv4 lv_kernel_read_ahead "128.00k"
+lvcreate -L 8 -n $lv5 -i2 --stripesize 16k --readahead auto $vg
+check lv_field $vg/$lv5 lv_read_ahead "auto"
+check lv_field $vg/$lv5 lv_kernel_read_ahead "128.00k"
+lvcreate -L 8 -n $lv6 -i2 --stripesize 128k --readahead auto $vg
+check lv_field $vg/$lv6 lv_read_ahead "auto"
+check lv_field $vg/$lv6 lv_kernel_read_ahead "512.00k"
 lvremove -ff $vg
 
+#
+# Validate --major --minor,  we need to know VG, thus failing
+#
+fail lvcreate -My --major 234 -l1 $vg
+# cannot specify --major or --minor with -Mn
+fail lvcreate -Mn --major 234 -l1 $vg
+fail lvcreate --persistent n --minor 234 -l1 $vg
+# out-of-range minor value
+fail lvcreate --minor 9999999 -l1 $vg
+if kernel_at_least 2 4 0; then
+# On >2.4 we ignore --major
+lvcreate --major 234 -l1 $vg |& tee err;
+grep "Ignoring" err
+# Try some bigger possibly unused minor
+if test ! -d /sys/block/dm-2345; then
+	lvcreate --minor 2345 -l1 -n $lv1 $vg
+	check lv_field $vg/$lv1 lv_kernel_minor "2345"
+fi
+if test ! -d /sys/block/dm-23456; then
+	lvcreate -My --minor 23456 -j 122 -l1 -n $lv2 $vg
+	check lv_field $vg/$lv2 lv_kernel_minor "23456"
+fi
+fi # 2.4
+lvremove -f $vg
+
 # prohibited names
 for i in pvmove snapshot ; do
 	invalid lvcreate -l1 -n ${i}1 $vg
@@ -158,3 +190,8 @@ done
 for i in _cdata _cmeta _mimage _mlog _pmspare _tdata _tmeta _vorigin ; do
 	invalid lvcreate -l1 -n s_${i}_1 $vg
 done
+
+# Check invalid error for pool-only options
+invalid lvcreate --poolmetadataspare y -l1 $vg
+invalid lvcreate --poolmetadatasize 10 -l1 $vg
+invalid lvcreate --discards passdown -l1 $vg


