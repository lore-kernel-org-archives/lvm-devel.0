From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 08:18:00 -0400
Subject: stable-2.02 - mirror: remove unused code
Message-ID: <201910311218.x9VCI08A010832@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b7bcf3ed4b5e427984bd7883238e681405edf5f
Commit:        4b7bcf3ed4b5e427984bd7883238e681405edf5f
Parent:        cf426744aef84d993b95926b23489f55f9a25838
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 12:10:00 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 13:00:01 2019 +0100

mirror: remove unused code

---
 lib/metadata/mirror.c |  157 -------------------------------------------------
 1 files changed, 0 insertions(+), 157 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6cd88cb..411079a 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1176,163 +1176,6 @@ int collapse_mirrored_lv(struct logical_volume *lv)
 	return 1;
 }
 
-#if 0
-/* FIXME: reconfigure_mirror_images: remove this code? */
-static int _get_mirror_fault_policy(struct cmd_context *cmd __attribute__((unused)),
-				   int log_policy)
-{
-	const char *policy = NULL;
-/*
-	if (log_policy)
-		policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG);
-	else {
-		policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG);
-		if (!policy)
-			policy = find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG);
-	}
-*/
-	if (!strcmp(policy, "remove"))
-		return MIRROR_REMOVE;
-	else if (!strcmp(policy, "allocate"))
-		return MIRROR_ALLOCATE;
-	else if (!strcmp(policy, "allocate_anywhere"))
-		return MIRROR_ALLOCATE_ANYWHERE;
-
-	if (log_policy)
-		log_error("Bad activation/mirror_log_fault_policy");
-	else
-		log_error("Bad activation/mirror_device_fault_policy");
-
-	return MIRROR_REMOVE;
-}
-
-static int _get_mirror_log_fault_policy(struct cmd_context *cmd)
-{
-	return _get_mirror_fault_policy(cmd, 1);
-}
-
-static int _get_mirror_device_fault_policy(struct cmd_context *cmd)
-{
-	return _get_mirror_fault_policy(cmd, 0);
-}
-
-/*
- * replace_mirror_images
- * @mirrored_seg: segment (which may be linear now) to restore
- * @num_mirrors: number of copies we should end up with
- * @replace_log: replace log if not present
- * @in_sync: was the original mirror in-sync?
- *
- * in_sync will be set to 0 if new mirror devices are being added
- * In other words, it is only useful if the log (and only the log)
- * is being restored.
- *
- * Returns: 0 on failure, 1 on reconfig, -1 if no reconfig done
- */
-static int _replace_mirror_images(struct lv_segment *mirrored_seg,
-				 uint32_t num_mirrors,
-				 int log_policy, int in_sync)
-{
-	int r = -1;
-	struct logical_volume *lv = mirrored_seg->lv;
-
-	/* FIXME: Use lvconvert rather than duplicating its code */
-
-	if (mirrored_seg->area_count < num_mirrors) {
-		log_warn("WARNING: Failed to replace mirror device in %s.",
-			 display_lvname(mirrored_seg->lv);
-
-		if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv)
-			log_warn("WARNING: Use 'lvconvert -m %d %s --corelog' to replace failed devices.",
-				 num_mirrors - 1, display_lvname(lv));
-		else
-			log_warn("WARNING: Use 'lvconvert -m %d %s' to replace failed devices.",
-				 num_mirrors - 1, display_lvname(lv));
-		r = 0;
-
-		/* REMEMBER/FIXME: set in_sync to 0 if a new mirror device was added */
-		in_sync = 0;
-	}
-
-	/*
-	 * FIXME: right now, we ignore the allocation policy specified to
-	 * allocate the new log.
-	 */
-	if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv &&
-	    (log_policy != MIRROR_REMOVE)) {
-		log_warn("WARNING: Failed to replace mirror log device in %s.",
-			 display_lvname(lv));
-
-		log_warn("WARNING: Use 'lvconvert -m %d %s' to replace failed devices.",
-			 mirrored_seg->area_count - 1 , display_lvname(lv));
-		r = 0;
-	}
-
-	return r;
-}
-
-int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			      struct dm_list *removable_pvs, unsigned remove_log)
-{
-	int r;
-	int in_sync;
-	int log_policy, dev_policy;
-	uint32_t old_num_mirrors = mirrored_seg->area_count;
-	int had_log = (mirrored_seg->log_lv) ? 1 : 0;
-
-	/* was the mirror in-sync before problems? */
-	in_sync = _mirrored_lv_in_sync(mirrored_seg->lv);
-
-	/*
-	 * While we are only removing devices, we can have sync set.
-	 * Setting this is only useful if we are moving to core log
-	 * otherwise the disk log will contain the sync information
-	 */
-	init_mirror_in_sync(in_sync);
-
-	r = _remove_mirror_images(mirrored_seg->lv, old_num_mirrors - num_mirrors,
-				  is_mirror_image_removable, removable_pvs,
-				  remove_log, 0, NULL, 0);
-	if (!r)
-		/* Unable to remove bad devices */
-		return 0;
-
-	log_warn("WARNING: Bad device removed from mirror volume %s.",
-		  display_lvname(mirrored_seg->lv));
-
-	log_policy = _get_mirror_log_fault_policy(mirrored_seg->lv->vg->cmd);
-	dev_policy = _get_mirror_device_fault_policy(mirrored_seg->lv->vg->cmd);
-
-	r = _replace_mirror_images(mirrored_seg,
-				  (dev_policy != MIRROR_REMOVE) ?
-				  old_num_mirrors : num_mirrors,
-				  log_policy, in_sync);
-
-	if (!r)
-		/* Failed to replace device(s) */
-		log_warn("WARNING: Unable to find substitute device for mirror volume %s.",
-			 display_lvname(mirrored_seg->lv));
-	else if (r > 0)
-		/* Success in replacing device(s) */
-		log_warn("WARNING: Mirror volume %s restored - substitute for failed device found.",
-			 display_lvname(mirrored_seg->lv));
-	else
-		/* Bad device removed, but not replaced because of policy */
-		if (mirrored_seg->area_count == 1) {
-			log_warn("WARNING: Mirror volume %s converted to linear due to device failure.",
-				  display_lvname(mirrored_seg->lv);
-		} else if (had_log && !mirrored_seg->log_lv) {
-			log_warn("WARNING: Mirror volume %s disk log removed due to device failure.",
-				  display_lvname(mirrored_seg->lv));
-		}
-	/*
-	 * If we made it here, we at least removed the bad device.
-	 * Consider this success.
-	 */
-	return 1;
-}
-#endif
-
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,
 			      uint32_t stripes,


