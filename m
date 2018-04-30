From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Apr 2018 04:42:59 -0400
Subject: master - mirror: improve table update
Message-ID: <201804300842.w3U8gxHO017313@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fade45b1d14c90eac7c6cc41019ef946659a8fb5
Commit:        fade45b1d14c90eac7c6cc41019ef946659a8fb5
Parent:        dd7ac793a02553c9c7a14b9715d5a6ad636aa065
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 28 22:14:47 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 30 10:41:51 2018 +0200

mirror: improve table update

Shift refresh of mirror table right into monitor_dev_for_events().
Use  !vg_write_lock_held() to recognize use of lvchange/vgchange.
(this shall change if this would no longer work, but requires
futher some API changes).

With this patch  dm mirror table is only refreshed when necassary.

Also update WARNING message about mirror usage without monitoring
and display LV name.
---
 lib/activate/activate.c |   14 ++++++++++++++
 lib/mirror/mirrored.c   |   11 ++++++-----
 tools/lvchange.c        |    4 ----
 3 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7a2a945..a7113f1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1857,6 +1857,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
 	static const struct lv_activate_opts zlaopts = { 0 };
+	struct lv_activate_opts mirr_laopts = { .origin_only = 1 };
 	struct lvinfo info;
 	const char *dso = NULL;
 	int new_unmonitor;
@@ -2057,6 +2058,19 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		} else
 			continue;
 
+		if (!vg_write_lock_held() && lv_is_mirror(lv)) {
+			mirr_laopts.exclusive = lv_is_active_exclusive_locally(lv) ? 1 : 0;
+			/*
+			 * Commands vgchange and lvchange do use read-only lock when changing
+			 * monitoring (--monitor y|n). All other use cases hold 'write-lock'
+			 * so they skip this dm mirror table refreshing step.
+			 */
+			if (!_lv_activate_lv(lv, &mirr_laopts)) {
+				stack;
+				r = 0;
+			}
+		}
+
 		/* Check [un]monitor results */
 		/* Try a couple times if pending, but not forever... */
 		for (i = 0;; i++) {
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 10828e8..7c5c0a6 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -315,12 +315,13 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 		log_flags |= DM_NOSYNC;
 
 	if (_block_on_error_available && !(seg->status & PVMOVE)) {
-		if (dmeventd_monitor_mode() > 0)
+		if (dmeventd_monitor_mode() == 0) {
+			log_warn_suppress(seg->lv->vg->cmd->mirror_warn_printed,
+					  "WARNING: Mirror %s without monitoring will not react on failures.",
+					  display_lvname(seg->lv));
+			seg->lv->vg->cmd->mirror_warn_printed = 1; /* Do not print this more then once */
+		} else
 			log_flags |= DM_BLOCK_ON_ERROR;
-		else {
-			log_warn_suppress(seg->lv->vg->cmd->mirror_warn_printed, "WARNING: Mirrors without monitoring will not react on failures.");
-			seg->lv->vg->cmd->mirror_warn_printed = 1;
-		}
 	}
 
 	return dm_tree_node_add_mirror_target_log(node, region_size, clustered, log_dlid, area_count, log_flags);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e1be4cb..0aac5ac 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1603,10 +1603,6 @@ static int _lvchange_monitor_poll_single(struct cmd_context *cmd,
 				         struct logical_volume *lv,
 				         struct processing_handle *handle)
 {
-	/* Mirror is using different table line when un/monitored */
-	if (lv_is_mirror(lv) && !lv_refresh(cmd, lv))
-		return_ECMD_FAILED;
-
 	if (arg_is_set(cmd, monitor_ARG) &&
 	    !_lvchange_monitoring(cmd, lv))
 		return_ECMD_FAILED;


