From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 30 May 2014 22:29:25 +0000 (UTC)
Subject: master - test: use direct I/O when injecting bad data into RAID images
Message-ID: <20140530222925.4B51F60F81@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4454a580dfd966d0cd132a2fd7d0cbb0df7e46a6
Commit:        4454a580dfd966d0cd132a2fd7d0cbb0df7e46a6
Parent:        03621692774e33357acc11ad23d4c8d1faffe971
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri May 30 17:26:10 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri May 30 17:26:10 2014 -0500

test: use direct I/O when injecting bad data into RAID images

When directly corrupting RAID images for the purpose of testing,
we must use direct I/O (or a 'sync' after the 'dd') to ensure that
the writes are not caught in the buffer cache in a way that is not
reachable by the top-level RAID device.
---
 test/shell/lvchange-syncaction-raid.sh |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index a27b885..b5fdfb4 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -13,7 +13,10 @@
 
 . lib/test
 
-aux have_raid 1 5 0 || skip
+# Proper mismatch count 1.5.2+ upstream, 1.3.5 < x < 1.4.0 in RHEL6
+aux have_raid 1 3 5 &&
+  ! aux have_raid 1 4 0 ||
+  aux have_raid 1 5 2 || skip
 aux prepare_vg 3
 
 lvcreate -n $lv1 $vg -l1 --type raid1
@@ -22,16 +25,7 @@ START=$(get pv_field "$dev2" pe_start --units 1k)
 METASIZE=$(get lv_field $vg/${lv1}_rmeta_1 size -a --units 1k)
 SEEK=$((${START%\.00k} + ${METASIZE%\.00k}))
 # Overwrite some portion of  _rimage_1
-dd if=/dev/urandom of="$dev2" bs=1K count=1 seek=$SEEK
-
-lvchange --syncaction check $vg/$lv1
-
-# hmmm it's still in 'dd' buffer and not on real disk ??
-# anyway skip over with 'should'
-should check lv_field $vg/$lv1 raid_mismatch_count "128"
-
-# Ensure it's all on disk now
-sync
+dd if=/dev/urandom of="$dev2" bs=1K count=1 seek=$SEEK oflag=direct
 
 lvchange --syncaction check $vg/$lv1
 check lv_field $vg/$lv1 raid_mismatch_count "128"


