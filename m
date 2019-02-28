From: David Teigland <teigland@sourceware.org>
Date: Thu, 28 Feb 2019 12:02:41 -0500
Subject: master - logging: remove unused code
Message-ID: <201902281702.x1SH2f2U019050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb83719d7f6ca0b2da0a56e5ce7ac1a9d1ebc7e1
Commit:        fb83719d7f6ca0b2da0a56e5ce7ac1a9d1ebc7e1
Parent:        ce79b62bc2fcaddf65e090ec3fef75926cddf82c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 28 10:30:54 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 28 10:30:54 2019 -0600

logging: remove unused code

Incomplete bits of original code that's unused.
---
 lib/commands/toolcontext.c |    6 ----
 lib/log/log.c              |   61 +-------------------------------------------
 lib/log/lvm-logging.h      |    2 -
 3 files changed, 1 insertions(+), 68 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 29c1bd8..0b88dca 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -374,15 +374,10 @@ static void _init_logging(struct cmd_context *cmd)
 	log_file = find_config_tree_str(cmd, log_file_CFG, NULL);
 
 	if (log_file) {
-		release_log_memory();
 		fin_log();
 		init_log_file(log_file, append);
 	}
 
-	log_file = find_config_tree_str(cmd, log_activate_file_CFG, NULL);
-	if (log_file)
-		init_log_direct(log_file, append);
-
 	init_log_while_suspended(find_config_tree_bool(cmd, log_activation_CFG, NULL));
 
 	cmd->default_settings.debug_classes = _parse_debug_classes(cmd);
@@ -1995,7 +1990,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	lvmpolld_disconnect();
 
-	release_log_memory();
 	activation_exit();
 	reset_log_duplicated();
 	fin_log();
diff --git a/lib/log/log.c b/lib/log/log.c
index cb850dc..ebf26b4 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -28,19 +28,15 @@
 
 static FILE *_log_file;
 static char _log_file_path[PATH_MAX];
-static struct device _log_dev;
-static struct dm_str_list _log_dev_alias;
 
 static int _syslog = 0;
 static int _log_to_file = 0;
 static uint64_t _log_file_max_lines = 0;
 static uint64_t _log_file_lines = 0;
-static int _log_direct = 0;
 static int _log_while_suspended = 0;
 static int _indent = 0;
 static int _log_suppress = 0;
 static char _msg_prefix[30] = "  ";
-static int _already_logging = 0;
 static int _abort_on_internal_errors_config = 0;
 static uint32_t _debug_file_fields;
 static uint32_t _debug_output_fields;
@@ -309,17 +305,6 @@ void unlink_log_file(int ret)
 	}
 }
 
-void init_log_direct(const char *log_file, int append)
-{
-	int open_flags = append ? 0 : O_TRUNC;
-
-	dev_create_file(log_file, &_log_dev, &_log_dev_alias, 1);
-	if (!dev_open_flags(&_log_dev, O_RDWR | O_CREAT | open_flags, 1, 0))
-		return;
-
-	_log_direct = 1;
-}
-
 void init_log_while_suspended(int log_while_suspended)
 {
 	_log_while_suspended = log_while_suspended;
@@ -343,22 +328,8 @@ int log_suppress(int suppress)
 	return old_suppress;
 }
 
-void release_log_memory(void)
-{
-	if (!_log_direct)
-		return;
-
-	free((char *) _log_dev_alias.str);
-	_log_dev_alias.str = "activate_log file";
-}
-
 void fin_log(void)
 {
-	if (_log_direct) {
-		(void) dev_close(&_log_dev);
-		_log_direct = 0;
-	}
-
 	if (_log_to_file) {
 		if (dm_fclose(_log_file)) {
 			if (errno)
@@ -519,7 +490,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	char buf[1024], message[4096];
 	char time_prefix[32] = "";
 	const char *command_prefix = NULL;
-	int bufused, n;
+	int n;
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
 	int use_stderr = log_stderr(level);
@@ -749,36 +720,6 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 
 	if (fatal_internal_error)
 		abort();
-
-	/* FIXME This code is unfinished - pre-extend & condense. */
-	if (!_already_logging && _log_direct && critical_section()) {
-		_already_logging = 1;
-		memset(&buf, ' ', sizeof(buf));
-		bufused = 0;
-		if ((n = dm_snprintf(buf, sizeof(buf), "%s:%s %s:%d %s",
-				     time_prefix, log_command_file(), file, line, _msg_prefix)) == -1)
-			goto done;
-
-		bufused += n;		/* n does not include '\0' */
-
-		va_copy(ap, orig_ap);
-		n = vsnprintf(buf + bufused, sizeof(buf) - bufused,
-			      trformat, ap);
-		va_end(ap);
-
-		if (n < 0)
-			goto done;
-
-		bufused += n;
-		if (n >= (int) sizeof(buf))
-			bufused = sizeof(buf) - 1;
-	      done:
-		buf[bufused] = '\n';
-		buf[sizeof(buf) - 1] = '\n';
-		/* FIXME real size bufused */
-		dev_append(&_log_dev, sizeof(buf), DEV_IO_LOG, buf);
-		_already_logging = 0;
-	}
 }
 
 void print_log(int level, const char *file, int line, int dm_errno_or_class,
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 8a0c0e5..39108fc 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -53,12 +53,10 @@ void init_debug_output_fields(uint32_t debug_fields);
 
 void init_log_file(const char *log_file, int append);
 void unlink_log_file(int ret);
-void init_log_direct(const char *log_file, int append);
 void init_log_while_suspended(int log_while_suspended);
 void init_abort_on_internal_errors(int fatal);
 
 void fin_log(void);
-void release_log_memory(void);
 void reset_log_duplicated(void);
 
 void init_syslog(int facility);


