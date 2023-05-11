From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 May 2023 16:29:04 +0000 (GMT)
Subject: main - raidintegrity: allow snapshots
Message-ID: <20230511162904.2867A3858C54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd6e113bba5fed5ee41152cde33220294c24ce2b
Commit:        fd6e113bba5fed5ee41152cde33220294c24ce2b
Parent:        05c2b10c5d0a99993430ffbcef684a099ba810ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 22 13:05:43 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 11 11:02:52 2023 -0500

raidintegrity: allow snapshots

---
 lib/activate/dev_manager.c     |   6 +-
 lib/metadata/integrity_manip.c |   5 -
 lib/metadata/snapshot_manip.c  |   2 -
 test/shell/snapshot-raid.sh    | 441 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 446 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ac3f01718..1f4d7c98b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3039,7 +3039,11 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 		if (((seg_type(seg, s) == AREA_PV) && _bad_pv_area(seg, s)) ||
 		    ((seg_type(seg, s) == AREA_LV) && !seg_lv(seg, s))) {
 			if (!cmd->partial_activation) {
-				if (!cmd->degraded_activation || !lv_is_raid_type(seg->lv)) {
+				if (!cmd->degraded_activation ||
+				    (!lv_is_raid_type(seg->lv) &&
+				     !lv_is_integrity(seg->lv) &&
+				     !lv_is_integrity_metadata(seg->lv) &&
+				     !lv_is_integrity_origin(seg->lv))) {
 					log_error("Aborting.  LV %s is incomplete and --activationmode partial was not specified.",
 						  display_lvname(seg->lv));
 					return 0;
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index d71fbaeb6..6b507f7e9 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -508,11 +508,6 @@ int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_setting
 		return 0;
 	}
 
-	if (lv_is_origin(lv)) {
-		log_error("Integrity cannot be added to snapshot origins.");
-		return 0;
-	}
-
 	seg_top = first_seg(lv);
 	area_count = seg_top->area_count;
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 822b8da77..b34079d08 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -423,8 +423,6 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 		}
 	} else if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv)) {
 		err = "raid subvolumes";
-	} else if (lv_is_raid(origin_lv) && lv_raid_has_integrity((struct logical_volume *)origin_lv)) {
-		err = "raid with integrity";
 	}
 
  out:
diff --git a/test/shell/snapshot-raid.sh b/test/shell/snapshot-raid.sh
new file mode 100644
index 000000000..757bf911e
--- /dev/null
+++ b/test/shell/snapshot-raid.sh
@@ -0,0 +1,441 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test snapshots of raid
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext4 || skip
+
+mount_dir="mnt"
+mkdir -p "$mount_dir"
+
+snap_dir="mnt_snap"
+mkdir -p "$snap_dir"
+
+_sync_percent() {
+        local checklv=$1
+        get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_sync() {
+        local checklv=$1
+
+        for i in $(seq 1 10) ; do
+                sync=$(_sync_percent "$checklv")
+                echo "sync_percent is $sync"
+
+                if test "$sync" = "100"; then
+                        return
+                fi
+
+                sleep 1
+        done
+        echo "timeout waiting for recalc"
+        dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+        return 1
+}
+
+
+# add and remove a snapshot
+
+test_add_del_snap() {
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	touch "$mount_dir/B"
+	not ls "$snap_dir/B"
+	touch "$snap_dir/C"
+	not ls "$mount_dir/C"
+	ls "$mount_dir/A"
+	ls "$snap_dir/A"
+
+	umount "$snap_dir"
+	lvremove -y $vg/snap
+	umount "$mount_dir"
+}
+
+# add and remove snapshot while origin has a missing raid image
+
+test_snap_with_missing_image() {
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	aux disable_dev "$dev1"
+	lvs -a -o+devices $vg
+
+	not lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+
+	aux enable_dev "$dev1"
+	_wait_sync $vg/$lv1
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+
+	aux disable_dev "$dev1"
+	lvs -a -o+devices $vg
+
+	lvremove -y $vg/snap
+
+	aux enable_dev "$dev1"
+	vgextend --restoremissing $vg "$dev1"
+	lvs -a -o+devices $vg
+	_wait_sync $vg/$lv1
+
+	umount "$mount_dir"
+}
+
+# raid image is lost and restored while a snapshot exists
+
+test_missing_image_with_snap() {
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	aux disable_dev "$dev1"
+	lvs -a -o+devices $vg
+
+	touch "$mount_dir/B"
+	not ls "$snap_dir/B"
+	touch "$snap_dir/C"
+	not ls "$mount_dir/C"
+	ls "$mount_dir/A"
+	ls "$snap_dir/A"
+
+	aux enable_dev "$dev1"
+	_wait_sync $vg/$lv1
+
+	ls "$mount_dir/B"
+	ls "$snap_dir/C"
+
+	umount "$snap_dir"
+	lvremove -y $vg/snap
+	umount "$mount_dir"
+}
+
+# add and remove raid image while snapshot exists
+
+test_add_del_image_with_snap() {
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	touch "$mount_dir/B"
+	touch "$snap_dir/C"
+
+	lvconvert -y -m+1 $vg/$lv1 "$dev4"
+	_wait_sync $vg/$lv1
+
+	ls "$mount_dir/B"
+	ls "$snap_dir/C"
+	ls "$mount_dir/A"
+	ls "$snap_dir/A"
+
+	touch "$mount_dir/B2"
+	touch "$snap_dir/C2"
+
+	lvconvert -y -m-1 $vg/$lv1 "$dev4"
+
+	ls "$mount_dir/B"
+	ls "$snap_dir/C"
+	ls "$mount_dir/A"
+	ls "$snap_dir/A"
+	ls "$mount_dir/B2"
+	ls "$snap_dir/C2"
+	umount "$snap_dir"
+	lvremove -y $vg/snap
+
+	umount "$mount_dir"
+}
+
+test_replace_image_with_snap() {
+	# add an image to replace
+	lvconvert -y -m+1 $vg/$lv1 "$dev4"
+	_wait_sync $vg/$lv1
+
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	touch "$mount_dir/B"
+	touch "$snap_dir/C"
+
+	lvconvert -y --replace "$dev4" $vg/$lv1 "$dev5"
+	_wait_sync $vg/$lv1
+
+	ls "$mount_dir/B"
+	ls "$snap_dir/C"
+	ls "$mount_dir/A"
+	ls "$snap_dir/A"
+
+	touch "$mount_dir/B2"
+	touch "$snap_dir/C2"
+
+	umount "$snap_dir"
+	lvremove -y $vg/snap
+
+	# put lv1 back to original state with images on dev1 and dev2
+	lvconvert -y -m-1 $vg/$lv1 "$dev5"
+
+	umount "$mount_dir"
+}
+
+test_repair_image_with_snap() {
+	# add an image to repair
+	lvconvert -y -m+1 $vg/$lv1 "$dev4"
+	_wait_sync $vg/$lv1
+
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	touch "$mount_dir/B"
+	touch "$snap_dir/C"
+
+	aux disable_dev "$dev4"
+	lvs -a -o+devices $vg
+
+	lvconvert -y --repair $vg/$lv1 "$dev5"
+	_wait_sync $vg/$lv1
+
+	ls "$mount_dir/B"
+	ls "$snap_dir/C"
+	ls "$mount_dir/A"
+	ls "$snap_dir/A"
+
+	touch "$mount_dir/B2"
+	touch "$snap_dir/C2"
+
+	umount "$snap_dir"
+	lvremove -y $vg/snap
+
+	aux enable_dev "$dev4"
+	lvs -a -o+devices $vg
+	vgck --updatemetadata $vg
+
+	# put lv1 back to original state with images on dev1 and dev2
+	lvconvert -y -m-1 $vg/$lv1 "$dev5"
+
+	umount "$mount_dir"
+}
+
+test_merge_snap()
+{
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	touch "$mount_dir/B"
+	touch "$snap_dir/C"
+
+	umount "$snap_dir"
+
+	lvconvert --merge $vg/snap
+
+	# the merge will begin once the origin is not in use
+	umount "$mount_dir"
+
+	lvs -a $vg
+	lvchange -an $vg/$lv1
+	lvchange -ay $vg/$lv1
+	lvs -a $vg
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	ls "$mount_dir/A"
+	ls "$mount_dir/C"
+	not ls "$mount_dir/B"
+
+	umount "$mount_dir"
+}
+
+test_extend_snap()
+{
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L8M $vg/$lv1 "$dev3"
+	mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+	touch "$mount_dir/B"
+	touch "$snap_dir/C"
+
+	lvextend -L+8M $vg/snap
+
+	umount "$mount_dir"
+	umount "$snap_dir"
+	lvremove -y $vg/snap
+}
+
+test_fill_snap()
+{
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	touch "$mount_dir/A"
+
+	lvcreate -s -n snap -L4M $vg/$lv1 "$dev3"
+
+	lvs -a $vg
+	get lv_field $vg/snap lv_attr | grep "swi-a-s---"
+
+	dd if=/dev/zero of="$mount_dir/1" bs=1M count=1 oflag=sync
+	dd if=/dev/zero of="$mount_dir/2" bs=1M count=1 oflag=sync
+	dd if=/dev/zero of="$mount_dir/3" bs=1M count=1 oflag=sync
+	dd if=/dev/zero of="$mount_dir/4" bs=1M count=1 oflag=sync
+	dd if=/dev/zero of="$mount_dir/5" bs=1M count=1 oflag=sync
+
+	lvs -a $vg
+	get lv_field $vg/snap lv_attr | grep "swi-I-s---"
+	check lv_field $vg/snap data_percent "100.00"
+
+	umount "$mount_dir"
+	lvremove -y $vg/snap
+}
+
+aux prepare_devs 5 200
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+
+lvcreate --type raid1 -m1 -n $lv1 -L128M $vg "$dev1" "$dev2"
+_wait_sync $vg/$lv1
+test_add_del_snap
+test_snap_with_missing_image
+test_missing_image_with_snap
+test_add_del_image_with_snap
+test_replace_image_with_snap
+test_repair_image_with_snap
+test_merge_snap
+test_extend_snap
+test_fill_snap
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -L128M $vg "$dev1" "$dev2"
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+_wait_sync $vg/$lv1
+test_add_del_snap
+test_snap_with_missing_image
+test_missing_image_with_snap
+test_add_del_image_with_snap
+test_replace_image_with_snap
+test_repair_image_with_snap
+test_merge_snap
+test_extend_snap
+test_fill_snap
+lvremove -y $vg/$lv1
+
+# Repeat above with cache|writecache on the raid image? 
+
+#
+# Add/remove integrity while a snapshot exists
+#
+
+lvcreate --type raid1 -m1 -n $lv1 -L128M $vg "$dev1" "$dev2"
+_wait_sync $vg/$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+touch "$mount_dir/A"
+
+lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+touch "$mount_dir/B"
+touch "$snap_dir/C"
+
+lvconvert --raidintegrity y $vg/$lv1
+_wait_sync $vg/${lv1}_rimage_0
+_wait_sync $vg/${lv1}_rimage_1
+
+ls "$mount_dir/B"
+ls "$snap_dir/C"
+ls "$mount_dir/A"
+ls "$snap_dir/A"
+
+touch "$mount_dir/B2"
+touch "$snap_dir/C2"
+
+lvconvert --raidintegrity n $vg/$lv1
+
+ls "$mount_dir/B"
+ls "$snap_dir/C"
+ls "$mount_dir/A"
+ls "$snap_dir/A"
+ls "$mount_dir/B2"
+ls "$snap_dir/C2"
+umount "$snap_dir"
+umount "$mount_dir"
+lvremove -y $vg/snap
+lvremove -y $vg/$lv1
+
+#
+# Add integrity not allowed with missing image and snapshot exists
+#
+
+lvcreate --type raid1 -m1 -n $lv1 -L128M $vg "$dev1" "$dev2"
+_wait_sync $vg/$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+touch "$mount_dir/A"
+
+lvcreate -s -n snap -L12M $vg/$lv1 "$dev3"
+mount "$DM_DEV_DIR/$vg/snap" "$snap_dir"
+
+touch "$mount_dir/B"
+touch "$snap_dir/C"
+
+aux disable_dev "$dev1"
+lvs -a $vg
+
+not lvconvert --raidintegrity y $vg/$lv1
+
+aux enable_dev "$dev1"
+lvs -a $vg
+
+umount "$snap_dir"
+umount "$mount_dir"
+lvremove -y $vg/snap
+lvremove -y $vg/$lv1
+
+vgremove -ff $vg
+

