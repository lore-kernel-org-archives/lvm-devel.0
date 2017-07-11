From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:28 -0400
Subject: master - tests: double quote
Message-ID: <201707111522.v6BFMS3o015572@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ab2676bac452e9875a970d0ece53983a6c16643
Commit:        5ab2676bac452e9875a970d0ece53983a6c16643
Parent:        21e0e98665f0a51b928e621ea5a6794d36d16a47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 11:23:14 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:26:12 2017 +0200

tests: double quote

---
 test/shell/lvconvert-raid-regionsize.sh |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 4763bab..893c158 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -28,10 +28,10 @@ function _test_regionsize
 	local vg=$4
 	local lv=$5
 
-	lvconvert --type $type --yes -R $regionsize $vg/$lv
+	lvconvert --type "$type" --yes -R "$regionsize" "$vg/$lv"
 	check lv_field $vg/$lv regionsize "$regionsize_str"
 
-	not lvconvert --regionsize $regionsize $vg/$lv 2>err
+	not lvconvert --regionsize "$regionsize" "$vg/$lv" 2>err
 	grep "is already" err
 
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"
@@ -43,12 +43,12 @@ function _test_regionsizes
 	local type=$1
 
 	# Test RAID regionsize changes
-	_test_regionsize $type 128K "128.00k" $vg $lv1
-	_test_regionsize $type 256K "256.00k" $vg $lv1
-	not _test_regionsize $type 1K "1.00k" $vg $lv1
-	_test_regionsize $type 1m "1.00m" $vg $lv1
-	not _test_regionsize $type 1G "1.00g" $vg $lv1
-	not _test_regionsize $type 16K "16.00k" $vg $lv1
+	_test_regionsize "$type" 128K "128.00k" $vg $lv1
+	_test_regionsize "$type" 256K "256.00k" $vg $lv1
+	not _test_regionsize "$type" 1K "1.00k" $vg $lv1
+	_test_regionsize "$type" 1m "1.00m" $vg $lv1
+	not _test_regionsize "$type" 1G "1.00g" $vg $lv1
+	not _test_regionsize "$type" 16K "16.00k" $vg $lv1
 }
 
 # Create 3-way raid1


