From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Jan 2023 21:39:05 +0000 (GMT)
Subject: main - lvmlockd: fix report of lv_active_exclusively for special lv types
Message-ID: <20230110213905.7CE203858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c9c3ba5d59eef94c846e16d786e3ff4029516e5
Commit:        7c9c3ba5d59eef94c846e16d786e3ff4029516e5
Parent:        789904bd57442f783d50f7076c7f9ee188dbd33b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 10 15:23:16 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 10 15:37:15 2023 -0600

lvmlockd: fix report of lv_active_exclusively for special lv types

Cover a case missed by the recent commit e0ea0706d
"report: query lvmlockd for lv_active_exclusively"

Fix the lv_active_exclusively value reported for thin LVs.
It's the thin pool that is locked in lvmlockd, and the thin
LV state was mistakenly being queried and not found.

Certain LV types like thin can only be activated exclusively, so
always report lv_active_exclusively true for these when active.
---
 lib/locking/lvmlockd.c | 48 ++++++++++++++++++++++++++++++++++++------------
 lib/locking/lvmlockd.h |  6 ++----
 lib/report/report.c    | 13 ++++++-------
 3 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 051aa817c..614c95642 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2298,27 +2298,20 @@ int lockd_vg_update(struct volume_group *vg)
 	return ret;
 }
 
-int lockd_query_lv(struct volume_group *vg, const char *lv_name, char *lv_uuid,
-		   const char *lock_args, int *ex, int *sh)
+static int _query_lv(struct cmd_context *cmd, struct volume_group *vg,
+		     const char *lv_name, char *lv_uuid, const char *lock_args,
+		     int *ex, int *sh)
 {
 	daemon_reply reply;
-	const char *opts = NULL;
 	const char *reply_str;
 	int result;
 	int ret;
 
-	if (!vg_is_shared(vg))
-		return 1;
-	if (!_use_lvmlockd)
-		return 0;
-	if (!_lvmlockd_connected)
-		return 0;
-
 	log_debug("lockd query LV %s/%s", vg->name, lv_name);
 
 	reply = _lockd_send("query_lock_lv",
 				"pid = " FMTd64, (int64_t) getpid(),
-				"opts = %s", opts ?: "none",
+				"opts = %s", "none",
 				"vg_name = %s", vg->name,
 				"lv_name = %s", lv_name,
 				"lv_uuid = %s", lv_uuid,
@@ -2354,6 +2347,37 @@ int lockd_query_lv(struct volume_group *vg, const char *lv_name, char *lv_uuid,
 	return ret;
 }
 
+int lockd_query_lv(struct cmd_context *cmd, struct logical_volume *lv, int *ex, int *sh)
+{
+	struct volume_group *vg = lv->vg;
+	char lv_uuid[64] __attribute__((aligned(8)));
+
+	if (cmd->lockd_lv_disable)
+		return 1;
+	if (!vg_is_shared(vg))
+		return 1;
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	/* types that cannot be active concurrently will always be ex. */
+	if (lv_is_external_origin(lv) ||
+	    lv_is_thin_type(lv) ||
+	    lv_is_mirror_type(lv) ||
+	    lv_is_raid_type(lv) ||
+	    lv_is_vdo_type(lv) ||
+	    lv_is_cache_type(lv)) {
+		*ex = 1;
+		return 1;
+	}
+
+	if (!id_write_format(&lv->lvid.id[1], lv_uuid, sizeof(lv_uuid)))
+		return_0;
+
+	return _query_lv(cmd, vg, lv->name, lv_uuid, lv->lock_args, ex, sh);
+}
+
 /*
  * When this is called directly (as opposed to being called from
  * lockd_lv), the caller knows that the LV has a lock.
@@ -2392,7 +2416,7 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		    !strcmp(cmd->name, "lvchange") || !strcmp(cmd->name, "lvconvert")) {
 			int ex = 0, sh = 0;
 
-			if (!lockd_query_lv(vg, lv_name, lv_uuid, lock_args, &ex, &sh))
+			if (!_query_lv(cmd, vg, lv_name, lv_uuid, lock_args, &ex, &sh))
 				return 1;
 			if (sh) {
 				log_warn("WARNING: shared LV may require refresh on other hosts where it is active.");
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index fcaa0a326..8628fa093 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -103,8 +103,7 @@ int lockd_lv_uses_lock(struct logical_volume *lv);
 
 int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_params *lp);
 
-int lockd_query_lv(struct volume_group *vg, const char *lv_name, char *lv_uuid,
-		   const char *lock_args, int *ex, int *sh);
+int lockd_query_lv(struct cmd_context *cmd, struct logical_volume *lv, int *ex, int *sh);
 
 #else /* LVMLOCKD_SUPPORT */
 
@@ -261,8 +260,7 @@ static inline int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_para
 	return 0;
 }
 
-static inline int lockd_query_lv(struct volume_group *vg, const char *lv_name,
-		  char *lv_uuid, const char *lock_args, int *ex, int *sh)
+static inline int lockd_query_lv(struct cmd_context *cmd, struct logical_volume *lv, int *ex, int *sh);
 {
 	return 0;
 }
diff --git a/lib/report/report.c b/lib/report/report.c
index 26d35ba95..a15b7298a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3855,21 +3855,20 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
 				     const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	int active_exclusively, _sh = 0;
+	int ex = 0, sh = 0;
 
 	if (!activation())
 		return _binary_undef_disp(rh, mem, field, private);
 
-	active_exclusively = lv_is_active(lv);
+	ex = lv_is_active(lv);
 
-	if (active_exclusively && vg_is_shared(lv->vg)) {
-		active_exclusively = 0;
-		if (!lockd_query_lv(lv->vg, lv->name, lv_uuid_dup(NULL, lv),
-				    lv->lock_args, &active_exclusively, &_sh))
+	if (ex && vg_is_shared(lv->vg)) {
+		ex = 0;
+		if (!lockd_query_lv(lv->vg->cmd, (struct logical_volume *)lv, &ex, &sh))
 			return _binary_undef_disp(rh, mem, field, private);
 	}
 
-	return _binary_disp(rh, mem, field, active_exclusively, GET_FIRST_RESERVED_NAME(lv_active_exclusively_y), private);
+	return _binary_disp(rh, mem, field, ex, GET_FIRST_RESERVED_NAME(lv_active_exclusively_y), private);
 }
 
 static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,

