From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:34 +0000 (UTC)
Subject: master - cleanup: access pool segs with check
Message-ID: <20130615221634.052B060D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d73c0c674502bc1cf4962ee958511adf53fd720
Commit:        5d73c0c674502bc1cf4962ee958511adf53fd720
Parent:        5e19410d935134794b7a206b5300e43be44c8a28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 22:02:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:33 2013 +0200

cleanup: access pool segs with check

Add some minor checks after first_seg(lv).
Use direct check for thin pool segment.
Drop some unneeded {}
---
 lib/metadata/lv.c         |   30 ++++++++++++++++++++----------
 lib/metadata/thin_manip.c |    7 ++++++-
 lib/report/report.c       |   12 ++++++------
 3 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index fb7870d..6215e1a 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -170,7 +170,7 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_cow(seg->lv)->chunk_size;
-	else if (lv_is_thin_pool(seg->lv))
+	else if (seg_is_thin_pool(seg))
 		size = (uint64_t) seg->chunk_size;
 	else
 		size = UINT64_C(0);
@@ -254,14 +254,16 @@ char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	return lv_is_thin_pool(lv) ?
-		dm_pool_strdup(mem, seg_lv(first_seg(lv), 0)->name) : NULL;
+	struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+
+	return seg ? dm_pool_strdup(mem, seg_lv(seg, 0)->name) : NULL;
 }
 
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	return lv_is_thin_pool(lv) ?
-		dm_pool_strdup(mem, first_seg(lv)->metadata_lv->name) : NULL;
+	struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+
+	return seg ? dm_pool_strdup(mem, seg->metadata_lv->name) : NULL;
 }
 
 const char *lv_layer(const struct logical_volume *lv)
@@ -310,27 +312,35 @@ char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments) {
+	dm_list_iterate_items(seg, &lv->segments)
 		if (seg->status & PVMOVE)
 			return dm_pool_strdup(mem, dev_name(seg_dev(seg, 0)));
-	}
+
 	return NULL;
 }
 
 uint64_t lv_origin_size(const struct logical_volume *lv)
 {
+	struct lv_segment *seg;
+
 	if (lv_is_cow(lv))
 		return (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
-	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
-		return first_seg(lv)->external_lv->size;
+
+	if (lv_is_thin_volume(lv) && (seg = first_seg(lv)) &&
+	    seg->external_lv)
+		return seg->external_lv->size;
+
 	if (lv_is_origin(lv))
 		return lv->size;
+
 	return 0;
 }
 
 uint64_t lv_metadata_size(const struct logical_volume *lv)
 {
-	return lv_is_thin_pool(lv) ? first_seg(lv)->metadata_lv->size : 0;
+	struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+
+	return seg ? seg->metadata_lv->size : 0;
 }
 
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 37b5d77..bd30458 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -378,7 +378,12 @@ struct logical_volume *find_pool_lv(struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
-	if (!(seg = find_pool_seg(first_seg(lv))))
+	if (!(seg = first_seg(lv))) {
+		log_error("LV %s has no segment", lv->name);
+		return NULL;
+	}
+
+	if (!(seg = find_pool_seg(seg)))
 		return_NULL;
 
 	return seg->lv;
diff --git a/lib/report/report.c b/lib/report/report.c
index 47b3a33..8ff4f28 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -277,10 +277,10 @@ static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
 
-	if (lv_is_thin_pool(lv))
-		return _lvname_disp(rh, mem, field,
-				    seg_lv(first_seg(lv), 0), private);
+	if (seg)
+		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
 
 	dm_report_field_set_value(field, "", NULL);
 	return 1;
@@ -291,10 +291,10 @@ static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 			    const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
 
-	if (lv_is_thin_pool(lv))
-		return _lvname_disp(rh, mem, field,
-				    first_seg(lv)->metadata_lv, private);
+	if (seg)
+		return _lvname_disp(rh, mem, field, seg->metadata_lv, private);
 
 	dm_report_field_set_value(field, "", NULL);
 	return 1;


