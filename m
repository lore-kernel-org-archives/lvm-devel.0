From: okozina <okozina@fedoraproject.org>
Date: Wed, 22 Jul 2015 08:40:02 +0000 (UTC)
Subject: master - lvconvert: fix polling outside of core lvconvert
Message-ID: <20150722084002.E816C60520@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae88bf03a1d109a342a8ad31196c3ef8fa1a5b65
Commit:        ae88bf03a1d109a342a8ad31196c3ef8fa1a5b65
Parent:        c3fddb0fbbcabf73d3bcf2786cea31c179f13fae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 15 13:02:54 2015 -0500
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Jul 22 10:38:02 2015 +0200

lvconvert: fix polling outside of core lvconvert

Recent change to move the polling outside of core lvconvert
code was wrongly using 'lv' and 'vg' structs which can't be
used outside of the core code, which caused seg fault.

Properly isolate all use of lv structs within the core of
the lvconvert code, saving any information necessary,
(esp lvid).  After the core of lvconvert is done, use
the saved information to do polling.

FIXME: the need for is_merging_origin and is_merging_origin_thin
in this patch is ugly, and a cleaner way should be found to deal
with that than what is done here.

Also it effectively removed all hacks in _lvconvert_merge_single
performing ugly: VG reread, unlock, polling, lock sequence.

Moreover all polling operations are postponed after all conversions
are finished.

lvm2 (while locking via lvmlockd) should now be able to run with
or without lvmpolld while performing poll operations originating
in lvconvert command.

Signed-off-by: Ondrej Kozina <okozina@redhat.com>
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |  198 ++++++++++++++++++++++++++---------------------------
 2 files changed, 98 insertions(+), 101 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 22a0233..adf8eb7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix lvconvert segfaults while performing snapshots merge.
   Ignore errors during detection if use_blkid_wiping=1 and --force is used.
   Recognise DM_ABORT_ON_INTERNAL_ERRORS env var override in lvm logging fn.
   Fix alloc segfault when extending LV with fewer stripes than in first seg.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e673f53..58428b7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -17,7 +17,6 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
-#include "lvmpolld-client.h"
 
 struct lvconvert_params {
 	int cache;
@@ -41,6 +40,9 @@ struct lvconvert_params {
 	int wait_completion;
 	int need_polling;
 
+	int is_merging_origin;
+	int is_merging_origin_thin;
+
 	int thin_chunk_size_calc_policy;
 	uint32_t chunk_size;
 	uint32_t region_size;
@@ -69,6 +71,7 @@ struct lvconvert_params {
 	struct dm_list *replace_pvh;
 
 	struct logical_volume *lv_to_poll;
+	struct dm_list idls;
 
 	uint32_t pool_metadata_extents;
 	int passed_args;
@@ -81,6 +84,13 @@ struct lvconvert_params {
 	thin_discards_t discards;
 };
 
+struct convert_poll_id_list {
+	struct dm_list list;
+	struct poll_operation_id *id;
+	unsigned is_merging_origin:1;
+	unsigned is_merging_origin_thin:1;
+};
+
 static int _lvconvert_validate_names(struct lvconvert_params *lp)
 {
 	int i, j;
@@ -763,26 +773,41 @@ static struct poll_operation_id *_create_id(struct cmd_context *cmd,
 	return id;
 }
 
+static int _lvconvert_poll_by_id(struct cmd_context *cmd, struct poll_operation_id *id,
+				 unsigned background,
+				 int is_merging_origin,
+				 int is_merging_origin_thin)
+{
+	if (is_merging_origin)
+		return poll_daemon(cmd, background,
+				(MERGING | (is_merging_origin_thin ? THIN_VOLUME : SNAPSHOT)),
+				is_merging_origin_thin ? &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
+				"Merged", id);
+	else
+		return poll_daemon(cmd, background, CONVERTING,
+				&_lvconvert_mirror_fns, "Converted", id);
+}
+
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
-	int is_thin, r;
+	int r;
 	struct poll_operation_id *id = _create_id(cmd, lv->vg->name, lv->name, lv->lvid.s);
+	int is_merging_origin = 0;
+	int is_merging_origin_thin = 0;
 
 	if (!id) {
 		log_error("Failed to allocate poll identifier for lvconvert.");
 		return ECMD_FAILED;
 	}
 
+	/* FIXME: check this in polling instead */
 	if (lv_is_merging_origin(lv)) {
-		is_thin = seg_is_thin_volume(find_snapshot(lv));
-		r = poll_daemon(cmd, background,
-				(MERGING | (is_thin ? THIN_VOLUME : SNAPSHOT)),
-				is_thin ? &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
-				"Merged", id);
-	} else
-		r = poll_daemon(cmd, background, CONVERTING,
-				&_lvconvert_mirror_fns, "Converted", id);
+		is_merging_origin = 1;
+		is_merging_origin_thin = seg_is_thin_volume(find_snapshot(lv));
+	}
+
+	r = _lvconvert_poll_by_id(cmd, id, background, is_merging_origin, is_merging_origin_thin);
 
 	_destroy_id(cmd, id);
 
@@ -3028,7 +3053,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return_0;
 
 	/*
-	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock. 
+	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock.
 	 * Locks are removed from existing LVs that are being converted to
 	 * data and meta LVs (they are unlocked and deleted below.)
 	 */
@@ -3330,17 +3355,51 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	return ECMD_PROCESSED;
 }
 
-static int _poll_logical_volume(struct cmd_context *cmd, struct logical_volume *lv,
-			       int wait_completion)
+static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_context *cmd,
+								 const struct logical_volume *lv)
 {
+	struct convert_poll_id_list *idl = (struct convert_poll_id_list *) dm_pool_alloc(cmd->mem, sizeof(struct convert_poll_id_list));
+
+	if (!idl) {
+		log_error("Convert poll ID list allocation failed.");
+		return NULL;
+	}
+
+	if (!(idl->id = _create_id(cmd, lv->vg->name, lv->name, lv->lvid.s))) {
+		dm_pool_free(cmd->mem, idl);
+		return NULL;
+	}
+
+	idl->is_merging_origin = lv_is_merging_origin(lv);
+	idl->is_merging_origin_thin = idl->is_merging_origin && seg_is_thin_volume(find_snapshot(lv));
+
+	return idl;
+}
+
+static int _convert_and_add_to_poll_list(struct cmd_context *cmd,
+					 struct lvconvert_params *lp,
+					 struct logical_volume *lv)
+{
+	int ret;
 	struct lvinfo info;
+	struct convert_poll_id_list *idl;
 
-	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
-		log_print_unless_silent("Conversion starts after activation.");
-		return ECMD_PROCESSED;
+	/* _lvconvert_single() call may alter the reference in lp->lv_to_poll */
+	if ((ret = _lvconvert_single(cmd, lv, lp)) != ECMD_PROCESSED)
+		stack;
+	else if (lp->need_polling) {
+		if (!lv_info(cmd, lp->lv_to_poll, 0, &info, 0, 0) || !info.exists)
+			log_print_unless_silent("Conversion starts after activation.");
+		else {
+			idl = _convert_poll_id_list_create(cmd, lp->lv_to_poll);
+			if (!idl)
+				return_ECMD_FAILED;
+			else
+				dm_list_add(&lp->idls, &idl->list);
+		}
 	}
 
-	return lvconvert_poll(cmd, lv, wait_completion ? 0 : 1U);
+	return ret;
 }
 
 static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
@@ -3402,7 +3461,8 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 			goto_bad;
 
 	lp->lv_to_poll = lv;
-	ret = _lvconvert_single(cmd, lv, lp);
+	ret = _convert_and_add_to_poll_list(cmd, lp, lv);
+
 bad:
 	unlock_vg(cmd, lp->vg_name);
 
@@ -3412,10 +3472,6 @@ bad:
 	 */
 	lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state);
 
-	if (ret == ECMD_PROCESSED && lp->need_polling)
-		ret = _poll_logical_volume(cmd, lp->lv_to_poll,
-					  lp->wait_completion);
-
 	release_vg(vg);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
@@ -3426,84 +3482,16 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 				   struct processing_handle *handle)
 {
 	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
-	const char *vg_name;
-	struct volume_group *vg_fresh;
-	struct logical_volume *lv_fresh;
-	int ret = ECMD_FAILED;
-	uint32_t lockd_state = 0; /* dummy placeholder, lvmlockd doesn't use this path */
-
-	/*
-	 * FIXME can't trust lv's VG to be current given that caller
-	 * is process_each_lv() -- _poll_logical_volume() may have
-	 * already updated the VG's metadata in an earlier iteration.
-	 * - preemptively drop the VG lock, as is needed for
-	 *   _poll_logical_volume(), refresh LV (and VG in the process).
-	 */
-
-	vg_name = lv->vg->name;
-	unlock_vg(cmd, vg_name);
-	vg_fresh = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE, lockd_state);
-	if (vg_read_error(vg_fresh)) {
-		log_error("ABORTING: Can't reread VG %s", vg_name);
-		goto out;
-	}
-
-	if (!(lv_fresh = find_lv(vg_fresh, lv->name))) {
-		log_error("ABORTING: Can't find LV %s in VG %s", lv->name, vg_name);
-		unlock_vg(cmd, vg_name);
-		goto out;
-	}
-
-	lp->lv_to_poll = lv_fresh;
-	if ((ret = _lvconvert_single(cmd, lv_fresh, lp)) != ECMD_PROCESSED)
-		stack;
-
-	if (ret == ECMD_PROCESSED && lp->need_polling) {
-		/*
-		 * Must drop VG lock, because lvconvert_poll() needs it,
-		 * then reacquire it after polling completes
-		 */
-		unlock_vg(cmd, vg_name);
-
-		if ((ret = _poll_logical_volume(cmd, lp->lv_to_poll,
-						 lp->wait_completion)) != ECMD_PROCESSED)
-			stack;
-
-		/* use LCK_VG_WRITE to match lvconvert()'s READ_FOR_UPDATE */
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
-			log_error("ABORTING: Can't relock VG for %s "
-				  "after polling finished", vg_name);
-			ret = ECMD_FAILED;
-		}
-	}
-out:
-	release_vg(vg_fresh);
-	return ret;
-}
-
-/*
- * process_each_lv locks the VG, reads the VG, calls this which starts the
- * conversion, then unlocks the VG.  The lvpoll command will come along later
- * and lock the VG, read the VG, check the progress, unlock the VG, sleep and
- * repeat until done.
- */
-
-static int _lvconvert_lvmpolld_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
-					    struct processing_handle *handle)
-{
-	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
-	int ret;
 
 	lp->lv_to_poll = lv;
-	if ((ret = _lvconvert_single(cmd, lv, lp)) != ECMD_PROCESSED)
-		stack;
 
-	return ret;
+	return _convert_and_add_to_poll_list(cmd, lp, lv);
 }
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
 	int ret;
+	struct convert_poll_id_list *idl;
 	struct lvconvert_params lp = {
 		.target_attr = ~0,
 	};
@@ -3515,6 +3503,8 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		goto out;
 	}
 
+	dm_list_init(&lp.idls);
+
 	handle->custom_handle = &lp;
 
 	if (!_read_params(cmd, argc, argv, &lp)) {
@@ -3522,18 +3512,24 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		goto_out;
 	}
 
-	if (lp.merge) {
+	if (lp.merge)
 		ret = process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, handle,
-				    lvmpolld_use() ? &_lvconvert_lvmpolld_merge_single :
-				    		     &_lvconvert_merge_single);
-
-		if (ret == ECMD_PROCESSED && lvmpolld_use() && lp.need_polling) {
-			if ((ret = _poll_logical_volume(cmd, lp.lv_to_poll, lp.wait_completion)) != ECMD_PROCESSED)
-				stack;
-		}
-	} else
+				      &_lvconvert_merge_single);
+	else
 		ret = lvconvert_single(cmd, &lp);
+
+	dm_list_iterate_items(idl, &lp.idls) {
+		ret = _lvconvert_poll_by_id(cmd, idl->id,
+					    lp.wait_completion ? 0 : 1U,
+					    idl->is_merging_origin,
+					    idl->is_merging_origin_thin);
+		if (ret != ECMD_PROCESSED)
+			goto out;
+	}
+
 out:
+	if (!dm_list_empty(&lp.idls))
+		dm_pool_free(cmd->mem, dm_list_item(dm_list_first(&lp.idls), struct convert_poll_id_list));
 	if (lp.policy_settings)
 		dm_config_destroy(lp.policy_settings);
 	destroy_processing_handle(cmd, handle);


