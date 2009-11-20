From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:50 -0500
Subject: [PATCH 10/15] lvm-merge-background-poll
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-11-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Background poll for lvconvert --merge command.
The merging snapshot is removed when the merge finishes.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/lvconvert.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 69 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 49b22a7..7447007 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -41,6 +41,8 @@ struct lvconvert_params {
 	int pv_count;
 	char **pvs;
 	struct dm_list *pvh;
+
+	struct logical_volume *lv_to_poll;
 };
 
 static int _lvconvert_name_params(struct lvconvert_params *lp,
@@ -329,6 +331,54 @@ out:
 	return r;
 }
 
+static int _finish_lvconvert_merge(struct cmd_context *cmd,
+				   struct volume_group *vg,
+				   struct logical_volume *lv,
+				   struct dm_list *lvs_changed __attribute((unused)))
+{
+	struct lv_segment *snap_seg = lv->merging_snapshot;
+	if (!snap_seg) {
+		log_error("Logical volume %s has no merging snapshot.", lv->name);
+		return 0;
+	}
+
+	log_print("Merge into logical volume %s finished.", lv->name);
+	if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT)) {
+		log_error("Could not remove snapshot %s merged into %s.",
+			  snap_seg->cow->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static progress_t _poll_merge_progress(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       const char *name __attribute((unused)),
+				       struct daemon_parms *parms)
+{
+	float percent = 0.0;
+	percent_range_t percent_range;
+
+	if (!lv_snapshot_percent(lv, &percent, &percent_range)) {
+		log_error("%s: Failed query for merging percentage", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	} else if (percent_range == PERCENT_INVALID) {
+		log_error("%s: Merging snapshot invalidated, aborting merge", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	if (parms->progress_display)
+		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
+	else
+		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
+
+	if (percent_range == PERCENT_0)
+		return PROGRESS_FINISHED_ALL;
+
+	return PROGRESS_UNFINISHED;
+}
+
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
@@ -337,6 +387,13 @@ static struct poll_functions _lvconvert_mirror_fns = {
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
+static struct poll_functions _lvconvert_merge_fns = {
+	.get_copy_vg = _get_lvconvert_vg,
+	.get_copy_lv = _get_lvconvert_lv,
+	.poll_progress = _poll_merge_progress,
+	.finish_copy = _finish_lvconvert_merge,
+};
+
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
@@ -353,8 +410,12 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
 
-	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-			   &_lvconvert_mirror_fns, "Converted");
+	if (!lv->merging_snapshot)
+		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+				   &_lvconvert_mirror_fns, "Converted");
+	else
+		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+				   &_lvconvert_merge_fns, "Merged");
 }
 
 static int _insert_lvconvert_layer(struct cmd_context *cmd,
@@ -987,6 +1048,9 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		/* merge is running regardless of this deactivation failure */
 	}
 
+	lp->need_polling = 1;
+	lp->lv_to_poll = origin;
+
 	r = 1;
 	log_print("Merging of volume %s started.", lv->name);
 out:
@@ -1099,17 +1163,18 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	} else
 		lp.pvh = &vg->pvs;
 
+	lp.lv_to_poll = lvl->lv;
 	ret = lvconvert_single(cmd, lvl->lv, &lp);
 
 bad:
 	unlock_vg(cmd, lp.vg_name);
 
 	if (ret == ECMD_PROCESSED && lp.need_polling) {
-		if (!lv_info(cmd, lvl->lv, &info, 1, 0) || !info.exists) {
+		if (!lv_info(cmd, lp.lv_to_poll, &info, 1, 0) || !info.exists) {
 			log_print("Conversion starts after activation");
 			goto out;
 		}
-		ret = lvconvert_poll(cmd, lvl->lv,
+		ret = lvconvert_poll(cmd, lp.lv_to_poll,
 				     lp.wait_completion ? 0 : 1U);
 	}
 out:
-- 
1.6.5.2


