From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 17 May 2017 05:44:26 -0400
Subject: master - test: Fix condition
Message-ID: <201705170944.v4H9iQXo001751@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9291fb7bf5d5f6265f3fd2f5ec6eff6542d2afb9
Commit:        9291fb7bf5d5f6265f3fd2f5ec6eff6542d2afb9
Parent:        1fb13e8660340492e3d2f249caa78bacc5b8410a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed May 17 11:43:49 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed May 17 11:43:49 2017 +0200

test: Fix condition

---
 test/shell/lvconvert-raid-regionsize.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 2a9ef62..762dada 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -64,7 +64,7 @@ _test_regionsizes raid1
 # Clean up
 lvremove --yes $vg
 
-if aux have_raid 1 11 0; then
+if aux have_raid 1 10 0; then
 # Create 5-way raid6
 lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid6"


