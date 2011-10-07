From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 7 Oct 2011 14:52:28 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c lib ...
Message-ID: <20111007145228.20377.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-07 14:52:27

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c segtype.h 
	test           : t-lvconvert-raid.sh 
	tools          : commands.h lvconvert.c 

Log message:
	Add the ability to convert linear LVs to RAID1
	
	Example:
	~> lvconvert --type raid1 -m 1 vg/lv
	
	The following steps are performed to convert linear to RAID1:
	1) Allocate a metadata device from the same PV as the linear device
	to provide the metadata/data LV pair required for all RAID components.
	2) Allocate the required number of metadata/data LV pairs for the
	remaining additional images.
	3) Clear the metadata LVs.  This performs a LVM metadata update.
	4) Create the top-level RAID LV and add the component devices.
	
	We want to make any failure easy to unwind.  This is why we don't create the
	top-level LV and add the components until the last step.  Should anything
	happen before that, the user could simply remove the unnecessary images.  Also,
	we want to ensure that the metadata LVs are cleared before forming the array to
	prevent stale information from polluting the new array.
	
	A new macro 'seg_is_linear' was added to allow us to distinguish linear LVs
	from striped LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2150&r2=1.2151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173

--- LVM2/WHATS_NEW	2011/10/06 15:32:26	1.2150
+++ LVM2/WHATS_NEW	2011/10/07 14:52:26	1.2151
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add ability to convert from linear to RAID1.
   Add ability to extend mirrors with '--nosync' option.
   Fix splitmirror in cluster having different DM/LVM views of storage.
   Fix improper udev settings during suspend/resume for mirror sub-LVs.
--- LVM2/lib/metadata/raid_manip.c	2011/09/22 15:33:21	1.15
+++ LVM2/lib/metadata/raid_manip.c	2011/10/07 14:52:27	1.16
@@ -24,6 +24,8 @@
 #include "str_list.h"
 #include "memlock.h"
 
+#define RAID_REGION_SIZE 1024
+
 uint32_t lv_raid_image_count(const struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
@@ -125,6 +127,45 @@
 	return 0;
 }
 
+static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
+{
+	uint32_t s;
+	struct pv_list *pvl;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_linear(seg)) {
+		log_error(INTERNAL_ERROR
+			  "_get_pv_list_for_lv only handles linear volumes");
+		return 0;
+	}
+
+	log_debug("Getting list of PVs that %s/%s is on:",
+		  lv->vg->name, lv->name);
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV) {
+				log_error(INTERNAL_ERROR
+					  "Linear seg_type should be AREA_PV");
+				return 0;
+			}
+
+			if (!(pvl = dm_pool_zalloc(lv->vg->cmd->mem,
+						   sizeof(*pvl)))) {
+				log_error("Failed to allocate memory");
+				return 0;
+			}
+
+			pvl->pv = seg_pv(seg, s);
+			log_debug("  %s/%s is on %s", lv->vg->name, lv->name,
+				  pv_dev_name(pvl->pv));
+			dm_list_add(pvs, &pvl->list);
+		}
+	}
+
+	return 1;
+}
+
 static int _raid_in_sync(struct logical_volume *lv)
 {
 	percent_t sync_percent;
@@ -411,7 +452,9 @@
 				   struct dm_list *new_data_lvs)
 {
 	uint32_t s;
+	uint32_t region_size;
 	struct lv_segment *seg = first_seg(lv);
+	const struct segment_type *segtype;
 	struct alloc_handle *ah;
 	struct dm_list *parallel_areas;
 	struct logical_volume *tmp_lv;
@@ -425,8 +468,18 @@
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
 		return_0;
 
-	if (!(ah = allocate_extents(lv->vg, NULL, seg->segtype, 0, count, count,
-				    seg->region_size, lv->le_count, pvs,
+	if (seg_is_linear(seg))
+		region_size = RAID_REGION_SIZE;
+	else
+		region_size = seg->region_size;
+
+	if (seg_is_raid(seg))
+		segtype = seg->segtype;
+	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
+		return_0;
+
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
+				    region_size, lv->le_count, pvs,
 				    lv->alloc, parallel_areas)))
 		return_0;
 
@@ -452,12 +505,60 @@
 	return 1;
 }
 
+/*
+ * _alloc_rmeta_for_lv
+ * @lv
+ *
+ * Allocate a RAID metadata device for the given LV (which is or will
+ * be the associated RAID data device).  The new metadata device must
+ * be allocated from the same PV(s) as the data device.
+ */
+static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
+			       struct logical_volume **meta_lv)
+{
+	struct dm_list allocatable_pvs;
+	struct alloc_handle *ah;
+	struct lv_segment *seg = first_seg(data_lv);
+
+	dm_list_init(&allocatable_pvs);
+
+	if (!seg_is_linear(seg)) {
+		log_error(INTERNAL_ERROR "Unable to allocate RAID metadata "
+			  "area for non-linear LV, %s", data_lv->name);
+		return 0;
+	}
+
+	if (strstr("_mimage_", data_lv->name)) {
+		log_error("Unable to alloc metadata device for mirror device");
+		return 0;
+	}
+
+	if (!_get_pv_list_for_lv(data_lv, &allocatable_pvs)) {
+		log_error("Failed to build list of PVs for %s/%s",
+			  data_lv->vg->name, data_lv->name);
+		return 0;
+	}
+
+	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
+				    seg->region_size,
+				    1 /*RAID_METADATA_AREA_LEN*/,
+				    &allocatable_pvs, data_lv->alloc, NULL)))
+		return_0;
+
+	if (!_alloc_image_component(data_lv, ah, 0, RAID_META, meta_lv))
+		return_0;
+
+	alloc_destroy(ah);
+	return 1;
+}
+
 static int _raid_add_images(struct logical_volume *lv,
 			    uint32_t new_count, struct dm_list *pvs)
 {
 	uint32_t s;
 	uint32_t old_count = lv_raid_image_count(lv);
 	uint32_t count = new_count - old_count;
+	uint64_t status_mask = -1;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list meta_lvs, data_lvs;
@@ -467,7 +568,24 @@
 	dm_list_init(&meta_lvs); /* For image addition */
 	dm_list_init(&data_lvs); /* For image addition */
 
-	if (!seg_is_raid(seg)) {
+	/*
+	 * If the segtype is linear, then we must allocate a metadata
+	 * LV to accompany it.
+	 */
+	if (seg_is_linear(seg)) {
+		/* A complete resync will be done, no need to mark each sub-lv */
+		status_mask = ~(LV_NOTSYNCED);
+
+		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
+			log_error("Memory allocation failed");
+			return 0;
+		}
+
+		if (!_alloc_rmeta_for_lv(lv, &lvl->lv))
+			return_0;
+
+		dm_list_add(&meta_lvs, &lvl->list);
+	} else if (!seg_is_raid(seg)) {
 		log_error("Unable to add RAID images to %s of segment type %s",
 			  lv->name, seg->segtype->name);
 		return 0;
@@ -478,10 +596,52 @@
 		return 0;
 	}
 
+	/*
+	 * If linear, we must correct data LV names.  They are off-by-one
+	 * because the linear volume hasn't taken its proper name of "_rimage_0"
+	 * yet.  This action must be done before '_clear_lvs' because it
+	 * commits the LVM metadata before clearing the LVs.
+	 */
+	if (seg_is_linear(seg)) {
+		char *name;
+		size_t len;
+		struct dm_list *l;
+		struct lv_list *lvl_tmp;
+
+		dm_list_iterate(l, &data_lvs) {
+			if (l == dm_list_last(&data_lvs)) {
+				lvl = dm_list_item(l, struct lv_list);
+				len = strlen(lv->name) + strlen("_rimage_XXX");
+				name = dm_pool_alloc(lv->vg->vgmem, len);
+				sprintf(name, "%s_rimage_%u", lv->name, count);
+				lvl->lv->name = name;
+				continue;
+			}
+			lvl = dm_list_item(l, struct lv_list);
+			lvl_tmp = dm_list_item(l->n, struct lv_list);
+			lvl->lv->name = lvl_tmp->lv->name;
+		}
+	}
+
 	/* Metadata LVs must be cleared before being added to the array */
 	if (!_clear_lvs(&meta_lvs))
 		goto fail;
 
+	if (seg_is_linear(seg)) {
+		first_seg(lv)->status |= RAID_IMAGE;
+		if (!insert_layer_for_lv(lv->vg->cmd, lv,
+					 RAID | LVM_READ | LVM_WRITE,
+					 "_rimage_0"))
+			return_0;
+
+		lv->status |= RAID;
+		seg = first_seg(lv);
+		seg_lv(seg, 0)->status |= RAID_IMAGE | LVM_READ | LVM_WRITE;
+		seg->region_size = RAID_REGION_SIZE;
+		seg->segtype = get_segtype_from_string(lv->vg->cmd, "raid1");
+		if (!seg->segtype)
+			return_0;
+	}
 /*
 FIXME: It would be proper to activate the new LVs here, instead of having
 them activated by the suspend.  However, this causes residual device nodes
@@ -504,16 +664,21 @@
 	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
 					 new_count * sizeof(*new_areas))))
 		goto fail;
-	memcpy(new_areas, seg->meta_areas,
-	       seg->area_count * sizeof(*seg->meta_areas));
+	if (seg->meta_areas)
+		memcpy(new_areas, seg->meta_areas,
+		       seg->area_count * sizeof(*seg->meta_areas));
 	seg->meta_areas = new_areas;
 	seg->area_count = new_count;
 
+	/* Add extra meta area when converting from linear */
+	s = (old_count == 1) ? 0 : old_count;
+
 	/* Set segment areas for metadata sub_lvs */
-	s = old_count;
 	dm_list_iterate_items(lvl, &meta_lvs) {
 		log_debug("Adding %s to %s",
 			  lvl->lv->name, lv->name);
+		lvl->lv->status &= status_mask;
+		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
 			log_error("Failed to add %s to %s",
@@ -523,11 +688,14 @@
 		s++;
 	}
 
-	/* Set segment areas for data sub_lvs */
 	s = old_count;
+
+	/* Set segment areas for data sub_lvs */
 	dm_list_iterate_items(lvl, &data_lvs) {
 		log_debug("Adding %s to %s",
 			  lvl->lv->name, lv->name);
+		lvl->lv->status &= status_mask;
+		first_seg(lvl->lv)->status &= status_mask;
 		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
 					    lvl->lv->status)) {
 			log_error("Failed to add %s to %s",
@@ -810,12 +978,6 @@
 			       uint32_t new_count, struct dm_list *pvs)
 {
 	uint32_t old_count = lv_raid_image_count(lv);
-	struct lv_segment *seg = first_seg(lv);
-
-	if (!seg_is_mirrored(seg)) {
-		log_error("Unable to change image count of non-mirrored RAID.");
-		return 0;
-	}
 
 	if (old_count == new_count) {
 		log_error("%s/%s already has image count of %d",
--- LVM2/lib/metadata/segtype.h	2011/08/30 14:55:17	1.42
+++ LVM2/lib/metadata/segtype.h	2011/10/07 14:52:27	1.43
@@ -47,6 +47,7 @@
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
+#define     seg_is_linear(seg)  (seg_is_striped(seg) && !(seg)->stripe_size)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
--- LVM2/test/t-lvconvert-raid.sh	2011/08/18 19:56:17	1.1
+++ LVM2/test/t-lvconvert-raid.sh	2011/10/07 14:52:27	1.2
@@ -34,6 +34,11 @@
 		return 1
 	fi
 
+	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
+		echo "$dm_name in-sync, but 'a' characters in health status"
+		exit 1
+	fi
+
 	echo "$dm_name (${a[3]}) is in-sync"
 	return 0
 }
@@ -81,7 +86,7 @@
 ###########################################
 # RAID1 convert tests
 ###########################################
-for i in 2 3 4; do
+for i in 1 2 3 4; do
 	for j in 1 2 3 4; do
 		if [ $i -eq 1 ]; then
 			from="linear"
@@ -94,8 +99,15 @@
 			to="$j-way"
 		fi
 		echo "Converting from $from to $to"
-		lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
-		wait_for_raid_sync $vg/$lv1
+		if [ $i -eq 1 ]; then
+			# Shouldn't be able to create with just 1 image
+			not lvcreate --type raid1 -m 0 -l 2 -n $lv1 $vg
+
+			lvcreate -l 2 -n $lv1 $vg
+		else
+			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
+			wait_for_raid_sync $vg/$lv1
+		fi
 		lvconvert -m $((j - 1))  $vg/$lv1
 
 		# FIXME: ensure no residual devices
@@ -135,12 +147,10 @@
 # 3-way to linear/2-way
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
 wait_for_raid_sync $vg/$lv1
-
 # FIXME: Can't split off a mirror from a mirror yet
-#lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
+should lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
 #check linear $vg $lv1
 #check lv_exists $vg $lv2
-
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 
--- LVM2/tools/commands.h	2011/10/06 15:32:27	1.163
+++ LVM2/tools/commands.h	2011/10/07 14:52:27	1.164
@@ -98,6 +98,7 @@
    0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
+   "\t[--type SegmentType]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -141,7 +142,7 @@
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
    regionsize_ARG, repair_ARG, snapshot_ARG, splitmirrors_ARG, trackchanges_ARG,
-   stripes_long_ARG, stripesize_ARG, test_ARG,
+   type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
--- LVM2/tools/lvconvert.c	2011/09/06 18:49:32	1.172
+++ LVM2/tools/lvconvert.c	2011/10/07 14:52:27	1.173
@@ -304,7 +304,8 @@
 			return 0;
 		}
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "mirror")))
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "mirror"));
+		if (!lp->segtype)
 			return_0;
 	}
 
@@ -1393,7 +1394,7 @@
 	if (!segtype_is_raid(from_segtype) && !segtype_is_raid(to_segtype))
 		return_0;  /* Not converting to or from RAID? */
 
-	return 0;
+	return 1;
 }
 
 static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
@@ -1405,7 +1406,9 @@
 	if (!arg_count(cmd, type_ARG))
 		lp->segtype = seg->segtype;
 
-	if (arg_count(cmd, mirrors_ARG) && !seg_is_mirrored(seg)) {
+	/* Can only change image count for raid1 and linear */
+	if (arg_count(cmd, mirrors_ARG) &&
+	    !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",
 			  seg->segtype->name);
 		return 0;


