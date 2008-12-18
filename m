From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 18 Dec 2008 05:27:21 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/lvm2.h ...
Message-ID: <20081218052721.6893.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-18 05:27:18

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib            : lvm2.h 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/locking    : locking.c 
	lib/misc       : lvm-globals.c lvm-globals.h sharedlib.c 
	tools          : lvchange.c lvm-static.c lvm.c lvm2cmdline.h 
	                 lvmcmdlib.c lvmcmdline.c vgchange.c 

Log message:
	Create global is_static() to eliminate from the library init function.
	
	Very simple / crude method of removing 'is_static' from initialization.
	Why should we require an application tell us whether it is linked
	statically or dynamically to libLVM?  If the application is linked
	statically, but libraries exist and dlopen() calls succeed, why
	do we care if it's statically linked?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm2.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/sharedlib.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmdline.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/17 16:46:45	1.54
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/18 05:27:17	1.55
@@ -724,7 +724,7 @@
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(0, 1))) {
+	if (!(cmd = create_toolcontext(1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
--- LVM2/lib/lvm2.h	2008/12/17 16:46:45	1.2
+++ LVM2/lib/lvm2.h	2008/12/18 05:27:18	1.3
@@ -24,7 +24,7 @@
  */
 struct arg;
 struct cmd_context;
-struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 
 /*
@@ -37,7 +37,7 @@
  * NULL: Fail - unable to initialise handle.
  * non-NULL: Success - valid LVM2 handle returned
  */
-#define lvm2_create(X) create_toolcontext(0,1)
+#define lvm2_create(X) create_toolcontext(1)
 
 /*
  * lvm2_destroy
--- LVM2/lib/commands/toolcontext.c	2008/12/17 16:46:45	1.71
+++ LVM2/lib/commands/toolcontext.c	2008/12/18 05:27:18	1.72
@@ -738,7 +738,7 @@
 
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs if not static */
-	if (!cmd->is_static &&
+	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/format_libraries"))) {
 
 		struct config_value *cv;
@@ -848,7 +848,7 @@
 
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
-	if (!cmd->is_static &&
+	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
 		struct config_value *cv;
@@ -998,8 +998,7 @@
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_static,
-				       unsigned is_long_lived)
+struct cmd_context *create_toolcontext(unsigned is_long_lived)
 {
 	struct cmd_context *cmd;
 
@@ -1021,7 +1020,6 @@
 		return NULL;
 	}
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->is_static = is_static;
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
 	cmd->hosttags = 0;
--- LVM2/lib/commands/toolcontext.h	2008/12/17 16:46:45	1.29
+++ LVM2/lib/commands/toolcontext.h	2008/12/18 05:27:18	1.30
@@ -66,7 +66,6 @@
 	char *cmd_line;
 	struct command *command;
 	char **argv;
-	unsigned is_static:1;	/* Static binary? */
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned partial_activation:1;
@@ -95,7 +94,7 @@
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(unsigned is_static, unsigned is_long_lived);
+struct cmd_context *create_toolcontext(unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
--- LVM2/lib/locking/locking.c	2008/11/04 15:07:44	1.53
+++ LVM2/lib/locking/locking.c	2008/12/18 05:27:18	1.54
@@ -228,7 +228,7 @@
 
 #ifdef HAVE_LIBDL
 	case 2:
-		if (!cmd->is_static) {
+		if (!is_static()) {
 			log_very_verbose("External locking selected.");
 			if (init_external_locking(&_locking, cmd))
 				return 1;
--- LVM2/lib/misc/lvm-globals.c	2008/10/30 17:39:00	1.1
+++ LVM2/lib/misc/lvm-globals.c	2008/12/18 05:27:18	1.2
@@ -38,6 +38,7 @@
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
+static unsigned _is_static = 0;
 
 void init_verbose(int level)
 {
@@ -106,6 +107,11 @@
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
@@ -199,3 +205,8 @@
 {
 	return _debug_level;
 }
+
+unsigned is_static(void)
+{
+	return _is_static;
+}
--- LVM2/lib/misc/lvm-globals.h	2008/11/12 09:41:44	1.3
+++ LVM2/lib/misc/lvm-globals.h	2008/12/18 05:27:18	1.4
@@ -34,6 +34,7 @@
 void init_dmeventd_monitor(int reg);
 void init_ignore_suspended_devices(int ignore);
 void init_error_message_produced(int produced);
+void init_is_static(unsigned value);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -50,6 +51,7 @@
 int mirror_in_sync(void);
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
+unsigned is_static(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
--- LVM2/lib/misc/sharedlib.c	2008/01/30 14:00:00	1.15
+++ LVM2/lib/misc/sharedlib.c	2008/12/18 05:27:18	1.16
@@ -44,7 +44,7 @@
 	char path[PATH_MAX];
 	void *library;
 
-	if (cmd->is_static) {
+	if (is_static()) {
 		log_error("Not loading shared %s library %s in static mode.",
 			  desc, libname);
 		return NULL;
--- LVM2/tools/lvchange.c	2008/12/04 15:54:27	1.94
+++ LVM2/tools/lvchange.c	2008/12/18 05:27:18	1.95
@@ -597,7 +597,7 @@
 	}
 
 	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (cmd->is_static || arg_count(cmd, ignoremonitoring_ARG)) ?
+					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	/* access permission change */
--- LVM2/tools/lvm-static.c	2008/01/31 12:19:36	1.5
+++ LVM2/tools/lvm-static.c	2008/12/18 05:27:18	1.6
@@ -17,7 +17,8 @@
 
 int main(int argc, char **argv)
 {
-	return lvm2_main(argc, argv, 1);
+	init_is_static(1);
+	return lvm2_main(argc, argv);
 }
 
 int lvm_shell(struct cmd_context *cmd __attribute((unused)),
--- LVM2/tools/lvm.c	2008/06/06 19:28:35	1.109
+++ LVM2/tools/lvm.c	2008/12/18 05:27:18	1.110
@@ -18,7 +18,7 @@
 
 int main(int argc, char **argv)
 {
-	return lvm2_main(argc, argv, 0);
+	return lvm2_main(argc, argv);
 }
 
 #ifdef READLINE_SUPPORT
--- LVM2/tools/lvm2cmdline.h	2007/08/20 20:55:30	1.6
+++ LVM2/tools/lvm2cmdline.h	2008/12/18 05:27:18	1.7
@@ -26,12 +26,12 @@
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
--- LVM2/tools/lvmcmdlib.c	2008/06/23 09:27:45	1.7
+++ LVM2/tools/lvmcmdlib.c	2008/12/18 05:27:18	1.8
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
--- LVM2/tools/lvmcmdline.c	2008/12/17 16:46:45	1.89
+++ LVM2/tools/lvmcmdline.c	2008/12/18 05:27:18	1.90
@@ -1147,13 +1147,13 @@
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
@@ -1272,7 +1272,7 @@
 		log_warn("WARNING: Running as a non-root user. Functionality may be unavailable.");
 }
 
-int lvm2_main(int argc, char **argv, unsigned is_static)
+int lvm2_main(int argc, char **argv)
 {
 	const char *base;
 	int ret, alias = 0;
@@ -1285,7 +1285,7 @@
 
 	_close_stray_fds(base);
 
-	if (is_static && strcmp(base, "lvm.static") &&
+	if (is_static() && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_SHARED_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {
 		setenv("LVM_DID_EXEC", base, 1);
@@ -1293,7 +1293,7 @@
 		unsetenv("LVM_DID_EXEC");
 	}
 
-	if (!(cmd = init_lvm(is_static)))
+	if (!(cmd = init_lvm()))
 		return -1;
 
 	cmd->argv = argv;
--- LVM2/tools/vgchange.c	2008/11/03 22:14:30	1.66
+++ LVM2/tools/vgchange.c	2008/12/18 05:27:18	1.67
@@ -540,7 +540,7 @@
 	}
 
 	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (cmd->is_static || arg_count(cmd, ignoremonitoring_ARG)) ?
+					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	if (arg_count(cmd, available_ARG))


