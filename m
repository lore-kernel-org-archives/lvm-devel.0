From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:09 +0000 (GMT)
Subject: stable-2.02 - lvmcmdlib: lvm2_init_threaded
Message-ID: <20201020212509.EFED9394741A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=511cd6adb7756301ca0a2c2b153696a71a3f4423
Commit:        511cd6adb7756301ca0a2c2b153696a71a3f4423
Parent:        f0913c6482c8be53221540f6fa4b82f0eda264ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 22:22:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:49:18 2020 +0200

lvmcmdlib:  lvm2_init_threaded

cmd context has 'threaded' value that used be set
by clvmd - and allowed proper memory locking management.
Reuse same bit for dmeventd.

Since dmeventd is using 300KiB stack per thread,
we will ignore any user settings for allocation/reserved_stack
until some better solution is find.
This avoids crashing of dmevend when user changes this value
and because in most cases lvm2 should work ok with 64K stack
size, this change should not cause any problems.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c | 2 +-
 tools/lvm2cmd-static.c                       | 7 ++++++-
 tools/lvm2cmd.c                              | 7 ++++++-
 tools/lvm2cmd.h                              | 6 ++++++
 tools/lvm2cmdline.h                          | 4 ++--
 tools/lvmcmdlib.c                            | 4 ++--
 tools/lvmcmdline.c                           | 8 +++++---
 7 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index be58aaceb..5c5286700 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -71,7 +71,7 @@ int dmeventd_lvm2_init(void)
 	if (!_lvm_handle) {
 		lvm2_log_fn(_lvm2_print_log);
 
-		if (!(_lvm_handle = lvm2_init()))
+		if (!(_lvm_handle = lvm2_init_threaded()))
 			goto out;
 
 		/*
diff --git a/tools/lvm2cmd-static.c b/tools/lvm2cmd-static.c
index 4fb109c0a..31c75159e 100644
--- a/tools/lvm2cmd-static.c
+++ b/tools/lvm2cmd-static.c
@@ -17,5 +17,10 @@
 
 void *lvm2_init(void)
 {
-	return cmdlib_lvm2_init(1);
+	return cmdlib_lvm2_init(1, 0);
+}
+
+void *lvm2_init_threaded(void)
+{
+	return cmdlib_lvm2_init(1, 1);
 }
diff --git a/tools/lvm2cmd.c b/tools/lvm2cmd.c
index 235540c8a..aca3e6569 100644
--- a/tools/lvm2cmd.c
+++ b/tools/lvm2cmd.c
@@ -17,7 +17,12 @@
 
 void *lvm2_init(void)
 {
-	return cmdlib_lvm2_init(0);
+	return cmdlib_lvm2_init(0, 0);
+}
+
+void *lvm2_init_threaded(void)
+{
+	return cmdlib_lvm2_init(0, 1);
 }
 
 int lvm_shell(struct cmd_context *cmd __attribute__((unused)),
diff --git a/tools/lvm2cmd.h b/tools/lvm2cmd.h
index cd2e0ec9d..39a8d6036 100644
--- a/tools/lvm2cmd.h
+++ b/tools/lvm2cmd.h
@@ -58,6 +58,12 @@ void lvm2_log_fn(lvm2_log_fn_t log_fn);
  */ 
 void *lvm2_init(void);
 
+/*
+ * Initialise library for threaded user
+ * Returns a handle so repeated use of lvm2_run is more efficient.
+ */
+void *lvm2_init_threaded(void);
+
 /*
  * Disable any dmeventd calls that the library may otherwise do. Useful to avoid
  * recursive calls from dmeventd to itself.
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 0073f9025..84cab9359 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -28,10 +28,10 @@ struct cmdline_context {
 
 int lvm2_main(int argc, char **argv);
 
-void *cmdlib_lvm2_init(unsigned static_compile);
+void *cmdlib_lvm2_init(unsigned static_compile, unsigned threaded);
 void lvm_fin(struct cmd_context *cmd);
 
-struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters);
+struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters, unsigned threaded);
 int lvm_register_commands(struct cmd_context *cmdtool, const char *name);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 5944576ee..a2754ea34 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -26,12 +26,12 @@
 #include <time.h>
 #include <sys/resource.h>
 
-void *cmdlib_lvm2_init(unsigned static_compile)
+void *cmdlib_lvm2_init(unsigned static_compile, unsigned threaded)
 {
 	struct cmd_context *cmd;
 
 	init_is_static(static_compile);
-	if (!(cmd = init_lvm(1, 1)))
+	if (!(cmd = init_lvm(1, 1, threaded)))
 		return NULL;
 
 	if (!lvm_register_commands(cmd, NULL))
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0655a57a9..890aa0551 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3302,7 +3302,9 @@ static int _close_stray_fds(const char *command, struct custom_fds *custom_fds)
 	return 1;
 }
 
-struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
+struct cmd_context *init_lvm(unsigned set_connections,
+			     unsigned set_filters,
+			     unsigned threaded)
 {
 	struct cmd_context *cmd;
 
@@ -3316,7 +3318,7 @@ struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 	 */
 	dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
-	if (!(cmd = create_toolcontext(0, NULL, 1, 0,
+	if (!(cmd = create_toolcontext(0, NULL, 1, threaded,
 			set_connections, set_filters))) {
 		udev_fin_library_context();
 		return_NULL;
@@ -3470,7 +3472,7 @@ int lvm2_main(int argc, char **argv)
 	if (!alias && (argc > 2) && !strcmp(argv[2], "-?"))
 		argv[2] = (char *)"-h";
 
-	if (!(cmd = init_lvm(0, 0)))
+	if (!(cmd = init_lvm(0, 0, 0)))
 		return EINIT_FAILED;
 
 	/* Store original argv location so we may customise it if we become a daemon */


