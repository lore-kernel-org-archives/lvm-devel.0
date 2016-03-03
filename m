From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:46 +0000 (UTC)
Subject: master - metadata: add support for interconnection of thin pool LV segment with indirect origin
Message-ID: <20160303131946.80D7960091@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a61bc70f62a1648632985fa7ac81b89773da6d78
Commit:        a61bc70f62a1648632985fa7ac81b89773da6d78
Parent:        c45af2df4ee1f3a7cf1e979ce5312acdc392ba68
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:21:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:46:40 2016 +0100

metadata: add support for interconnection of thin pool LV segment with indirect origin

Add support for making an interconnection between thin LV segment and
its indirect origin (which may be historical or live LV) - add a new
"indirect_origin" argument to attach_pool_lv function.
---
 lib/cache_segtype/cache.c  |    2 +-
 lib/metadata/cache_manip.c |    4 ++--
 lib/metadata/lv_manip.c    |    4 ++--
 lib/metadata/metadata.h    |    4 +++-
 lib/metadata/pool_manip.c  |   15 +++++++++++++++
 lib/thin/thin.c            |    3 ++-
 6 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 17d1b31..a645756 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -348,7 +348,7 @@ static int _cache_text_import(struct lv_segment *seg,
 
 	seg->lv->status |= strstr(seg->lv->name, "_corig") ? LV_PENDING_DELETE : 0;
 
-	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
+	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 		return_0;
 
 	if (!dm_list_empty(&pool_lv->segments) &&
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 4fe8613..115abcb 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -273,7 +273,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	seg = first_seg(cache_lv);
 	seg->segtype = segtype;
 
-	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
+	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 		return_NULL;
 
 	return cache_lv;
@@ -424,7 +424,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	corigin_lv->status |= LV_PENDING_DELETE;
 
 	/* Reattach cache pool */
-	if (!attach_pool_lv(cache_seg, cache_pool_lv, NULL, NULL))
+	if (!attach_pool_lv(cache_seg, cache_pool_lv, NULL, NULL, NULL))
 		return_0;
 
 	/* Suspend/resume also deactivates deleted LV via support of LV_PENDING_DELETE */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 399668c..ed46ad3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7335,13 +7335,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (origin_lv && lv_is_thin_volume(origin_lv) &&
 		    (first_seg(origin_lv)->pool_lv == pool_lv)) {
 			/* For thin snapshot pool must match */
-			if (!attach_pool_lv(seg, pool_lv, origin_lv, NULL))
+			if (!attach_pool_lv(seg, pool_lv, origin_lv, NULL, NULL))
 				return_NULL;
 			/* Use the same external origin */
 			if (!attach_thin_external_origin(seg, first_seg(origin_lv)->external_lv))
 				return_NULL;
 		} else {
-			if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
+			if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 				return_NULL;
 			/* If there is an external origin... */
 			if (!attach_thin_external_origin(seg, origin_lv))
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 33cbfa6..31c9346 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -487,7 +487,9 @@ int fixup_imported_mirrors(struct volume_group *vg);
  * From thin_manip.c
  */
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
-		   struct logical_volume *origin_lv, struct logical_volume *merge_lv);
+		   struct logical_volume *origin_lv,
+		   struct generic_logical_volume *indirect_origin,
+		   struct logical_volume *merge_lv);
 int detach_pool_lv(struct lv_segment *seg);
 int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 20bb756..ac590b3 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -90,8 +90,11 @@ int attach_pool_data_lv(struct lv_segment *pool_seg,
 int attach_pool_lv(struct lv_segment *seg,
 		   struct logical_volume *pool_lv,
 		   struct logical_volume *origin,
+		   struct generic_logical_volume *indirect_origin,
 		   struct logical_volume *merge_lv)
 {
+	struct glv_list *glvl;
+
 	if (!seg_is_thin_volume(seg) && !seg_is_cache(seg)) {
 		log_error(INTERNAL_ERROR "Unable to attach pool to %s/%s"
 			  " that is not cache or thin volume.",
@@ -109,6 +112,18 @@ int attach_pool_lv(struct lv_segment *seg,
 	if (origin && !add_seg_to_segs_using_this_lv(origin, seg))
 		return_0;
 
+	if (indirect_origin) {
+		if (!(glvl = get_or_create_glvl(seg->lv->vg->vgmem, seg->lv, NULL)))
+			return_0;
+
+		seg->indirect_origin = indirect_origin;
+		if (indirect_origin->is_historical)
+			dm_list_add(&indirect_origin->historical->indirect_glvs, &glvl->list);
+		else
+			dm_list_add(&indirect_origin->live->indirect_glvs, &glvl->list);
+
+	}
+
 	if (!add_seg_to_segs_using_this_lv(pool_lv, seg))
 		return_0;
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 6a19055..a850757 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -473,6 +473,7 @@ static int _thin_text_import(struct lv_segment *seg,
 {
 	const char *lv_name;
 	struct logical_volume *pool_lv, *origin = NULL, *external_lv = NULL, *merge_lv = NULL;
+	struct generic_logical_volume *indirect_origin = NULL;
 
 	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
@@ -513,7 +514,7 @@ static int _thin_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Unknown external origin %s in", lv_name);
 	}
 
-	if (!attach_pool_lv(seg, pool_lv, origin, merge_lv))
+	if (!attach_pool_lv(seg, pool_lv, origin, indirect_origin, merge_lv))
 		return_0;
 
 	if (!attach_thin_external_origin(seg, external_lv))


