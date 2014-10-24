From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:14 +0000 (UTC)
Subject: master - cache: separate func for pool/origin validation
Message-ID: <20141024144114.78D5A60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd00d2c6eceb6536208558561a02d464d1808469
Commit:        fd00d2c6eceb6536208558561a02d464d1808469
Parent:        298de1f5c3c2a84eb4c12f4697c110016a98237e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 21:01:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

cache: separate func for pool/origin validation

Split validate_lv_cache_create() into 2 function
once is called for pool validation other for origin.

It's less misleading the accepting NULLs.
---
 lib/metadata/cache_manip.c       |   55 ++++++++++++++++++--------------------
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    4 +-
 tools/lvconvert.c                |    5 ++-
 tools/lvcreate.c                 |    2 +
 5 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6aad50d..44d1bd8 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -92,39 +92,35 @@ int update_cache_pool_params(const struct segment_type *segtype,
  *
  * Always validates origin_lv, and when it is known also cache pool_lv
  */
-int validate_lv_cache_create(const struct logical_volume *pool_lv,
-			     const struct logical_volume *origin_lv)
+int validate_lv_cache_create_pool(const struct logical_volume *pool_lv)
 {
 	struct lv_segment *seg;
 
-	if (pool_lv) {
-		if (!lv_is_cache_pool(pool_lv)) {
-			log_error("Logical volume %s is not a cache pool.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
-
-		if (lv_is_locked(pool_lv)) {
-			log_error("Cannot use locked cache pool %s.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
+	if (!lv_is_cache_pool(pool_lv)) {
+		log_error("Logical volume %s is not a cache pool.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
 
-		if (origin_lv == pool_lv) {
-			log_error("Can't use same LV %s for cache pool and cache volume.",
-				  display_lvname(pool_lv));
-			return 0;
-		}
+	if (lv_is_locked(pool_lv)) {
+		log_error("Cannot use locked cache pool %s.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
 
-		if (!dm_list_empty(&pool_lv->segs_using_this_lv)) {
-			seg = get_only_segment_using_this_lv(pool_lv);
-			log_error("Logical volume %s is already in use by %s",
-				  display_lvname(pool_lv),
-				  seg ? display_lvname(seg->lv) : "another LV");
-			return 0;
-		}
+	if (!dm_list_empty(&pool_lv->segs_using_this_lv)) {
+		seg = get_only_segment_using_this_lv(pool_lv);
+		log_error("Logical volume %s is already in use by %s",
+			  display_lvname(pool_lv),
+			  seg ? display_lvname(seg->lv) : "another LV");
+		return 0;
 	}
 
+	return 1;
+}
+
+int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
+{
 	if (lv_is_locked(origin_lv)) {
 		log_error("Cannot use locked origin volume %s.",
 			  display_lvname(origin_lv));
@@ -174,7 +170,8 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	struct logical_volume *cache_lv = origin_lv;
 	struct lv_segment *seg;
 
-	if (!validate_lv_cache_create(pool_lv, origin_lv))
+	if (!validate_lv_cache_create_pool(pool_lv) ||
+	    !validate_lv_cache_create_origin(origin_lv))
 		return_NULL;
 
 	if (!(segtype = get_segtype_from_string(cmd, "cache")))
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f2cf404..335a1bd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6711,7 +6711,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (!validate_lv_cache_create(NULL, origin_lv))
+		if (!validate_lv_cache_create_origin(origin_lv))
 			return_NULL;
 
 		/* Validate cache origin is exclusively active */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1100849..19508ab 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1083,8 +1083,8 @@ int update_cache_pool_params(const struct segment_type *segtype,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
-int validate_lv_cache_create(const struct logical_volume *pool_lv,
-			     const struct logical_volume *origin_lv);
+int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
+int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index eb8a83b..c792986 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3202,7 +3202,8 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	struct logical_volume *pool_lv = lp->pool_data_lv;
 	struct logical_volume *cache_lv;
 
-	if (!validate_lv_cache_create(pool_lv, origin_lv))
+	if (!validate_lv_cache_create_pool(pool_lv) ||
+	    !validate_lv_cache_create_origin(origin_lv))
 		return_0;
 
 	if (!archive(origin_lv->vg))
@@ -3270,7 +3271,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->cache) {
 		if (lv_is_thin_pool(lv))
 			lv = seg_lv(first_seg(lv), 0); /* cache _tdata */
-		if (!validate_lv_cache_create(NULL, lv))
+		if (!validate_lv_cache_create_origin(lv))
 			return_ECMD_FAILED;
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 767405b..45f432e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1051,6 +1051,8 @@ static int _determine_cache_argument(struct volume_group *vg,
 	if (!lp->pool_name) {
 		lp->pool_name = lp->lv_name;
 	} else if ((lv = find_lv(vg, lp->pool_name)) && lv_is_cache_pool(lv)) {
+		if (!validate_lv_cache_create_pool(lv))
+			return_0;
 		/* Pool exists, create cache volume */
 		lp->create_pool = 0;
 		lp->origin_name = NULL;


