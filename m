From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:32:41 +0200
Subject: [PATCH 3/6] vg mempool: fix activation code
Message-ID: <49D9BE29.8030002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Properly release VG memory pool in activation code and clvmd.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    1 +
 lib/activate/activate.c       |  120 +++++++++++++++++++++++++++--------------
 2 files changed, 80 insertions(+), 41 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 4fc8613..6509bc2 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -724,6 +724,7 @@ void lvm_do_backup(const char *vgname)
 	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
 
+	vg_release(vg);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 863f471..7011a09 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -843,36 +843,39 @@ int monitor_dev_for_events(struct cmd_context *cmd,
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       int error_if_not_suspended)
 {
-	struct logical_volume *lv, *lv_pre;
+	struct logical_volume *lv = NULL, *lv_pre = NULL;
 	struct lvinfo info;
-	int lockfs = 0;
+	int r = 0, lockfs = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return_0;
+		goto_out;
 
 	/* Use precommitted metadata if present */
 	if (!(lv_pre = lv_from_lvid(cmd, lvid_s, 1)))
-		return_0;
+		goto_out;
 
 	if (test_mode()) {
 		_skip("Suspending '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 0, 0))
-		return_0;
+		goto_out;
 
-	if (!info.exists || info.suspended)
-		return error_if_not_suspended ? 0 : 1;
+	if (!info.exists || info.suspended) {
+		r = error_if_not_suspended ? 0 : 1;
+		goto out;
+	}
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
 		if (!_lv_preload(lv_pre)) {
 			/* FIXME Revert preloading */
-			return_0;
+			goto_out;
 		}
 	}
 
@@ -888,10 +891,17 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!_lv_suspend_lv(lv, lockfs)) {
 		memlock_dec();
 		fs_unlock();
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	r = 1;
+out:
+	if (lv_pre)
+		vg_release(lv_pre->vg);
+	if (lv)
+		vg_release(lv->vg);
+
+	return r;
 }
 
 /* Returns success if the device is not active */
@@ -910,26 +920,30 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
+	int r = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (test_mode()) {
 		_skip("Resuming '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 0, 0))
-		return_0;
+		goto_out;
 
-	if (!info.exists || !info.suspended)
-		return error_if_not_active ? 0 : 1;
+	if (!info.exists || !info.suspended) {
+		r = error_if_not_active ? 0 : 1;
+		goto out;
+	}
 
 	if (!_lv_activate_lv(lv))
-		return 0;
+		goto out;
 
 	memlock_dec();
 	fs_unlock();
@@ -937,7 +951,12 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
-	return 1;
+	r = 1;
+out:
+	if (lv)
+		vg_release(lv->vg);
+
+	return r;
 }
 
 /* Returns success if the device is not active */
@@ -955,29 +974,32 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
-	int r;
+	int r = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (test_mode()) {
 		_skip("Deactivating '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 1, 0))
-		return_0;
+		goto_out;
 
-	if (!info.exists)
-		return 1;
+	if (!info.exists) {
+		r = 1;
+		goto out;
+	}
 
 	if (info.open_count && (lv->status & VISIBLE_LV)) {
 		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
 			  lv->name);
-		return 0;
+		goto out;
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, 0))
@@ -988,6 +1010,10 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	memlock_dec();
 	fs_unlock();
 
+out:
+	if (lv)
+		vg_release(lv->vg);
+
 	return r;
 }
 
@@ -996,23 +1022,28 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 			 int *activate_lv)
 {
 	struct logical_volume *lv;
+	int r = 0;
 
-	if (!activation())
-		goto activate;
+	if (!activation()) {
+		*activate_lv = 1;
+		return 1;
+	}
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (!_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s/%s due to config file settings",
 			    lv->vg->name, lv->name);
 		*activate_lv = 0;
-		return 1;
-	}
+	} else
+		*activate_lv = 1;
+	r = 1;
+out:
+	if (lv)
+		vg_release(lv->vg);
 
-      activate:
-	*activate_lv = 1;
-	return 1;
+	return r;
 }
 
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
@@ -1020,36 +1051,39 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
-	int r;
+	int r = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s/%s due to config file settings",
 			    lv->vg->name, lv->name);
-		return 0;
+		goto out;
 	}
 
 	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
 		log_error("Refusing activation of partial LV %s. Use --partial to override.",
 			  lv->name);
-		return_0;
+		goto_out;
 	}
 
 	if (test_mode()) {
 		_skip("Activating '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 0, 0))
-		return_0;
+		goto_out;
 
-	if (info.exists && !info.suspended && info.live_table)
-		return 1;
+	if (info.exists && !info.suspended && info.live_table) {
+		r = 1;
+		goto out;
+	}
 
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
@@ -1062,6 +1096,10 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (r && !monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
+out:
+	if (lv)
+		vg_release(lv->vg);
+
 	return r;
 }
 



