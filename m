From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Sep 2016 14:52:50 +0000 (UTC)
Subject: master - tests: use exclusive activation
Message-ID: <20160912145250.DDA3D60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44f1f45e16d4e6111e1dfd79a485697385e04160
Commit:        44f1f45e16d4e6111e1dfd79a485697385e04160
Parent:        a4363fbcb57af5399ea9d503dd4ae21477c24d59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 23:40:41 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 12 16:51:53 2016 +0200

tests: use exclusive activation

Slightly better for clvmd - thought test is still crashing
as table is broken.
---
 test/shell/lvconvert-raid-takeover.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index fd327ad..19a65d3 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -23,7 +23,7 @@ aux prepare_vg 9 288
 # aux delay_dev "$dev1" 0 1
 
 # Create 3-way mirror
-lvcreate --yes --type mirror -m 2 -L 64M -n $lv1 $vg
+lvcreate --yes -aey --type mirror -m 2 -L 64M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 3
 echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
@@ -79,7 +79,7 @@ aux wait_for_sync $vg $lv1
 lvremove --yes $vg/$lv1
 
 # Create 3-way raid0
-lvcreate -y --type raid0 -i 3 -L 256M -n $lv1 $vg
+lvcreate -y -aey --type raid0 -i 3 -L 64M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid0"
 check lv_field $vg/$lv1 stripes 3
 echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1


