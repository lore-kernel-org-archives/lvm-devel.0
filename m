From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 16:16:03 -0400
Subject: stable-2.02 - lvmlockd: do not allow mirror LV to be activated shared
Message-ID: <201905212016.x4LKG3MD013841@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3669c33af4279c93c8a9104de9501ba9cf6a2745
Commit:        3669c33af4279c93c8a9104de9501ba9cf6a2745
Parent:        e2ae1f2d715d64c508d8f978a62d37a95c5d682d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 15:06:37 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 15:06:37 2019 -0500

lvmlockd: do not allow mirror LV to be activated shared

This reverts 518a8e8cfbb672c2bf5e3455f1fe7cd8d94eb5b0
  "lvmlockd: activate mirror LVs in shared mode with cmirrord"

because while activating a mirror LV with cmirrord worked,
changes to the active cmirror did not work.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.h |    1 -
 lib/locking/lvmlockd.c     |   38 +-------------------------------------
 lib/metadata/mirror.c      |   12 ------------
 lib/mirror/mirrored.c      |    9 ---------
 man/lvmlockd.8_main        |    2 +-
 6 files changed, 3 insertions(+), 60 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1b68e47..106661f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.186 - 
 ================================
+  Prevent shared active mirror LVs with lvmlockd.
 
 Version 2.02.185 - 13th May 2019
 ================================
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index da5d582..485dca9 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -163,7 +163,6 @@ struct cmd_context {
 	unsigned lockd_vg_rescan:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
-	unsigned lockd_lv_sh:1;
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 788b62b..1160126 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2076,15 +2076,6 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	/*
-	 * This is a hack for mirror LVs which need to know at a very low level
-	 * which lock mode the LV is being activated with so that it can pick
-	 * a mirror log type during activation.  Do not use this for anything
-	 * else.
-	 */
-	if (mode && !strcmp(mode, "sh"))
-		cmd->lockd_lv_sh = 1;
-
 	if (!mode)
 		mode = "ex";
 
@@ -2209,31 +2200,6 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 /*
- * Only the combination of dlm + corosync + cmirrord allows
- * mirror LVs to be activated in shared mode on multiple nodes.
- */
-static int _lockd_lv_mirror(struct cmd_context *cmd, struct logical_volume *lv,
-			    const char *def_mode, uint32_t flags)
-{
-	if (!strcmp(lv->vg->lock_type, "sanlock"))
-		flags |= LDLV_MODE_NO_SH;
-
-	else if (!strcmp(lv->vg->lock_type, "dlm") && def_mode && !strcmp(def_mode, "sh")) {
-#ifdef CMIRRORD_PIDFILE
-		if (!cmirrord_is_running()) {
-			log_error("cmirrord must be running to activate an LV in shared mode.");
-			return 0;
-		}
-#else
-		flags |= LDLV_MODE_NO_SH;
-#endif
-	}
-
-	return lockd_lv_name(cmd, lv->vg, lv->name, &lv->lvid.id[1],
-			     lv->lock_args, def_mode, flags);
-}
-
-/*
  * If the VG has no lock_type, then this function can return immediately.
  * The LV itself may have no lock (NULL lv->lock_args), but the lock request
  * may be directed to another lock, e.g. the pool LV lock in _lockd_lv_thin.
@@ -2286,14 +2252,12 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (lv_is_external_origin(lv) ||
 	    lv_is_thin_type(lv) ||
+	    lv_is_mirror_type(lv) ||
 	    lv_is_raid_type(lv) ||
 	    lv_is_cache_type(lv)) {
 		flags |= LDLV_MODE_NO_SH;
 	}
 
-	if (lv_is_mirror_type(lv))
-		return _lockd_lv_mirror(cmd, lv, def_mode, flags);
-	       
 	return lockd_lv_name(cmd, lv->vg, lv->name, &lv->lvid.id[1],
 			     lv->lock_args, def_mode, flags);
 }
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index b1dcaa0..cd8ce1e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2104,18 +2104,6 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm") && cmd->lockd_lv_sh) {
-		if (!cluster_mirror_is_available(cmd)) {
-			log_error("Shared cluster mirrors are not available.");
-			return 0;
-		}
-
-		if (log_count > 1) {
-			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
-			return 0;
-		}
-	}
-
 	/* For corelog mirror, activation code depends on
 	 * the global mirror_in_sync status. As we are adding
 	 * a new mirror, it should be set as 'out-of-sync'
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 7c5c0a6..606bcf0 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -285,15 +285,6 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	if (!laopts->exclusive && vg_is_clustered(seg->lv->vg))
 		clustered = 1;
 
-	else if (seg->lv->vg->lock_type && !strcmp(seg->lv->vg->lock_type, "dlm")) {
-		/*
-		 * If shared lock was used due to -asy, then we set clustered
-		 * to use a clustered mirror log with cmirrod.
-		 */
-		if (seg->lv->vg->cmd->lockd_lv_sh)
-			clustered = 1;
-	}
-
 	if (seg->log_lv) {
 		/* If disk log, use its UUID */
 		if (!(log_dlid = build_dm_uuid(mem, seg->log_lv, NULL))) {
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index cfb45b2..3f0e3ed 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -545,7 +545,7 @@ report an error and fail.
 The shared mode is intended for a multi-host/cluster application or
 file system.
 LV types that cannot be used concurrently
-from multiple hosts include thin, cache, raid, and snapshot.
+from multiple hosts include thin, cache, raid, mirror, and snapshot.
 
 .IP \fBn\fP
 The command deactivates the LV.  After deactivating the LV, the command


