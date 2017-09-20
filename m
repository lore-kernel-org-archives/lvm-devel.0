From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Sep 2017 10:58:42 -0400
Subject: master - lvmlockd: activate mirror LVs in shared mode with cmirrord
Message-ID: <201709201458.v8KEwgcf027732@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=518a8e8cfbb672c2bf5e3455f1fe7cd8d94eb5b0
Commit:        518a8e8cfbb672c2bf5e3455f1fe7cd8d94eb5b0
Parent:        d9f9ce126856245541a66492f35422ab060a837e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 19 11:52:36 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 20 09:55:34 2017 -0500

lvmlockd: activate mirror LVs in shared mode with cmirrord

Previously lvmlockd disallowed mirror LVs to be activated
in shared mode.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.h |    1 +
 lib/locking/lvmlockd.c     |   38 +++++++++++++++++++++++++++++++++++++-
 lib/metadata/mirror.c      |   12 ++++++++++++
 lib/mirror/mirrored.c      |    9 +++++++++
 man/lvmlockd.8_main        |    6 ++++--
 6 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7927673..6d820bd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.175 - 
 ======================================
+  Allow shared active mirror LVs with lvmlockd, dlm, and cmirrord.
   Support lvconvert --repair with cache and cachepool volumes.
   lvconvert --repair respects --poolmetadataspare option.
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 20b24f9..bf2b251 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -160,6 +160,7 @@ struct cmd_context {
 	unsigned lockd_vg_rescan:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
+	unsigned lockd_lv_sh:1;
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 058d4b5..0f2b160 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2042,6 +2042,15 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	/*
+	 * This is a hack for mirror LVs which need to know at a very low level
+	 * which lock mode the LV is being activated with so that it can pick
+	 * a mirror log type during activation.  Do not use this for anything
+	 * else.
+	 */
+	if (mode && !strcmp(mode, "sh"))
+		cmd->lockd_lv_sh = 1;
+
 	if (!mode)
 		mode = "ex";
 
@@ -2160,6 +2169,31 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 /*
+ * Only the combination of dlm + corosync + cmirrord allows
+ * mirror LVs to be activated in shared mode on multiple nodes.
+ */
+static int _lockd_lv_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			    const char *def_mode, uint32_t flags)
+{
+	if (!strcmp(lv->vg->lock_type, "sanlock"))
+		flags |= LDLV_MODE_NO_SH;
+
+	else if (!strcmp(lv->vg->lock_type, "dlm") && def_mode && !strcmp(def_mode, "sh")) {
+#ifdef CMIRRORD_PIDFILE
+		if (!cmirrord_is_running()) {
+			log_error("cmirrord must be running to activate an LV in shared mode.");
+			return 0;
+		}
+#else
+		flags |= LDLV_MODE_NO_SH;
+#endif
+	}
+
+	return lockd_lv_name(cmd, lv->vg, lv->name, &lv->lvid.id[1],
+			     lv->lock_args, def_mode, flags);
+}
+
+/*
  * If the VG has no lock_type, then this function can return immediately.
  * The LV itself may have no lock (NULL lv->lock_args), but the lock request
  * may be directed to another lock, e.g. the pool LV lock in _lockd_lv_thin.
@@ -2212,12 +2246,14 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (lv_is_external_origin(lv) ||
 	    lv_is_thin_type(lv) ||
-	    lv_is_mirror_type(lv) ||
 	    lv_is_raid_type(lv) ||
 	    lv_is_cache_type(lv)) {
 		flags |= LDLV_MODE_NO_SH;
 	}
 
+	if (lv_is_mirror_type(lv))
+		return _lockd_lv_mirror(cmd, lv, def_mode, flags);
+	       
 	return lockd_lv_name(cmd, lv->vg, lv->name, &lv->lvid.id[1],
 			     lv->lock_args, def_mode, flags);
 }
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 7496ddc..e775495 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2145,6 +2145,18 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm")) {
+		if (!cluster_mirror_is_available(cmd)) {
+			log_error("Shared cluster mirrors are not available.");
+			return 0;
+		}
+
+		if (log_count > 1) {
+			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
+			return 0;
+		}
+	}
+
 	/* For corelog mirror, activation code depends on
 	 * the global mirror_in_sync status. As we are adding
 	 * a new mirror, it should be set as 'out-of-sync'
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index f4c1567..4891fb7 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -285,6 +285,15 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	if (!laopts->exclusive && vg_is_clustered(seg->lv->vg))
 		clustered = 1;
 
+	else if (seg->lv->vg->lock_type && !strcmp(seg->lv->vg->lock_type, "dlm")) {
+		/*
+		 * If shared lock was used due to -asy, then we set clustered
+		 * to use a clustered mirror log with cmirrod.
+		 */
+		if (seg->lv->vg->cmd->lockd_lv_sh)
+			clustered = 1;
+	}
+
 	if (seg->log_lv) {
 		/* If disk log, use its UUID */
 		if (!(log_dlid = build_dm_uuid(mem, seg->log_lv, NULL))) {
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 1dbdaf9..067c60d 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -601,9 +601,11 @@ report an error and fail.
 The shared mode is intended for a multi-host/cluster application or
 file system.
 LV types that cannot be used concurrently
-from multiple hosts include thin, cache, raid, mirror, and snapshot.
+from multiple hosts include thin, cache, raid, and snapshot.
 lvextend on LV with shared locks is not yet allowed.  The LV must be
-deactivated, or activated exclusively to run lvextend.
+deactivated, or activated exclusively to run lvextend.  (LVs with
+the mirror type can be activated in shared mode from multiple hosts
+when using the dlm lock type and cmirrord.)
 
 .IP \fBn\fP
 The command deactivates the LV.  After deactivating the LV, the command


