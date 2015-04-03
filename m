From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 12:55:23 +0000 (UTC)
Subject: master - tests: simplify check sysfs_queue
Message-ID: <20150403125523.BAD9260353@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=308f9bcc18d6c3b5f56b77dedacff4edafeb86fd
Commit:        308f9bcc18d6c3b5f56b77dedacff4edafeb86fd
Parent:        a701d337d4a8b2bbabc8e0930f79018b7f3d4305
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 10:27:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 10:27:00 2015 +0200

tests: simplify check sysfs_queue

Pass just device name and let figure out
sysfs path inside the function.
---
 test/lib/check.sh              |   12 +++++++-----
 test/shell/profiles-thin.sh    |    5 ++---
 test/shell/topology-support.sh |   15 ++++++---------
 3 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 12c5e23..219d43f 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -366,11 +366,13 @@ dev_md5sum() {
 }
 
 sysfs_queue() {
-	# Verify optimal_io_size
-	local P="/sys/block/$1/queue/$2"
-	test -f "$P" || return 0
-	test "$(< $P)" -eq "$3" || \
-		die "$P = $(< $P) differs from expected value $3!"
+	# read maj min and also convert hex to decimal
+	local maj=$(($(stat -L --printf=0x%t "$1")))
+	local min=$(($(stat -L --printf=0x%T "$1")))
+	local P="/sys/dev/block/$maj:$min/queue/$2"
+	local val=$(< "$P") || return 0 # no sysfs ?
+	test "$val" -eq "$3" || \
+		die "$1: $P = $val differs from expected value $3!"
 }
 
 #set -x
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index e8110d9..8800e7b 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -25,13 +25,12 @@ aux prepare_profiles "thin-performance"
 # Create scsi debug dev with sector size of 4096B and 1MiB optimal_io_size
 aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256 || skip
 EXPECT=1048576
-check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" optimal_io_size "$EXPECT"
+check sysfs_queue "$(< SCSI_DEBUG_DEV)" optimal_io_size "$EXPECT"
 aux prepare_pvs 1 $DEV_SIZE
 
 # Check we are not running on buggy kernel (broken lcm())
 # If so, turn chunk_size test into  'should'
-MINOR=$(stat -c %T "$dev1")
-check sysfs_queue "dm-$MINOR" optimal_io_size "$EXPECT" || SHOULD=should
+check sysfs_queue "$dev1" optimal_io_size "$EXPECT" || SHOULD=should
 
 vgcreate $vg "$dev1"
 
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 2e63da8..62f2b88 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -56,8 +56,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
-check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" logical_block_size $LOGICAL_BLOCK_SIZE
-
+check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 get_devs
 
@@ -73,7 +72,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
-check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate $vg "${DEVICES[@]}"
@@ -88,7 +87,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=4096
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE
-check sysfs_queue "$(basename $(< SCSI_DEBUG_DEV))" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate $vg "${DEVICES[@]}"
@@ -105,16 +104,14 @@ LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE opt_blks=1536
 
-TDEV="$(basename $(< SCSI_DEBUG_DEV))"
-check sysfs_queue "$TDEV" logical_block_size $LOGICAL_BLOCK_SIZE
-check sysfs_queue "$TDEV" optimal_io_size 786432
+check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs_queue "$(< SCSI_DEBUG_DEV)" optimal_io_size 786432
 
 aux prepare_pvs 1 $PER_DEV_SIZE
 
 # Kernel (3.19) could provide wrong results - in this case skip
 # test with incorrect result - lvm2 can't figure out good values.
-MINOR=$(stat -c %T "$dev1")
-check sysfs_queue "dm-$MINOR" optimal_io_size 786432 || SHOULD=should
+check sysfs_queue "$dev1" optimal_io_size 786432 || SHOULD=should
 $SHOULD check pv_field "${DEVICES[@]}" pe_start 768.00k
 
 aux cleanup_scsi_debug_dev


