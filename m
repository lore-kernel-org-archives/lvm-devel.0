From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 Mar 2021 23:44:15 +0000 (GMT)
Subject: main - lvmlockctl: replace popen and system
Message-ID: <20210303234415.BDDE73857832@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5fbb1b76fc39fe968d847247b9040ff2acbadcc
Commit:        f5fbb1b76fc39fe968d847247b9040ff2acbadcc
Parent:        89a3440fc0179318954855aa251b0aae4f5c1a63
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 3 17:36:42 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 3 17:43:29 2021 -0600

lvmlockctl: replace popen and system

with fork and exec to avoid use of shell.
largely copied from lib/misc/lvm-exec.c

require lvmlockctl_kill_command to be full path

use lvm config instead of lvmconfig to avoid need for LVM_DIR
---
 configure                     |   3 -
 configure.ac                  |   2 -
 daemons/lvmlockd/lvmlockctl.c | 241 +++++++++++++++++++++++++++++++++++++++---
 include/configure.h.in        |   3 -
 4 files changed, 228 insertions(+), 21 deletions(-)

diff --git a/configure b/configure
index b84a20144..4c38cbebb 100755
--- a/configure
+++ b/configure
@@ -693,7 +693,6 @@ MANGLING
 LVM_RELEASE_DATE
 LVM_RELEASE
 LVM_PATH
-LVM_DIR
 LVM_PATCHLEVEL
 LVM_MINOR
 LVM_MAJOR
@@ -13767,11 +13766,9 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
-LVM_DIR="$SBINDIR/"
 
 cat >>confdefs.h <<_ACEOF
 #define LVM_PATH "$LVM_PATH"
-#define LVM_DIR "$LVM_DIR"
 _ACEOF
 
 
diff --git a/configure.ac b/configure.ac
index 93f91384d..ee21b879d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1607,9 +1607,7 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
-LVM_DIR="$SBINDIR/"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
-AC_DEFINE_UNQUOTED(LVM_DIR, ["$LVM_DIR"], [Path to lvm binary dir.])
 
 LVMCONFIG_PATH="$SBINDIR/lvmconfig"
 AC_DEFINE_UNQUOTED(LVMCONFIG_PATH, ["$LVMCONFIG_PATH"], [Path to lvmconfig binary.])
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 34ae081ad..350e78e9a 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -18,8 +18,11 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <syslog.h>
+#include <ctype.h>
 #include <sys/socket.h>
 #include <sys/un.h>
+#include <unistd.h>
+#include <sys/wait.h>
 
 static int quit = 0;
 static int info = 0;
@@ -519,24 +522,224 @@ static int do_stop_lockspaces(void)
 	return rv;
 }
 
+static int _reopen_fd_to_null(int fd)
+{
+	int null_fd;
+	int r = 0;
+
+	if ((null_fd = open("/dev/null", O_RDWR)) == -1) {
+		log_error("open error /dev/null %d", errno);
+		return 0;
+	}
+
+	if (close(fd)) {
+		log_error("close error fd %d %d", fd, errno);
+		goto out;
+	}
+
+	if (dup2(null_fd, fd) == -1) {
+		log_error("dup2 error %d", errno);
+		goto out;
+	}
+
+	r = 1;
+out:
+	if (close(null_fd)) {
+		log_error("close error fd %d %d", null_fd, errno);
+		return 0;
+	}
+
+	return r;
+}
+
+#define MAX_AV_COUNT 32
+#define ONE_ARG_LEN 1024
+
+static void _run_command_pipe(const char *cmd_str, pid_t *pid_out, FILE **fp_out)
+{
+	char arg[ONE_ARG_LEN];
+	char *av[MAX_AV_COUNT + 1]; /* +1 for NULL */
+	char *arg_dup;
+	int av_count = 0;
+	int cmd_len;
+	int arg_len;
+	pid_t pid = 0;
+	FILE *fp = NULL;
+	int pipefd[2];
+	int i;
+
+	for (i = 0; i < MAX_AV_COUNT + 1; i++)
+		av[i] = NULL;
+
+	cmd_len = strlen(cmd_str);
+
+	memset(&arg, 0, sizeof(arg));
+	arg_len = 0;
+
+	for (i = 0; i < cmd_len; i++) {
+		if (!cmd_str[i])
+			break;
+
+		if (av_count == MAX_AV_COUNT)
+			goto out;
+
+		if (cmd_str[i] == '\\') {
+			if (i == (cmd_len - 1))
+				break;
+			i++;
+
+			if (cmd_str[i] == '\\') {
+				arg[arg_len++] = cmd_str[i];
+				continue;
+			}
+			if (isspace(cmd_str[i])) {
+				arg[arg_len++] = cmd_str[i];
+				continue;
+			} else {
+				break;
+			}
+		}
+
+		if (isalnum(cmd_str[i]) || ispunct(cmd_str[i])) {
+			arg[arg_len++] = cmd_str[i];
+		} else if (isspace(cmd_str[i])) {
+			if (arg_len) {
+				if (!(arg_dup = strdup(arg)))
+					goto out;
+				av[av_count++] = arg_dup;
+			}
+
+			memset(arg, 0, sizeof(arg));
+			arg_len = 0;
+		} else {
+			break;
+		}
+	}
+
+	if (arg_len) {
+		if (av_count >= MAX_AV_COUNT)
+			goto out;
+		if (!(arg_dup = strdup(arg)))
+			goto out;
+		av[av_count++] = arg_dup;
+	}
+
+	if (pipe(pipefd)) {
+		log_error("pipe error %d", errno);
+		goto out;
+	}
+
+	pid = fork();
+
+	if (pid < 0) {
+		log_error("fork error %d", errno);
+		pid = 0;
+		goto out;
+	}
+
+	if (pid == 0) {
+		/* Child -> writer, convert pipe[0] to STDOUT */
+		if (!_reopen_fd_to_null(STDIN_FILENO))
+			log_error("reopen STDIN error");
+		else if (close(pipefd[0 /*read*/]))
+			log_error("close error pipe[0] %d", errno);
+		else if (close(STDOUT_FILENO))
+			log_error("close error STDOUT %d", errno);
+		else if (dup2(pipefd[1 /*write*/], STDOUT_FILENO) == -1)
+			log_error("dup2 error STDOUT %d", errno);
+		else if (close(pipefd[1]))
+			log_error("close error pipe[1] %d", errno);
+		else {
+			execvp(av[0], av);
+			log_error("execvp error %d", errno);
+		}
+		_exit(errno);
+	}
+
+	/* Parent -> reader */
+	if (close(pipefd[1 /*write*/]))
+		log_error("close error STDOUT %d", errno);
+
+	if (!(fp = fdopen(pipefd[0 /*read*/],  "r"))) {
+		log_error("fdopen STDIN error %d", errno);
+		if (close(pipefd[0]))
+			log_error("close error STDIN %d", errno);
+	}
+
+ out:
+	for (i = 0; i < MAX_AV_COUNT + 1; i++)
+		free(av[i]);
+
+	*pid_out = pid;
+	*fp_out = fp;
+}
+
+/* Returns -1 on error, 0 on success. */
+
+static int _close_command_pipe(pid_t pid, FILE *fp)
+{
+	int status, estatus;
+	int ret = -1;
+
+	if (waitpid(pid, &status, 0) != pid) {
+		log_error("waitpid error pid %d %d", pid, errno);
+		goto out;
+	}
+
+	if (WIFEXITED(status)) {
+		/* pid exited with an exit code */
+		estatus = WEXITSTATUS(status);
+
+		/* exit status 0: child success */
+		if (!estatus) {
+			ret = 0;
+			goto out;
+		}
+
+		/* exit status not zero: child error */
+		log_error("child exit error %d", estatus);
+		goto out;
+	}
+
+	if (WIFSIGNALED(status)) {
+		/* pid terminated due to a signal */
+		log_error("child exit from signal");
+		goto out;
+	}
+
+	log_error("child exit problem");
+
+out:
+	if (fp && fclose(fp))
+		log_error("fclose error STDIN %d", errno);
+	return ret;
+}
+
 /* Returns -1 on error, 0 on success. */
 
 static int _get_kill_command(char *kill_cmd)
 {
-	char config_cmd[PATH_MAX] = { 0 };
+	char config_cmd[PATH_MAX + 128] = { 0 };
 	char config_val[1024] = { 0 };
 	char line[PATH_MAX] = { 0 };
-	char type[4] = { 0 };
-	FILE *fp;
+	pid_t pid = 0;
+	FILE *fp = NULL;
 
-	snprintf(config_cmd, PATH_MAX, "%s/lvmconfig --typeconfig full global/lvmlockctl_kill_command", LVM_DIR);
-	type[0] = 'r';
+	snprintf(config_cmd, PATH_MAX, "%s config --typeconfig full global/lvmlockctl_kill_command", LVM_PATH);
 
-	if (!(fp = popen(config_cmd, type))) {
+	_run_command_pipe(config_cmd, &pid, &fp);
+
+	if (!pid) {
 		log_error("failed to run %s", config_cmd);
 		return -1;
 	}
 
+	if (!fp) {
+		log_error("failed to get output %s", config_cmd);
+		_close_command_pipe(pid, fp);
+		return -1;
+	}
+
 	if (!fgets(line, sizeof(line), fp)) {
 		log_error("no output from %s", config_cmd);
 		goto bad;
@@ -552,14 +755,20 @@ static int _get_kill_command(char *kill_cmd)
 		goto bad;
 	}
 
+	if (config_val[0] != '/') {
+		log_error("lvmlockctl_kill_command must be full path");
+		goto bad;
+	}
+
 	printf("Found lvmlockctl_kill_command: %s\n", config_val);
 
 	snprintf(kill_cmd, PATH_MAX, "%s %s", config_val, arg_vg_name);
+	kill_cmd[PATH_MAX-1] = '\0';
 
-	pclose(fp);
+	_close_command_pipe(pid, fp);
 	return 0;
 bad:
-	pclose(fp);
+	_close_command_pipe(pid, fp);
 	return -1;
 }
 
@@ -567,14 +776,20 @@ bad:
 
 static int _run_kill_command(char *kill_cmd)
 {
-	int status;
+	pid_t pid = 0;
+	FILE *fp = NULL;
+	int rv;
 
-	status = system(kill_cmd);
+	_run_command_pipe(kill_cmd, &pid, &fp);
+	rv = _close_command_pipe(pid, fp);
 
-	if (!WEXITSTATUS(status))
-		return 0;
+	if (!pid)
+		return -1;
 
-	return -1;
+	if (rv < 0)
+		return -1;
+
+	return 0;
 }
 
 static int do_drop(void)
diff --git a/include/configure.h.in b/include/configure.h.in
index 2597651e3..59b4da86f 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -586,9 +586,6 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
-/* Path to lvm binary dir. */
-#undef LVM_DIR
-
 /* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
    */
 #undef MAJOR_IN_MKDEV


