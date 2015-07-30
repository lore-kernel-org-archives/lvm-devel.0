From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jul 2015 11:57:59 +0000 (UTC)
Subject: master - toolcontext: add switches to create_toolcontext for connections and filters init
Message-ID: <20150730115759.A1AD760FB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6473baffc2d0b486b2aa941cf2681683026b3a5
Commit:        f6473baffc2d0b486b2aa941cf2681683026b3a5
Parent:        3e343ba5ef02d8ae3e87eadc80cf69fc34c65622
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 30 10:34:10 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 30 13:54:09 2015 +0200

toolcontext: add switches to create_toolcontext for connections and filters init

Make it possible to decide whether we want to initialize connections and
filters together with toolcontext creation.

Add "filters" and "connections" fields to struct
cmd_context_initialized_parts and set these in cmd_context.initialized
instance accordingly.

(For now, all create_toolcontext calls do initialize connections and
filters, we'll change that in subsequent patch appropriately.)
---
 daemons/clvmd/lvm-functions.c |    2 +-
 daemons/lvmetad/testclient.c  |    2 +-
 lib/commands/toolcontext.c    |   54 ++++++++++++++++++++++++++++------------
 lib/commands/toolcontext.h    |    8 +++++-
 liblvm/lvm_base.c             |    2 +-
 tools/lvm2cmdline.h           |    2 +-
 tools/lvmcmdlib.c             |    2 +-
 tools/lvmcmdline.c            |    7 +++--
 8 files changed, 54 insertions(+), 25 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e7dbfde..99e7317 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -899,7 +899,7 @@ int init_clvm(struct dm_hash_table *excl_uuid)
 	if (!get_initial_state(excl_uuid))
 		log_error("Cannot load initial lock states.");
 
-	if (!(cmd = create_toolcontext(1, NULL, 0, 1))) {
+	if (!(cmd = create_toolcontext(1, NULL, 0, 1, 1, 1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/daemons/lvmetad/testclient.c b/daemons/lvmetad/testclient.c
index fbf7b65..59aedc6 100644
--- a/daemons/lvmetad/testclient.c
+++ b/daemons/lvmetad/testclient.c
@@ -124,7 +124,7 @@ int main(int argc, char **argv) {
 
 	if (argc > 1) {
 		int i;
-		struct cmd_context *cmd = create_toolcontext(0, NULL, 0, 0);
+		struct cmd_context *cmd = create_toolcontext(0, NULL, 0, 0, 1, 1);
 		for (i = 1; i < argc; ++i) {
 			const char *uuid = NULL;
 			scan(h, argv[i]);
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index dadb3c5..c087820 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -55,7 +55,6 @@
 #endif
 
 static const size_t linebuffer_size = 4096;
-static int _init_connections(struct cmd_context *cmd);
 
 /*
  * Copy the input string, removing invalid characters.
@@ -675,9 +674,6 @@ static int _process_config(struct cmd_context *cmd)
 	init_detect_internal_vg_cache_corruption
 		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
 
-	if (!_init_connections(cmd))
-		return_0;
-
 	if (!_init_system_id(cmd))
 		return_0;
 
@@ -1165,7 +1161,7 @@ bad:
  *     md component filter -> fw raid filter
  *
  */
-static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
+int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
 	const char *dev_cache;
 	struct dev_filter *filter = NULL, *filter_components[2] = {0};
@@ -1173,6 +1169,11 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	const struct dm_config_node *cn;
 	struct timespec ts, cts;
 
+	if (!cmd->initialized.connections) {
+		log_error(INTERNAL_ERROR "connections must be initialized before filters");
+		return 0;
+	}
+
 	cmd->dump_filter = 0;
 
 	cmd->lvmetad_filter = _init_lvmetad_filter_chain(cmd);
@@ -1253,6 +1254,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 				    dev_cache);
 	}
 
+	cmd->initialized.filters = 1;
 	return 1;
 bad:
 	if (!filter) {
@@ -1276,6 +1278,7 @@ bad:
 	if (cmd->lvmetad_filter)
 		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
 
+	cmd->initialized.filters = 0;
 	return 0;
 }
 
@@ -1696,26 +1699,33 @@ static int _init_lvmpolld(struct cmd_context *cmd)
 	return 1;
 }
 
-static int _init_connections(struct cmd_context *cmd)
+int init_connections(struct cmd_context *cmd)
 {
+
 	if (!_init_lvmetad(cmd)) {
 		log_error("Failed to initialize lvmetad connection.");
-		return 0;
+		goto bad;
 	}
 
 	if (!_init_lvmpolld(cmd)) {
 		log_error("Failed to initialize lvmpolld connection.");
-		return 0;
+		goto bad;
 	}
 
+	cmd->initialized.connections = 1;
 	return 1;
+bad:
+	cmd->initialized.connections = 0;
+	return 0;
 }
 
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir,
 				       unsigned set_buffering,
-				       unsigned threaded)
+				       unsigned threaded,
+				       unsigned set_connections,
+				       unsigned set_filters)
 {
 	struct cmd_context *cmd;
 	FILE *new_stream;
@@ -1859,9 +1869,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_init_dev_cache(cmd))
 		goto_out;
 
-	if (!_init_filters(cmd, 1))
-		goto_out;
-
 	memlock_init(cmd);
 
 	if (!_init_formats(cmd))
@@ -1880,6 +1887,12 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 
 	_init_globals(cmd);
 
+	if (set_connections && !init_connections(cmd))
+		return_0;
+
+	if (set_filters && !init_filters(cmd, 1))
+		goto_out;
+
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
@@ -1957,14 +1970,19 @@ static void _destroy_filters(struct cmd_context *cmd)
 		cmd->full_filter->destroy(cmd->full_filter);
 		cmd->lvmetad_filter = cmd->filter = cmd->full_filter = NULL;
 	}
+	cmd->initialized.filters = 0;
 }
 
 int refresh_filters(struct cmd_context *cmd)
 {
 	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
 
+	if (!cmd->initialized.filters)
+		/* if filters not initialized, there's nothing to refresh */
+		return 1;
+
 	_destroy_filters(cmd);
-	if (!(r = _init_filters(cmd, 0)))
+	if (!(r = init_filters(cmd, 0)))
                 stack;
 
 	/*
@@ -2074,9 +2092,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_dev_cache(cmd))
 		return_0;
 
-	if (!_init_filters(cmd, 0))
-		return_0;
-
 	if (!_init_formats(cmd))
 		return_0;
 
@@ -2091,6 +2106,12 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	cmd->initialized.config = 1;
 
+	if (cmd->initialized.connections && !init_connections(cmd))
+		return_0;
+
+	if (cmd->initialized.filters && !init_filters(cmd, 0))
+		return_0;
+
 	reset_lvm_errno(1);
 	return 1;
 }
@@ -2159,6 +2180,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	lvmetad_release_token();
 	lvmetad_disconnect();
 	lvmpolld_disconnect();
+	cmd->initialized.connections = 0;
 
 	release_log_memory();
 	activation_exit();
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c59024b..57feb01 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -62,6 +62,8 @@ struct config_tree_list {
 
 struct cmd_context_initialized_parts {
 	unsigned config:1; /* used to reinitialize config if previous init was not successful */
+	unsigned filters:1;
+	unsigned connections:1;
 };
 
 /* FIXME Split into tool & library contexts */
@@ -171,13 +173,17 @@ struct cmd_context {
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir,
 				       unsigned set_buffering,
-				       unsigned threaded);
+				       unsigned threaded,
+				       unsigned set_connections,
+				       unsigned set_filters);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int refresh_filters(struct cmd_context *cmd);
 int process_profilable_config(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
+int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache);
+int init_connections(struct cmd_context *cmd);
 
 struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format);
 
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index c1954d1..5b14c3b 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -45,7 +45,7 @@ static lvm_t _lvm_init(const char *system_dir)
 	/* create context */
 	/* FIXME: split create_toolcontext */
 	/* FIXME: make all globals configurable */
-	cmd = create_toolcontext(0, system_dir, 0, 0);
+	cmd = create_toolcontext(0, system_dir, 0, 0, 1, 1);
 	if (!cmd)
 		return NULL;
 
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 5c4889e..fe77d56 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -31,7 +31,7 @@ int lvm2_main(int argc, char **argv);
 void *cmdlib_lvm2_init(unsigned static_compile);
 void lvm_fin(struct cmd_context *cmd);
 
-struct cmd_context *init_lvm(void);
+struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters);
 void lvm_register_commands(void);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 76576c2..26f160f 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -33,7 +33,7 @@ void *cmdlib_lvm2_init(unsigned static_compile)
 	lvm_register_commands();
 
 	init_is_static(static_compile);
-	if (!(cmd = init_lvm()))
+	if (!(cmd = init_lvm(1, 1)))
 		return NULL;
 
 	return (void *) cmd;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 98a2c30..0c88164 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1873,7 +1873,7 @@ static int _close_stray_fds(const char *command)
 	return 1;
 }
 
-struct cmd_context *init_lvm(void)
+struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 {
 	struct cmd_context *cmd;
 
@@ -1887,7 +1887,8 @@ struct cmd_context *init_lvm(void)
 	 */
 	dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
-	if (!(cmd = create_toolcontext(0, NULL, 1, 0))) {
+	if (!(cmd = create_toolcontext(0, NULL, 1, 0,
+			set_connections, set_filters))) {
 		udev_fin_library_context();
 		return_NULL;
 	}
@@ -2055,7 +2056,7 @@ int lvm2_main(int argc, char **argv)
 	if (!alias && argc > 1 && !strcmp(argv[1], "version"))
 		return lvm_return_code(version(NULL, argc, argv));
 
-	if (!(cmd = init_lvm()))
+	if (!(cmd = init_lvm(1, 1)))
 		return -1;
 
 	cmd->argv = argv;


