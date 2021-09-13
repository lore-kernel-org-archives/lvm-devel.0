From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:08 +0000 (GMT)
Subject: main - tests: increase size of thin-pool for newer mkfs
Message-ID: <20210913103608.1C92E3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7af0a1b9d87827f0d15e6b062b753ee3043f75dc
Commit:        7af0a1b9d87827f0d15e6b062b753ee3043f75dc
Parent:        fc5f9924c74d9a2d930fe37480aeb70e9aa1c856
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 12 21:20:38 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

tests: increase size of thin-pool for newer mkfs

Looks like newer version of mkfs.ext4 consumes more 'real' disk space,
when formating virtual volumes - so double the size of thin-pool to
have enough backend chunks for provisioning.
---
 test/shell/pvmove-thin-segtypes.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 08685c886..f8c65f583 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -38,7 +38,7 @@ do
 
 # Testing pvmove of thin LV
 lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -aey -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"
+lvcreate -aey -T $vg/${lv1}_pool -l8 -V 8 -n $lv1 "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1"
 aux mkdev_md5sum $vg $lv1
@@ -54,7 +54,7 @@ lvremove -ff $vg
 
 # Testing pvmove of thin LV on RAID
 lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -aey --type raid1 -m 1 -l 4 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
+lvcreate -aey --type raid1 -m 1 -l 8 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
 lvcreate -aey --type raid1 -m 1 -L 2 -n ${lv1}_raid1_meta $vg "$dev1" "$dev2"
 lvconvert --yes --thinpool $vg/${lv1}_raid1_pool \
         --poolmetadata ${lv1}_raid1_meta


