From: David Teigland <teigland@sourceware.org>
Date: Thu, 4 Apr 2019 14:35:17 -0400
Subject: master - lvmlockd: do not allow mirror LV to be activated shared
Message-ID: <201904041835.x34IZHW7019201@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c33770c02d9d6b9deddbc1b3c52c77c1a17ea246
Commit:        c33770c02d9d6b9deddbc1b3c52c77c1a17ea246
Parent:        50800e33d56176e034970f93c5f87f59ecd569db
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 22 12:07:31 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 4 13:21:38 2019 -0500

lvmlockd: do not allow mirror LV to be activated shared

This reverts 518a8e8cfbb672c2bf5e3455f1fe7cd8d94eb5b0
  "lvmlockd: activate mirror LVs in shared mode with cmirrord"

because while activating a mirror LV with cmirrord worked,
changes to the active cmirror did not work.
---
 lib/commands/toolcontext.h |    1 -
 lib/locking/lvmlockd.c     |   38 +-------------------------------------
 lib/metadata/mirror.c      |   12 ------------
 lib/mirror/mirrored.c      |    9 ---------
 man/lvmlockd.8_main        |    2 +-
 5 files changed, 2 insertions(+), 60 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2ce243e..fea0e51 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -159,7 +159,6 @@ struct cmd_context {
 	unsigned lockd_gl_removed:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
-	unsigned lockd_lv_sh:1;
 	unsigned lockd_lv_sh_for_ex:1;
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 60e0617..1e3553d 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2160,15 +2160,6 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
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
 
@@ -2302,31 +2293,6 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
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
@@ -2379,14 +2345,12 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
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
index 6950546..8459457 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2056,18 +2056,6 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
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
index 7fa8714..aaaa0b8 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -278,15 +278,6 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	char *log_dlid = NULL;
 	uint32_t log_flags = 0;
 
-	if (seg->lv->vg->lock_type && !strcmp(seg->lv->vg->lock_type, "dlm")) {
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
index 50b3473..0feab80 100644
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


