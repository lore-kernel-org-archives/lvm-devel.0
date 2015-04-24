From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Apr 2015 22:42:25 +0000 (UTC)
Subject: master - tests: check sysfs more generically
Message-ID: <20150424224225.28F6460F5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a939857a63e7e119e6a4ce0f749cf981a196aabc
Commit:        a939857a63e7e119e6a4ce0f749cf981a196aabc
Parent:        d9176782feab130c3e94030f64bf67ca25f41e11
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 24 20:31:22 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 25 00:40:02 2015 +0200

tests: check sysfs more generically

Allow to access more files in device sysfs subtree.
---
 test/lib/check.sh              |    4 ++--
 test/shell/profiles-thin.sh    |    4 ++--
 test/shell/topology-support.sh |   12 ++++++------
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 219d43f..5244290 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -365,11 +365,11 @@ dev_md5sum() {
 		 die "LV $1/$2 has different MD5 check sum!")
 }
 
-sysfs_queue() {
+sysfs() {
 	# read maj min and also convert hex to decimal
 	local maj=$(($(stat -L --printf=0x%t "$1")))
 	local min=$(($(stat -L --printf=0x%T "$1")))
-	local P="/sys/dev/block/$maj:$min/queue/$2"
+	local P="/sys/dev/block/$maj:$min/$2"
 	local val=$(< "$P") || return 0 # no sysfs ?
 	test "$val" -eq "$3" || \
 		die "$1: $P = $val differs from expected value $3!"
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 8800e7b..d3e282a 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -25,12 +25,12 @@ aux prepare_profiles "thin-performance"
 # Create scsi debug dev with sector size of 4096B and 1MiB optimal_io_size
 aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256 || skip
 EXPECT=1048576
-check sysfs_queue "$(< SCSI_DEBUG_DEV)" optimal_io_size "$EXPECT"
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/optimal_io_size "$EXPECT"
 aux prepare_pvs 1 $DEV_SIZE
 
 # Check we are not running on buggy kernel (broken lcm())
 # If so, turn chunk_size test into  'should'
-check sysfs_queue "$dev1" optimal_io_size "$EXPECT" || SHOULD=should
+check sysfs "$dev1" queue/optimal_io_size "$EXPECT" || SHOULD=should
 
 vgcreate $vg "$dev1"
 
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 9bded0e..c186814 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -56,7 +56,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
-check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 get_devs
 
@@ -72,7 +72,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
-check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate $vg "${DEVICES[@]}"
@@ -87,7 +87,7 @@ aux cleanup_scsi_debug_dev
 LOGICAL_BLOCK_SIZE=4096
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE
-check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate $vg "${DEVICES[@]}"
@@ -107,14 +107,14 @@ LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE opt_blks=1536
 
-check sysfs_queue "$(< SCSI_DEBUG_DEV)" logical_block_size $LOGICAL_BLOCK_SIZE
-check sysfs_queue "$(< SCSI_DEBUG_DEV)" optimal_io_size 786432
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/optimal_io_size 786432
 
 aux prepare_pvs 1 $PER_DEV_SIZE
 
 # Kernel (3.19) could provide wrong results - in this case skip
 # test with incorrect result - lvm2 can't figure out good values.
-check sysfs_queue "$dev1" optimal_io_size 786432 || SHOULD=should
+check sysfs "$dev1" queue/optimal_io_size 786432 || SHOULD=should
 $SHOULD check pv_field "${DEVICES[@]}" pe_start 768.00k
 
 aux cleanup_scsi_debug_dev


