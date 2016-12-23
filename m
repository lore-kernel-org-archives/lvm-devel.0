From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 23 Dec 2016 02:41:47 +0000 (UTC)
Subject: master - lvchange: allow a transiently failed RaidLV to be refreshed
Message-ID: <20161223024147.CA25360F2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95d68f1d0e16f553f4f12046ceb7b6ff8d251336
Commit:        95d68f1d0e16f553f4f12046ceb7b6ff8d251336
Parent:        62be9c8de430a054d5de9b652949f58a684a0cf6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 23 03:35:13 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 23 03:41:32 2016 +0100

lvchange: allow a transiently failed RaidLV to be refreshed

Add to commits 87117c2b2546 and 0b8bf73a63d8 to avoid refreshing two
times altogether, thus avoiding issues related to clustered, remotely
activated RaidLV.  Avoid need to repeat "lvchange --refresh RaidLV"
two times as a workaround to refresh a RaidLV.  Fix handles removal
of temporary *-missing-* devices created for any missing segments
in RAID SubLVs during activation.

Because the kernel dm-raid target isn't able to handle transiently
failing devices properly we need
"[dm-devel][PATCH] dm raid: fix transient device failure processing"
as well.

test: add lvchange-raid-transient-failures.sh
      and enhance lvconvert-raid.sh

Resolves: rhbz1025322
Related:  rhbz1265191
Related:  rhbz1399844
Related:  rhbz1404425
---
 lib/activate/activate.c                        |   75 ++++++++++++++++++++++++
 lib/activate/activate.h                        |    2 +
 lib/metadata/lv_manip.c                        |   34 +++--------
 test/shell/lvchange-raid-transient-failures.sh |   69 ++++++++++++++++++++++
 test/shell/lvconvert-raid.sh                   |   19 +++++-
 5 files changed, 171 insertions(+), 28 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b7009e6..742d838 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -358,6 +358,10 @@ int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	return 1;
 }
+int lv_deactivate_any_missing_subdevs(const struct logical_volume *lv)
+{
+	return 1;
+}
 int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg)
 {
@@ -2573,6 +2577,77 @@ int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 	return r;
 }
 
+/* Remove any existing, closed mapped device by @name */
+static int _remove_dm_dev_by_name(const char *name)
+{
+	int r = 0;
+	struct dm_task *dmt;
+	struct dm_info info;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		return_0;
+
+	/* Check, if the device exists. */
+	if (dm_task_set_name(dmt, name) && dm_task_run(dmt) && dm_task_get_info(dmt, &info)) {
+		dm_task_destroy(dmt);
+
+		/* Ignore non-existing or open dm devices */
+		if (!info.exists || info.open_count)
+			return 1;
+
+		if (!(dmt = dm_task_create(DM_DEVICE_REMOVE)))
+			return_0;
+
+		if (dm_task_set_name(dmt, name))
+			r = dm_task_run(dmt);
+	}
+
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+/* Work all segments of @lv removing any existing, closed "*-missing_N_0" sub devices. */
+static int _lv_remove_any_missing_subdevs(struct logical_volume *lv)
+{
+	if (lv) {
+		uint32_t seg_no = 0;
+		char name[257];
+		struct lv_segment *seg;
+
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (seg->area_count != 1)
+				return_0;
+			if (dm_snprintf(name, sizeof(name), "%s-%s-missing_%u_0", seg->lv->vg->name, seg->lv->name, seg_no) < 0)
+				return 0;
+			if (!_remove_dm_dev_by_name(name))
+				return 0;
+
+			seg_no++;
+		}
+	}
+
+	return 1;
+}
+
+/* Remove any "*-missing_*" sub devices added by the activation layer for an rmate/rimage missing PV mapping */
+int lv_deactivate_any_missing_subdevs(const struct logical_volume *lv)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) == AREA_LV &&
+		    !_lv_remove_any_missing_subdevs(seg_lv(seg, s)))
+			return 0;
+		if (seg->meta_areas && seg_metatype(seg, s) == AREA_LV &&
+		    !_lv_remove_any_missing_subdevs(seg_metalv(seg, s)))
+			return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Does PV use VG somewhere in its construction?
  * Returns 1 on failure.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index db8d997..85c1521 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -124,6 +124,8 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
 
+int lv_deactivate_any_missing_subdevs(const struct logical_volume *lv);
+
 /*
  * Returns 1 if info structure has been populated, else 0 on failure.
  * When lvinfo* is NULL, it returns 1 if the device is locally active, 0 otherwise.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3862f11..e5808ec 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1419,35 +1419,19 @@ static int _lv_refresh_suspend_resume(const struct logical_volume *lv)
 
 int lv_refresh_suspend_resume(const struct logical_volume *lv)
 {
+	if (!_lv_refresh_suspend_resume(lv))
+		return 0;
+
 	/*
-	 * FIXME:
-	 *
-	 * in case of RAID, refresh the SubLVs before
-	 * refreshing the top-level one in order to cope
-	 * with transient failures of SubLVs.
+	 * Remove any transiently activated error
+	 * devices which arean't used any more.
 	 */
-	if (lv_is_raid(lv)) {
-		if (vg_is_clustered(lv->vg) &&
-		    lv_is_active_remotely(lv)) {
-			if (!_lv_refresh_suspend_resume(lv))
-				return 0;
-		} else {
-			uint32_t s;
-			struct lv_segment *seg = first_seg(lv);
-
-			for (s = 0; s < seg->area_count; s++) {
-				if (seg_type(seg, s) == AREA_LV &&
-				    !_lv_refresh_suspend_resume(seg_lv(seg, s)))
-					return 0;
-				if (seg->meta_areas &&
-				    seg_metatype(seg, s) == AREA_LV &&
-				    !_lv_refresh_suspend_resume(seg_metalv(seg, s)))
-					return 0;
-			}
-		}
+	if (lv_is_raid(lv) && !lv_deactivate_any_missing_subdevs(lv)) {
+		log_error("Failed to remove temporary SubLVs from %s", display_lvname(lv));
+		return 0;
 	}
 
-	return _lv_refresh_suspend_resume(lv);
+	return 1;
 }
 
 /*
diff --git a/test/shell/lvchange-raid-transient-failures.sh b/test/shell/lvchange-raid-transient-failures.sh
new file mode 100644
index 0000000..844f217
--- /dev/null
+++ b/test/shell/lvchange-raid-transient-failures.sh
@@ -0,0 +1,69 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 10 1 || skip
+aux prepare_vg 6
+
+#
+# FIXME: add multi-segment leg tests
+#
+
+function _check_raid
+{
+	local vg=$1
+	shift
+	local lv=$1
+	shift
+	local fail=$1
+	shift
+	local good=$1
+	shift
+	local devs=$*
+
+	aux wait_for_sync $vg $lv
+	aux disable_dev --error --silent $devs
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+	fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv"
+	check raid_leg_status $vg $lv "$fail"
+	aux enable_dev --silent $devs
+	lvs -a -o +devices $vg | tee out
+	not grep unknown out
+	lvchange --refresh $vg/$lv
+	fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv"
+	aux wait_for_sync $vg $lv
+	fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv"
+	check raid_leg_status $vg $lv "$good"
+}
+
+# raid1 with transiently failing devices
+lv=4way
+lvcreate -aey --type raid1 -m 3 --ignoremonitoring -L 1 -n $lv $vg
+_check_raid $vg $lv "ADAD" "AAAA" $dev2 $dev4
+lvremove -y $vg/$lv
+
+# raid6 with transiently failing devices
+lv=6way
+lvcreate -aey --type raid6 -i 4 --ignoremonitoring -L 1 -n $lv $vg
+_check_raid $vg $lv "ADADAA" "AAAAAA" $dev2 $dev4
+lvremove -y $vg/$lv
+
+# raid10 with transiently failing devices
+lv=6way
+lvcreate -aey --type raid10 -i 3 -m 1 --ignoremonitoring -L 1 -n $lv $vg
+_check_raid $vg $lv "ADADDA" "AAAAAA" $dev2 $dev4 $dev5
+lvremove -y $vg/$lv
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 25bc4a8..8538c41 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -32,7 +32,8 @@ get_image_pvs() {
 aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 9
-vgcreate -s 256k $vg $(cat DEVICES)
+# vgcreate -s 256k $vg $(cat DEVICES)
+vgcreate -s 2m $vg $(cat DEVICES)
 
 ###########################################
 # RAID1 convert tests
@@ -135,15 +136,27 @@ lvconvert --yes --splitmirrors 1 --name $lv2 $vg/$lv1 "$dev2"
 lvremove -ff $vg
 
 ###########################################
-# RAID1 split + trackchanges / merge
+# RAID1 split + trackchanges / merge with content check
 ###########################################
 # 3-way to 2-way/linear
-lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+lvcreate --type raid1 -m 2 -l 1 -n $lv1 $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
+fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
 lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg ${lv1}_rimage_2
+fsck.ext4 -fn "$DM_DEV_DIR/mapper/$vg-${lv1}_rimage_2"
+dd of="$DM_DEV_DIR/$vg/$lv1" if=/dev/zero bs=512 oflag=direct count=`blockdev --getsz "$DM_DEV_DIR/$vg/$lv1"`
+not fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
+fsck.ext4 -fn "$DM_DEV_DIR/mapper/$vg-${lv1}_rimage_2"
+# FIXME: needed on tiny loop but not on real block backend ?
+lvchange --refresh $vg/$lv1
 lvconvert --merge $vg/${lv1}_rimage_2
+aux wait_for_sync $vg $lv1
+lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
+not fsck.ext4 -fn "$DM_DEV_DIR/mapper/$vg-${lv1}_rimage_2"
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 


