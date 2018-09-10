From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 10 Sep 2018 12:44:34 -0400
Subject: master - lvconvert: allow raid4 -> linear conversion request
Message-ID: <201809101644.w8AGiYRp020844@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=989626926c98cd00f0236c4fcac883107d76899d
Commit:        989626926c98cd00f0236c4fcac883107d76899d
Parent:        e2e30a64ab10602951443dfbd3481bd6b32f5459
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Sep 10 18:36:52 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Sep 10 18:43:21 2018 +0200

lvconvert: allow raid4 -> linear conversion request

Allow "lvconvert --type linear RaidLV" on a raid4 LV
providing convenient interim steps to convert to linear.

Add respective new test
   lvconvert-raid-takeover-raid4_to_linear.sh
and
   lvconvert-raid-takeover-linear_to_raid4.sh
for linear to raid4 once on it.
---
 WHATS_NEW                                          |    1 +
 lib/metadata/raid_manip.c                          |   22 +++--
 .../lvconvert-raid-takeover-linear_to_raid4.sh     |   71 +++++++++++++++++
 .../lvconvert-raid-takeover-raid4_to_linear.sh     |   82 ++++++++++++++++++++
 4 files changed, 167 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6575887..a065a17 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Allow raid4 -> linear conversion request.
   Fix lvconvert striped/raid0/raid0_meta -> raid6 regression.
   Add 'lvm2-activation-generator:' prefix for kmsg messages logged by generator.
   Add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 130cd34..1af3729 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6149,9 +6149,17 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 		else if (!segtype_is_raid4(*segtype) && !segtype_is_any_raid5(*segtype))
 			seg_flag = SEG_RAID5_LS;
 
-	/* raid5* -> */
-	} else if (seg_is_any_raid5(seg_from)) {
-		if (segtype_is_raid1(*segtype) || segtype_is_linear(*segtype)) {
+	/* raid4/raid5* -> */
+	} else if (seg_is_raid4(seg_from) || seg_is_any_raid5(seg_from)) {
+		if (seg_is_raid4(seg_from) && segtype_is_any_raid5(*segtype)) {
+			if (!segtype_is_raid5_n(*segtype))
+				seg_flag = SEG_RAID5_N;
+
+		} else if (seg_is_any_raid5(seg_from) && segtype_is_raid4(*segtype)) {
+				if (!seg_is_raid5_n(seg_from))
+					seg_flag = SEG_RAID5_N;
+
+		} else if (segtype_is_raid1(*segtype) || segtype_is_linear(*segtype)) {
 			if (seg_from->area_count != 2) {
 				log_error("Converting %s LV %s to 2 stripes first.",
 					  lvseg_name(seg_from), display_lvname(seg_from->lv));
@@ -6173,12 +6181,12 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 					  lvseg_name(seg_from), display_lvname(seg_from->lv), *new_image_count);
 
 			} else
-				seg_flag = _raid_seg_flag_5_to_6(seg_from);
+				seg_flag = seg_is_raid4(seg_from) ? SEG_RAID6_N_6 :_raid_seg_flag_5_to_6(seg_from);
 
 		} else if (segtype_is_striped(*segtype) || segtype_is_raid10(*segtype)) {
 			int change = 0;
 
-			if (!seg_is_raid5_n(seg_from)) {
+			if (!seg_is_raid4(seg_from) && !seg_is_raid5_n(seg_from)) {
 				seg_flag = SEG_RAID5_N;
 
 			} else if (*stripes > 2 && *stripes != seg_from->area_count - seg_from->segtype->parity_devs) {
@@ -6199,10 +6207,6 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 					  lvseg_name(seg_from), display_lvname(seg_from->lv), *new_image_count);
 		}
 
-	/* raid4 -> * */
-	} else if (seg_is_raid4(seg_from) && !segtype_is_raid4(*segtype) && !segtype_is_striped(*segtype)) {
-		seg_flag = segtype_is_any_raid6(*segtype) ? SEG_RAID6_N_6 : SEG_RAID5_N;
-
 	/* raid6 -> striped/raid0/raid5/raid10 */
 	} else if (seg_is_any_raid6(seg_from)) {
 		if (segtype_is_raid1(*segtype)) {
diff --git a/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh b/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
new file mode 100644
index 0000000..0360fa0
--- /dev/null
+++ b/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
@@ -0,0 +1,71 @@
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
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext4 || skip
+aux have_raid 1 9 1 || skip
+
+aux prepare_vg 4 32
+
+# FIXME: lvconvert leaks  'error' devices
+detect_error_leak_()
+{
+	local err=""
+
+	for i in $(dmsetup info -c -o name --noheadings) ; do
+		case "$i" in
+		"$vg*") (dmsetup table "$i" | grep "error ") && err="$err $i" ;;
+		esac
+	done
+
+	test -z "$err" || {
+		dmsetup table | grep $vg
+		dmsetup ls --tree
+		die "Device(s) $err should not be here."
+	}
+}
+
+# Create linear LV
+lvcreate -y -L 9M -n $lv $vg
+check lv_field $vg/$lv segtype "linear"
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripes 1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
+
+# Step 1: convert linear -> raid4 (convert to 2-legged raid1)
+lvconvert -y --stripes 3 --ty raid4 $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "raid1"
+check lv_field $vg/$lv data_stripes 2
+check lv_field $vg/$lv stripes 2
+aux wait_for_sync $vg $lv
+
+# Step 2: convert linear ->raid4 (convert to raid4)
+lvconvert -y --stripes 3 --ty raid4 $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "raid4"
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripes 2
+
+# Step 3: convert linear ->raid4 (reshape to add stripes)
+lvconvert -y --stripes 3 --ty raid4 $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "raid4"
+check lv_field $vg/$lv data_stripes 3
+check lv_field $vg/$lv stripes 4
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh b/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
new file mode 100644
index 0000000..e571b82
--- /dev/null
+++ b/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
@@ -0,0 +1,82 @@
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
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext4 || skip
+aux have_raid 1 9 1 || skip
+
+aux prepare_vg 4 32
+
+# FIXME: lvconvert leaks  'error' devices
+detect_error_leak_()
+{
+	local err=""
+
+	for i in $(dmsetup info -c -o name --noheadings) ; do
+		case "$i" in
+		"$vg*") (dmsetup table "$i" | grep "error ") && err="$err $i" ;;
+		esac
+	done
+
+	test -z "$err" || {
+		dmsetup table | grep $vg
+		dmsetup ls --tree
+		die "Device(s) $err should not be here."
+	}
+}
+
+# Create 3-way striped raid4 (4 legs total)
+lvcreate -y --ty raid4 --stripes 3 -L 9M -n $lv $vg
+check lv_field $vg/$lv segtype "raid4"
+check lv_field $vg/$lv data_stripes 3
+check lv_field $vg/$lv stripes 4
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+fsck -fn "$DM_DEV_DIR/$vg/$lv"
+
+# Step 1: grow before removing stripes
+lvextend -y -L27M $vg/$lv
+aux wait_for_sync $vg $lv
+
+# Step 2: convert raid4 -> linear (reshape to remove stripes)
+lvconvert -y -f --ty linear $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "raid4"
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripes 4
+aux wait_for_sync $vg $lv 1
+
+# Step 2: convert raid4 -> linear (remove freed stripes)
+lvconvert -y --ty linear $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "raid4"
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripes 2
+
+# Step 3: convert raid4 -> linear (convert to raid1)
+lvconvert -y --ty linear $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "raid1"
+check lv_field $vg/$lv data_stripes 2
+check lv_field $vg/$lv stripes 2
+
+# Step 4: convert raid4 -> linear (convert to linear)
+lvconvert -y --ty linear $vg/$lv
+detect_error_leak_
+check lv_field $vg/$lv segtype "linear"
+check lv_field $vg/$lv data_stripes 1
+check lv_field $vg/$lv stripes 1
+
+vgremove -ff $vg


