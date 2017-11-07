From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 18:03:48 -0500
Subject: master - tests: allow to proceed futher with test
Message-ID: <201711072303.vA7N3m79030282@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b78add3df5bcb40708c71c153ae2e6a8e2c109f2
Commit:        b78add3df5bcb40708c71c153ae2e6a8e2c109f2
Parent:        d6473b20183b873d9ea3480e2f34428539ee1fd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 8 00:00:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 8 00:02:54 2017 +0100

tests: allow to proceed futher with test

So raid doesn't want to create raid arrays with bigger regionsize ATM,
so just use smaller regionsize.
---
 test/shell/pvmove-raid-segtypes.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 28e3e56..667c7d9 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -35,7 +35,7 @@ do
 
 # Testing pvmove of RAID1 LV
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --regionsize 16K -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1


