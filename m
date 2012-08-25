From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 25 Aug 2012 23:28:54 +0000 (UTC)
Subject: master - setvbuf: close and reopen stream before change
Message-ID: <20120825232854.69C77A1503@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92330ba9c8e21451f8406377ae4839f397f369a2
Commit:        92330ba9c8e21451f8406377ae4839f397f369a2
Parent:        3acc85caa8d313b8c21e4bef7f84601731e74b2b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Aug 26 00:19:52 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Aug 26 00:19:52 2012 +0100

setvbuf: close and reopen stream before change

Fix setvbuf code by closing and reopening stream before changing buffer.

But we need to review what this code is doing embedded inside a library
function rather than the simpler original form being run independently
at the top of main() by tools that need it.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |   65 +++++++++++++++++++++++++++++++++++++++----
 2 files changed, 60 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index acb158b..85f8663 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Fix setvbuf code by closing and reopening stream before changing buffer.
   Disable private buffering when using liblvm.
   When private stdin/stdout buffering is not used always use silent mode.
   Add log/silent to lvm.conf equivalent to -qq.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4230624..0ede104 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1245,6 +1245,37 @@ static void _init_globals(struct cmd_context *cmd)
 	init_mirror_in_sync(0);
 }
 
+/*
+ * Close and reopen stream on file descriptor fd.
+ */
+static int _reopen_stream(FILE *stream, int fd, const char *mode, const char *name, FILE **new_stream)
+{
+	int fd_copy, new_fd;
+
+	if ((fd_copy = dup(fd)) < 0) {
+		log_sys_error("dup", name);
+		return 0;
+	}
+
+	if (fclose(stream))
+		log_sys_error("fclose", name);
+
+	if ((new_fd = dup2(fd_copy, fd)) < 0)
+		log_sys_error("dup2", name);
+	else if (new_fd != fd)
+		log_error("dup2(%d, %d) returned %d", fd_copy, fd, new_fd);
+
+	if (close(fd_copy) < 0)
+		log_sys_error("close", name);
+
+	if (!(*new_stream = fdopen(fd, mode))) {
+		log_sys_error("fdopen", name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir,
@@ -1252,6 +1283,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       unsigned threaded)
 {
 	struct cmd_context *cmd;
+	FILE *new_stream;
 
 #ifdef M_MMAP_MAX
 	mallopt(M_MMAP_MAX, 0);
@@ -1293,9 +1325,20 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 			log_error("Failed to allocate line buffer.");
 			goto out;
 		}
-		if ((setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size) ||
-		     setvbuf(stdout, cmd->linebuffer + linebuffer_size,
-			     _IOLBF, linebuffer_size))) {
+
+		if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
+			goto_out;
+		stdin = new_stream;
+		if (setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size)) {
+			log_sys_error("setvbuf", "");
+			goto out;
+		}
+
+		if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream))
+			goto_out;
+		stdout = new_stream;
+		if (setvbuf(stdout, cmd->linebuffer + linebuffer_size,
+			     _IOLBF, linebuffer_size)) {
 			log_sys_error("setvbuf", "");
 			goto out;
 		}
@@ -1546,6 +1589,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 void destroy_toolcontext(struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft_cmdline;
+	FILE *new_stream;
 
 	if (cmd->dump_filter)
 		persistent_filter_dump(cmd->filter, 1);
@@ -1570,9 +1614,18 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
-		setlinebuf(stdin);
-		fflush(stdout);
-		setlinebuf(stdout);
+		if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
+			stdin = new_stream;
+			setlinebuf(stdin);
+		} else
+			cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
+
+		if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
+			stdout = new_stream;
+			setlinebuf(stdout);
+		} else
+			cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
+
 		dm_free(cmd->linebuffer);
 	}
 


