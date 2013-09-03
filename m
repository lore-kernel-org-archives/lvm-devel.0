From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  3 Sep 2013 14:49:31 +0000 (UTC)
Subject: master - tools: add -b/--background for pvscan --cache -aay
Message-ID: <20130903144931.03B4760DCB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=008c33a21ba0e0fb27319b63c7bad8fb8136f804
Commit:        008c33a21ba0e0fb27319b63c7bad8fb8136f804
Parent:        ea1e8166d57c40a5406b68864e19056df6d2f103
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 3 16:06:16 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 3 16:49:21 2013 +0200

tools: add -b/--background for pvscan --cache -aay

Udev daemon has recently introduced a limit on the number of udev
processes (there was no limit before). This causes a problem
when calling pvscan --cache -aay in lvmetad udev rules which
is supposed to activate the volumes. This activation is itself
synced with udev and so it waits for the activation to complete
before the pvscan finishes. The event processing can't continue
until this pvscan call is finished.

But if we're at the limit with the udev process count, we can't
instatiate any more udev processes, all such events are queued
and so we can't process the lvm activation event for which the
pvscan is waiting.

Then we're in a deadlock since the udev process with the
pvscan --cache -aay call waits for the lvm activation udev
processing to complete, but that will never happen as there's
this limit hit with the number of udev processes.

The process with pvscan --cache -aay actually times out eventually
(3min or 30sec, depends on the version of udev).

This patch makes it possible to run the pvscan --cache -aay
in the background so the udev processing can continue and hence
we can avoid the deadlock mentioned above.
---
 WHATS_NEW                     |    2 +
 man/pvscan.8.in               |    4 ++
 tools/commands.h              |    5 ++-
 tools/lvmcmdline.c            |    8 ++++
 tools/polldaemon.c            |   76 +---------------------------------------
 tools/toollib.c               |   77 +++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h               |    2 +
 udev/69-dm-lvm-metad.rules.in |    2 +-
 8 files changed, 98 insertions(+), 78 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f1a9933..c87bce1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.101 - 
 ===================================
+  Use pvscan -b in udev rules to avoid a deadlock on udev process count limit.
+  Add pvscan -b/--background for the command to be processed in the background.
   Don't assume stdin file descriptor is readable.
   Avoid unlimited recursion when creating dtree containing inactive pvmove LV.
   Require exactly 3 arguments for lvm2-activation-generator. Remove defaults.
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 2246744..78ee3e2 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -19,6 +19,7 @@ pvscan \- scan all disks for physical volumes
 .RB [ \-h | \-\-help ]
 .B \-\-cache
 .RB [ \-a | \-\-activate " " \fIay ]
+.RB [ \-b | \-\-background ]
 .RB [ \-\-major
 .I major
 .B \-\-minor
@@ -51,6 +52,9 @@ activation/auto_activation_volume_list set in lvm.conf. If this list is not set,
 all volumes are considered for autoactivation. The autoactivation is not yet
 supported for logical volumes that are part of partial or clustered volume groups.
 .TP
+.BR \-b ", " \-\-background
+Run the command in the background.
+.TP
 .BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " ]..."
 Scan one or more devices and instruct the lvmetad daemon to update its cached
 state accordingly.  Called internally by udev rules.
diff --git a/tools/commands.h b/tools/commands.h
index f9f81c5..ef7848d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -724,6 +724,7 @@ xx(pvscan,
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
+   "\t[-b|--background]\n"
    "\t[--cache [-a|--activate ay] [ DevicePath | --major major --minor minor]...]\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
@@ -735,8 +736,8 @@ xx(pvscan,
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   activate_ARG, available_ARG, cache_ARG, exported_ARG,
-   ignorelockingfailure_ARG, major_ARG, minor_ARG,
+   activate_ARG, available_ARG, background_ARG, cache_ARG,
+   exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
    novolumegroup_ARG, partial_ARG, short_ARG, uuid_ARG)
 
 xx(segtypes,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a155d21..dc5d592 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1097,6 +1097,14 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	set_cmd_name(cmd->command->name);
 
+	if (arg_count(cmd, background_ARG)) {
+		if (!become_daemon(cmd, 1)) {
+			/* parent - quit immediately */
+			ret = ECMD_PROCESSED;
+			goto out;
+		}
+	}
+
 	if (arg_count(cmd, config_ARG))
 		if (!override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index c139d2b..0b00e93 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -16,80 +16,6 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lvm2cmdline.h"
-#include <signal.h>
-#include <sys/wait.h>
-
-static void _sigchld_handler(int sig __attribute__((unused)))
-{
-	while (wait4(-1, NULL, WNOHANG | WUNTRACED, NULL) > 0) ;
-}
-
-/*
- * returns:
- * -1 if the fork failed
- *  0 if the parent
- *  1 if the child
- */
-static int _become_daemon(struct cmd_context *cmd)
-{
-	static const char devnull[] = "/dev/null";
-	int null_fd;
-	pid_t pid;
-	struct sigaction act = {
-		{_sigchld_handler},
-		.sa_flags = SA_NOCLDSTOP,
-	};
-
-	log_verbose("Forking background process");
-
-	sigaction(SIGCHLD, &act, NULL);
-
-	sync_local_dev_names(cmd); /* Flush ops and reset dm cookie */
-
-	if ((pid = fork()) == -1) {
-		log_error("fork failed: %s", strerror(errno));
-		return -1;
-	}
-
-	/* Parent */
-	if (pid > 0)
-		return 0;
-
-	/* Child */
-	if (setsid() == -1)
-		log_error("Background process failed to setsid: %s",
-			  strerror(errno));
-
-	/* For poll debugging it's best to disable for compilation */
-#if 1
-	if ((null_fd = open(devnull, O_RDWR)) == -1) {
-		log_sys_error("open", devnull);
-		_exit(ECMD_FAILED);
-	}
-
-	if ((dup2(null_fd, STDIN_FILENO) < 0)  || /* reopen stdin */
-	    (dup2(null_fd, STDOUT_FILENO) < 0) || /* reopen stdout */
-	    (dup2(null_fd, STDERR_FILENO) < 0)) { /* reopen stderr */
-		log_sys_error("dup2", "redirect");
-		(void) close(null_fd);
-		_exit(ECMD_FAILED);
-	}
-
-	if (null_fd > STDERR_FILENO)
-		(void) close(null_fd);
-
-	init_verbose(VERBOSE_BASE_LEVEL);
-#endif
-	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
-
-	reset_locking();
-	if (!lvmcache_init())
-		/* FIXME Clean up properly here */
-		_exit(ECMD_FAILED);
-	dev_close_all();
-
-	return 1;
-}
 
 progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
@@ -340,7 +266,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	}
 
 	if (parms.background) {
-		daemon_mode = _become_daemon(cmd);
+		daemon_mode = become_daemon(cmd, 0);
 		if (daemon_mode == 0)
 			return ECMD_PROCESSED;	    /* Parent */
 		else if (daemon_mode == 1)
diff --git a/tools/toollib.c b/tools/toollib.c
index befd3b8..50c43d9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -15,12 +15,89 @@
 
 #include "tools.h"
 #include <sys/stat.h>
+#include <signal.h>
+#include <sys/wait.h>
 
 const char *command_name(struct cmd_context *cmd)
 {
 	return cmd->command->name;
 }
 
+static void _sigchld_handler(int sig __attribute__((unused)))
+{
+	while (wait4(-1, NULL, WNOHANG | WUNTRACED, NULL) > 0) ;
+}
+
+/*
+ * returns:
+ * -1 if the fork failed
+ *  0 if the parent
+ *  1 if the child
+ */
+int become_daemon(struct cmd_context *cmd, int skip_lvm)
+{
+	static const char devnull[] = "/dev/null";
+	int null_fd;
+	pid_t pid;
+	struct sigaction act = {
+		{_sigchld_handler},
+		.sa_flags = SA_NOCLDSTOP,
+	};
+
+	log_verbose("Forking background process");
+
+	sigaction(SIGCHLD, &act, NULL);
+
+	if (!skip_lvm)
+		sync_local_dev_names(cmd); /* Flush ops and reset dm cookie */
+
+	if ((pid = fork()) == -1) {
+		log_error("fork failed: %s", strerror(errno));
+		return -1;
+	}
+
+	/* Parent */
+	if (pid > 0)
+		return 0;
+
+	/* Child */
+	if (setsid() == -1)
+		log_error("Background process failed to setsid: %s",
+			  strerror(errno));
+
+	/* For poll debugging it's best to disable for compilation */
+#if 1
+	if ((null_fd = open(devnull, O_RDWR)) == -1) {
+		log_sys_error("open", devnull);
+		_exit(ECMD_FAILED);
+	}
+
+	if ((dup2(null_fd, STDIN_FILENO) < 0)  || /* reopen stdin */
+	    (dup2(null_fd, STDOUT_FILENO) < 0) || /* reopen stdout */
+	    (dup2(null_fd, STDERR_FILENO) < 0)) { /* reopen stderr */
+		log_sys_error("dup2", "redirect");
+		(void) close(null_fd);
+		_exit(ECMD_FAILED);
+	}
+
+	if (null_fd > STDERR_FILENO)
+		(void) close(null_fd);
+
+	init_verbose(VERBOSE_BASE_LEVEL);
+#endif
+	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
+
+	if (!skip_lvm) {
+		reset_locking();
+		if (!lvmcache_init())
+			/* FIXME Clean up properly here */
+			_exit(ECMD_FAILED);
+	}
+	dev_close_all();
+
+	return 1;
+}
+
 /*
  * Strip dev_dir if present
  */
diff --git a/tools/toollib.h b/tools/toollib.h
index cfcb934..cd9ca49 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -18,6 +18,8 @@
 
 #include "metadata-exported.h"
 
+int become_daemon(struct cmd_context *cmd, int skip_lvm);
+
 int autobackup_set(void);
 int autobackup_init(const char *backup_dir, int keep_days, int keep_number,
 		    int autobackup);
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 2d6720e..6162e26 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -34,6 +34,6 @@ KERNEL!="dm-[0-9]*", ACTION!="add", GOTO="lvm_end"
 KERNEL=="dm-[0-9]*", ENV{DM_ACTIVATION}!="1", GOTO="lvm_end"
 
 LABEL="lvm_scan"
-RUN+="(LVM_EXEC)/lvm pvscan --cache --activate ay --major $major --minor $minor"
+RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor"
 
 LABEL="lvm_end"


