From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jul 2015 11:57:57 +0000 (UTC)
Subject: master - refactor: toolcontext: move lvmetad and lvmpolld init into separate function
Message-ID: <20150730115757.818A160EAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e343ba5ef02d8ae3e87eadc80cf69fc34c65622
Commit:        3e343ba5ef02d8ae3e87eadc80cf69fc34c65622
Parent:        6b0c464a3462c568931c22fe71cc4f80b7ead508
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 30 10:13:45 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 30 13:54:09 2015 +0200

refactor: toolcontext: move lvmetad and lvmpolld init into separate function

Move original lvmetad and lvmpolld initialization code from
_process_config fn to their own functions _init_lvmetad and
_init_lvmpolld (both covered with single _init_connections fn).
---
 lib/commands/toolcontext.c |   98 +++++++++++++++++++++++++++++---------------
 1 files changed, 65 insertions(+), 33 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index da0ca22..dadb3c5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -55,6 +55,7 @@
 #endif
 
 static const size_t linebuffer_size = 4096;
+static int _init_connections(struct cmd_context *cmd);
 
 /*
  * Copy the input string, removing invalid characters.
@@ -532,8 +533,6 @@ static int _process_config(struct cmd_context *cmd)
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	int64_t pv_min_kb;
-	const char *lvmetad_socket;
-	const char *lvmpolld_socket;
 	int udev_disabled = 0;
 	char sysfs_dir[PATH_MAX];
 
@@ -676,41 +675,12 @@ static int _process_config(struct cmd_context *cmd)
 	init_detect_internal_vg_cache_corruption
 		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
 
-	lvmetad_disconnect();
-	lvmpolld_disconnect();
-
-	lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
-	if (!lvmetad_socket)
-		lvmetad_socket = DEFAULT_RUN_DIR "/lvmetad.socket";
-
-	/* TODO?
-		lvmetad_socket = find_config_tree_str(cmd, "lvmetad/socket_path",
-						      DEFAULT_RUN_DIR "/lvmetad.socket");
-	*/
-	lvmetad_set_socket(lvmetad_socket);
-	cn = find_config_tree_array(cmd, devices_global_filter_CFG, NULL);
-	lvmetad_set_token(cn ? cn->v : NULL);
-
-	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
-	    find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
-			 "Clustered environment not supported by lvmetad yet.");
-		lvmetad_set_active(NULL, 0);
-	} else
-		lvmetad_set_active(NULL, find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL));
-
-	lvmetad_init(cmd);
+	if (!_init_connections(cmd))
+		return_0;
 
 	if (!_init_system_id(cmd))
 		return_0;
 
-	lvmpolld_socket = getenv("LVM_LVMPOLLD_SOCKET");
-	if (!lvmpolld_socket)
-		lvmpolld_socket = DEFAULT_RUN_DIR "/lvmpolld.socket";
-	lvmpolld_set_socket(lvmpolld_socket);
-
-	lvmpolld_set_active(find_config_tree_bool(cmd, global_use_lvmpolld_CFG, NULL));
-
 	return 1;
 }
 
@@ -1679,6 +1649,68 @@ static int _reopen_stream(FILE *stream, int fd, const char *mode, const char *na
 	return 1;
 }
 
+static int _init_lvmetad(struct cmd_context *cmd)
+{
+	const struct dm_config_node *cn;
+	const char *lvmetad_socket;
+
+	lvmetad_disconnect();
+
+	lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
+	if (!lvmetad_socket)
+		lvmetad_socket = DEFAULT_RUN_DIR "/lvmetad.socket";
+
+	/* TODO?
+		lvmetad_socket = find_config_tree_str(cmd, "lvmetad/socket_path",
+						      DEFAULT_RUN_DIR "/lvmetad.socket");
+	*/
+
+	lvmetad_set_socket(lvmetad_socket);
+	cn = find_config_tree_array(cmd, devices_global_filter_CFG, NULL);
+	lvmetad_set_token(cn ? cn->v : NULL);
+
+	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
+	    find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
+		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
+			 "Clustered environment not supported by lvmetad yet.");
+		lvmetad_set_active(NULL, 0);
+	} else
+		lvmetad_set_active(NULL, find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL));
+
+	lvmetad_init(cmd);
+	return 1;
+}
+
+static int _init_lvmpolld(struct cmd_context *cmd)
+{
+	const char *lvmpolld_socket;
+
+	lvmpolld_disconnect();
+
+	lvmpolld_socket = getenv("LVM_LVMPOLLD_SOCKET");
+	if (!lvmpolld_socket)
+		lvmpolld_socket = DEFAULT_RUN_DIR "/lvmpolld.socket";
+	lvmpolld_set_socket(lvmpolld_socket);
+
+	lvmpolld_set_active(find_config_tree_bool(cmd, global_use_lvmpolld_CFG, NULL));
+	return 1;
+}
+
+static int _init_connections(struct cmd_context *cmd)
+{
+	if (!_init_lvmetad(cmd)) {
+		log_error("Failed to initialize lvmetad connection.");
+		return 0;
+	}
+
+	if (!_init_lvmpolld(cmd)) {
+		log_error("Failed to initialize lvmpolld connection.");
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir,


