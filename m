From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  2 Apr 2013 13:18:29 +0000 (UTC)
Subject: master - thin: lvcreate external origin snapshot support
Message-ID: <20130402131829.300AE1297@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d24c01a414506f0cdc04b5c8589f61d288b25273
Commit:        d24c01a414506f0cdc04b5c8589f61d288b25273
Parent:        435e0bb60895b3831840a10a5deb68a51936f3e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 2 14:53:58 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 2 15:17:31 2013 +0200

thin: lvcreate external origin snapshot support

---
 lib/metadata/lv_manip.c |   49 +++++++++++++++++----
 tools/lvcreate.c        |  107 +++++++++++++++++++++++++++--------------------
 2 files changed, 102 insertions(+), 54 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ad8160e..10331c3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -324,10 +324,14 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 			/* Use the same external origin */
 			if (!attach_thin_external_origin(seg, first_seg(thin_pool_lv)->external_lv))
 				return_NULL;
-		} else {
+		} else if (lv_is_thin_pool(thin_pool_lv)) {
 			seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
 			if (!attach_pool_lv(seg, thin_pool_lv, NULL))
 				return_NULL;
+		} else {
+			log_error(INTERNAL_ERROR "Volume %s is not thin volume or thin pool",
+				  thin_pool_lv->name);
+			return NULL;
 		}
 	}
 
@@ -4302,6 +4306,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
 	int origin_active = 0;
+	const char *thin_name = NULL;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -4364,7 +4369,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	status |= lp->permission | VISIBLE_LV;
 
-	if (lp->snapshot && lp->thin) {
+	if (seg_is_thin(lp) && lp->snapshot) {
 		if (!(org = find_lv(vg, lp->origin))) {
 			log_error("Couldn't find origin volume '%s'.",
 				  lp->origin);
@@ -4454,7 +4459,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		return NULL;
 	}
 
-	if (lp->snapshot && !lp->thin && ((uint64_t)lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
+	if (lp->snapshot && !seg_is_thin(lp) && ((uint64_t)lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
 		log_error("Unable to create a snapshot smaller than 2 chunks.");
 		return NULL;
 	}
@@ -4493,7 +4498,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	}
 
 	/* The snapshot segment gets created later */
-	if (lp->snapshot && !lp->thin &&
+	if (lp->snapshot && !seg_is_thin(lp) &&
 	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
 		return_NULL;
 
@@ -4571,12 +4576,21 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	dm_list_splice(&lv->tags, &lp->tags);
 
+	if (seg_is_thin_volume(lp)) {
+		/* For thin snapshot we must have matching pool */
+		if (org && lv_is_thin_volume(org) && (!lp->pool ||
+		    (strcmp(first_seg(org)->pool_lv->name, lp->pool) == 0)))
+			thin_name = org->name;
+		else
+			thin_name = lp->pool;
+	}
+
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
 		       seg_is_thin_pool(lp) ? lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
-		       seg_is_thin_volume(lp) ? (org ? org->name : lp->pool) : NULL, lp->pvh, lp->alloc))
+		       thin_name, lp->pvh, lp->alloc))
 		return_NULL;
 
 	if (seg_is_thin_pool(lp)) {
@@ -4587,12 +4601,29 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		first_seg(lv)->low_water_mark = 0;
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
-
 		if (!(first_seg(lv)->device_id =
 		      get_free_pool_device_id(first_seg(pool_lv)))) {
 			stack;
 			goto revert_new_lv;
 		}
+		/*
+		 * Check if using 'external origin' or the 'normal' snapshot
+		 * within the same thin pool
+		 */
+		if (lp->snapshot && (first_seg(org)->pool_lv != pool_lv)) {
+			if (org->status & LVM_WRITE) {
+				log_error("Cannot use writable LV as the external origin.");
+				return 0; // TODO conversion for inactive
+			}
+			if (lv_is_active(org) && !lv_is_external_origin(org)) {
+				log_error("Cannot use active LV for the external origin.");
+				return 0; // We can't be sure device it is read-only
+			}
+			if (!attach_thin_external_origin(first_seg(lv), org)) {
+				stack;
+				goto revert_new_lv;
+			}
+		}
 
 		if (!attach_pool_message(first_seg(pool_lv),
 					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0)) {
@@ -4634,7 +4665,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	if (seg_is_thin(lp)) {
 		/* For snapshot, suspend active thin origin first */
-		if (org && lv_is_active(org)) {
+		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {
 			if (!pool_below_threshold(first_seg(first_seg(org)->pool_lv))) {
 				log_error("Cannot create thin snapshot. Pool %s/%s is filled "
 					  "over the autoextend threshold.",
@@ -4699,7 +4730,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		goto deactivate_and_revert_new_lv;
 	}
 
-	if (lp->snapshot && !lp->thin) {
+	if (lp->snapshot && !seg_is_thin(lp)) {
 		/* Reset permission after zeroing */
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
@@ -4788,7 +4819,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 		if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
 			return_0;
 
-		if (!lp->thin)
+		if (!lp->thin && !lp->snapshot)
 			goto out;
 
 		lp->pool = lv->name;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index aa75636..df05cbb 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -207,12 +207,17 @@ static int _determine_snapshot_type(struct volume_group *vg,
 	}
 
 	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
+		if (seg_is_thin(lp)) {
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+				return_0;
+			return 1;
+		}
+
 		if (!lv_is_thin_volume(lvl->lv)) {
 			log_error("Please specify either size or extents with snapshots.");
 			return 0;
 		}
 
-		lp->thin = 1;
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 			return_0;
 
@@ -355,7 +360,7 @@ static int _read_size_params(struct lvcreate_params *lp,
 	}
 
 	/* If size/extents given with thin, then we are creating a thin pool */
-	if (lp->thin && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
+	if (seg_is_thin(lp) && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
 		lp->create_thin_pool = 1;
 
 	if (arg_count(cmd, poolmetadatasize_ARG) && !seg_is_thin(lp)) {
@@ -380,8 +385,9 @@ static int _read_size_params(struct lvcreate_params *lp,
 			return 0;
 		}
 	} else {
-		/* No virtual size given, so no thin LV to create. */
-		if (seg_is_thin_volume(lp) && !(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
+		/* No virtual size given and no snapshot, so no thin LV to create. */
+		if (seg_is_thin_volume(lp) && !lp->snapshot &&
+		    !(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
 			return_0;
 
 		lp->thin = 0;
@@ -651,6 +657,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
+	unsigned i;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -660,7 +667,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
-// FIXME -m0 implies *striped*
 	if ((arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG)) &&
 	    arg_count(cmd,mirrors_ARG)) {
 		log_error("--thin,--thinpool  and --mirrors are incompatible.");
@@ -692,6 +698,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
+	if ((arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp)) &&
+	     arg_count(cmd, thin_ARG)) {
+		log_error("--thin and --snapshot are incompatible.");
+		return 0;
+	}
+
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
 	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;
@@ -802,37 +814,43 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_raid_params(lp, cmd))
 		return_0;
 
-	if (!lp->create_thin_pool && arg_count(cmd, discards_ARG)) {
-		log_error("--discards is only available for thin pool creation.");
-		return 0;
-	}
+	if (!lp->create_thin_pool) {
+		if (seg_is_thin(lp)) {
+			static const int _argname[] = {
+				chunksize_ARG, discards_ARG, poolmetadatasize_ARG, zero_ARG
+			};
+			for (i = 0; i < sizeof(_argname)/sizeof(_argname[0]); ++i) {
+				if (arg_count(cmd, _argname[i])) {
+					log_error("%s is only available for thin pool creation.",
+						  arg_long_option_name(_argname[i]));
+					return 0;
+				}
+			}
+		} else if (lp->snapshot) {
+			if (arg_count(cmd, zero_ARG)) {
+				log_error("-Z is incompatible with snapshots.");
+				return 0;
+			}
+			if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+				log_error("Negative chunk size is invalid.");
+				return 0;
+			}
+			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
+			if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
+			    (lp->chunk_size & (lp->chunk_size - 1))) {
+				log_error("Chunk size must be a power of 2 in the "
+					  "range 4K to 512K.");
+				return 0;
+			}
+			log_verbose("Setting chunksize to %s.", display_size(cmd, lp->chunk_size));
 
-	if (lp->snapshot && lp->thin && arg_count(cmd, chunksize_ARG))
-		log_warn("WARNING: Ignoring --chunksize with thin snapshots.");
-	else if (lp->thin && !lp->create_thin_pool) {
-		if (arg_count(cmd, chunksize_ARG))
-			log_warn("WARNING: Ignoring --chunksize when using an existing pool.");
-	} else if (lp->snapshot) {
-		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid");
-			return 0;
-		}
-		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
-		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-		    (lp->chunk_size & (lp->chunk_size - 1))) {
-			log_error("Chunk size must be a power of 2 in the "
-				  "range 4K to 512K");
+			if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+				return_0;
+		} else if (arg_count(cmd, chunksize_ARG)) {
+			log_error("--chunksize is only available with snapshots and thin pools.");
 			return 0;
 		}
-		log_verbose("Setting chunksize to %s.", display_size(cmd, lp->chunk_size));
-
-		if (!lp->thin && lp->snapshot && !(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
-			return_0;
-	} else if (arg_count(cmd, chunksize_ARG) && !lp->create_thin_pool) {
-		log_error("-c is only available with snapshots and thin pools");
-		return 0;
 	}
-
 	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Only up to %d images in mirror supported currently.",
 			  DEFAULT_MIRROR_MAX_IMAGES);
@@ -879,11 +897,16 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 {
 	struct lv_list *lvl;
 
-	if (!lp->thin && !lp->create_thin_pool) {
+	if (!lp->thin && !lp->create_thin_pool && !lp->snapshot) {
 		log_error("Please specify device size(s).");
 		return 0;
 	}
 
+	if (lp->thin && lp->snapshot) {
+		log_error("Please either creater snapshot or thin volume.");
+		return 0;
+	}
+
 	if (lp->thin && !lp->create_thin_pool) {
 		if (arg_count(vg->cmd, chunksize_ARG)) {
 			log_error("Only specify --chunksize when originally creating the thin pool.");
@@ -945,12 +968,11 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 		return 0;
 	}
 
-	if (!lp->thin && lp->lv_name) {
-		log_error("--name may only be given when creating a new thin Logical volume or snapshot.");
-		return 0;
-	}
-
-	if (!lp->thin) {
+	if (!lp->thin && !lp->snapshot) {
+		if (lp->lv_name) {
+			log_error("--name may only be given when creating a new thin Logical volume or snapshot.");
+			return 0;
+		}
 		if (arg_count(vg->cmd, readahead_ARG)) {
 			log_error("--readhead may only be given when creating a new thin Logical volume or snapshot.");
 			return 0;
@@ -994,12 +1016,7 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 		r = 0;
 	}
 
-	if (lp->snapshot && (lp->create_thin_pool || !lp->thin)) {
-		log_error(INTERNAL_ERROR "Inconsistent thin and snapshot parameters identified.");
-		r = 0;
-	}
-
-	if (!lp->thin && !lp->create_thin_pool) {
+	if (!lp->thin && !lp->create_thin_pool && !lp->snapshot) {
 		log_error(INTERNAL_ERROR "Failed to identify what type of thin target to use.");
 		r = 0;
 	}


