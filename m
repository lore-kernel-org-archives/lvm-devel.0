From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:24 +0000 (UTC)
Subject: master - lvcreate: use process_each_vg
Message-ID: <20151202000824.6040460AC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f7571eb287ff3810d93485f6be7d5e1fad2bb250
Commit:        f7571eb287ff3810d93485f6be7d5e1fad2bb250
Parent:        ea74215fa1f76cc965efd4f4656ad74321827161
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 17:32:49 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:36:52 2015 -0600

lvcreate: use process_each_vg

No functional change.
---
 tools/lvcreate.c |  123 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 71 insertions(+), 52 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0debf40..e0d665b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -25,6 +25,11 @@ struct lvcreate_cmdline_params {
 	uint32_t pv_count;
 };
 
+struct processing_params {
+	struct lvcreate_params *lp;
+	struct lvcreate_cmdline_params *lcp;
+};
+
 static int _set_vg_name(struct lvcreate_params *lp, const char *vg_name)
 {
 	/* Can't do anything */
@@ -1445,74 +1450,51 @@ static void _destroy_lvcreate_params(struct lvcreate_params *lp)
 	}
 }
 
-int lvcreate(struct cmd_context *cmd, int argc, char **argv)
+static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg, struct processing_handle *handle)
 {
-	int r = ECMD_FAILED;
-	struct lvcreate_params lp = {
-		.major = -1,
-		.minor = -1,
-	};
-	struct lvcreate_cmdline_params lcp = { 0 };
-	struct volume_group *vg;
-	uint32_t lockd_state = 0;
-
-	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
-		stack;
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!_check_pool_parameters(cmd, NULL, &lp, &lcp)) {
-		stack;
-		return EINVALID_CMD_LINE;
-	}
+	struct processing_params *pp = (struct processing_params *) handle->custom_handle;
+	struct lvcreate_params *lp = pp->lp;
+	struct lvcreate_cmdline_params *lcp = pp->lcp;
+	int ret = ECMD_FAILED;
 
-	if (!lockd_vg(cmd, lp.vg_name, "ex", 0, &lockd_state))
-		return_ECMD_FAILED;
-
-	log_verbose("Finding volume group \"%s\"", lp.vg_name);
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		return_ECMD_FAILED;
-	}
-
-	if (!_read_activation_params(cmd, vg, &lp))
+	if (!_read_activation_params(cmd, vg, lp))
 		goto_out;
 
 	/* Resolve segment types with opened VG */
-	if (lp.snapshot && lp.origin_name && !_determine_snapshot_type(vg, &lp, &lcp))
+	if (lp->snapshot && lp->origin_name && !_determine_snapshot_type(vg, lp, lcp))
 		goto_out;
 
-	if (seg_is_cache(&lp) && !_determine_cache_argument(vg, &lp))
+	if (seg_is_cache(lp) && !_determine_cache_argument(vg, lp))
 		goto_out;
 
 	/* All types resolved at this point, now only validation steps */
-	if (seg_is_raid(&lp) && !_check_raid_parameters(vg, &lp, &lcp))
+	if (seg_is_raid(lp) && !_check_raid_parameters(vg, lp, lcp))
 		goto_out;
 
-	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
+	if (seg_is_thin(lp) && !_check_thin_parameters(vg, lp, lcp))
 		goto_out;
 
-	if (!_check_pool_parameters(cmd, vg, &lp, &lcp))
+	if (!_check_pool_parameters(cmd, vg, lp, lcp))
 		goto_out;
 
 	/* All types are checked */
-	if (!_check_zero_parameters(cmd, &lp))
+	if (!_check_zero_parameters(cmd, lp))
 		return_0;
 
-	if (!_update_extents_params(vg, &lp, &lcp))
+	if (!_update_extents_params(vg, lp, lcp))
 		goto_out;
 
-	if (seg_is_thin(&lp) && !_validate_internal_thin_processing(&lp))
+	if (seg_is_thin(lp) && !_validate_internal_thin_processing(lp))
 		goto_out;
 
-	if (lp.create_pool) {
-		if (!handle_pool_metadata_spare(vg, lp.pool_metadata_extents,
-						lp.pvh, lp.pool_metadata_spare))
+	if (lp->create_pool) {
+		if (!handle_pool_metadata_spare(vg, lp->pool_metadata_extents,
+						lp->pvh, lp->pool_metadata_spare))
 			goto_out;
 
 		log_verbose("Making pool %s in VG %s using segtype %s",
-			    lp.pool_name ? : "with generated name", lp.vg_name, lp.segtype->name);
+			    lp->pool_name ? : "with generated name", lp->vg_name, lp->segtype->name);
 	}
 
 	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
@@ -1522,22 +1504,59 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (seg_is_thin_volume(&lp))
+	if (seg_is_thin_volume(lp))
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
-			    lp.lv_name ? : "with generated name",
-			    lp.pool_name ? : "with generated name", lp.vg_name,
-			    lp.snapshot ? " as snapshot of " : "",
-			    lp.snapshot ? lp.origin_name : "", lp.segtype->name);
+			    lp->lv_name ? : "with generated name",
+			    lp->pool_name ? : "with generated name", lp->vg_name,
+			    lp->snapshot ? " as snapshot of " : "",
+			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
 	if (is_lockd_type(vg->lock_type))
-		lp.needs_lockd_init = 1;
+		lp->needs_lockd_init = 1;
 
-	if (!lv_create_single(vg, &lp))
+	if (!lv_create_single(vg, lp))
 		goto_out;
 
-	r = ECMD_PROCESSED;
+	ret = ECMD_PROCESSED;
 out:
+	return ret;
+}
+
+int lvcreate(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle = NULL;
+	struct processing_params pp;
+	struct lvcreate_params lp = {
+		.major = -1,
+		.minor = -1,
+	};
+	struct lvcreate_cmdline_params lcp = { 0 };
+	int ret;
+
+	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!_check_pool_parameters(cmd, NULL, &lp, &lcp)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	pp.lp = &lp;
+	pp.lcp = &lcp;
+
+        if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &pp;
+
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, READ_FOR_UPDATE, handle,
+			      &_lvcreate_single);
+
 	_destroy_lvcreate_params(&lp);
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
-	return r;
+	destroy_processing_handle(cmd, handle);
+	return ret;
 }


