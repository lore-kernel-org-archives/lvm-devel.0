From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  7 Feb 2017 00:01:36 +0000 (UTC)
Subject: master - lvconvert: add support to change RAID region size
Message-ID: <20170207000136.EB63F60759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfb6ef654d3d1f1dd02569a1d5bd2fc252ae2494
Commit:        cfb6ef654d3d1f1dd02569a1d5bd2fc252ae2494
Parent:        51d03acb1c910a65ff05a0a339ed6a4ff957c0db
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Feb 6 22:09:26 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 7 01:01:19 2017 +0100

lvconvert: add support to change RAID region size

Add:
- support to change region size of existing RaidLVs
  (all RAID LV types but raid0/raid0_meta)
- lvconvert-raid-regionsize.sh with test variations
  for different RAID types and region sizes

Resolves: rhbz1392947
---
 WHATS_NEW                               |    1 +
 lib/metadata/raid_manip.c               |  105 +++++++++++++++++++++++++++++++
 test/shell/lvconvert-raid-regionsize.sh |   90 ++++++++++++++++++++++++++
 tools/lvconvert.c                       |    4 +-
 4 files changed, 198 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cbe6c05..c6994ca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support region size changes on existing RaidLVs
   Avoid parallel usage of cpg_mcast_joined() in clvmd with corosync.
   Support raid6_{ls,rs,la,ra}_6 segment types and conversions from/to it.
   Support raid6_n_6 segment type and conversions from/to it.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 736e2ee..9b9f5f3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -746,6 +746,27 @@ static int _alloc_image_components(struct logical_volume *lv,
 }
 
 /*
+ * HM Helper:
+ *
+ * Calculate absolute amount of metadata device extents based
+ * on @rimage_extents, @region_size and @extent_size.
+ */
+static uint32_t _raid_rmeta_extents(struct cmd_context *cmd, uint32_t rimage_extents,
+				    uint32_t region_size, uint32_t extent_size)
+{
+	uint64_t bytes, regions, sectors;
+
+	region_size = region_size ?: get_default_region_size(cmd);
+	regions = (uint64_t) rimage_extents * extent_size / region_size;
+
+	/* raid and bitmap superblocks + region bytes */
+	bytes = 2 * 4096 + dm_div_up(regions, 8);
+	sectors = dm_div_up(bytes, 512);
+
+	return dm_div_up(sectors, extent_size);
+}
+
+/*
  * _alloc_rmeta_for_lv
  * @lv
  *
@@ -3847,6 +3868,86 @@ replaced:
 	return 1;
 }
 
+/*
+ * HM Helper:
+ *
+ * Change region size on raid @lv to @region_size if
+ * different from current region_size and adjusted region size
+ */
+static int _region_size_change_requested(struct logical_volume *lv, int yes, uint32_t region_size)
+{
+	uint32_t old_region_size;
+	const char *seg_region_size_str;
+	struct lv_segment *seg = first_seg(lv);
+
+	/* Caller should ensure this */
+	if (!region_size)
+		return_0;
+
+	/* CLI validation prvides the check but be caucious... */
+	if (seg_is_any_raid0(seg))
+		return_0;
+
+	if (region_size == seg->region_size) {
+		log_warn("Region size wouldn't change on %s LV %s.",
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	if (region_size * 8 > lv->size) {
+		log_error("Requested region size too large for LV %s size %s.",
+			  display_lvname(lv), display_size(lv->vg->cmd, lv->size));
+		return 0;
+	}
+
+	if (region_size < seg->stripe_size) {
+		log_error("Region size for LV %s is smaller than stripe size.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to change region size on %s LV %s while it is not in-sync.",
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	old_region_size = seg->region_size;
+	seg->region_size = region_size;
+	seg_region_size_str = display_size(lv->vg->cmd, seg->region_size);
+	_check_and_adjust_region_size(lv);
+
+	if (seg->region_size == old_region_size) {
+		log_warn("Region size on %s did not change due to adjustment.",
+			 display_lvname(lv));
+		return 1;
+	}
+
+	if (!yes && yes_no_prompt("Do you really want to change the region_size %s of LV %s to %s? [y/n]: ",
+				  display_size(lv->vg->cmd, old_region_size),
+				  display_lvname(lv), seg_region_size_str) == 'n') {
+		log_error("Logical volume %s NOT converted", display_lvname(lv));
+		return 0;
+	}
+	if (sigint_caught())
+		return_0;
+
+	/* Check for new region size causing bitmap to still fit metadata image LV */
+	if (seg->meta_areas && seg_metatype(seg, 0) == AREA_LV && seg_metalv(seg, 0)->le_count <
+	    _raid_rmeta_extents(lv->vg->cmd, lv->le_count, seg->region_size, lv->vg->extent_size)) {
+		log_error("Region size %s on %s is too small for metadata LV size.",
+			  seg_region_size_str, display_lvname(lv));
+		return 0;
+	}
+
+	if (!lv_update_and_reload_origin(lv))
+		return_0;
+
+	log_warn("Changed region size on RAID LV %s to %s.",
+		 display_lvname(lv), seg_region_size_str);
+	return 1;
+}
+
 /* Check allowed conversion from seg_from to *segtype_to */
 static int _conversion_options_allowed(const struct lv_segment *seg_from,
 				       const struct segment_type **segtype_to,
@@ -3923,6 +4024,10 @@ int lv_raid_convert(struct logical_volume *lv,
 	if (segtype_is_raid(new_segtype) && !_check_max_raid_devices(new_image_count))
 		return_0;
 
+	/* Change RAID region size */
+	if (new_region_size && new_region_size != seg->region_size)
+		return _region_size_change_requested(lv, yes, new_region_size);
+
 	/*
 	 * Check acceptible options mirrors, region_size,
 	 * stripes and/or stripe_size have been provided.
diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
new file mode 100644
index 0000000..4f0e90d
--- /dev/null
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -0,0 +1,90 @@
+#!/bin/sh
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
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
+aux have_raid 1 9 0 || skip
+
+aux prepare_vg 6
+
+function _test_regionsize
+{
+	local type=$1
+	local regionsize=$2
+	local regionsize_str=$3
+	local vg=$4
+	local lv=$5
+
+	lvconvert --type $type --yes -R $regionsize $vg/$lv
+	[ $? -ne 0 ] && return 1
+	check lv_field $vg/$lv regionsize "$regionsize_str"
+	fsck -fn  /dev/mapper/$vg-$lv
+}
+
+function _test_regionsizes
+{
+	# FIXME: have to provide raid type or region size ain't set until cli validation merged
+	local type=$1
+
+	# Test RAID regionsize changes
+	_test_regionsize $type 128K "128.00k" $vg $lv1
+	_test_regionsize $type 256K "256.00k" $vg $lv1
+	not _test_regionsize $type 1K "1.00k" $vg $lv1
+	_test_regionsize $type 1m "1.00m" $vg $lv1
+	not _test_regionsize $type 1G "1.00g" $vg $lv1
+	not _test_regionsize $type 16K "16.00k" $vg $lv1
+}
+
+# Create 3-way raid1
+lvcreate --yes -aey --type raid1 -m 2 -R64K -L 64M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "raid1"
+check lv_field $vg/$lv1 stripes 3
+check lv_field $vg/$lv1 regionsize "64.00k"
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+_test_regionsizes raid1
+
+# Clean up
+lvremove --yes $vg
+
+# Create 5-way raid6
+lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L 64M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "raid6"
+check lv_field $vg/$lv1 stripes 5
+check lv_field $vg/$lv1 stripesize "128.00k"
+check lv_field $vg/$lv1 regionsize "256.00k"
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+_test_regionsizes raid6
+
+# Clean up
+lvremove --yes $vg
+
+# Create 6-way raid01
+lvcreate --yes -aey --type raid10 -i 3 -m 1 --stripesize 128K -R 256K -L 64M -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "raid10"
+check lv_field $vg/$lv1 stripes 6
+check lv_field $vg/$lv1 stripesize "128.00k"
+check lv_field $vg/$lv1 regionsize "256.00k"
+echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+_test_regionsizes raid10
+
+vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ba8396f..32e04d6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2012,13 +2012,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!lp->repair && !lp->replace && (!*lp->type_str || seg->segtype == lp->segtype)) {
+	} else if (!lp->repair && !lp->replace && !arg_is_set(cmd, regionsize_ARG) && (!*lp->type_str || seg->segtype == lp->segtype)) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
-	    (lp->type_str && lp->type_str[0])) {
+	    ((lp->type_str && lp->type_str[0]) || arg_is_set(cmd, regionsize_ARG))) {
 		/* Activation is required later which precludes existing supported raid0 segment */
 		if ((seg_is_any_raid0(seg) || segtype_is_any_raid0(lp->segtype)) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID0)) {


