From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 31 Jan 2014 18:03:11 -0600
Subject: [LVM PATCH 5/6] cache: Code to allow the creation of cache LVs
In-Reply-To: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
References: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1391212992-3439-6-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows users to create cache LVs with 'lvcreate'.  An origin
or a cache pool LV must be created first.  Then, while supplying the
origin or cache pool to the lvcreate command, the cache can be created.

Ex1:
Here the cache pool is created first, followed by the origin which will
be cached.
# Create a cache pool first
~> lvcreate --type cache_pool -L 500M -n cachepool vg /dev/small_n_fast
# Then create an origin + cache LV
~> lvcreate --type cache -L 1G -n lv vg/cachepool /dev/large_n_slow

Ex2:
Here the origin is created first, followed by the cache pool - allowing
a cache LV to be created covering the origin.
# Create origin first
~> lvcreate -L 1G -n lv vg /dev/large_n_slow
# Then create the cache pool + cache LV
~> lvcreate --type cache -L 500M -n cachepool vg/lv /dev/small_n_fast

The code determines which type of LV was supplied (cache pool or origin)
by checking its type.  It ensures the right argument was given by ensuring
that the origin is larger than the cache pool.
---
 lib/activate/dev_manager.c       |   11 +++-
 lib/metadata/lv_manip.c          |  130 ++++++++++++++++++++++++++++++++++++--
 lib/metadata/merge.c             |   11 +++
 lib/metadata/metadata-exported.h |    1 +
 tools/lvcreate.c                 |   87 +++++++++++++++++++++++++-
 5 files changed, 231 insertions(+), 9 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b48ca99..9a10e74 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1912,6 +1912,10 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 1)) /* stack */
 			return_0;
 
+		if (seg->pool_lv && lv_is_cache_pool(seg->pool_lv) &&
+		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 0))
+			return_0;
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
@@ -2376,15 +2380,18 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	if (seg->external_lv &&
 	    !_add_new_external_lv_to_dtree(dm, dtree, seg->external_lv, laopts))
 		return_0;
+
 	/* Add mirror log */
 	if (seg->log_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
 		return_0;
-	/* Add thin pool metadata */
+
+	/* Add pool metadata */
 	if (seg->metadata_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->metadata_lv, laopts, NULL))
 		return_0;
-	/* Add thin pool layer */
+
+	/* Add pool layer */
 	if (seg->pool_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->pool_lv, laopts,
 				  lv_layer(seg->pool_lv)))
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index abb7c6e..3013bf8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5757,9 +5757,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if ((segtype_is_mirrored(lp->segtype) ||
-	     segtype_is_raid(lp->segtype) || segtype_is_thin(lp->segtype)) &&
-	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
+	if (!(vg->fid->fmt->features & FMT_SEGMENTS) &&
+	    (segtype_is_mirrored(lp->segtype) ||
+	     segtype_is_raid(lp->segtype) ||
+	     segtype_is_thin(lp->segtype) ||
+	     segtype_is_cache(lp->segtype))) {
 		log_error("Metadata does not support %s segments.",
 			  lp->segtype->name);
 		return NULL;
@@ -5806,7 +5808,58 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	status |= lp->permission | VISIBLE_LV;
 
-	if (seg_is_thin(lp) && lp->snapshot) {
+	if (segtype_is_cache(lp->segtype) && lp->pool) {
+		/* We have the cache_pool, create the origin with cache */
+		if (!(pool_lv = find_lv(vg, lp->pool))) {
+			log_error("Couldn't find origin volume '%s'.",
+				  lp->pool);
+			return NULL;
+		}
+
+		if (pool_lv->status & LOCKED) {
+			log_error("Caching locked devices is not supported.");
+			return NULL;
+		}
+
+		if (!lp->extents) {
+			log_error("No size given for new cache origin LV");
+			return NULL;
+		}
+
+		if (lp->extents < pool_lv->le_count) {
+			log_error("Origin size cannot be smaller than"
+				  " the cache_pool");
+			return NULL;
+		}
+
+		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "striped")))
+			return_0;
+	} else if (segtype_is_cache(lp->segtype) && lp->origin) {
+		/* We have the origin, create the cache_pool and cache */
+		if (!(org = find_lv(vg, lp->origin))) {
+			log_error("Couldn't find origin volume '%s'.",
+				  lp->origin);
+			return NULL;
+		}
+
+		if (org->status & LOCKED) {
+			log_error("Caching locked devices is not supported.");
+			return NULL;
+		}
+
+		if (!lp->extents) {
+			log_error("No size given for new cache_pool LV");
+			return NULL;
+		}
+
+		if (lp->extents > org->le_count) {
+			log_error("Cache_Pool size cannot be larger than"
+				  " the origin");
+			return NULL;
+		}
+		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache_pool")))
+			return_0;
+	} else if (seg_is_thin(lp) && lp->snapshot) {
 		if (!(org = find_lv(vg, lp->origin))) {
 			log_error("Couldn't find origin volume '%s'.",
 				  lp->origin);
@@ -6078,6 +6131,73 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	}
 
+	if (lp->cache) {
+		struct logical_volume *tmp_lv;
+
+		if (lp->origin) {
+			if (!(lvl = find_lv_in_vg(vg, lp->origin)))
+				goto revert_new_lv; // FIXME: TEST
+			org = lvl->lv;
+			pool_lv = lv;
+
+			/*
+			 * FIXME:  At this point, create_pool has created
+			 * the pool and added the data and metadata sub-LVs,
+			 * but only the metadata sub-LV is in the kernel -
+			 * a suspend/resume cycle is still necessary on the
+			 * cache_pool to actualize it in the kernel.
+			 *
+			 * Should the suspend/resume be added to create_pool?
+			 *    I say that would be cleaner, but I'm not sure
+			 *    about the effects on thinpool yet...
+			 */
+			if (!vg_write(vg) || !vg_commit(vg))
+				return_0;
+			if (vg_is_clustered(lv->vg)) {
+				if (!activate_lv_excl(cmd, lv)) {
+					log_error("Failed to activate pool %s.",
+						  lv->name);
+					return_0;
+					// FIXME: better error handling, like this
+					goto deactivate_and_revert_new_lv;
+				}
+			} else {
+				/*
+				 * Suspend cleared plain metadata LV
+				 * but now already commited as pool LV
+				 * and resume it as a pool LV.
+				 *
+				 * This trick avoids collision with udev watch
+				 * rule.
+				 */
+				if (!suspend_lv(cmd, lv)) {
+					log_error("Failed to suspend pool %s.",
+						  lv->name);
+					return_0;
+					// FIXME: better error handling...
+					goto deactivate_and_revert_new_lv;
+				}
+				if (!resume_lv(cmd, lv)) {
+					log_error("Failed to resume pool %s.",
+						  lv->name);
+					return_0;
+					// FIXME: better error handling...
+					goto deactivate_and_revert_new_lv;
+				}
+			}
+		} else {
+			if (!(lvl = find_lv_in_vg(vg, lp->pool)))
+				goto revert_new_lv; // FIXME: TEST
+			pool_lv = lvl->lv;
+			org = lv;
+		}
+
+		if (!(tmp_lv = lv_cache_create(pool_lv, org)))
+			goto revert_new_lv; // FIXME: test
+
+		lv = tmp_lv;
+	}
+
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
@@ -6317,7 +6437,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 	struct logical_volume *lv;
 
 	/* Create thin pool first if necessary */
-	if (lp->create_pool && !seg_is_cache_pool(lp)) {
+	if (lp->create_pool && !seg_is_cache_pool(lp) && !seg_is_cache(lp)) {
 		if (!seg_is_thin_pool(lp) &&
 		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 			return_0;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 5ef2eea..e636580 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -294,6 +294,17 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 						inc_error_count;
 					}
 				}
+			} else if (seg_is_cache(seg)) {
+				if (!lv_is_cache(lv)) {
+					log_error("LV %s is missing cache flag for segment %u",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+				if (!seg->pool_lv) {
+					log_error("LV %s: segment %u is missing cache_pool LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
 			} else {
 				if (seg->pool_lv) {
 					log_error("LV %s: segment %u must not have thin pool LV set",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e296453..8283383 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -749,6 +749,7 @@ static inline int is_change_activating(activation_change_t change)
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
+	int cache;
 	int snapshot; /* snap */
 	int thin; /* thin */
 	int create_pool; /* thin */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 3210869..4d8ff32 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -73,8 +73,45 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			lp->lv_name = ptr + 1;
 	}
 
-	/* Need an origin? */
-	if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
+	if (seg_is_cache(lp)) {
+		/*
+		 * We are looking for the origin or cache_pool LV.
+		 * Could be in the form 'lv' or 'vg/lv'
+		 *
+		 * We store the lv name in 'lp->origin' for now, but
+		 * it must be accessed later (when we can look-up the
+		 * LV in the VG) whether it is truly the origin that
+		 * was specified, or whether it is the cache_pool.
+		 */
+		if (!argc) {
+			log_error("Please specify a logical volume to act as "
+				  "the origin or cache_pool.");
+			return 0;
+		}
+
+		lp->origin = skip_dev_dir(cmd, argv[0], NULL);
+		if (strrchr(lp->origin, '/')) {
+			if (!_set_vg_name(lp, extract_vgname(cmd, lp->origin)))
+				return_0;
+
+			/* Strip the volume group from the origin */
+			if ((ptr = strrchr(lp->origin, (int) '/')))
+				lp->origin = ptr + 1;
+		}
+
+		if (!lp->vg_name &&
+		    !_set_vg_name(lp, extract_vgname(cmd, NULL)))
+			return_0;
+
+		if (!lp->vg_name) {
+			log_error("The origin or cache_pool name should include"
+				  " the volume group.");
+			return 0;
+		}
+
+		lp->cache = 1;
+		(*pargv)++, (*pargc)--;
+	} else if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		/* argv[0] might be origin or vg/origin */
 		if (!argc) {
 			log_error("Please specify a logical volume to act as "
@@ -228,6 +265,49 @@ static int _determine_snapshot_type(struct volume_group *vg,
 }
 
 /*
+ * _determine_cache_argument
+ * @vg
+ * @lp
+ *
+ * 'lp->origin' is set with an LV that could be either the origin
+ * or the cache_pool of the cached LV which is being created.  This
+ * function determines which it is and sets 'lp->origin' or
+ * 'lp->pool' appropriately.
+ */
+static int _determine_cache_argument(struct volume_group *vg,
+				     struct lvcreate_params *lp)
+{
+	struct lv_list *lvl;
+
+	if (!seg_is_cache(lp)) {
+		log_error(INTERNAL_ERROR
+			  "Unable to determine cache argument on %s segtype",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
+		log_error("LV %s not found in Volume group %s.",
+			  lp->origin, vg->name);
+		return 0;
+	}
+
+	if (lv_is_cache_pool(lvl->lv)) {
+		lp->pool = lp->origin;
+		lp->origin = NULL;
+	} else {
+		lp->pool = NULL;
+		lp->create_pool = 1;
+		lp->poolmetadataspare = arg_int_value(vg->cmd,
+						      poolmetadataspare_ARG,
+						      DEFAULT_POOL_METADATA_SPARE);
+		lp->origin = lp->origin;
+	}
+
+	return 1;
+}
+
+/*
  * Update extents parameters based on other parameters which affect the size
  * calculation.
  * NOTE: We must do this here because of the percent_t typedef and because we
@@ -1202,6 +1282,9 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
 		goto_out;
 
+	if (seg_is_cache(&lp) && !_determine_cache_argument(vg, &lp))
+		goto_out;
+
 	/*
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
-- 
1.7.7.6


