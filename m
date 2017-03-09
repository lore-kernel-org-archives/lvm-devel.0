From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 07:16:37 -0500
Subject: master - test: raid1 down convert to linear
Message-ID: <201703091216.v29CGbNj008680@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b0ae266c2d20a682329c37bb0e8cd28b76b9c95
Commit:        4b0ae266c2d20a682329c37bb0e8cd28b76b9c95
Parent:        413164765fc81b6b9e551114d92f382ad273429b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 13:16:08 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 13:16:08 2017 +0100

test: raid1 down convert to linear

Add/adjust more tests for commit 7fbe6ef16bfb.
---
 test/shell/lvchange-raid.sh             |    3 ++-
 test/shell/lvconvert-raid-allocation.sh |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index f81cc53..09ef3fa 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -126,7 +126,8 @@ run_writemostly_check() {
 	check lv_field $vg/$lv raid_write_behind "512"
 
 	# Converting to linear should clear flags and writebehind
-	lvconvert -m 0 $vg/$lv $d1
+	not lvconvert -m 0 $vg/$lv $d1
+	lvconvert -y -m 0 $vg/$lv $d1
 	lvconvert --type raid1 -m 1 $vg/$lv $d1
 	check lv_field $vg/$lv raid_write_behind ""
 	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index c5927a7..87e28fc 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -25,7 +25,8 @@ lvcreate -aey -l 4 -n $lv1 $vg "$dev1:0-1" "$dev2:0-1"
 not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev2"
 not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev3:0-2"
 lvconvert --type raid1 -m 1 $vg/$lv1 "$dev3"
-lvconvert -m 0 $vg/$lv1
+not lvconvert -m 0 $vg/$lv1
+lvconvert -y -m 0 $vg/$lv1
 # RAID conversions are not honoring allocation policy!
 # lvconvert --type raid1 -m 1 --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 lvremove -ff $vg
@@ -48,7 +49,8 @@ aux wait_for_sync $vg $lv1
 not lvconvert -m +1 $vg/$lv1 \
     "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
 lvconvert -m +1 $vg/$lv1 "$dev5"
-lvconvert -m 0 $vg/$lv1
+not lvconvert -m 0 $vg/$lv1
+lvconvert -y -m 0 $vg/$lv1
 # Should work due to '--alloc anywhere'
 # RAID conversion not honoring allocation policy!
 #lvconvert -m +1 --alloc anywhere $vg/$lv1 \


