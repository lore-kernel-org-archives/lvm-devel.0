From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Wed, 16 Aug 2023 20:31:33 +0000
Subject: [Git][lvmteam/lvm2][main] 3 commits: lvmlockd: fix thick to thin lv conversion
Message-ID: <64dd322577118_28a562c3853a@gitlab-sidekiq-low-urgency-cpu-bound-v2-7c75b4c959-t27f4.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
09619628 by David Teigland at 2023-08-16T15:29:19-05:00
lvmlockd: fix thick to thin lv conversion

- - - - -
696ee52f by David Teigland at 2023-08-16T15:29:20-05:00
lvmlockd: let lockd_init_lv_args set lock_args

Set the lock_args string in addition to doing initialization.
lvconvert calls lockd_init_lv_args() directly, skipping
the normal lockd_init_lv() which usually sets lock_args.

- - - - -
6ca97e6e by David Teigland at 2023-08-16T15:29:20-05:00
lvmlockd: fix lvconvert to thin-pool

- - - - -


3 changed files:

- lib/locking/lvmlockd.c
- lib/metadata/metadata.c
- tools/lvconvert.c


Changes:

=====================================
lib/locking/lvmlockd.c
=====================================
@@ -2916,6 +2916,8 @@ static int _free_lv(struct cmd_context *cmd, struct volume_group *vg,
 	if (!id_write_format(lv_id, lv_uuid, sizeof(lv_uuid)))
 		return_0;
 
+	log_debug("lockd free LV %s/%s %s lock_args %s", vg->name, lv_name, lv_uuid, lock_args ?: "none");
+
 	reply = _lockd_send("free_lv",
 				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
@@ -2944,8 +2946,13 @@ int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
 		       struct logical_volume *lv,
 		       const char *lock_type, const char **lock_args)
 {
-	/* sanlock is the only lock type that sets per-LV lock_args. */
-	if (!strcmp(lock_type, "sanlock"))
+	if (!lock_type)
+		return 1;
+	if (!strcmp(lock_type, "dlm"))
+		*lock_args = "dlm";
+	else if (!strcmp(lock_type, "idm"))
+		*lock_args = "idm";
+	else if (!strcmp(lock_type, "sanlock"))
 		return _init_lv_sanlock(cmd, vg, lv->name, &lv->lvid.id[1], lock_args);
 	return 1;
 }


=====================================
lib/metadata/metadata.c
=====================================
@@ -2924,6 +2924,8 @@ int vg_write(struct volume_group *vg)
 	vgid[ID_LEN] = 0;
 	memcpy(vgid, &vg->id.uuid, ID_LEN);
 
+	log_debug("Writing metadata for VG %s.", vg->name);
+
 	if (vg_is_shared(vg)) {
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			if (lvl->lv->lock_args && !strcmp(lvl->lv->lock_args, "pending")) {


=====================================
tools/lvconvert.c
=====================================
@@ -2834,7 +2834,7 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	struct lv_segment *seg;
 	struct lv_type *lvtype;
 	char meta_name[NAME_LEN];
-	const char *swap_lock_args;
+	const char *swap_lock_args = NULL;
 	uint32_t chunk_size;
 	int is_thinpool;
 	int is_cachepool;
@@ -2970,8 +2970,7 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	 * requires a lockd lock, and gets the lock from the LV that's becoming
 	 * the new metadata LV.
 	 */
-	if (is_lockd_type(vg->lock_type))
-		prev_metadata_lv->lock_args = swap_lock_args;
+	prev_metadata_lv->lock_args = swap_lock_args;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
@@ -2989,9 +2988,22 @@ static struct logical_volume *_lvconvert_insert_thin_layer(struct logical_volume
 	if (!(thin_segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_THIN)))
 		return_NULL;
 
+	/*
+	 * input lv foo (often linear)
+	 * creates new lv foo_tpoolN (no seg)
+	 * segment from foo is moved to foo_tpoolN
+	 * new linear segment is created for foo that maps to foo_tpoolN
+	 * returns foo_tpoolN
+	 *
+	 * In spite of the "pool" variable naming, pool_lv foo_tpoolN is *not*
+	 * yet a pool type, but rather is whatever type the input lv was.
+	 */
 	if (!(pool_lv = insert_layer_for_lv(vg->cmd, lv, 0, "_tpool%d")))
 		return_NULL;
 
+	/*
+	 * change lv foo to a thin LV using foo_tpoolN
+	 */
 	lv->status |= THIN_VOLUME | VIRTUAL;
 	lv_set_visible(pool_lv);
 
@@ -3061,9 +3073,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	const char *pool_metadata_name;             /* user-specified lv name */
 	char converted_names[3*NAME_LEN];	    /* preserve names of converted lv */
 	struct segment_type *pool_segtype;          /* thinpool or cachepool */
+	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 	struct lv_segment *seg;
 	unsigned int target_attr = ~0;
 	unsigned int activate_pool;
+	unsigned int lock_active_pool_done = 0;
 	unsigned int zero_metadata;
 	uint64_t meta_size;
 	uint32_t meta_extents;
@@ -3078,16 +3092,18 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	thin_discards_t discards;
 	thin_zero_t zero_new_blocks;
 	int error_when_full;
-	int r = 0;
+	int end_error = 0;
+	int is_active;
 
 	/* for handling lvmlockd cases */
 	char *lockd_data_args = NULL;
 	char *lockd_meta_args = NULL;
 	char *lockd_data_name = NULL;
 	char *lockd_meta_name = NULL;
+	uint32_t lockd_data_flags = 0;
+	uint32_t lockd_meta_flags = 0;
 	struct id lockd_data_id;
 	struct id lockd_meta_id;
-	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 
 	if (!_raid_split_image_conversion(lv))
 		return_0;
@@ -3106,16 +3122,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* Allow to have only thinpool active and restore it's active state. */
-	activate_pool = to_thinpool && lv_is_active(lv);
+	is_active = lv_is_active(lv);
+
+	activate_pool = to_thinpool && is_active;
 
 	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
 	zero_metadata = (to_cachepool) ? arg_int_value(cmd, zero_ARG, 1) : 1;
 
-	/* An existing LV needs to have its lock freed once it becomes a data LV. */
 	if (vg_is_shared(vg) && lv->lock_args) {
-		lockd_data_args = dm_pool_strdup(lv->vg->vgmem, lv->lock_args);
-		lockd_data_name = dm_pool_strdup(lv->vg->vgmem, lv->name);
+		lockd_data_args = dm_pool_strdup(vg->vgmem, lv->lock_args);
+		lockd_data_name = dm_pool_strdup(vg->vgmem, lv->name);
+		lockd_data_flags = is_active ? LDLV_PERSISTENT : 0;
 		lockd_data_id = lv->lvid.id[1];
 	}
 
@@ -3143,8 +3160,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
 		if (vg_is_shared(vg) && metadata_lv->lock_args) {
-			lockd_meta_args = dm_pool_strdup(metadata_lv->vg->vgmem, metadata_lv->lock_args);
-			lockd_meta_name = dm_pool_strdup(metadata_lv->vg->vgmem, metadata_lv->name);
+			lockd_meta_args = dm_pool_strdup(vg->vgmem, metadata_lv->lock_args);
+			lockd_meta_name = dm_pool_strdup(vg->vgmem, metadata_lv->name);
+			lockd_meta_flags = lv_is_active(metadata_lv) ? LDLV_PERSISTENT : 0;
 			lockd_meta_id = metadata_lv->lvid.id[1];
 		}
 
@@ -3338,20 +3356,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * When the LV referenced by the original function arg "lv"
-	 * is layered
-	 *
-	 * pool_name    pool name taken from lv arg
-	 * data_name    sub lv name, generated
-	 * meta_name    sub lv name, generated
-	 *
-	 * pool_lv      new lv for pool object, created here
-	 * data_lv      sub lv, was lv arg, now renamed
-	 * metadata_lv  sub lv, existing or created here
-	 */
-
 	if (to_thin) {
+		/*
+		 * pool_lv is not yet a pool, when returned, pool_lv contains
+		 * the segment that belonged to "lv".
+		 */
 		if (!(pool_lv = _lvconvert_insert_thin_layer(lv)))
 			goto_bad;
 	} else {
@@ -3365,6 +3374,17 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		pool_lv = lv;
 	}
 
+	/*
+	 * starts with pool_lv foo (not a pool yet)
+	 * creates new data_lv foo_tdata
+	 * segment from pool_lv foo is moved to data_lv foo_tdata
+	 * pool_lv foo linear segment is created that maps to foo_tdata
+	 * returns data_lv foo_tdata
+	 *
+	 * (In the to_thin case, the segment from the original lv is first
+	 * moved to pool_lv by _lvconvert_insert_thin_layer, and now is
+	 * moved to data_lv.)
+	 */
 	if (!(data_lv = insert_layer_for_lv(cmd, pool_lv, 0,
 					    (to_cachepool ? "_cdata" : "_tdata"))))
 		goto_bad;
@@ -3372,33 +3392,15 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	data_lv->status |= (to_cachepool) ? CACHE_POOL_DATA : THIN_POOL_DATA;
 	data_lv->status |= LVM_WRITE;  /* Pool data LV is writable */
 
+	/*
+	 * pool_lv now becomes a pool type.
+	 * FIXME: change variable naming to avoid this confusion.
+	 */
 	pool_lv->status |= (to_cachepool) ? CACHE_POOL : THIN_POOL;
 
 	seg = first_seg(pool_lv);
 	seg->segtype = pool_segtype;
 
-	/*
-	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock.
-	 * Locks are removed from existing LVs that are being converted to
-	 * data and meta LVs (they are unlocked and deleted below.)
-	 */
-	if (vg_is_shared(vg)) {
-		lv->lock_args = NULL;
-		pool_lv->lock_args = NULL;
-		data_lv->lock_args = NULL;
-		metadata_lv->lock_args = NULL;
-
-		if (!to_cachepool) {
-			if (!strcmp(vg->lock_type, "sanlock"))
-				pool_lv->lock_args = "pending";
-			else if (!strcmp(vg->lock_type, "dlm"))
-				pool_lv->lock_args = "dlm";
-			else if (!strcmp(vg->lock_type, "idm"))
-				pool_lv->lock_args = "idm";
-			/* The lock_args will be set in vg_write(). */
-		}
-	}
-
 	/* Apply settings to the new pool seg */
 	if (to_cachepool) {
 		if (!cache_set_params(seg, chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
@@ -3435,87 +3437,127 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (!_lvconvert_attach_metadata_to_pool(seg, metadata_lv))
 		goto_bad;
 
-	if (!handle_pool_metadata_spare(vg,
-					metadata_lv->le_count,
-					use_pvh, pool_metadata_spare))
-		goto_bad;
+	/*
+	 * If the input LV is being converted to a thin pool, the input LV lock
+	 * is used for the thin pool LV.  If the input LV is being converted to
+	 * a thin LV, a new lock is created for the thin pool and the lock from
+	 * the input LV is freed.  A cache pool LV has no lock, so the lock for
+	 * the input LV is freed.
+	 */
+	if (vg_is_shared(vg)) {
+		lv->lock_args = NULL;
+		pool_lv->lock_args = NULL;
+		data_lv->lock_args = NULL;
+		metadata_lv->lock_args = NULL;
 
-	if (to_thin) {
-		if (!lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
-			log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
-			goto out;
+		if (to_thin) {
+			if (!lockd_init_lv_args(cmd, vg, pool_lv, vg->lock_type, &pool_lv->lock_args)) {
+				log_error("Cannot allocate lock for new pool LV.");
+				goto_bad;
+			}
+		} else if (to_thinpool) {
+			pool_lv->lock_args = lockd_data_args;
+			/* Don't free this lock below. */
+			lockd_data_args = NULL;
+			lockd_data_name = NULL;
+		}
+
+		/* Acquire the thin pool lock if the pool will remain active. */
+		if ((to_thin || to_thinpool) && is_active) {
+			if (!lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
+				log_error("Failed to lock new pool LV %s.", display_lvname(pool_lv));
+				goto_bad;
+			}
+			lock_active_pool_done = 1;
 		}
+	}
+
+	if (to_thin) {
 		if (!lv_update_and_reload(lv))
 			goto_bad;
 	} else {
 		if (!vg_write(vg) || !vg_commit(vg))
 			goto_bad;
+	}
 
-		if (activate_pool) {
-			if (!lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
-				log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
-				goto out;
-			}
+	/*
+	 * The main conversion is successfully committed.  If any subsequent
+	 * steps fail (creating spare, activating, unlocking), we do not
+	 * currently have the ability to undo the changes committed up to this
+	 * point.  Failures in the remaining steps can print an error and cause
+	 * the command to exit with an error, but no partial revert of the
+	 * completed steps is attempted.
+	 */
+	log_print_unless_silent("Converted %s to %s %s.", converted_names,
+				 (to_cachepool) ? "cache" : "thin",
+				 (to_thin) ? "volume" : "pool");
 
-			if (!activate_lv(cmd, pool_lv)) {
-				log_error("Failed to activate pool logical volume %s.",
-					  display_lvname(pool_lv));
-
-				/* Deactivate subvolumes */
-				if (!deactivate_lv(cmd, seg_lv(seg, 0)))
-					log_error("Failed to deactivate pool data logical volume %s.",
-						  display_lvname(seg_lv(seg, 0)));
-				if (!deactivate_lv(cmd, seg->metadata_lv))
-					log_error("Failed to deactivate pool metadata logical volume %s.",
-						  display_lvname(seg->metadata_lv));
-				goto out;
-			}
-		}
+	/*
+	 * FIXME handle_pool_metadata_spare() calls vg_write() vg_commit()
+	 * after creating a new lvolN, but then lvolN is renamed and hidden as
+	 * [lvolN_pmspare] without any further vg_write(). So, there's an extra
+	 * vg_write and vg_commit required here to cover the renaming/hiding.
+	 */
+	if (!handle_pool_metadata_spare(vg, metadata_lv->le_count, use_pvh, pool_metadata_spare) ||
+	    !vg_write(vg) || !vg_commit(vg)) {
+		log_error("Failed to set up spare metadata LV for thin pool.");
+		end_error = 1;
 	}
 
-	r = 1;
-
-out:
-	if (r)
-		log_print_unless_silent("Converted %s to %s %s.",
-					converted_names, (to_cachepool) ? "cache" : "thin",
-					(to_thin) ? "volume" : "pool");
+	if (activate_pool && !activate_lv(cmd, pool_lv)) {
+		log_error("Failed to activate pool logical volume %s.", display_lvname(pool_lv));
+		end_error = 1;
+	}
 
 	/*
-	 * Unlock and free the locks from existing LVs that became pool data
-	 * and meta LVs.
+	 * Unlock and free locks that are no longer used.
 	 */
 	if (lockd_data_name) {
-		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", LDLV_PERSISTENT))
+		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", lockd_data_flags)) {
 			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
-		lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args);
+			end_error = 1;
+		}
+		if (!lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args)) {
+			log_error("Failed to free lock for pool data LV %s/%s", vg->name, lockd_data_name);
+			end_error = 1;
+		}
 	}
-
 	if (lockd_meta_name) {
-		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", LDLV_PERSISTENT))
+		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", lockd_meta_flags)) {
 			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
-		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
+			end_error = 1;
+		}
+		if (!lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args)) {
+			log_error("Failed to free lock for pool metadata LV %s/%s", vg->name, lockd_meta_name);
+			end_error = 1;
+		}
 	}
-bad:
+
 	if (policy_settings)
 		dm_config_destroy(policy_settings);
 
-	return r;
-#if 0
-revert_new_lv:
-	/* TBD */
-	if (!pool_metadata_lv_name) {
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Failed to deactivate metadata lv.");
-			return 0;
-		}
-		if (!lv_remove(metadata_lv) || !vg_write(vg) || !vg_commit(vg))
-			log_error("Manual intervention may be required to remove "
-				  "abandoned LV(s) before retrying.");
+	if (end_error) {
+		log_error("Manual intervention may be required to handle reported errors.");
+		return 0;
 	}
 
+	return 1;
+
+	/*
+	 * Error exit path for failures that occur before the main conversion
+	 * is committed.  Failures that occur after the main conversion is
+	 * committed should not exit here.  There is some cleanup missing here.
+	 */
+bad:
+	if (lock_active_pool_done)
+		lockd_lv(cmd, pool_lv, "un", LDLV_PERSISTENT);
+	if (pool_lv && pool_lv->lock_args && pool_lv->new_lock_args)
+		lockd_free_lv(cmd, vg, pool_lv->name, &pool_lv->lvid.id[1], pool_lv->lock_args);
+
+	if (policy_settings)
+		dm_config_destroy(policy_settings);
+
 	return 0;
-#endif
 }
 
 static int _cache_vol_attach(struct cmd_context *cmd,



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/5a96ca4a7fedf873f9b707f35f584d9bde56b357...6ca97e6e62852bd491fd19ff98ee41318f902d36

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/5a96ca4a7fedf873f9b707f35f584d9bde56b357...6ca97e6e62852bd491fd19ff98ee41318f902d36
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230816/9ed302d9/attachment-0001.htm>
