From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:45:56 -0500
Subject: master - cleanup: more usage of dm_strncpy
Message-ID: <201803061445.w26Ejuop026681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6e7a0b490a3fa2e43675a4d3fb3d25daaac831e
Commit:        b6e7a0b490a3fa2e43675a4d3fb3d25daaac831e
Parent:        f04abd1f8a7eea9edf473be17ae1e2aea1a00ee6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 16:25:37 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:40:34 2018 +0100

cleanup: more usage of dm_strncpy

Use existing wrapper function arournd  strncpy + buf[] = 0;
---
 daemons/clvmd/lvm-functions.c  |    3 +--
 daemons/lvmetad/lvmetad-core.c |   15 ++++++---------
 lib/cache/lvmcache.c           |   17 ++++++-----------
 lib/device/dev-cache.c         |    6 ++----
 lib/format_text/archive.c      |    3 +--
 lib/format_text/format-text.c  |    6 ++----
 lib/misc/lvm-globals.c         |    6 ++----
 lib/misc/sharedlib.c           |    3 +--
 tools/command.c                |    3 +--
 9 files changed, 22 insertions(+), 40 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e872fbe..c845e6d 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -807,8 +807,7 @@ static void lvm2_log_fn(int level, const char *file, int line, int dm_errno,
 	if (level != _LOG_ERR && level != _LOG_FATAL)
 		return;
 
-	strncpy(last_error, message, sizeof(last_error));
-	last_error[sizeof(last_error)-1] = '\0';
+	(void) dm_strncpy(last_error, message, sizeof(last_error));
 }
 
 /* This checks some basic cluster-LVM configuration stuff */
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 04a7224..eeb3f20 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2705,9 +2705,8 @@ static response handler(daemon_state s, client_handle h, request r)
 		if (!prev_in_progress && this_in_progress) {
 			/* New update is starting (filter token is replaced by update token) */
 
-			memcpy(prev_token, state->token, 128);
-			strncpy(state->token, token, 128);
-			state->token[127] = 0;
+			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
+			(void) dm_strncpy(state->token, token, sizeof(state->token));
 			state->update_begin = _monotonic_seconds();
 			state->update_timeout = update_timeout;
 			state->update_pid = pid;
@@ -2728,9 +2727,8 @@ static response handler(daemon_state s, client_handle h, request r)
 				 (int)(_monotonic_seconds() - state->update_begin),
 				 state->update_cmd);
 
-			memcpy(prev_token, state->token, 128);
-			strncpy(state->token, token, 128);
-			state->token[127] = 0;
+			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
+			(void) dm_strncpy(state->token, token, sizeof(state->token));
 			state->update_begin = _monotonic_seconds();
 			state->update_timeout = update_timeout;
 			state->update_pid = pid;
@@ -2762,9 +2760,8 @@ static response handler(daemon_state s, client_handle h, request r)
 				 (int)(_monotonic_seconds() - state->update_begin),
 				 state->update_pid, token);
 
-			memcpy(prev_token, state->token, 128);
-			strncpy(state->token, token, 128);
-			state->token[127] = 0;
+			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
+			(void) dm_strncpy(state->token, token, sizeof(state->token));
 			state->update_begin = 0;
 			state->update_timeout = 0;
 			state->update_pid = 0;
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4022ea6..5ff2827 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -617,8 +617,7 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
 	}
 
 	/* vgid not necessarily NULL-terminated */
-	strncpy(&id[0], vgid, ID_LEN);
-	id[ID_LEN] = '\0';
+	(void) dm_strncpy(id, vgid, sizeof(id));
 
 	if (!(vginfo = dm_hash_lookup(_vgid_hash, id))) {
 		log_debug_cache("lvmcache has no info for vgid \"%s\"", id);
@@ -719,8 +718,7 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *d
 	if (!_pvid_hash || !pvid)
 		return NULL;
 
-	strncpy(&id[0], pvid, ID_LEN);
-	id[ID_LEN] = '\0';
+	(void) dm_strncpy(id, pvid, sizeof(id));
 
 	if (!(info = dm_hash_lookup(_pvid_hash, id)))
 		return NULL;
@@ -1646,8 +1644,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 		return 1;
 	}
 
-	strncpy(vginfo->vgid, vgid, ID_LEN);
-	vginfo->vgid[ID_LEN] = '\0';
+	(void) dm_strncpy(vginfo->vgid, vgid, sizeof(vginfo->vgid));
 	if (!dm_hash_insert(_vgid_hash, vginfo->vgid, vginfo)) {
 		log_error("_lvmcache_update: vgid hash insertion failed: %s",
 			  vginfo->vgid);
@@ -2055,10 +2052,8 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 		.lock_type = vg->lock_type
 	};
 
-	pvid_s[sizeof(pvid_s) - 1] = '\0';
-
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
+		(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
 		if ((info = lvmcache_info_from_pvid(pvid_s, pvl->pv->dev, 0)) &&
 		    !lvmcache_update_vgname_and_id(info, &vgsummary))
@@ -2162,8 +2157,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 	struct device_list *devl;
 	int created = 0;
 
-	strncpy(pvid_s, pvid, sizeof(pvid_s) - 1);
-	pvid_s[sizeof(pvid_s) - 1] = '\0';
+	(void) dm_strncpy(pvid_s, pvid, sizeof(pvid_s));
+
 	if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
 		stack;
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 2f74c81..711c2d8 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -275,10 +275,8 @@ static int _compare_paths(const char *path0, const char *path1)
 	if (slash1 < slash0)
 		return 1;
 
-	strncpy(p0, path0, sizeof(p0) - 1);
-	p0[sizeof(p0) - 1] = '\0';
-	strncpy(p1, path1, sizeof(p1) - 1);
-	p1[sizeof(p1) - 1] = '\0';
+	(void) dm_strncpy(p0, path0, sizeof(p0));
+	(void) dm_strncpy(p1, path1, sizeof(p1));
 	s0 = p0 + 1;
 	s1 = p1 + 1;
 
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index a81a83b..2186de8 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -80,8 +80,7 @@ static int _split_vg(const char *filename, char *vgname, size_t vgsize,
 	if (vg_len + 1 > vgsize)
 		return 0;
 
-	strncpy(vgname, filename, vg_len);
-	vgname[vg_len] = '\0';
+	(void) dm_strncpy(vgname, filename, vg_len + 1);
 
 	return 1;
 }
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e1603e7..2e7e2b8 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1143,10 +1143,8 @@ static int _vg_write_file(struct format_instance *fid __attribute__((unused)),
 	if (slash == 0)
 		strcpy(temp_dir, ".");
 	else if (slash - tc->path_edit < PATH_MAX) {
-		strncpy(temp_dir, tc->path_edit,
-			(size_t) (slash - tc->path_edit));
-		temp_dir[slash - tc->path_edit] = '\0';
-
+		(void) dm_strncpy(temp_dir, tc->path_edit,
+				  (size_t) (slash - tc->path_edit + 1));
 	} else {
 		log_error("Text format failed to determine directory.");
 		return 0;
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 9c78f3e..be33091 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -205,8 +205,7 @@ void init_detect_internal_vg_cache_corruption(int detect)
 
 void set_cmd_name(const char *cmd)
 {
-	strncpy(_cmd_name, cmd, sizeof(_cmd_name) - 1);
-	_cmd_name[sizeof(_cmd_name) - 1] = '\0';
+	(void) dm_strncpy(_cmd_name, cmd, sizeof(_cmd_name));
 }
 
 const char *get_cmd_name(void)
@@ -216,8 +215,7 @@ const char *get_cmd_name(void)
 
 void set_sysfs_dir_path(const char *path)
 {
-	strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path) - 1);
-	_sysfs_dir_path[sizeof(_sysfs_dir_path) - 1] = '\0';
+	(void) dm_strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path));
 }
 
 const char *log_command_name(void)
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index db1ba43..2532f79 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -37,8 +37,7 @@ void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 	     !(cmd->lib_dir = find_config_tree_str(cmd, global_library_dir_CFG, NULL))) ||
 	    (dm_snprintf(path, path_len, "%s/%s", cmd->lib_dir,
 			 libname) == -1) || stat(path, &info) == -1) {
-		strncpy(path, libname, path_len - 1);
-		path[path_len - 1] = '\0';
+		(void) dm_strncpy(path, libname, path_len);
 	}
 }
 
diff --git a/tools/command.c b/tools/command.c
index f974474..10efedb 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -492,8 +492,7 @@ static uint64_t _lv_to_bits(struct command *cmd, char *name)
 	int argc;
 	int i;
 
-	memset(buf, 0, sizeof(buf));
-	strncpy(buf, name, LVTYPE_LEN-1);
+	(void) dm_strncpy(buf, name, LVTYPE_LEN);
 
 	_split_line(buf, &argc, argv, '_');
 


