From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Jun 2016 22:00:23 +0000 (UTC)
Subject: master - lvconvert: remove unused code
Message-ID: <20160629220023.556BE60562@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=802ed9d4597443e21086b392d9ee160f6d99dde9
Commit:        802ed9d4597443e21086b392d9ee160f6d99dde9
Parent:        2282f53ac73d33311661226894ee90e72772f0db
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 29 16:59:32 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 29 16:59:32 2016 -0500

lvconvert: remove unused code

This code became unused with the previous commit 2282f5.
---
 tools/lvconvert.c |  221 -----------------------------------------------------
 1 files changed, 0 insertions(+), 221 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1a863a4..4808090 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2023,68 +2023,6 @@ static int _lvconvert_split_cached(struct cmd_context *cmd,
 	return 1;
 }
 
-#if 0
-static int _lvconvert_splitcache(struct cmd_context *cmd,
-				 struct logical_volume *lv,
-				 struct lvconvert_params *lp)
-{
-	struct lv_segment *seg;
-
-	if (lv_is_thin_pool(lv))
-		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
-
-	/* When passed used cache-pool of used cached LV -> split cached LV */
-	if (lv_is_cache_pool(lv) &&
-	    (dm_list_size(&lv->segs_using_this_lv) == 1) &&
-	    (seg = get_only_segment_using_this_lv(lv)) &&
-	    seg_is_cache(seg))
-		lv = seg->lv;
-
-	/* Supported LV types for split */
-	if (!lv_is_cache(lv)) {
-		log_error("Split of %s is not cache.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!_lvconvert_split_cached(cmd, lv))
-		return_0;
-
-	return 1;
-}
-#endif
-
-#if 0
-static int _lvconvert_split(struct cmd_context *cmd,
-			    struct logical_volume *lv,
-			    struct lvconvert_params *lp)
-{
-	struct lv_segment *seg;
-
-	if (lv_is_thin_pool(lv) &&
-	    lv_is_cache(seg_lv(first_seg(lv), 0)))
-		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
-
-	/* When passed used cache-pool of used cached LV -> split cached LV */
-	if (lv_is_cache_pool(lv) &&
-	    (dm_list_size(&lv->segs_using_this_lv) == 1) &&
-	    (seg = get_only_segment_using_this_lv(lv)) &&
-	    seg_is_cache(seg))
-		lv = seg->lv;
-
-	/* Supported LV types for split */
-	if (lv_is_cache(lv)) {
-		if (!_lvconvert_split_cached(cmd, lv))
-			return_0;
-	/* Add more types here */
-	} else {
-		log_error("Split of %s is unsupported.", display_lvname(lv));
-		return 0;
-	}
-
-	return 1;
-}
-#endif
-
 static int _lvconvert_uncache(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
@@ -3341,165 +3279,6 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	return 1;
 }
 
-#if 0
-static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
-		      struct lvconvert_params *lp)
-{
-	struct logical_volume *origin = NULL;
-	struct dm_list *failed_pvs;
-
-	if (lv_is_locked(lv)) {
-		log_error("Cannot convert locked LV %s.", display_lvname(lv));
-		return ECMD_FAILED;
-	}
-
-	if (lv_is_cow(lv) && !lp->merge_snapshot && !lp->splitsnapshot) {
-		log_error("Cannot convert snapshot logical volume %s.",
-			  display_lvname(lv));
-		return ECMD_FAILED;
-	}
-
-	if (lv_is_pvmove(lv)) {
-		log_error("Unable to convert pvmove LV %s.",
-			  display_lvname(lv));
-		return ECMD_FAILED;
-	}
-
-	if (lp->splitsnapshot) {
-		if (!_lvconvert_splitsnapshot(cmd, lv, lp))
-			return_ECMD_FAILED;
-		return ECMD_PROCESSED;
-	}
-
-	if (lp->splitcache) {
-		if (!_lvconvert_splitcache(cmd, lv, lp))
-			return_ECMD_FAILED;
-		return ECMD_PROCESSED;
-	}
-
-	if (lp->split) {
-		if (!_lvconvert_split(cmd, lv, lp))
-			return_ECMD_FAILED;
-		return ECMD_PROCESSED;
-	}
-
-	if (lp->uncache) {
-		if (!_lvconvert_uncache(cmd, lv, lp))
-			return_ECMD_FAILED;
-		return ECMD_PROCESSED;
-	}
-
-	/* Validate origin prior we start conversion of pool */
-	if (lp->cache &&
-	    !validate_lv_cache_create_origin(lv))
-		return_ECMD_FAILED;
-
-	if (lp->thin) {
-		if (lv_is_cache_type(lv) ||
-		    lv_is_pool(lv) ||
-		    lv_is_thin_pool_data(lv) ||
-		    lv_is_thin_pool_metadata(lv)) {
-			log_error("Can't convert %s %s to external origin.",
-				  first_seg(lv)->segtype->name,
-				  display_lvname(lv));
-			return ECMD_FAILED;
-		}
-	}
-
-	if (lp->repair) {
-		if (lv_is_pool(lv)) {
-			if (lv_is_cache_pool(lv)) {
-				log_error("Repair for cache pool %s not yet implemented.",
-					  display_lvname(lv));
-				return ECMD_FAILED;
-			}
-			if (!_lvconvert_thin_pool_repair(cmd, lv, lp))
-				return_ECMD_FAILED;
-			return ECMD_PROCESSED;
-		}
-		if (!lv_is_mirrored(lv) && !lv_is_raid(lv)) {
-			if (arg_is_set(cmd, usepolicies_ARG))
-				return ECMD_PROCESSED; /* nothing to be done here */
-			log_error("Cannot repair logical volume %s of segtype %s.",
-				  display_lvname(lv), lvseg_name(first_seg(lv)));
-			return ECMD_FAILED;
-		}
-	}
-
-	/* forward splitmirror operations to the cache origin, which may be raid
-	 * or old-style mirror */
-	if (lp->keep_mimages && lv_is_cache_type(lv) &&
-	    (origin = seg_lv(first_seg(lv), 0)) && lv_is_cache_origin(origin)) {
-		log_warn("WARNING: Selected operation does not work with cache-type LVs.");
-		log_warn("WARNING: Proceeding using the cache origin volume %s instead.",
-			 display_lvname(origin));
-		lv = origin;
-	}
-
-	if (!lp->segtype) {
-		/* segtype not explicitly set in _read_params */
-		lp->segtype = first_seg(lv)->segtype;
-
-		/*
-		 * If we are converting to mirror/raid1 and
-		 * the segtype was not specified, then we need
-		 * to consult the default.
-		 */
-		if (lp->mirrors_supplied && !lv_is_mirrored(lv)) {
-			if (!(lp->segtype = get_segtype_from_string(cmd, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL))))
-				return_ECMD_FAILED;
-		}
-	}
-	if (lp->merge_snapshot) {
-		if ((lv_is_thin_volume(lv) && !_lvconvert_merge_thin_snapshot(cmd, lv, lp)) ||
-		    (!lv_is_thin_volume(lv) && !_lvconvert_merge_old_snapshot(cmd, lv, lp))) {
-			log_print_unless_silent("Unable to merge volume %s into its origin.",
-						display_lvname(lv));
-			return ECMD_FAILED;
-		}
-	} else if (lp->snapshot) {
-		if (!_lvconvert_snapshot(cmd, lv, lp))
-			return_ECMD_FAILED;
-	} else if (segtype_is_pool(lp->segtype) || lp->thin || lp->cache) {
-		if (!_lvconvert_pool(cmd, lv, lp))
-			return_ECMD_FAILED;
-
-		if ((lp->thin && !_lvconvert_thin(cmd, lv, lp)) ||
-		    (lp->cache && !_lvconvert_cache(cmd, lv, lp)))
-			return_ECMD_FAILED;
-	} else if (segtype_is_raid(lp->segtype) ||
-		   (lv->status & RAID) || lp->merge_mirror) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-
-		if (!_lvconvert_raid(lv, lp))
-			return_ECMD_FAILED;
-
-		if (!(failed_pvs = _failed_pv_list(lv->vg)))
-			return_ECMD_FAILED;
-
-		/* If repairing and using policies, remove missing PVs from VG */
-		if (lp->repair && arg_is_set(cmd, usepolicies_ARG))
-			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	} else if (lp->mirrors_supplied || lp->keep_mimages || lv_is_mirrored(lv)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-
-		if (!_lvconvert_mirrors(cmd, lv, lp))
-			return_ECMD_FAILED;
-
-		if (!(failed_pvs = _failed_pv_list(lv->vg)))
-			return_ECMD_FAILED;
-
-		/* If repairing and using policies, remove missing PVs from VG */
-		if (lp->repair && arg_is_set(cmd, usepolicies_ARG))
-			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	}
-
-	return ECMD_PROCESSED;
-}
-#endif
-
 /*
  * Functions called to perform a specific operation on a specific LV type.
  *


