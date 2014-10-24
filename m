From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:06 +0000 (UTC)
Subject: master - lvcreate: new validation code
Message-ID: <20141024144106.090C260CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d13239b0547e09def4b58b0f49bd0252f459d431
Commit:        d13239b0547e09def4b58b0f49bd0252f459d431
Parent:        51a29e60564d5379b38ee4688bca5eb9b844c410
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 24 15:26:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

lvcreate: new validation code

Refactor lvcreate code.

Prefer to use arg_outside_list_is_set() so we get automatic 'white-list'
validation of supported options with different segment types.

Drop used lp->cache, lp->cache and use seg_is_cache(), seg_is_thin()

Draw clear border where is the last moment we could change create
segment type.

When segment type is given with --type - do not allow it to be changed
later.

Put together tests related to individual segment types.

Finish cache conversion at proper part of lv_manip code after
the vg_metadata are written - so we could correcly clean-up created
stripe LV for cache volume.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |  364 +++++++-------
 lib/metadata/metadata-exported.h |    3 +-
 liblvm/lvm_lv.c                  |    1 -
 tools/lvcreate.c                 | 1061 ++++++++++++++++++++++----------------
 5 files changed, 799 insertions(+), 631 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa88ddc..320bca3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Refactor lvcreate towards more complete validation of all supported options.
   Support lvcreate --type linear.
   Improve _should_wipe_lv() to warn with message.
   Inform about temporarily created volumes only in verbose mode.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 277a51d..f2cf404 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6604,6 +6604,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
 	uint64_t status = lp->permission | VISIBLE_LV;
+	const struct segment_type *create_segtype = lp->segtype;
 	struct logical_volume *lv, *origin_lv = NULL;
 	struct logical_volume *pool_lv;
 	struct logical_volume *tmp_lv;
@@ -6672,7 +6673,58 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
-	if (seg_is_cache(lp)) {
+	if (!lp->extents && !seg_is_thin_volume(lp)) {
+		log_error(INTERNAL_ERROR "Unable to create new logical volume with no extents.");
+		return_NULL;
+	}
+
+	if (seg_is_pool(lp) &&
+	    ((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
+		log_error("Unable to create %s smaller than 1 chunk.",
+			  lp->segtype->name);
+		return NULL;
+	}
+
+	if (!seg_is_virtual(lp) && !lp->approx_alloc &&
+	    (vg->free_count < lp->extents)) {
+		log_error("Volume group \"%s\" has insufficient free space "
+			  "(%u extents): %u required.",
+			  vg->name, vg->free_count, lp->extents);
+		return NULL;
+	}
+
+	if ((lp->alloc != ALLOC_ANYWHERE) && (lp->stripes > dm_list_size(lp->pvh))) {
+		log_error("Number of stripes (%u) must not exceed "
+			  "number of physical volumes (%d)", lp->stripes,
+			  dm_list_size(lp->pvh));
+		return NULL;
+	}
+
+	if (seg_is_pool(lp))
+		status |= LVM_WRITE; /* Pool is always writable */
+
+	if (seg_is_cache_pool(lp) && lp->origin_name) {
+		/* Converting exiting origin and creating cache pool */
+		if (!(origin_lv = find_lv(vg, lp->origin_name))) {
+			log_error("Cache origin volume %s not found in Volume group %s.",
+				  lp->origin_name, vg->name);
+			return NULL;
+		}
+
+		if (!validate_lv_cache_create(NULL, origin_lv))
+			return_NULL;
+
+		/* Validate cache origin is exclusively active */
+		if (vg_is_clustered(origin_lv->vg) &&
+		    locking_is_clustered() &&
+		    locking_supports_remote_queries() &&
+		    lv_is_active(origin_lv) &&
+		    !lv_is_active_exclusive(origin_lv)) {
+			log_error("Cannot cache not exclusively active origin volume %s.",
+				  display_lvname(origin_lv));
+			return NULL;
+		}
+	} else if (seg_is_cache(lp)) {
 		if (!lp->pool_name) {
 			log_error(INTERNAL_ERROR "Cannot create thin volume without thin pool.");
 			return NULL;
@@ -6683,47 +6735,83 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (lv_is_locked(pool_lv)) {
-			log_error("Caching locked devices is not supported.");
+		if (!lv_is_cache_pool(pool_lv)) {
+			log_error("Logical volume %s is not a cache pool.",
+				  display_lvname(pool_lv));
 			return NULL;
 		}
 
-		if (!lp->extents) {
-			log_error("No size given for new cache origin LV.");
+		if (lv_is_locked(pool_lv)) {
+			log_error("Cannot use locked cache pool %s.",
+				  display_lvname(pool_lv));
 			return NULL;
 		}
 
-		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "striped")))
+		/* Create cache origin for cache pool */
+		/* TODO: eventually support raid/mirrors with -m */
+		if (!(create_segtype = get_segtype_from_string(vg->cmd, "striped")))
 			return_0;
-	} else if (seg_is_thin(lp) && lp->snapshot) {
-		if (!lp->origin_name) {
-			log_error(INTERNAL_ERROR "Origin LV is not defined.");
-			return 0;
+	} else if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
+		/* FIXME: this will not pass cluster lock! */
+		init_mirror_in_sync(lp->nosync);
+
+		if (lp->nosync) {
+			log_warn("WARNING: New %s won't be synchronised. "
+				 "Don't read what you didn't write!",
+				 lp->segtype->name);
+			status |= LV_NOTSYNCED;
 		}
-		if (!(origin_lv = find_lv(vg, lp->origin_name))) {
-			log_error("Couldn't find origin volume '%s'.",
-				  lp->origin_name);
+
+		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
+							      lp->extents,
+							      lp->region_size, 0);
+	} else if (seg_is_thin_volume(lp)) {
+		if (!lp->pool_name) {
+			log_error(INTERNAL_ERROR "Cannot create thin volume without thin pool.");
 			return NULL;
 		}
 
-		if (lv_is_locked(origin_lv)) {
-			log_error("Snapshots of locked devices are not supported.");
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
+			log_error("Unable to find existing pool LV %s in VG %s.",
+				  lp->pool_name, vg->name);
 			return NULL;
 		}
 
-		lp->voriginextents = origin_lv->le_count;
-	} else if (lp->snapshot) {
-		if (!activation()) {
-			log_error("Can't create snapshot without using "
-				  "device-mapper kernel driver");
+		if (!lv_is_thin_pool(pool_lv)) {
+			log_error("Logical volume %s is not a thin pool.",
+				  display_lvname(pool_lv));
 			return NULL;
 		}
 
-		/* Must zero cow */
-		status |= LVM_WRITE;
+		if (lv_is_locked(pool_lv)) {
+			log_error("Cannot use locked thin pool %s.",
+				  display_lvname(pool_lv));
+			return NULL;
+		}
 
-		if (!lp->voriginsize) {
+		thin_name = lp->pool_name;
 
+		if (lp->origin_name) {
+			if (!(origin_lv = find_lv(vg, lp->origin_name))) {
+				log_error("Couldn't find origin volume '%s'.",
+					  lp->origin_name);
+				return NULL;
+			}
+
+			if (lv_is_locked(origin_lv)) {
+				log_error("Snapshots of locked devices are not supported.");
+				return NULL;
+			}
+
+			/* For thin snapshot we must have matching pool */
+			if (lv_is_thin_volume(origin_lv) &&
+			    (strcmp(first_seg(origin_lv)->pool_lv->name, lp->pool_name) == 0))
+				thin_name = origin_lv->name;
+
+			lp->voriginextents = origin_lv->le_count;
+		}
+	} else if (lp->snapshot) {
+		if (!lp->voriginsize) {
 			if (!(origin_lv = find_lv(vg, lp->origin_name))) {
 				log_error("Couldn't find origin volume '%s'.",
 					  lp->origin_name);
@@ -6771,86 +6859,28 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 		}
-	}
-
-	if (!seg_is_thin_volume(lp) && !lp->extents) {
-		log_error("Unable to create new logical volume with no extents");
-		return NULL;
-	}
-
-	if (seg_is_pool(lp)) {
-		if (((uint64_t)lp->extents * vg->extent_size < lp->chunk_size)) {
-			log_error("Unable to create %s smaller than 1 chunk.",
-				  lp->segtype->name);
-			return NULL;
-		}
-	}
 
-	if (lp->snapshot && !seg_is_thin(lp) &&
-	    !cow_has_min_chunks(vg, lp->extents, lp->chunk_size))
-                return NULL;
+		if (!cow_has_min_chunks(vg, lp->extents, lp->chunk_size))
+			return_NULL;
 
-	if (!seg_is_virtual(lp) &&
-	    vg->free_count < lp->extents && !lp->approx_alloc) {
-		log_error("Volume group \"%s\" has insufficient free space "
-			  "(%u extents): %u required.",
-			  vg->name, vg->free_count, lp->extents);
-		return NULL;
-	}
+		/* The snapshot segment gets created later */
+		if (!(create_segtype = get_segtype_from_string(cmd, "striped")))
+			return_NULL;
 
-	if (lp->stripes > dm_list_size(lp->pvh) && lp->alloc != ALLOC_ANYWHERE) {
-		log_error("Number of stripes (%u) must not exceed "
-			  "number of physical volumes (%d)", lp->stripes,
-			  dm_list_size(lp->pvh));
-		return NULL;
+		/* Must zero cow */
+		status |= LVM_WRITE;
+		lp->zero = 1;
+		lp->wipe_signatures = 0;
 	}
 
-	/* The snapshot segment gets created later */
-	if (lp->snapshot && !seg_is_thin(lp) &&
-	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
-		return_NULL;
-
 	if (!archive(vg))
 		return_NULL;
 
 	if (seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
-		if (!lp->pool_name) {
-			log_error(INTERNAL_ERROR "Undefined pool for thin volume segment.");
-			return NULL;
-		}
-
-		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
-			log_error("Unable to find existing pool LV %s in VG %s.",
-				  lp->pool_name, vg->name);
-			return NULL;
-		}
-
 		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
 		    !update_pool_lv(pool_lv, 1))
 			return_NULL;
-
-		/* For thin snapshot we must have matching pool */
-		if (origin_lv && lv_is_thin_volume(origin_lv) && (!lp->pool_name ||
-		    (strcmp(first_seg(origin_lv)->pool_lv->name, lp->pool_name) == 0)))
-			thin_name = origin_lv->name;
-		else
-			thin_name = lp->pool_name;
-	}
-
-	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
-		init_mirror_in_sync(lp->nosync);
-
-		if (lp->nosync) {
-			log_warn("WARNING: New %s won't be synchronised. "
-				 "Don't read what you didn't write!",
-				 lp->segtype->name);
-			status |= LV_NOTSYNCED;
-		}
-
-		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
-							      lp->extents,
-							      lp->region_size, 0);
 	}
 
 	if (!(lv = lv_create_empty(new_lv_name ? : "lvol%d", NULL,
@@ -6862,7 +6892,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		log_debug_metadata("Setting read ahead sectors %u.", lv->read_ahead);
 	}
 
-	if (!seg_is_thin_pool(lp) && lp->minor >= 0) {
+	if (!seg_is_pool(lp) && lp->minor >= 0) {
 		lv->major = lp->major;
 		lv->minor = lp->minor;
 		lv->status |= FIXED_MINOR;
@@ -6872,7 +6902,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	dm_list_splice(&lv->tags, &lp->tags);
 
-	if (!lv_extend(lv, lp->segtype,
+	if (!lv_extend(lv, create_segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
 		       seg_is_pool(lp) ? lp->pool_metadata_extents : lp->region_size,
@@ -6915,7 +6945,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * Check if using 'external origin' or the 'normal' snapshot
 		 * within the same thin pool
 		 */
-		if (lp->snapshot && (first_seg(origin_lv)->pool_lv != pool_lv)) {
+		if (origin_lv && (first_seg(origin_lv)->pool_lv != pool_lv)) {
 			if (!pool_supports_external_origin(first_seg(pool_lv), origin_lv))
 				return_0;
 			if (origin_lv->status & LVM_WRITE) {
@@ -6960,56 +6990,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE))
 		lp->activate = CHANGE_AN;
 
-	/*
-	 * Check if this is conversion inside lvcreate
-	 * Either we have origin or pool and created cache origin LV
-	 */
-	if (lp->cache &&
-	    (lp->origin_name || (lp->pool_name && !lv_is_cache_pool(lv)))) {
-		if (lp->origin_name) {
-			if (!(origin_lv = find_lv(vg, lp->origin_name)))
-				goto deactivate_and_revert_new_lv;
-			pool_lv = lv; /* Cache pool is created */
-		} else if (lp->pool_name) {
-			if (!(pool_lv = find_lv(vg, lp->pool_name)))
-				goto deactivate_and_revert_new_lv;
-			origin_lv = lv; /* Cached origin is created */
-		}
-
-		if (!(tmp_lv = lv_cache_create(pool_lv, origin_lv)))
-			goto deactivate_and_revert_new_lv;
-
-		/* From here we cannot deactive_and_revert! */
-		lv = tmp_lv;
-
-		/*
-		 * We need to check if origin is active and in
-		 * that case reload cached LV.
-		 * There is no such problem with cache pool
-		 * since it cannot be activated.
-		 */
-		if (lp->origin_name && lv_is_active(lv)) {
-			if (!is_change_activating(lp->activate)) {
-				/* User requested to create inactive cached volume */
-				if (deactivate_lv(cmd, lv)) {
-					log_error("Failed to deactivate %s.", display_lvname(lv));
-					return NULL;
-				}
-			} else if (vg_is_clustered(lv->vg) &&
-				   locking_is_clustered() &&
-				   locking_supports_remote_queries() &&
-				   !lv_is_active_exclusive(lv)) {
-				log_error("Only exclusively active %s could be converted.", display_lvname(lv));
-				return NULL;
-			} else {
-				/* With exclusively active origin just reload */
-				if (!lv_update_and_reload(lv))
-					return_NULL;
-				goto out; /* converted */
-			}
-		}
-	}
-
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		if (seg_is_pool(lp)) {
@@ -7027,11 +7007,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		goto out;
 	}
 
-	if (lv_is_cache_pool(lv)) {
-		log_verbose("Cache pool is prepared.");
-		goto out;
-	}
-
 	/* Do not scan this LV until properly zeroed/wiped. */
 	if (_should_wipe_lv(lp, lv, 0))
 		lv->status |= LV_NOSCAN;
@@ -7039,7 +7014,18 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lp->temporary)
 		lv->status |= LV_TEMPORARY;
 
-	if (lv_is_thin_volume(lv)) {
+	if (seg_is_cache(lp)) {
+		/* TODO: support remote exclusive activation? */
+		if (is_change_activating(lp->activate) &&
+		    !activate_lv_excl_local(cmd, lv)) {
+			log_error("Aborting. Failed to activate LV %s locally exclusively.",
+				  display_lvname(lv));
+			goto revert_new_lv;
+		}
+	} else if (lv_is_cache_pool(lv)) {
+		/* Cache pool cannot be actived and zeroed */
+		log_very_verbose("Cache pool is prepared.");
+	} else if (lv_is_thin_volume(lv)) {
 		/* For snapshot, suspend active thin origin first */
 		if (origin_lv && lv_is_active(origin_lv) && lv_is_thin_volume(origin_lv)) {
 			if (!suspend_lv_origin(cmd, origin_lv)) {
@@ -7083,11 +7069,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	} else if (!lv_active_change(cmd, lv, lp->activate)) {
 		log_error("Failed to activate new LV.");
-		if (lp->zero || lp->wipe_signatures ||
-		    lv_is_thin_pool(lv) ||
-		    lv_is_cache_type(lv))
-			goto deactivate_and_revert_new_lv;
-		return NULL;
+		goto deactivate_and_revert_new_lv;
 	}
 
 	if (_should_wipe_lv(lp, lv, 1)) {
@@ -7104,7 +7086,30 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	}
 
-	if (lp->snapshot && !seg_is_thin(lp)) {
+	if (seg_is_cache(lp) || (origin_lv && lv_is_cache_pool(lv))) {
+		/* Finish cache conversion magic */
+		if (origin_lv) {
+			/* Convert origin to cached LV */
+			if (!(tmp_lv = lv_cache_create(lv, origin_lv))) {
+				/* TODO: do a better revert */
+				log_error("Aborting. Leaving cache pool %s and uncached origin volume %s.",
+					  display_lvname(lv), display_lvname(origin_lv));
+				return NULL;
+			}
+		} else {
+			if (!(tmp_lv = lv_cache_create(pool_lv, lv))) {
+				/* 'lv' still keeps created new LV */
+				stack;
+				goto deactivate_and_revert_new_lv;
+			}
+		}
+		lv = tmp_lv;
+		if (!lv_update_and_reload(lv)) {
+			/* TODO: do a better revert */
+			log_error("Aborting. Manual intervention required.");
+			return NULL; /* FIXME: revert */
+		}
+	} else if (lp->snapshot) {
 		/* Reset permission after zeroing */
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
@@ -7177,35 +7182,26 @@ revert_new_lv:
 struct logical_volume *lv_create_single(struct volume_group *vg,
 					struct lvcreate_params *lp)
 {
+	const struct segment_type *segtype;
 	struct logical_volume *lv;
 
 	/* Create pool first if necessary */
-	if (lp->create_pool) {
-		if (seg_is_thin(lp)) {
-			if (!seg_is_thin_pool(lp) &&
-			    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
-				return_NULL;
-
-			if (lp->pool_name && !apply_lvname_restrictions(lp->pool_name))
+	if (lp->create_pool && !seg_is_pool(lp)) {
+		segtype = lp->segtype;
+		if (seg_is_thin_volume(lp)) {
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 				return_NULL;
 
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
-
-			if (!lp->thin && !lp->snapshot)
-				goto out;
-
-			lp->pool_name = lv->name;
-
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-				return_NULL;
-		} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
-                        if (!seg_is_cache_pool(lp) &&
-			    !(lp->segtype = get_segtype_from_string(vg->cmd,
-								    "cache-pool")))
-				return_NULL;
-
-			if (lp->pool_name && !apply_lvname_restrictions(lp->pool_name))
+		} else if (seg_is_cache(lp)) {
+			if (!lp->origin_name) {
+				/* Until we have --pooldatasize we are lost */
+				log_error(INTERNAL_ERROR "Unsupported creation of cache and cache pool volume.");
+				return NULL;
+			}
+			/* origin_name is defined -> creates cache LV with new cache pool */
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
 				return_NULL;
 
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
@@ -7218,19 +7214,21 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 				return lv;
 			}
 
-			if (!lp->cache)
-				goto out;
-
-			lp->pool_name = lv->name;
-			log_error("Creation of cache pool and cached volume in one command is not yet supported.");
+			log_error(INTERNAL_ERROR "Logical volume is not cache %s.",
+				  display_lvname(lv));
+			return NULL;
+		} else {
+			log_error(INTERNAL_ERROR "Creation of pool for unsupported segment type %s.",
+				  lp->segtype->name);
 			return NULL;
 		}
+		lp->pool_name = lv->name;
+		lp->segtype = segtype;
 	}
 
 	if (!(lv = _lv_create_an_lv(vg, lp, lp->lv_name)))
 		return_NULL;
 
-out:
 	if (lp->temporary)
 		log_verbose("Temporary logical volume \"%s\" created.", lv->name);
 	else
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3d656b7..1100849 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -798,9 +798,7 @@ static inline int is_change_activating(activation_change_t change)
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
-	int cache;
 	int snapshot; /* snap */
-	int thin; /* thin */
 	int create_pool; /* pools */
 	int zero; /* all */
 	int wipe_signatures; /* all */
@@ -809,6 +807,7 @@ struct lvcreate_params {
 	int log_count; /* mirror */
 	int nosync; /* mirror */
 	int pool_metadata_spare; /* pools */
+	int type;   /* type arg is given */
 	int temporary; /* temporary LV */
 #define ACTIVATION_SKIP_SET		0x01 /* request to set LV activation skip flag state */
 #define ACTIVATION_SKIP_SET_ENABLED	0x02 /* set the LV activation skip flag state to 'enabled' */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 76a3164..f7f1596 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -611,7 +611,6 @@ static int _lv_set_thin_params(struct lvcreate_params *lp,
 {
 	_lv_set_default_params(lp, vg, lvname, extents);
 
-	lp->thin = 1;
 	lp->pool_name = pool_name;
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b6907f5..a789fb2 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -42,9 +42,9 @@ static int _set_vg_name(struct lvcreate_params *lp, const char *vg_name)
 	return 1;
 }
 
-static int _lvcreate_name_params(struct lvcreate_params *lp,
-				 struct cmd_context *cmd,
-				 int *pargc, char ***pargv)
+static int _lvcreate_name_params(struct cmd_context *cmd,
+				 int *pargc, char ***pargv,
+				 struct lvcreate_params *lp)
 {
 	int argc = *pargc;
 	char **argv = *pargv;
@@ -125,8 +125,6 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 				  "in one command is not yet supported.");
 			return 0;
 		}
-
-		lp->cache = 1;
 	} else if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		/* argv[0] might be [vg/]origin */
 		if (!argc) {
@@ -379,167 +377,89 @@ static int _update_extents_params(struct volume_group *vg,
  * Note: at this place all volume types needs to be already
  *       identified, do not change them here.
  */
-static int _read_size_params(struct lvcreate_params *lp,
-			     struct lvcreate_cmdline_params *lcp,
-			     struct cmd_context *cmd)
+static int _read_size_params(struct cmd_context *cmd,
+			     struct lvcreate_params *lp,
+			     struct lvcreate_cmdline_params *lcp)
 {
-	if (arg_count(cmd, extents_ARG) && arg_count(cmd, size_ARG)) {
-		log_error("Please specify either size or extents (not both)");
-		return 0;
-	}
+	if (arg_from_list_is_negative(cmd, "may not be negative",
+				      chunksize_ARG, extents_ARG,
+				      mirrors_ARG,
+				      maxrecoveryrate_ARG,
+				      minrecoveryrate_ARG,
+				      regionsize_ARG,
+				      size_ARG,
+				      stripes_ARG, stripesize_ARG,
+				      virtualsize_ARG,
+				      -1))
+		return_0;
 
-	if (!lp->thin && !lp->snapshot && !arg_count(cmd, extents_ARG) && !arg_count(cmd, size_ARG)) {
-		log_error("Please specify either size or extents");
-		return 0;
-	}
+	if (arg_from_list_is_zero(cmd, "may not be zero",
+				  chunksize_ARG, extents_ARG,
+				  regionsize_ARG,
+				  size_ARG,
+				  stripes_ARG, stripesize_ARG,
+				  virtualsize_ARG,
+				  -1))
+		return_0;
 
-	/* poolmetadatasize_ARG is parsed in get_pool_params() */
-	if (!lp->create_pool && arg_count(cmd, poolmetadatasize_ARG)) {
-		log_error("--poolmetadatasize may only be specified when creating pools.");
-		return 0;
-	}
+	lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG, UINT64_C(0));
 
 	if (arg_count(cmd, extents_ARG)) {
-		if (arg_sign_value(cmd, extents_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative number of extents is invalid.");
-			return 0;
-		}
-		if (!(lp->extents = arg_uint_value(cmd, extents_ARG, 0))) {
-			log_error("Number of extents may not be zero.");
+		if (arg_count(cmd, size_ARG)) {
+			log_error("Please specify either size or extents (not both).");
 			return 0;
 		}
+		lp->extents = arg_uint_value(cmd, extents_ARG, 0);
 		lcp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
-	}
-
-	/* Size returned in kilobyte units; held in sectors */
-	if (arg_count(cmd, size_ARG)) {
-		if (arg_sign_value(cmd, size_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative size is invalid.");
-			return 0;
-		}
-		if (!(lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0)))) {
-			log_error("Size may not be zero.");
-			return 0;
-		}
+	} else if (arg_count(cmd, size_ARG)) {
+		lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lcp->percent = PERCENT_NONE;
-	}
-
-	if (arg_count(cmd, virtualsize_ARG)) {
-		if (!lp->thin && !lp->snapshot) {
-			log_error("--virtualsize may only be specified when creating thins or virtual snapshots.");
-			return 0;
-		}
-		if (arg_sign_value(cmd, virtualsize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative virtual origin size is invalid.");
-			return 0;
-		}
-		/* Size returned in kilobyte units; held in sectors */
-		if (!(lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG,
-							 UINT64_C(0)))) {
-			log_error("Virtual origin size may not be zero.");
-			return 0;
-		}
+	} else if (!lp->snapshot && !seg_is_thin_volume(lp)) {
+		log_error("Please specify either size or extents.");
+		return 0;
 	}
 
 	return 1;
 }
 
 /*
- * Generic mirror parameter checks.
- * FIXME: Should eventually be moved into lvm library.
+ * Read parameters related to mirrors
  */
-static int _validate_mirror_params(const struct cmd_context *cmd __attribute__((unused)),
-				   const struct lvcreate_params *lp)
+static int _read_mirror_params(struct cmd_context *cmd,
+			       struct lvcreate_params *lp)
 {
-	int pagesize = lvm_getpagesize();
-
-	if (lp->region_size & (lp->region_size - 1)) {
-		log_error("Region size (%" PRIu32 ") must be a power of 2",
-			  lp->region_size);
-		return 0;
-	}
-
-	if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
-		log_error("Region size (%" PRIu32 ") must be a multiple of "
-			  "machine memory page size (%d)",
-			  lp->region_size, pagesize >> SECTOR_SHIFT);
-		return 0;
-	}
-
-	if (!lp->region_size) {
-		log_error("Non-zero region size must be supplied.");
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _read_mirror_params(struct lvcreate_params *lp,
-			       struct cmd_context *cmd)
-{
-	int region_size;
-	const char *mirrorlog;
 	int corelog = arg_count(cmd, corelog_ARG);
+	const char *mirrorlog = arg_str_value(cmd, mirrorlog_ARG, corelog
+					      ? "core" : DEFAULT_MIRRORLOG);
 
-	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-				  corelog ? "core" : DEFAULT_MIRRORLOG);
-
-	if (strcmp("core", mirrorlog) && corelog) {
-		log_error("Please use only one of --mirrorlog or --corelog");
-		return 0;
-	}
-
-	if (!strcmp("mirrored", mirrorlog)) {
+	if (!strcmp("mirrored", mirrorlog))
 		lp->log_count = 2;
-	} else if (!strcmp("disk", mirrorlog)) {
+	else if (!strcmp("disk", mirrorlog))
 		lp->log_count = 1;
-	} else if (!strcmp("core", mirrorlog))
+	else if (!strcmp("core", mirrorlog)) {
 		lp->log_count = 0;
-	else {
+	} else {
 		log_error("Unknown mirrorlog type: %s", mirrorlog);
 		return 0;
 	}
 
-	log_verbose("Setting logging type to %s", mirrorlog);
-
-	lp->nosync = arg_is_set(cmd, nosync_ARG);
-
-	if (arg_count(cmd, regionsize_ARG)) {
-		if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative regionsize is invalid");
-			return 0;
-		}
-		lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
-	} else {
-		region_size = get_default_region_size(cmd);
-		if (region_size < 0) {
-			log_error("Negative regionsize in configuration file "
-				  "is invalid");
-			return 0;
-		}
-		lp->region_size = region_size;
+	if (corelog && (lp->log_count != 0)) {
+		log_error("Please use only one of --corelog or --mirrorlog.");
+		return 0;
 	}
 
-	if (!_validate_mirror_params(cmd, lp))
-		return 0;
+	log_verbose("Setting logging type to %s", mirrorlog);
 
 	return 1;
 }
 
-static int _read_raid_params(struct lvcreate_params *lp,
-			     struct cmd_context *cmd)
+/*
+ * Read parameters related to raids
+ */
+static int _read_raid_params(struct cmd_context *cmd,
+			     struct lvcreate_params *lp)
 {
-	if (!segtype_is_raid(lp->segtype))
-		return 1;
-
-	if (arg_count(cmd, corelog_ARG) ||
-	    arg_count(cmd, mirrorlog_ARG)) {
-		log_error("Log options not applicable to %s segtype",
-			  lp->segtype->name);
-		return 0;
-	}
-
-	if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10) && (lp->stripes < 2)) {
+	if ((lp->stripes < 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		if (arg_count(cmd, stripes_ARG)) {
 			/* User supplied the bad argument */
 			log_error("Segment type 'raid10' requires 2 or more stripes.");
@@ -551,16 +471,6 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	}
 
 	/*
-	 * RAID types without a mirror component do not take '-m' arg
-	 */
-	if (!segtype_is_mirrored(lp->segtype) &&
-	    arg_count(cmd, mirrors_ARG)) {
-		log_error("Mirror argument cannot be used with segment type, %s",
-			  lp->segtype->name);
-		return 0;
-	}
-
-	/*
 	 * RAID1 does not take a stripe arg
 	 */
 	if ((lp->stripes > 1) && seg_is_mirrored(lp) &&
@@ -570,41 +480,90 @@ static int _read_raid_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	/*
-	 * _read_mirror_params is called before _read_raid_params
-	 * and already sets:
-	 *   lp->nosync
-	 *   lp->region_size
-	 *
-	 * But let's ensure that programmers don't reorder
-	 * that by checking and warning if they aren't set.
-	 */
-	if (!lp->region_size) {
-		log_error(INTERNAL_ERROR "region_size not set.");
+	/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
+	lp->min_recovery_rate = arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
+	lp->max_recovery_rate = arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;
+
+	if (lp->min_recovery_rate > lp->max_recovery_rate) {
+		log_error("Minimum recovery rate cannot be higher than maximum.");
 		return 0;
 	}
 
-	if (arg_count(cmd, minrecoveryrate_ARG))
-		lp->min_recovery_rate = arg_uint_value(cmd,
-						       minrecoveryrate_ARG, 0);
-	if (arg_count(cmd, maxrecoveryrate_ARG))
-		lp->max_recovery_rate = arg_uint_value(cmd,
-						       maxrecoveryrate_ARG, 0);
+	return 1;
+}
 
-	/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
-	lp->min_recovery_rate /= 2;
-	lp->max_recovery_rate /= 2;
+/*
+ * Read parameters related to mirrors and raids
+ */
+static int _read_mirror_and_raid_params(struct cmd_context *cmd,
+					struct lvcreate_params *lp)
+{
+	int pagesize = lvm_getpagesize();
 
-	if (lp->max_recovery_rate &&
-	    (lp->max_recovery_rate < lp->min_recovery_rate)) {
-		log_error("Minimum recovery rate cannot be higher than maximum.");
+	/* Common mirror and raid params */
+	if (arg_count(cmd, mirrors_ARG)) {
+		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
+
+		if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+			log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
+				  " images in mirror supported currently.");
+			return 0;
+		}
+
+		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+			/*
+			 * FIXME: When RAID10 is no longer limited to
+			 *        2-way mirror, 'lv_mirror_count()'
+			 *        must also change for RAID10.
+			 */
+			log_error("RAID10 currently supports "
+				  "only 2-way mirroring (i.e. '-m 1')");
+			return 0;
+		}
+
+		if (lp->mirrors == 1) {
+			if (seg_is_mirrored(lp)) {
+				log_error("--mirrors must be at least 1 with segment type %s.", lp->segtype->name);
+				return 0;
+			}
+			log_print_unless_silent("Redundant mirrors argument: default is 0");
+		}
+	} else
+		/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
+		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
+
+	lp->nosync = arg_is_set(cmd, nosync_ARG);
+
+	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&
+	    ((lp->region_size = get_default_region_size(cmd)) <= 0)) {
+		log_error("regionsize in configuration file is invalid.");
+		return 0;
+	}
+
+	if (lp->region_size & (lp->region_size - 1)) {
+		log_error("Region size (%" PRIu32 ") must be a power of 2",
+			  lp->region_size);
 		return 0;
 	}
+
+	if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
+		log_error("Region size (%" PRIu32 ") must be a multiple of "
+			  "machine memory page size (%d)",
+			  lp->region_size, pagesize >> SECTOR_SHIFT);
+		return 0;
+	}
+
+	if (seg_is_mirror(lp) && !_read_mirror_params(cmd, lp))
+                return_0;
+
+	if (seg_is_raid(lp) && !_read_raid_params(cmd, lp))
+		return_0;
+
 	return 1;
 }
 
-static int _read_cache_pool_params(struct lvcreate_params *lp,
-				  struct cmd_context *cmd)
+static int _read_cache_params(struct cmd_context *cmd,
+			      struct lvcreate_params *lp)
 {
 	const char *cachemode;
 
@@ -620,9 +579,9 @@ static int _read_cache_pool_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-static int _read_activation_params(struct lvcreate_params *lp,
-				   struct cmd_context *cmd,
-				   struct volume_group *vg)
+static int _read_activation_params(struct cmd_context *cmd,
+                                   struct volume_group *vg,
+				   struct lvcreate_params *lp)
 {
 	unsigned pagesize;
 
@@ -658,14 +617,7 @@ static int _read_activation_params(struct lvcreate_params *lp,
 	}
 
 	/* Permissions */
-	lp->permission = arg_uint_value(cmd, permission_ARG,
-					LVM_READ | LVM_WRITE);
-
-	if (lp->snapshot) {
-		/* Snapshot has to zero COW header */
-		lp->zero = 1;
-		lp->wipe_signatures = 0;
-	} else if (!(lp->permission & LVM_WRITE)) {
+	if (!(lp->permission & LVM_WRITE)) {
 		/* Must not zero/wipe read only volume */
 		lp->zero = 0;
 		lp->wipe_signatures = 0;
@@ -673,7 +625,7 @@ static int _read_activation_params(struct lvcreate_params *lp,
 
 	/* Persistent minor (and major) */
 	if (arg_is_set(cmd, persistent_ARG)) {
-		if (lp->create_pool && !lp->thin) {
+		if (lp->create_pool && !seg_is_thin_volume(lp)) {
 			log_error("--persistent is not permitted when creating a thin pool device.");
 			return 0;
 		}
@@ -705,52 +657,58 @@ static int _read_activation_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-static int _lvcreate_params(struct lvcreate_params *lp,
-			    struct lvcreate_cmdline_params *lcp,
-			    struct cmd_context *cmd,
-			    int argc, char **argv)
+static int _lvcreate_params(struct cmd_context *cmd,
+			    int argc, char **argv,
+			    struct lvcreate_params *lp,
+			    struct lvcreate_cmdline_params *lcp)
 {
 	int contiguous;
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
 	int only_linear = 0;
+	int mirror_default_cfg;
 
 	memset(lcp, 0, sizeof(*lcp));
 	dm_list_init(&lp->tags);
 	lp->target_attr = ~0;
 	lp->yes = arg_count(cmd, yes_ARG);
 	lp->force = (force_t) arg_count(cmd, force_ARG);
+	lp->permission = arg_uint_value(cmd, permission_ARG,
+					LVM_READ | LVM_WRITE);
 
-	/* Set default segtype - remember, '-m 0' implies stripe. */
-	if (arg_count(cmd, mirrors_ARG) &&
-	    arg_uint_value(cmd, mirrors_ARG, 0))
-		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
-				   stripes_long_ARG : stripes_ARG, 1) > 1) {
-			segtype_str = find_config_tree_str(cmd, global_raid10_segtype_default_CFG, NULL);;
-		} else {
-			segtype_str = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
+	/*
+	 * --type is the top most rule
+	 *
+	 * Ordering of following type tests is IMPORTANT
+	 */
+	if ((segtype_str = arg_str_value(cmd, type_ARG, NULL))) {
+		lp->type = 1;
+		if (!strcmp(segtype_str, "linear")) {
+			segtype_str = "striped";
+			only_linear = 1; /* User requested linear only target */
 		}
-	else if (arg_count(cmd, snapshot_ARG))
-		segtype_str = "snapshot";
-	else if (arg_count(cmd, cache_ARG))
-		segtype_str = "cache";
-	else if (arg_count(cmd, thin_ARG))
-		segtype_str = "thin";
-	/* estimations after valid shortcuts */
-	else if (arg_count(cmd, cachepool_ARG))
+		if (arg_from_list_is_set(cmd, "is conflicting with option --type",
+					 cache_ARG, thin_ARG, snapshot_ARG,
+					 -1))
+			return_0;
+	/* More estimations from options after shortcuts */
+	} else if (arg_is_set(cmd, snapshot_ARG))
+		/* Snapshot has higher priority then thin */
+		segtype_str = "snapshot"; /* --thinpool makes thin volume */
+	else if (arg_is_set(cmd, cache_ARG) || arg_count(cmd, cachepool_ARG))
 		segtype_str = "cache";
-	else if (arg_count(cmd, thinpool_ARG))
+	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG) ||
+		 arg_is_set(cmd, virtualsize_ARG))
 		segtype_str = "thin";
-	else
+	else if (arg_uint_value(cmd, mirrors_ARG, 0)) {
+		/* Remember, '-m 0' implies stripe */
+		mirror_default_cfg = (arg_uint_value(cmd, stripes_ARG, 1) > 1)
+			? global_raid10_segtype_default_CFG : global_mirror_segtype_default_CFG;
+		segtype_str = find_config_tree_str(cmd, mirror_default_cfg, NULL);
+	} else
 		segtype_str = "striped";
 
-	segtype_str = arg_str_value(cmd, type_ARG, segtype_str);
-	if (!strcmp(segtype_str, "linear")) {
-		segtype_str = "striped";
-		only_linear = 1; /* User requested linear only target */
-	}
-
 	if (!(lp->segtype = get_segtype_from_string(cmd, segtype_str)))
 		return_0;
 
@@ -759,108 +717,269 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if (seg_is_snapshot(lp) ||
-	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG))) {
-		if (arg_from_list_is_set(cmd, "is unsupported with snapshots",
-					 cache_ARG, cachepool_ARG,
-					 mirrors_ARG,
-					 thin_ARG,
-					 zero_ARG,
-					 -1))
+	/* Starts basic option validation for every segment type */
+
+	/* TODO: Use these ARGS macros also in commands.h ? */
+	/* ARGS are disjoint! sets of options */
+#define LVCREATE_ARGS \
+	activate_ARG,\
+	addtag_ARG,\
+	alloc_ARG,\
+	autobackup_ARG,\
+	available_ARG,\
+	contiguous_ARG,\
+	ignoreactivationskip_ARG,\
+	ignoremonitoring_ARG,\
+	name_ARG,\
+	noudevsync_ARG,\
+	permission_ARG,\
+	setactivationskip_ARG,\
+	test_ARG,\
+	type_ARG
+
+#define CACHE_POOL_ARGS \
+	cachemode_ARG,\
+	cachepool_ARG
+
+#define MIRROR_ARGS \
+	corelog_ARG,\
+	mirrorlog_ARG
+
+#define MIRROR_RAID_ARGS \
+	mirrors_ARG,\
+	nosync_ARG,\
+	regionsize_ARG
+
+#define PERSISTENT_ARGS \
+	major_ARG,\
+	minor_ARG,\
+	persistent_ARG
+
+#define POOL_ARGS \
+	pooldatasize_ARG,\
+	poolmetadatasize_ARG,\
+	poolmetadataspare_ARG
+
+#define RAID_ARGS \
+	maxrecoveryrate_ARG,\
+	minrecoveryrate_ARG,\
+	raidmaxrecoveryrate_ARG,\
+	raidminrecoveryrate_ARG
+
+#define SIZE_ARGS \
+	extents_ARG,\
+	size_ARG,\
+	stripes_ARG,\
+	stripesize_ARG
+
+#define THIN_POOL_ARGS \
+	discards_ARG,\
+	thinpool_ARG
+
+	/* Cache and cache-pool segment type */
+	if (seg_is_cache(lp)) {
+		/* Only supported with --type cache, -H, --cache */
+		if (arg_outside_list_is_set(cmd, "is unsupported with cache",
+					    CACHE_POOL_ARGS,
+					    LVCREATE_ARGS,
+					    PERSISTENT_ARGS,
+					    POOL_ARGS,
+					    SIZE_ARGS,
+					    cache_ARG,
+					    chunksize_ARG,
+					    wipesignatures_ARG, zero_ARG,
+					    -1))
 			return_0;
-
-		if (seg_is_pool(lp)) {
-			log_error("Snapshots are incompatible with pool segment types.");
+		lp->create_pool = 1; /* Confirmed when opened VG */
+	} else if (seg_is_cache_pool(lp)) {
+		if (arg_outside_list_is_set(cmd, "is unsupported with cache pools",
+					    CACHE_POOL_ARGS,
+					    LVCREATE_ARGS,
+					    POOL_ARGS,
+					    SIZE_ARGS,
+					    chunksize_ARG,
+					    -1))
+			return_0;
+		if (!(lp->permission & LVM_WRITE)) {
+			log_error("Cannot create read-only cache pool.");
 			return 0;
 		}
+		lp->create_pool = 1;
+	} else if (arg_from_list_is_set(cmd, "is supported only with cache",
+					cache_ARG, CACHE_POOL_ARGS,
+					-1))
+		return_0;
+
+	/* Snapshot segment type */
+	if (seg_is_snapshot(lp)) {
+		/* Only supported with --type snapshot, -s, --snapshot */
+		if (arg_outside_list_is_set(cmd, "is unsupported with snapshots",
+					    LVCREATE_ARGS,
+					    PERSISTENT_ARGS,
+					    SIZE_ARGS,
+					    chunksize_ARG,
+					    snapshot_ARG,
+					    thinpool_ARG,
+					    virtualoriginsize_ARG,
+					    virtualsize_ARG,
+					    -1))
+			return_0;
+
+		/* TODO: resolve this ambiguous case with --pooldatasize  */
+		if (arg_is_set(cmd, thinpool_ARG)) {
+			if (lp->type) {
+				/* Unsupported with --type snapshot */
+				log_error("Snapshot segment type is incompatible with thin pools.");
+				return 0;
+			}
+
+			if (arg_from_list_is_set(cmd, "is unsupported with snapshots and --thinpool",
+						 SIZE_ARGS,
+						 chunksize_ARG,
+						 virtualoriginsize_ARG,
+						 virtualsize_ARG,
+						 -1))
+				return_0;
+		}
 
-		if (arg_is_set(cmd, thinpool_ARG) &&
-		    (arg_is_set(cmd, extents_ARG) || arg_is_set(cmd, size_ARG))) {
-			log_error("Cannot specify snapshot size and thin pool.");
+		/* Snapshot segment type needs size/extents */
+		if (lp->type && !arg_is_set(cmd, size_ARG) && !arg_is_set(cmd, extents_ARG)) {
+			log_error("Snapshot segment type requires size or extents.");
 			return 0;
 		}
 
-		lp->snapshot = 1;
-	}
+		lp->snapshot = 1; /* Free arg is snapshot origin */
+	} else if (arg_from_list_is_set(cmd, "is supported only with sparse snapshots",
+					virtualoriginsize_ARG,
+					-1))
+		return_0;
+
+	/* Mirror segment type */
+	if (seg_is_mirror(lp)) {
+		if (arg_outside_list_is_set(cmd, "is unsupported with mirrors",
+					    LVCREATE_ARGS,
+					    MIRROR_ARGS,
+					    MIRROR_RAID_ARGS,
+					    PERSISTENT_ARGS,
+					    SIZE_ARGS,
+					    wipesignatures_ARG, zero_ARG,
+					    -1))
+			return_0;
+	} else if (arg_from_list_is_set(cmd, "is supported only with mirrors",
+					MIRROR_ARGS,
+					-1))
+		return_0;
 
+	/* Raid segment type */
+	if (seg_is_raid(lp)) {
+		if (arg_outside_list_is_set(cmd, "is unsupported with raids",
+					    LVCREATE_ARGS,
+					    MIRROR_RAID_ARGS,
+					    PERSISTENT_ARGS,
+					    RAID_ARGS,
+					    SIZE_ARGS,
+					    wipesignatures_ARG, zero_ARG,
+					    -1))
+			return_0;
+	} else if (arg_from_list_is_set(cmd, "is supported only with raids",
+					RAID_ARGS,
+					-1))
+		return_0;
+
+	/* Thin and thin-pool segment type */
 	if (seg_is_thin_volume(lp)) {
-		if (arg_is_set(cmd, virtualsize_ARG))
-			lp->thin = 1;
-		else if (arg_is_set(cmd, name_ARG)) {
-			log_error("Missing --virtualsize when specified --name of thin volume.");
-			return 0;
-		/* When no virtual size -> create thin-pool only */
-		} else if (!(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
+		/* Only supported with --type thin, -T, --thin, -V */
+		if (arg_outside_list_is_set(cmd, "is unsupported with thins",
+					    LVCREATE_ARGS,
+					    PERSISTENT_ARGS,
+					    POOL_ARGS,
+					    SIZE_ARGS,
+					    THIN_POOL_ARGS,
+					    chunksize_ARG,
+					    thin_ARG,
+					    virtualsize_ARG,
+					    wipesignatures_ARG, zero_ARG,
+					    -1))
 			return_0;
 
-		/* If size/extents given with thin, then we are creating a thin pool */
-		if (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)) {
-			if (lp->snapshot &&
-			    (arg_is_set(cmd, cachepool_ARG) || arg_is_set(cmd, thinpool_ARG))) {
-				log_error("Size or extents cannot be specified with pool name.");
+		/* If size/extents given with thin, then we are also creating a thin-pool */
+		if (arg_is_set(cmd, size_ARG) || arg_is_set(cmd, extents_ARG)) {
+			if (arg_is_set(cmd, pooldatasize_ARG)) {
+				log_error("Please specify either size or pooldatasize.");
 				return 0;
 			}
 			lp->create_pool = 1;
-		}
-	} else if (seg_is_pool(lp)) {
-		if (arg_from_list_is_set(cmd, "is unsupported with pool segment type",
-					 cache_ARG, mirrors_ARG, snapshot_ARG, thin_ARG,
-					 virtualsize_ARG,
-					 -1))
+		} else if (arg_from_list_is_set(cmd, "is supported only with thin pool creation",
+						POOL_ARGS,
+						SIZE_ARGS,
+						chunksize_ARG,
+						discards_ARG,
+						zero_ARG,
+						-1))
 			return_0;
-		lp->create_pool = 1;
-	}
 
-	if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
-		/* Note: snapshots have snapshot_ARG or virtualsize_ARG */
-		if (arg_from_list_is_set(cmd, "is unsupported with mirrored segment type",
-					 cache_ARG, cachepool_ARG,
-					 snapshot_ARG,
-					 thin_ARG, thinpool_ARG,
-					 virtualsize_ARG,
-					 -1))
+		if (!arg_is_set(cmd, virtualsize_ARG)) {
+			/* Without virtual size could be creation of thin-pool or snapshot */
+			if (lp->create_pool) {
+				if (lp->type) {
+					log_error("Thin segment type requires --virtualsize.");
+					return 0;
+				}
+
+				log_debug_metadata("Switching from thin to thin pool segment type.");
+				if (!(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
+					return_0;
+			} else	/* Parse free arg as snapshot origin */
+				lp->snapshot = 1;
+		}
+	} else if (seg_is_thin_pool(lp)) {
+		if (arg_outside_list_is_set(cmd, "is unsupported with thin pools",
+					    LVCREATE_ARGS,
+					    POOL_ARGS,
+					    SIZE_ARGS,
+					    THIN_POOL_ARGS,
+					    chunksize_ARG,
+					    zero_ARG,
+					    -1))
 			return_0;
-	} else if (arg_from_list_is_set(cmd, "is unsupported without mirrored segment type",
-					corelog_ARG, mirrorlog_ARG, nosync_ARG,
+		if (!(lp->permission & LVM_WRITE)) {
+			log_error("Cannot create read-only thin pool.");
+			return 0;
+		}
+		lp->create_pool = 1;
+	} else if (!lp->snapshot &&
+		   arg_from_list_is_set(cmd, "is supported only with thins",
+					thin_ARG, THIN_POOL_ARGS,
 					-1))
 		return_0;
 
-	/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
-	lp->mirrors = segtype_is_mirrored(lp->segtype) ? 2 : 1;
-
-	if (arg_count(cmd, mirrors_ARG)) {
-		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Mirrors argument may not be negative");
+	/* Check options shared between more segment types */
+	if (!seg_is_mirror(lp) && !seg_is_raid(lp)) {
+		if (arg_from_list_is_set(cmd, "is supported only with mirrors or raids",
+					 nosync_ARG,
+					 regionsize_ARG,
+					 -1))
+			return_0;
+		/* Let -m0 pass */
+		if (arg_int_value(cmd, mirrors_ARG, 0)) {
+			log_error("--mirrors is supported only with mirrors or raids");
 			return 0;
 		}
+	}
 
-		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
-
-		if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
-			log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
-				  " images in mirror supported currently.");
-			return 0;
-		}
+	if (!lp->create_pool && !lp->snapshot &&
+	    arg_from_list_is_set(cmd, "is supported only with pools and snapshots",
+				 chunksize_ARG,
+				 -1))
+		return_0;
 
-		if (lp->mirrors == 1) {
-			if (segtype_is_mirrored(lp->segtype)) {
-				log_error("--mirrors must be at least 1 with segment type %s.", lp->segtype->name);
-				return 0;
-			}
-			log_print_unless_silent("Redundant mirrors argument: default is 0");
-		}
+	if (!lp->snapshot && !seg_is_thin_volume(lp) &&
+	    arg_from_list_is_set(cmd, "is supported only with sparse snapshots and thins",
+				 virtualsize_ARG,
+				 -1))
+		return_0;
 
-		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
-			/*
-			 * FIXME: When RAID10 is no longer limited to
-			 *        2-way mirror, 'lv_mirror_count()'
-			 *        must also change for RAID10.
-			 */
-			log_error("RAID10 currently supports "
-				  "only 2-way mirroring (i.e. '-m 1')");
-			return 0;
-		}
-	}
+	/* Basic segment type validation finished here */
 
 	if (activation() && lp->segtype->ops->target_present) {
 		if (!lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
@@ -898,22 +1017,15 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			lp->wipe_signatures = 0;
 	}
 
-	if (arg_count(cmd, chunksize_ARG) &&
-	    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
-		log_error("Negative chunk size is invalid.");
-		return 0;
-	}
-
-	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
-	    !_read_size_params(lp, lcp, cmd) ||
+	if (!_lvcreate_name_params(cmd, &argc, &argv, lp) ||
+	    !_read_size_params(cmd, lp, lcp) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_pool &&
 	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
 			      &lp->chunk_size, &lp->discards, &lp->zero)) ||
-	    !_read_mirror_params(lp, cmd) ||
-	    !_read_raid_params(lp, cmd) ||
-	    !_read_cache_pool_params(lp, cmd))
+	    !_read_cache_params(cmd, lp) ||
+	    !_read_mirror_and_raid_params(cmd, lp))
 		return_0;
 
 	if (only_linear && lp->stripes > 1) {
@@ -930,22 +1042,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			return 0;
 		}
 		log_verbose("Setting chunksize to %s.", display_size(cmd, lp->chunk_size));
-
-		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
-			return_0;
-	} else if (!lp->create_pool && arg_count(cmd, chunksize_ARG)) {
-		log_error("--chunksize is only available with snapshots and pools.");
-		return 0;
 	}
 
-	if (!lp->create_pool &&
-	    arg_count(cmd, poolmetadataspare_ARG)) {
-		log_error("--poolmetadataspare is only available with pool creation.");
-		return 0;
-	}
-	/*
-	 * Allocation parameters
-	 */
+	/* Allocation parameters */
 	contiguous = arg_int_value(cmd, contiguous_ARG, 0);
 	lp->alloc = contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lp->alloc);
@@ -991,31 +1090,59 @@ static int _determine_cache_argument(struct volume_group *vg,
 {
 	struct logical_volume *lv;
 
-	if (!seg_is_cache(lp)) {
-		log_error(INTERNAL_ERROR
-			  "Unable to determine cache argument on %s segtype",
-			  lp->segtype->name);
-		return 0;
-	}
-
 	if (!lp->pool_name) {
 		lp->pool_name = lp->lv_name;
-	} else if (lp->pool_name == lp->origin_name) {
-		if (!(lv = find_lv(vg, lp->pool_name))) {
-			/* Cache pool nor origin volume exists */
-			lp->cache = 0;
-			lp->origin_name = NULL;
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
-				return_0;
-		} else if (!lv_is_cache_pool(lv)) {
-			/* Name arg in this case is for pool name */
-			lp->pool_name = lp->lv_name;
-			/* We were given origin for caching */
-		} else {
-			/* FIXME error on pool args */
-			lp->create_pool = 0;
-			lp->origin_name = NULL;
+	} else if ((lv = find_lv(vg, lp->pool_name)) && lv_is_cache_pool(lv)) {
+		/* Pool exists, create cache volume */
+		lp->create_pool = 0;
+		lp->origin_name = NULL;
+	} else if (lv) {
+		/* Origin exists, create cache pool volume */
+		if (!validate_lv_cache_create_origin(lv))
+			return_0;
+
+		if (arg_is_set(vg->cmd, permission_ARG) &&
+		    ((lp->permission & LVM_WRITE) != (lv->status & LVM_WRITE))) {
+			/* Reverting permissions on all error path is very complicated */
+			log_error("Change of volume permission is unsupported with cache conversion, use lvchange.");
+			return 0;
 		}
+		/* FIXME: how to handle skip flag */
+		if (arg_from_list_is_set(vg->cmd, "is unsupported with cache conversion",
+					 setactivationskip_ARG,
+					 ignoreactivationskip_ARG,
+					 -1))
+			return_0; /* TODO FIX THIS */
+
+		/* Put origin into resulting activation state first */
+		if (is_change_activating(lp->activate)) {
+			if ((lp->activate == CHANGE_AAY) &&
+			    !lv_passes_auto_activation_filter(vg->cmd, lv)) {
+				log_verbose("Skipping activation of cache origin %s.",
+					    display_lvname(lv));
+				return 1;
+			} else if (!activate_lv_excl_local(vg->cmd, lv)) {
+				log_error("Cannot activate cache origin %s.",
+					  display_lvname(lv));
+				return 0;
+			}
+		} else if (!deactivate_lv(vg->cmd, lv)) {
+			log_error("Cannot deactivate activate cache origin %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		/* lp->origin_name is already equal to lp->pool_name */
+		lp->pool_name = lp->lv_name; /* --name is cache pool name */
+		/*  No zeroing of an existing origin! */
+		lp->zero = lp->wipe_signatures = 0;
+	} else {
+		/* Cache pool and cache volume needs to be created */
+		lp->origin_name = NULL;
+		/* --pooldatasize is needed here */
+		log_error("Ambiguous syntax, please create --type cache-pool %s separately.",
+			  lp->pool_name);
+		return 0;
 	}
 
 	return 1;
@@ -1025,21 +1152,20 @@ static int _determine_cache_argument(struct volume_group *vg,
  * Normal snapshot or thinly-provisioned snapshot?
  */
 static int _determine_snapshot_type(struct volume_group *vg,
-				    struct lvcreate_params *lp)
+				    struct lvcreate_params *lp,
+				    struct lvcreate_cmdline_params *lcp)
 {
-	struct logical_volume *lv, *pool_lv = NULL;
+	struct logical_volume *origin_lv, *pool_lv = NULL;
 
-	if (!(lv = find_lv(vg, lp->origin_name))) {
+	if (!(origin_lv = find_lv(vg, lp->origin_name))) {
 		log_error("Snapshot origin LV %s not found in Volume group %s.",
 			  lp->origin_name, vg->name);
 		return 0;
 	}
+	if (lp->extents || lcp->size)
+		return 1; /* Size specified */
 
-	if (lv_is_cache(lv)) {
-		log_error("Snapshot of cache LV is not yet supported.");
-		return 0;
-	}
-
+	/* Check if we could make thin snapshot */
 	if (lp->pool_name) {
 		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
 			log_error("Thin pool volume %s not found in Volume group %s.",
@@ -1052,24 +1178,63 @@ static int _determine_snapshot_type(struct volume_group *vg,
 				  display_lvname(pool_lv));
 			return 0;
 		}
+	} else {
+		if (!lv_is_thin_volume(origin_lv)) {
+			if (!seg_is_thin(lp))
+				log_error("Please specify either size or extents with snapshots.");
+			else
+				log_error("Logical volume %s is not a thin volume. "
+					  "Thin snapshot supports only thin origins.",
+					  display_lvname(origin_lv));
+			return 0;
+		}
+		/* Origin thin volume without size makes thin segment */
+		lp->pool_name = first_seg(origin_lv)->pool_lv->name;
 	}
 
-	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
-		if (lv_is_thin_volume(lv) && !lp->pool_name)
-			lp->pool_name = first_seg(lv)->pool_lv->name;
+	log_debug_metadata("Switching from snapshot to thin segment type.");
+	if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+		return_0;
+	lp->snapshot = 0;
 
-		if (seg_is_thin(lp) || lp->pool_name) {
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-				return_0;
-			return 1;
-		}
+	return 1;
+}
 
-		log_error("Please specify either size or extents with snapshots.");
-		return 0;
-	} else if (lp->pool_name) {
-		log_error("Cannot specify size with thin pool snapshot.");
-		return 0;
+static int _check_raid_parameters(struct volume_group *vg,
+				  struct lvcreate_params *lp,
+				  struct lvcreate_cmdline_params *lcp)
+{
+	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
+	struct cmd_context *cmd = vg->cmd;
+
+	/*
+	 * If number of devices was not supplied, we can infer from
+	 * the PVs given.
+	 */
+	if (!seg_is_mirrored(lp)) {
+		if (!arg_count(cmd, stripes_ARG) &&
+		    (devs > 2 * lp->segtype->parity_devs))
+			lp->stripes = devs - lp->segtype->parity_devs;
+
+		if (!lp->stripe_size)
+			lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+
+		if (lp->stripes <= lp->segtype->parity_devs) {
+			log_error("Number of stripes must be at least %d for %s",
+				  lp->segtype->parity_devs + 1,
+				  lp->segtype->name);
+			return 0;
+		}
+	} else if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+		if (!arg_count(cmd, stripes_ARG))
+			lp->stripes = devs / lp->mirrors;
+		if (lp->stripes < 2) {
+			log_error("Unable to create RAID10 LV,"
+				  " insufficient number of devices.");
+			return 0;
+		}
 	}
+	/* 'mirrors' defaults to 2 - not the number of PVs supplied */
 
 	return 1;
 }
@@ -1077,74 +1242,110 @@ static int _determine_snapshot_type(struct volume_group *vg,
 static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_params *lp,
 				  struct lvcreate_cmdline_params *lcp)
 {
-	struct logical_volume *pool_lv = NULL;
-
-	if (!lp->thin && !lp->create_pool && !lp->snapshot) {
-		log_error("Please specify device size(s).");
-		return 0;
-	}
-
-	if (lp->thin && lp->snapshot) {
+	if (seg_is_thin_volume(lp) && lp->snapshot) {
 		log_error("Please either create snapshot or thin volume.");
 		return 0;
 	}
 
-	if (lp->pool_name)
-		pool_lv = find_lv(vg, lp->pool_name);
-
-	if (!lp->create_pool) {
-		if (arg_from_list_is_set(vg->cmd, "is only available with thin pool creation",
+	if (!seg_is_thin_volume(lp) && !lp->snapshot) {
+		/* Not creating thin volume nor snapshot */
+		if (arg_from_list_is_set(vg->cmd, "may only be given when creating a new thin Logical volume or snapshot",
+					 permission_ARG,
+					 persistent_ARG,
+					 readahead_ARG,
+					 -1))
+			return_0;
+		if (!lp->create_pool) {
+			/* Not even creating thin pool? */
+			log_error("Please specify device size(s).");
+			return 0;
+		}
+	} else if (!lp->create_pool) {
+		if (arg_from_list_is_set(vg->cmd, "is only available when creating thin pool",
 					 alloc_ARG,
 					 chunksize_ARG,
 					 contiguous_ARG,
-					 discards_ARG,
-					 poolmetadatasize_ARG,
-					 poolmetadataspare_ARG,
 					 stripes_ARG,
-					 stripesize_ARG,
 					 zero_ARG,
 					 -1))
 			return_0;
 
 		if (lcp->pv_count) {
-			log_error("Only specify Physical volumes when allocating the thin pool.");
+			log_error("Only specify Physical volumes when allocating thin pool.");
 			return 0;
 		}
+	}
 
-		if (!lp->pool_name) {
-			log_error("Please specify name of existing thin pool.");
-			return 0;
-		}
+	return 1;
+}
+
+static int _check_pool_parameters(struct cmd_context *cmd,
+				  struct volume_group *vg,
+				  struct lvcreate_params *lp,
+				  struct lvcreate_cmdline_params *lcp)
+{
+	struct logical_volume *pool_lv;
 
-		if (!pool_lv) {
-			log_error("Thin pool %s not found in Volume group %s.", lp->pool_name, vg->name);
+	if (!lp->create_pool &&
+	    arg_from_list_is_set(cmd, "is only available with pools",
+				 POOL_ARGS,
+				 discards_ARG,
+				 -1))
+		return_0;
+
+	if (!seg_is_cache(lp) &&
+	    !seg_is_thin_volume(lp) &&
+	    !seg_is_pool(lp)) {
+		if (lp->pool_name && !lp->snapshot) {
+			log_error("Segment type %s cannot use pool %s.",
+				  lp->segtype->name, lp->pool_name);
 			return 0;
 		}
+		return 1; /* Pool unrelated types */
+	}
 
-		if (!lv_is_thin_pool(pool_lv)) {
-			log_error("Logical volume %s is not a thin pool.", display_lvname(pool_lv));
-			return 0;
+	if (lp->create_pool) {
+		/* Given pool name needs to follow restrictions for created LV */
+		if (lp->pool_name) {
+			if (!apply_lvname_restrictions(lp->pool_name))
+				return_0;
+			/* We could check existance only when we have vg */
+			if (vg && find_lv(vg, lp->pool_name)) {
+				log_error("Logical volume %s already exists in Volume group %s.",
+					  lp->pool_name, vg->name);
+				return 0;
+			}
 		}
-	} else if (pool_lv) {
-		log_error("Logical volume %s already exists in Volume group %s.", lp->pool_name, vg->name);
+		/* When creating just pool the pool_name needs to be in lv_name */
+		if (seg_is_pool(lp))
+			lp->lv_name = lp->pool_name;
+
+		return 1;
+	}
+	/* Not creating new pool, but existing pool is needed */
+	if (!lp->pool_name) {
+		if (lp->snapshot)
+			/* Taking snapshot via 'lvcreate -T vg/origin' */
+			return 1;
+		log_error("Please specify name of existing pool.");
 		return 0;
 	}
 
-	if (!lp->thin && !lp->snapshot) {
-		if (lp->lv_name) {
-			log_error("--name may only be given when creating a new thin Logical volume or snapshot.");
-			return 0;
-		}
-		if (arg_count(vg->cmd, readahead_ARG)) {
-			log_error("--readhead may only be given when creating a new thin Logical volume or snapshot.");
+	if (vg) {
+		/* Validate pool has matching type */
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
+			log_error("Pool %s not found in Volume group %s.",
+				  lp->pool_name, vg->name);
 			return 0;
 		}
-		if (arg_count(vg->cmd, permission_ARG)) {
-			log_error("--permission may only be given when creating a new thin Logical volume or snapshot.");
+		if (seg_is_cache(lp) && !lv_is_cache_pool(pool_lv)) {
+			log_error("Logical volume %s is not a cache pool.",
+				  display_lvname(pool_lv));
 			return 0;
 		}
-		if (arg_count(vg->cmd, persistent_ARG)) {
-			log_error("--persistent may only be given when creating a new thin Logical volume or snapshot.");
+		if (seg_is_thin_volume(lp) && !lv_is_thin_pool(pool_lv)) {
+			log_error("Logical volume %s is not a thin pool.",
+				  display_lvname(pool_lv));
 			return 0;
 		}
 	}
@@ -1152,44 +1353,6 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 	return 1;
 }
 
-static int _check_raid_parameters(struct volume_group *vg,
-				  struct lvcreate_params *lp,
-				  struct lvcreate_cmdline_params *lcp)
-{
-	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
-	struct cmd_context *cmd = vg->cmd;
-
-	/*
-	 * If number of devices was not supplied, we can infer from
-	 * the PVs given.
-	 */
-	if (!seg_is_mirrored(lp)) {
-		if (!arg_count(cmd, stripes_ARG) &&
-		    (devs > 2 * lp->segtype->parity_devs))
-			lp->stripes = devs - lp->segtype->parity_devs;
-
-		if (!lp->stripe_size)
-			lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
-
-		if (lp->stripes <= lp->segtype->parity_devs) {
-			log_error("Number of stripes must be at least %d for %s",
-				  lp->segtype->parity_devs + 1,
-				  lp->segtype->name);
-			return 0;
-		}
-	} else if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
-		if (!arg_count(cmd, stripes_ARG))
-			lp->stripes = devs / lp->mirrors;
-		if (lp->stripes < 2) {
-			log_error("Unable to create RAID10 LV,"
-				  " insufficient number of devices.");
-			return 0;
-		}
-	}
-	/* 'mirrors' defaults to 2 - not the number of PVs supplied */
-
-	return 1;
-}
 
 /*
  * Ensure the set of thin parameters extracted from the command line is consistent.
@@ -1212,21 +1375,17 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 		r = 0;
 	}
 
-	if ((lp->snapshot && !lp->origin_name) || (!lp->snapshot && lp->origin_name)) {
+	if ((!lp->origin_name && lp->snapshot) ||
+	    (lp->origin_name && !lp->snapshot && !seg_is_thin_volume(lp))) {
 		log_error(INTERNAL_ERROR "Inconsistent snapshot and origin parameters identified.");
 		r = 0;
 	}
 
-	if (!lp->thin && !lp->create_pool && !lp->snapshot) {
+	if (!lp->create_pool && !lp->snapshot && !seg_is_thin_volume(lp)) {
 		log_error(INTERNAL_ERROR "Failed to identify what type of thin target to use.");
 		r = 0;
 	}
 
-	if (seg_is_thin_pool(lp) && lp->thin) {
-		log_error(INTERNAL_ERROR "Thin volume cannot be created with thin pool segment type.");
-		r = 0;
-	}
-
 	return r;
 }
 
@@ -1240,8 +1399,15 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;
 
-	if (!_lvcreate_params(&lp, &lcp, cmd, argc, argv))
+	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
+		stack;
 		return EINVALID_CMD_LINE;
+	}
+
+	if (!_check_pool_parameters(cmd, NULL, &lp, &lcp)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
@@ -1250,23 +1416,28 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	if (lp.snapshot && lp.origin_name && !_determine_snapshot_type(vg, &lp))
-		goto_out;
-
-	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
+	/* Resolve segment types with opened VG */
+	if (lp.snapshot && lp.origin_name && !_determine_snapshot_type(vg, &lp, &lcp))
 		goto_out;
 
 	if (seg_is_cache(&lp) && !_determine_cache_argument(vg, &lp))
 		goto_out;
 
+	/* All types resolved at this point, now only validation steps */
 	if (seg_is_raid(&lp) && !_check_raid_parameters(vg, &lp, &lcp))
 		goto_out;
 
+	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
+		goto_out;
+
+	if (!_check_pool_parameters(cmd, vg, &lp, &lcp))
+		goto_out;
+
 	/*
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
 	 */
-	if (!_read_activation_params(&lp, cmd, vg))
+	if (!_read_activation_params(cmd, vg, &lp))
 		goto_out;
 
 	if (!_update_extents_params(vg, &lp, &lcp))
@@ -1284,7 +1455,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 			    lp.pool_name ? : "with generated name", lp.vg_name, lp.segtype->name);
 	}
 
-	if (lp.thin)
+	if (seg_is_thin_volume(&lp))
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
 			    lp.lv_name ? : "with generated name",
 			    lp.pool_name ? : "with generated name", lp.vg_name,


