From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:28 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - bz1168959: v2 fix replaced rimage allocation
Message-ID: <20150131141028.989F760EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8e0b7b75afd379b69bc9efb0b2767b5a139a132
Commit:        f8e0b7b75afd379b69bc9efb0b2767b5a139a132
Parent:        df53bd845aeeedee83776a6fe63ce704d788f8f2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jan 16 13:05:12 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jan 16 13:05:12 2015 +0100

bz1168959: v2 fix replaced rimage allocation

---
 lib/metadata/metadata-exported.h |    6 +-
 lib/metadata/pv_map.c            |    5 +-
 lib/metadata/raid_manip.c        |  284 +++++++++++++++++++++++++-------------
 lib/metadata/segtype.h           |    2 +
 4 files changed, 202 insertions(+), 95 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0fe83bf..a48f31b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -122,7 +122,11 @@
 #define LV_RESHAPE_DELTA_DISKS_PLUS		UINT64_C(0x0008000000000000)    /* LV reshape flag delta disks plus image(s) */
 #define LV_RESHAPE_DELTA_DISKS_MINUS		UINT64_C(0x0010000000000000)    /* LV reshape flag delta disks minus image(s) */
 
-/* Next unused flag:		UINT64_C(0x0020000000000000)    */
+#define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0020000000000000)	/* PV - internal use only - allocation prohibited
+									e.g. to prohibit allocation of a RAID image
+									on a PV already holing an image of the RAID set */
+
+/* Next unused flag:		UINT64_C(0x0040000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/pv_map.c b/lib/metadata/pv_map.c
index 4423a7d..db9f84e 100644
--- a/lib/metadata/pv_map.c
+++ b/lib/metadata/pv_map.c
@@ -133,8 +133,11 @@ static int _create_maps(struct dm_pool *mem, struct dm_list *pvs, struct dm_list
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, pvs) {
-		if (!(pvl->pv->status & ALLOCATABLE_PV))
+		if (!(pvl->pv->status & ALLOCATABLE_PV) ||
+		    (pvl->pv->status & PV_ALLOCATION_PROHIBITED)) {
+			pvl->pv->status &= ~PV_ALLOCATION_PROHIBITED;
 			continue;
+		}
 		if (is_missing_pv(pvl->pv))
 			continue;
 		assert(pvl->pv->dev);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 60f80c6..cf0de89 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1017,26 +1017,32 @@ static int _raid_add_images(struct logical_volume *lv, struct segment_type *segt
 		goto fail;
 
 	/* Reshape adding image component pairs to raid set changing size accordingly */
-	if (!seg_is_raid1(seg) && seg->segtype == segtype) {
-		uint32_t extents = lv->le_count / __data_rimages_count(seg, old_count);
+	if (!seg_is_raid1(seg)) {
+		if (seg->segtype == segtype) {
+			uint32_t extents = lv->le_count / __data_rimages_count(seg, old_count);
 
-		for (s = old_count; s < new_count; s++) {
-			seg_lv(seg, s)->status &= ~LV_REBUILD;
-			seg_lv(seg, s)->status |= LV_RESHAPE_DELTA_DISKS_PLUS;
+			for (s = old_count; s < new_count; s++) {
+				seg_lv(seg, s)->status &= ~LV_REBUILD;
+				seg_lv(seg, s)->status |= LV_RESHAPE_DELTA_DISKS_PLUS;
 
-			lv->le_count += extents;
-			seg->len += extents;
-			seg->area_len += extents;
+				lv->le_count += extents;
+				seg->len += extents;
+				seg->area_len += extents;
+			}
 		}
 	}
 
 #if 1
 	/* HM FIXME: TESTME reshape of a raid5 to add disks after a raid1 -> raid5 takeover */
-	if (seg_is_raid1(seg) && segtype_is_any_raid5(segtype) &&
-	    count == 1 && old_count == 2) {
-		lv->le_count *= 2;
-		seg->len *= 2;
-		seg->area_len *= 2;
+	else if (segtype_is_any_raid5(segtype) &&
+		 count == 1 && old_count == 2) {
+			s = seg->area_count - 1;
+			seg_lv(seg, s)->status &= ~LV_REBUILD;
+			seg_lv(seg, s)->status |= LV_RESHAPE_DELTA_DISKS_PLUS;
+
+			lv->le_count *= 2;
+			seg->len *= 2;
+			seg->area_len *= 2;
 	}
 #endif
 	/* HM FIXME: really needed? */
@@ -2182,7 +2188,7 @@ static int __adjust_segtype_for_takeover(struct logical_volume *lv, struct segme
 	if (is_level_up(seg->segtype, segtype)){
 		/* To raid1 */
 		if (segtype_is_raid1(segtype)) {
-			/* From linear/raid0 */
+			/* From raid0 */
 			if (!seg_is_raid0(seg))
 				return 0;
 
@@ -2209,12 +2215,13 @@ static int __adjust_segtype_for_takeover(struct logical_volume *lv, struct segme
 				segtype_name = SEG_TYPE_NAME_RAID5_N;
 			else if (seg_is_raid1(seg)) {
 				if (seg->area_count != 2) {
-					log_error("raid1 LV %s/%s has to have 2 devices for conversion; use \"lvconvert -m1 %s/%s\"",
+					log_error("raid1 LV %s/%s has to have 2 devices for conversion;"
+						  " use \"lvconvert -m1 %s/%s\"",
 						  lv->vg->name, lv->name, lv->vg->name, lv->name);
 					return 0;
 				}
 
-				segtype_name = SEG_TYPE_NAME_RAID5_LS;
+				segtype_name = SEG_TYPE_NAME_RAID5_N;
 			} else
 				return 0;
 
@@ -2257,8 +2264,6 @@ static int __adjust_segtype_for_takeover(struct logical_volume *lv, struct segme
 			    seg->area_count != 3)
 				return 0;
 
-			// lv->le_count /= 2;
-
 		/* To raid4 */
 		} else if (segtype_is_any_raid4(segtype)) {
 			/* From raid6_0_6 */
@@ -2343,6 +2348,157 @@ static int __convert_reshape(struct logical_volume *lv,
 	return 1;
 }
 
+/* Process one level up takeover on @lv to @segtype allocating fron @allocate_pvs */
+static int __raid_level_up(struct logical_volume *lv,
+			   struct segment_type *segtype,
+			   struct dm_list *allocate_pvs)
+{
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t new_count = seg->area_count + 1;
+
+	/* Make sure to set default region size on takeover from raid0 */
+	__check_and_init_region_size(lv);
+
+	/*
+	 * In case of raid1 -> raid5, takeover will run a degraded 2 disk raid5 set
+	 * which will get an additional disk allocated afterwards and reloaded starting
+	 * resynchronization to reach full redundance.
+	 *
+	 * FIXME: fully redundant raid5_ls set does not double-fold capacity after takeover from raid1 yet!!!
+	 */
+	if (seg_is_raid1(seg)) {
+		seg->segtype = segtype;
+		seg->stripe_size = 64*2;
+
+		/* This causes the raid1 -> raid5 (2 disks) takeover */
+		if (!lv_update_and_reload_origin(lv))
+			return_0;
+
+		/* Leave 2 legged RAID5 as is. Reshape to > 2 legged optional */
+		return 1;
+	}
+
+	/*
+	 * The top-level LV is being reloaded and the VG
+	 * written and committed in the course of this call
+	 */
+	return __lv_raid_change_image_count(lv, segtype, new_count, allocate_pvs);
+}
+
+/* Process one level down takeover on @lv to @segtype */
+static int __raid_level_down(struct logical_volume *lv,
+			    struct segment_type *segtype,
+			    struct dm_list *allocate_pvs)
+{
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t new_count = seg->area_count - 1;
+
+	if (segtype_is_raid1(segtype)) {
+		/* FIXME: delta_disks = -1 mandatory! */
+		/* Reduce image count to 2 first */
+		if (!__lv_raid_change_image_count(lv, NULL, new_count, NULL))
+			return 0;
+
+		seg->segtype = segtype;
+
+		/* This causes the raid5 -> raid1 (2 disks) takeover */
+		if (!lv_update_and_reload_origin(lv))
+			return_0;
+
+		return 1;
+	}
+
+	seg->segtype = segtype;
+
+	/* This causes any !raid1 -> raid takeover */
+	if (!lv_update_and_reload(lv))
+		return_0;
+
+	return __lv_raid_change_image_count(lv, segtype, new_count, NULL);
+}
+
+static struct segment_type *__get_next_up_segtype(struct logical_volume *lv,
+						 const struct segment_type *segtype,
+						 const struct segment_type *new_segtype)
+{
+	const char *segtype_name;
+
+	if (segtype_is_raid0(segtype) ||
+	    segtype_is_raid1(segtype))
+		segtype_name = SEG_TYPE_NAME_RAID5;
+
+	else if (segtype_is_raid4(segtype) ||
+		 segtype_is_any_raid5(segtype))
+		segtype_name = SEG_TYPE_NAME_RAID6;
+
+	else
+		segtype_name = NULL;
+
+	return segtype_name ? get_segtype_from_string(lv->vg->cmd, segtype_name) : NULL;
+}
+
+static struct segment_type *__get_next_down_segtype(struct logical_volume *lv,
+						   const struct segment_type *segtype,
+						   const struct segment_type *new_segtype)
+{
+	const char *segtype_name;
+
+	if (segtype_is_any_raid6(segtype))
+		segtype_name = SEG_TYPE_NAME_RAID5;
+
+	else if (segtype_is_any_raid5(segtype))
+		segtype_name = segtype_is_raid1(new_segtype) ? SEG_TYPE_NAME_RAID1 : SEG_TYPE_NAME_RAID0;
+
+	else
+		segtype_name = NULL;
+
+	return segtype_name ? get_segtype_from_string(lv->vg->cmd, segtype_name) : NULL;
+}
+
+static struct segment_type *__get_next_segtype(struct logical_volume *lv,
+					      const struct segment_type *segtype,
+					      const struct segment_type *new_segtype,
+					      int up)
+{
+	return (up ? __get_next_up_segtype : __get_next_down_segtype)(lv, segtype, new_segtype);
+}
+
+/* Adjust @segtype to takeover compatible one */
+struct possible_takeover {
+	const char *current_name;
+	const char *possible_names[5];
+};
+
+#define	ARRAY_SIZE(a) (sizeof(a) / sizeof(*a))
+static const struct segment_type *__adjust_final_segtype(struct logical_volume *lv,
+							const struct segment_type *segtype,
+							const struct segment_type *new_segtype)
+{
+	unsigned cn, pn;
+	struct possible_takeover pt[] = {
+		{ .current_name = SEG_TYPE_NAME_RAID0,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_N, SEG_TYPE_NAME_RAID6_N_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID1,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_N, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID5_N,
+		  .possible_names = { SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_RAID1,
+				      SEG_TYPE_NAME_STRIPED, SEG_TYPE_NAME_RAID6_N_6, NULL } },
+		{ .current_name = SEG_TYPE_NAME_RAID6_N_6,
+		  .possible_names = { SEG_TYPE_NAME_RAID5_N, SEG_TYPE_NAME_RAID0, SEG_TYPE_NAME_STRIPED, NULL } },
+	};
+
+
+	for (cn = 0; cn < ARRAY_SIZE(pt); cn++) {
+		if (!strcmp(segtype->name, pt[cn].current_name)) {
+			for (pn = 0; pt[cn].possible_names[pn]; pn++)
+				if (!strncmp(new_segtype->name, pt[cn].possible_names[pn], 5))
+					return get_segtype_from_string(lv->vg->cmd, pt[cn].possible_names[pn]);
+		}
+	}
+
+	return NULL;
+}
+
 /*
  * Convert a RAID set to another RAID alogoritm or stripe size
  *
@@ -2354,9 +2510,11 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 				 const unsigned new_stripe_size,
 				 struct dm_list *allocate_pvs)
 {
-	int new_count;
+	int up;
 	struct lv_segment *seg = first_seg(lv);
 	struct segment_type *new_segtype = (struct segment_type *) requested_segtype;
+	struct segment_type *next_segtype;
+	const struct segment_type *final_segtype;
 	unsigned stripes = new_stripes ?: __data_rimages_count(seg, seg->area_count);
 	unsigned stripe_size = new_stripe_size ?: seg->stripe_size;
 
@@ -2404,93 +2562,33 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 
 	}
 
-	/* Takeover (i.e. level switch) requested */
-	if (!__adjust_segtype_for_takeover(lv, &new_segtype))
-		return 0;
-
 	/*
 	 * HM
 	 *
-	 * Up takeover of raid levels
+	 * Up/down takeover of raid levels
 	 *
 	 * In order to takeover the raid set level N to M (M > N) in @lv, all existing
 	 * rimages in that set need to be paired with rmeta devs (if not yet present)
-	 * to store superblocks* and bitmaps of the to be taken over raid4/raid5/raid6
+	 * to store superblocks and bitmaps of the to be taken over raid0/raid1/raid4/raid5/raid6
 	 * set plus another rimage/rmeta pair has to be allocated for dedicated xor/q.
-	 */
-	if (is_level_up(seg->segtype, new_segtype)) {
-		new_count = seg->area_count + 1;
-
-		/* Make sure to set default region size on takeover from raid0 */
-		__check_and_init_region_size(lv);
-
-		/*
-		 * In case of raid1 -> raid5, takeover will run a degraded 2 disk raid5 set
-		 * which will get an additional disk allocated afterwards and reloaded starting
-		 * resynchronization to reach full redundance.
-		 *
-		 * FIXME: fully redundant raid5_ls set does not double-fold capacity after takeover from raid1 yet!!!
-		 */
-		if (seg_is_raid1(seg)) {
-			seg->segtype = new_segtype;
-			seg->stripe_size = 64*2;
-
-			/* This causes the raid1 -> raid5 (2 disks) takeover */
-			if (!lv_update_and_reload_origin(lv))
-				return_0;
-
-		}
-
-		/*
-		 * The top-level LV is being reloaded and the VG
-		 * written and committed in the course of this call
-		 */
-		if (!__lv_raid_change_image_count(lv, new_segtype, new_count, allocate_pvs))
-			return 0;
-
-
-	/*
-	 * HM
-	 *
-	 * Down takeover of raid levels
 	 *
 	 * In order to postprocess the takeover of a raid set from level M to M (M > N)
 	 * in @lv, the last rimage/rmeta devs pair need to be droped in the metadata.
 	 */
-	} else {
-		new_count = seg->area_count - 1;
-
-		if (segtype_is_raid1(new_segtype)) {
-			/* FIXME: delta_disks = -1 mandatory! */
-			/* Reduce image count to 2 first */
-			if (!__lv_raid_change_image_count(lv, NULL, new_count, allocate_pvs))
-				return 0;
-
-			seg->segtype = new_segtype;
-
-			/* This causes the raid5 -> raid1 (2 disks) takeover */
-			if (!lv_update_and_reload_origin(lv))
-				return_0;
-
-			return 1;
-		}
-
-		seg->segtype = new_segtype;
-
-		/* This causes any !raid1 -> raid takeover */
-		if (!lv_update_and_reload(lv))
-			return_0;
-
-		if (!__lv_raid_change_image_count(lv, new_segtype, new_count, allocate_pvs))
+	if (!(final_segtype = __adjust_final_segtype(lv, seg->segtype, new_segtype)))
+		return 0;
+	up = is_level_up(seg->segtype, final_segtype);
+	do {
+		if (!(next_segtype = __get_next_segtype(lv, seg->segtype, final_segtype, up)) ||
+		    !__adjust_segtype_for_takeover(lv, &next_segtype) ||
+		    !__raid_level_up(lv, next_segtype, allocate_pvs))
 			return 0;
-	} 
+	} while (next_segtype != final_segtype);
 
 	return 1;
 }
 /******* END: raid <-> raid conversion *******/
 
-
-
 /*
  * lv_raid_reshape
  * @lv
@@ -2651,19 +2749,19 @@ has_enough_space:
 static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
 {
 	struct dm_list *allocate_pvs = (struct dm_list *) data;
-	struct pv_list *pvl;
+	struct pv_list *pvl, *tmp;
 
-	dm_list_iterate_items(pvl, allocate_pvs)
+	dm_list_iterate_items_safe(pvl, tmp, allocate_pvs)
 		if (!(lv->status & PARTIAL_LV) &&
 		    lv_is_on_pv(lv, pvl->pv))
-			pvl->pv->status &= ~ALLOCATABLE_PV;
+			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
 
 	return 1;
 }
 
 /*
  * Prevent any PVs holding other image components of @lv from being used for allocation,
- * I.e. reset ALLOCATABLE_PV flag on respective PVs listed on @allocatable_pvs
+ * I.e. remove respective PVs from @allocatable_pvs
  */
 static void __avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 509de96..dd60c38 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -156,6 +156,8 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#define SEG_TYPE_NAME_STRIPED		"striped"
+
 #define SEG_TYPE_NAME_RAID0		"raid0"
 #define SEG_TYPE_NAME_RAID1		"raid1"
 #define SEG_TYPE_NAME_RAID10		"raid10"


