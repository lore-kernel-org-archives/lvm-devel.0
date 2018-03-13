From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:02:39 -0400
Subject: master - mirror: correct locking for mirror log initialization
Message-ID: <201803131202.w2DC2dV0002015@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29b2cfba06ee849774025c50599edb1c7587b7d9
Commit:        29b2cfba06ee849774025c50599edb1c7587b7d9
Parent:        1bd57b4c1d4a6d715d24ab5dc162c350b97fc613
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 13 12:48:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:27 2018 +0100

mirror: correct locking for mirror log initialization

The code was not acking proper lock holding LVs when trying to
initialize mirror log to predefined values.
---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |  103 +++++++++++++++++--------------------------------
 2 files changed, 37 insertions(+), 67 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1d9e61c..faf43fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Enhance mirror log initialization for old mirror target.
   Skip private crypto and stratis devices.
   Skip frozen raid devices from scanning.
   Activate RAID SubLVs on read_only_volume_list readwrite
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6419b5c..d3ced60 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -317,8 +317,13 @@ static int _init_mirror_log(struct cmd_context *cmd,
 			    struct dm_list *tagsl, int remove_on_failure)
 {
 	struct dm_str_list *sl;
-	uint64_t orig_status = log_lv->status;
-	int was_active = 0;
+
+	if (log_lv != lv_lock_holder(log_lv) || !lv_is_visible(log_lv)) {
+		/* Expect fully visible device for init */
+		log_error(INTERNAL_ERROR "Log LV %s is not top level LV for initialization.",
+			  display_lvname(log_lv));
+		return 0;
+	}
 
 	if (test_mode()) {
 		log_verbose("Test mode: Skipping mirror log initialisation.");
@@ -331,53 +336,22 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* If the LV is active, deactivate it first. */
-	if (lv_is_active(log_lv)) {
-		(void) deactivate_lv(cmd, log_lv);
-		/*
-		 * FIXME: workaround to fail early
-		 * Ensure that log is really deactivated because deactivate_lv
-		 * on cluster do not fail if there is log_lv with different UUID.
-		 */
-		if (lv_is_active(log_lv)) {
-			log_error("Aborting. Unable to deactivate mirror log.");
-			goto revert_new_lv;
-		}
-		was_active = 1;
-	}
-
-	/* Temporary make it visible for set_lv() */
-	lv_set_visible(log_lv);
-
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tagsl)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
 			log_error("Aborting. Unable to tag mirror log.");
-			goto activate_lv;
+			return 0;
 		}
 
 	/* store mirror log on disk(s) */
 	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
-		goto activate_lv;
-
-	backup(log_lv->vg);
-
-	/* Wait for events following any deactivation before reactivating */
-	if (!sync_local_dev_names(cmd)) {
-		log_error("Aborting. Failed to sync local devices before initialising mirror log %s.",
-			  display_lvname(log_lv));
-		goto revert_new_lv;
-	}
+		return_0;
 
-	if (!activate_lv(cmd, log_lv)) {
+	if (!activate_lv_excl_local(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
 	}
 
-	/* Remove the temporary tags */
-	dm_list_iterate_items(sl, tagsl)
-		str_list_del(&log_lv->tags, sl->str);
-
 	if (activation()) {
 		if (!wipe_lv(log_lv, (struct wipe_params)
 			     { .do_zero = 1, .zero_sectors = log_lv->size,
@@ -385,23 +359,29 @@ static int _init_mirror_log(struct cmd_context *cmd,
 			log_error("Aborting. Failed to wipe mirror log.");
 			goto deactivate_and_revert_new_lv;
 		}
-	}
 
-	if (activation() && !_write_log_header(cmd, log_lv)) {
-		log_error("Aborting. Failed to write mirror log header.");
-		goto deactivate_and_revert_new_lv;
+		if (!_write_log_header(cmd, log_lv)) {
+			log_error("Aborting. Failed to write mirror log header.");
+			goto deactivate_and_revert_new_lv;
+		}
 	}
 
 	if (!deactivate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to deactivate mirror log. "
 			  "Manual intervention required.");
-		return 0;
+		goto revert_new_lv;
 	}
 
-	lv_set_hidden(log_lv);
+	/* Wait for events following any deactivation before reactivating */
+	if (!sync_local_dev_names(cmd)) {
+		log_error("Aborting. Failed to sync local devices before initialising mirror log %s.",
+			  display_lvname(log_lv));
+		goto revert_new_lv;
+	}
 
-	if (was_active && !activate_lv(cmd, log_lv))
-		return_0;
+	/* Remove the temporary tags */
+	dm_list_iterate_items(sl, tagsl)
+		str_list_del(&log_lv->tags, sl->str);
 
 	return 1;
 
@@ -413,8 +393,6 @@ deactivate_and_revert_new_lv:
 	}
 
 revert_new_lv:
-	log_lv->status = orig_status;
-
 	dm_list_iterate_items(sl, tagsl)
 		str_list_del(&log_lv->tags, sl->str);
 
@@ -430,10 +408,6 @@ revert_new_lv:
 	else
 		backup(log_lv->vg);
 
-activate_lv:
-	if (was_active && !remove_on_failure && !activate_lv(cmd, log_lv))
-		return_0;
-
 	return 0;
 }
 
@@ -657,6 +631,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 	struct lv_list *lvl;
 	struct cmd_context *cmd = lv->vg->cmd;
 	char layer_name[NAME_LEN], format[NAME_LEN];
+	int act;
 
 	if (!lv_is_mirrored(lv)) {
 		log_error("Unable to split non-mirrored LV %s.",
@@ -791,30 +766,22 @@ static int _split_mirror_images(struct logical_volume *lv,
 	 * Suspend and resume the mirror - this includes all
 	 * the sub-LVs and soon-to-be-split sub-LVs
 	 */
-	if (!lv_update_and_reload(mirrored_seg->lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
-	/*
-	 * Recycle newly split LV so it is properly renamed.
-	 *   Cluster requires the extra deactivate/activate calls.
-	 */
-	if (vg_is_clustered(lv->vg) &&
-	    (!deactivate_lv(cmd, new_lv) ||
-	     !_activate_lv_like_model(lv, new_lv))) {
-		log_error("Failed to rename newly split LV in the kernel");
-		return 0;
-	}
-	if (!suspend_lv(cmd, new_lv) || !resume_lv(cmd, new_lv)) {
+	act = lv_is_active(lv_lock_holder(lv));
+
+	if (act && !_activate_lv_like_model(lv, new_lv)) {
 		log_error("Failed to rename newly split LV in the kernel");
 		return 0;
 	}
 
 	/* Remove original mirror layer if it has been converted to linear */
-	if (sub_lv && !_delete_lv(lv, sub_lv, 1))
+	if (sub_lv && !_delete_lv(lv, sub_lv, act))
 		return_0;
 
 	/* Remove the log if it has been converted to linear */
-	if (detached_log_lv && !_delete_lv(lv, detached_log_lv, 1))
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv, act))
 		return_0;
 
 	return 1;
@@ -1051,15 +1018,17 @@ static int _remove_mirror_images(struct logical_volume *lv,
 
 	/* Mirror with only 1 area is 'in sync'. */
 	if (new_area_count == 1 && is_temporary_mirror_layer(lv)) {
-		if (first_seg(lv)->log_lv &&
-		    !_init_mirror_log(lv->vg->cmd, first_seg(lv)->log_lv,
+		detached_log_lv = detach_mirror_log(mirrored_seg);
+		if (!_init_mirror_log(lv->vg->cmd, detached_log_lv,
 				      1, &lv->tags, 0)) {
 			/* As a result, unnecessary sync may run after
 			 * collapsing. But safe.*/
 			log_error("Failed to initialize log device %s.",
-				  display_lvname(first_seg(lv)->log_lv));
+				  display_lvname(detached_log_lv));
 			return 0;
 		}
+		if (!attach_mirror_log(mirrored_seg, detached_log_lv))
+			return_0;
 	}
 
 	if (removed)


