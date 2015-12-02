From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:28 +0000 (UTC)
Subject: master - lvresize: use process_each_vg
Message-ID: <20151202000828.92ECC60AC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67763a9bec03415996903a97916b234252fb150d
Commit:        67763a9bec03415996903a97916b234252fb150d
Parent:        5bbbd37f414bdbf31776d09af1c937635205ab2d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 1 11:01:26 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 11:01:26 2015 -0600

lvresize: use process_each_vg

No functional change.
---
 tools/lvresize.c |   63 +++++++++++++++++++++++++++++------------------------
 1 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 3188f27..da97205 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -163,51 +163,56 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	return 1;
 }
 
-int lvresize(struct cmd_context *cmd, int argc, char **argv)
+static int _lvresize_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg, struct processing_handle *handle)
 {
-	struct lvresize_params lp = { 0 };
-	struct volume_group *vg;
+	struct lvresize_params *lp = (struct lvresize_params *) handle->custom_handle;
 	struct dm_list *pvh = NULL;
 	struct logical_volume *lv;
-	uint32_t lockd_state = 0;
-	int r = ECMD_FAILED;
-
-	if (!_lvresize_params(cmd, argc, argv, &lp))
-		return EINVALID_CMD_LINE;
-
-	if (!lockd_vg(cmd, lp.vg_name, "ex", 0, &lockd_state))
-		return_ECMD_FAILED;
-
-	log_verbose("Finding volume group %s", lp.vg_name);
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		return_ECMD_FAILED;
-	}
+	int ret = ECMD_FAILED;
 
 	/* Does LV exist? */
-	if (!(lv = find_lv(vg, lp.lv_name))) {
+	if (!(lv = find_lv(vg, lp->lv_name))) {
 		log_error("Logical volume %s not found in volume group %s",
-			  lp.lv_name, lp.vg_name);
+			  lp->lv_name, lp->vg_name);
 		goto out;
 	}
 
-	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
-					     lp.argv, 1) : &vg->pvs))
+	if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc, lp->argv, 1) : &vg->pvs))
 		goto_out;
 
-	if (!lv_resize_prepare(cmd, lv, &lp, pvh)) {
-		r = EINVALID_CMD_LINE;
+	if (!lv_resize_prepare(cmd, lv, lp, pvh)) {
+		ret = EINVALID_CMD_LINE;
 		goto_out;
 	}
 
-	if (!lv_resize(cmd, lv, &lp, pvh))
+	if (!lv_resize(cmd, lv, lp, pvh))
 		goto_out;
 
-	r = ECMD_PROCESSED;
-
+	ret = ECMD_PROCESSED;
 out:
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
+	return ret;
+}
+
+int lvresize(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle = NULL;
+	struct lvresize_params lp = { 0 };
+	int ret = ECMD_FAILED;
+
+	if (!_lvresize_params(cmd, argc, argv, &lp))
+		return EINVALID_CMD_LINE;
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lp;
+
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, READ_FOR_UPDATE, handle,
+			      &_lvresize_single);
 
-	return r;
+	destroy_processing_handle(cmd, handle);
+	return ret;
 }


