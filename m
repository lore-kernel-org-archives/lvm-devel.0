From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 14:16:07 +0000 (UTC)
Subject: master - tests: update test for resize
Message-ID: <20151029141607.3D54B6022D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28e54032c092ed4a5592575ac716fe698ce75d22
Commit:        28e54032c092ed4a5592575ac716fe698ce75d22
Parent:        bca55c9b205ff2b0613ad44d85c12c6d6ae9691b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 15:11:16 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 15:11:16 2015 +0100

tests: update test for resize

Drop already tested 'threshold & create' which is in
lvextend-thin-full.sh

Count with now match faster 'dmeventd' wakeup on watermark
as it's now nearly instant after crossing threshold value.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |   28 +++++-------------------
 1 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 030991f..a2d6a39 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -23,8 +23,8 @@ meta_percent_() {
 
 wait_for_change_() {
 	# dmeventd only checks every 10 seconds :(
-	for i in $(seq 1 15) ; do
-		test "$(meta_percent_)" != "$1" && return
+	for i in $(seq 1 12) ; do
+		test "$(meta_percent_)" -lt "$1" && return
 		sleep 1
 	done
 
@@ -101,43 +101,27 @@ lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
 
 vgchange -ay $vg
 
-# Check dmeventd resizes metadata
+# Check dmeventd resizes metadata via timeout (nothing is written to pool)
 pre=$(meta_percent_)
 wait_for_change_ $pre
 
 lvchange -an $vg
 
-lvs -a $vg
 #
 fake_metadata_ 350 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
-lvs -a $vg
-dmsetup table
 lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
 lvchange -ay $vg/pool  $vg/$lv1
 lvs -a $vg
 
 lvcreate -s -Ky -n $lv2 $vg/thin
-echo 2 >"$DM_DEV_DIR/mapper/$vg-$lv2"
-
-#lvchange -an $vg
-#lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
-#lvchange -ay $vg/$lv1
-#thin_dump "$DM_DEV_DIR/mapper/$vg-$lv1"
-#exit
+pre=$(meta_percent_)
 
-# no more space for new thin LV
-#
-# TODO:
-# though maybe 'lvcreate' itself should initiate  resize - if dmeventd is not 'fast' enough
-# deploying usage of threshold kernel module paramater would likely help as well
-# for now it stops here:
-not lvcreate -s -Ky -n $lv3 $vg/thin
-lvs -a $vg
+# go over thin metadata threshold
+echo 2 >"$DM_DEV_DIR/mapper/$vg-$lv2"
 
-pre=$(meta_percent_)
 wait_for_change_ $pre
 
 lvs -a $vg


