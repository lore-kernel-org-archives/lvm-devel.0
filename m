From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 17 May 2017 05:38:15 -0400
Subject: master - test: Fix skipped cleanup
Message-ID: <201705170938.v4H9cFMq001124@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fb13e8660340492e3d2f249caa78bacc5b8410a
Commit:        1fb13e8660340492e3d2f249caa78bacc5b8410a
Parent:        48408ece6ddd730c394e3081f9a2d78d1771f129
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed May 17 11:37:29 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed May 17 11:37:29 2017 +0200

test: Fix skipped cleanup

---
 test/shell/lvconvert-raid-regionsize.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 2884037..2a9ef62 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -61,10 +61,10 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 _test_regionsizes raid1
 
-if aux have_raid 1 11 0; then
 # Clean up
 lvremove --yes $vg
 
+if aux have_raid 1 11 0; then
 # Create 5-way raid6
 lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid6"


