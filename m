From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:15 +0000 (UTC)
Subject: dev-dct-process-latest - lv_update_and_reload: replace code sequence
Message-ID: <20140922153715.59D1A6153C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c710f02e0181cc2db5455f0c98033247a70ecc30
Commit:        c710f02e0181cc2db5455f0c98033247a70ecc30
Parent:        e4e50863a22d4decd1b4c3a89e94b94173d2a704
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 9 14:40:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 9 19:20:09 2014 +0200

lv_update_and_reload: replace code sequence

Use lv_update_and_reload() and lv_update_and_reload_origin()
to handle write/suspend/commit/resume sequence.

In few places this properly handle vg_revert() after suspend failure,
and also ensures there is metadata backup after successful vg_commit().
---
 lib/metadata/cache_manip.c |   27 ++------
 lib/metadata/lv_manip.c    |   35 ++-------
 lib/metadata/raid_manip.c  |  173 ++++----------------------------------------
 tools/lvchange.c           |  120 ++----------------------------
 4 files changed, 34 insertions(+), 321 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 04e165f..73df448 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -175,7 +175,6 @@ static int _cleanup_orphan_lv(struct logical_volume *lv)
  */
 int lv_cache_remove(struct logical_volume *cache_lv)
 {
-	struct cmd_context *cmd = cache_lv->vg->cmd;
 	const char *policy_name;
 	uint64_t dirty_blocks;
 	struct lv_segment *cache_seg = first_seg(cache_lv);
@@ -225,14 +224,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		cache_seg->policy_argv = NULL;
 
 		/* update the kernel to put the cleaner policy in place */
-		if (!vg_write(cache_lv->vg))
-			return_0;
-		if (!suspend_lv(cmd, cache_lv))
-			return_0;
-		if (!vg_commit(cache_lv->vg))
-			return_0;
-		if (!resume_lv(cmd, cache_lv))
-			return_0;
+		if (lv_update_and_reload(cache_lv))
+                        return_0;
 	}
 
 	//FIXME: use polling to do this...
@@ -256,7 +249,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!remove_layer_from_lv(cache_lv, corigin_lv))
 			return_0;
 
-	if (!vg_write(cache_lv->vg))
+	if (!lv_update_and_reload(cache_lv))
 		return_0;
 
 	/*
@@ -264,20 +257,12 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 * - the top-level cache LV
 	 * - the origin
 	 * - the cache_pool _cdata and _cmeta
-	 */
-	if (!suspend_lv(cmd, cache_lv))
-		return_0;
-
-	if (!vg_commit(cache_lv->vg))
-		return_0;
-
-	/* resume_lv on this (former) cache LV will resume all */
-	/*
+	 *
+	 * resume_lv on this (former) cache LV will resume all
+	 *
 	 * FIXME: currently we can't easily avoid execution of
 	 * blkid on resumed error device
 	 */
-	if (!resume_lv(cmd, cache_lv))
-		return_0;
 
 	/*
 	 * cleanup orphan devices
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cec9f84..cc7b6da 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5039,26 +5039,8 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg))
-		goto_out;
-
-	if (!suspend_lv(cmd, lock_lv)) {
-		log_error("Failed to suspend %s", lock_lv->name);
-		vg_revert(vg);
-		goto bad;
-	}
-
-	if (!vg_commit(vg)) {
-		stack;
-		if (!resume_lv(cmd, lock_lv))
-			stack;
-		goto bad;
-	}
-
-	if (!resume_lv(cmd, lock_lv)) {
-		log_error("Problem reactivating %s", lock_lv->name);
-		goto bad;
-	}
+	if (!lv_update_and_reload(lock_lv))
+		goto_bad;
 
 	if (lv_is_cow_covering_origin(lv))
 		if (!monitor_dev_for_events(cmd, lv, 0, 0))
@@ -5069,15 +5051,14 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!update_pool_lv(lock_lv, 0))
 			goto_bad;
 
+		backup(vg);
+
 		if (inactive && !deactivate_lv(cmd, lock_lv)) {
 			log_error("Problem deactivating %s.", lock_lv->name);
-			backup(vg);
 			return 0;
 		}
 	}
 
-	backup(vg);
-
 	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
@@ -5085,10 +5066,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	return 1;
-
 bad:
-	backup(vg);
-out:
 	if (inactive && !deactivate_lv(cmd, lock_lv))
 		log_error("Problem deactivating %s.", lock_lv->name);
 
@@ -6951,9 +6929,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			 *    I say that would be cleaner, but I'm not sure
 			 *    about the effects on thinpool yet...
 			 */
-			if (!vg_write(vg) || !suspend_lv(cmd, lv) ||
-			    !vg_commit(vg) || !resume_lv(cmd, lv))
+			if (!lv_update_and_reload(lv)) {
+				stack;
 				goto deactivate_and_revert_new_lv;
+			}
 
 			if (!(lvl = find_lv_in_vg(vg, lp->origin)))
 				goto deactivate_and_revert_new_lv;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ab30af9..d39dbc8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -502,7 +502,6 @@ static int _raid_add_images(struct logical_volume *lv,
 	uint32_t old_count = lv_raid_image_count(lv);
 	uint32_t count = new_count - old_count;
 	uint64_t status_mask = -1;
-	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list meta_lvs, data_lvs;
 	struct lv_list *lvl;
@@ -679,29 +678,8 @@ to be left for these sub-lvs.
 	dm_list_iterate_items(lvl, &data_lvs)
 		lv_set_hidden(lvl->lv);
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv_origin(cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!resume_lv_origin(cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
+	if (!lv_update_and_reload_origin(lv))
+		return_0;
 
 	/*
 	 * Now that the 'REBUILD' has made its way to the kernel, we must
@@ -1223,34 +1201,12 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
+	if (!lv_update_and_reload(lv))
+		return_0;
 
 	log_print_unless_silent("%s split from %s for read-only purposes.",
 				seg_lv(seg, s)->name, lv->name);
 
-	/* Resume original LV */
-	if (!resume_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
 	/* Activate the split (and tracking) LV */
 	if (!_activate_sublv_preserving_excl(lv, seg_lv(seg, s)))
 		return 0;
@@ -1316,29 +1272,8 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	image_lv->status |= (lv->status & LVM_WRITE);
 	image_lv->status |= RAID_IMAGE;
 
-	if (!vg_write(vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv(vg->cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, vg->name);
-		return 0;
-	}
-
-	if (!resume_lv(vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  vg->name, lv->name);
-		return 0;
-	}
+	if (!lv_update_and_reload(lv))
+		return_0;
 
 	log_print_unless_silent("%s/%s successfully merged back into %s/%s",
 				vg->name, image_lv->name, vg->name, lv->name);
@@ -1439,29 +1374,8 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	lv->status |= RAID;
 	seg->status |= RAID;
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!resume_lv(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
+	if (!lv_update_and_reload(lv))
+		return_0;
 
 	return 1;
 }
@@ -1806,29 +1720,8 @@ try_again:
 		}
 	}
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv_origin(lv->vg->cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!resume_lv_origin(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
+	if (!lv_update_and_reload_origin(lv))
+		return_0;
 
 	dm_list_iterate_items(lvl, &old_lvs) {
 		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
@@ -1848,29 +1741,8 @@ try_again:
 		}
 	}
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv_origin(lv->vg->cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!resume_lv_origin(lv->vg->cmd, lv)) {
-		log_error("Failed to resume %s/%s after committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
+	if (!lv_update_and_reload_origin(lv))
+		return_0;
 
 	return 1;
 }
@@ -1879,7 +1751,6 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 {
 	uint32_t s;
 	struct lv_segment *seg = first_seg(lv);
-	struct cmd_context *cmd = lv->vg->cmd;
 
 	if (!(lv->status & PARTIAL_LV)) {
 		log_error(INTERNAL_ERROR "%s/%s is not a partial LV",
@@ -1915,25 +1786,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 		}
 	}
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to suspend %s/%s before committing changes",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit changes to %s in %s",
-			  lv->name, lv->vg->name);
-		return 0;
-	}
-
-	if (!resume_lv(cmd, lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	return 1;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 31c397b..bbb030f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -20,7 +20,6 @@ static int lvchange_permission(struct cmd_context *cmd,
 {
 	uint32_t lv_access;
 	struct lvinfo info;
-	int r = 0;
 
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
@@ -73,38 +72,15 @@ static int lvchange_permission(struct cmd_context *cmd,
 			    lv->name);
 	}
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
-		vg_revert(lv->vg);
-		goto out;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, lv))
-			stack;
-		goto_out;
-	}
-
-	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		goto out;
-	}
-
-	r = 1;
-out:
-	backup(lv->vg);
-	return r;
+	return 1;
 }
 
 static int lvchange_pool_update(struct cmd_context *cmd,
 				struct logical_volume *lv)
 {
-	int r = 0;
 	int update = 0;
 	unsigned val;
 	thin_discards_t discards;
@@ -143,32 +119,10 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	if (!update)
 		return 0;
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s).", lv->name);
-	if (!vg_write(lv->vg))
+	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
-	if (!suspend_lv_origin(cmd, lv)) {
-		log_error("Failed to update active %s/%s (deactivation is needed).",
-			  lv->vg->name, lv->name);
-		vg_revert(lv->vg);
-		goto out;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv_origin(cmd, lv))
-			stack;
-		goto_out;
-	}
-
-	if (!resume_lv_origin(cmd, lv)) {
-		log_error("Problem reactivating %s.", lv->name);
-		goto out;
-	}
-
-	r = 1;
-out:
-	backup(lv->vg);
-	return r;
+	return 1;
 }
 
 static int lvchange_monitoring(struct cmd_context *cmd,
@@ -555,7 +509,6 @@ static int lvchange_readahead(struct cmd_context *cmd,
 {
 	unsigned read_ahead = 0;
 	unsigned pagesize = (unsigned) lvm_getpagesize() >> SECTOR_SHIFT;
-	int r = 0;
 
 	read_ahead = arg_uint_value(cmd, readahead_ARG, 0);
 
@@ -590,32 +543,10 @@ static int lvchange_readahead(struct cmd_context *cmd,
 	log_verbose("Setting read ahead to %u for \"%s\"", read_ahead,
 		    lv->name);
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
-		vg_revert(lv->vg);
-		goto out;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, lv))
-			stack;
-		goto_out;
-	}
-
-	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		goto out;
-	}
-
-	r = 1;
-out:
-	backup(lv->vg);
-	return r;
+	return 1;
 }
 
 static int lvchange_persistent(struct cmd_context *cmd,
@@ -814,25 +745,8 @@ static int lvchange_writemostly(struct logical_volume *lv)
 		}
 	}
 
-	if (!vg_write(lv->vg))
-		return_0;
-
-	if (!suspend_lv(cmd, lv)) {
-		vg_revert(lv->vg);
-		return_0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, lv))
-			stack;
+	if (!lv_update_and_reload(lv))
 		return_0;
-	}
-
-	log_very_verbose("Updating writemostly for \"%s\" in kernel", lv->name);
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		return 0;
-	}
 
 	return 1;
 }
@@ -862,26 +776,8 @@ static int lvchange_recovery_rate(struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!vg_write(lv->vg))
-		return_0;
-
-	if (!suspend_lv(cmd, lv)) {
-		vg_revert(lv->vg);
+	if (!lv_update_and_reload(lv))
 		return_0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, lv))
-			stack;
-		return_0;
-	}
-
-	log_very_verbose("Updating recovery rate for \"%s\" in kernel",
-			 lv->name);
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		return 0;
-	}
 
 	return 1;
 }


