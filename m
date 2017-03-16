From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Mar 2017 03:53:30 -0400
Subject: master - tests: better disk delay
Message-ID: <201703160753.v2G7rUGv009715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51b9de7249e912cdaa4508f5046d95d2c108b1c1
Commit:        51b9de7249e912cdaa4508f5046d95d2c108b1c1
Parent:        7fa08ae4e80e37e102d77f8fe02902a68bf52d9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 08:49:52 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 08:49:52 2017 +0100

tests: better disk delay

Delay only writable extents.
Skip zeroing for earlier lvcreate finish.
---
 test/shell/lvchange-raid1-writemostly.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index 611992a..a6d5b6e 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -21,7 +21,7 @@ aux prepare_vg 4
 
 for d in $dev1 $dev2 $dev3 $dev4
 do
-	aux delay_dev $d 1 1
+	aux delay_dev $d 0 20 $(get first_extent_sector "$d")
 done
 
 #
@@ -29,11 +29,12 @@ done
 #
 
 # Create 4-way raid1 LV
-lvcreate -aey --ty raid1 -m 3 -L 32M -n $lv1 $vg
+lvcreate -aey --ty raid1 -m 3 -Zn -L16M -n $lv1 $vg
 not lvchange -y --writemostly $dev1 $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
 check lv_attr_bit health $vg/${lv1}_rimage_0 "-"
+aux enable_dev $(< DEVICES)
 aux wait_for_sync $vg $lv1
 lvchange -y --writemostly $dev1 $vg/$lv1
 check lv_attr_bit health $vg/${lv1}_rimage_0 "w"


