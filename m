From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:53 +0000 (UTC)
Subject: master - test: Fix 100%FREE RAID tests since test device sizes changed slightly.
Message-ID: <20150205134253.F1A9C601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad0267b2ad70258fe79c90ed7cdd31fa19c8bec1
Commit:        ad0267b2ad70258fe79c90ed7cdd31fa19c8bec1
Parent:        c82c69bb5618721ac82286623f9deb019e216ca5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 14 11:46:13 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

test: Fix 100%FREE RAID tests since test device sizes changed slightly.

---
 test/shell/lvcreate-raid.sh   |   52 ++++++++++++++++++++--------------------
 test/shell/lvcreate-raid10.sh |    8 +++---
 2 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 6bbc3fe..956ebb5 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -76,31 +76,31 @@ done
 
 # Create RAID using 100%FREE
 ############################
-# 6 PVs with 18.5m in each PV.
+# 6 PVs with 19m in each PV.
 # 1 metadata LV = 1 extent   = .5m
-# 1 image = 36+37+37 extents = 55.00m = lv_size
+# 1 image = 37+38+38 extents = 56.50m = lv_size
 lvcreate --type raid1 -m 1 -l 100%FREE -an -Zn -n raid1 $vg
-check lv_field $vg/raid1 size "55.00m"
+check lv_field $vg/raid1 size "56.50m"
 lvremove -ff $vg
 
 # 1 metadata LV = 1 extent
-# 1 image = 36 extents
-# 5 images = 180 extents = 90.00m = lv_size
+# 1 image = 37 extents
+# 5 images = 190 extents = 95.00m = lv_size
 lvcreate --type raid5 -i 5 -l 100%FREE -an -Zn -n raid5 $vg
-should check lv_field $vg/raid5 size "90.00m"
+should check lv_field $vg/raid5 size "95.00m"
 #FIXME: Currently allocates incorrectly at 87.50m
 lvremove -ff $vg
 
-# 1 image = 36+37 extents
-# 2 images = 146 extents = 73.00m = lv_size
+# 1 image = 37+38 extents
+# 2 images = 150 extents = 75.00m = lv_size
 lvcreate --type raid5 -i 2 -l 100%FREE -an -Zn -n raid5 $vg
-check lv_field $vg/raid5 size "73.00m"
+check lv_field $vg/raid5 size "75.00m"
 lvremove -ff $vg
 
-# 1 image = 36 extents
-# 4 images = 144 extents = 72.00m = lv_size
+# 1 image = 37 extents
+# 4 images = 148 extents = 74.00m = lv_size
 lvcreate --type raid6 -i 4 -l 100%FREE -an -Zn -n raid6 $vg
-should check lv_field $vg/raid6 size "72.00m"
+should check lv_field $vg/raid6 size "74.00m"
 #FIXME: Currnently allocates incorrectly at 70.00m
 lvremove -ff $vg
 
@@ -111,9 +111,9 @@ EAT_SIZE=$(get lv_field $vg/eat_space size)
 
 # Using 100% free should take the rest of dev1 and equal from dev2
 # 1 meta takes 1 extent
-# 1 image = 18 extents = 9.00m = lv_size
+# 1 image = 19 extents = 9.50m = lv_size
 lvcreate --type raid1 -m 1 -l 100%FREE -an -Zn -n raid1 $vg "$dev1" "$dev2"
-check lv_field $vg/raid1 size "9.00m"
+check lv_field $vg/raid1 size "9.50m"
 # Ensure image size is the same as the RAID1 size
 check lv_field $vg/raid1 size $(get lv_field $vg/raid1_rimage_0 size -a)
 # Amount remaining in dev2 should equal the amount taken by 'lv' in dev1
@@ -122,10 +122,10 @@ lvremove -ff $vg/raid1
 
 # Using 100% free should take the rest of dev1 and equal amount from the rest
 # 1 meta takes 1 extent
-# 1 image = 18 extents = 9.00m
-# 5 images = 90 extents = 45.00m = lv_size
+# 1 image = 19 extents = 9.50m
+# 5 images = 95 extents = 47.50m = lv_size
 lvcreate --type raid5 -i 5 -l 100%FREE -an -Zn -n raid5 $vg
-check lv_field $vg/raid5 size "45.00m"
+check lv_field $vg/raid5 size "47.50m"
 # Amount remaining in dev6 should equal the amount taken by 'lv' in dev1
 check pv_field "$dev6" pv_free "$EAT_SIZE"
 lvremove -ff $vg/raid5
@@ -133,26 +133,26 @@ lvremove -ff $vg/raid5
 # Using 100% free should take the rest of dev1, an equal amount
 # from 2 more devs, and all extents from 3 additional devs
 # 1 meta takes 1 extent
-# 1 image = 18+37 extents
-# 2 images = 110 extents = 55.00m = lv_size
+# 1 image = 19+39 extents
+# 2 images = 114 extents = 57.00m = lv_size
 lvcreate --type raid5 -i 2 -l 100%FREE -an -Zn -n raid5 $vg
-check lv_field $vg/raid5 size "55.00m"
+check lv_field $vg/raid5 size "57.00m"
 lvremove -ff $vg/raid5
 
 # Let's do some stripe tests too
 # Using 100% free should take the rest of dev1 and an equal amount from rest
-# 1 image = 19 extents
-# 6 images = 114 extents = 57.00m = lv_size
+# 1 image = 20 extents
+# 6 images = 120 extents = 60.00m = lv_size
 lvcreate -i 6 -l 100%FREE -an -Zn -n stripe $vg
-check lv_field $vg/stripe size "57.00m"
+check lv_field $vg/stripe size "60.00m"
 lvremove -ff $vg/stripe
 
 # Using 100% free should take the rest of dev1, an equal amount from
 #  one more dev, and all of the remaining 4
-# 1 image = 19+37+37 extents
-# 2 images = 186 extents = 93.00m = lv_size
+# 1 image = 20+38+38 extents
+# 2 images = 192 extents = 96.00m = lv_size
 lvcreate -i 2 -l 100%FREE -an -Zn -n stripe $vg
-check lv_field $vg/stripe size "93.00m"
+check lv_field $vg/stripe size "96.00m"
 
 lvremove -ff $vg
 # end of use of '$vg/eat_space'
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index e334bd1..5f22a2d 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -50,11 +50,11 @@ aux wait_for_sync $vg $lv2
 lvremove -ff $vg
 
 # Test 100%FREE option
-# 37 extents / device
-# 1 image = 36 extents (1 for meta)
-# 3 images = 108 extents = 54.00m
+# 38 extents / device
+# 1 image = 37 extents (1 for meta)
+# 3 images = 111 extents = 55.50m
 lvcreate --type raid10 -i 3 -l 100%FREE -an -Zn -n raid10 $vg
-check lv_field $vg/raid10 size "54.00m"
+check lv_field $vg/raid10 size "55.50m"
 lvremove -ff $vg
 
 # Create RAID (implicit stripe count based on PV count)


