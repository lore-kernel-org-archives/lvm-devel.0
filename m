From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:23:10 +0000 (UTC)
Subject: master - exec: pipe open
Message-ID: <20130806142310.658BA60E80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6dd5a294b9beaf1d3ef68385eeeb8d55ec3a344
Commit:        f6dd5a294b9beaf1d3ef68385eeeb8d55ec3a344
Parent:        b6437a61806bdec29951eb80616db121c4ec4eff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 6 14:27:37 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 6 16:18:43 2013 +0200

exec: pipe open

Function replaces popen() system and avoids shell execution
and argument parsing (no surprices).
---
 WHATS_NEW           |    1 +
 lib/misc/lvm-exec.c |   99 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/misc/lvm-exec.h |   30 +++++++++++++++
 3 files changed, 130 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5baa00d..5284145 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Add pipe_open/close() to replace less secure popen() glibc call.
   Fix metadata area offset/size overflow if it's >= 4g and while using lvmetad.
   Inherit and apply any profile attached to a VG if creating new thin pool.
   Add initial support thin pool lvconvert --repair.
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 2f0f5ca..4cecfa3 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -107,3 +107,102 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 
 	return 1;
 }
+
+static int _reopen_fd_to_null(int fd)
+{
+	int null_fd;
+
+	if ((null_fd = open("/dev/null", O_RDWR)) == -1) {
+		log_sys_error("open", "/dev/null");
+		return 0;
+	}
+
+	if (close(fd)) {
+		log_sys_error("close", "");
+		return 0;
+	}
+
+	if (dup2(null_fd, fd) == -1) {
+		log_sys_error("dup2", "");
+		return 0;
+	}
+
+	if (close(null_fd)) {
+		log_sys_error("dup2", "");
+		return 0;
+	}
+
+	return 1;
+}
+
+FILE *pipe_open(struct cmd_context *cmd, const char *const argv[],
+		int sync_needed, struct pipe_data *pdata)
+{
+	int pipefd[2];
+	char buf[PATH_MAX * 2];
+
+	if (sync_needed)
+		if (!sync_local_dev_names(cmd)) /* Flush ops and reset dm cookie */
+			return_0;
+
+	if (pipe(pipefd)) {
+		log_sys_error("pipe", "");
+		return 0;
+	}
+
+	log_verbose("Piping:%s", _verbose_args(argv, buf, sizeof(buf)));
+
+	if ((pdata->pid = fork()) == -1) {
+		log_sys_error("pipe", "");
+		return 0;
+	}
+
+	if (pdata->pid == 0) {
+		/* Child -> writer, convert pipe[0] to STDOUT */
+		if (!_reopen_fd_to_null(STDIN_FILENO))
+			stack;
+		else if (close(pipefd[0 /*read*/]))
+			log_sys_error("close", "pipe[0]");
+		else if (close(STDOUT_FILENO))
+			log_sys_error("close", "STDOUT");
+		else if (dup2(pipefd[1 /*write*/], STDOUT_FILENO) == -1)
+			log_sys_error("dup2", "STDOUT");
+		else if (close(pipefd[1]))
+			log_sys_error("close", "pipe[1]");
+		else if (argv[0]) {
+			execvp(argv[0], (char **) argv);
+			log_sys_error("execvp", argv[0]);
+		}
+		_exit(errno);
+	}
+
+	/* Parent -> reader */
+	if (close(pipefd[1 /*write*/])) {
+		log_sys_error("close", "STDOUT");
+		return NULL;
+	}
+
+	if (!(pdata->fp = fdopen(pipefd[0 /*read*/],  "r"))) {
+		log_sys_error("fdopen", "STDIN");
+		if (close(pipefd[0]))
+			log_sys_error("close", "STDIN");
+		return NULL; /* FIXME: kill */
+	}
+
+	return pdata->fp;
+}
+
+int pipe_close(struct pipe_data *pdata)
+{
+	int status;
+
+	if (fclose(pdata->fp))
+		log_sys_error("fclose", "STDIN");
+
+	if (waitpid(pdata->pid, &status, 0) != pdata->pid) {
+		log_sys_error("waitpid", "");
+		return 0;
+	}
+
+	return (status == 0) ? 1 : 0;
+}
diff --git a/lib/misc/lvm-exec.h b/lib/misc/lvm-exec.h
index 3ad4af1..c73d4c4 100644
--- a/lib/misc/lvm-exec.h
+++ b/lib/misc/lvm-exec.h
@@ -37,4 +37,34 @@ struct cmd_context;
 int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	     int *rstatus, int sync_needed);
 
+
+struct FILE;
+struct pipe_data {
+	FILE *fp;
+	pid_t pid;
+};
+
+/**
+ * popen() like function to read-only output from executed command
+ * without running shell.
+ *
+ * \param argv
+ * Arguments for execvp.
+ *
+ * \param sync_needed
+ * Bool specifying whether local devices needs to be synchronized
+ * before executing command.
+ * Note: You cannot synchronize devices within activation context.
+ *
+ * \param pdata
+ * Arguments to store data needed for pclose_exec().
+ *
+ * \return
+ * 1 (success) or 0 (failure).
+ */
+FILE *pipe_open(struct cmd_context *cmd, const char *const argv[],
+		int sync_needed, struct pipe_data *pdata);
+
+int pipe_close(struct pipe_data *pdata);
+
 #endif


