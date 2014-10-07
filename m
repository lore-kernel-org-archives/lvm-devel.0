From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 13:57:01 +0000 (UTC)
Subject: master - cleanup: rename _name, _lv and _size
Message-ID: <20141007135701.D24E460EF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27ff61d012740dcdb8f5cf6421c22f746d056fe1
Commit:        27ff61d012740dcdb8f5cf6421c22f746d056fe1
Parent:        62802ddae052e9af996a4366bdcd5a9f2ec713d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 10:43:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 15:51:53 2014 +0200

cleanup: rename _name, _lv and _size

Use some standard names for lv char * names, logical_volume * lv
and sizes internally.
---
 lib/metadata/lv_manip.c          |  120 +++++++++++++++++-----------------
 lib/metadata/metadata-exported.h |   10 ++--
 liblvm/lvm_lv.c                  |   32 +++++-----
 tools/lvconvert.c                |   52 +++++++-------
 tools/lvcreate.c                 |  134 +++++++++++++++++++-------------------
 5 files changed, 174 insertions(+), 174 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0aa6521..892f7ca 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6555,7 +6555,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
 	uint64_t status = UINT64_C(0);
-	struct logical_volume *lv, *org = NULL;
+	struct logical_volume *lv, *origin_lv = NULL;
 	struct logical_volume *pool_lv;
 	struct logical_volume *tmp_lv;
 	const char *thin_name = NULL;
@@ -6639,14 +6639,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	status |= lp->permission | VISIBLE_LV;
 
 	if (seg_is_cache(lp)) {
-		if (!lp->pool) {
+		if (!lp->pool_name) {
 			log_error(INTERNAL_ERROR "Cannot create cached volume without cache pool.");
                         return NULL;
 		}
 		/* We have the cache_pool, create the origin with cache */
-		if (!(pool_lv = find_lv(vg, lp->pool))) {
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
 			log_error("Couldn't find cache pool volume %s in "
-				  "volume group %s.", lp->pool, vg->name);
+				  "volume group %s.", lp->pool_name, vg->name);
 			return NULL;
 		}
 
@@ -6663,22 +6663,22 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "striped")))
 			return_0;
 	} else if (seg_is_thin(lp) && lp->snapshot) {
-		if (!lp->origin) {
+		if (!lp->origin_name) {
 			log_error(INTERNAL_ERROR "Origin LV is not defined.");
 			return 0;
 		}
-		if (!(org = find_lv(vg, lp->origin))) {
+		if (!(origin_lv = find_lv(vg, lp->origin_name))) {
 			log_error("Couldn't find origin volume '%s'.",
-				  lp->origin);
+				  lp->origin_name);
 			return NULL;
 		}
 
-		if (lv_is_locked(org)) {
+		if (lv_is_locked(origin_lv)) {
 			log_error("Snapshots of locked devices are not supported.");
 			return NULL;
 		}
 
-		lp->voriginextents = org->le_count;
+		lp->voriginextents = origin_lv->le_count;
 	} else if (lp->snapshot) {
 		if (!activation()) {
 			log_error("Can't create snapshot without using "
@@ -6691,51 +6691,51 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		if (!lp->voriginsize) {
 
-			if (!(org = find_lv(vg, lp->origin))) {
+			if (!(origin_lv = find_lv(vg, lp->origin_name))) {
 				log_error("Couldn't find origin volume '%s'.",
-					  lp->origin);
+					  lp->origin_name);
 				return NULL;
 			}
-			if (lv_is_virtual_origin(org)) {
+			if (lv_is_virtual_origin(origin_lv)) {
 				log_error("Can't share virtual origins. "
 					  "Use --virtualsize.");
 				return NULL;
 			}
-			if (lv_is_cow(org)) {
+			if (lv_is_cow(origin_lv)) {
 				log_error("Snapshots of snapshots are not "
 					  "supported yet.");
 				return NULL;
 			}
-			if (lv_is_locked(org)) {
+			if (lv_is_locked(origin_lv)) {
 				log_error("Snapshots of locked devices are not "
 					  "supported yet");
 				return NULL;
 			}
-			if (lv_is_merging_origin(org)) {
+			if (lv_is_merging_origin(origin_lv)) {
 				log_error("Snapshots of an origin that has a "
 					  "merging snapshot is not supported");
 				return NULL;
 			}
 
-			if (lv_is_thin_type(org) && !lv_is_thin_volume(org)) {
+			if (lv_is_thin_type(origin_lv) && !lv_is_thin_volume(origin_lv)) {
 				log_error("Snapshots of thin pool %sdevices "
 					  "are not supported.",
-					  lv_is_thin_pool_data(org) ? "data " :
-					  lv_is_thin_pool_metadata(org) ?
+					  lv_is_thin_pool_data(origin_lv) ? "data " :
+					  lv_is_thin_pool_metadata(origin_lv) ?
 					  "metadata " : "");
 				return NULL;
 			}
 
-			if (lv_is_mirror_type(org)) {
+			if (lv_is_mirror_type(origin_lv)) {
 				log_warn("WARNING: Snapshots of mirrors can deadlock under rare device failures.");
 				log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
-			if (vg_is_clustered(vg) && lv_is_active(org) &&
-			    !lv_is_active_exclusive_locally(org)) {
+			if (vg_is_clustered(vg) && lv_is_active(origin_lv) &&
+			    !lv_is_active_exclusive_locally(origin_lv)) {
 				log_error("%s must be active exclusively to"
-					  " create snapshot", org->name);
+					  " create snapshot", origin_lv->name);
 				return NULL;
 			}
 		}
@@ -6807,14 +6807,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
-		if (!lp->pool) {
+		if (!lp->pool_name) {
 			log_error(INTERNAL_ERROR "Undefined pool for thin volume segment.");
 			return NULL;
 		}
 
-		if (!(pool_lv = find_lv(vg, lp->pool))) {
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
 			log_error("Unable to find existing pool LV %s in VG %s.",
-				  lp->pool, vg->name);
+				  lp->pool_name, vg->name);
 			return NULL;
 		}
 
@@ -6823,11 +6823,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return_NULL;
 
 		/* For thin snapshot we must have matching pool */
-		if (org && lv_is_thin_volume(org) && (!lp->pool ||
-		    (strcmp(first_seg(org)->pool_lv->name, lp->pool) == 0)))
-			thin_name = org->name;
+		if (origin_lv && lv_is_thin_volume(origin_lv) && (!lp->pool_name ||
+		    (strcmp(first_seg(origin_lv)->pool_lv->name, lp->pool_name) == 0)))
+			thin_name = origin_lv->name;
 		else
-			thin_name = lp->pool;
+			thin_name = lp->pool_name;
 	}
 
 	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
@@ -6867,7 +6867,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
-		       seg_is_pool(lp) ? lp->poolmetadataextents : lp->region_size,
+		       seg_is_pool(lp) ? lp->pool_metadata_extents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
 		       thin_name, lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
@@ -6900,18 +6900,18 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * Check if using 'external origin' or the 'normal' snapshot
 		 * within the same thin pool
 		 */
-		if (lp->snapshot && (first_seg(org)->pool_lv != pool_lv)) {
-			if (!pool_supports_external_origin(first_seg(pool_lv), org))
+		if (lp->snapshot && (first_seg(origin_lv)->pool_lv != pool_lv)) {
+			if (!pool_supports_external_origin(first_seg(pool_lv), origin_lv))
 				return_0;
-			if (org->status & LVM_WRITE) {
+			if (origin_lv->status & LVM_WRITE) {
 				log_error("Cannot use writable LV as the external origin.");
 				return 0; // TODO conversion for inactive
 			}
-			if (lv_is_active(org) && !lv_is_external_origin(org)) {
+			if (lv_is_active(origin_lv) && !lv_is_external_origin(origin_lv)) {
 				log_error("Cannot use active LV for the external origin.");
 				return 0; // We can't be sure device is read-only
 			}
-			if (!attach_thin_external_origin(first_seg(lv), org))
+			if (!attach_thin_external_origin(first_seg(lv), origin_lv))
 				return_NULL;
 		}
 
@@ -6953,18 +6953,18 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	 * Either we have origin or pool and created cache origin LV
 	 */
 	if (lp->cache &&
-	    (lp->origin || (lp->pool && !lv_is_cache_pool(lv)))) {
-		if (lp->origin) {
-			if (!(org = find_lv(vg, lp->origin)))
+	    (lp->origin_name || (lp->pool_name && !lv_is_cache_pool(lv)))) {
+		if (lp->origin_name) {
+			if (!(origin_lv = find_lv(vg, lp->origin_name)))
 				goto deactivate_and_revert_new_lv;
 			pool_lv = lv; /* Cache pool is created */
-		} else if (lp->pool) {
-			if (!(pool_lv = find_lv(vg, lp->pool)))
+		} else if (lp->pool_name) {
+			if (!(pool_lv = find_lv(vg, lp->pool_name)))
 				goto deactivate_and_revert_new_lv;
-			org = lv; /* Cached origin is created */
+			origin_lv = lv; /* Cached origin is created */
 		}
 
-		if (!(tmp_lv = lv_cache_create(pool_lv, org)))
+		if (!(tmp_lv = lv_cache_create(pool_lv, origin_lv)))
 			goto deactivate_and_revert_new_lv;
 
 		/* From here we cannot deactive_and_revert! */
@@ -6976,7 +6976,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * There is no such problem with cache pool
 		 * since it cannot be activated.
 		 */
-		if (lp->origin && lv_is_active(lv)) {
+		if (lp->origin_name && lv_is_active(lv)) {
 			if (!is_change_activating(lp->activate)) {
 				/* User requested to create inactive cached volume */
 				if (deactivate_lv(cmd, lv)) {
@@ -7023,19 +7023,19 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (lv_is_thin_volume(lv)) {
 		/* For snapshot, suspend active thin origin first */
-		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {
-			if (!suspend_lv_origin(cmd, org)) {
+		if (origin_lv && lv_is_active(origin_lv) && lv_is_thin_volume(origin_lv)) {
+			if (!suspend_lv_origin(cmd, origin_lv)) {
 				log_error("Failed to suspend thin snapshot origin %s/%s.",
-					  org->vg->name, org->name);
+					  origin_lv->vg->name, origin_lv->name);
 				goto revert_new_lv;
 			}
-			if (!resume_lv_origin(cmd, org)) { /* deptree updates thin-pool */
+			if (!resume_lv_origin(cmd, origin_lv)) { /* deptree updates thin-pool */
 				log_error("Failed to resume thin snapshot origin %s/%s.",
-					  org->vg->name, org->name);
+					  origin_lv->vg->name, origin_lv->name);
 				goto revert_new_lv;
 			}
 			/* At this point remove pool messages, snapshot is active */
-			if (!update_pool_lv(first_seg(org)->pool_lv, 0)) {
+			if (!update_pool_lv(first_seg(origin_lv)->pool_lv, 0)) {
 				stack;
 				goto revert_new_lv;
 			}
@@ -7104,7 +7104,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * if origin is real (not virtual) inactive device.
 		 */
 		if ((vg_is_clustered(vg) ||
-		     (!lp->voriginsize && !lv_is_active(org))) &&
+		     (!lp->voriginsize && !lv_is_active(origin_lv))) &&
 		    !deactivate_lv(cmd, lv)) {
 			log_error("Aborting. Couldn't deactivate snapshot "
 				  "COW area. Manual intervention required.");
@@ -7113,13 +7113,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		/* A virtual origin must be activated explicitly. */
 		if (lp->voriginsize &&
-		    (!(org = _create_virtual_origin(cmd, vg, lv->name,
+		    (!(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
 						    lp->permission,
 						    lp->voriginextents)) ||
-		     !activate_lv_excl(cmd, org))) {
+		     !activate_lv_excl(cmd, origin_lv))) {
 			log_error("Couldn't create virtual origin for LV %s",
 				  lv->name);
-			if (org && !lv_remove(org))
+			if (origin_lv && !lv_remove(origin_lv))
 				stack;
 			goto deactivate_and_revert_new_lv;
 		}
@@ -7128,14 +7128,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * COW LV is activated via implicit activation of origin LV
 		 * Only the snapshot origin holds the LV lock in cluster
 		 */
-		if (!vg_add_snapshot(org, lv, NULL,
-				     org->le_count, lp->chunk_size)) {
+		if (!vg_add_snapshot(origin_lv, lv, NULL,
+				     origin_lv->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
 			goto deactivate_and_revert_new_lv;
 		}
 
 		/* store vg on disk(s) */
-		if (!lv_update_and_reload(org))
+		if (!lv_update_and_reload(origin_lv))
 			return_0;
 	}
 
@@ -7172,13 +7172,13 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 				return_NULL;
 
-			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
+			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
 
 			if (!lp->thin && !lp->snapshot)
 				goto out;
 
-			lp->pool = lv->name;
+			lp->pool_name = lv->name;
 
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 				return_NULL;
@@ -7188,7 +7188,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 								    "cache-pool")))
 				return_NULL;
 
-			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
+			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
 
 			if (lv_is_cache(lv)) {
@@ -7201,7 +7201,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			if (!lp->cache)
 				goto out;
 
-			lp->pool = lv->name;
+			lp->pool_name = lv->name;
 			log_error("Creation of cache pool and cached volume in one command is not yet supported.");
 			return NULL;
 		}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4ab7672..ae9996d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -811,7 +811,7 @@ struct lvcreate_params {
 	int32_t minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
-	int poolmetadataspare; /* thin pool */
+	int pool_metadata_spare; /* pools */
 	int temporary; /* temporary LV */
 #define ACTIVATION_SKIP_SET		0x01 /* request to set LV activation skip flag state */
 #define ACTIVATION_SKIP_SET_ENABLED	0x02 /* set the LV activation skip flag state to 'enabled' */
@@ -823,10 +823,10 @@ struct lvcreate_params {
 #define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
 	int thin_chunk_size_calc_policy;
 
-	const char *origin; /* snap */
-	const char *pool;   /* thin */
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name; /* all */
+	const char *origin_name; /* snap */
+	const char *pool_name;   /* thin */
 
 	/* Keep args given by the user on command line */
 	/* FIXME: create some more universal solution here */
@@ -855,8 +855,8 @@ struct lvcreate_params {
 	uint32_t extents; /* all */
 	uint32_t voriginextents; /* snapshot */
 	uint64_t voriginsize; /* snapshot */
-	uint32_t poolmetadataextents; /* thin pool */
-	uint64_t poolmetadatasize; /* thin pool */
+	uint32_t pool_metadata_extents; /* pools */
+	uint64_t pool_metadata_size; /* pools */
 	struct dm_list *pvh; /* all */
 
 	uint32_t permission; /* all */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 3af1f62..76a3164 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -496,35 +496,35 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
 
 /* Set defaults for thin pool specific LV parameters */
 static int _lv_set_pool_params(struct lvcreate_params *lp,
-				vg_t vg, const char *pool,
+				vg_t vg, const char *pool_name,
 				uint64_t extents, uint64_t meta_size)
 {
 	_lv_set_default_params(lp, vg, NULL, extents);
 
-	lp->pool = pool;
+	lp->pool_name = pool_name;
 
 	lp->create_pool = 1;
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
 	lp->stripes = 1;
 
 	if (!meta_size) {
-		lp->poolmetadatasize = extents * vg->extent_size /
+		lp->pool_metadata_size = extents * vg->extent_size /
 			(lp->chunk_size * (SECTOR_SIZE / 64));
-		while ((lp->poolmetadatasize >
+		while ((lp->pool_metadata_size >
 			(2 * DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
 		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
 			lp->chunk_size <<= 1;
-			lp->poolmetadatasize >>= 1;
+			lp->pool_metadata_size >>= 1;
 	         }
 	} else
-		lp->poolmetadatasize = meta_size;
+		lp->pool_metadata_size = meta_size;
 
-	if (lp->poolmetadatasize % vg->extent_size)
-		lp->poolmetadatasize +=
-			vg->extent_size - lp->poolmetadatasize % vg->extent_size;
+	if (lp->pool_metadata_size % vg->extent_size)
+		lp->pool_metadata_size +=
+			vg->extent_size - lp->pool_metadata_size % vg->extent_size;
 
-	if (!(lp->poolmetadataextents =
-	      extents_from_size(vg->cmd, lp->poolmetadatasize / SECTOR_SIZE,
+	if (!(lp->pool_metadata_extents =
+	      extents_from_size(vg->cmd, lp->pool_metadata_size / SECTOR_SIZE,
 				vg->extent_size)))
 		return_0;
 
@@ -605,14 +605,14 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 
 /* Set defaults for thin LV specific parameters */
 static int _lv_set_thin_params(struct lvcreate_params *lp,
-				vg_t vg, const char *pool,
+				vg_t vg, const char *pool_name,
 				const char *lvname,
 				uint64_t extents)
 {
 	_lv_set_default_params(lp, vg, lvname, extents);
 
 	lp->thin = 1;
-	lp->pool = pool;
+	lp->pool_name = pool_name;
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
 
 	lp->voriginsize = extents * vg->extent_size;
@@ -674,11 +674,11 @@ static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 				return NULL;
 			}
 
-			lvcp->lvp.pool = first_seg(lv)->pool_lv->name;
+			lvcp->lvp.pool_name = first_seg(lv)->pool_lv->name;
 		}
 
 		lvcp->lvp.stripes = 1;
-		lvcp->lvp.origin = lv->name;
+		lvcp->lvp.origin_name = lv->name;
 
 		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
 	}
@@ -797,7 +797,7 @@ static lv_t _lvm_lv_create(lv_create_params_t params)
 		 * pool is.
 		 */
 		if (!(lvl = find_lv_in_vg(params->vg,
-				(params->lvp.lv_name) ? params->lvp.lv_name : params->lvp.pool)))
+				(params->lvp.lv_name) ? params->lvp.lv_name : params->lvp.pool_name)))
 			return_NULL;
 		return (lv_t) lvl->lv;
 	}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fc22823..50410a5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -67,10 +67,10 @@ struct lvconvert_params {
 
 	int passed_args;
 	uint64_t pool_metadata_size;
-	const char *origin_lv_name;
-	const char *pool_data_lv_name;
+	const char *origin_name;
+	const char *pool_data_name;
 	struct logical_volume *pool_data_lv;
-	const char *pool_metadata_lv_name;
+	const char *pool_metadata_name;
 	struct logical_volume *pool_metadata_lv;
 	thin_discards_t discards;
 };
@@ -126,13 +126,13 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		(*pargv)++, (*pargc)--;
 	}
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_metadata_lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_metadata_name))
 		return_0;
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_data_lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_data_name))
 		return_0;
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
 		return_0;
 
 	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
@@ -188,7 +188,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 			log_error("Too many arguments provided with --uncache.");
 			return 0;
 		}
-		if (lp->pool_data_lv_name && lp->pool_metadata_lv_name) {
+		if (lp->pool_data_name && lp->pool_metadata_name) {
 			log_error("Too many arguments provided for pool.");
 			return 0;
 		}
@@ -236,7 +236,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 	int cachepool = 0;
 	int thinpool = 0;
 
-	if ((lp->pool_data_lv_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
+	if ((lp->pool_data_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
 		if (type_str[0] &&
 		    strcmp(type_str, "cache") &&
 		    strcmp(type_str, "cache-pool")) {
@@ -248,7 +248,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 		type_str = "cache-pool";
 	} else if (!strcmp(type_str, "cache-pool"))
 		cachepool = 1;
-	else if ((lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
+	else if ((lp->pool_data_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
 		if (type_str[0] &&
 		    strcmp(type_str, "thin") &&
 		    strcmp(type_str, "thin-pool")) {
@@ -280,7 +280,7 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 
 	if (thinpool) {
 		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
-		lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL);
+		lp->origin_name = arg_str_value(cmd, originname_ARG, NULL);
 	} else {
 		if (arg_from_list_is_set(cmd, "is valid only with thin pools",
 					 discards_ARG, originname_ARG, thinpool_ARG,
@@ -308,23 +308,23 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 				     &lp->zero))
 			return_0;
 
-		if ((lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, NULL)) &&
+		if ((lp->pool_metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL)) &&
 		    arg_from_list_is_set(cmd, "is invalid with --poolmetadata",
 					 stripesize_ARG, stripes_long_ARG,
 					 readahead_ARG, -1))
 			return_0;
 
-		if (!lp->pool_data_lv_name) {
+		if (!lp->pool_data_name) {
 			if (!*pargc) {
 				log_error("Please specify the pool data LV.");
 				return 0;
 			}
-			lp->pool_data_lv_name = (*pargv)[0];
+			lp->pool_data_name = (*pargv)[0];
 			(*pargv)++, (*pargc)--;
 		}
 
 		if (!lp->thin && !lp->cache)
-			lp->lv_name_full = lp->pool_data_lv_name;
+			lp->lv_name_full = lp->pool_data_name;
 
 		/* Hmm _read_activation_params */
 		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
@@ -528,7 +528,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			log_error("Please provide logical volume path for snapshot origin.");
 			return 0;
 		}
-		lp->origin_lv_name = argv[0];
+		lp->origin_name = argv[0];
 		argv++, argc--;
 
 		if (arg_count(cmd, regionsize_ARG)) {
@@ -2164,9 +2164,9 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!(org = find_lv(lv->vg, lp->origin_lv_name))) {
+	if (!(org = find_lv(lv->vg, lp->origin_name))) {
 		log_error("Couldn't find origin volume %s in Volume group %s.",
-			  lp->origin_lv_name, lv->vg->name);
+			  lp->origin_name, lv->vg->name);
 		return 0;
 	}
 
@@ -2648,11 +2648,11 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	struct lvcreate_params lvc = {
 		.activate = CHANGE_AEY,
 		.alloc = ALLOC_INHERIT,
-		.lv_name = lp->origin_lv_name,
+		.lv_name = lp->origin_name,
 		.major = -1,
 		.minor = -1,
 		.permission = LVM_READ,
-		.pool = pool_lv->name,
+		.pool_name = pool_lv->name,
 		.pvh = &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
@@ -2792,9 +2792,9 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	char metadata_name[NAME_LEN], data_name[NAME_LEN];
 	int activate_pool;
 
-	if (lp->pool_data_lv_name &&
-	    !(pool_lv = find_lv(vg, lp->pool_data_lv_name))) {
-		log_error("Unknown pool data LV %s.", lp->pool_data_lv_name);
+	if (lp->pool_data_name &&
+	    !(pool_lv = find_lv(vg, lp->pool_data_name))) {
+		log_error("Unknown pool data LV %s.", lp->pool_data_name);
 		return 0;
 	}
 
@@ -2845,9 +2845,9 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lp->pool_metadata_lv_name) {
-		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_lv_name))) {
-			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_lv_name);
+	if (lp->pool_metadata_name) {
+		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_name))) {
+			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_name);
 			return 0;
 		}
 		lp->pool_metadata_size = lp->pool_metadata_lv->size;
@@ -3127,7 +3127,7 @@ mda_write:
 
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */
-	if (lp->pool_metadata_lv_name &&
+	if (lp->pool_metadata_name &&
 	    !lv_rename_update(cmd, metadata_lv, metadata_name, 0))
 		return_0;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0dc3699..2fa7918 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -54,9 +54,9 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
 		return_0;
 
-	lp->pool = arg_str_value(cmd, thinpool_ARG, NULL)
+	lp->pool_name = arg_str_value(cmd, thinpool_ARG, NULL)
 		? : arg_str_value(cmd, cachepool_ARG, NULL);
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_name))
 		return_0;
 
 	if (seg_is_cache(lp)) {
@@ -73,7 +73,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		 * or whether it is the origin for cached LV.
 		 */
 		if (!argc) {
-			if (!lp->pool) {
+			if (!lp->pool_name) {
 				/* Don't advertise we could handle cache origin */
 				log_error("Please specify a logical volume to act as the cache pool.");
 				return 0;
@@ -86,25 +86,25 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 					return_0;
 			} else {
 				/* Lets pretend it's cache origin for now */
-				lp->origin = vg_name;
-				if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin))
+				lp->origin_name = vg_name;
+				if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
 					return_0;
 
-				if (lp->pool) {
-					if (strcmp(lp->pool, lp->origin)) {
+				if (lp->pool_name) {
+					if (strcmp(lp->pool_name, lp->origin_name)) {
 						log_error("Unsupported syntax, cannot use cache origin %s and --cachepool %s.",
-							  lp->origin, lp->pool);
+							  lp->origin_name, lp->pool_name);
 						/* Stop here, only older form remains supported */
 						return 0;
 					}
-					lp->origin = NULL;
+					lp->origin_name = NULL;
 				} else {
 					/*
 					 * Gambling here, could be cache pool or cache origin,
 					 * detection is possible after openning vg,
 					 * yet we need to parse pool args
 					 */
-					lp->pool = lp->origin;
+					lp->pool_name = lp->origin_name;
 					lp->create_pool = 1;
 				}
 			}
@@ -121,7 +121,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			return 0;
 		}
 
-		if (!lp->pool) {
+		if (!lp->pool_name) {
 			log_error("Creation of cached volume and cache pool "
 				  "in one command is not yet supported.");
 			return 0;
@@ -136,8 +136,8 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			return 0;
 		}
 
-		lp->origin = argv[0];
-		if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin))
+		lp->origin_name = argv[0];
+		if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
 			return_0;
 
 		if (!lp->vg_name &&
@@ -162,13 +162,13 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			if (!validate_lvname_param(cmd, &lp->vg_name, &vg_name))
 				return_0;
 
-			if (lp->pool &&
-			    (strcmp(vg_name, lp->pool) != 0)) {
+			if (lp->pool_name &&
+			    (strcmp(vg_name, lp->pool_name) != 0)) {
 				log_error("Ambiguous %s name specified, %s and %s.",
-					  lp->segtype->name, vg_name, lp->pool);
+					  lp->segtype->name, vg_name, lp->pool_name);
 				return 0;
 			}
-			lp->pool = vg_name;
+			lp->pool_name = vg_name;
 
 			if (!lp->vg_name &&
 			    !_set_vg_name(lp, extract_vgname(cmd, NULL)))
@@ -207,16 +207,16 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 
 	/* support --name & --type {thin|cache}-pool */
 	if (seg_is_pool(lp) && lp->lv_name) {
-		if (lp->pool && (strcmp(lp->lv_name, lp->pool) != 0)) {
+		if (lp->pool_name && (strcmp(lp->lv_name, lp->pool_name) != 0)) {
 			log_error("Ambiguous %s name specified, %s and %s.",
-				  lp->segtype->name, lp->lv_name, lp->pool);
+				  lp->segtype->name, lp->lv_name, lp->pool_name);
 			return 0;
 		}
-		lp->pool = lp->lv_name;
+		lp->pool_name = lp->lv_name;
 		lp->lv_name = NULL;
 	}
 
-	if (lp->pool && lp->lv_name && !strcmp(lp->pool, lp->lv_name)) {
+	if (lp->pool_name && lp->lv_name && !strcmp(lp->pool_name, lp->lv_name)) {
 		log_error("Logical volume name %s and pool name must be different.",
 			  lp->lv_name);
 		return 0;
@@ -239,9 +239,9 @@ static int _determine_snapshot_type(struct volume_group *vg,
 {
 	struct logical_volume *lv, *pool_lv = NULL;
 
-	if (!(lv = find_lv(vg, lp->origin))) {
+	if (!(lv = find_lv(vg, lp->origin_name))) {
 		log_error("Snapshot origin LV %s not found in Volume group %s.",
-			  lp->origin, vg->name);
+			  lp->origin_name, vg->name);
 		return 0;
 	}
 
@@ -250,10 +250,10 @@ static int _determine_snapshot_type(struct volume_group *vg,
 		return 0;
 	}
 
-	if (lp->pool) {
-		if (!(pool_lv = find_lv(vg, lp->pool))) {
+	if (lp->pool_name) {
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
 			log_error("Thin pool volume %s not found in Volume group %s.",
-				  lp->pool, vg->name);
+				  lp->pool_name, vg->name);
 			return 0;
 		}
 
@@ -265,10 +265,10 @@ static int _determine_snapshot_type(struct volume_group *vg,
 	}
 
 	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
-		if (lv_is_thin_volume(lv) && !lp->pool)
-			lp->pool = first_seg(lv)->pool_lv->name;
+		if (lv_is_thin_volume(lv) && !lp->pool_name)
+			lp->pool_name = first_seg(lv)->pool_lv->name;
 
-		if (seg_is_thin(lp) || lp->pool) {
+		if (seg_is_thin(lp) || lp->pool_name) {
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 				return_0;
 			return 1;
@@ -276,7 +276,7 @@ static int _determine_snapshot_type(struct volume_group *vg,
 
 		log_error("Please specify either size or extents with snapshots.");
 		return 0;
-	} else if (lp->pool) {
+	} else if (lp->pool_name) {
 		log_error("Cannot specify size with thin pool snapshot.");
 		return 0;
 	}
@@ -289,7 +289,7 @@ static int _lvcreate_update_pool_params(struct volume_group *vg,
 {
 	return update_pool_params(lp->segtype, vg, lp->target_attr,
 				  lp->passed_args, lp->extents,
-				  &lp->poolmetadatasize,
+				  &lp->pool_metadata_size,
 				  &lp->thin_chunk_size_calc_policy, &lp->chunk_size,
 				  &lp->discards, &lp->zero);
 }
@@ -316,23 +316,23 @@ static int _determine_cache_argument(struct volume_group *vg,
 		return 0;
 	}
 
-	if (!lp->pool) {
-		lp->pool = lp->lv_name;
-	} else if (lp->pool == lp->origin) {
-		if (!(lv = find_lv(vg, lp->pool))) {
+	if (!lp->pool_name) {
+		lp->pool_name = lp->lv_name;
+	} else if (lp->pool_name == lp->origin_name) {
+		if (!(lv = find_lv(vg, lp->pool_name))) {
 			/* Cache pool nor origin volume exists */
 			lp->cache = 0;
-			lp->origin = NULL;
+			lp->origin_name = NULL;
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache-pool")))
 				return_0;
 		} else if (!lv_is_cache_pool(lv)) {
 			/* Name arg in this case is for pool name */
-			lp->pool = lp->lv_name;
+			lp->pool_name = lp->lv_name;
 			/* We were given origin for caching */
 		} else {
 			/* FIXME error on pool args */
 			lp->create_pool = 0;
-			lp->origin = NULL;
+			lp->origin_name = NULL;
 		}
 	}
 
@@ -350,7 +350,7 @@ static int _update_extents_params(struct volume_group *vg,
 				  struct lvcreate_cmdline_params *lcp)
 {
 	uint32_t pv_extent_count;
-	struct logical_volume *origin = NULL;
+	struct logical_volume *origin_lv = NULL;
 	uint32_t size_rest;
 	uint32_t stripesize_extents;
 	uint32_t extents;
@@ -395,19 +395,19 @@ static int _update_extents_params(struct volume_group *vg,
 				  "or %%FREE.", (lp->snapshot) ? "%ORIGIN, " : "");
 			return 0;
 		case PERCENT_ORIGIN:
-			if (lp->snapshot && lp->origin &&
-			    !(origin = find_lv(vg, lp->origin))) {
+			if (lp->snapshot && lp->origin_name &&
+			    !(origin_lv = find_lv(vg, lp->origin_name))) {
 				log_error("Couldn't find origin volume '%s'.",
-					  lp->origin);
+					  lp->origin_name);
 				return 0;
 			}
-			if (!origin) {
+			if (!origin_lv) {
 				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
 				return 0;
 			}
 			/* Add whole metadata size estimation */
-			extents = cow_max_extents(origin, lp->chunk_size) - origin->le_count +
-				percent_of_extents(lp->extents, origin->le_count, 1);
+			extents = cow_max_extents(origin_lv, lp->chunk_size) - origin_lv->le_count +
+				percent_of_extents(lp->extents, origin_lv->le_count, 1);
 			break;
 		case PERCENT_NONE:
 			extents = lp->extents;
@@ -424,19 +424,19 @@ static int _update_extents_params(struct volume_group *vg,
 		lp->extents = extents;
 	}
 
-	if (lp->snapshot && lp->origin && lp->extents) {
+	if (lp->snapshot && lp->origin_name && lp->extents) {
 		if (!lp->chunk_size) {
 			log_error(INTERNAL_ERROR "Missing snapshot chunk size.");
 			return 0;
 		}
 
-		if (!origin && !(origin = find_lv(vg, lp->origin))) {
+		if (!origin_lv && !(origin_lv = find_lv(vg, lp->origin_name))) {
 			log_error("Couldn't find origin volume '%s'.",
-				  lp->origin);
+				  lp->origin_name);
 			return 0;
 		}
 
-		extents = cow_max_extents(origin, lp->chunk_size);
+		extents = cow_max_extents(origin_lv, lp->chunk_size);
 
 		if (extents < lp->extents) {
 			log_print_unless_silent("Reducing COW size %s down to maximum usable size %s.",
@@ -462,16 +462,16 @@ static int _update_extents_params(struct volume_group *vg,
 		if (!_lvcreate_update_pool_params(vg, lp))
 			return_0;
 
-		if (!(lp->poolmetadataextents =
-		      extents_from_size(vg->cmd, lp->poolmetadatasize, vg->extent_size)))
+		if (!(lp->pool_metadata_extents =
+		      extents_from_size(vg->cmd, lp->pool_metadata_size, vg->extent_size)))
 			return_0;
 		if (lcp->percent == PERCENT_FREE) {
-			if (lp->extents <= (2 * lp->poolmetadataextents)) {
+			if (lp->extents <= (2 * lp->pool_metadata_extents)) {
 				log_error("Not enough space for thin pool creation.");
 				return 0;
 			}
 			/* FIXME: persistent hidden space in VG wanted */
-			lp->extents -= (2 * lp->poolmetadataextents);
+			lp->extents -= (2 * lp->pool_metadata_extents);
 		}
 	}
 
@@ -1016,7 +1016,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_pool &&
 	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
-			      &lp->poolmetadatasize, &lp->poolmetadataspare,
+			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
 			      &lp->chunk_size, &lp->discards, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
 	    !_read_raid_params(lp, cmd) ||
@@ -1095,8 +1095,8 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 		return 0;
 	}
 
-	if (lp->pool)
-		pool_lv = find_lv(vg, lp->pool);
+	if (lp->pool_name)
+		pool_lv = find_lv(vg, lp->pool_name);
 
 	if (!lp->create_pool) {
 		if (arg_from_list_is_set(vg->cmd, "is only available with thin pool creation",
@@ -1117,13 +1117,13 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			return 0;
 		}
 
-		if (!lp->pool) {
+		if (!lp->pool_name) {
 			log_error("Please specify name of existing thin pool.");
 			return 0;
 		}
 
 		if (!pool_lv) {
-			log_error("Thin pool %s not found in Volume group %s.", lp->pool, vg->name);
+			log_error("Thin pool %s not found in Volume group %s.", lp->pool_name, vg->name);
 			return 0;
 		}
 
@@ -1132,7 +1132,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			return 0;
 		}
 	} else if (pool_lv) {
-		log_error("Logical volume %s already exists in Volume group %s.", lp->pool, vg->name);
+		log_error("Logical volume %s already exists in Volume group %s.", lp->pool_name, vg->name);
 		return 0;
 	}
 
@@ -1213,12 +1213,12 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 	     1        0           1         1      y      - create thin snapshot of existing thin LV
 	*/
 
-	if (!lp->create_pool && !lp->pool) {
+	if (!lp->create_pool && !lp->pool_name) {
 		log_error(INTERNAL_ERROR "--thinpool not identified.");
 		r = 0;
 	}
 
-	if ((lp->snapshot && !lp->origin) || (!lp->snapshot && lp->origin)) {
+	if ((lp->snapshot && !lp->origin_name) || (!lp->snapshot && lp->origin_name)) {
 		log_error(INTERNAL_ERROR "Inconsistent snapshot and origin parameters identified.");
 		r = 0;
 	}
@@ -1256,7 +1256,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	if (lp.snapshot && lp.origin && !_determine_snapshot_type(vg, &lp))
+	if (lp.snapshot && lp.origin_name && !_determine_snapshot_type(vg, &lp))
 		goto_out;
 
 	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
@@ -1282,20 +1282,20 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 
 	if (lp.create_pool) {
-		if (!handle_pool_metadata_spare(vg, lp.poolmetadataextents,
-						lp.pvh, lp.poolmetadataspare))
+		if (!handle_pool_metadata_spare(vg, lp.pool_metadata_extents,
+						lp.pvh, lp.pool_metadata_spare))
 			goto_out;
 
 		log_verbose("Making pool %s in VG %s using segtype %s",
-			    lp.pool ? : "with generated name", lp.vg_name, lp.segtype->name);
+			    lp.pool_name ? : "with generated name", lp.vg_name, lp.segtype->name);
 	}
 
 	if (lp.thin)
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
 			    lp.lv_name ? : "with generated name",
-			    lp.pool ? : "with generated name", lp.vg_name,
+			    lp.pool_name ? : "with generated name", lp.vg_name,
 			    lp.snapshot ? " as snapshot of " : "",
-			    lp.snapshot ? lp.origin : "", lp.segtype->name);
+			    lp.snapshot ? lp.origin_name : "", lp.segtype->name);
 
 	if (!lv_create_single(vg, &lp))
 		goto_out;


