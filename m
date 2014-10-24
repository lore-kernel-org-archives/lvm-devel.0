From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:32 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20141024144032.9BAD260CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f8ed25a999821cd37cc1e2c0051e60e8a63e371
Commit:        4f8ed25a999821cd37cc1e2c0051e60e8a63e371
Parent:        c6456bd6390f6d99dd975f671c5730b0438c4c89
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 18 11:01:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: indent

Various indents and tiny error message improvements.
---
 lib/metadata/lv_manip.c          |   45 ++++++++++++++++---------------------
 lib/metadata/metadata-exported.h |    4 +-
 lib/metadata/pool_manip.c        |    2 +-
 tools/lvcreate.c                 |   30 +++++++++----------------
 4 files changed, 34 insertions(+), 47 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6240f14..ec09b41 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6032,7 +6032,8 @@ int remove_layer_from_lv(struct logical_volume *lv,
 		return_0;
 
 	/* Replace the empty layer with error segment */
-	segtype = get_segtype_from_string(lv->vg->cmd, "error");
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "error")))
+		return_0;
 	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype, NULL))
 		return_0;
 
@@ -6050,7 +6051,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   uint64_t status,
 					   const char *layer_suffix)
 {
-	static char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
+	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
 	int r;
 	char *name;
 	size_t len;
@@ -6129,7 +6130,6 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		/* Remove the temporary tags */
 		dm_list_iterate_items(sl, &lv_where->tags)
 			str_list_del(&layer_lv->tags, sl->str);
-
 	}
 
 	log_very_verbose("Inserting layer %s for %s",
@@ -6166,7 +6166,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 			lv_names.old = lv_where->name;
 			lv_names.new = layer_lv->name;
 			if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
-				return 0;
+				return_NULL;
 			break;
 		}
 
@@ -6635,8 +6635,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	if (lp->stripe_size > vg->extent_size) {
-		if (segtype_is_raid(lp->segtype) &&
-		    (vg->extent_size < STRIPE_SIZE_MIN)) {
+		if (seg_is_raid(lp) && (vg->extent_size < STRIPE_SIZE_MIN)) {
 			/*
 			 * FIXME: RAID will simply fail to load the table if
 			 *        this is the case, but we should probably
@@ -6677,13 +6676,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_cache(lp)) {
 		if (!lp->pool_name) {
-			log_error(INTERNAL_ERROR "Cannot create cached volume without cache pool.");
-                        return NULL;
+			log_error(INTERNAL_ERROR "Cannot create thin volume without thin pool.");
+			return NULL;
 		}
-		/* We have the cache_pool, create the origin with cache */
 		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
-			log_error("Couldn't find cache pool volume %s in "
-				  "volume group %s.", lp->pool_name, vg->name);
+			log_error("Couldn't find volume %s in Volume group %s.",
+				  lp->pool_name, vg->name);
 			return NULL;
 		}
 
@@ -6744,8 +6742,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 			if (lv_is_locked(origin_lv)) {
-				log_error("Snapshots of locked devices are not "
-					  "supported yet");
+				log_error("Snapshots of locked devices are not supported.");
 				return NULL;
 			}
 			if (lv_is_merging_origin(origin_lv)) {
@@ -6871,16 +6868,16 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 
 	if (lp->read_ahead != lv->read_ahead) {
-		log_verbose("Setting read ahead sectors");
 		lv->read_ahead = lp->read_ahead;
+		log_debug_metadata("Setting read ahead sectors %u.", lv->read_ahead);
 	}
 
 	if (!seg_is_thin_pool(lp) && lp->minor >= 0) {
 		lv->major = lp->major;
 		lv->minor = lp->minor;
 		lv->status |= FIXED_MINOR;
-		log_verbose("Setting device number to (%d, %d)", lv->major,
-			    lv->minor);
+		log_debug_metadata("Setting device number to (%d, %d).",
+				   lv->major, lv->minor);
 	}
 
 	dm_list_splice(&lv->tags, &lp->tags);
@@ -6963,8 +6960,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	 * it just as if CHANGE_AY was used, CHANGE_AN otherwise.
 	 */
 	if (lp->activate == CHANGE_AAY)
-		lp->activate = lv_passes_auto_activation_filter(cmd, lv) ?
-				CHANGE_ALY : CHANGE_ALN;
+		lp->activate = lv_passes_auto_activation_filter(cmd, lv)
+			? CHANGE_ALY : CHANGE_ALN;
 
 	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE))
 		lp->activate = CHANGE_AN;
@@ -7100,9 +7097,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				     .yes = lp->yes,
 				     .force = lp->force
 			     })) {
-			log_error("Aborting. Failed to wipe %s.",
-				  lp->snapshot ? "snapshot exception store" :
-						 "start of new LV");
+			log_error("Aborting. Failed to wipe %s.", lp->snapshot
+				  ? "snapshot exception store" : "start of new LV");
 			goto deactivate_and_revert_new_lv;
 		}
 	}
@@ -7120,8 +7116,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if ((vg_is_clustered(vg) ||
 		     (!lp->voriginsize && !lv_is_active(origin_lv))) &&
 		    !deactivate_lv(cmd, lv)) {
-			log_error("Aborting. Couldn't deactivate snapshot "
-				  "COW area. Manual intervention required.");
+			log_error("Aborting. Couldn't deactivate snapshot COW area. "
+				  "Manual intervention required.");
 			return NULL;
 		}
 
@@ -7150,9 +7146,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		/* store vg on disk(s) */
 		if (!lv_update_and_reload(origin_lv))
-			return_0;
+			return_NULL;
 	}
-
 out:
 	return lv;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bf6f1c1..1af9cbf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -783,7 +783,7 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 typedef enum activation_change {
 	CHANGE_AY = 0,  /* activate */
 	CHANGE_AN = 1,  /* deactivate */
-	CHANGE_AEY = 2,  /* activate exclusively */
+	CHANGE_AEY = 2, /* activate exclusively */
 	CHANGE_ALY = 3, /* activate locally */
 	CHANGE_ALN = 4, /* deactivate locally */
 	CHANGE_AAY = 5  /* automatic activation */
@@ -801,7 +801,7 @@ struct lvcreate_params {
 	int cache;
 	int snapshot; /* snap */
 	int thin; /* thin */
-	int create_pool; /* thin */
+	int create_pool; /* pools */
 	int zero; /* all */
 	int wipe_signatures; /* all */
 	int32_t major; /* all */
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 2fbadea..02a82bd 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -433,7 +433,7 @@ int create_pool(struct logical_volume *pool_lv,
 		 */
 		pool_lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
-		    /* Clear 4KB of metadata device for new thin-pool. */
+		    /* Clear 4KB of pool metadata device. */
 		    !wipe_lv(pool_lv, (struct wipe_params) { .do_zero = 1 })) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  pool_lv->name);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 5a91627..7573a2e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -390,8 +390,8 @@ static int _update_extents_params(struct volume_group *vg,
 				extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
 		case PERCENT_LV:
-			log_error("Please express size as %s%%VG, %%PVS, "
-				  "or %%FREE.", (lp->snapshot) ? "%ORIGIN, " : "");
+			log_error("Please express size as %%FREE%s, %%PVS or %%VG.",
+				  (lp->snapshot) ? ", %ORIGIN" : "");
 			return 0;
 		case PERCENT_ORIGIN:
 			if (lp->snapshot && lp->origin_name &&
@@ -667,8 +667,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	/*
 	 * RAID1 does not take a stripe arg
 	 */
-	if ((lp->stripes > 1) &&
-	    segtype_is_mirrored(lp->segtype) &&
+	if ((lp->stripes > 1) && seg_is_mirrored(lp) &&
 	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		log_error("Stripe argument cannot be used with segment type, %s",
 			  lp->segtype->name);
@@ -713,11 +712,10 @@ static int _read_cache_pool_params(struct lvcreate_params *lp,
 {
 	const char *cachemode;
 
-	if (!segtype_is_cache_pool(lp->segtype))
+	if (!seg_is_cache(lp) && !seg_is_cache_pool(lp))
 		return 1;
 
-	cachemode = arg_str_value(cmd, cachemode_ARG, NULL);
-	if (!cachemode)
+	if (!(cachemode = arg_str_value(cmd, cachemode_ARG, NULL)))
 		cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
 
 	if (!get_cache_mode(cachemode, &lp->feature_flags))
@@ -748,9 +746,7 @@ static int _read_activation_params(struct lvcreate_params *lp,
 		lp->zero = 0;
 	}
 
-	/*
-	 * Read ahead.
-	 */
+	/* Read ahead */
 	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
 					cmd->default_settings.read_ahead);
 	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
@@ -765,9 +761,7 @@ static int _read_activation_params(struct lvcreate_params *lp,
 			 "of %uK page size.", lp->read_ahead, pagesize >> 1);
 	}
 
-	/*
-	 * Permissions.
-	 */
+	/* Permissions */
 	lp->permission = arg_uint_value(cmd, permission_ARG,
 					LVM_READ | LVM_WRITE);
 
@@ -790,7 +784,7 @@ static int _read_activation_params(struct lvcreate_params *lp,
 
 		if (!get_and_validate_major_minor(cmd, vg->fid->fmt,
 						  &lp->major, &lp->minor))
-                        return_0;
+			return_0;
 	} else if (arg_is_set(cmd, major_ARG) || arg_is_set(cmd, minor_ARG)) {
 		log_error("--major and --minor require -My.");
 		return 0;
@@ -1048,13 +1042,11 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	 * Allocation parameters
 	 */
 	contiguous = arg_int_value(cmd, contiguous_ARG, 0);
-
 	lp->alloc = contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
-
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lp->alloc);
 
 	if (contiguous && (lp->alloc != ALLOC_CONTIGUOUS)) {
-		log_error("Conflicting contiguous and alloc arguments");
+		log_error("Conflicting contiguous and alloc arguments.");
 		return 0;
 	}
 
@@ -1063,12 +1055,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			continue;
 
 		if (!(tag = grouped_arg_str_value(current_group->arg_values, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
+			log_error("Failed to get tag.");
 			return 0;
 		}
 
 		if (!str_list_add(cmd->mem, &lp->tags, tag)) {
-			log_error("Unable to allocate memory for tag %s", tag);
+			log_error("Unable to allocate memory for tag %s.", tag);
 			return 0;
 		}
 	}


