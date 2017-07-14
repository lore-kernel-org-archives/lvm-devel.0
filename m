From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 14 Jul 2017 09:53:45 -0400
Subject: master - raid: fix allocation/activation of reshape space
Message-ID: <201707141353.v6EDrj2V025104@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1b78665ef181ccd630209243b74df0627322a35
Commit:        f1b78665ef181ccd630209243b74df0627322a35
Parent:        cd4e6c9b1780672f1a68f85123e0e9a1cc39ddca
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 13 18:26:43 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 14 15:53:23 2017 +0200

raid: fix allocation/activation of reshape space

When reshape space is allocated anew, an update and reload is needed to
promote the new size to the cluster node with the exclusively active RaidLV
or reloading the RaidLV will fail with a size related error.  Additionally,
store "data_offset <sectors>" with the RaidLV in the lvm2 metadata so that
it can be retrieved on cluster nodes.

Process allocation of reshape space on a 2-legged raid4/5 (interim layout
to convert from/to linear via raid1) properly in the cluster.

Resolves: rhbz1461562
Resolves: rhbz1448116
---
 lib/metadata/raid_manip.c |  128 ++++++++++++++++++++++++++++++++++++++-------
 lib/raid/raid.c           |    9 +++-
 2 files changed, 116 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a22b529..1966bb8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1529,8 +1529,29 @@ static int _lv_relocate_reshape_space(struct logical_volume *lv, enum alloc_wher
  * and adjust the rest to remove the reshape space.
  * If it's at the end, just lv_reduce() and set seg->reshape_len to 0.
  *
- * Does not write metadata!
+ * Writes metadata in case of new allocation!
  */
+/* HM Helper: reset @lv to @segtype, @stripe_size and @lv_size post lv_extend() when changed for area_count < 3. */
+static int _lv_alloc_reshape_post_extend(struct logical_volume *lv,
+					 const struct segment_type *segtype,
+					 uint32_t stripe_size, uint64_t lv_size)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg->area_count < 3) {
+		/* Reset segment type, stripe and lv size */
+		seg->segtype = segtype;
+		seg->stripe_size = stripe_size;
+		lv->size = lv_size;
+
+		/* Update and reload mapping for proper size of data SubLVs in the cluster */
+		if (!lv_update_and_reload(lv))
+			return_0;
+	}
+
+	return 1;
+}
+
 static int _lv_alloc_reshape_space(struct logical_volume *lv,
 				   enum alloc_where where,
 				   enum alloc_where *where_it_was,
@@ -1538,6 +1559,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 {
 	uint32_t out_of_place_les_per_disk;
 	uint64_t data_offset;
+	uint64_t lv_size_cur = lv->size;
 	struct lv_segment *seg = first_seg(lv);
 
 	if (!seg->stripe_size)
@@ -1553,7 +1575,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 		return 0;
 	}
 
-	/* Get data_offset and dev_sectors from the kernel */
+	/* Get data_offset from the kernel */
 	if (!lv_raid_data_offset(lv, &data_offset)) {
 		log_error("Can't get data offset for %s from kernel.",
 			  display_lvname(lv));
@@ -1587,24 +1609,50 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 	 * size as before including the reshape space
 	 */
 	if (out_of_place_les_per_disk) {
+		const struct segment_type *segtype = seg->segtype, *segtype_sav = segtype;
 		uint32_t data_rimages = _data_rimages_count(seg, seg->area_count);
+		uint32_t mirrors = 1;
 		uint32_t reshape_len = out_of_place_les_per_disk * data_rimages;
+		uint32_t stripe_size = seg->stripe_size, stripe_size_sav = stripe_size;
 		uint32_t prev_rimage_len = _lv_total_rimage_len(lv);
-		uint64_t lv_size_cur = lv->size;
 
-		if (!lv_extend(lv, seg->segtype, data_rimages,
-			       seg->stripe_size, 1, /* seg_is_any_raid10(seg) ? seg->data_copies : 1, */ seg->region_size,
-			       reshape_len /* # of reshape LEs to add */,
+		/* Special case needed to add reshape space for raid4/5 with 2 total stripes */
+		if (seg->area_count < 3) {
+			if ((mirrors = seg->area_count) < 2)
+				return_0;
+			if (!seg_is_raid4(seg) &&
+			    !seg_is_any_raid5(seg))
+				return_0;
+			if (!(segtype = seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
+				return_0;
+			reshape_len = out_of_place_les_per_disk;
+			stripe_size = seg->stripe_size = 0;
+			data_rimages = 1;
+
+			/* Temporarily convert to raid1 for proper extensions of data SubLVs. */
+			if (!lv_update_and_reload(lv))
+				return_0;
+		}
+
+		if (!lv_extend(lv, segtype, data_rimages, stripe_size,
+			       mirrors, /* seg_is_any_raid10(seg) ? seg->data_copies : mirrors, */
+			       seg->region_size, reshape_len /* # of reshape LEs to add */,
 			       allocate_pvs, lv->alloc, 0)) {
 			log_error("Failed to allocate out-of-place reshape space for %s.",
 				  display_lvname(lv));
-			return 0;
+			return _lv_alloc_reshape_post_extend(lv, segtype_sav, stripe_size_sav, lv_size_cur);
 		}
 
-		lv->size = lv_size_cur;
 		/* pay attention to lv_extend maybe having allocated more because of layout specific rounding */
 		if (!_lv_set_reshape_len(lv, _lv_total_rimage_len(lv) - prev_rimage_len))
 			return_0;
+
+		if (!_lv_alloc_reshape_post_extend(lv, segtype_sav, stripe_size_sav, lv_size_cur))
+			return 0;
+
+		/* Update and reload mapping for proper size of data SubLVs in the cluster */
+		if (!lv_update_and_reload(lv))
+			return_0;
 	}
 
 	/* Preset data offset in case we fail relocating reshape space below */
@@ -1674,14 +1722,6 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 		 */
 		if (!_lv_alloc_reshape_space(lv, alloc_end, &where, NULL))
 			return_0;
-		seg->extents_copied = first_seg(lv)->area_len;
-		if (!lv_reduce(lv, total_reshape_len))
-			return_0;
-
-		seg->extents_copied = first_seg(lv)->area_len;
-
-		if (!_lv_set_reshape_len(lv, 0))
-			return_0;
 
 		/*
 		 * Only in case reshape space was freed at the beginning,
@@ -1693,6 +1733,19 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 		 */
 		seg->data_offset = (where == alloc_begin) ? 1 : 0;
 
+		if (seg->data_offset &&
+		    !lv_update_and_reload(lv))
+			return_0;
+
+		seg->extents_copied = first_seg(lv)->area_len;
+		if (!lv_reduce(lv, total_reshape_len))
+			return_0;
+
+		seg->extents_copied = first_seg(lv)->area_len;
+
+		if (!_lv_set_reshape_len(lv, 0))
+			return_0;
+
 	} else if (where_it_was)
 		*where_it_was = alloc_none;
 
@@ -1882,6 +1935,19 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 		return 0;
 	}
 
+	/*
+	 * https://bugzilla.redhat.com/1447812
+	 * https://bugzilla.redhat.com/1448116
+	 *
+	 * Preallocate out of place reshape space at the end of all data image LVs
+	 * and reload _before_ potentially switching that space to the begin.
+	 */
+	if (!_reshape_len_per_lv(lv)) {
+		log_debug_metadata("Allocating reshape space for %s.", display_lvname(lv));
+		if (!_lv_alloc_reshape_space(lv, alloc_end, NULL, allocate_pvs))
+			return 0;
+	}
+
 	/* Allocate forward out of place reshape space at the beginning of all data image LVs */
 	log_debug_metadata("(Re)allocating reshape space for %s.", display_lvname(lv));
 	if (!_lv_alloc_reshape_space(lv, alloc_begin, NULL, allocate_pvs))
@@ -2073,7 +2139,6 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 				     struct dm_list *allocate_pvs)
 {
 	int alloc_reshape_space = 1;
-	enum alloc_where where = alloc_anywhere;
 	struct lv_segment *seg = first_seg(lv);
 
 	if (seg->segtype != new_segtype)
@@ -2113,9 +2178,31 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 	if (seg->area_count == 2)
 		alloc_reshape_space = 0;
 
-	if (alloc_reshape_space &&
-	    !_lv_alloc_reshape_space(lv, where, NULL, allocate_pvs))
-		return_0;
+	if (alloc_reshape_space) {
+		enum alloc_where where;
+		const char *what;
+
+		/*
+		 * https://bugzilla.redhat.com/1447812
+		 * https://bugzilla.redhat.com/1448116
+		 *
+		 * Preallocate out of place reshape space at the end of all data image LVs
+		 * and reload _before_ potentially switching that space to the begin.
+		 */
+		if (_reshape_len_per_lv(lv)) {
+			what = "Rea";
+			where = alloc_anywhere;
+
+		} else {
+			what = "A";
+			where = alloc_end;
+		}
+
+		log_debug_metadata("%sllocating reshape space for %s.", what, display_lvname(lv));
+		if (!_lv_alloc_reshape_space(lv, where, NULL, allocate_pvs))
+			return_0;
+	}
+
 
 	seg->segtype = new_segtype;
 
@@ -2350,6 +2437,7 @@ static int _raid_reshape(struct logical_volume *lv,
 					lvseg_name(seg), display_lvname(lv),
 					display_size(lv->vg->cmd, new_stripe_size));
 
+	/* raid4/5 with N image component pairs (i.e. N-1 stripes): allow for raid4/5 reshape to 2 devices, i.e. raid1 layout */
 	/* Handle disk addition reshaping */
 	if (old_image_count < new_image_count) {
 		if (!_raid_reshape_add_images(lv, new_segtype, yes,
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index c5cfb0f..b9f9161 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -141,13 +141,15 @@ static int _raid_text_import(struct lv_segment *seg,
 		{ "writebehind",	&seg->writebehind },
 		{ "min_recovery_rate",	&seg->min_recovery_rate },
 		{ "max_recovery_rate",	&seg->max_recovery_rate },
+		{ "data_offset",	&seg->data_offset },
 	}, *aip = raid_attr_import;
 	unsigned i;
 
 	for (i = 0; i < DM_ARRAY_SIZE(raid_attr_import); i++, aip++) {
 		if (dm_config_has_node(sn, aip->name)) {
 			if (!dm_config_get_uint32(sn, aip->name, aip->var)) {
-				if (!strcmp(aip->name, "data_copies")) {
+				if (!strcmp(aip->name, "data_copies") ||
+				    !strcmp(aip->name, "data_offset")) {
 					*aip->var = 0;
 					continue;
 				}
@@ -155,6 +157,9 @@ static int _raid_text_import(struct lv_segment *seg,
 					  aip->name, dm_config_parent_name(sn), seg->lv->name);
 				return 0;
 			}
+
+			if (!strcmp(aip->name, "data_offset") && !*aip->var)
+				*aip->var = 1;
 		}
 	}
 
@@ -215,6 +220,8 @@ static int _raid_text_export_raid(const struct lv_segment *seg, struct formatter
 			outf(f, "min_recovery_rate = %" PRIu32, seg->min_recovery_rate);
 		if (seg->max_recovery_rate)
 			outf(f, "max_recovery_rate = %" PRIu32, seg->max_recovery_rate);
+		if (seg->data_offset)
+			outf(f, "data_offset = %" PRIu32, seg->data_offset == 1 ? 0 : seg->data_offset);
 	}
 
 	return out_areas(f, seg, "raid");


