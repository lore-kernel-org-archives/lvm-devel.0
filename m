From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Jun 2014 02:20:52 +0000 (UTC)
Subject: master - raid/misc: Allow creation of parallel areas by LV vs segment
Message-ID: <20140626022052.6A166610F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b35fb0b15af1d87693be286f0630e95622056a77
Commit:        b35fb0b15af1d87693be286f0630e95622056a77
Parent:        1f1675b059d65768524398791b2e505b7dfe2497
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 25 21:20:41 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 25 21:20:41 2014 -0500

raid/misc: Allow creation of parallel areas by LV vs segment

I've changed build_parallel_areas_from_lv to take a new parameter
that allows the caller to build parallel areas by LV vs by segment.
Previously, the function created a list of parallel areas for each
segment in the given LV.  When it came time for allocation, the
parallel areas were honored on a segment basis.  This was problematic
for RAID because any new RAID image must avoid being placed on any
PVs used by other images in the RAID.  For example, if we have a
linear LV that has half its space on one PV and half on another, we
do not want an up-convert to use either of those PVs.  It should
especially not wind up with the following, where the first portion
of one LV is paired up with the second portion of the other:
------PV1-------  ------PV2-------
[ 2of2 image_1 ]  [ 1of2 image_1 ]
[ 1of2 image_0 ]  [ 2of2 image_0 ]
----------------  ----------------
Previously, it was possible for this to happen.  The change makes
it so that the returned parallel areas list contains one "super"
segment (seg_pvs) with a list of all the PVs from every actual
segment in the given LV and covering the entire logical extent range.

This change allows RAID conversions to function properly when there
are existing images that contain multiple segments that span more
than one PV.
---
 WHATS_NEW                               |    1 +
 lib/metadata/lv_alloc.h                 |    3 +-
 lib/metadata/lv_manip.c                 |   55 +++++++++++++++++++++--------
 lib/metadata/mirror.c                   |    6 ++--
 lib/metadata/raid_manip.c               |    2 +-
 test/shell/lvconvert-raid-allocation.sh |   57 +++++++++++++++++++++++++++++++
 test/shell/lvconvert-raid.sh            |   22 ------------
 7 files changed, 104 insertions(+), 42 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3ab7046..05b3c7c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  New RAID images now avoid allocation on any PVs in the same parent RAID LV.
   Always reevaluate filters just before creating PV.
 
 Version 2.02.107 - 23rd June 2014
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index f99e1a1..9824c67 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -86,6 +86,7 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 void alloc_destroy(struct alloc_handle *ah);
 
 struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
-					     unsigned use_pvmove_parent_lv);
+					     unsigned use_pvmove_parent_lv,
+					     unsigned create_single_list);
 
 #endif
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 069e5a6..05293f1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4664,15 +4664,30 @@ static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
 }
 
 /*
- * Construct dm_list of segments of LVs showing which PVs they use.
- * For pvmove we use the *parent* LV so we can pick up stripes & existing mirrors etc.
+ * build_parallel_areas_from_lv
+ * @lv
+ * @use_pvmove_parent_lv
+ * @create_single_list
+ *
+ * For each segment in an LV, create a list of PVs used by the segment.
+ * Thus, the returned list is really a list of segments (seg_pvs)
+ * containing a list of PVs that are in use by that segment.
+ *
+ * use_pvmove_parent_lv:  For pvmove we use the *parent* LV so we can
+ *                        pick up stripes & existing mirrors etc.
+ * create_single_list  :  Instead of creating a list of segments that
+ *                        each contain a list of PVs, return a list
+ *                        containing just one segment (i.e. seg_pvs)
+ *                        that contains a list of all the PVs used by
+ *                        the entire LV and all it's segments.
  */
 struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
-					     unsigned use_pvmove_parent_lv)
+					     unsigned use_pvmove_parent_lv,
+					     unsigned create_single_list)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct dm_list *parallel_areas;
-	struct seg_pvs *spvs;
+	struct seg_pvs *spvs = NULL;
 	uint32_t current_le = 0;
 	uint32_t raid_multiple;
 	struct lv_segment *seg = first_seg(lv);
@@ -4685,19 +4700,20 @@ struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 	dm_list_init(parallel_areas);
 
 	do {
-		if (!(spvs = dm_pool_zalloc(cmd->mem, sizeof(*spvs)))) {
-			log_error("allocation failed");
-			return NULL;
-		}
-
-		dm_list_init(&spvs->pvs);
+		if (!spvs || !create_single_list) {
+			if (!(spvs = dm_pool_zalloc(cmd->mem, sizeof(*spvs)))) {
+				log_error("allocation failed");
+				return NULL;
+			}
 
+			dm_list_init(&spvs->pvs);
+			dm_list_add(parallel_areas, &spvs->list);
+		}
 		spvs->le = current_le;
 		spvs->len = lv->le_count - current_le;
 
-		dm_list_add(parallel_areas, &spvs->list);
-
-		if (use_pvmove_parent_lv && !(seg = find_seg_by_le(lv, current_le))) {
+		if (use_pvmove_parent_lv &&
+		    !(seg = find_seg_by_le(lv, current_le))) {
 			log_error("Failed to find segment for %s extent %" PRIu32,
 				  lv->name, current_le);
 			return 0;
@@ -4718,7 +4734,16 @@ struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 			seg->area_count - seg->segtype->parity_devs : 1;
 	} while ((current_le * raid_multiple) < lv->le_count);
 
-	/* FIXME Merge adjacent segments with identical PV lists (avoids need for contiguous allocation attempts between successful allocations) */
+	if (create_single_list) {
+		spvs->le = 0;
+		spvs->len = lv->le_count;
+	}
+
+	/*
+	 * FIXME:  Merge adjacent segments with identical PV lists
+	 * (avoids need for contiguous allocation attempts between
+	 * successful allocations)
+	 */
 
 	return parallel_areas;
 }
@@ -5165,7 +5190,7 @@ int split_parent_segments_for_layer(struct cmd_context *cmd,
 	uint32_t s;
 	struct dm_list *parallel_areas;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(layer_lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(layer_lv, 0, 0)))
 		return_0;
 
 	/* Loop through all LVs except itself */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 484b1f1..985bde0 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1687,7 +1687,7 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 	uint32_t adjusted_region_size;
 	int r = 1;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 1)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 1, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -1971,7 +1971,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		return 1;
 	}
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -2044,7 +2044,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	 * allocate destination extents
 	 */
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cdfbc84..0303654 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -392,7 +392,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 	if (!lvl_array)
 		return_0;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
 		return_0;
 
 	if (seg_is_linear(seg))
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
new file mode 100644
index 0000000..804317b
--- /dev/null
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -0,0 +1,57 @@
+#!/bin/sh
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+aux have_raid 1 3 0 || skip
+
+aux prepare_pvs 5
+vgcreate -s 256k $vg $(cat DEVICES)
+
+# Start with linear on 2 PV and ensure that converting to
+# RAID is not allowed to reuse PVs for different images.  (Bug 1113180)
+lvcreate -l 4 -n $lv1 $vg "$dev1:0-1" "$dev2:0-1"
+not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev2"
+not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev3:0-2"
+lvconvert --type raid1 -m 1 $vg/$lv1 "$dev3"
+lvconvert -m 0 $vg/$lv1
+# RAID conversions are not honoring allocation policy!
+# lvconvert --type raid1 -m 1 --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
+lvremove -ff $vg
+
+# Setup 2-way RAID1 LV to spread across 4 devices.
+# For each image:
+#  - metadata LV + 1 image extent (2 total extents) on one PV
+#  - 2 image extents on the other PV
+# Then attempt allocation of another image from 2 extents on
+# a 5th PV and the remainder of the rest of already used PVs.
+#
+# This should fail because there is insufficient space on the
+# non-parallel PV (i.e. there is not enough space for the image
+# if it doesn't share a PV with another image).
+lvcreate --type raid1 -m 1 -l 3 -n $lv1 $vg \
+    "$dev1:0-1" "$dev2:0-1" "$dev3:0-1" "$dev4:0-1"
+aux wait_for_sync $vg $lv1
+# Should not be enough non-overlapping space.
+not lvconvert -m +1 $vg/$lv1 \
+    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvconvert -m +1 $vg/$lv1 "$dev5"
+lvconvert -m 0 $vg/$lv1
+
+# Should work due to '--alloc anywhere'
+# RAID conversion not honoring allocation policy!
+#lvconvert -m +1 --alloc anywhere $vg/$lv1 \
+#    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
+lvremove -ff $vg
+
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 8bd56ec..6f17303 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -202,26 +202,4 @@ for i in {1..3}; do
 	lvremove -ff $vg
 done
 
-# Setup 2-way RAID1 LV to spread across 4 devices.
-# For each image:
-#  - metadata LV + 1 image extent (2 total extents) on one PV
-#  - 2 image extents on the other PV
-# Then attempt allocation of another image from 2 extents on
-# a 5th PV and the remainder of the rest of already used PVs.
-#
-# This should fail because there is insufficient space on the
-# non-parallel PV (i.e. there is not enough space for the image
-# if it doesn't share a PV with another image).
-lvcreate --type raid1 -m 1 -l 3 -n $lv1 $vg \
-    "$dev1:0-1" "$dev2:0-1" "$dev3:0-1" "$dev4:0-1"
-aux wait_for_sync $vg $lv1
-# Should not be enough non-overlapping space.
-not lvconvert -m +1 $vg/$lv1 \
-    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
-# Should work due to '--alloc anywhere'
-lvconvert -m +1 --alloc anywhere $vg/$lv1 \
-    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
-lvremove -ff $vg
-
-
 vgremove -ff $vg


