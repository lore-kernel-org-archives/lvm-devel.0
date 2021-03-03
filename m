From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 Mar 2021 20:00:49 +0000 (GMT)
Subject: main - lvmlockctl: use lvm.conf lvmlockctl_kill_command
Message-ID: <20210303200049.77558384A029@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89a3440fc0179318954855aa251b0aae4f5c1a63
Commit:        89a3440fc0179318954855aa251b0aae4f5c1a63
Parent:        e9d10f371199055e9ed0c2715b5353491cb759b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 1 15:22:54 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 3 13:57:15 2021 -0600

lvmlockctl: use lvm.conf lvmlockctl_kill_command

which specifies a command to run by lvmlockctl --kill.
---
 configure                     |   3 +
 configure.ac                  |   2 +
 daemons/lvmlockd/lvmlockctl.c | 197 +++++++++++++++++++++++++++++++++---------
 include/configure.h.in        |   3 +
 lib/config/config_settings.h  |   9 ++
 man/lvmlockctl.8_main         |  14 +--
 6 files changed, 180 insertions(+), 48 deletions(-)

diff --git a/configure b/configure
index 4c38cbebb..b84a20144 100755
--- a/configure
+++ b/configure
@@ -693,6 +693,7 @@ MANGLING
 LVM_RELEASE_DATE
 LVM_RELEASE
 LVM_PATH
+LVM_DIR
 LVM_PATCHLEVEL
 LVM_MINOR
 LVM_MAJOR
@@ -13766,9 +13767,11 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
+LVM_DIR="$SBINDIR/"
 
 cat >>confdefs.h <<_ACEOF
 #define LVM_PATH "$LVM_PATH"
+#define LVM_DIR "$LVM_DIR"
 _ACEOF
 
 
diff --git a/configure.ac b/configure.ac
index ee21b879d..93f91384d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1607,7 +1607,9 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
+LVM_DIR="$SBINDIR/"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
+AC_DEFINE_UNQUOTED(LVM_DIR, ["$LVM_DIR"], [Path to lvm binary dir.])
 
 LVMCONFIG_PATH="$SBINDIR/lvmconfig"
 AC_DEFINE_UNQUOTED(LVMCONFIG_PATH, ["$LVMCONFIG_PATH"], [Path to lvmconfig binary.])
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index c2a998c8c..34ae081ad 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -30,6 +30,7 @@ static int kill_vg = 0;
 static int drop_vg = 0;
 static int gl_enable = 0;
 static int gl_disable = 0;
+static int use_stderr = 0;
 static int stop_lockspaces = 0;
 static char *arg_vg_name = NULL;
 
@@ -47,6 +48,22 @@ do { \
 	printf(fmt "\n", ##args); \
 } while (0)
 
+#define log_sys_emerg(fmt, args...) \
+do { \
+	if (use_stderr) \
+		fprintf(stderr, fmt "\n", ##args); \
+	else \
+		syslog(LOG_EMERG, fmt, ##args); \
+} while (0)
+
+#define log_sys_warn(fmt, args...) \
+do { \
+	if (use_stderr) \
+		fprintf(stderr, fmt "\n", ##args); \
+	else \
+		syslog(LOG_WARNING, fmt, ##args); \
+} while (0)
+
 #define MAX_LINE 512
 
 /* copied from lvmlockd-internal.h */
@@ -502,25 +519,82 @@ static int do_stop_lockspaces(void)
 	return rv;
 }
 
-static int do_kill(void)
+/* Returns -1 on error, 0 on success. */
+
+static int _get_kill_command(char *kill_cmd)
+{
+	char config_cmd[PATH_MAX] = { 0 };
+	char config_val[1024] = { 0 };
+	char line[PATH_MAX] = { 0 };
+	char type[4] = { 0 };
+	FILE *fp;
+
+	snprintf(config_cmd, PATH_MAX, "%s/lvmconfig --typeconfig full global/lvmlockctl_kill_command", LVM_DIR);
+	type[0] = 'r';
+
+	if (!(fp = popen(config_cmd, type))) {
+		log_error("failed to run %s", config_cmd);
+		return -1;
+	}
+
+	if (!fgets(line, sizeof(line), fp)) {
+		log_error("no output from %s", config_cmd);
+		goto bad;
+	}
+
+	if (sscanf(line, "lvmlockctl_kill_command=\"%256[^\n\"]\"", config_val) != 1) {
+		log_error("unrecognized config value from %s", config_cmd);
+		goto bad;
+	}
+
+	if (!config_val[0] || (config_val[0] == ' ')) {
+		log_error("invalid config value from %s", config_cmd);
+		goto bad;
+	}
+
+	printf("Found lvmlockctl_kill_command: %s\n", config_val);
+
+	snprintf(kill_cmd, PATH_MAX, "%s %s", config_val, arg_vg_name);
+
+	pclose(fp);
+	return 0;
+bad:
+	pclose(fp);
+	return -1;
+}
+
+/* Returns -1 on error, 0 on success. */
+
+static int _run_kill_command(char *kill_cmd)
+{
+	int status;
+
+	status = system(kill_cmd);
+
+	if (!WEXITSTATUS(status))
+		return 0;
+
+	return -1;
+}
+
+static int do_drop(void)
 {
 	daemon_reply reply;
 	int result;
 	int rv;
 
-	syslog(LOG_EMERG, "Lost access to sanlock lease storage in VG %s.", arg_vg_name);
-	/* These two lines explain the manual alternative to the FIXME below. */
-	syslog(LOG_EMERG, "Immediately deactivate LVs in VG %s.", arg_vg_name);
-	syslog(LOG_EMERG, "Once VG is unused, run lvmlockctl --drop %s.", arg_vg_name);
+	log_sys_warn("Dropping locks for VG %s.", arg_vg_name);
 
 	/*
-	 * It may not be strictly necessary to notify lvmlockd of the kill, but
-	 * lvmlockd can use this information to avoid attempting any new lock
-	 * requests in the VG (which would fail anyway), and can return an
-	 * error indicating that the VG has been killed.
+	 * Check for misuse by looking for any active LVs in the VG
+	 * and refusing this operation if found?  One possible way
+	 * to kill LVs (e.g. if fs cannot be unmounted) is to suspend
+	 * them, or replace them with the error target.  In that
+	 * case the LV will still appear to be active, but it is
+	 * safe to release the lock.
 	 */
 
-	reply = _lvmlockd_send("kill_vg",
+	reply = _lvmlockd_send("drop_vg",
 				"cmd = %s", "lvmlockctl",
 				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", arg_vg_name,
@@ -534,52 +608,84 @@ static int do_kill(void)
 	}
 
 	daemon_reply_destroy(reply);
-
-	/*
-	 * FIXME: here is where we should implement a strong form of
-	 * blkdeactivate, and if it completes successfully, automatically call
-	 * do_drop() afterward.  (The drop step may not always be necessary
-	 * if the lvm commands run while shutting things down release all the
-	 * leases.)
-	 *
-	 * run_strong_blkdeactivate();
-	 * do_drop();
-	 */
-
 	return rv;
 }
 
-static int do_drop(void)
+static int do_kill(void)
 {
+	char kill_cmd[PATH_MAX] = { 0 };
 	daemon_reply reply;
+	int no_kill_command = 0;
 	int result;
 	int rv;
 
-	syslog(LOG_WARNING, "Dropping locks for VG %s.", arg_vg_name);
+	log_sys_emerg("lvmlockd lost access to locks in VG %s.", arg_vg_name);
+
+	rv = _get_kill_command(kill_cmd);
+	if (rv < 0) {
+		log_sys_emerg("Immediately deactivate LVs in VG %s.", arg_vg_name);
+		log_sys_emerg("Once VG is unused, run lvmlockctl --drop %s.", arg_vg_name);
+		no_kill_command = 1;
+	}
 
 	/*
-	 * Check for misuse by looking for any active LVs in the VG
-	 * and refusing this operation if found?  One possible way
-	 * to kill LVs (e.g. if fs cannot be unmounted) is to suspend
-	 * them, or replace them with the error target.  In that
-	 * case the LV will still appear to be active, but it is
-	 * safe to release the lock.
+	 * It may not be strictly necessary to notify lvmlockd of the kill, but
+	 * lvmlockd can use this information to avoid attempting any new lock
+	 * requests in the VG (which would fail anyway), and can return an
+	 * error indicating that the VG has been killed.
 	 */
+	_lvmlockd = lvmlockd_open(NULL);
+	if (_lvmlockd.socket_fd < 0 || _lvmlockd.error) {
+		log_error("Cannot connect to lvmlockd for kill_vg.");
+		goto run;
+	}
+	reply = _lvmlockd_send("kill_vg",
+				"cmd = %s", "lvmlockctl",
+				"pid = " FMTd64, (int64_t) getpid(),
+				"vg_name = %s", arg_vg_name,
+				NULL);
+	if (!_lvmlockd_result(reply, &result))
+		log_error("lvmlockd result %d kill_vg", result);
+	daemon_reply_destroy(reply);
+	lvmlockd_close(_lvmlockd);
 
+ run:
+	if (no_kill_command)
+		return 0;
+
+	rv = _run_kill_command(kill_cmd);
+	if (rv < 0) {
+		log_sys_emerg("Failed to run VG %s kill command %s", arg_vg_name, kill_cmd);
+		log_sys_emerg("Immediately deactivate LVs in VG %s.", arg_vg_name);
+		log_sys_emerg("Once VG is unused, run lvmlockctl --drop %s.", arg_vg_name);
+		return -1;
+	}
+
+	log_sys_warn("Successful VG %s kill command %s", arg_vg_name, kill_cmd);
+
+	/*
+	 * If kill command was successfully, call do_drop().  (The drop step
+	 * may not always be necessary if the lvm commands run while shutting
+	 * things down release all the leases.)
+	 */
+	rv = 0;
+	_lvmlockd = lvmlockd_open(NULL);
+	if (_lvmlockd.socket_fd < 0 || _lvmlockd.error) {
+		log_sys_emerg("Failed to connect to lvmlockd to drop locks in VG %s.", arg_vg_name);
+		return -1;
+	}
 	reply = _lvmlockd_send("drop_vg",
 				"cmd = %s", "lvmlockctl",
 				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", arg_vg_name,
 				NULL);
-
 	if (!_lvmlockd_result(reply, &result)) {
-		log_error("lvmlockd result %d", result);
+		log_sys_emerg("Failed to drop locks in VG %s", arg_vg_name);
 		rv = result;
-	} else {
-		rv = 0;
 	}
-
 	daemon_reply_destroy(reply);
+	lvmlockd_close(_lvmlockd);
+
 	return rv;
 }
 
@@ -600,7 +706,7 @@ static void print_usage(void)
 	printf("--force | -f 0|1>\n");
 	printf("      Force option for other commands.\n");
 	printf("--kill | -k <vgname>\n");
-	printf("      Kill access to the VG when sanlock cannot renew lease.\n");
+	printf("      Kill access to the VG locks are lost (see lvmlockctl_kill_command).\n");
 	printf("--drop | -r <vgname>\n");
 	printf("      Clear locks for the VG when it is unused after kill (-k).\n");
 	printf("--gl-enable | -E <vgname>\n");
@@ -609,6 +715,8 @@ static void print_usage(void)
 	printf("      Tell lvmlockd to disable the global lock in a sanlock VG.\n");
 	printf("--stop-lockspaces | -S\n");
 	printf("      Stop all lockspaces.\n");
+	printf("--stderr | -e\n");
+	printf("      Send kill and drop messages to stderr instead of syslog\n");
 }
 
 static int read_options(int argc, char *argv[])
@@ -628,6 +736,7 @@ static int read_options(int argc, char *argv[])
 		{"gl-enable",       required_argument, 0,  'E' },
 		{"gl-disable",      required_argument, 0,  'D' },
 		{"stop-lockspaces", no_argument,       0,  'S' },
+		{"stderr",          no_argument,       0,  'e' },
 		{0, 0, 0, 0 }
 	};
 
@@ -637,7 +746,7 @@ static int read_options(int argc, char *argv[])
 	}
 
 	while (1) {
-		c = getopt_long(argc, argv, "hqidE:D:w:k:r:S", long_options, &option_index);
+		c = getopt_long(argc, argv, "hqidE:D:w:k:r:Se", long_options, &option_index);
 		if (c == -1)
 			break;
 
@@ -680,6 +789,9 @@ static int read_options(int argc, char *argv[])
 		case 'S':
 			stop_lockspaces = 1;
 			break;
+		case 'e':
+			use_stderr = 1;
+			break;
 		default:
 			print_usage();
 			exit(1);
@@ -698,8 +810,12 @@ int main(int argc, char **argv)
 	if (rv < 0)
 		return rv;
 
-	_lvmlockd = lvmlockd_open(NULL);
+	/* do_kill handles lvmlockd connections itself */
+	if (kill_vg)
+		return do_kill();
+
 
+	_lvmlockd = lvmlockd_open(NULL);
 	if (_lvmlockd.socket_fd < 0 || _lvmlockd.error) {
 		log_error("Cannot connect to lvmlockd.");
 		return -1;
@@ -720,11 +836,6 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	if (kill_vg) {
-		rv = do_kill();
-		goto out;
-	}
-
 	if (drop_vg) {
 		rv = do_drop();
 		goto out;
diff --git a/include/configure.h.in b/include/configure.h.in
index 59b4da86f..2597651e3 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -586,6 +586,9 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
+/* Path to lvm binary dir. */
+#undef LVM_DIR
+
 /* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
    */
 #undef MAJOR_IN_MKDEV
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f04b435fb..fac5d6317 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1152,6 +1152,15 @@ cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_D
 	"and can cause lvcreate to fail. Applicable only if LVM is compiled\n"
 	"with lockd support\n")
 
+cfg(global_lvmlockctl_kill_command_CFG, "lvmlockctl_kill_command", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "", vsn(2, 3, 12), NULL, 0, NULL,
+	"The command that lvmlockctl --kill should use to force LVs offline.\n"
+	"The lvmlockctl --kill command is run when a shared VG has lost\n"
+	"access to locks (e.g. when sanlock has lost access to storage.)\n"
+	"An empty string means that there will be no automatic attempt by\n"
+	"lvmlockctl --kill to forcibly shut down LVs in the VG, and the user\n"
+	"can manually intervene as described in lvmlockd(8).\n"
+	"The VG name will be appended to the command specified here.\n")
+
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
 	"LVM uses this command to check that a thin metadata device is in a\n"
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index b7ac0ecd6..14ce926b5 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -65,17 +65,21 @@ and prints it.
 .SS kill
 
 This is run by sanlock when it loses access to the storage holding leases
-for a VG.  It currently emits a syslog message stating that the VG must
-be immediately deactivated.  In the future it may automatically attempt to
-forcibly deactivate the VG.  For more, see
+for a VG.  It runs the command specified in lvm.conf
+lvmlockctl_kill_command to deactivate LVs in the VG.  If the specified
+command is successful, locks will be dropped for the VG in lvmlockd
+(the equivalent of lvmlockctl --drop will be run.)  If no command
+is specified, or the command fails, then the user must intervene
+to forcefully deactivate LVs in the VG, and if successful, run
+lvmlockctl --drop.  For more, see
 .BR lvmlockd (8).
 
 .SS drop
 
 This should only be run after a VG has been successfully deactivated
 following an lvmlockctl --kill command.  It clears the stale lockspace
-from lvmlockd.  In the future, this may become automatic along with an
-automatic handling of --kill.  For more, see
+from lvmlockd.  When lvmlockctl_kill_command is used, the --kill
+command may run drop automatically.  For more, see
 .BR lvmlockd (8).
 
 .SS gl-enable


