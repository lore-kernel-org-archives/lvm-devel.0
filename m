From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:57 +0000 (UTC)
Subject: master - tests: raid syncaction test
Message-ID: <20141030230057.A99C560AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da61e6355e35ba7961b2073812c6a5639d9d541d
Commit:        da61e6355e35ba7961b2073812c6a5639d9d541d
Parent:        fe245d78ff603dd798b719854ee8d900f858779d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 25 16:03:44 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

tests: raid syncaction test

Add sync wait for syncaction of raid1 test.
--syncaction requires raid to be in sync first.
---
 test/shell/lvchange-syncaction-raid.sh |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 9a42894..7ef4e01 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -21,12 +21,15 @@ aux prepare_vg 3
 
 lvcreate -n $lv1 $vg -l1 --type raid1
 
+aux wait_for_sync $vg $lv1
+
 START=$(get pv_field "$dev2" pe_start --units 1k)
 METASIZE=$(get lv_field $vg/${lv1}_rmeta_1 size -a --units 1k)
 SEEK=$((${START%\.00k} + ${METASIZE%\.00k}))
 # Overwrite some portion of  _rimage_1
 dd if=/dev/urandom of="$dev2" bs=1K count=1 seek=$SEEK oflag=direct
 
+aux wait_for_sync $vg $lv1
 lvchange --syncaction check $vg/$lv1
 check lv_field $vg/$lv1 raid_mismatch_count "128"
 
@@ -34,7 +37,7 @@ check lv_field $vg/$lv1 raid_mismatch_count "128"
 lvchange -an $vg/$lv1
 
 # Slow down write by 100ms
-aux delay_dev "$dev2" 0 100
+aux delay_dev "$dev2" 0 50
 lvchange -ay $vg/$lv1
 # noone has it open and target is read & running
 dmsetup info -c | grep $vg
@@ -49,9 +52,12 @@ dmsetup info -c | grep $vg
 # For now it fails with:
 # device-mapper: message ioctl on  failed: Device or resource busy
 #
+# As solution for now - user needs to run --synaction on synchronous raid array
+#
+aux wait_for_sync $vg $lv1
 should lvchange --syncaction check $vg/$lv1
 
 aux enable_dev "$dev2"
-lvs -o+raid_mismatch_count -a $vg
+check lv_field $vg/$lv1 raid_mismatch_count "0"
 
 vgremove -ff $vg


