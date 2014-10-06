From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:14 +0000 (UTC)
Subject: master - cache: improve creation code
Message-ID: <20141006133314.E91D06016C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d46c2f1c946e21393537a730eaa624665cb96bbc
Commit:        d46c2f1c946e21393537a730eaa624665cb96bbc
Parent:        189d0f8e1deb2ad8b985696d9925f5259ab30baa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 23:51:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

cache: improve creation code

Move code to better locations.
Improve test and remove invalid ones
(i.e. no reason to require cache size to be >= then origin).

Correctly comment where the code is doing actual conversion
of other existing volume - we do already a similar thing with
external origins.

Lots of new command line options and combinations is now supported.
Hopefully older syntax still works as well.

lvcreate --cache --cachepool vg/pool  -l1
lvcreate --type cache --cachepool vg/pool  -l1
lvcreate --type cache-pool vg/pool  -l1
lvcreate --type cache-pool --name pool vg  -l1
... and many many more ...
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |  189 ++++++++++++++++++++++++----------------------
 tools/lvcreate.c        |  116 +++++++++++++++++++----------
 3 files changed, 175 insertions(+), 131 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8a4fa13..0ffb048 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Improve code for creation of cache and cache pool volumes.
   Check cluster-wide (not local) active status before removing LV.
   Properly check if activation of removed cached LV really activated.
   Lvremoving cached LV removes cachepool (keep with lvconvert --splitcache).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1edb0a0..0aa6521 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6557,7 +6557,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	uint64_t status = UINT64_C(0);
 	struct logical_volume *lv, *org = NULL;
 	struct logical_volume *pool_lv;
-	struct lv_list *lvl;
+	struct logical_volume *tmp_lv;
 	const char *thin_name = NULL;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
@@ -6638,11 +6638,15 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	status |= lp->permission | VISIBLE_LV;
 
-	if (segtype_is_cache(lp->segtype) && lp->pool) {
+	if (seg_is_cache(lp)) {
+		if (!lp->pool) {
+			log_error(INTERNAL_ERROR "Cannot create cached volume without cache pool.");
+                        return NULL;
+		}
 		/* We have the cache_pool, create the origin with cache */
 		if (!(pool_lv = find_lv(vg, lp->pool))) {
-			log_error("Couldn't find origin volume '%s'.",
-				  lp->pool);
+			log_error("Couldn't find cache pool volume %s in "
+				  "volume group %s.", lp->pool, vg->name);
 			return NULL;
 		}
 
@@ -6652,44 +6656,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		if (!lp->extents) {
-			log_error("No size given for new cache origin LV");
-			return NULL;
-		}
-
-		if (lp->extents < pool_lv->le_count) {
-			log_error("Origin size cannot be smaller than"
-				  " the cache_pool");
+			log_error("No size given for new cache origin LV.");
 			return NULL;
 		}
 
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "striped")))
 			return_0;
-	} else if (segtype_is_cache(lp->segtype) && lp->origin) {
-		/* We have the origin, create the cache_pool and cache */
-		if (!(org = find_lv(vg, lp->origin))) {
-			log_error("Couldn't find origin volume '%s'.",
-				  lp->origin);
-			return NULL;
-		}
-
-		if (lv_is_locked(org)) {
-			log_error("Caching locked devices is not supported.");
-			return NULL;
-		}
-
-		if (!lp->extents) {
-			log_error("No size given for new cache_pool LV");
-			return NULL;
-		}
-
-		if (lp->extents > org->le_count) {
-			log_error("cache-pool size cannot be larger than"
-				  " the origin");
-			return NULL;
-		}
-		if (!(lp->segtype = get_segtype_from_string(vg->cmd,
-							    "cache-pool")))
-			return_0;
 	} else if (seg_is_thin(lp) && lp->snapshot) {
 		if (!lp->origin) {
 			log_error(INTERNAL_ERROR "Origin LV is not defined.");
@@ -6840,14 +6812,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
+		if (!(pool_lv = find_lv(vg, lp->pool))) {
 			log_error("Unable to find existing pool LV %s in VG %s.",
 				  lp->pool, vg->name);
 			return NULL;
 		}
 
-		if ((pool_is_active(lvl->lv) || is_change_activating(lp->activate)) &&
-		    !update_pool_lv(lvl->lv, 1))
+		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
+		    !update_pool_lv(pool_lv, 1))
 			return_NULL;
 
 		/* For thin snapshot we must have matching pool */
@@ -6951,43 +6923,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
 	}
 
-	if (lp->cache) {
-		struct logical_volume *tmp_lv;
-
-		if (lp->origin) {
-			/*
-			 * FIXME:  At this point, create_pool has created
-			 * the pool and added the data and metadata sub-LVs,
-			 * but only the metadata sub-LV is in the kernel -
-			 * a suspend/resume cycle is still necessary on the
-			 * cache_pool to actualize it in the kernel.
-			 *
-			 * Should the suspend/resume be added to create_pool?
-			 *    I say that would be cleaner, but I'm not sure
-			 *    about the effects on thinpool yet...
-			 */
-			if (!lv_update_and_reload(lv)) {
-				stack;
-				goto deactivate_and_revert_new_lv;
-			}
-
-			if (!(lvl = find_lv_in_vg(vg, lp->origin)))
-				goto deactivate_and_revert_new_lv;
-			org = lvl->lv;
-			pool_lv = lv;
-		} else {
-			if (!(lvl = find_lv_in_vg(vg, lp->pool)))
-				goto deactivate_and_revert_new_lv;
-			pool_lv = lvl->lv;
-			org = lv;
-		}
-
-		if (!(tmp_lv = lv_cache_create(pool_lv, org)))
-			goto deactivate_and_revert_new_lv;
-
-		lv = tmp_lv;
-	}
-
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
@@ -7013,6 +6948,56 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE))
 		lp->activate = CHANGE_AN;
 
+	/*
+	 * Check if this is conversion inside lvcreate
+	 * Either we have origin or pool and created cache origin LV
+	 */
+	if (lp->cache &&
+	    (lp->origin || (lp->pool && !lv_is_cache_pool(lv)))) {
+		if (lp->origin) {
+			if (!(org = find_lv(vg, lp->origin)))
+				goto deactivate_and_revert_new_lv;
+			pool_lv = lv; /* Cache pool is created */
+		} else if (lp->pool) {
+			if (!(pool_lv = find_lv(vg, lp->pool)))
+				goto deactivate_and_revert_new_lv;
+			org = lv; /* Cached origin is created */
+		}
+
+		if (!(tmp_lv = lv_cache_create(pool_lv, org)))
+			goto deactivate_and_revert_new_lv;
+
+		/* From here we cannot deactive_and_revert! */
+		lv = tmp_lv;
+
+		/*
+		 * We need to check if origin is active and in
+		 * that case reload cached LV.
+		 * There is no such problem with cache pool
+		 * since it cannot be activated.
+		 */
+		if (lp->origin && lv_is_active(lv)) {
+			if (!is_change_activating(lp->activate)) {
+				/* User requested to create inactive cached volume */
+				if (deactivate_lv(cmd, lv)) {
+					log_error("Failed to deactivate %s.", display_lvname(lv));
+					return NULL;
+				}
+			} else if (vg_is_clustered(lv->vg) &&
+				   locking_is_clustered() &&
+				   locking_supports_remote_queries() &&
+				   !lv_is_active_exclusive(lv)) {
+				log_error("Only exclusively active %s could be converted.", display_lvname(lv));
+				return NULL;
+			} else {
+				/* With exclusively active origin just reload */
+				if (!lv_update_and_reload(lv))
+					return_NULL;
+				goto out; /* converted */
+			}
+		}
+	}
+
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_NULL;
@@ -7180,26 +7165,50 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 {
 	struct logical_volume *lv;
 
-	/* Create thin pool first if necessary */
-	if (lp->create_pool && !seg_is_cache_pool(lp) && !seg_is_cache(lp)) {
-		if (!seg_is_thin_pool(lp) &&
-		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
-			return_0;
+	/* Create pool first if necessary */
+	if (lp->create_pool) {
+		if (seg_is_thin(lp)) {
+			if (!seg_is_thin_pool(lp) &&
+			    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
+				return_NULL;
 
-		if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
-			return_0;
+			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
+				return_NULL;
 
-		if (!lp->thin && !lp->snapshot)
-			goto out;
+			if (!lp->thin && !lp->snapshot)
+				goto out;
 
-		lp->pool = lv->name;
+			lp->pool = lv->name;
 
-		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-			return_0;
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+				return_NULL;
+		} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
+                        if (!seg_is_cache_pool(lp) &&
+			    !(lp->segtype = get_segtype_from_string(vg->cmd,
+								    "cache-pool")))
+				return_NULL;
+
+			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
+				return_NULL;
+
+			if (lv_is_cache(lv)) {
+				/* Here it's been converted via lvcreate */
+				log_print_unless_silent("Logical volume %s is now cached.",
+							display_lvname(lv));
+				return lv;
+			}
+
+			if (!lp->cache)
+				goto out;
+
+			lp->pool = lv->name;
+			log_error("Creation of cache pool and cached volume in one command is not yet supported.");
+			return NULL;
+		}
 	}
 
 	if (!(lv = _lv_create_an_lv(vg, lp, lp->lv_name)))
-		return_0;
+		return_NULL;
 
 out:
 	log_print_unless_silent("Logical volume \"%s\" created", lv->name);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 3db2c85..0a0ce1d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -47,7 +47,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 				 int *pargc, char ***pargv)
 {
 	int argc = *pargc;
-	char **argv = *pargv, *ptr;
+	char **argv = *pargv;
 	const char *vg_name;
 
 	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
@@ -61,28 +61,54 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 
 	if (seg_is_cache(lp)) {
 		/*
-		 * We are looking for the origin or cache_pool LV.
-		 * Could be in the form 'lv' or 'vg/lv'
+		 * We allowed somewhat hard to 'parse' syntax
+		 * (usage of lvcreate to convert LV to a cached LV).
+		 * So let's try to do our best to avoid wrong steps.
 		 *
-		 * We store the lv name in 'lp->origin' for now, but
+		 * We are looking for the vgname or cache pool or cache origin LV.
+		 *
+		 * We store the lv name in 'lp->pool', but
 		 * it must be accessed later (when we can look-up the
-		 * LV in the VG) whether it is truly the origin that
-		 * was specified, or whether it is the cache_pool.
+		 * LV in the VG) whether it is truly the cache pool
+		 * or whether it is the origin for cached LV.
 		 */
 		if (!argc) {
-			log_error("Please specify a logical volume to act as "
-				  "the origin or cache_pool.");
-			return 0;
-		}
-
-		lp->origin = skip_dev_dir(cmd, argv[0], NULL);
-		if (strrchr(lp->origin, '/')) {
-			if (!_set_vg_name(lp, extract_vgname(cmd, lp->origin)))
-				return_0;
-
-			/* Strip the volume group from the origin */
-			if ((ptr = strrchr(lp->origin, (int) '/')))
-				lp->origin = ptr + 1;
+			if (!lp->pool) {
+				/* Don't advertise we could handle cache origin */
+				log_error("Please specify a logical volume to act as the cache pool.");
+				return 0;
+			}
+		} else {
+			vg_name = skip_dev_dir(cmd, argv[0], NULL);
+			if (!strchr(vg_name, '/')) {
+				/* Lucky part - only vgname is here */
+				if (!_set_vg_name(lp, vg_name))
+					return_0;
+			} else {
+				/* Lets pretend it's cache origin for now */
+				lp->origin = vg_name;
+				if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin))
+					return_0;
+
+				if (lp->pool) {
+					if (strcmp(lp->pool, lp->origin)) {
+						log_error("Unsupported syntax, cannot use cache origin %s and --cachepool %s.",
+							  lp->origin, lp->pool);
+						/* Stop here, only older form remains supported */
+						return 0;
+					}
+					lp->origin = NULL;
+				} else {
+					/*
+					 * Gambling here, could be cache pool or cache origin,
+					 * detection is possible after openning vg,
+					 * yet we need to parse pool args
+					 */
+					lp->pool = lp->origin;
+					lp->create_pool = 1;
+				}
+			}
+			(*pargv)++, (*pargc)--;
 		}
 
 		if (!lp->vg_name &&
@@ -90,13 +116,18 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			return_0;
 
 		if (!lp->vg_name) {
-			log_error("The origin or cache_pool name should include"
-				  " the volume group.");
+			log_error("The cache pool or cache origin name should "
+				  "include the volume group.");
+			return 0;
+		}
+
+		if (!lp->pool) {
+			log_error("Creation of cached volume and cache pool "
+				  "in one command is not yet supported.");
 			return 0;
 		}
 
 		lp->cache = 1;
-		(*pargv)++, (*pargc)--;
 	} else if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		/* argv[0] might be [vg/]origin */
 		if (!argc) {
@@ -268,15 +299,15 @@ static int _lvcreate_update_pool_params(struct volume_group *vg,
  * @vg
  * @lp
  *
- * 'lp->origin' is set with an LV that could be either the origin
- * or the cache_pool of the cached LV which is being created.  This
+ * 'lp->pool' is set with an LV that could be either the cache_pool
+ * or the origin of the cached LV which is being created.  This
  * function determines which it is and sets 'lp->origin' or
  * 'lp->pool' appropriately.
  */
 static int _determine_cache_argument(struct volume_group *vg,
 				     struct lvcreate_params *lp)
 {
-	struct lv_list *lvl;
+	struct logical_volume *lv;
 
 	if (!seg_is_cache(lp)) {
 		log_error(INTERNAL_ERROR
@@ -284,22 +315,25 @@ static int _determine_cache_argument(struct volume_group *vg,
 			  lp->segtype->name);
 		return 0;
 	}
-	if (!lp->origin) {
-		log_error(INTERNAL_ERROR "Origin LV is not defined.");
-		return 0;
-	}
-	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
-		log_error("LV %s not found in Volume group %s.",
-			  lp->origin, vg->name);
-		return 0;
-	}
 
-	if (lv_is_cache_pool(lvl->lv)) {
-		lp->pool = lp->origin;
-		lp->origin = NULL;
-	} else {
-		lp->pool = NULL;
-		lp->create_pool = 1;
+	if (!lp->pool) {
+		lp->pool = lp->lv_name;
+	} else if (lp->pool == lp->origin) {
+		if (!(lv = find_lv(vg, lp->pool))) {
+			/* Cache pool nor origin volume exists */
+			lp->cache = 0;
+			lp->origin = NULL;
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
+				return_0;
+		} else if (!lv_is_cache_pool(lv)) {
+			/* Name arg in this case is for pool name */
+			lp->pool = lp->lv_name;
+			/* We were given origin for caching */
+		} else {
+			/* FIXME error on pool args */
+			lp->create_pool = 0;
+			lp->origin = NULL;
+		}
 	}
 
 	return 1;
@@ -1246,7 +1280,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 						lp.pvh, lp.poolmetadataspare))
 			goto_out;
 
-		log_verbose("Making thin pool %s in VG %s using segtype %s",
+		log_verbose("Making pool %s in VG %s using segtype %s",
 			    lp.pool ? : "with generated name", lp.vg_name, lp.segtype->name);
 	}
 


