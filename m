From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 19:38:46 +0000 (UTC)
Subject: master - cleanup: add seg_is_pool macro
Message-ID: <20140523193846.2042A6101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=952514611d258f99e29b29daf25e285f9286c60a
Commit:        952514611d258f99e29b29daf25e285f9286c60a
Parent:        cb7bba9ffe48cecaf92912d04255171bf2f79bf6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 14:24:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 21:36:55 2014 +0200

cleanup: add seg_is_pool macro

Simplify code querying for pool segtype.
---
 lib/metadata/lv.c         |    2 +-
 lib/metadata/lv_manip.c   |    8 +++-----
 lib/metadata/merge.c      |    2 +-
 lib/metadata/pool_manip.c |    7 +++----
 lib/metadata/segtype.h    |    2 ++
 5 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4dbcb20..5414d94 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -170,7 +170,7 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_snapshot(seg->lv)->chunk_size;
-	else if (seg_is_thin_pool(seg) || seg_is_cache_pool(seg))
+	else if (seg_is_pool(seg))
 		size = (uint64_t) seg->chunk_size;
 	else
 		size = UINT64_C(0);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 91a15f2..37c7686 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6077,7 +6077,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if (seg_is_thin_pool(lp) || seg_is_cache_pool(lp)) {
+	if (seg_is_pool(lp)) {
 		if (((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
 			log_error("Unable to create %s smaller than 1 chunk.",
 				  lp->segtype->name);
@@ -6107,8 +6107,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!activation() &&
 	    (seg_is_mirrored(lp) ||
 	     seg_is_raid(lp) ||
-	     seg_is_thin_pool(lp) ||
-	     seg_is_cache_pool(lp))) {
+	     seg_is_pool(lp))) {
 		/*
 		 * FIXME: For thin pool add some code to allow delayed
 		 * initialization of empty thin pool volume.
@@ -6208,8 +6207,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
-		       (seg_is_thin_pool(lp) || seg_is_cache_pool(lp)) ?
-		       lp->poolmetadataextents : lp->region_size,
+		       seg_is_pool(lp) ? lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
 		       thin_name, lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 146034f..319df4b 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -191,7 +191,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 
 			}
-			if (seg_is_thin_pool(seg) || seg_is_cache_pool(seg)) {
+			if (seg_is_pool(seg)) {
 				if (seg->area_count != 1 ||
 				    seg_type(seg, 0) != AREA_LV) {
 					log_error("LV %s: %spool segment %u is missing a pool data LV",
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index fe14034..ab52ff1 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -27,7 +27,7 @@
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *metadata_lv)
 {
-	if (!seg_is_thin_pool(pool_seg) && !seg_is_cache_pool(pool_seg)) {
+	if (!seg_is_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to attach pool metadata LV to %s segtype.",
 			  pool_seg->segtype->ops->name(pool_seg));
@@ -44,7 +44,7 @@ int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 int attach_pool_data_lv(struct lv_segment *pool_seg,
 			struct logical_volume *pool_data_lv)
 {
-	if (!seg_is_thin_pool(pool_seg) && !seg_is_cache_pool(pool_seg)) {
+	if (!seg_is_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to attach pool data LV to %s segtype.",
 			  pool_seg->segtype->ops->name(pool_seg));
@@ -199,8 +199,7 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 		return NULL;
 	}
 
-	if ((lv_is_thin_type(seg->lv) && !seg_is_thin_pool(pool_seg)) &&
-	    !seg_is_cache_pool(pool_seg)) {
+	if ((lv_is_thin_type(seg->lv) && !seg_is_pool(pool_seg))) {
 		log_error("%s on %s is not a %s pool segment",
 			  pool_seg->lv->name, seg->lv->name,
 			  lv_is_thin_type(seg->lv) ? "thin" : "cache");
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 4f060cd..1a4a92f 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -48,6 +48,7 @@ struct dev_manager;
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
@@ -59,6 +60,7 @@ struct dev_manager;
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
+#define seg_is_pool(seg)	segtype_is_pool((seg)->segtype)
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)


