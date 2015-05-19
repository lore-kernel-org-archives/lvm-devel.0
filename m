From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:03:06 +0000 (UTC)
Subject: master - lvconvert.c: drop get_vg_lock_and_logical_volume fn
Message-ID: <20150519190306.2105660FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf5b4a228612981ec5de358adad670014e885e4c
Commit:        cf5b4a228612981ec5de358adad670014e885e4c
Parent:        f400f9db19324a29aeff6ad92039db91adc1e8f9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 16:46:11 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:56:32 2015 +0200

lvconvert.c: drop get_vg_lock_and_logical_volume fn

---
 tools/lvconvert.c |   81 +++++++++++++++++++++-------------------------------
 1 files changed, 33 insertions(+), 48 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9192d04..6e47f81 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3231,37 +3231,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	return ECMD_PROCESSED;
 }
 
-/*
- * FIXME move to toollib along with the rest of the drop/reacquire
- * VG locking that is used by _lvconvert_merge_single()
- */
-static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context *cmd,
-							     const char *vg_name,
-							     const char *lv_name)
-{
-	/*
-	 * Returns NULL if the requested LV doesn't exist;
-	 * otherwise the caller must release_vg(lv->vg)
-	 * - it is also up to the caller to unlock_vg() as needed
-	 */
-	struct volume_group *vg;
-	struct logical_volume* lv = NULL;
-
-	vg = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		return_NULL;
-	}
-
-	if (!(lv = find_lv(vg, lv_name))) {
-		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return NULL;
-	}
-
-	return lv;
-}
-
 static int _poll_logical_volume(struct cmd_context *cmd, struct logical_volume *lv,
 			       int wait_completion)
 {
@@ -3278,6 +3247,7 @@ static int _poll_logical_volume(struct cmd_context *cmd, struct logical_volume *
 static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
 {
 	struct logical_volume *lv;
+	struct volume_group *vg;
 	int ret = ECMD_FAILED;
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
@@ -3286,21 +3256,29 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 		cmd->handles_missing_pvs = 1;
 	}
 
-	if (!(lv = get_vg_lock_and_logical_volume(cmd, lp->vg_name, lp->lv_name)))
+	vg = vg_read(cmd, lp->vg_name, NULL, READ_FOR_UPDATE);
+	if (vg_read_error(vg)) {
+		release_vg(vg);
 		goto_out;
+	}
+
+	if (!(lv = find_lv(vg, lp->lv_name))) {
+		log_error("Can't find LV %s in VG %s", lp->lv_name, lp->vg_name);
+		unlock_and_release_vg(cmd, vg, lp->vg_name);
+		goto_out;
+	}
 
 	/*
 	 * lp->pvh holds the list of PVs available for allocation or removal
 	 */
 	if (lp->pv_count) {
-		if (!(lp->pvh = create_pv_list(cmd->mem, lv->vg, lp->pv_count,
-					      lp->pvs, 0)))
+		if (!(lp->pvh = create_pv_list(cmd->mem, vg, lp->pv_count, lp->pvs, 0)))
 			goto_bad;
 	} else
-		lp->pvh = &lv->vg->pvs;
+		lp->pvh = &vg->pvs;
 
 	if (lp->replace_pv_count &&
-	    !(lp->replace_pvh = create_pv_list(cmd->mem, lv->vg,
+	    !(lp->replace_pvh = create_pv_list(cmd->mem, vg,
 					       lp->replace_pv_count,
 					       lp->replace_pvs, 0)))
 			goto_bad;
@@ -3314,7 +3292,7 @@ bad:
 		ret = _poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
 
-	release_vg(lv->vg);
+	release_vg(vg);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	return ret;
@@ -3325,8 +3303,9 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 {
 	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
 	const char *vg_name;
-	struct logical_volume *refreshed_lv;
-	int ret;
+	struct volume_group *vg_fresh;
+	struct logical_volume *lv_fresh;
+	int ret = ECMD_FAILED;
 
 	/*
 	 * FIXME can't trust lv's VG to be current given that caller
@@ -3335,16 +3314,23 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 	 * - preemptively drop the VG lock, as is needed for
 	 *   _poll_logical_volume(), refresh LV (and VG in the process).
 	 */
+
 	vg_name = lv->vg->name;
 	unlock_vg(cmd, vg_name);
-	refreshed_lv = get_vg_lock_and_logical_volume(cmd, vg_name, lv->name);
-	if (!refreshed_lv) {
-		log_error("ABORTING: Can't reread LV %s/%s", vg_name, lv->name);
-		return ECMD_FAILED;
+	vg_fresh = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE);
+	if (vg_read_error(vg_fresh)) {
+		log_error("ABORTING: Can't reread VG %s", vg_name);
+		goto out;
+	}
+
+	if (!(lv_fresh = find_lv(vg_fresh, lv->name))) {
+		log_error("ABORTING: Can't find LV %s in VG %s", lv->name, vg_name);
+		unlock_vg(cmd, vg_name);
+		goto out;
 	}
 
-	lp->lv_to_poll = refreshed_lv;
-	if ((ret = _lvconvert_single(cmd, refreshed_lv, lp)) != ECMD_PROCESSED)
+	lp->lv_to_poll = lv_fresh;
+	if ((ret = _lvconvert_single(cmd, lv_fresh, lp)) != ECMD_PROCESSED)
 		stack;
 
 	if (ret == ECMD_PROCESSED && lp->need_polling) {
@@ -3365,9 +3351,8 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 			ret = ECMD_FAILED;
 		}
 	}
-
-	release_vg(refreshed_lv->vg);
-
+out:
+	release_vg(vg_fresh);
 	return ret;
 }
 


