From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Apr 2017 17:48:33 -0400
Subject: master - lvchange/lvconvert: fix missing lvmlockd LV locks
Message-ID: <201704052148.v35LmXd8030317@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ccb4825c7c5f40e93afea065100105f3d5f3551
Commit:        7ccb4825c7c5f40e93afea065100105f3d5f3551
Parent:        c9bc1c1c8ccd624762b59a46689467573bc2933e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 5 15:05:32 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 5 16:46:38 2017 -0500

lvchange/lvconvert: fix missing lvmlockd LV locks

lvchange/lvconvert operations that do not require the LV
to already be active need to acquire a transient LV lock
before changing/converting the LV to ensure the LV is not
active on another host.  If the LV is already active,
a persistent LV lock already exists on the host and the
transient LV lock request is a no-op.

Some lvmlockd locks in lvchange were lost in the cmd def
changes.  The lvmlockd locks in lvconvert seem to have
been missed from the start.
---
 tools/lvchange.c  |   29 +++++++++++++++++++----------
 tools/lvconvert.c |   26 ++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index a35891e..660570a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1056,16 +1056,9 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 	int i, opt_enum;
 	uint32_t mr = 0;
 
-	/*
-	 * If a persistent lv lock already exists from activation
-	 * (with the needed mode or higher), this will be a no-op.
-	 * Otherwise, the lv lock will be taken as non-persistent
-	 * and released when this command exits.
-	 */
-	if (!lockd_lv(cmd, lv, "ex", 0)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_ECMD_FAILED;
 
 	/* First group of options which allow for one metadata commit/update for the whole group */
 	for (i = 0; i < cmd->command->ro_count; i++) {
@@ -1451,6 +1444,10 @@ static int _lvchange_resync_single(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    struct processing_handle *handle)
 {
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_ECMD_FAILED;
+
 	if (!_lvchange_resync(cmd, lv))
 		return_ECMD_FAILED;
 
@@ -1502,6 +1499,10 @@ static int _lvchange_syncaction_single(struct cmd_context *cmd,
 				       struct logical_volume *lv,
 				       struct processing_handle *handle)
 {
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_ECMD_FAILED;
+
 	if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
 		return_ECMD_FAILED;
 
@@ -1532,6 +1533,10 @@ static int _lvchange_rebuild_single(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    struct processing_handle *handle)
 {
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_ECMD_FAILED;
+
 	if (!_lvchange_rebuild(lv))
 		return_ECMD_FAILED;
 
@@ -1601,6 +1606,10 @@ static int _lvchange_persistent_single(struct cmd_context *cmd,
 {
 	uint32_t mr = 0;
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_ECMD_FAILED;
+
 	if (!_lvchange_persistent(cmd, lv, &mr))
 		return_ECMD_FAILED;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a37dc25..c28a75f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1685,6 +1685,10 @@ static int _lvconvert_raid_types(struct cmd_context *cmd, struct logical_volume
 	struct lv_segment *seg = first_seg(lv);
 	int ret = 0;
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_ECMD_FAILED;
+
 	/* Set up segtype either from type_str or else to match the existing one. */
 	if (!*lp->type_str)
 		lp->segtype = seg->segtype;
@@ -2734,6 +2738,10 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return 0;
+
 	/*
 	 * If an existing LV is to be used as the metadata LV,
 	 * verify that it's in a usable state.  These checks are
@@ -2789,6 +2797,10 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				  display_lvname(metadata_lv));
 			return 0;
 		}
+
+		/* If LV is inactive here, ensure it's not active elsewhere. */
+		if (!lockd_lv(cmd, metadata_lv, "ex", 0))
+			return 0;
 	}
 
 	if (!get_pool_params(cmd, pool_segtype,
@@ -3135,6 +3147,10 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	struct dm_config_tree *policy_settings = NULL;
 	int r = 0;
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_0;
+
 	if (!validate_lv_cache_create_pool(cachepool_lv))
 		return_0;
 
@@ -3958,6 +3974,12 @@ static int _lvconvert_swap_pool_metadata_single(struct cmd_context *cmd,
 	struct logical_volume *metadata_lv;
 	const char *metadata_name;
 
+	if (is_lockd_type(lv->vg->lock_type)) {
+		/* FIXME: need to swap locks betwen LVs? */
+		log_error("Unable to swap pool metadata in VG with lock_type %s", lv->vg->lock_type);
+		goto out;
+	}
+
 	if (!(metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL)))
 		goto_out;
 
@@ -4133,6 +4155,10 @@ static int _lvconvert_split_cachepool_single(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
+	/* If LV is inactive here, ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, cache_lv, "ex", 0))
+		return_0;
+
 	switch (cmd->command->command_enum) {
 	case lvconvert_split_and_keep_cachepool_CMD:
 		ret = _lvconvert_split_and_keep_cachepool(cmd, cache_lv, cachepool_lv);


