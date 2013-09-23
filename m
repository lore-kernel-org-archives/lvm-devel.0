From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:15 +0000 (UTC)
Subject: master - cleanup: shorter code
Message-ID: <20130923101615.67ED4613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d61955a303d73d1a97b80f3a010711eac846d4
Commit:        d2d61955a303d73d1a97b80f3a010711eac846d4
Parent:        85b9c12e92873a87b7c02bac20287beeea82ef2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 09:44:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

cleanup: shorter code

Put assignment on declaration line.
---
 lib/report/report.c |  109 +++++++++++++++------------------------------------
 1 files changed, 32 insertions(+), 77 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 347b830..73e72f4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -326,13 +326,10 @@ static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lv_segment *seg;
+	struct lv_segment *seg = lv_is_thin_volume(lv) ? first_seg(lv) : NULL;
 
-	if (lv_is_thin_volume(lv))
-		dm_list_iterate_items(seg, &lv->segments)
-			if (seg_is_thin_volume(seg))
-				return _lvname_disp(rh, mem, field,
-						    seg->pool_lv, private);
+	if (seg)
+		return _lvname_disp(rh, mem, field, seg->pool_lv, private);
 
 	dm_report_field_set_value(field, "", NULL);
 	return 1;
@@ -500,9 +497,9 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			      void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	uint32_t read_ahead;
+	uint32_t read_ahead = lv_kernel_read_ahead(lv);
 
-	if ((read_ahead = lv_kernel_read_ahead(lv)) == UINT32_MAX)
+	if (read_ahead == UINT32_MAX)
 		return dm_report_field_int32(rh, field, &_minusone32);
 
 	return _size32_disp(rh, mem, field, &read_ahead, private);
@@ -513,9 +510,7 @@ static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t size;
-
-	size = (uint64_t) vg_size(vg);
+	uint64_t size = vg_size(vg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -539,9 +534,7 @@ static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
 			  const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	uint64_t start;
-
-	start = lvseg_start(seg);
+	uint64_t start = lvseg_start(seg);
 
 	return _size64_disp(rh, mem, field, &start, private);
 }
@@ -562,9 +555,7 @@ static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	uint64_t size;
-
-	size = lvseg_size(seg);
+	uint64_t size = lvseg_size(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -574,9 +565,7 @@ static int _chunksize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	uint64_t size;
-
-	size = lvseg_chunksize(seg);
+	uint64_t size = lvseg_chunksize(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -636,14 +625,14 @@ static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	uint64_t size;
+	uint64_t size = lv_origin_size(lv);
 
-	if (!(size = lv_origin_size(lv))) {
-		dm_report_field_set_value(field, "", &_zero64);
-		return 1;
-	}
+	if (size)
+		return _size64_disp(rh, mem, field, &size, private);
 
-	return _size64_disp(rh, mem, field, &size, private);
+	dm_report_field_set_value(field, "", &_zero64);
+
+	return 1;
 }
 
 static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -652,9 +641,7 @@ static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	uint64_t used;
-
-	used = pv_used(pv);
+	uint64_t used = pv_used(pv);
 
 	return _size64_disp(rh, mem, field, &used, private);
 }
@@ -665,9 +652,7 @@ static int _pvfree_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	uint64_t freespace;
-
-	freespace = pv_free(pv);
+	uint64_t freespace = pv_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -678,9 +663,7 @@ static int _pvsize_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	uint64_t size;
-
-	size = pv_size_field(pv);
+	uint64_t size = pv_size_field(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -691,9 +674,7 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	uint64_t size;
-
-	size = pv_dev_size(pv);
+	uint64_t size = pv_dev_size(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -703,9 +684,7 @@ static int _vgfree_disp(struct dm_report *rh, struct dm_pool *mem,
 			const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t freespace;
-
-	freespace = (uint64_t) vg_free(vg);
+	uint64_t freespace = vg_free(vg);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -727,11 +706,9 @@ static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
-	uint32_t count;
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-
-	count = pv_mda_count(pv);
+	uint32_t count = pv_mda_count(pv);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -740,11 +717,9 @@ static int _pvmdasused_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {
-	uint32_t count;
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-
-	count = pv_mda_used_count(pv);
+	uint32_t count = pv_mda_used_count(pv);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -754,9 +729,7 @@ static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint32_t count;
-
-	count = vg_mda_count(vg);
+	uint32_t count = vg_mda_count(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -766,9 +739,7 @@ static int _vgmdasused_disp(struct dm_report *rh, struct dm_pool *mem,
 			     const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint32_t count;
-
-	count = vg_mda_used_count(vg);
+	uint32_t count = vg_mda_used_count(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -778,9 +749,7 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 				   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint32_t count;
-
-	count = vg_mda_copies(vg);
+	uint32_t count = vg_mda_copies(vg);
 
 	if (count == VGMETADATACOPIES_UNMANAGED) {
 		dm_report_field_set_value(field, "unmanaged", &_minusone64);
@@ -809,9 +778,7 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	uint64_t freespace;
-
-	freespace = pv_mda_free(pv);
+	uint64_t freespace = pv_mda_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -822,9 +789,7 @@ static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	uint64_t min_mda_size;
-
-	min_mda_size = pv_mda_size(pv);
+	uint64_t min_mda_size = pv_mda_size(pv);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -834,9 +799,7 @@ static int _vgmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t min_mda_size;
-
-	min_mda_size = vg_mda_size(vg);
+	uint64_t min_mda_size = vg_mda_size(vg);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -846,9 +809,7 @@ static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t freespace;
-
-	freespace = vg_mda_free(vg);
+	uint64_t freespace = vg_mda_free(vg);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -858,9 +819,7 @@ static int _lvcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			 const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint32_t count;
-
-	count = vg_visible_lvs(vg);
+	uint32_t count = vg_visible_lvs(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -870,9 +829,7 @@ static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	uint32_t count;
-
-	count = dm_list_size(&lv->segments);
+	uint32_t count = dm_list_size(&lv->segments);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -882,9 +839,7 @@ static int _snapcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint32_t count;
-
-	count = snapshot_count(vg);
+	uint32_t count = snapshot_count(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }


