From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Dec 2008 18:27:11 -0500
Subject: [RFC][PATCH] Create global is_static() to eliminate from the library init function.
Message-ID: <1229556431-14791-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Very simple / crude method of removing 'is_static' from initialization.

Why should we require an application tell us whether it is linked
statically or dynamically to libLVM?  If the application is linked
statically, but libraries exist and dlopen() calls succeed, why
do we care if it's statically linked?

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |    8 +++-----
 lib/commands/toolcontext.h    |    3 +--
 lib/locking/locking.c         |    2 +-
 lib/lvm2.h                    |    4 ++--
 lib/misc/lvm-globals.c        |   11 +++++++++++
 lib/misc/lvm-globals.h        |    2 ++
 lib/misc/sharedlib.c          |    2 +-
 tools/lvchange.c              |    2 +-
 tools/lvm-static.c            |    3 ++-
 tools/lvm.c                   |    2 +-
 tools/lvm2cmdline.h           |    4 ++--
 tools/lvmcmdlib.c             |    5 +++--
 tools/lvmcmdline.c            |   10 +++++-----
 tools/vgchange.c              |    2 +-
 15 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 7250e04..c74bf26 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -724,7 +724,7 @@ void lvm_do_backup(const char *vgname)
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(0, 1))) {
+	if (!(cmd = create_toolcontext(1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index cda9057..0a98325 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -738,7 +738,7 @@ static int _init_formats(struct cmd_context *cmd)
 
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs if not static */
-	if (!cmd->is_static &&
+	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/format_libraries"))) {
 
 		struct config_value *cv;
@@ -848,7 +848,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
-	if (!cmd->is_static &&
+	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
 		struct config_value *cv;
@@ -998,8 +998,7 @@ static void _init_globals(struct cmd_context *cmd)
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_static,
-				       unsigned is_long_lived)
+struct cmd_context *create_toolcontext(unsigned is_long_lived)
 {
 	struct cmd_context *cmd;
 
@@ -1021,7 +1020,6 @@ struct cmd_context *create_toolcontext(unsigned is_static,
 		return NULL;
 	}
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->is_static = is_static;
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
 	cmd->hosttags = 0;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 3c7dfea..7d2aef9 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -66,7 +66,6 @@ struct cmd_context {
 	char *cmd_line;
 	struct command *command;
 	char **argv;
-	unsigned is_static:1;	/* Static binary? */
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned partial_activation:1;
@@ -95,7 +94,7 @@ struct cmd_context {
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index aa008ff..b5871ae 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -228,7 +228,7 @@ int init_locking(int type, struct cmd_context *cmd)
 
 #ifdef HAVE_LIBDL
 	case 2:
-		if (!cmd->is_static) {
+		if (!is_static()) {
 			log_very_verbose("External locking selected.");
 			if (init_external_locking(&_locking, cmd))
 				return 1;
diff --git a/lib/lvm2.h b/lib/lvm2.h
index 75c002a..b18cead 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -24,7 +24,7 @@
  */
 struct arg;
 struct cmd_context;
-struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 
 /*
@@ -37,7 +37,7 @@ lvm_handle_t lvm2_create(void);
  * NULL: Fail - unable to initialise handle.
  * non-NULL: Success - valid LVM2 handle returned
  */
-#define lvm2_create(X) create_toolcontext(0,1)
+#define lvm2_create(X) create_toolcontext(1)
 
 /*
  * lvm2_destroy
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 45114c8..870b2d7 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -38,6 +38,7 @@ static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
+static unsigned _is_static = 0;
 
 void init_verbose(int level)
 {
@@ -106,6 +107,11 @@ void init_cmd_name(int status)
 	_log_cmd_name = status;
 }
 
+void init_is_static(unsigned value)
+{
+	_is_static = value;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -199,3 +205,8 @@ int debug_level()
 {
 	return _debug_level;
 }
+
+unsigned is_static(void)
+{
+	return _is_static;
+}
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 8c354f5..8209b3e 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -34,6 +34,7 @@ void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
 void init_ignore_suspended_devices(int ignore);
 void init_error_message_produced(int produced);
+void init_is_static(unsigned value);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -50,6 +51,7 @@ int security_level(void);
 int mirror_in_sync(void);
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
+unsigned is_static(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index 7622e47..cab2909 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -44,7 +44,7 @@ void *load_shared_library(struct cmd_context *cmd, const char *libname,
 	char path[PATH_MAX];
 	void *library;
 
-	if (cmd->is_static) {
+	if (is_static()) {
 		log_error("Not loading shared %s library %s in static mode.",
 			  desc, libname);
 		return NULL;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3c2fa19..66b4874 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -597,7 +597,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (cmd->is_static || arg_count(cmd, ignoremonitoring_ARG)) ?
+					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	/* access permission change */
diff --git a/tools/lvm-static.c b/tools/lvm-static.c
index b0c1e12..822989f 100644
--- a/tools/lvm-static.c
+++ b/tools/lvm-static.c
@@ -17,7 +17,8 @@
 
 int main(int argc, char **argv)
 {
-	return lvm2_main(argc, argv, 1);
+	init_is_static(1);
+	return lvm2_main(argc, argv);
 }
 
 int lvm_shell(struct cmd_context *cmd __attribute((unused)),
diff --git a/tools/lvm.c b/tools/lvm.c
index 3576515..e1f7900 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -18,7 +18,7 @@
 
 int main(int argc, char **argv)
 {
-	return lvm2_main(argc, argv, 0);
+	return lvm2_main(argc, argv);
 }
 
 #ifdef READLINE_SUPPORT
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index f174179..f4855e7 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -26,12 +26,12 @@ struct cmdline_context {
         int interactive;
 };
 
-int lvm2_main(int argc, char **argv, unsigned is_static);
+int lvm2_main(int argc, char **argv);
 
 void *cmdlib_lvm2_init(unsigned is_static);
 void lvm_fin(struct cmd_context *cmd);
 
-struct cmd_context *init_lvm(unsigned is_static);
+struct cmd_context *init_lvm(void);
 void lvm_register_commands(void);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 6507acc..1a90c92 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -28,13 +28,14 @@
 #include <time.h>
 #include <sys/resource.h>
 
-void *cmdlib_lvm2_init(unsigned is_static)
+void *cmdlib_lvm2_init(unsigned static_compile)
 {
 	struct cmd_context *cmd;
 
 	lvm_register_commands();
 
-	if (!(cmd = init_lvm(is_static)))
+	init_is_static(static_compile);
+	if (!(cmd = init_lvm()))
 		return NULL;
 
 	return (void *) cmd;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 95dcfbe..f4a19e5 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1147,13 +1147,13 @@ static void _close_stray_fds(const char *command)
 				  parent_cmdline);
 }
 
-struct cmd_context *init_lvm(unsigned is_static)
+struct cmd_context *init_lvm(void)
 {
 	struct cmd_context *cmd;
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(is_static, 0)))
+	if (!(cmd = create_toolcontext(0)))
 		return_NULL;
 
 	return cmd;
@@ -1272,7 +1272,7 @@ static void _nonroot_warning(void)
 		log_warn("WARNING: Running as a non-root user. Functionality may be unavailable.");
 }
 
-int lvm2_main(int argc, char **argv, unsigned is_static)
+int lvm2_main(int argc, char **argv)
 {
 	const char *base;
 	int ret, alias = 0;
@@ -1285,7 +1285,7 @@ int lvm2_main(int argc, char **argv, unsigned is_static)
 
 	_close_stray_fds(base);
 
-	if (is_static && strcmp(base, "lvm.static") &&
+	if (is_static() && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_SHARED_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {
 		setenv("LVM_DID_EXEC", base, 1);
@@ -1293,7 +1293,7 @@ int lvm2_main(int argc, char **argv, unsigned is_static)
 		unsetenv("LVM_DID_EXEC");
 	}
 
-	if (!(cmd = init_lvm(is_static)))
+	if (!(cmd = init_lvm()))
 		return -1;
 
 	cmd->argv = argv;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index f2df836..f5d0197 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -540,7 +540,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (cmd->is_static || arg_count(cmd, ignoremonitoring_ARG)) ?
+					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	if (arg_count(cmd, available_ARG))
-- 
1.5.5.1


