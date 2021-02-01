From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:44 +0000 (GMT)
Subject: main - tests: update thin and cache checked messages
Message-ID: <20210201114744.3F04E3836C71@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19ddad12cae6b8c6a8011876302dd968ae3ddbeb
Commit:        19ddad12cae6b8c6a8011876302dd968ae3ddbeb
Parent:        b17b556e26e83bd9dadf711c5fba1d0d8939499f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 30 13:13:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

tests: update thin and cache checked messages

Slightly changed messages for allocation of pool metadata.
---
 test/shell/lvconvert-thin.sh    |  2 +-
 test/shell/lvcreate-cache.sh    | 12 +++++-------
 test/shell/lvcreate-thin-big.sh | 10 +++++-----
 3 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 131965508..ee8569164 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -128,7 +128,7 @@ lvcreate -L1T -n $lv1 $vg
 lvcreate -L32G -n $lv2 $vg
 # Warning about bigger then needed
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 2>&1 | tee err
-grep "WARNING: Maximum" err
+grep -i "maximum" err
 lvremove -f $vg
 
 
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 2c46e21c1..4d9d75eb9 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -27,7 +27,6 @@ aux prepare_vg 5 80000
 
 aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
 
-
 #######################
 # Cache_Pool creation #
 #######################
@@ -173,17 +172,16 @@ dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 
 lvremove -f $vg
 
-
 # Check minimum cache pool metadata size
-lvcreate -l 1 --type cache-pool --poolmetadatasize 1 $vg 2>out
-grep "WARNING: Minimum" out
+lvcreate -l 1 --type cache-pool --poolmetadatasize 1 $vg 2>&1 | tee out
+grep -i "minimal" out
+
 
 # FIXME: This test is failing in allocator with smaller VG sizes
-lvcreate -l 1 --type cache-pool --poolmetadatasize 17G $vg 2>out
-grep "WARNING: Maximum" out
+lvcreate -l 1 --type cache-pool --poolmetadatasize 17G $vg 2>&1 | tee out
+grep -i "maximum" out
 
 lvremove -f $vg
-
 ########################################
 # Cache conversion and r/w permissions #
 ########################################
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 0b622b7a9..254903548 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -31,14 +31,14 @@ vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # Size 0 is not valid
 invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
-lvcreate -Zn -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>out
-grep "WARNING: Minimum" out
+lvcreate -Zn -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>&1 >out
+grep -i "minimal" out
 # FIXME: metadata allocation fails, if PV doesn't have at least 16GB
 # i.e. pool metadata device cannot be multisegment
-lvcreate -Zn -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
-grep "WARNING: Maximum" out
+lvcreate -Zn -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>&1 >out
+grep "maximum" out
 check lv_field $vg/pool1_tmeta size "2.00m"
-check lv_field $vg/pool2_tmeta size "15.81g"
+check lv_field $vg/pool2_tmeta size "<15.88g"
 
 # Check we do report correct percent values.
 lvcreate --type zero -L3G $vg -n pool3


