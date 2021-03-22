From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:48 +0000 (GMT)
Subject: main - tests: skip only portion of test
Message-ID: <20210322215348.61D7C3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bee8027cfa296bd910c75d5000a60d7ef99ecd78
Commit:        bee8027cfa296bd910c75d5000a60d7ef99ecd78
Parent:        8d2ad4419a58536696474dbdfb241204d561dcf6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 21 23:25:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:36:37 2021 +0100

tests: skip only portion of test

Seems this kernel bug is taking more time to get it fixed,
so skipping only failing portion of test and ending with WARNING.
---
 .../lvconvert-raid-reshape-stripes-load-reload.sh     | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 3b6150909..1e2ad0fb4 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -21,15 +21,6 @@ which md5sum || skip
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
-case "$(uname -r)" in
-  5.[891]*) die "Cannot run this test on unfixed kernel." ;;
-  3.10.0-862*) skip "Cannot run this test on unfixed kernel." ;;
-  4.18.0-*.el8*)
-    REL="$(uname -r)"
-    REL="${REL#4.18.0-}"
-    [[ "${REL%%.*}" -lt 283 ]] || die "Cannot run this test on unfixed kernel." ;;
-esac
-
 mount_dir="mnt"
 
 cleanup_mounted_and_teardown()
@@ -57,8 +48,8 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
 check lv_first_seg_field $vg/$lv1 stripes 11
-wipefs -a /dev/$vg/$lv1
-mkfs -t ext4 /dev/$vg/$lv1
+wipefs -a "$DM_DEV_DIR/$vg/$lv1"
+mkfs -t ext4 "$DM_DEV_DIR/$vg/$lv1"
 
 mkdir -p "$mount_dir"
 mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
@@ -80,6 +71,10 @@ check lv_first_seg_field $vg/$lv1 data_stripes 15
 check lv_first_seg_field $vg/$lv1 stripes 16
 
 # Reload table during reshape to test for data corruption
+case "$(uname -r)" in
+  5.[891]*|3.10.0-862*|4.18.0-*.el8*)
+	should not echo "Skipping table reload test on on unfixed kernel!!!" ;;
+  *)
 for i in {0..5}
 do
 	dmsetup table $vg-$lv1|dmsetup load $vg-$lv1
@@ -88,6 +83,8 @@ do
 	sleep 0.3
 done
 
+esac
+
 aux delay_dev "$dev2" 0
 
 kill -9 %% || true


