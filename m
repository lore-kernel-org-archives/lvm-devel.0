From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:26 +0000 (UTC)
Subject: master - tests: use conv=fdatasync
Message-ID: <20150903213626.48B2060F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc261f17e96cb4012dd34329fd6ae9f766eb7c11
Commit:        dc261f17e96cb4012dd34329fd6ae9f766eb7c11
Parent:        ee8200f1c6d8613ae1f55b41d5eb758b547c6a4b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 23:04:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:37 2015 +0200

tests: use conv=fdatasync

Should be slightly better to flushed before dd exits
instead of using direct IO.
---
 test/shell/lvcreate-thin-external-size.sh  |    8 ++++----
 test/shell/snapshot-autoumount-dmeventd.sh |    2 +-
 test/shell/snapshot-maxsize.sh             |    2 +-
 test/shell/snapshot-reactivate.sh          |   10 +++++-----
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index d8e98f9..e2f49c4 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -42,7 +42,7 @@ d2="$DM_DEV_DIR/$vg/$lv2"
 lvcreate -l47 -n $lv1 $vg
 
 # Fill end with pattern
-dd if=64K of="$d1" bs=8192 seek=45 count=2
+dd if=64K of="$d1" bs=8192 seek=45 count=2 conv=fdatasync
 
 # Switch to read-only volume
 lvchange -an $vg/$lv1
@@ -58,7 +58,7 @@ cmp -n 16384 -l 64K 16K
 # Now extend and rewrite
 lvextend -l+2 $vg/$lv2
 
-dd if=64K of="$d2" bs=8192 seek=46 count=3 oflag=direct
+dd if=64K of="$d2" bs=8192 seek=46 count=3 conv=fdatasync
 dd if="$d2" of=24K bs=8192 skip=46 count=3 iflag=direct
 cmp -n 24576 -l 64K 24K
 
@@ -67,7 +67,7 @@ check lv_field $vg/$lv2 data_percent "66.67"
 
 lvreduce -f -l-24 $vg/$lv2
 
-dd if=64K of="$d2" bs=8192 seek=24 count=1 oflag=direct
+dd if=64K of="$d2" bs=8192 seek=24 count=1 conv=fdatasync
 dd if="$d2" of=8K bs=8192 skip=24 count=1 iflag=direct
 cmp -n 8192 -l 64K 8K
 
@@ -80,7 +80,7 @@ lvcreate -L256M -T $vg/pool -c 64M
 lvcreate -s $vg/$lv1 --name $lv2 --thinpool $vg/pool
 lvextend -l+2 $vg/$lv2
 
-dd if=64K of="$d2" bs=8192 seek=45 count=4 oflag=direct
+dd if=64K of="$d2" bs=8192 seek=45 count=4 conv=fdatasync
 dd if="$d2" of=32K bs=8192 skip=45 count=4 iflag=direct
 cmp -n 32768 -l 64K 32K
 
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index d369dac..9fc1c72 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -34,7 +34,7 @@ mkdir "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 
 cat /proc/mounts | grep "$mntdir"
-not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 oflag=direct
+not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 conv=fdatasync
 
 # Should be nearly instant check of dmeventd for invalid snapshot.
 # Wait here for umount and open_count drops to 0 as it may
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index e24f965..a96bd7f 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -24,7 +24,7 @@ lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
 lvcreate -L2 -s $vg/$lv1 -n $lv2
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 oflag=direct
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 conv=fdatasync
 
 # Snapshot must not be 'I'nvalid here
 check lv_attr_bit state $vg/$lv2 "a"
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index 978f7c0..9e9b4b7 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -30,24 +30,24 @@ which md5sum || skip
 aux prepare_vg
 
 # 8M file with some random data
-dd if=/dev/urandom of=data bs=1M count=1
-dd if=data of=data bs=1M count=7 seek=1
+dd if=/dev/urandom of=data bs=1M count=1 conv=fdatasync
+dd if=data of=data bs=1M count=7 seek=1 conv=fdatasync
 echo "$(md5sum data | cut -d' ' -f1)  $DM_DEV_DIR/$vg/s" >md5.${vg}-s
 
 lvcreate -aey -L 8M -n o $vg
-dd if=data of="$DM_DEV_DIR/$vg/o" bs=1M
+dd if=data of="$DM_DEV_DIR/$vg/o" bs=1M conv=fdatasync
 
 lvcreate -L 8M -s -n s $vg/o
 check_s_
 
-dd if=data of="$DM_DEV_DIR/$vg/o" bs=1234567 count=1 skip=1
+dd if=data of="$DM_DEV_DIR/$vg/o" bs=1234567 count=1 skip=1 conv=fdatasync
 check_s_
 lvchange -an $vg
 
 lvchange -ay $vg
 check_s_
 
-dd if=data of="$DM_DEV_DIR/$vg/o" bs=1234567 count=2 skip=1
+dd if=data of="$DM_DEV_DIR/$vg/o" bs=1234567 count=2 skip=1 conv=fdatasync
 check_s_
 
 lvchange -an $vg


