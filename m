From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  5 Feb 2014 12:30:23 +0000 (UTC)
Subject: master - cache: Code to allow the create/remove of cache LVs
Message-ID: <20140205123023.51F776061D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96626f64fa499fb45dfc1afb39b86b70b8d3d9a4
Commit:        96626f64fa499fb45dfc1afb39b86b70b8d3d9a4
Parent:        97be8b3482a0c566d5fa529321bd035526974c96
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 4 16:50:16 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 4 16:50:16 2014 -0600

cache: Code to allow the create/remove of cache LVs

This patch allows users to create cache LVs with 'lvcreate'.  An origin
or a cache pool LV must be created first.  Then, while supplying the
origin or cache pool to the lvcreate command, the cache can be created.

Ex1:
Here the cache pool is created first, followed by the origin which will
be cached.
~> lvcreate --type cache_pool -L 500M -n cachepool vg /dev/small_n_fast
~> lvcreate --type cache -L 1G -n lv vg/cachepool /dev/large_n_slow

Ex2:
Here the origin is created first, followed by the cache pool - allowing
a cache LV to be created covering the origin.
~> lvcreate -L 1G -n lv vg /dev/large_n_slow
~> lvcreate --type cache -L 500M -n cachepool vg/lv /dev/small_n_fast

The code determines which type of LV was supplied (cache pool or origin)
by checking its type.  It ensures the right argument was given by ensuring
that the origin is larger than the cache pool.

If the user wants to remove just the cache for an LV.  They specify
the LV's associated cache pool when removing:
~> lvremove vg/cachepool

If the user wishes to remove the origin, but leave the cachepool to be
used for another LV, they specify the cache LV.
~> lvremove vg/lv

In order to remove it all, specify both LVs.

This patch also includes tests to create and remove cache pools and
cache LVs.
---
 lib/activate/dev_manager.c       |   11 +++-
 lib/metadata/lv_manip.c          |  130 ++++++++++++++++++++++++++++++++++--
 lib/metadata/merge.c             |   11 +++
 lib/metadata/metadata-exported.h |    1 +
 test/shell/lvcreate-cache.sh     |  135 ++++++++++++++++++++++++++++++++++++++
 tools/lvcreate.c                 |   87 ++++++++++++++++++++++++-
 6 files changed, 365 insertions(+), 10 deletions(-)

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
index e85b3ce..96515d7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -542,6 +542,8 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s,
 						uint32_t area_reduction, int with_discard)
 {
+	struct lv_segment *cache_seg;
+
 	if (seg_type(seg, s) == AREA_UNASSIGNED)
 		return 1;
 
@@ -558,7 +560,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
-	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
+	if (seg_is_cache(seg) ||
+	    (seg_lv(seg, s)->status & MIRROR_IMAGE) ||
 	    (seg_lv(seg, s)->status & THIN_POOL_DATA) ||
 	    (seg_lv(seg, s)->status & CACHE_POOL_DATA)) {
 		if (!lv_reduce(seg_lv(seg, s), area_reduction))
@@ -566,6 +569,15 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
+	if (seg_is_cache_pool(seg) &&
+	    !dm_list_empty(&seg->lv->segs_using_this_lv)) {
+		if (!(cache_seg = get_only_segment_using_this_lv(seg->lv)))
+			return_0;
+
+		if (!lv_cache_remove(cache_seg->lv))
+			return_0;
+	}
+
 	if (seg_lv(seg, s)->status & RAID_IMAGE) {
 		/*
 		 * FIXME: Use lv_reduce not lv_remove
@@ -4598,6 +4610,21 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
+	/*
+	 * If we are removing a cache_pool, we must first unlink
+	 * it from any origins (i.e. remove the cache layer).
+	 *
+	 * If the cache_pool is not linked, we can simply proceed
+	 * to remove it.
+	 */
+	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
+		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+
+		if (!lv_cache_remove(cache_seg->lv))
+			return_0;
+	}
+
 	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
 		log_error("Can't remove logical volume %s used by a cache_pool.",
 			  lv->name);
@@ -5122,6 +5149,8 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	    parent->le_count != layer_lv->le_count)
 		return_0;
 
+	//FIXME: why do we empty the parent?  It removes everything below.
+	//This makes the function unusable for 'lv_cache_remove'
 	if (!lv_empty(parent))
 		return_0;
 
@@ -5758,9 +5787,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
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
@@ -5807,7 +5838,58 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
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
@@ -6079,6 +6161,42 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	}
 
+	if (lp->cache) {
+		struct logical_volume *tmp_lv;
+
+		if (lp->origin) {
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
+			if (!vg_write(vg) || !suspend_lv(cmd, lv) ||
+			    !vg_commit(vg) || !resume_lv(cmd, lv))
+				goto deactivate_and_revert_new_lv;
+
+			if (!(lvl = find_lv_in_vg(vg, lp->origin)))
+				goto deactivate_and_revert_new_lv;
+			org = lvl->lv;
+			pool_lv = lv;
+		} else {
+			if (!(lvl = find_lv_in_vg(vg, lp->pool)))
+				goto deactivate_and_revert_new_lv;
+			pool_lv = lvl->lv;
+			org = lv;
+		}
+
+		if (!(tmp_lv = lv_cache_create(pool_lv, org)))
+			goto deactivate_and_revert_new_lv;
+
+		lv = tmp_lv;
+	}
+
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
@@ -6318,7 +6436,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
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
index 1e16c34..faa8217 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -750,6 +750,7 @@ static inline int is_change_activating(activation_change_t change)
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
+	int cache;
 	int snapshot; /* snap */
 	int thin; /* thin */
 	int create_pool; /* thin */
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
new file mode 100644
index 0000000..39f95c1
--- /dev/null
+++ b/test/shell/lvcreate-cache.sh
@@ -0,0 +1,135 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux target_at_least dm-cache 1 2 0 || skip
+
+# Skip in cluster for now, but should test EX mode...
+test -e LOCAL_CLVMD && skip
+
+aux prepare_vg 5 80
+
+####################
+# Cache_Pool creation
+####################
+
+# Full CLI (the advertised form)
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvremove -ff $vg/${lv}_cache_pool
+
+# Shorthand CLI (not advertised) -- not yet implemented
+# lvcreate --cache -l 1 vg
+# lvremove -ff $vg
+
+# Shorthand CLI (not advertised) -- not yet implemented
+# lvcreate -H -l 1 vg
+# lvremove -ff $vg
+
+################
+# Cache creation
+# Creating a cache is a two phase process
+# - first, cache_pool (or origin)
+# - then, the cache LV (lvcreate distinguishes supplied origin vs cache_pool)
+################
+
+# Create/remove cache_pool
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvremove -ff $vg
+
+# Create cache_pool, then origin with cache, then remove all
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
+lvremove -ff $vg
+
+# Create cache_pool, then origin with cache, then remove cache_pool/cache
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
+lvremove -ff $vg/${lv}_cache_pool
+lvremove -ff $vg/$lv1
+
+# Create cache_pool, then origin with cache, then remove origin
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
+lvremove -ff $vg/$lv1
+lvremove -ff $vg/${lv}_cache_pool
+
+# Shorthand CLI (cache_pool exists, create origin w/ cache)
+#lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+#lvcreate --cache -l 2 $vg/${lv}_cache_pool -n $lv1
+#lvremove -ff $vg
+
+# Shorthand CLI (cache_pool exists, create origin w/ cache)
+#lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+#lvcreate -H -l 2 $vg/${lv}_cache_pool -n $lv1
+#lvremove -ff $vg
+
+# Create origin, then cache_pool and cache
+lvcreate -l 2 -n $lv1 $vg
+lvcreate --type cache -l 1 $vg/$lv1
+lvremove -ff $vg
+
+# Shorthand CLI (origin exists, create cache_pool and cache)
+#lvcreate -l 1 -n $lv1 $vg
+#lvcreate --cache -l 2 $vg/$lv1
+#lvremove -ff $vg
+
+# Shorthand CLI (origin exists, create cache_pool and cache)
+#lvcreate -l 1 -n $lv1 $vg
+#lvcreate -H -l 2 $vg/$lv1
+#lvremove -ff $vg
+
+
+################################################
+# Repeat key tests with 'writethrough' cachemode
+################################################
+# Create/remove cache_pool
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg --cachemode writethrough
+lvremove -ff $vg
+
+# Create cache_pool, then origin with cache, then remove all
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
+lvremove -ff $vg
+
+# Create cache_pool, then origin with cache, then remove cache_pool/cache
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
+lvremove -ff $vg/${lv}_cache_pool
+lvremove -ff $vg/$lv1
+
+# Create cache_pool, then origin with cache, then remove origin
+lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
+lvremove -ff $vg/$lv1
+lvremove -ff $vg/${lv}_cache_pool
+
+# Create origin, then cache_pool and cache
+lvcreate -l 2 -n $lv1 $vg
+lvcreate --type cache -l 1 $vg/$lv1 --cachemode writethrough
+lvremove -ff $vg
+
+
+##############################
+# Test things that should fail
+##############################
+
+# Attempt to create smaller cache than origin should fail
+lvcreate -l 1 -n $lv1 $vg
+not lvcreate --type cache -l 2 $vg/$lv1
+lvremove -ff $vg
+
+
+# Option testing
+# --chunksize
+# --cachepolicy
+# --poolmetadatasize
+# --poolmetadataspare
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e14ce7a..638a868 100644
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
@@ -247,6 +284,49 @@ static int _lvcreate_update_pool_params(struct volume_group *vg,
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
@@ -1164,6 +1244,9 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
 		goto_out;
 
+	if (seg_is_cache(&lp) && !_determine_cache_argument(vg, &lp))
+		goto_out;
+
 	/*
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?


