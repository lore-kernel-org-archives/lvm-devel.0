From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 3 Mar 2017 16:30:33 -0500
Subject: master - report: raid enhancements for --select
Message-ID: <201703032130.v23LUX4I021175@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c5b6c9ad44a3057cd3d8e81e29b65149151ff1e7
Commit:        c5b6c9ad44a3057cd3d8e81e29b65149151ff1e7
Parent:        6dea1ed5ae47018d75532203660eca0decbda08e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 3 22:29:50 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 3 22:29:50 2017 +0100

report: raid enhancements for --select

Enhance the raid report functions for the recently added LV fields
reshape_len, reshape_len_le, data_offset, new_data_offset, data_copies,
data_stripes and parity_chunks to cope with "lvs --select".

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/lv.c    |   21 +++++++++
 lib/report/columns.h |    4 +-
 lib/report/report.c  |  110 +++++++++++++++++++++++++++++---------------------
 3 files changed, 87 insertions(+), 48 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b54e391..a7e1dcd 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1104,6 +1104,19 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	return 1;
 }
 
+/* Helper: check for any sub LVs after a disk removing reshape */
+static int _sublvs_remove_after_reshape(const struct logical_volume *lv)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+
+	for (s = seg->area_count -1; s; s--)
+		if (seg_lv(seg, s)->status & LV_REMOVE_AFTER_RESHAPE)
+			return 1;
+
+	return 0;
+}
+
 char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm)
 {
 	const struct logical_volume *lv = lvdm->lv;
@@ -1269,6 +1282,8 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		repstr[8] = 'p';
 	else if (lv_is_raid_type(lv)) {
 		uint64_t n;
+		char *sync_action;
+
 		if (!activation())
 			repstr[8] = 'X';	/* Unknown */
 		else if (!lv_raid_healthy(lv))
@@ -1276,6 +1291,12 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		else if (lv_is_raid(lv)) {
 			if (lv_raid_mismatch_count(lv, &n) && n)
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
+			else if (lv_raid_sync_action(lv, &sync_action) &&
+				 !strcmp(sync_action, "reshape"))
+				repstr[8] = 's';  /* LV is re(s)haping */
+			else if (_sublvs_remove_after_reshape(lv))
+				repstr[8] = 'R';  /* sub-LV got freed from raid set by reshaping
+						     and has to be 'R'emoved */
 		} else if (lv->status & LV_WRITEMOSTLY)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
 		else if (lv->status & LV_REMOVE_AFTER_RESHAPE)
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 31255d7..f723ded 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -243,8 +243,8 @@ FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 0, vgmdacopies, vg_mda_copies, "Target numb
 FIELD(SEGS, seg, STR, "Type", list, 0, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", list, 0, seg_stripes, stripes, "Number of stripes or mirror/raid1 legs.", 0)
 FIELD(SEGS, seg, NUM, "#DStr", list, 0, seg_data_stripes, data_stripes, "Number of data stripes or mirror/raid1 legs.", 0)
-FIELD(SEGS, seg, NUM, "RSize", list, 0, seg_reshape_len, reshape_len, "Size of out-of-place reshape space in current units.", 0)
-FIELD(SEGS, seg, SIZ, "RSize", list, 0, seg_reshape_len_le, reshape_len_le, "Size of out-of-place reshape space in physical extents.", 0)
+FIELD(SEGS, seg, SIZ, "RSize", list, 0, seg_reshape_len, reshape_len, "Size of out-of-place reshape space in current units.", 0)
+FIELD(SEGS, seg, NUM, "RSize", list, 0, seg_reshape_len_le, reshape_len_le, "Size of out-of-place reshape space in logical extents.", 0)
 FIELD(SEGS, seg, NUM, "#Cpy", list, 0, seg_data_copies, data_copies, "Number of data copies.", 0)
 FIELD(SEGS, seg, NUM, "DOff", list, 0, seg_data_offset, data_offset, "Data offset on each image device.", 0)
 FIELD(SEGS, seg, NUM, "NOff", list, 0, seg_new_data_offset, new_data_offset, "New data offset after any reshape on each image device.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 5142f72..1808a2b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2412,6 +2412,7 @@ static int _segstartpe_disp(struct dm_report *rh,
 	return dm_report_field_uint32(rh, field, &seg->le);
 }
 
+/* Hepler: get used stripes = total stripes minux any to remove after reshape */
 static int _get_seg_used_stripes(const struct lv_segment *seg)
 {
 	uint32_t s;
@@ -2437,6 +2438,7 @@ static int _seg_stripes_disp(struct dm_report *rh, struct dm_pool *mem,
 	return dm_report_field_uint32(rh, field, &seg->area_count);
 }
 
+/* Report the number of data stripes, which is less than total stripes (e.g. 2 less for raid6) */
 static int _seg_data_stripes_disp(struct dm_report *rh, struct dm_pool *mem,
 				  struct dm_report_field *field,
 				  const void *data, void *private)
@@ -2451,95 +2453,111 @@ static int _seg_data_stripes_disp(struct dm_report *rh, struct dm_pool *mem,
 	return dm_report_field_uint32(rh, field, &stripes);
 }
 
+/* Helper: return the top-level, reshapable raid LV in case @seg belongs to an raid rimage LV */
+static struct logical_volume *_lv_for_raid_image_seg(const struct lv_segment *seg, struct dm_pool *mem)
+{
+	char *lv_name;
+
+	if (seg_is_reshapable_raid(seg))
+		return seg->lv;
+
+	if (seg->lv &&
+	    lv_is_raid_image(seg->lv) && !seg->le &&
+	    (lv_name = dm_pool_strdup(mem, seg->lv->name))) {
+		char *p = strchr(lv_name, '_');
+
+		if (p) {
+			/* Handle duplicated sub LVs */
+			if (strstr(p, "_dup_"))
+				p = strchr(p + 5, '_');
+
+			if (p) {
+				struct lv_list *lvl;
+
+				*p = '\0';
+				if ((lvl = find_lv_in_vg(seg->lv->vg, lv_name)) &&
+				    seg_is_reshapable_raid(first_seg(lvl->lv)))
+					return lvl->lv;
+
+			}
+		}
+	}
+
+	return NULL;
+}
+
+/* Helper: return the top-level raid LV in case it is reshapale for @seg or @seg if it is */
+static const struct lv_segment *_get_reshapable_seg(const struct lv_segment *seg, struct dm_pool *mem)
+{
+	return _lv_for_raid_image_seg(seg, mem) ? seg : NULL;
+}
+
+/* Display segment reshape length in current units */
 static int _seg_reshape_len_disp(struct dm_report *rh, struct dm_pool *mem,
 				    struct dm_report_field *field,
 				    const void *data, void *private)
 {
-	const struct lv_segment *seg = (const struct lv_segment *) data;
-	uint32_t reshape_len = seg->reshape_len;
+	const struct lv_segment *seg = _get_reshapable_seg((const struct lv_segment *) data, mem);
 
-	if (reshape_len && seg->lv) {
-		reshape_len *= seg->area_count * seg->lv->vg->extent_size;
+	if (seg) {
+		uint32_t reshape_len = seg->reshape_len * seg->area_count * seg->lv->vg->extent_size;
 
 		return _size32_disp(rh, mem, field, &reshape_len, private);
 	}
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
+/* Display segment reshape length of in logical extents */
 static int _seg_reshape_len_le_disp(struct dm_report *rh, struct dm_pool *mem,
 				    struct dm_report_field *field,
 				    const void *data, void *private)
 {
-	const struct lv_segment *seg = (const struct lv_segment *) data;
-	uint32_t reshape_len = seg->reshape_len;
+	const struct lv_segment *seg = _get_reshapable_seg((const struct lv_segment *) data, mem);
 
-	if (reshape_len) {
-		reshape_len *= seg->area_count;
+	if (seg) {
+		uint32_t reshape_len = seg->reshape_len* seg->area_count;
 
 		return dm_report_field_uint32(rh, field, &reshape_len);
 	}
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
+/* Display segment data copies (e.g. 3 for raid6) */
 static int _seg_data_copies_disp(struct dm_report *rh, struct dm_pool *mem,
 				 struct dm_report_field *field,
 				 const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
-	if (seg->data_copies > 1)
+	if (seg->data_copies)
 		return dm_report_field_uint32(rh, field, &seg->data_copies);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
+/* Helper: display segment data offset/new data offset in sectors */
 static int _segdata_offset(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private, int new_data_offset)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	const char *what = "";
+	struct logical_volume *lv;
 
-	if (lv_is_raid_image(seg->lv) &&
-	    !seg->le &&
-	    (seg->reshape_len || !new_data_offset)) {
-		struct lv_list *lvl;
-		char *lv_name;
+	if ((lv = _lv_for_raid_image_seg(seg, mem))) {
+		uint64_t data_offset;
 
-		if ((lv_name = strdup(seg->lv->name))) {
-			char *p = strchr(lv_name, '_');
+		if (lv_raid_data_offset(lv, &data_offset)) {
+			if (new_data_offset && !lv_raid_image_in_sync(seg->lv))
+				data_offset = data_offset ? 0 : seg->reshape_len * lv->vg->extent_size;
 
-			if (p) {
-				/* Handle duplicated sub LVs */
-				if (strstr(p, "_dup_"))
-					p = strchr(p + 5, '_');
-
-				if (p) {
-					*p = '\0';
-					if ((lvl = find_lv_in_vg(seg->lv->vg, lv_name))) {
-						if (seg_is_reshapable_raid(first_seg(lvl->lv))) {
-							uint64_t data_offset;
-
-							if (lv_raid_data_offset(lvl->lv, &data_offset)) {
-								if (new_data_offset && !lv_raid_image_in_sync(seg->lv))
-									data_offset = data_offset ? 0 :
-										      seg->reshape_len * seg->lv->vg->extent_size;
-
-								return dm_report_field_uint64(rh, field, &data_offset);
-							}
-
-							what = _str_unknown;
-						}
-					}
-				}
-			}
+			return dm_report_field_uint64(rh, field, &data_offset);
 		}
 
 	}
 
-	return _field_set_value(field, what, &GET_TYPE_RESERVED_VALUE(num_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _seg_data_offset_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2582,7 +2600,7 @@ static int _seg_parity_chunks_disp(struct dm_report *rh, struct dm_pool *mem,
 		return dm_report_field_uint32(rh, field, &parity_chunks);
 	}
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,


