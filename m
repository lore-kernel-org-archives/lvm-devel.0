From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 28 Jan 2014 08:16:09 -0600
Subject: [LVM PATCH 3/3] cache/pool: Make the fns in pool_manip.c work with cache pools
In-Reply-To: <1390918569-22041-1-git-send-email-jbrassow@redhat.com>
References: <1390918569-22041-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1390918569-22041-4-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The functions in pool_manip.c are specific to thin pools.  It's
now time to make them more generic and able to handle cache pools
as well.

---
 lib/metadata/pool_manip.c |   44 +++++++++++++++++++++++++++++---------------
 1 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 18dfad5..afb77d6 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -28,14 +28,15 @@
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *metadata_lv)
 {
-	if (!seg_is_thin_pool(pool_seg)) {
+	if (!seg_is_thin_pool(pool_seg) && !seg_is_cache_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to attach pool metadata LV to %s segtype.",
 			  pool_seg->segtype->ops->name(pool_seg));
 		return 0;
 	}
 	pool_seg->metadata_lv = metadata_lv;
-	metadata_lv->status |= THIN_POOL_METADATA;
+	metadata_lv->status |= seg_is_thin_pool(pool_seg) ?
+		THIN_POOL_METADATA : CACHE_POOL_METADATA;
 	lv_set_hidden(metadata_lv);
 
 	return add_seg_to_segs_using_this_lv(metadata_lv, pool_seg);
@@ -44,7 +45,7 @@ int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 int attach_pool_data_lv(struct lv_segment *pool_seg,
 			struct logical_volume *pool_data_lv)
 {
-	if (!seg_is_thin_pool(pool_seg)) {
+	if (!seg_is_thin_pool(pool_seg) && !seg_is_cache_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to attach pool data LV to %s segtype.",
 			  pool_seg->segtype->ops->name(pool_seg));
@@ -52,10 +53,12 @@ int attach_pool_data_lv(struct lv_segment *pool_seg,
 	}
 
 	if (!set_lv_segment_area_lv(pool_seg, 0, pool_data_lv,
-				    0, THIN_POOL_DATA))
+				    0, seg_is_thin_pool(pool_seg) ?
+				    THIN_POOL_DATA : CACHE_POOL_DATA))
 		return_0;
 
-	pool_seg->lv->status |= THIN_POOL;
+	pool_seg->lv->status |= seg_is_thin_pool(pool_seg) ?
+		THIN_POOL : CACHE_POOL;
 	lv_set_hidden(pool_data_lv);
 
 	return 1;
@@ -66,16 +69,16 @@ int attach_pool_lv(struct lv_segment *seg,
 		   struct logical_volume *origin,
 		   struct logical_volume *merge_lv)
 {
-	if (!seg_is_thin_volume(seg)) {
+	if (!seg_is_thin_volume(seg) && !seg_is_cache(seg)) {
 		log_error(INTERNAL_ERROR "Unable to attach pool to %s/%s"
-			  " that is thin volume.",
+			  " that is not cache or thin volume.",
 			  pool_lv->vg->name, seg->lv->name);
 		return 0;
 	}
 
 	seg->pool_lv = pool_lv;
 	seg->origin = origin;
-	seg->lv->status |= THIN_VOLUME;
+	seg->lv->status |= seg_is_cache(seg) ? CACHE : THIN_VOLUME;
 
 	if (origin && !add_seg_to_segs_using_this_lv(origin, seg))
 		return_0;
@@ -108,6 +111,13 @@ int detach_pool_lv(struct lv_segment *seg)
 		return 0;
 	}
 
+	if (seg_is_cache(seg)) {
+		if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
+			return_0;
+		seg->pool_lv = NULL;
+		return 1;
+	}
+
 	if (!lv_is_thin_pool(seg->pool_lv)) {
 		log_error(INTERNAL_ERROR
 			  "Cannot detach pool from LV %s.",
@@ -189,9 +199,11 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 		return NULL;
 	}
 
-	if (!seg_is_thin_pool(pool_seg)) {
-		log_error("%s on %s is not a pool segment.",
-			  pool_seg->lv->name, seg->lv->name);
+	if ((lv_is_thin_type(seg->lv) && !seg_is_thin_pool(pool_seg)) &&
+	    !seg_is_cache_pool(pool_seg)) {
+		log_error("%s on %s is not a %s pool segment",
+			  pool_seg->lv->name, seg->lv->name,
+			  lv_is_thin_type(seg->lv) ? "thin" : "cache");
 		return NULL;
 	}
 
@@ -208,7 +220,7 @@ int create_pool(struct logical_volume *pool_lv,
 	char name[NAME_LEN];
 
 	if (pool_lv->le_count) {
-		log_error(INTERNAL_ERROR "Pool %s has already extents.",
+		log_error(INTERNAL_ERROR "Pool %s already has extents.",
 			  pool_lv->name);
 		return 0;
 	}
@@ -259,7 +271,8 @@ int create_pool(struct logical_volume *pool_lv,
 	}
 
 	if (dm_snprintf(name, sizeof(name), "%s_%s", pool_lv->name,
-			"tmeta") < 0) {
+			(segtype_is_cache_pool(segtype)) ?
+			"cmeta" : "tmeta") < 0) {
 		log_error("Name is too long to be a pool name.");
 		goto bad;
 	}
@@ -277,7 +290,8 @@ int create_pool(struct logical_volume *pool_lv,
 
 	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
 					    pool_lv->status,
-					    "_tdata")))
+					    (segtype_is_cache_pool(segtype)) ?
+					    "_cdata" : "_tdata")))
 		goto_bad;
 
 	seg = first_seg(pool_lv);
@@ -285,7 +299,7 @@ int create_pool(struct logical_volume *pool_lv,
 	if (!remove_seg_from_segs_using_this_lv(data_lv, seg))
 		goto_bad;
 
-	seg->segtype = segtype; /* Set as thin_pool segment */
+	seg->segtype = segtype; /* Set as thin_pool or cache_pool segment */
 
 	if (!attach_pool_data_lv(seg, data_lv))
 		goto_bad;
-- 
1.7.7.6


