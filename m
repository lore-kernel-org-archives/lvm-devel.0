From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 27 Aug 2012 11:08:11 +0000 (UTC)
Subject: master - setvbuf: reopen only valid fd
Message-ID: <20120827110811.4D304A1550@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c68c15757384e6cebd7667139661ab643eebbfbe
Commit:        c68c15757384e6cebd7667139661ab643eebbfbe
Parent:        5a3c597fd599c21a0bb0c551c92393518d3e70b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 27 13:07:07 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 27 13:07:07 2012 +0200

setvbuf: reopen only valid fd

We should check whether the fd is opened before trying to reopen it.
For example, the stdin is closed in test/lib/harness.c causing the
test suite to fail.
---
 lib/commands/toolcontext.c |   54 +++++++++++++++++++++++++------------------
 lib/misc/lvm-file.h        |    2 +
 tools/lvmcmdline.c         |    2 +-
 3 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0ede104..9c2404f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1326,21 +1326,25 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 			goto out;
 		}
 
-		if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
-			goto_out;
-		stdin = new_stream;
-		if (setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size)) {
-			log_sys_error("setvbuf", "");
-			goto out;
+		if (is_valid_fd(STDIN_FILENO)) {
+			if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
+				goto_out;
+			stdin = new_stream;
+			if (setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size)) {
+				log_sys_error("setvbuf", "");
+				goto out;
+			}
 		}
 
-		if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream))
-			goto_out;
-		stdout = new_stream;
-		if (setvbuf(stdout, cmd->linebuffer + linebuffer_size,
-			     _IOLBF, linebuffer_size)) {
-			log_sys_error("setvbuf", "");
-			goto out;
+		if (is_valid_fd(STDOUT_FILENO)) {
+			if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream))
+				goto_out;
+			stdout = new_stream;
+			if (setvbuf(stdout, cmd->linebuffer + linebuffer_size,
+				     _IOLBF, linebuffer_size)) {
+				log_sys_error("setvbuf", "");
+				goto out;
+			}
 		}
 		/* Buffers are used for lines without '\n' */
 	} else
@@ -1614,17 +1618,21 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
-		if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
-			stdin = new_stream;
-			setlinebuf(stdin);
-		} else
-			cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
+		if (is_valid_fd(STDIN_FILENO)) {
+			if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
+				stdin = new_stream;
+				setlinebuf(stdin);
+			} else
+				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
+		}
 
-		if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
-			stdout = new_stream;
-			setlinebuf(stdout);
-		} else
-			cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
+		if (is_valid_fd(STDOUT_FILENO)) {
+			if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
+				stdout = new_stream;
+				setlinebuf(stdout);
+			} else
+				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
+		}
 
 		dm_free(cmd->linebuffer);
 	}
diff --git a/lib/misc/lvm-file.h b/lib/misc/lvm-file.h
index 07327c3..c23d8ad 100644
--- a/lib/misc/lvm-file.h
+++ b/lib/misc/lvm-file.h
@@ -51,6 +51,8 @@ void fcntl_unlock_file(int lockfd);
   ((buf1).st_ino == (buf2).st_ino && \
    (buf1).st_dev == (buf2).st_dev)
 
+#define is_valid_fd(fd) (!(fcntl(fd, F_GETFD) == -1 && errno == EBADF))
+
 /*
  * Close the specified stream, taking care to detect and diagnose any write
  * error.  If there is an error, use the supplied file name in a diagnostic
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f3704d6..c5341df 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1230,7 +1230,7 @@ static void _close_descriptor(int fd, unsigned suppress_warnings,
 	const char *filename;
 
 	/* Ignore bad file descriptors */
-	if (fcntl(fd, F_GETFD) == -1 && errno == EBADF)
+	if (!is_valid_fd(fd))
 		return;
 
 	if (!suppress_warnings)


