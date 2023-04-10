From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Apr 2023 17:44:31 +0000 (GMT)
Subject: main - cache: fix snapshot of cache with cachevol
Message-ID: <20230410174431.58A1A3858D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=317071ec53c2f6e338c53a8964fdbb61dc3e8b57
Commit:        317071ec53c2f6e338c53a8964fdbb61dc3e8b57
Parent:        8458ff9ad18c518b774d16358e28a805057e4dc1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 10 11:41:28 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 10 12:44:22 2023 -0500

cache: fix snapshot of cache with cachevol

Creating a snapshot of a cache LV with a cachevol would fail
because cache_check was not being skipped.
---
 lib/activate/dev_manager.c     |   2 +
 test/shell/caching-snapshot.sh | 162 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 164 insertions(+)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ec642f421..07d58733e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3694,6 +3694,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv) &&
 	    /* Register callback only for layer activation or non-layered cache LV */
 	    (layer || !lv_layer(lv)) &&
+	    /* Register callback when cachevol LV is NOT already active */
+	    !_cached_dm_info(dm->mem, dtree, first_seg(lv)->pool_lv, NULL) &&
 	    !_pool_register_callback(dm, dnode, lv))
 		return_0;
 
diff --git a/test/shell/caching-snapshot.sh b/test/shell/caching-snapshot.sh
new file mode 100644
index 000000000..d73f4ad06
--- /dev/null
+++ b/test/shell/caching-snapshot.sh
@@ -0,0 +1,162 @@
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
+# Test snapshot on cache|writecache
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+lvm segtypes 2>/dev/null | grep writecache$ >/dev/null || {
+	skip 'Writecache is not built-in.'
+}
+aux have_cache 1 10 0 || skip
+which mkfs.ext4 || skip
+
+mount_dir="mnt"
+mkdir -p "$mount_dir"
+
+mount_dir_snap="mnt_snap"
+mkdir -p "$mount_dir_snap"
+
+# generate random data
+dd if=/dev/urandom of=pattern1 bs=512K count=1
+
+aux prepare_devs 2 310
+
+vgcreate $SHARED $vg "$dev1" "$dev2"
+
+# creating a snapshot on top of a cache|writecache
+
+test_snap_create() {
+	# cache | writecache
+	local convert_type=$1
+
+	# --cachepool | --cachevol
+	local convert_option=$2
+
+	lvcreate -n $lv1 -L 300 -an $vg "$dev1"
+	lvcreate -n fast -l 4 -an $vg "$dev2"
+	lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+	lvchange -ay $vg/$lv1
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	cp pattern1 "$mount_dir/pattern1a"
+	lvcreate -s -L 32 -n snap $vg/$lv1
+	cp pattern1 "$mount_dir/pattern1b"
+	mount "$DM_DEV_DIR/$vg/snap" "$mount_dir_snap"
+	not ls "$mount_dir_snap/pattern1b"
+	rm "$mount_dir/pattern1a"
+	diff pattern1 "$mount_dir_snap/pattern1a"
+	umount "$mount_dir_snap"
+	lvconvert --splitcache $vg/$lv1
+	umount "$mount_dir"
+	lvchange -an $vg/$lv1
+	lvchange -an $vg/fast
+	lvremove $vg/snap
+	lvremove $vg/$lv1
+	lvremove $vg/fast
+}
+
+test_snap_create cache --cachepool
+test_snap_create cache --cachevol
+test_snap_create writecache --cachevol
+
+# removing cache|writecache while snapshot exists
+
+test_snap_remove() {
+	# cache | writecache
+	local convert_type=$1
+
+	# --cachepool | --cachevol
+	local convert_option=$2
+
+	lvcreate -n $lv1 -L 300 -an $vg "$dev1"
+	lvcreate -n fast -l 4 -an $vg "$dev2"
+	lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+	lvchange -ay $vg/$lv1
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	cp pattern1 "$mount_dir/pattern1a"
+	lvcreate -s -L 32 -n snap $vg/$lv1
+	cp pattern1 "$mount_dir/pattern1b"
+	lvconvert --splitcache $vg/$lv1
+	mount "$DM_DEV_DIR/$vg/snap" "$mount_dir_snap"
+	not ls "$mount_dir_snap/pattern1b"
+	rm "$mount_dir/pattern1a"
+	diff pattern1 "$mount_dir_snap/pattern1a"
+	umount "$mount_dir_snap"
+	umount "$mount_dir"
+	lvchange -an $vg/$lv1
+	lvchange -an $vg/fast
+	lvremove $vg/snap
+	lvremove $vg/$lv1
+	lvremove $vg/fast
+}
+
+test_snap_remove cache --cachepool
+test_snap_remove cache --cachevol
+test_snap_remove writecache --cachevol
+
+# adding cache|writecache to an LV that has a snapshot
+
+test_caching_with_snap() {
+	# cache | writecache
+	local convert_type=$1
+
+	# --cachepool | --cachevol
+	local convert_option=$2
+
+	lvcreate -n $lv1 -L 300 -an $vg "$dev1"
+	lvcreate -n fast -l 4 -an $vg "$dev2"
+	lvchange -ay $vg/$lv1
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+	mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+	cp pattern1 "$mount_dir/pattern1a"
+	lvcreate -s -L 32 -n snap $vg/$lv1
+	lvconvert -y --type $convert_type $convert_option fast $vg/$lv1
+	cp pattern1 "$mount_dir/pattern1b"
+	mount "$DM_DEV_DIR/$vg/snap" "$mount_dir_snap"
+	not ls "$mount_dir_snap/pattern1b"
+	mv "$mount_dir/pattern1a" "$mount_dir/pattern1c"
+	diff pattern1 "$mount_dir_snap/pattern1a"
+	lvconvert --splitcache $vg/$lv1
+	diff pattern1 "$mount_dir/pattern1c"
+	diff pattern1 "$mount_dir_snap/pattern1a"
+	umount "$mount_dir_snap"
+	umount "$mount_dir"
+	lvchange -an $vg/$lv1
+	lvchange -an $vg/fast
+	lvremove $vg/snap
+	lvremove $vg/$lv1
+	lvremove $vg/fast
+}
+
+test_caching_with_snap cache --cachepool
+test_caching_with_snap cache --cachevol
+test_caching_with_snap writecache --cachevol
+
+# adding cache|writecache to a snapshot is not allowed
+
+lvcreate -n $lv1 -L 300 $vg "$dev1"
+lvcreate -n fast -l 4 $vg "$dev2"
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+lvcreate -s -L 32 -n snap $vg/$lv1
+not lvconvert -y --type writecache --cachevol fast $vg/snap
+not lvconvert -y --type cache --cachevol fast $vg/snap
+not lvconvert -y --type cache --cachepool fast $vg/snap
+vgchange -an $vg
+lvremove $vg/snap
+lvremove $vg/$lv1
+lvremove $vg/fast
+
+vgremove -ff $vg

