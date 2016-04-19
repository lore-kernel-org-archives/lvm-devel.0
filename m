From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 19:02:18 +0000 (UTC)
Subject: master - lvmetad: rework command connection setup and checking
Message-ID: <20160419190218.519E760C92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e9e43074a6c5e251ee44768421879b03ad2e530
Commit:        5e9e43074a6c5e251ee44768421879b03ad2e530
Parent:        593900b795e194608e9e2088aa8f75f4f42484c1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 13 17:00:01 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 14:00:02 2016 -0500

lvmetad: rework command connection setup and checking

The lvmetad connection is created within the
init_connections() path during command startup,
rather than via the old lvmetad_active() check.

The old lvmetad_active() checks are replaced
with lvmetad_used() which is a simple check that
tests if the command is using/connected to lvmetad.

The old lvmetad_set_active(cmd, 0) calls, which
stopped the command from using lvmetad (to revert to
disk scanning), are replaced with lvmetad_make_unused(cmd).
---
 lib/cache/lvmcache.c          |   14 ++--
 lib/cache/lvmetad.c           |  122 ++++++++++++++++++-----------------------
 lib/cache/lvmetad.h           |   53 ++++-------------
 lib/commands/toolcontext.c    |   46 +++++++++++++--
 lib/format_text/archiver.c    |    2 +-
 lib/format_text/format-text.c |    2 +-
 lib/format_text/import_vsn1.c |    6 +-
 lib/metadata/metadata.c       |    6 +-
 tools/lvchange.c              |   23 +------
 tools/lvmcmdline.c            |   14 ++---
 tools/lvscan.c                |    4 +-
 tools/pvdisplay.c             |    2 +-
 tools/pvscan.c                |    4 +-
 tools/reporter.c              |    2 +-
 tools/vgchange.c              |   21 +------
 tools/vgck.c                  |    2 +-
 tools/vgimport.c              |    4 +-
 tools/vgscan.c                |    4 +-
 18 files changed, 144 insertions(+), 187 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3432ef6..e2c86c4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -164,7 +164,7 @@ void lvmcache_set_preferred_duplicates(const char *vgid)
 
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 {
-	if (!lvmetad_active() || _has_scanned)
+	if (!lvmetad_used() || _has_scanned)
 		return;
 
 	if (!lvmetad_pv_list_to_lvmcache(cmd)) {
@@ -542,7 +542,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
-		if (!lvmetad_active())
+		if (!lvmetad_used())
 			return NULL; /* too bad */
 		/* If we don't have the info but we have lvmetad, we can ask
 		 * there before failing. */
@@ -784,7 +784,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	int r = 0;
 
-	if (lvmetad_active())
+	if (lvmetad_used())
 		return 1;
 
 	/* Avoid recursion when a PVID can't be found! */
@@ -862,7 +862,7 @@ struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname
 	 * using the classic scanning mechanics, and read from disk or from
 	 * lvmcache.
 	 */
-	if (lvmetad_active() && !precommitted) {
+	if (lvmetad_used() && !precommitted) {
 		/* Still serve the locally cached VG if available */
 		if (vgid && (vginfo = lvmcache_vginfo_from_vgid(vgid)) &&
 		    vginfo->vgmetadata && (vg = vginfo->cached_vg))
@@ -1082,7 +1082,7 @@ static struct device *_device_from_pvid(const struct id *pvid,
 	struct label *label;
 
 	if ((info = lvmcache_info_from_pvid((const char *) pvid, 0))) {
-		if (lvmetad_active()) {
+		if (lvmetad_used()) {
 			if (info->label && label_sector)
 				*label_sector = info->label->sector;
 			return info->dev;
@@ -2397,7 +2397,7 @@ int lvmcache_is_orphan(struct lvmcache_info *info) {
 int lvmcache_vgid_is_cached(const char *vgid) {
 	struct lvmcache_vginfo *vginfo;
 
-	if (lvmetad_active())
+	if (lvmetad_used())
 		return 1;
 
 	vginfo = lvmcache_vginfo_from_vgid(vgid);
@@ -2497,7 +2497,7 @@ int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const ch
 	struct lvmcache_vginfo *vginfo;
 	int ret = 0;
 
-	if (lvmetad_active())
+	if (lvmetad_used())
 		return lvmetad_vg_is_foreign(cmd, vgname, vgid);
 
 	if ((vginfo = lvmcache_vginfo_from_vgid(vgid)))
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 858be4d..bbf3550 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -120,50 +120,36 @@ void lvmetad_disconnect(void)
 		daemon_close(_lvmetad);
 
 	_lvmetad_connected = 0;
+	_lvmetad_use = 0;
+	_lvmetad_cmd = NULL;
 }
 
-void lvmetad_init(struct cmd_context *cmd)
+int lvmetad_connect(struct cmd_context *cmd)
 {
-	if (!_lvmetad_use && !access(getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE, F_OK))
-		log_warn("WARNING: lvmetad is running but disabled."
-			 " Restart lvmetad before enabling it!");
-
-	if (_lvmetad_connected)
-		log_debug(INTERNAL_ERROR "Refreshing lvmetad global handle while connection with the daemon is active");
-
-	_lvmetad_cmd = cmd;
-}
-
-static void _lvmetad_connect(void)
-{
-	if (!_lvmetad_use || !_lvmetad_socket || _lvmetad_connected)
-		return;
+	if (access(getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE, F_OK)) {
+		log_debug_lvmetad("Failed to connect to lvmetad: not running.");
+		_lvmetad_connected = 0;
+		_lvmetad_use = 0;
+		_lvmetad_cmd = NULL;
+		return 0;
+	}
 
 	_lvmetad = lvmetad_open(_lvmetad_socket);
+
 	if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
 		log_debug_lvmetad("Successfully connected to lvmetad on fd %d.",
 				  _lvmetad.socket_fd);
 		_lvmetad_connected = 1;
-	}
-
-	if (!_lvmetad_connected)
+		_lvmetad_use = 1;
+		_lvmetad_cmd = cmd;
+		return 1;
+	} else {
+		log_debug_lvmetad("Failed to connect to lvmetad: %s", strerror(_lvmetad.error));
+		_lvmetad_connected = 0;
 		_lvmetad_use = 0;
-}
-
-void lvmetad_connect_or_warn(void)
-{
-	if (!_lvmetad_use)
-		return;
-
-	if (!_lvmetad_connected && !_lvmetad.error) {
-		_lvmetad_connect();
-
-		if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
-			log_warn("WARNING: Failed to connect to lvmetad. Falling back to internal scanning.");
+		_lvmetad_cmd = NULL;
+		return 0;
 	}
-
-	if (!_lvmetad_connected)
-		_lvmetad_use = 0;
 }
 
 int lvmetad_used(void)
@@ -171,6 +157,14 @@ int lvmetad_used(void)
 	return _lvmetad_use;
 }
 
+void lvmetad_make_unused(struct cmd_context *cmd)
+{
+	lvmetad_disconnect();
+
+	if (cmd && !refresh_filters(cmd))
+		stack;
+}
+
 int lvmetad_socket_present(void)
 {
 	const char *socket = _lvmetad_socket ?: LVMETAD_SOCKET;
@@ -182,22 +176,9 @@ int lvmetad_socket_present(void)
 	return !r;
 }
 
-int lvmetad_active(void)
-{
-	lvmetad_connect_or_warn();
-
-	return _lvmetad_connected;
-}
-
-void lvmetad_set_active(struct cmd_context *cmd, int active)
+void lvmetad_set_socket(const char *sock)
 {
-	_lvmetad_use = active;
-
-	if (!active && lvmetad_active())
-		lvmetad_disconnect();
-
-	if (cmd && !refresh_filters(cmd))
-		stack;
+	_lvmetad_socket = sock;
 }
 
 /*
@@ -224,11 +205,6 @@ void lvmetad_release_token(void)
 	_lvmetad_token = NULL;
 }
 
-void lvmetad_set_socket(const char *sock)
-{
-	_lvmetad_socket = sock;
-}
-
 /*
  * Check if lvmetad's token matches our token.  The token is a hash of the
  * global filter used to populate lvmetad.  The lvmetad token was set by the
@@ -351,7 +327,7 @@ out:
 fail:
 	daemon_reply_destroy(reply);
 	/* The command will not use lvmetad and will revert to scanning. */
-	lvmetad_set_active(cmd, 0);
+	lvmetad_make_unused(cmd);
 	return 0;
 }
 
@@ -428,6 +404,11 @@ static daemon_reply _lvmetad_send(struct cmd_context *cmd, const char *id, ...)
 	unsigned int wait_sec = 0;
 	uint64_t now = 0, wait_start = 0;
 
+	if (!_lvmetad_connected || !_lvmetad_use) {
+		reply.error = ECONNRESET;
+		return reply;
+	}
+
 	if (cmd)
 		wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
 retry:
@@ -448,6 +429,9 @@ retry:
 
 	daemon_request_destroy(req);
 
+	if (reply.error == ECONNRESET)
+		log_warn("WARNING: lvmetad connection failed, cannot reconnect."); 
+
 	if (reply.error)
 		goto out;
 
@@ -846,7 +830,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	struct pv_list *pvl;
 	int rescan = 0;
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return NULL;
 
 	if (vgid) {
@@ -1026,7 +1010,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!vg)
 		return 0;
 
-	if (!lvmetad_active() || test_mode())
+	if (!lvmetad_used() || test_mode())
 		return 1; /* fake it */
 
 	if (!vg->cft_precommitted) {
@@ -1080,7 +1064,7 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	daemon_reply reply;
 	int result;
 
-	if (!lvmetad_active() || test_mode())
+	if (!lvmetad_used() || test_mode())
 		return 1; /* just fake it */
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
@@ -1102,7 +1086,7 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 	int result = 0;
 	struct dm_config_node *cn;
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return_0;
 
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
@@ -1136,7 +1120,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return_0;
 
 	log_debug_lvmetad("Asking lvmetad for PV on %s", dev_name(dev));
@@ -1165,7 +1149,7 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return 1;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
@@ -1243,7 +1227,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return 1;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known VGs");
@@ -1362,7 +1346,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	int64_t changed;
 	int result;
 
-	if (!lvmetad_active() || test_mode())
+	if (!lvmetad_used() || test_mode())
 		return 1;
 
 	if (!id_write_format(pvid, uuid, sizeof(uuid)))
@@ -1502,7 +1486,7 @@ int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler
 	int result;
 	int found;
 
-	if (!lvmetad_active() || test_mode())
+	if (!lvmetad_used() || test_mode())
 		return 1;
 
 	/*
@@ -1692,7 +1676,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	struct format_instance_ctx fic = { .type = 0 };
 	struct metadata_area *mda;
 
-	if (!lvmetad_active()) {
+	if (!lvmetad_used()) {
 		log_error("Cannot proceed since lvmetad is not active.");
 		return 0;
 	}
@@ -1805,7 +1789,7 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	int replaced_update = 0;
 	int retries = 0;
 
-	if (!lvmetad_active()) {
+	if (!lvmetad_used()) {
 		log_error("Cannot proceed since lvmetad is not active.");
 		return 0;
 	}
@@ -1952,7 +1936,7 @@ static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *p
 	const char *pvid_txt;
 	const char *vgid;
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return 1;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
@@ -2146,7 +2130,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 		return;
 	}
 
-	if (!lvmetad_active())
+	if (!lvmetad_used())
 		return;
 
 	log_debug_lvmetad("Validating global lvmetad cache");
@@ -2195,13 +2179,13 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	 */
 	if (!lvmetad_pvscan_all_devs(cmd, NULL, 1)) {
 		log_warn("WARNING: Not using lvmetad because cache update failed.");
-		lvmetad_set_active(cmd, 0);
+		lvmetad_make_unused(cmd);
 		return;
 	}
 
 	if (lvmetad_is_disabled(cmd, &reason)) {
 		log_warn("WARNING: Not using lvmetad because %s.", reason);
-		lvmetad_set_active(cmd, 0);
+		lvmetad_make_unused(cmd);
 		return;
 	}
 
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 9ae3f26..82371d9 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -28,15 +28,18 @@ typedef int (*activation_handler) (struct cmd_context *cmd,
 				   enum activation_change activate);
 
 #ifdef LVMETAD_SUPPORT
-/*
- * Sets up a global handle for our process.
- */
-void lvmetad_init(struct cmd_context *);
 
 /*
- * Override the use of lvmetad for retrieving scan results and metadata.
+ * lvmetad_connect: connect to lvmetad
+ * lvmetad_disconnect: disconnect from lvmetad
+ * lvmetad_make_unused: disconnect from lvmetad and refresh cmd filter
+ * lvmetad_used: check if lvmetad is being used (i.e. is connected)
  */
-void lvmetad_set_active(struct cmd_context *, int);
+int lvmetad_connect(struct cmd_context *cmd);
+void lvmetad_disconnect(void);
+void lvmetad_make_unused(struct cmd_context *cmd);
+int lvmetad_used(void);
+
 
 /*
  * Configure the socket that lvmetad_init will use to connect to the daemon.
@@ -44,40 +47,12 @@ void lvmetad_set_active(struct cmd_context *, int);
 void lvmetad_set_socket(const char *);
 
 /*
- * Check whether lvmetad is used.
- */
-int lvmetad_used(void);
-
-/*
  * Check if lvmetad socket is present (either the one set by lvmetad_set_socket
- * or the default one if not set). For example, this may be used before calling
- * lvmetad_active() check that does connect to the socket - this would produce
- * various connection errors if the socket is not present.
+ * or the default one if not set).
  */
 int lvmetad_socket_present(void);
 
 /*
- * Check whether lvmetad is active (where active means both that it is running
- * and that we have a working connection with it). It opens new connection
- * with lvmetad in the process when lvmetad is supposed to be used and the
- * connection is not open yet.
- */
-int lvmetad_active(void);
-
-/* 
- * Connect to lvmetad unless the connection is already open or lvmetad is
- * not configured to be used.  If we fail to connect, print a warning.
- */
-void lvmetad_connect_or_warn(void);
-
-/*
- * Drop connection to lvmetad. A subsequent lvmetad_connect_or_warn or
- * lvmetad_active will re-establish the connection (possibly at a
- * different socket path).
- */
-void lvmetad_disconnect(void);
-
-/*
  * Set the "lvmetad validity token" (currently only consists of the lvmetad
  * filter. See lvm.conf.
  */
@@ -178,14 +153,12 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 
 #  else		/* LVMETAD_SUPPORT */
 
-#    define lvmetad_init(cmd)	do { } while (0)
 #    define lvmetad_disconnect()	do { } while (0)
-#    define lvmetad_set_active(cmd, a)	do { } while (0)
+#    define lvmetad_connect(cmd)	do { } while (0)
+#    define lvmetad_make_unused()	do { } while (0)
+#    define lvmetad_used()		(0)
 #    define lvmetad_set_socket(a)	do { } while (0)
-#    define lvmetad_used()	(0)
 #    define lvmetad_socket_present()	(0)
-#    define lvmetad_active()	(0)
-#    define lvmetad_connect_or_warn()	do { } while (0)
 #    define lvmetad_set_token(a)	do { } while (0)
 #    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 08e857c..1f8ac4c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1673,6 +1673,26 @@ static int _reopen_stream(FILE *stream, int fd, const char *mode, const char *na
 	return 1;
 }
 
+/*
+ * init_connections();
+ *   _init_lvmetad();
+ *     lvmetad_disconnect();  (close previous connection)
+ *     lvmetad_set_socket();  (set path from config)
+ *     lvmetad_set_token();   (set token from filter config)
+ *     if (find_config(use_lvmetad))
+ *       lvmetad_connect();
+ *
+ * If lvmetad_connect() is successful, lvmetad_used() will
+ * return 1.
+ *
+ * If the config has use_lvmetad=0, then lvmetad_connect()
+ * will not be called, and lvmetad_used() will return 0.
+ *
+ * Other code should use lvmetad_used() to check if the
+ * command is using lvmetad.
+ *
+ */
+
 static int _init_lvmetad(struct cmd_context *cmd)
 {
 	const struct dm_config_node *cn;
@@ -1695,13 +1715,27 @@ static int _init_lvmetad(struct cmd_context *cmd)
 
 	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
 	    find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
-			 "Clustered environment not supported by lvmetad yet.");
-		lvmetad_set_active(NULL, 0);
-	} else
-		lvmetad_set_active(NULL, find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL));
+		log_warn("WARNING: Not using lvmetad because locking_type is 3 (clustered).");
+		return 1;
+	}
+
+	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
+		if (lvmetad_socket_present())
+			log_warn("WARNING: Not using lvmetad because config setting use_lvmetad=0.");
+		return 1;
+	}
+
+	if (!lvmetad_connect(cmd)) {
+		log_warn("WARNING: Failed to connect to lvmetad. Falling back to device scanning.");
+		return 1;
+	}
+
+	if (!lvmetad_used()) {
+		/* This should never happen. */
+		log_error(INTERNAL_ERROR "lvmetad setup incorrect");
+		return 0;
+	}
 
-	lvmetad_init(cmd);
 	return 1;
 }
 
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index b92f4a5..8220c38 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -502,7 +502,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 	if (!vg_write(vg))
 		return_0;
 
-	if (drop_lvmetad && lvmetad_active()) {
+	if (drop_lvmetad && lvmetad_used()) {
 		struct volume_group *vg_lvmetad = lvmetad_vg_lookup(cmd, vg->name, NULL);
 		if (vg_lvmetad) {
 			/* FIXME Cope with failure to update lvmetad */
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index bd20670..43ebd27 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1525,7 +1525,7 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
 		return_0;
 
-	if (lvmetad_active()) {
+	if (lvmetad_used()) {
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
 		if (!info && !lvmetad_pv_lookup_by_dev(fmt->cmd, dev, NULL))
 			return 0;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 22f519e..f9a1040 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -63,7 +63,7 @@ static int _vsn1_check_version(const struct dm_config_tree *cft)
 	const struct dm_config_value *cv;
 
 	// TODO if this is pvscan --cache, we want this check back.
-	if (lvmetad_active())
+	if (lvmetad_used())
 		return 1;
 
 	/*
@@ -241,8 +241,8 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
-	/* TODO is the !lvmetad_active() too coarse here? */
-	if (!pv->dev && !lvmetad_active())
+	/* TODO is the !lvmetad_used() too coarse here? */
+	if (!pv->dev && !lvmetad_used())
 		pv->status |= MISSING_PV;
 
 	if ((pv->status & MISSING_PV) && pv->dev && pv_mda_used_count(pv) == 0) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 782235e..e9f5fa5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4122,7 +4122,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		return _vg_read_orphans(cmd, warn_flags, vgname, consistent);
 	}
 
-	if (lvmetad_active() && !use_precommitted) {
+	if (lvmetad_used() && !use_precommitted) {
 		if ((correct_vg = lvmcache_get_vg(cmd, vgname, vgid, precommitted))) {
 			dm_list_iterate_items(pvl, &correct_vg->pvs)
 				if (pvl->pv->dev)
@@ -4949,7 +4949,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	if (!(dev = dev_cache_get(pv_name, cmd->filter)))
 		return_NULL;
 
-	if (lvmetad_active()) {
+	if (lvmetad_used()) {
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
 		if (!info) {
 			if (!lvmetad_pv_lookup_by_dev(cmd, dev, &found))
@@ -5044,7 +5044,7 @@ int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
 		return 1;
 	}
 
-	if (lvmetad_active()) {
+	if (lvmetad_used()) {
 		/*
 		 * This just gets the list of names/ids from lvmetad
 		 * and does not populate lvmcache.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 316a786..3a050e9 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1258,25 +1258,10 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 * need to take special care here as lvmetad service does
 	 * not neet to be running at this moment yet - it could be
 	 * just too early during system initialization time.
-	*/
-	if (arg_count(cmd, sysinit_ARG) && lvmetad_used() &&
-	    arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY) {
-		if (!lvmetad_socket_present()) {
-			/*
-			 * If lvmetad socket is not present yet,
-			 * the service is just not started. It'll
-			 * be started a bit later so we need to do
-			 * the activation without lvmetad which means
-			 * direct activation instead of autoactivation.
-			*/
-			log_warn("lvmetad is not active yet, using direct activation during sysinit");
-			lvmetad_set_active(cmd, 0);
-		} else if (lvmetad_active()) {
-			/*
-			 * If lvmetad is active already, we want
-			 * to make use of the autoactivation.
-			*/
-			log_warn("lvmetad is active, skipping direct activation during sysinit");
+	 */
+	if (arg_count(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
+		if (lvmetad_used()) {
+			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit");
 			return ECMD_PROCESSED;
 		}
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index dd89a7b..e6c82cf 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1112,9 +1112,6 @@ static int _get_settings(struct cmd_context *cmd)
 	 */
 	cmd->vg_read_print_access_error = 1;
 		
-	if (!arg_count(cmd, sysinit_ARG))
-		lvmetad_connect_or_warn();
-
 	if (arg_count(cmd, nosuffix_ARG))
 		cmd->current_settings.suffix = 0;
 
@@ -1474,8 +1471,7 @@ static int _cmd_no_meta_proc(struct cmd_context *cmd)
 
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct dm_config_tree *config_string_cft;
-	struct dm_config_tree *config_profile_command_cft, *config_profile_metadata_cft;
+	struct dm_config_tree *config_string_cft, *config_profile_command_cft, *config_profile_metadata_cft;
 	const char *reason = NULL;
 	int ret = 0;
 	int locking_type;
@@ -1606,7 +1602,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
 		lvmetad_set_disabled(cmd, "LVM1");
 		log_warn("WARNING: Not using lvmetad because lvm1 format is used.");
-		lvmetad_set_active(cmd, 0);
+		lvmetad_make_unused(cmd);
 	}
 
 	if (cmd->metadata_read_only &&
@@ -1633,7 +1629,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 
 		if (lvmetad_used()) {
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 			log_verbose("Not using lvmetad because read-only is set.");
 		}
 	} else if (arg_count(cmd, nolocking_ARG))
@@ -1674,13 +1670,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
 			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, cmd->include_foreign_vgs ? 1 : 0)) {
 				log_warn("WARNING: Not using lvmetad because cache update failed.");
-				lvmetad_set_active(cmd, 0);
+				lvmetad_make_unused(cmd);
 			}
 		}
 
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 	}
 
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 4f13587..4ae3ce6 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -105,12 +105,12 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 
 		/*
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 4d8275c..46439c8 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -99,7 +99,7 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	 * we lock VG_GLOBAL to enable use of metadata cache.
 	 * This can pause alongide pvscan or vgscan process for a while.
 	 */
-	if (!lvmetad_active()) {
+	if (!lvmetad_used()) {
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 			log_error("Unable to obtain global lock.");
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 44e7737..425383a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -465,12 +465,12 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 	}
 
diff --git a/tools/reporter.c b/tools/reporter.c
index ab11be2..fb09263 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -897,7 +897,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	 * This can pause alongide pvscan or vgscan process for a while.
 	 */
 	if (args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
-	    !lvmetad_active()) {
+	    !lvmetad_used()) {
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 			log_error("Unable to obtain global lock.");
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 83f75fa..372f881 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1184,24 +1184,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	 * not neet to be running at this moment yet - it could be
 	 * just too early during system initialization time.
 	 */
-	if (arg_count(cmd, sysinit_ARG) && lvmetad_used() &&
-	    arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY) {
-		if (!lvmetad_socket_present()) {
-			/*
-			 * If lvmetad socket is not present yet,
-			 * the service is just not started. It'll
-			 * be started a bit later so we need to do
-			 * the activation without lvmetad which means
-			 * direct activation instead of autoactivation.
-			 */
-			log_warn("lvmetad is not active yet, using direct activation during sysinit");
-			lvmetad_set_active(cmd, 0);
-		} else if (lvmetad_active()) {
-			/*
-			 * If lvmetad is active already, we want
-			 * to make use of the autoactivation.
-			 */
-			log_warn("lvmetad is active, skipping direct activation during sysinit");
+	if (arg_count(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
+		if (lvmetad_used()) {
+			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit");
 			return ECMD_PROCESSED;
 		}
 	}
diff --git a/tools/vgck.c b/tools/vgck.c
index fc2f886..15f7bc3 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -37,7 +37,7 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	lvmetad_set_active(cmd, 0);
+	lvmetad_make_unused(cmd);
 	return process_each_vg(cmd, argc, argv, NULL, 0, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgimport.c b/tools/vgimport.c
index f5980a1..5bcf7e0 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -98,12 +98,12 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 	if (lvmetad_used()) {
 		if (!lvmetad_pvscan_all_devs(cmd, NULL, 1)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 	}
 
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 78048c0..59a0f6a 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -103,12 +103,12 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	if (lvmetad_used() && (arg_is_set(cmd, cache_long_ARG) || !lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, arg_is_set(cmd, cache_long_ARG))) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_set_active(cmd, 0);
+			lvmetad_make_unused(cmd);
 		}
 	}
 


