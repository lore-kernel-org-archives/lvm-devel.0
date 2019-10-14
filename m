From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:43 -0400
Subject: master - cachevol: drop no longer needed functions
Message-ID: <201910141322.x9EDMhFL018854@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cd308d6406d297591c9a9f3ee043efe9150203b
Commit:        1cd308d6406d297591c9a9f3ee043efe9150203b
Parent:        201ffbd04a76789eb5b1ef3aced6a89cb064d4c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 10:23:51 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:20:25 2019 +0200

cachevol: drop no longer needed functions

Code is no longer used/needed.
---
 lib/activate/dev_manager.c       |   85 ------------------
 lib/activate/dev_manager.h       |    8 --
 lib/metadata/cache_manip.c       |  180 --------------------------------------
 lib/metadata/metadata-exported.h |    1 -
 4 files changed, 0 insertions(+), 274 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e7aa6b1..38a397b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -837,91 +837,6 @@ static int _info(struct cmd_context *cmd,
 	return 1;
 }
 
-/* FIXME: could we just use dev_manager_info instead of this? */
-
-int get_cache_vol_meta_data(struct cmd_context *cmd,
-				    struct logical_volume *lv,
-				    struct logical_volume *pool_lv,
-				    struct dm_info *info_meta, struct dm_info *info_data)
-{
-	struct lv_segment *lvseg = first_seg(lv);
-	union lvid lvid_meta;
-	union lvid lvid_data;
-	char *name_meta;
-	char *name_data;
-	char *dlid_meta;
-	char *dlid_data;
-
-	memset(&lvid_meta, 0, sizeof(lvid_meta));
-	memset(&lvid_data, 0, sizeof(lvid_meta));
-	memcpy(&lvid_meta.id[0], &lv->vg->id, sizeof(struct id));
-	memcpy(&lvid_meta.id[1], &lvseg->metadata_id, sizeof(struct id));
-	memcpy(&lvid_data.id[0], &lv->vg->id, sizeof(struct id));
-	memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
-
-	if (!(dlid_meta = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_meta.s, "cmeta")))
-		return_0;
-	if (!(dlid_data = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_data.s, "cdata")))
-		return_0;
-	if (!(name_meta = dm_build_dm_name(cmd->mem, lv->vg->name, pool_lv->name, "_cmeta")))
-		return_0;
-	if (!(name_data = dm_build_dm_name(cmd->mem, lv->vg->name, pool_lv->name, "_cdata")))
-		return_0;
-
-	if (!_info(cmd, name_meta, dlid_meta, 1, 0, info_meta, NULL, NULL))
-		return_0;
-
-	if (!_info(cmd, name_data, dlid_data, 1, 0, info_data, NULL, NULL))
-		return_0;
-
-	return 1;
-}
-
-/*
- * FIXME: isn't there a simpler, more direct way to just remove these two dm
- * devs?
- */
-
-int remove_cache_vol_meta_data(struct cmd_context *cmd,
-				       struct dm_info *info_meta, struct dm_info *info_data)
-{
-	struct dm_tree *dtree;
-	struct dm_tree_node *root;
-	struct dm_tree_node *child;
-	const char *uuid;
-	void *handle = NULL;
-
-	if (!(dtree = dm_tree_create()))
-		goto_out;
-
-	if (!dm_tree_add_dev(dtree, info_meta->major, info_meta->minor))
-		goto_out;
-
-	if (!dm_tree_add_dev(dtree, info_data->major, info_data->minor))
-		goto_out;
-
-	if (!(root = dm_tree_find_node(dtree, 0, 0)))
-		goto_out;
-
-	while ((child = dm_tree_next_child(&handle, root, 0))) {
-		if (!(uuid = dm_tree_node_get_uuid(child))) {
-			stack;
-			continue;
-		}
-
-		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid))) {
-			stack;
-			continue;
-		}
-	}
-
-	dm_tree_free(dtree);
-	return 1;
- out:
-	dm_tree_free(dtree);
-	return 0;
-}
-
 int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor)
 {
 	struct dm_task *dmt;
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index d159364..d3d9ce4 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -109,12 +109,4 @@ int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor);
 
 int dev_manager_check_prefix_dm_major_minor(uint32_t major, uint32_t minor, const char *prefix);
 
-int get_cache_vol_meta_data(struct cmd_context *cmd,
-                                    struct logical_volume *lv,
-                                    struct logical_volume *pool_lv,
-                                    struct dm_info *info_meta, struct dm_info *info_data);
-
-int remove_cache_vol_meta_data(struct cmd_context *cmd,
-                                       struct dm_info *info_meta, struct dm_info *info_data);
-
 #endif
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 9ace494..6eb68d5 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -562,186 +562,6 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	return 1;
 }
 
-static int _lv_detach_cache_vol_while_active(struct cmd_context *cmd, struct logical_volume *cache_lv)
-{
-	struct lv_segment *cache_seg = first_seg(cache_lv);
-	struct logical_volume *corigin_lv;
-	struct logical_volume *cache_pool_lv;
-	struct lvinfo corigin_info;
-	struct dm_info info_meta;
-	struct dm_info info_data;
-	int is_clear;
-
-	cache_pool_lv = cache_seg->pool_lv;
-
-	corigin_lv = seg_lv(cache_seg, 0);
-
-	/*
-	 * This info is needed to remove the corigin lv at the end.
-	 */
-	if (!lv_info(cmd, corigin_lv, 1, &corigin_info, 0, 0))
-		log_error("Failed to get info about corigin %s", display_lvname(corigin_lv));
-
-	/*
-	 * This info is needed to remove the cmeta/cdata devs at the end.
-	 */
-	if (!get_cache_vol_meta_data(cmd, cache_lv, cache_pool_lv, &info_meta, &info_data)) {
-		log_error("Failed to get info about cdata/cmeta for %s", display_lvname(cache_pool_lv));
-		return 0;
-	}
-
-	/*
-	 * Flush the cache.
-	 */
-	if (!lv_cache_wait_for_clean(cache_lv, &is_clear)) {
-		log_error("Failed to flush cache for detaching LV %s.", display_lvname(cache_lv));
-		return_0;
-	}
-
-	/*
-	 * The main job of detaching the cache.
-	 */
-
-	if (!detach_pool_lv(cache_seg)) {
-		log_error("Failed to detach cache from %s", display_lvname(cache_lv));
-		return_0;
-	}
-
-	cache_pool_lv->status &= ~LV_CACHE_VOL;
-
-	if (!remove_layer_from_lv(cache_lv, corigin_lv)) {
-		log_error("Failed to remove cache layer from %s", display_lvname(cache_lv));
-		return_0;
-	}
-
-	if (!lv_update_and_reload(cache_lv)) {
-		log_error("Failed to update and reload after detaching cache from %s", display_lvname(cache_lv));
-		return 0;
-	}
-
-	/*
-	 * Detaching the cache is done, now finish cleaning up what's left over
-	 * from when the cache was attached: deactivate the cache_pool_lv, and
-	 * remove the unused dm dev for corigin_lv.
-	 */
-
-	/* These cmeta/cdata dm devs need to be removed since they are using cache_pool_lv. */
-	if (!remove_cache_vol_meta_data(cmd, &info_meta, &info_data))
-		log_error("Failed to remove cdata/cmeta devs for %s", display_lvname(cache_pool_lv));
-
-	if (!deactivate_lv(cmd, cache_pool_lv))
-		log_error("Failed to deactivate the detached cache %s", display_lvname(cache_pool_lv));
-
-	if (!corigin_info.major || !corigin_info.minor) {
-		log_error("Invalid device number %u:%u for corigin %s",
-			  corigin_info.major, corigin_info.minor, display_lvname(corigin_lv));
-		return 1;
-	}
-
-	dm_udev_set_sync_support(0);
-
-	if (!dev_manager_remove_dm_major_minor(corigin_info.major, corigin_info.minor))
-		log_error("Failed to remove the unused corigin dev %s", display_lvname(corigin_lv));
-
-	dm_udev_set_sync_support(1);
-
-	if (!lv_remove(corigin_lv)) {
-		log_error("Failed to remove unused cache layer %s for %s",
-			  display_lvname(corigin_lv),
-			  display_lvname(cache_lv));
-		return_0;
-	}
-
-	return 1;
-}
-
-static int _lv_detach_cache_vol_while_inactive(struct cmd_context *cmd, struct logical_volume *cache_lv, int noflush)
-{
-	struct lv_segment *cache_seg = first_seg(cache_lv);
-	struct logical_volume *corigin_lv;
-	struct logical_volume *cache_pool_lv;
-	int cache_mode;
-	int is_clear;
-
-	cache_pool_lv = cache_seg->pool_lv;
-
-	corigin_lv = seg_lv(cache_seg, 0);
-
-	cache_mode = cache_seg->cache_mode;
-
-	/*
-	 * With these modes there is no flush needed so we can immediately
-	 * detach without temporarily activating the LV to flush it.
-	 */
-	if ((cache_mode == CACHE_MODE_WRITETHROUGH) || (cache_mode == CACHE_MODE_PASSTHROUGH) || noflush)
-		goto detach;
-
-	/*
-	 * With mode WRITEBACK we need to activate the cache LV to flush/clean
-	 * it before detaching the cache.
-	 *
-	 * LV_TEMPORARY should prevent the active LV from being exposed and
-	 * used outside of lvm.
-	 */
-
-	log_debug("Activating %s internally for cache flush.", display_lvname(cache_lv));
-
-	cache_lv->status |= LV_TEMPORARY;
-
-	if (!activate_lv(cmd, cache_lv)) {
-		log_error("Failed to activate LV %s to flush cache.", display_lvname(cache_lv));
-		return 0;
-	}
-
-	if (!lv_cache_wait_for_clean(cache_lv, &is_clear)) {
-		log_error("Failed to flush cache for detaching LV %s.", display_lvname(cache_lv));
-		return_0;
-	}
-
-	if (!deactivate_lv(cmd, cache_lv)) {
-		log_error("Failed to deactivate LV %s for detaching cache.", display_lvname(cache_lv));
-		return 0;
-	}
-	cache_lv->status &= ~LV_TEMPORARY;
-
- detach:
-	if (!detach_pool_lv(cache_seg)) {
-		log_error("Failed to detach cache from %s", display_lvname(cache_lv));
-		return_0;
-	}
-
-	cache_pool_lv->status &= ~LV_CACHE_VOL;
-
-	if (!remove_layer_from_lv(cache_lv, corigin_lv)) {
-		log_error("Failed to remove cache layer from %s", display_lvname(cache_lv));
-		return_0;
-	}
-
-	if (!lv_remove(corigin_lv)) {
-		log_error("Failed to remove unused cache layer %s for %s",
-			  display_lvname(corigin_lv),
-			  display_lvname(cache_lv));
-		return_0;
-	}
-
-	return 1;
-}
-
-int lv_detach_cache_vol(struct logical_volume *cache_lv, int noflush)
-{
-	struct cmd_context *cmd = cache_lv->vg->cmd;
-
-	if (lv_is_pending_delete(cache_lv)) {
-		log_error("Already detaching cache pool from %s.", display_lvname(cache_lv));
-		return 0;
-	}
-
-	if (lv_is_active(cache_lv))
-		return _lv_detach_cache_vol_while_active(cmd, cache_lv);
-	else
-		return _lv_detach_cache_vol_while_inactive(cmd, cache_lv, noflush);
-}
-
 /*
  * lv_cache_remove
  * @cache_lv
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8239fed..2d97753 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1279,7 +1279,6 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 				       struct logical_volume *origin_lv);
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
-int lv_detach_cache_vol(struct logical_volume *cache_lv, int noflush);
 int lv_detach_writecache_cachevol(struct logical_volume *cache_lv, int noflush);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */


