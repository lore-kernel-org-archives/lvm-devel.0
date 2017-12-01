From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 12:57:43 -0500
Subject: master - test: add large tests skip option
Message-ID: <201712011757.vB1HvhC6029501@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=053314f2954dd94f707ef4a6ae9967ecd69fad6e
Commit:        053314f2954dd94f707ef4a6ae9967ecd69fad6e
Parent:        7aef59c6c332e5b9a983f5559acfa13834b2d064
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:50:55 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:50:55 2017 +0100

test: add large tests skip option

The lvm2 test suite aims at small test resource footprints
(few PVs, small PV sizes) to run on tmpfs backed loop device.

OTOH, lvconvert-reshape-raid.sh aims to test the maxima of
supported total stripes of 64.  This patch adds a prerequisite
conditional to skip tests using more than 14 stripes.

It requires the target version 1.13.1 to avoid deadlocks.
---
 test/shell/lvconvert-raid-reshape.sh |   60 ++++++++++++++++++++-------------
 1 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index b07e1ce..28bff0d 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -13,22 +13,25 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-. lib/inittest
+LVM_SKIP_LARGE_TESTS=0
 
-if [[ "$TESTDIR" == /dev/shm/* ]]; then
-	echo "Disabled. This tests is permanently causing /dev/shm exhaustion. RHBZ#1501145"
-	false
-fi
+. lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
+aux have_raid 1 13 1 || skip # needed to address RHBZ#1501145
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
 #aux have_multi_core || skip
 # dropping single-core limitation with  1.12 target
 
-aux prepare_pvs 65 32
+if [ $LVM_SKIP_LARGE_TESTS -eq 0 ]
+then
+	aux prepare_pvs 65 9
+else
+	aux prepare_pvs 20 9
+fi
+
 get_devs
 
 vgcreate -s 1M "$vg" "${DEVICES[@]}"
@@ -66,7 +69,7 @@ function _lvconvert
 	[ "${level:0:7}" = "striped" ] && wait_and_check=0
 	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
 
-	lvconvert -y --ty $req_level $R $vg/$lv || return $?
+	lvconvert -y --ty $req_level $R "$DM_DEV_DIR/$vg/$lv" || return $?
 
 	check lv_first_seg_field $vg/$lv segtype "$level"
 	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
@@ -97,7 +100,7 @@ function _reshape_layout
 
 	[[ "$opts" =~ "--stripes" ]] && ignore_a_chars=1
 
-	lvconvert -vvvv -y --ty $type $opts $vg/$lv
+	lvconvert -y --ty $type $opts "$DM_DEV_DIR/$vg/$lv"
 	check lv_first_seg_field $vg/$lv segtype "$type"
 	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
 	check lv_first_seg_field $vg/$lv stripes $stripes
@@ -114,6 +117,7 @@ function _reshape_layout
 #
 
 # Create 3-way striped raid5 (4 legs total)
+# _lvcreate raid5_ls 3 4 16M $vg $lv1
 _lvcreate raid5_ls 3 4 16M $vg $lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 aux wait_for_sync $vg $lv1
@@ -149,24 +153,32 @@ _reshape_layout raid5_ls 9 10 $vg $lv1 --stripes 9
 # Convert raid5_ls to 14 stripes
 _reshape_layout raid5_ls 14 15 $vg $lv1 --stripes 14
 
-# Convert raid5_ls to 63 stripes
-_reshape_layout raid5_ls 63 64 $vg $lv1 --stripes 63
-
-# Convert raid5_ls back to 27 stripes
-_reshape_layout raid5_ls 27 64 $vg $lv1 --stripes 27 --force
-_reshape_layout raid5_ls 27 28 $vg $lv1 --stripes 27
-
-# Convert raid5_ls back to 4 stripes checking
-# conversion to striped/raid* gets rejected
-# with existing LVs to be removed afer reshape
-_reshape_layout raid5_ls 4 28 $vg $lv1 --stripes 4 --force
+if [ $LVM_SKIP_LARGE_TESTS -eq 0 ]
+then
+	# Convert raid5_ls to 63 stripes
+	_reshape_layout raid5_ls 63 64 $vg $lv1 --stripes 63
+
+	# Convert raid5_ls back to 27 stripes
+	_reshape_layout raid5_ls 27 64 $vg $lv1 --stripes 27 --force
+	_reshape_layout raid5_ls 27 28 $vg $lv1 --stripes 27
+
+	# Convert raid5_ls back to 4 stripes checking
+	# conversion to striped/raid* gets rejected
+	# with existing LVs to be removed afer reshape
+	_reshape_layout raid5_ls 4 28 $vg $lv1 --stripes 4 --force
+else
+	# Convert raid5_ls back to 4 stripes checking
+	# conversion to striped/raid* gets rejected
+	# with existing LVs to be removed afer reshape
+	_reshape_layout raid5_ls 4 15 $vg $lv1 --stripes 4 --force
+fi
 
 # No we got the data reshaped and the freed SubLVs still present
 # -> check takeover request gets rejected
-not lvconvert --yes --type striped $vg/$lv1
-not lvconvert --yes --type raid0 $vg/$lv1
-not lvconvert --yes --type raid0_meta $vg/$lv1
-not lvconvert --yes --type raid6 $vg/$lv1
+not lvconvert --yes --type striped "$DM_DEV_DIR/$vg/$lv1"
+not lvconvert --yes --type raid0 "$DM_DEV_DIR/$vg/$lv1"
+not lvconvert --yes --type "$DM_DEV_DIR/raid0_meta $vg/$lv1"
+not lvconvert --yes --type "$DM_DEV_DIR/raid6 $vg/$lv1"
 # Remove the freed SubLVs
 _reshape_layout raid5_ls 4 5 $vg $lv1 --stripes 4
 


