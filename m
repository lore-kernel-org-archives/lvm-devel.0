From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  5 Feb 2014 15:47:12 +0000 (UTC)
Subject: master - cache[pool]: Populate existing report fields with cache data
Message-ID: <20140205154712.41AEE60E94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36f9fadcb4be4091ba5fd505016d79a91037b19d
Commit:        36f9fadcb4be4091ba5fd505016d79a91037b19d
Parent:        96626f64fa499fb45dfc1afb39b86b70b8d3d9a4
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 5 09:44:37 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 5 09:44:37 2014 -0600

cache[pool]:  Populate existing report fields with cache data

For the report fields that already exist that are relevent to cache
and cache pool LVs (like 'origin', 'metadata_lv', etc), populate
them.
---
 lib/metadata/lv.c   |   26 ++++++++++++++++++++------
 lib/report/report.c |   13 +++++++++----
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 3e1458c..2d78dec 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -170,7 +170,7 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_snapshot(seg->lv)->chunk_size;
-	else if (seg_is_thin_pool(seg))
+	else if (seg_is_thin_pool(seg) || seg_is_cache_pool(seg))
 		size = (uint64_t) seg->chunk_size;
 	else
 		size = UINT64_C(0);
@@ -202,6 +202,9 @@ char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (lv_is_cow(lv))
 		return lv_name_dup(mem, origin_from_cow(lv));
 
+	if (lv_is_cache(lv) && first_seg(lv)->origin)
+		return lv_name_dup(mem, first_seg(lv)->origin);
+
 	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
 		return lv_name_dup(mem, first_seg(lv)->origin);
 
@@ -246,7 +249,8 @@ char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	struct lv_segment *seg;
 
 	dm_list_iterate_items(seg, &lv->segments)
-		if (seg_is_thin_volume(seg) && seg->pool_lv)
+		if (seg->pool_lv &&
+		    (seg_is_thin_volume(seg) || seg_is_cache(seg)))
 			return dm_pool_strdup(mem, seg->pool_lv->name);
 
 	return NULL;
@@ -254,14 +258,16 @@ char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
+		first_seg(lv) : NULL;
 
 	return seg ? dm_pool_strdup(mem, seg_lv(seg, 0)->name) : NULL;
 }
 
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
+		first_seg(lv) : NULL;
 
 	return seg ? dm_pool_strdup(mem, seg->metadata_lv->name) : NULL;
 }
@@ -338,7 +344,8 @@ uint64_t lv_origin_size(const struct logical_volume *lv)
 
 uint64_t lv_metadata_size(const struct logical_volume *lv)
 {
-	struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
+		first_seg(lv) : NULL;
 
 	return seg ? seg->metadata_lv->size : 0;
 }
@@ -546,6 +553,10 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	/* Origin takes precedence over mirror and thin volume */
 	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
+	else if (lv_is_cache_pool_metadata(lv))
+		repstr[0] = 'e';
+	else if (lv_is_cache_type(lv))
+		repstr[0] = 'C';
 	else if (lv_is_thin_pool_metadata(lv) ||
 		 lv_is_pool_metadata_spare(lv) ||
 		 (lv->status & RAID_META))
@@ -638,6 +649,8 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
+	else if (lv_is_cache_type(lv))
+		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';
 	else if (lv_is_mirror_type(lv))
@@ -741,7 +754,8 @@ static int _lv_is_exclusive(struct logical_volume *lv)
 	/* Some devices require exlusivness */
 	return seg_is_raid(first_seg(lv)) ||
 		lv_is_origin(lv) ||
-		lv_is_thin_type(lv);
+		lv_is_thin_type(lv) ||
+		lv_is_cache_type(lv);
 }
 
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
diff --git a/lib/report/report.c b/lib/report/report.c
index 18d7579..681e80c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -321,7 +321,7 @@ static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+	const struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ? first_seg(lv) : NULL;
 
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
@@ -334,7 +334,7 @@ static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 			    const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = lv_is_thin_pool(lv) ? first_seg(lv) : NULL;
+	const struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ? first_seg(lv) : NULL;
 
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg->metadata_lv, private);
@@ -347,7 +347,8 @@ static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lv_segment *seg = lv_is_thin_volume(lv) ? first_seg(lv) : NULL;
+	struct lv_segment *seg = (lv_is_thin_volume(lv) || lv_is_cache(lv)) ?
+				  first_seg(lv) : NULL;
 
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg->pool_lv, private);
@@ -373,10 +374,14 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const struct lv_segment *seg = first_seg(lv);
 
 	if (lv_is_cow(lv))
 		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
 
+	if (lv_is_cache(lv))
+		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
+
 	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
 		return _lvname_disp(rh, mem, field, first_seg(lv)->origin, private);
 
@@ -1051,7 +1056,7 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	if (lv_is_thin_pool(lv)) {
+	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		size = lv_metadata_size(lv);
 		return _size64_disp(rh, mem, field, &size, private);
 	}


