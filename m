From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:36 +0000 (UTC)
Subject: master - tests: drop pointeless test
Message-ID: <20130923101636.4506860FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=151f4ba64e5b7384ccb6ec7e603d05ba38dc561c
Commit:        151f4ba64e5b7384ccb6ec7e603d05ba38dc561c
Parent:        ec66ff818cd670228bd299fa51f8867fe7e50a3e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 19 14:03:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:14:21 2013 +0200

tests: drop pointeless test

Writing directly to thin-pool and reading it is not a good idea.
---
 test/shell/pvmove-thin-segtypes.sh |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index fe07288..fb29fe3 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -30,22 +30,6 @@ vgcreate -c n -s 128k $vg $(cat DEVICES)
 # 3) Move only the second LV by name
 
 
-# Testing pvmove of thin-pool LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -T $vg/$lv1 -l 4 "$dev1"
-check lv_tree_on $vg ${lv1}_foo "$dev1"
-check lv_tree_on $vg $lv1 "$dev1"
-aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
-check lv_tree_on $vg ${lv1}_foo "$dev5"
-check lv_tree_on $vg $lv1 "$dev5"
-check dev_md5sum $vg $lv1
-pvmove -n $lv1 "$dev5" "$dev4"
-check lv_tree_on $vg $lv1 "$dev4"
-check lv_tree_on $vg ${lv1}_foo "$dev5"
-check dev_md5sum $vg $lv1
-lvremove -ff $vg
-
 # Testing pvmove of thin LV
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"


