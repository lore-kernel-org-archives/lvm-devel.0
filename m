From: David Teigland <teigland@redhat.com>
Date: Tue, 2 Sep 2014 15:56:00 -0500
Subject: [PATCH] lvconvert: limit lv types for cache use
Message-ID: <20140902205600.GF374@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Cache data and metadata lvs can be only linear, striped or raid.
Origin lvs must be either linear, striped or raid to be converted
to a cache lv.
---
 lib/metadata/metadata-exported.h |   8 ++
 lib/metadata/snapshot_manip.c    |   5 ++
 tools/lvconvert.c                | 173 ++++++++++++++++++++++++++++++++-------
 3 files changed, 157 insertions(+), 29 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0db43348dca2..7e29bb6e3307 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -180,6 +180,13 @@
 #define lv_is_raid_metadata(lv)	(((lv)->status & (RAID_META)) ? 1 : 0)
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
+/*
+ * Unfortunately, raid1 and raid10 end up being reported as MIRRORED,
+ * so lv_is_mirror_type() is true for them... add this test until that
+ * can be untangled.
+ */
+#define lv_is_really_mirror_type(lv) (lv_is_mirror_type((lv)) && !lv_is_raid((lv)))
+
 #define lv_is_cache(lv)		(((lv)->status & (CACHE)) ? 1 : 0)
 #define lv_is_cache_pool(lv)	(((lv)->status & (CACHE_POOL)) ? 1 : 0)
 #define lv_is_cache_pool_data(lv)	(((lv)->status & (CACHE_POOL_DATA)) ? 1 : 0)
@@ -927,6 +934,7 @@ int lv_is_cow_covering_origin(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
 int lv_is_visible(const struct logical_volume *lv);
+int lv_is_invisible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 278edc805391..611d919a5b50 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -129,6 +129,11 @@ int lv_is_visible(const struct logical_volume *lv)
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }
 
+int lv_is_invisible(const struct logical_volume *lv)
+{
+	return !lv_is_visible(lv);
+}
+
 int lv_is_virtual_origin(const struct logical_volume *lv)
 {
 	return (lv->status & VIRTUAL_ORIGIN) ? 1 : 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 185cd597aa1b..ba7c4bad29b4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -15,6 +15,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lv_alloc.h"
+#include "metadata.h"
 
 struct lvconvert_params {
 	int cache;
@@ -72,6 +73,62 @@ struct lvconvert_params {
 	thin_discards_t discards;
 };
 
+static const char *lv_is_name(struct logical_volume *lv)
+{
+	if (lv_is_external_origin(lv))
+		return "external_origin";
+
+	if (lv_is_thin_type(lv))
+		return "thin_type";
+
+	if (lv_is_external_origin(lv))
+		return "external_origin";
+
+	if (lv_is_really_mirror_type(lv))
+		return "mirror_type";
+
+	if (lv_is_raid_image(lv))
+		return "raid_image";
+
+	if (lv_is_raid_metadata(lv))
+		return "raid_metadata";
+
+	if (lv_is_cache_type(lv))
+		return "cache_type";
+
+	if (lv_is_virtual(lv))
+		return "virtual";
+
+	if (lv_is_pool_metadata_spare(lv))
+		return "metadata_spare";
+
+	if (lv_is_origin(lv))
+		return "origin";
+
+	if (lv_is_virtual_origin(lv))
+		return "virtual_origin";
+
+	if (lv_is_thin_origin(lv, NULL))
+		return "thin_origin";
+
+	if (lv_is_cache_origin(lv))
+		return "cache_origin";
+
+	if (lv_is_cow(lv))
+		return "cow";
+
+	if (lv_is_merging_origin(lv))
+		return "merging_origin";
+
+	if (lv_is_merging_cow(lv))
+		return "merging_cow";
+
+	if (lv_is_invisible(lv))
+		return "invisible";
+
+	return "unknown";
+}
+
 static int _lvconvert_vg_name(struct lvconvert_params *lp,
 			      struct cmd_context *cmd,
 			      const char **lv_name)
@@ -2662,6 +2719,8 @@ static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 }
 
 /*
+ * convert a data lv and a metadata lv into a thin|cache pool lv
+ *
  * Thin lvconvert version which
  *  rename metadata
  *  convert/layers thinpool over data
@@ -2687,6 +2746,44 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/*
+	 * For some reason we're calling this function to create a pool lv
+	 * even when pool_lv is already a pool lv.  A pool data lv (the
+	 * usual arg here) cannot be a pool lv, so we need to skip this
+	 * validation when the arg is already a pool lv.
+	 */
+
+	if (lv_is_pool(pool_lv))
+		goto skip_data_lv_validation;
+
+	/*
+	 * pool data lv's and pool metadata lv's can be linear, striped or raid
+	 */
+
+	if (lv_is_external_origin(pool_lv) ||
+	    lv_is_thin_type(pool_lv) ||
+	    lv_is_external_origin(pool_lv) ||
+	    lv_is_really_mirror_type(pool_lv) ||
+	    lv_is_raid_image(pool_lv) ||
+	    lv_is_raid_metadata(pool_lv) ||
+	    lv_is_cache_type(pool_lv) ||
+	    lv_is_virtual(pool_lv) ||
+	    lv_is_pool_metadata_spare(pool_lv) ||
+	    lv_is_origin(pool_lv) ||
+	    lv_is_virtual_origin(pool_lv) ||
+	    lv_is_thin_origin(pool_lv, NULL) ||
+	    lv_is_cache_origin(pool_lv) ||
+	    lv_is_cow(pool_lv) ||
+	    lv_is_merging_origin(pool_lv) ||
+	    lv_is_merging_cow(pool_lv) ||
+	    lv_is_invisible(pool_lv)) {
+		log_error("Pool data LV %s is not supported with LV type %s",
+			  pool_lv->name, lv_is_name(pool_lv));
+		return 0;
+	}
+
+ skip_data_lv_validation:
+
 	if (lp->pool_metadata_lv_name) {
 		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_lv_name))) {
 			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_lv_name);
@@ -2695,17 +2792,28 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		lp->pool_metadata_size = lp->pool_metadata_lv->size;
 		metadata_lv = lp->pool_metadata_lv;
 
-		if (!lv_is_visible(metadata_lv)) {
-			log_error("Can't convert internal LV %s.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-		if (lv_is_mirrored(metadata_lv) && !lv_is_raid_type(metadata_lv)) {
-			log_error("Mirror logical volumes cannot be used "
-				  "for pool metadata.");
-			log_error("Try \"raid1\" segment type instead.");
+		if (lv_is_external_origin(metadata_lv) ||
+		    lv_is_thin_type(metadata_lv) ||
+		    lv_is_external_origin(metadata_lv) ||
+		    lv_is_really_mirror_type(metadata_lv) ||
+		    lv_is_raid_image(metadata_lv) ||
+		    lv_is_raid_metadata(metadata_lv) ||
+		    lv_is_cache_type(metadata_lv) ||
+		    lv_is_virtual(metadata_lv) ||
+		    lv_is_pool_metadata_spare(metadata_lv) ||
+		    lv_is_origin(metadata_lv) ||
+		    lv_is_virtual_origin(metadata_lv) ||
+		    lv_is_thin_origin(metadata_lv, NULL) ||
+		    lv_is_cache_origin(metadata_lv) ||
+		    lv_is_cow(metadata_lv) ||
+		    lv_is_merging_origin(metadata_lv) ||
+		    lv_is_merging_cow(metadata_lv) ||
+		    lv_is_invisible(metadata_lv)) {
+			log_error("Pool metadata LV %s is not supported with LV type %s",
+				  metadata_lv->name, lv_is_name(metadata_lv));
 			return 0;
 		}
+
 		if (metadata_lv->status & LOCKED) {
 			log_error("Can't convert locked LV %s.",
 				  display_lvname(metadata_lv));
@@ -2716,12 +2824,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 				  display_lvname(metadata_lv));
 			return 0;
 		}
-		if (lv_is_thin_type(metadata_lv) ||
-		    lv_is_cache_type(metadata_lv)) {
-			log_error("Can't use thin or cache type LV %s for pool metadata.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
 
 		if (!lv_is_pool(pool_lv)) {
 			if (!_lvconvert_update_pool_params(pool_lv, lp))
@@ -2735,17 +2837,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		}
 	}
 
-	if (!lv_is_visible(pool_lv)) {
-		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
-		return 0;
-	}
-
-	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
-		log_error("Mirror logical volumes cannot be used as pools.\n"
-			  "Try \"raid1\" segment type instead.");
-		return 0;
-	}
-
 	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
 			 pool_lv->name,
 			 (segtype_is_cache_pool(lp->segtype)) ?
@@ -3032,6 +3123,10 @@ revert_new_lv:
 #endif
 }
 
+/*
+ * convert an origin lv into a cache lv by attaching a cache pool to the origin
+ */
+
 static int _lvconvert_cache(struct cmd_context *cmd,
 			    struct logical_volume *origin,
 			    struct lvconvert_params *lp)
@@ -3045,9 +3140,29 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_pool(origin) || lv_is_cache_type(origin)) {
-		log_error("Can't cache pool or cache type volume %s.",
-			  display_lvname(origin));
+	/*
+	 * origin can be linear, striped or raid
+	 */
+
+	if (lv_is_external_origin(origin) ||
+	    lv_is_thin_type(origin) ||
+	    lv_is_external_origin(origin) ||
+	    lv_is_really_mirror_type(origin) ||
+	    lv_is_raid_image(origin) ||
+	    lv_is_raid_metadata(origin) ||
+	    lv_is_cache_type(origin) ||
+	    lv_is_virtual(origin) ||
+	    lv_is_pool_metadata_spare(origin) ||
+	    lv_is_origin(origin) ||
+	    lv_is_virtual_origin(origin) ||
+	    lv_is_thin_origin(origin, NULL) ||
+	    lv_is_cache_origin(origin) ||
+	    lv_is_cow(origin) ||
+	    lv_is_merging_origin(origin) ||
+	    lv_is_merging_cow(origin) ||
+	    lv_is_invisible(origin)) {
+		log_error("Cache is not supported with origin LV %s type %s",
+			  origin->name, lv_is_name(origin));
 		return 0;
 	}
 
-- 
1.8.3.1


