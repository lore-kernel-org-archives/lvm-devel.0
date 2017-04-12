From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:39:14 -0400
Subject: master - tests: test for new supported commands
Message-ID: <201704121939.v3CJdEtt012316@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56704383bfded631ea16707e598e38df93dfaab5
Commit:        56704383bfded631ea16707e598e38df93dfaab5
Parent:        f8034e14e6c8012dbd51dc3c5e5fc1c0036e00a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 12 15:01:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:34:08 2017 +0200

tests: test for new supported commands

New tests for:

lvconvert --regionsize | --swapmetadata | --startpoll |
          --mergesnapshot | mergethin
---
 test/shell/lvconvert-cache.sh           |    4 ++++
 test/shell/lvconvert-mirror.sh          |   15 +++++++++++++++
 test/shell/lvconvert-raid-regionsize.sh |    5 ++++-
 test/shell/lvconvert-thin.sh            |    4 ++++
 test/shell/snapshot-merge.sh            |    3 +++
 test/shell/thin-merge.sh                |    7 +++++++
 6 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 6a8daa3..b1ac154 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -63,6 +63,10 @@ UUID=$(get lv_field $vg/$lv5 uuid)
 lvconvert --yes --cachepool $vg/$lv3 --poolmetadata $lv5
 check lv_field $vg/${lv3}_cmeta uuid "$UUID"
 
+# Check swap of cache pool metadata with --swapmetadata
+# (should swap back to lv5)
+lvconvert --yes --swapmetadata $vg/$lv3 --poolmetadata $lv5
+check lv_field $vg/$lv5 uuid "$UUID"
 
 #fail lvconvert --cachepool $vg/$lv1 --poolmetadata $vg/$lv2
 #lvconvert --yes --type cache-pool --poolmetadata $vg/$lv2 $vg/$lv1
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 7e8d663..86ae0e3 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -216,6 +216,21 @@ check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
+# Check the same with new --startpool lvconvert command option
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
+# FIXME: Extra wait here for mirror upconvert synchronization
+# otherwise we may fail her on parallel upconvert and downconvert
+# lvconvert-mirror-updown.sh tests this errornous case separately
+should lvconvert --startpoll $vg/$lv1
+lvconvert -m-1 $vg/$lv1 "$dev2"
+should lvconvert --startpoll $vg/$lv1
+
+check mirror $vg $lv1 "$dev3"
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+lvremove -ff $vg
+
 # ---------------------------------------------------------------------
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 7a6c7f0..9884c1b 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -28,8 +28,11 @@ function _test_regionsize
 	local lv=$5
 
 	lvconvert --type $type --yes -R $regionsize $vg/$lv
-	[ $? -ne 0 ] && return 1
 	check lv_field $vg/$lv regionsize "$regionsize_str"
+
+	not lvconvert --regionsize $regionsize $vg/$lv 2>err
+	grep "is already" err
+
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"
 }
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index c73c648..c08b95a 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -88,6 +88,10 @@ fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
 lvchange -an $vg
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
 check lv_field $vg/${lv1}_tmeta uuid "$UUID"
+
+# and swap again with new command --swapmetadata
+lvconvert --yes --swapmetadata $vg/$lv1 --poolmetadata $lv2
+check lv_field $vg/$lv2 uuid "$UUID"
 lvremove -f $vg
 
 
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index a301d22..bdbbdba 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -56,6 +56,9 @@ not lvconvert --merge
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
+setup_merge_ $vg $lv1
+lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
+lvremove -f $vg/$lv1
 
 # test that an actively merging snapshot may not be removed
 setup_merge_ $vg $lv1
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index f044f57..9955aab 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -109,5 +109,12 @@ check lv_not_exists $vg oldsnapof_${lv1}
 lvcreate -s -L10 -n oldsnapof_snap $vg/snap
 lvconvert --merge $vg/snap
 lvremove -f $vg/oldsnapof_snap
+check lv_field  $vg/$lv1 thin_id "3"
+
+# Check --mergethin
+lvcreate -s -n snap $vg/$lv1
+check lv_field  $vg/snap thin_id "4"
+lvconvert --mergethin $vg/snap
+check lv_field  $vg/$lv1 thin_id "4"
 
 vgremove -ff $vg


