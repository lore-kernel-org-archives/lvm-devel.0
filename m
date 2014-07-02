From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:49:00 +0000 (UTC)
Subject: master - tests: avoid hiding results in local
Message-ID: <20140702084900.D0FE360BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b22ab4dab0dcf78d86ff64c3412cf175118d1785
Commit:        b22ab4dab0dcf78d86ff64c3412cf175118d1785
Parent:        d1dcbe085370ba194b6598bb9440550edb7f184f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 20:04:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:43 2014 +0200

tests: avoid hiding results in local

There is a difference between:

local a=$(shell)

and

local a
a=$(shell)

The first return exit code from shells' local command.
---
 test/shell/fsadm.sh                         |    3 +-
 test/shell/lvchange-raid.sh                 |   10 ++++++--
 test/shell/lvconvert-mirror-basic.sh        |    2 +-
 test/shell/lvcreate-signature-wiping.sh     |    3 +-
 test/shell/mirror-names.sh                  |    4 ++-
 test/shell/mirror-vgreduce-removemissing.sh |   11 ++++++---
 test/shell/snapshot-merge.sh                |    4 ++-
 test/shell/topology-support.sh              |   30 +++++++++++---------------
 8 files changed, 38 insertions(+), 29 deletions(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 612d2b7..368e747 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -75,7 +75,8 @@ fscheck_reiserfs()
 
 check_missing()
 {
-	eval local t=$\check_$1
+	local t
+	eval t=$\check_$1
 	test -z "$t" && return 0
 	test "$t" = skip && return 1
 	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing."
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index e35f4de..a0a0d2a 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -29,9 +29,13 @@ aux prepare_vg 6
 run_writemostly_check() {
 	local vg=$1
 	local lv=${2}${THIN_POSTFIX}
-	local segtype=$(get lv_field $vg/$lv segtype -a)
-	local d0=$(get lv_devices $vg/${lv}_rimage_0)
-	local d1=$(get lv_devices $vg/${lv}_rimage_1)
+	local segtype=
+	local d0
+	local d1
+
+	segtype=$(get lv_field $vg/$lv segtype -a)
+	d0=$(get lv_devices $vg/${lv}_rimage_0)
+	d1=$(get lv_devices $vg/${lv}_rimage_1)
 
 	printf "#\n#\n#\n# %s/%s (%s): run_writemostly_check\n#\n#\n#\n" \
 		$vg $lv $segtype
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 6fcff70..07bafb9 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -43,7 +43,7 @@ test_lvconvert() {
 	local finish_count=$3
 	local finish_count_p1=$(($finish_count + 1))
 	local finish_log_type=$4
-	local dev_array=("$dev1" "$dev2" "$dev3" "$dev4" "$dev5")
+	local dev_array=( "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" )
 	local start_log_count
 	local finish_log_count
 	local max_log_count
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 388c542..32ef363 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -18,7 +18,8 @@ init_lv_() {
 }
 
 test_blkid_() {
-	local type=$(blkid -s TYPE -o value -c /dev/null "$DM_DEV_DIR/$vg/$lv1")
+	local type
+	type=$(blkid -s TYPE -o value -c /dev/null "$DM_DEV_DIR/$vg/$lv1")
 	test "$type" = "swap"
 }
 
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 8094798..0e064ed 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -22,7 +22,9 @@ lv_devices_() {
 	local lv=$1
 	shift
 	local devices=$@
-	local devs=$(get lv_field $lv devices -a | sed 's/([0-9]*)//g; s/ //g; s/,/ /g')
+	local devs
+
+	devs=$(get lv_devices "$lv")
 
 	for d in $devs; do
 		(echo "$devices" | grep $d) || return 1
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 62847ae..fd71696 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -75,9 +75,10 @@ rest_pvs_()
 	local num=$2
 	local rem=
 	local n
+	local dev
 
 	for n in $(seq 1 $(($index - 1))) $(seq $(($index + 1)) $num); do
-		eval local dev=$\dev$n
+		eval dev=$\dev$n
 		rem="$rem $dev"
 	done
 
@@ -223,6 +224,7 @@ done
 test_3way_mirror_plus_1_fail_3_()
 {
 	local index=$1
+	local dev
 
 	lvcreate -an -Zn -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
 	lvconvert -m+1 $vg/$lv1 "$dev4"
@@ -232,9 +234,9 @@ test_3way_mirror_plus_1_fail_3_()
 	aux disable_dev $(rest_pvs_ $index 4)
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
-	eval local dev=\$dev$n
+	eval dev=\$dev$n
 	check linear $vg $lv1
-        check lv_on $vg $lv1 "$dev"
+	check lv_on $vg $lv1 "$dev"
 }
 
 for n in $(seq 1 4); do
@@ -278,6 +280,7 @@ done
 test_2way_mirror_plus_2_fail_3_()
 {
 	local index=$1
+	local dev
 
 	lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
@@ -286,7 +289,7 @@ test_2way_mirror_plus_2_fail_3_()
 	aux disable_dev $(rest_pvs_ $index 4)
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
-	eval local dev=\$dev$n
+	eval dev=\$dev$n
 	mimages_are_on_ $lv1 "$dev" || lv_is_on_ $lv1 "$dev"
 	not mirrorlog_is_on_ $lv1 "$dev5"
 }
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 0117cdc..44d6c24 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -25,7 +25,9 @@ setup_merge_() {
     local VG_NAME=$1
     local LV_NAME=$2
     local NUM_EXTRA_SNAPS=${3:-0}
-    local BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
+    local BASE_SNAP_LV_NAME
+
+    BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
 
     lvcreate -aey -n $LV_NAME -l 50%FREE $VG_NAME
     lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index a1af6d7..caebb3d 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -14,23 +14,17 @@
 which mkfs.ext3 || skip
 
 check_logical_block_size() {
-    local DEV_=$(cat SCSI_DEBUG_DEV)
     # Verify logical_block_size - requires Linux >= 2.6.31
-    SYSFS_LOGICAL_BLOCK_SIZE=$(echo /sys/block/$(basename $DEV_)/queue/logical_block_size)
-    if [ -f "$SYSFS_LOGICAL_BLOCK_SIZE" ] ; then
-	ACTUAL_LOGICAL_BLOCK_SIZE=$(cat $SYSFS_LOGICAL_BLOCK_SIZE)
-	test $ACTUAL_LOGICAL_BLOCK_SIZE = $1
-    fi
+    SYSFS_LOGICAL_BLOCK_SIZE="/sys/block/$(basename $(< SCSI_DEBUG_DEV))/queue/logical_block_size"
+    test -f "$SYSFS_LOGICAL_BLOCK_SIZE" || return 0
+    test "$(< $SYSFS_LOGICAL_BLOCK_SIZE)" -eq "$1" # ACTUAL_LOGICAL_BLOCK_SIZE
 }
 
 check_optimal_io_size() {
-    local DEV_=$(cat SCSI_DEBUG_DEV)
     # Verify optimal_io_size
-    SYSFS_OPTIMAL_IO_SIZE=$(echo /sys/block/$(basename $DEV_)/queue/optimal_io_size)
-    if [ -f "$SYSFS_OPTIMAL_IO_SIZE" ] ; then
-	ACTUAL_OPTIMAL_IO_SIZE=$(cat $SYSFS_OPTIMAL_IO_SIZE)
-	test $ACTUAL_OPTIMAL_IO_SIZE = $1
-    fi
+    SYSFS_OPTIMAL_IO_SIZE="/sys/block/$(basename $(< SCSI_DEBUG_DEV))/queue/optimal_io_size"
+    test -f "$SYSFS_OPTIMAL_IO_SIZE" || return 0
+    test "$(< $SYSFS_OPTIMAL_IO_SIZE)" -eq "$1" # ACTUAL_OPTIMAL_IO_SIZE
 }
 
 lvdev_() {
@@ -64,7 +58,7 @@ DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
 # Test that kernel supports topology
 aux prepare_scsi_debug_dev $DEV_SIZE || skip
 
-if [ ! -e /sys/block/$(basename $(cat SCSI_DEBUG_DEV))/alignment_offset ] ; then
+if [ ! -e /sys/block/$(basename $(< SCSI_DEBUG_DEV))/alignment_offset ] ; then
 	aux cleanup_scsi_debug_dev
 	skip
 fi
@@ -79,7 +73,9 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate $vg $(cat DEVICES)
+get_devs
+
+vgcreate $vg "${DEVICES[@]}"
 test_snapshot_mount
 vgremove $vg
 
@@ -94,7 +90,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate $vg $(cat DEVICES)
+vgcreate $vg "${DEVICES[@]}"
 test_snapshot_mount
 vgremove $vg
 
@@ -109,7 +105,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate $vg $(cat DEVICES)
+vgcreate $vg "${DEVICES[@]}"
 test_snapshot_mount
 vgremove $vg
 
@@ -126,6 +122,6 @@ check_logical_block_size $LOGICAL_BLOCK_SIZE
 check_optimal_io_size 786432
 
 aux prepare_pvs 1 $PER_DEV_SIZE
-check pv_field $(cat DEVICES) pe_start 768.00k
+check pv_field "${DEVICES[@]}" pe_start 768.00k
 
 aux cleanup_scsi_debug_dev


