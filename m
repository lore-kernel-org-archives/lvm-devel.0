From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 31 May 2017 08:02:01 -0400
Subject: master - tests: skip reshaping raid10
Message-ID: <201705311202.v4VC211W028705@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=091c55a13fbd385f5ea230bcc9bc2b2f0e29af9f
Commit:        091c55a13fbd385f5ea230bcc9bc2b2f0e29af9f
Parent:        3719f4bc5441cb5f29ad4beb91ccaa6b234ea8e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 31 12:59:53 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 31 12:59:53 2017 +0200

tests: skip reshaping raid10

Needs newer target  >= 1.10.1 for reshaping of raid10 LVs.
---
 test/shell/lvconvert-raid-regionsize.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 762dada..d2c8a54 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -64,7 +64,7 @@ _test_regionsizes raid1
 # Clean up
 lvremove --yes $vg
 
-if aux have_raid 1 10 0; then
+if aux have_raid 1 10 1; then
 # Create 5-way raid6
 lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid6"
@@ -83,6 +83,7 @@ else
   echo "Skipping RAID6 tests"
 fi
 
+if aux have_raid 1 10 1; then
 # Create 6-way raid01
 lvcreate --yes -aey --type raid10 -i 3 -m 1 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid10"
@@ -94,5 +95,8 @@ aux wait_for_sync $vg $lv1
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 _test_regionsizes raid10
+else
+  echo "Skipping RAID10 tests"
+fi
 
 vgremove -ff $vg


