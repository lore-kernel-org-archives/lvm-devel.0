From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:54 +0000 (UTC)
Subject: master - thin and cache: improve conversion validation
Message-ID: <20140924085654.2B7216109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13c07c685ade35192348a6b60a6c19077976b089
Commit:        13c07c685ade35192348a6b60a6c19077976b089
Parent:        cd3345a5b06ee1626101619f94b346a77295ca03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 14:15:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:53:44 2014 +0200

thin and cache: improve conversion validation

More validations before any thin or cache related conversion begins.

We allow to use and stack:

pool data: cache or raid
pool metadata: raid

pool:  linear, striped
cache: linear, striped, raid
thin(extorig): linear, origin, cow, virtual, thin
---
 tools/lvconvert.c |  145 +++++++++++++++++++++++++++++------------------------
 1 files changed, 79 insertions(+), 66 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 62e560c..57975d1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2662,30 +2662,48 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/*
-	 * Only linear, striped and raid supported.
-	 * FIXME Tidy up all these type restrictions.
-	 */
-	if (!lv_is_pool(pool_lv) &&
-	    (lv_is_external_origin(pool_lv) || lv_is_origin(pool_lv) || lv_is_thin_type(pool_lv) ||
-	     lv_is_mirror_type(pool_lv) || lv_is_cache_type(pool_lv) || lv_is_virtual(pool_lv) ||
-	     lv_is_cache_origin(pool_lv) || lv_is_merging_origin(pool_lv) || lv_is_merging_cow(pool_lv))) {
-		log_error("Pool data LV %s is of an unsupported type.", display_lvname(pool_lv));
+	if (!lv_is_visible(pool_lv)) {
+		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
+		return 0;
+	}
+
+	if (lv_is_locked(pool_lv)) {
+		log_error("Can't convert locked LV %s.", display_lvname(pool_lv));
 		return 0;
 	}
 
-	if (arg_is_set(cmd, cachepool_ARG) && lv_is_thin_pool(pool_lv)) {
-		log_error("--cachepool requires a cache pool.  %s is a thin pool.",
+	if (lv_is_thin_pool(pool_lv) && (segtype_is_cache_pool(lp->segtype) || lp->cache)) {
+		log_error("Cannot convert thin pool volume %s as cache pool data volume.",
 			  display_lvname(pool_lv));
 		return 0;
 	}
 
-	if (arg_is_set(cmd, thinpool_ARG) && lv_is_cache_pool(pool_lv)) {
-		log_error("--thinpool requires a thin pool.  %s is a cache pool.",
+	if (lv_is_cache_pool(pool_lv) && (segtype_is_thin_pool(lp->segtype) || lp->thin)) {
+		log_error("Cannot convert cache pool %s as thin pool data volume.",
 			  display_lvname(pool_lv));
 		return 0;
 	}
 
+	if (lv_is_mirror(pool_lv)) {
+		log_error("Mirror logical volumes cannot be used as pools.");
+		log_print_unless_silent("Try \"raid1\" segment type instead.");
+		return 0;
+	}
+
+	/*
+	 * Only linear, striped and raid supported.
+	 * FIXME Tidy up all these type restrictions.
+	 */
+	if (!lv_is_pool(pool_lv) &&
+	    (lv_is_thin_type(pool_lv) ||
+	     lv_is_cow(pool_lv) || lv_is_merging_cow(pool_lv) ||
+	     lv_is_origin(pool_lv) ||lv_is_merging_origin(pool_lv) ||
+	     lv_is_external_origin(pool_lv) ||
+	     lv_is_virtual(pool_lv))) {
+		log_error("Pool data LV %s is of an unsupported type.", display_lvname(pool_lv));
+		return 0;
+	}
+
 	if (lp->pool_metadata_lv_name) {
 		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_lv_name))) {
 			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_lv_name);
@@ -2694,16 +2712,15 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		lp->pool_metadata_size = lp->pool_metadata_lv->size;
 		metadata_lv = lp->pool_metadata_lv;
 
-		if (!lv_is_visible(metadata_lv)) {
-			log_error("Can't convert internal LV %s.",
+		if (metadata_lv == pool_lv) {
+			log_error("Can't use same LV for pool data and metadata LV %s.",
 				  display_lvname(metadata_lv));
 			return 0;
 		}
 
-		if (lv_is_mirror(metadata_lv)) {
-			log_error("Mirror logical volumes cannot be used "
-				  "for pool metadata.");
-			log_error("Try \"raid1\" segment type instead.");
+		if (!lv_is_visible(metadata_lv)) {
+			log_error("Can't convert internal LV %s.",
+				  display_lvname(metadata_lv));
 			return 0;
 		}
 
@@ -2713,24 +2730,19 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (metadata_lv == pool_lv) {
-			log_error("Can't use same LV for pool data and metadata LV %s.",
-				  display_lvname(metadata_lv));
-			return 0;
-		}
-
-		if (lv_is_thin_type(metadata_lv) ||
-		    lv_is_cache_type(metadata_lv)) {
-			log_error("Can't use thin or cache type LV %s for pool metadata.",
-				  display_lvname(metadata_lv));
+		if (lv_is_mirror(metadata_lv)) {
+			log_error("Mirror logical volumes cannot be used for pool metadata.");
+			log_print_unless_silent("Try \"raid1\" segment type instead.");
 			return 0;
 		}
 
 		/* FIXME Tidy up all these type restrictions. */
-		if (lv_is_external_origin(metadata_lv) || lv_is_virtual(metadata_lv) ||
-		    lv_is_origin(metadata_lv) || lv_is_thin_origin(metadata_lv, NULL) ||
-		    lv_is_cache_origin(metadata_lv) || lv_is_cow(metadata_lv) ||
-		    lv_is_merging_origin(metadata_lv) || lv_is_merging_cow(metadata_lv)) {
+		if (lv_is_cache_type(metadata_lv) ||
+		    lv_is_thin_type(metadata_lv) ||
+		    lv_is_cow(metadata_lv) || lv_is_merging_cow(metadata_lv) ||
+		    lv_is_origin(metadata_lv) || lv_is_merging_origin(metadata_lv) ||
+		    lv_is_external_origin(metadata_lv) ||
+		    lv_is_virtual(metadata_lv)) {
 			log_error("Pool metadata LV %s is of an unsupported type.",
 				  display_lvname(metadata_lv));
 			return 0;
@@ -2748,39 +2760,21 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		}
 	}
 
-	if (!lv_is_visible(pool_lv)) {
-		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
-		return 0;
-	}
-
-	if (lv_is_mirror(pool_lv)) {
-		log_error("Mirror logical volumes cannot be used as pools.\n"
-			  "Try \"raid1\" segment type instead.");
-		return 0;
-	}
-
-	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
-			 pool_lv->name,
-			 (segtype_is_cache_pool(lp->segtype)) ?
-			  "_cmeta" : "_tmeta") < 0) ||
-	    (dm_snprintf(data_name, sizeof(data_name), "%s%s",
-			 pool_lv->name,
-			 (segtype_is_cache_pool(lp->segtype)) ?
-			 "_cdata" : "_tdata") < 0)) {
-		log_error("Failed to create internal lv names, "
-			  "pool name is too long.");
-		return 0;
-	}
-
 	if (lv_is_pool(pool_lv)) {
 		lp->pool_data_lv = pool_lv;
 
 		if (!metadata_lv) {
 			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
-						 cachemode_ARG,chunksize_ARG, discards_ARG,
+						 cachemode_ARG, chunksize_ARG, discards_ARG,
 						 zero_ARG, poolmetadatasize_ARG, -1))
 				return_0;
-			return 1;
+
+			if (lp->thin || lp->cache)
+				/* already pool, can continue converting volume */
+				return 1;
+
+			log_error("LV %s is already pool.", display_lvname(pool_lv));
+			return 0;
 		}
 
 		if (lp->thin || lp->cache) {
@@ -2841,10 +2835,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			log_error("Conversion aborted.");
 			return 0;
 		}
-	} else if (lv_is_thin_type(pool_lv)) {
-		log_error("Can't use thin type logical volume %s for thin pool data.",
-			  display_lvname(pool_lv));
-		return 0;
 	} else {
 		log_warn("WARNING: Converting logical volume %s%s%s to pool's data%s.",
 			 display_lvname(pool_lv),
@@ -2869,6 +2859,19 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		/* Allow to have only thinpool active and restore it's active state */
 		activate_pool = lv_is_active(pool_lv);
 
+	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
+			 pool_lv->name,
+			 (segtype_is_cache_pool(lp->segtype)) ?
+			  "_cmeta" : "_tmeta") < 0) ||
+	    (dm_snprintf(data_name, sizeof(data_name), "%s%s",
+			 pool_lv->name,
+			 (segtype_is_cache_pool(lp->segtype)) ?
+			 "_cdata" : "_tdata") < 0)) {
+		log_error("Failed to create internal lv names, "
+			  "pool name is too long.");
+		return 0;
+	}
+
 	if (!metadata_lv) {
 		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
@@ -3068,13 +3071,23 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/* We support conversion of _tdata */
+	if (!lv_is_visible(origin) && !lv_is_thin_pool_data(origin)) {
+		log_error("Can't convert internal LV %s.", display_lvname(origin));
+		return 0;
+	}
+
 	/*
 	 * Only linear, striped or raid supported.
 	 * FIXME Tidy up all these type restrictions.
 	 */
-	if (lv_is_external_origin(origin) || lv_is_origin(origin) || lv_is_thin_type(origin) ||
-	    lv_is_mirror_type(origin) || lv_is_cache_origin(origin) || lv_is_virtual(origin) ||
-	    lv_is_cow(origin) || lv_is_merging_origin(origin) || lv_is_merging_cow(origin)) {
+	if (lv_is_cache_origin(origin) ||
+	    lv_is_mirror_type(origin) ||
+	    lv_is_thin_volume(origin) || lv_is_thin_pool_metadata(origin) ||
+	    lv_is_origin(origin) || lv_is_merging_origin(origin) ||
+	    lv_is_cow(origin) || lv_is_merging_cow(origin) ||
+	    lv_is_external_origin(origin) ||
+	    lv_is_virtual(origin)) {
 		log_error("Cache is not supported with origin LV %s type.",
 			  display_lvname(origin));
 		return 0;


