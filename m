From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:37 +0000 (UTC)
Subject: master - tests: fix calcucaltion
Message-ID: <20150518105237.C2EBA6020B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0cb9df3cec424c7c4e7ea5b198f419f3ef8a8c5d
Commit:        0cb9df3cec424c7c4e7ea5b198f419f3ef8a8c5d
Parent:        caaca15854440c1781ecde06f3f8e3ecc6c728ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 10:16:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:45:43 2015 +0200

tests: fix calcucaltion

Code works properly.
---
 test/shell/lvcreate-raid.sh |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 2ddc7e3..f5e25c6 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -86,11 +86,11 @@ check lv_field $vg/raid1 size "56.50m"
 lvremove -ff $vg
 
 # 1 metadata LV = 1 extent
-# 1 image = 37 extents
-# 5 images = 190 extents = 95.00m = lv_size
+# 1 image = 37 extents   = 18.5m
+# 5 images = 185 extents = 92.5m = lv_size
+lvs -a  $vg
 lvcreate --type raid5 -i 5 -l 100%FREE -an -Zn -n raid5 $vg
-should check lv_field $vg/raid5 size "95.00m"
-#FIXME: Currently allocates incorrectly at 87.50m
+check lv_field $vg/raid5 size "92.50m"
 lvremove -ff $vg
 
 # 1 image = 37+38 extents
@@ -102,8 +102,7 @@ lvremove -ff $vg
 # 1 image = 37 extents
 # 4 images = 148 extents = 74.00m = lv_size
 lvcreate --type raid6 -i 4 -l 100%FREE -an -Zn -n raid6 $vg
-should check lv_field $vg/raid6 size "74.00m"
-#FIXME: Currnently allocates incorrectly at 70.00m
+check lv_field $vg/raid6 size "74.00m"
 lvremove -ff $vg
 
 ###


