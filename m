From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:07 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063207.02AE560AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92691e345d12515d61e6e7748e5b9ddc4eff49c0
Commit:        92691e345d12515d61e6e7748e5b9ddc4eff49c0
Parent:        c1865b0a864e0623b2395c96e7853e4637e46772
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 01:57:04 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- add lv_raid_data_copies returning raid type specific number;
  needed for raid10 with more than 2 data copies
- remove _shift_and_rename_image_components() constraint
  to support more than 10 raid legs
- add function to calculate total rimage length used by out-of-place
  reshape space allocation
- add out-of-place reshape space alloc/relocate/free functions
- move _data_rimages_count() used by reshape space alloc/realocate functions

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/raid_manip.c |  470 ++++++++++++++++++++++++++++++++++++++++++---
 lib/raid/raid.c           |    2 +-
 3 files changed, 443 insertions(+), 31 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f3cad09..b98391b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -957,7 +957,7 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	seg->stripe_size = stripe_size;
 	seg->area_count = area_count;
 	seg->area_len = area_len;
-	seg->data_copies = data_copies ? : 0; // lv_raid_data_copies(segtype, area_count);
+	seg->data_copies = data_copies ? : lv_raid_data_copies(segtype, area_count);
 	seg->chunk_size = chunk_size;
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 70e0a55..b2a5572 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -708,12 +708,11 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
  *
  * Returns: 1 on success, 0 on failure
  */
+static char *_generate_raid_name(struct logical_volume *lv,
+				 const char *suffix, int count);
 static int _shift_and_rename_image_components(struct lv_segment *seg)
 {
-	int len;
-	char *shift_name;
 	uint32_t s, missing;
-	struct cmd_context *cmd = seg->lv->vg->cmd;
 
 	/*
 	 * All LVs must be properly named for their index before
@@ -724,21 +723,12 @@ static int _shift_and_rename_image_components(struct lv_segment *seg)
 	if (!seg_is_raid(seg))
 		return_0;
 
-	if (seg->area_count > 10) {
-		/*
-		 * FIXME: Handling more would mean I'd have
-		 * to handle double digits
-		 */
-		log_error("Unable handle arrays with more than 10 devices.");
-		return 0;
-	}
-
 	log_very_verbose("Shifting images in %s.", display_lvname(seg->lv));
 
 	for (s = 0, missing = 0; s < seg->area_count; s++) {
 		if (seg_type(seg, s) == AREA_UNASSIGNED) {
 			if (seg_metatype(seg, s) != AREA_UNASSIGNED) {
-				log_error(INTERNAL_ERROR "Metadata segment area"
+				log_error(INTERNAL_ERROR "Metadata segment area."
 					  " #%d should be AREA_UNASSIGNED.", s);
 				return 0;
 			}
@@ -753,24 +743,16 @@ static int _shift_and_rename_image_components(struct lv_segment *seg)
 				 display_lvname(seg_lv(seg, s)), missing);
 
 		/* Alter rmeta name */
-		shift_name = dm_pool_strdup(cmd->mem, seg_metalv(seg, s)->name);
-		if (!shift_name) {
+		if (!(seg_metalv(seg, s)->name = _generate_raid_name(seg->lv, "rmeta", s - missing))) {
 			log_error("Memory allocation failed.");
 			return 0;
 		}
-		len = strlen(shift_name) - 1;
-		shift_name[len] -= missing;
-		seg_metalv(seg, s)->name = shift_name;
 
 		/* Alter rimage name */
-		shift_name = dm_pool_strdup(cmd->mem, seg_lv(seg, s)->name);
-		if (!shift_name) {
+		if (!(seg_lv(seg, s)->name = _generate_raid_name(seg->lv, "rimage", s - missing))) {
 			log_error("Memory allocation failed.");
 			return 0;
 		}
-		len = strlen(shift_name) - 1;
-		shift_name[len] -= missing;
-		seg_lv(seg, s)->name = shift_name;
 
 		seg->areas[s - missing] = seg->areas[s];
 		seg->meta_areas[s - missing] = seg->meta_areas[s];
@@ -1030,6 +1012,442 @@ uint32_t raid_rimage_extents(const struct segment_type *segtype,
 	return r > UINT_MAX ? 0 : (uint32_t) r;
 }
 
+/* Return number of data copies for @segtype */
+uint32_t lv_raid_data_copies(const struct segment_type *segtype, uint32_t area_count)
+{
+	if (segtype_is_any_raid10(segtype))
+		/* FIXME: change for variable number of data copies */
+		return 2;
+	else if (segtype_is_mirrored(segtype))
+		return area_count;
+	else if (segtype_is_striped_raid(segtype))
+		return segtype->parity_devs + 1;
+	return 1;
+}
+
+
+/* Return data images count for @total_rimages depending on @seg's type */
+static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t total_rimages)
+{
+	if (!seg_is_thin(seg) && total_rimages <= seg->segtype->parity_devs)
+		return_0;
+
+	return total_rimages - seg->segtype->parity_devs;
+}
+
+/* Get total area len of @lv, i.e. sum of area_len of all segments */
+static uint32_t _lv_total_rimage_len(struct logical_volume *lv)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg_is_raid(seg)) {
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_lv(seg, s))
+				return seg_lv(seg, s)->le_count;
+	} else
+		return lv->le_count;
+
+	return_0;
+}
+
+/*
+ * HM helper:
+ *
+ * Compare the raid levels in segtype @t1 and @t2
+ *
+ * Return 1 if same, else 0
+ */
+static int _cmp_level(const struct segment_type *t1, const struct segment_type *t2)
+{
+	if ((segtype_is_any_raid10(t1)  && !segtype_is_any_raid10(t2)) ||
+	    (!segtype_is_any_raid10(t1) && segtype_is_any_raid10(t2)))
+		return 0;
+
+	return !strncmp(t1->name, t2->name, 5);
+}
+
+/*
+ * HM Helper:
+ *
+ * Check for same raid levels in segtype @t1 and @t2
+ *
+ * Return 1 if same, else != 1
+ */
+__attribute__ ((__unused__))
+static int is_same_level(const struct segment_type *t1, const struct segment_type *t2)
+{
+	return _cmp_level(t1, t2);
+}
+
+/* Return # of reshape LEs per device for @seg */
+static uint32_t _reshape_len_per_dev(struct lv_segment *seg)
+{
+	return seg->reshape_len;
+}
+
+/* Return # of reshape LEs per @lv (sum of all sub LVs reshape LEs) */
+static uint32_t _reshape_len_per_lv(struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	return _reshape_len_per_dev(seg) * _data_rimages_count(seg, seg->area_count);
+}
+
+/*
+ * HM Helper:
+ *
+ * store the allocated reshape length per data image
+ * in the only segment of the top-level RAID @lv and
+ * in the first segment of each sub lv.
+ */
+static int _lv_set_reshape_len(struct logical_volume *lv, uint32_t reshape_len)
+{
+	uint32_t s;
+	struct lv_segment *data_seg, *seg = first_seg(lv);
+
+	if (reshape_len >= lv->le_count - 1)
+		return_0;
+
+	seg->reshape_len = reshape_len;
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (!seg_lv(seg, s))
+			return_0;
+
+		reshape_len = seg->reshape_len;
+		dm_list_iterate_items(data_seg, &seg_lv(seg, s)->segments) {
+			data_seg->reshape_len = reshape_len;
+			reshape_len = 0;
+		}
+	}
+
+	return 1;
+}
+
+/* HM Helper:
+ *
+ * correct segments logical start extents in all sub LVs of @lv
+ * after having reordered any segments in sub LVs e.g. because of
+ * reshape space (re)allocation.
+ */
+static int _lv_set_image_lvs_start_les(struct logical_volume *lv)
+{
+	uint32_t le, s;
+	struct lv_segment *data_seg, *seg = first_seg(lv);
+
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (!seg_lv(seg, s))
+			return_0;
+
+		le = 0;
+		dm_list_iterate_items(data_seg, &(seg_lv(seg, s)->segments)) {
+			data_seg->reshape_len = le ? 0 : seg->reshape_len;
+			data_seg->le = le;
+			le += data_seg->len;
+		}
+	}
+
+	/* Try merging rimage sub LV segments _after_ adjusting start LEs */
+	for (s = 0; s < seg->area_count; s++)
+		if (!lv_merge_segments(seg_lv(seg, s)))
+			return_0;
+
+	return 1;
+}
+
+/*
+ * Relocate @out_of_place_les_per_disk from @lv's data images  begin <-> end depending on @where
+ *
+ * @where:
+ * alloc_begin: end -> begin
+ * alloc_end:   begin -> end
+ */
+enum alloc_where { alloc_begin, alloc_end, alloc_anywhere, alloc_none };
+static int _lv_relocate_reshape_space(struct logical_volume *lv, enum alloc_where where)
+{
+	uint32_t le, begin, end, s;
+	struct logical_volume *dlv;
+	struct dm_list *insert;
+	struct lv_segment *data_seg, *seg = first_seg(lv);
+
+	if (!_reshape_len_per_dev(seg))
+		return_0;
+
+	/*
+	 * Move the reshape LEs of each stripe (i.e. the data image sub lv)
+	 * in the first/last segment(s) across to the opposite end of the
+	 * address space
+	 */
+	for (s = 0; s < seg->area_count; s++) {
+		if (!(dlv = seg_lv(seg, s)))
+			return_0;
+
+		switch (where) {
+		case alloc_begin:
+			/* Move to the beginning -> start moving to the beginning from "end - reshape LEs" to end  */
+			begin = dlv->le_count - _reshape_len_per_dev(seg);
+			end = dlv->le_count;
+			break;
+		case alloc_end:
+			/* Move to the end -> start moving to the end from 0 and end with reshape LEs */
+			begin = 0;
+			end = _reshape_len_per_dev(seg);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "bogus reshape space reallocation request [%d]", where);
+			return 0;
+		}
+
+		/* Ensure segment boundary at begin/end of reshape space */
+		if (!lv_split_segment(dlv, begin ?: end))
+			return_0;
+
+		/* Select destination to move to (begin/end) */
+		insert = begin ? dlv->segments.n : &dlv->segments;
+		if (!(data_seg = find_seg_by_le(dlv, begin)))
+			return_0;
+
+		le = begin;
+		while (le < end) {
+			struct dm_list *n = data_seg->list.n;
+
+			le += data_seg->len;
+
+			dm_list_move(insert, &data_seg->list);
+
+			/* If moving to the begin, adjust insertion point so that we don't reverse order */
+			if (begin)
+				insert = data_seg->list.n;
+
+			data_seg = dm_list_item(n, struct lv_segment);
+		}
+
+		le = 0;
+		dm_list_iterate_items(data_seg, &dlv->segments) {
+			data_seg->reshape_len = le ? 0 : _reshape_len_per_dev(seg);
+			data_seg->le = le;
+			le += data_seg->len;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Check if we've got out of space reshape
+ * capacity in @lv and allocate if necessary.
+ *
+ * We inquire the targets status interface to retrieve
+ * the current data_offset and the device size and
+ * compare that to the size of the component image LV
+ * to tell if an extension of the LV is needed or
+ * existing space can just be used,
+ *
+ * Three different scenarios need to be covered:
+ *
+ *  - we have to reshape forwards
+ *    (true for adding disks to a raid set) ->
+ *    add extent to each component image upfront
+ *    or move an existing one at the end across;
+ *    kernel will set component devs data_offset to
+ *    the passed in one and new_data_offset to 0,
+ *    i.e. the data starts at offset 0 after the reshape
+ *
+ *  - we have to reshape backwards
+ *    (true for removing disks form a raid set) ->
+ *    add extent to each component image by the end
+ *    or use already existing one from a previous reshape;
+ *    kernel will leave the data_offset of each component dev
+ *    at 0 and set new_data_offset to the passed in one,
+ *    i.e. the data will be at offset new_data_offset != 0
+ *    after the reshape
+ *
+ *  - we are free to reshape either way
+ *    (true for layout changes keeping number of disks) ->
+ *    let the kernel identify free out of place reshape space
+ *    and select the appropriate data_offset and reshape direction
+ *
+ * Kernel will always be told to put data offset
+ * on an extent boundary.
+ * When we convert to mappings outside MD ones such as linear,
+ * striped and mirror _and_ data_offset != 0, split the first segment
+ * and adjust the rest to remove the reshape space.
+ * If it's at the end, just lv_reduce() and set seg->reshape_len to 0.
+ *
+ * Does not write metadata!
+ */
+static int _lv_alloc_reshape_space(struct logical_volume *lv,
+				   enum alloc_where where,
+				   enum alloc_where *where_it_was,
+				   struct dm_list *allocate_pvs)
+{
+	uint32_t out_of_place_les_per_disk;
+	uint64_t data_offset;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg->stripe_size)
+		return_0;
+
+	/* Ensure min out-of-place reshape space 1 MiB */
+	out_of_place_les_per_disk = max(2048U, (unsigned) seg->stripe_size);
+	out_of_place_les_per_disk = (uint32_t) max(out_of_place_les_per_disk / (unsigned long long) lv->vg->extent_size, 1ULL);
+
+	/* Get data_offset and dev_sectors from the kernel */
+	if (!lv_raid_data_offset(lv, &data_offset)) {
+		log_error("Can't get data offset and dev size for %s from kernel.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	/*
+	 * If we have reshape space allocated and it has to grow,
+	 * relocate it to the end in case kernel says it is at the
+	 * beginning in order to grow the LV.
+	 */
+	if (_reshape_len_per_dev(seg)) {
+		if (out_of_place_les_per_disk > _reshape_len_per_dev(seg)) {
+			/* Kernel says data is at data_offset > 0 -> relocate reshape space at the begin to the end */
+			if (data_offset && !_lv_relocate_reshape_space(lv, alloc_end))
+				return_0;
+
+			data_offset = 0;
+			out_of_place_les_per_disk -= _reshape_len_per_dev(seg);
+		} else
+			out_of_place_les_per_disk = 0;
+	}
+
+	/*
+	 * If we don't reshape space allocated extend the LV.
+	 *
+	 * first_seg(lv)->reshape_len (only segment of top level raid LV)
+	 * is accounting for the data rimages so that unchanged
+	 * lv_extend()/lv_reduce() can be used to allocate/free,
+	 * because seg->len etc. still holds the whole size as before
+	 * including the reshape space
+	 */
+	if (out_of_place_les_per_disk) {
+		uint32_t data_rimages = _data_rimages_count(seg, seg->area_count);
+		uint32_t reshape_len = out_of_place_les_per_disk * data_rimages;
+		uint32_t prev_rimage_len = _lv_total_rimage_len(lv);
+		uint64_t lv_size = lv->size;
+
+		if (!lv_extend(lv, seg->segtype, data_rimages,
+			       seg->stripe_size, 1, seg->region_size,
+			       reshape_len /* # of reshape LEs to add */,
+			       allocate_pvs, lv->alloc, 0)) {
+			log_error("Failed to allocate out-of-place reshape space for %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		lv->size = lv_size;
+		/* pay attention to lv_extend maybe having allocated more because of layout specific rounding */
+		if (!_lv_set_reshape_len(lv, _lv_total_rimage_len(lv) - prev_rimage_len))
+			return 0;
+	}
+
+	/* Preset data offset in case we fail relocating reshape space below */
+	seg->data_offset = 0;
+
+	/*
+	 * Handle reshape space relocation
+	 */
+	switch (where) {
+	case alloc_begin:
+		/* Kernel says data is at data_offset == 0 -> relocate reshape space at the end to the begin */
+		if (!data_offset && !_lv_relocate_reshape_space(lv, where))
+			return_0;
+		break;
+
+	case alloc_end:
+		/* Kernel says data is at data_offset > 0 -> relocate reshape space at the begin to the end */
+		if (data_offset && !_lv_relocate_reshape_space(lv, where))
+			return_0;
+		break;
+
+	case alloc_anywhere:
+		/* We don't care where the space is, kernel will just toggle data_offset accordingly */
+		break;
+
+	default:
+		log_error(INTERNAL_ERROR "Bogus reshape space allocation request.");
+		return 0;
+	}
+
+	if (where_it_was)
+		*where_it_was = data_offset ? alloc_begin : alloc_end;
+
+	/* Inform kernel about the reshape length in sectors */
+	seg->data_offset = _reshape_len_per_dev(seg) * lv->vg->extent_size;
+
+	return _lv_set_image_lvs_start_les(lv);
+}
+
+/* Remove any reshape space from the data LVs of @lv */
+static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum alloc_where *where_it_was)
+{
+	uint32_t total_reshape_len;
+	struct lv_segment *seg = first_seg(lv);
+
+	if ((total_reshape_len = _reshape_len_per_lv(lv))) {
+		enum alloc_where where;
+		/*
+		 * raid10:
+		 *
+		 * the allocator will have added times #data_copies stripes,
+		 * so we need to lv_reduce() less visible size.
+		 */
+		if (seg_is_any_raid10(seg)) {
+			if (total_reshape_len % seg->data_copies)
+				return_0;
+
+			total_reshape_len /= seg->data_copies;
+		}
+
+		/*
+		 * Got reshape space on request to free it.
+		 *
+		 * If it happens to be at the beginning of
+		 * the data LVs, remap it to the end in order
+		 * to be able to free it via lv_reduce().
+		 */
+		if (!_lv_alloc_reshape_space(lv, alloc_end, &where, NULL))
+			return_0;
+
+		seg->extents_copied = first_seg(lv)->area_len;
+		if (!lv_reduce(lv, total_reshape_len))
+			return_0;
+
+		seg->extents_copied = first_seg(lv)->area_len;
+
+		if (!_lv_set_reshape_len(lv, 0))
+			return 0;
+
+		/*
+		 * Only in case reshape space was freed at the beginning,
+		 * which is indicated by "where == alloc_begin",
+		 * tell kernel to adjust data_offsets on raid devices to 0.
+		 *
+		 * The special, unused value '1' for seg->data_offset will cause
+		 * "data_offset 0" to be emitted in the segment line.
+		 */
+		seg->data_offset = (where == alloc_begin) ? 1 : 0;
+
+	} else if (where_it_was)
+		*where_it_was = alloc_none;
+
+	return 1;
+}
+
+__attribute__ ((__unused__))
+static int _lv_free_reshape_space(struct logical_volume *lv)
+{
+	return _lv_free_reshape_space_with_status(lv, NULL);
+}
+
+
 /*
  * _alloc_rmeta_for_lv
  * @lv
@@ -4088,12 +4506,6 @@ static takeover_fn_t _get_takeover_fn(const struct lv_segment *seg, const struct
 	return _takeover_fns[_segtype_ix(seg->segtype, seg->area_count)][_segtype_ix(new_segtype, new_image_count)];
 }
 
-/* Number of data (not parity) rimages */
-static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t total_rimages)
-{
-	return total_rimages - seg->segtype->parity_devs;
-}
-
 /*
  * Determine whether data_copies, stripes, stripe_size are
  * possible for conversion from seg_from to new_segtype.
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 398e8b0..59db437 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -171,7 +171,7 @@ static int _raid_text_import(struct lv_segment *seg,
 	}
 
 	if (seg->data_copies < 2)
-		seg->data_copies = 0; // lv_raid_data_copies(seg->segtype, seg->area_count);
+		seg->data_copies = lv_raid_data_copies(seg->segtype, seg->area_count);
 
 	if (seg_is_any_raid0(seg))
 		seg->area_len /= seg->area_count;


