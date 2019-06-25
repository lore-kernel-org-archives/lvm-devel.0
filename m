From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:44:43 -0400
Subject: stable-2.02 - tests: for cluster always use exlusive mirrors
Message-ID: <201906251544.x5PFihpa012299@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49813abc003180a38f9cd1e6c75f68311d005a50
Commit:        49813abc003180a38f9cd1e6c75f68311d005a50
Parent:        788d89c4127f69c813813e6a192fe44d8c1abc7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 21 14:51:17 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 21 14:51:17 2019 +0200

tests: for cluster always use exlusive mirrors

So to check the reason of failure is not influenced by missing cmirrord.
---
 test/shell/lvcreate-usage.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index ca8694e..4669539 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -91,12 +91,12 @@ lvremove -ff $vg/$lv3
 lvchange -an $vg/$lv1
 lvcreate -l1 -s -n $lv3 $vg/$lv1
 fail lvcreate -l1 -n $lv4 $vg
-fail lvcreate -l1 --type mirror -m1 -n $lv4 $vg
+fail lvcreate -aey -l1 --type mirror -m1 -n $lv4 $vg
 
 lvremove -ff $vg/$lv3
 lvcreate -aey -l1 --type mirror -m1 -n $lv3 $vg
 not lvcreate -l1 -n $lv4 $vg
-not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
+not lvcreate -aey -l1 --type mirror -m1 -n $lv4 $vg
 
 lvconvert -m0 $vg/$lv3
 lvconvert -m2 --type mirror -i 1 $vg/$lv3
@@ -128,10 +128,10 @@ lvremove -f $vg
 # - nonzero (bz186013)
 # - a power of 2 and a multiple of page size
 # - <= size of LV
-invalid lvcreate --type mirror -m 1 -L 32m -n $lv -R 0 $vg 2>err
+invalid lvcreate -aey --type mirror -m 1 -L 32m -n $lv -R 0 $vg 2>err
 grep "may not be zero" err
-invalid lvcreate --type mirror -m 1 -L 32m -n $lv -R 11k $vg
-invalid lvcreate --type mirror -m 1 -L 32m -n $lv -R 1k $vg
+invalid lvcreate -aey --type mirror -m 1 -L 32m -n $lv -R 11k $vg
+invalid lvcreate -aey --type mirror -m 1 -L 32m -n $lv -R 1k $vg
 lvcreate -aey -L 32m -n $lv --regionsize 128m  --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "32.00m"
 lvremove -f $vg


