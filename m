From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:35 -0400
Subject: master - tests: fix caller of mirror_images_on
Message-ID: <201707101228.v6ACSZ0A022093@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e2fd6f6abcb97fe9f8ec2b5843469e2b497df25
Commit:        4e2fd6f6abcb97fe9f8ec2b5843469e2b497df25
Parent:        bc10d0373ad7c2e9997896c72e0740bd71bc8e46
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 21:18:56 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: fix caller of mirror_images_on

Missed vg name.
---
 test/shell/lvconvert-mirror.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index d9dfdfb..449f605 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -95,7 +95,7 @@ lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should"
 
 aux wait_for_sync $vg $lv1
 lvconvert -m-1 $vg/$lv1 "$dev1"
-check mirror_images_on $lv1 "$dev2" "$dev4"
+check mirror_images_on $vg $lv1 "$dev2" "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev2"
 check linear $vg $lv1
 check lv_on $vg $lv1 "$dev4"
@@ -253,7 +253,7 @@ lvremove -ff $vg
 
 # lvconvert from linear (on multiple PVs) to mirror
 lvcreate -aey -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
-lvconvert --type mirror -vvvv -m1 $vg/$lv1
+lvconvert --type mirror -m1 $vg/$lv1
 
 should check mirror $vg $lv1
 check mirror_legs $vg $lv1 2


