From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:33 +0000 (UTC)
Subject: master - log: separate output and make it possible to use given FDs
Message-ID: <20160809173933.185DA60A4D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06ce9b4e4238da58d6c2acda7878dbc51245a8fc
Commit:        06ce9b4e4238da58d6c2acda7878dbc51245a8fc
Parent:        bb9789f2b3404893dcb92cfc2d1eeec002c90140
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 8 16:47:51 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:24:45 2016 +0200

log: separate output and make it possible to use given FDs

Currently, the output is separated in 3 parts and each part can go into
a separate and user-defined file descriptor:

  - common output (stdout by default, customizable by LVM_OUT_FD environment variable)
  - error output (stderr by default, customizable by LVM_ERR_FD environment variable)
  - report output (stdout by default, customizable by LVM_REPORT_FD environment variable)

For example, each type of output goes to different output file:

  [0] fedora/~ # export LVM_REPORT_FD=3

  [0] fedora/~ # lvs fedora vg/abc 1>out 2>err 3>report

  [0] fedora/~ # cat out

  [0] fedora/~ # cat err
    Volume group "vg" not found
    Cannot process volume group vg

  [0] fedora/~ # cat report
    LV   VG     Attr       LSize   Layout     Role       CTime
    root fedora -wi-ao----  19.00g linear     public     Wed May 27 2015 08:09:21
    swap fedora -wi-ao---- 500.00m linear     public     Wed May 27 2015 08:09:21

Another example in LVM shell where the report goes to "report" file:

  [0] fedora/~ # export LVM_REPORT_FD=3
  [0] fedora/~ # lvm 3>report

  (in lvm shell)
  lvm> vgs

  (content of "report" file)
  [1] fedora/~ # cat report
    VG     #PV #LV #SN Attr   VSize  VFree
    fedora   1   2   0 wz--n- 19.49g    0

  (in lvm shell)
  lvm> lvs

  (content of "report" file)
  [1] fedora/~ # cat report
    VG     #PV #LV #SN Attr   VSize  VFree
    fedora   1   2   0 wz--n- 19.49g    0
    LV   VG     Attr       LSize   Layout     Role       CTime
    root fedora -wi-ao----  19.00g linear     public     Wed May 27 2015 08:09:21
    swap fedora -wi-ao---- 500.00m linear     public     Wed May 27 2015 08:09:21
---
 lib/commands/toolcontext.c |   50 ++-----------
 lib/log/log.c              |  172 +++++++++++++++++++++++++++++++++++++++++---
 lib/log/lvm-logging.h      |    5 ++
 lib/misc/lvm-file.h        |    6 ++
 man/lvm.8.in               |    9 +++
 tools/lvmcmdline.c         |   62 ++++++++++++++--
 6 files changed, 245 insertions(+), 59 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d3bd5bc..82e990e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1650,37 +1650,6 @@ static void _init_globals(struct cmd_context *cmd)
 }
 
 /*
- * Close and reopen stream on file descriptor fd.
- */
-static int _reopen_stream(FILE *stream, int fd, const char *mode, const char *name, FILE **new_stream)
-{
-	int fd_copy, new_fd;
-
-	if ((fd_copy = dup(fd)) < 0) {
-		log_sys_error("dup", name);
-		return 0;
-	}
-
-	if (fclose(stream))
-		log_sys_error("fclose", name);
-
-	if ((new_fd = dup2(fd_copy, fd)) < 0)
-		log_sys_error("dup2", name);
-	else if (new_fd != fd)
-		log_error("dup2(%d, %d) returned %d", fd_copy, fd, new_fd);
-
-	if (close(fd_copy) < 0)
-		log_sys_error("close", name);
-
-	if (!(*new_stream = fdopen(fd, mode))) {
-		log_sys_error("fdopen", name);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
  * init_connections();
  *   _init_lvmetad();
  *     lvmetad_disconnect();  (close previous connection)
@@ -1835,7 +1804,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       unsigned set_filters)
 {
 	struct cmd_context *cmd;
-	FILE *new_stream;
 	int flags;
 
 #ifdef M_MMAP_MAX
@@ -1885,9 +1853,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		if (is_valid_fd(STDIN_FILENO) &&
 		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_WRONLY) {
-			if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
+			if (!reopen_standard_stream(&stdin, "r"))
 				goto_out;
-			stdin = new_stream;
 			if (setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size)) {
 				log_sys_error("setvbuf", "");
 				goto out;
@@ -1897,9 +1864,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		if (is_valid_fd(STDOUT_FILENO) &&
 		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_RDONLY) {
-			if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream))
+			if (!reopen_standard_stream(&stdout, "w"))
 				goto_out;
-			stdout = new_stream;
 			if (setvbuf(stdout, cmd->linebuffer + linebuffer_size,
 				     _IOLBF, linebuffer_size)) {
 				log_sys_error("setvbuf", "");
@@ -1911,7 +1877,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		/* Without buffering, must not use stdin/stdout */
 		init_silent(1);
 #endif
-
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
@@ -2227,7 +2192,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 void destroy_toolcontext(struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft_cmdline;
-	FILE *new_stream;
 	int flags;
 
 	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
@@ -2266,20 +2230,18 @@ void destroy_toolcontext(struct cmd_context *cmd)
 		if (is_valid_fd(STDIN_FILENO) &&
 		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_WRONLY) {
-			if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
-				stdin = new_stream;
+			if (reopen_standard_stream(&stdin, "r"))
 				setlinebuf(stdin);
-			} else
+			else
 				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
 		}
 
 		if (is_valid_fd(STDOUT_FILENO) &&
 		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_RDONLY) {
-			if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
-				stdout = new_stream;
+			if (reopen_standard_stream(&stdout, "w"))
 				setlinebuf(stdout);
-			} else
+			else
 				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
 		}
 
diff --git a/lib/log/log.c b/lib/log/log.c
index 6d5fc59..d021ffe 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -18,6 +18,7 @@
 #include "memlock.h"
 #include "defaults.h"
 #include "report.h"
+#include "lvm-file.h"
 
 #include <stdio.h>
 #include <stdarg.h>
@@ -59,6 +60,154 @@ static log_report_t _log_report = {
 	.object_group = NULL
 };
 
+#define LOG_STREAM_BUFFER_SIZE 4096
+
+struct log_stream_item {
+	FILE *stream;
+	char *buffer;
+};
+
+struct log_stream {
+	struct log_stream_item out;
+	struct log_stream_item err;
+	struct log_stream_item report;
+} _log_stream = {{NULL, NULL},
+		 {NULL, NULL},
+		 {NULL, NULL}};
+
+#define out_stream (_log_stream.out.stream ? : stdout)
+#define err_stream (_log_stream.err.stream ? : stderr)
+#define report_stream (_log_stream.report.stream ? : stdout)
+
+static int _set_custom_log_stream(struct log_stream_item *stream_item, int custom_fd)
+{
+	FILE *final_stream = NULL;
+	int flags;
+	int r = 1;
+
+	if (custom_fd < 0)
+		goto out;
+
+	if (is_valid_fd(custom_fd)) {
+		if ((flags = fcntl(custom_fd, F_GETFL)) > 0) {
+			if ((flags & O_ACCMODE) == O_RDONLY) {
+				log_error("File descriptor %d already open in read-only "
+					  "mode, expected write-only or read-write mode.",
+					   (int) custom_fd);
+				r = 0;
+				goto out;
+			}
+		}
+
+		if (custom_fd == STDIN_FILENO) {
+			log_error("Can't set standard input for log output.");
+			r = 0;
+			goto out;
+		}
+
+		if (custom_fd == STDOUT_FILENO) {
+			final_stream = stdout;
+			goto out;
+		}
+
+		if (custom_fd == STDERR_FILENO) {
+			final_stream = stderr;
+			goto out;
+		}
+	}
+
+	if (!(final_stream = fdopen(custom_fd, "w"))) {
+		log_error("Failed to open stream for file descriptor %d.",
+			  (int) custom_fd);
+		r = 0;
+		goto out;
+	}
+
+	if (!(stream_item->buffer = dm_malloc(LOG_STREAM_BUFFER_SIZE))) {
+		log_error("Failed to allocate buffer for stream on file "
+			  "descriptor %d.", (int) custom_fd);
+	} else {
+		if (setvbuf(final_stream, stream_item->buffer, _IOLBF, LOG_STREAM_BUFFER_SIZE)) {
+			log_sys_error("setvbuf", "");
+			dm_free(stream_item->buffer);
+			stream_item->buffer = NULL;
+		}
+	}
+out:
+	stream_item->stream = final_stream;
+	return r;
+}
+
+int init_custom_log_streams(struct custom_fds *custom_fds)
+{
+	return _set_custom_log_stream(&_log_stream.out, custom_fds->out) &&
+	       _set_custom_log_stream(&_log_stream.err, custom_fds->err) &&
+	       _set_custom_log_stream(&_log_stream.report, custom_fds->report);
+}
+
+static void _check_and_replace_standard_log_streams(FILE *old_stream, FILE *new_stream)
+{
+	if (_log_stream.out.stream == old_stream)
+		_log_stream.out.stream = new_stream;
+
+	if (_log_stream.err.stream == old_stream)
+		_log_stream.err.stream = new_stream;
+
+	if (_log_stream.report.stream == old_stream)
+		_log_stream.report.stream = new_stream;
+}
+
+/*
+ * Close and reopen standard stream on file descriptor fd.
+ */
+int reopen_standard_stream(FILE **stream, const char *mode)
+{
+	int fd, fd_copy, new_fd;
+	const char *name;
+	FILE *old_stream = *stream;
+	FILE *new_stream;
+
+	if (old_stream == stdin) {
+		fd = STDIN_FILENO;
+		name = "stdin";
+	} else if (old_stream == stdout) {
+		fd = STDOUT_FILENO;
+		name = "stdout";
+	} else if (old_stream == stderr) {
+		fd = STDERR_FILENO;
+		name = "stderr";
+	} else {
+		log_error(INTERNAL_ERROR "reopen_standard_stream called on non-standard stream");
+		return 0;
+	}
+
+	if ((fd_copy = dup(fd)) < 0) {
+		log_sys_error("dup", name);
+		return 0;
+	}
+
+	if (fclose(old_stream))
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
+	if (!(new_stream = fdopen(fd, mode))) {
+		log_sys_error("fdopen", name);
+		return 0;
+	}
+
+	_check_and_replace_standard_log_streams(old_stream, new_stream);
+
+	*stream = new_stream;
+	return 1;
+}
+
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
 	_lvm2_log_fn = log_fn;
@@ -207,10 +356,10 @@ void fin_log(void)
 	if (_log_to_file) {
 		if (dm_fclose(_log_file)) {
 			if (errno)
-			      fprintf(stderr, "failed to write log file: %s\n",
+			      fprintf(err_stream, "failed to write log file: %s\n",
 				      strerror(errno));
 			else
-			      fprintf(stderr, "failed to write log file\n");
+			      fprintf(err_stream, "failed to write log file\n");
 
 		}
 		_log_to_file = 0;
@@ -378,8 +527,8 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		/* When newer glibc returns >= sizeof(locn), we will just log what
                  * has fit into buffer, it's '\0' terminated string */
 		if (n < 0) {
-			fprintf(stderr, _("vsnprintf failed: skipping external "
-					"logging function"));
+			fprintf(err_stream, _("vsnprintf failed: skipping external "
+					      "logging function"));
 			goto log_it;
 		}
 	}
@@ -426,7 +575,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 				   _log_report.object_name, _log_report.object_id,
 				   _log_report.object_group, _log_report.object_group_id,
 				   message, _lvm_errno, 0))
-			fprintf(stderr, _("failed to report cmdstatus"));
+			fprintf(err_stream, _("failed to report cmdstatus"));
 		else
 			logged_via_report = 1;
 
@@ -468,10 +617,10 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 				break;
 			/* fall through */
 		default:
-			/* Typically only log_warn goes to stdout */
-			stream = (use_stderr || (level != _LOG_WARN)) ? stderr : stdout;
-			if (stream == stderr)
-				fflush(stdout);
+			/* Typically only log_warn goes to out_stream */
+			stream = (use_stderr || (level != _LOG_WARN)) ? err_stream : out_stream;
+			if (stream == err_stream)
+				fflush(out_stream);
 			fprintf(stream, "%s%s%s%s", buf, log_command_name(),
 				_msg_prefix, indent_spaces);
 			vfprintf(stream, trformat, ap);
@@ -556,6 +705,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 void print_log_libdm(int level, const char *file, int line, int dm_errno_or_class,
 		     const char *format, ...)
 {
+	FILE *orig_out_stream = out_stream;
 	va_list ap;
 
 	/*
@@ -567,9 +717,13 @@ void print_log_libdm(int level, const char *file, int line, int dm_errno_or_clas
 	    ((level & ~(_LOG_STDERR|_LOG_ONCE|_LOG_BYPASS_REPORT)) == _LOG_WARN))
 		level |= _LOG_BYPASS_REPORT;
 
+	_log_stream.out.stream = report_stream;
+
 	va_start(ap, format);
 	_vprint_log(level, file, line, dm_errno_or_class, format, ap);
 	va_end(ap);
+
+	_log_stream.out.stream = orig_out_stream;
 }
 
 log_report_t log_get_report_state(void)
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 4101bc8..7ddbf2c 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
+#include "lvm-file.h"
+
 __attribute__ ((format(printf, 5, 6)))
 void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	       const char *format, ...);
@@ -35,6 +37,9 @@ void print_log_libdm(int level, const char *file, int line, int dm_errno_or_clas
 
 #include "log.h"
 
+int init_custom_log_streams(struct custom_fds *custom_fds);
+int reopen_standard_stream(FILE **stream, const char *mode);
+
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
 			       int dm_errno_or_class, const char *message);
 
diff --git a/lib/misc/lvm-file.h b/lib/misc/lvm-file.h
index c92f783..6128abd 100644
--- a/lib/misc/lvm-file.h
+++ b/lib/misc/lvm-file.h
@@ -16,6 +16,12 @@
 #ifndef _LVM_FILE_H
 #define _LVM_FILE_H
 
+struct custom_fds {
+	int out;
+	int err;
+	int report;
+};
+
 /*
  * Create a temporary filename, and opens a descriptor to the file.
  */
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 0215783..76d05fd 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -748,6 +748,15 @@ All tools return a status code of zero on success or non-zero on failure.
 Directory containing \fI.lvm_history\fP if the internal readline
 shell is invoked.
 .TP
+.B LVM_OUT_FD
+File descriptor to use for common output from LVM commands.
+.TP
+.B LVM_ERR_FD
+File descriptor to use for error output from LVM commands.
+.TP
+.B LVM_REPORT_FD
+File descriptor to use for report output from LVM commands.
+.TP
 .B LVM_COMMAND_PROFILE
 Name of default command profile to use for LVM commands. This profile
 is overriden by direct use of \fB\-\-commandprofile\fP command line option.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3c3498a..629fb14 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1838,6 +1838,39 @@ static int _check_standard_fds(void)
 	return 1;
 }
 
+#define LVM_OUT_FD_ENV_VAR_NAME    "LVM_OUT_FD"
+#define LVM_ERR_FD_ENV_VAR_NAME    "LVM_ERR_FD"
+#define LVM_REPORT_FD_ENV_VAR_NAME "LVM_REPORT_FD"
+
+static int _do_get_custom_fd(const char *env_var_name, int *fd)
+{
+	const char *str;
+	char *endptr;
+	int tmp_fd;
+
+	*fd = -1;
+
+	if (!(str = getenv(env_var_name)))
+		return 1;
+
+	errno = 0;
+	tmp_fd = strtol(str, &endptr, 10);
+	if (errno || *endptr || (tmp_fd < 0) || (tmp_fd > INT_MAX)) {
+		log_error("%s: invalid file descriptor.", env_var_name);
+		return 0;
+	}
+
+	*fd = tmp_fd;
+	return 1;
+}
+
+static int _get_custom_fds(struct custom_fds *custom_fds)
+{
+	return _do_get_custom_fd(LVM_OUT_FD_ENV_VAR_NAME, &custom_fds->out) &&
+	       _do_get_custom_fd(LVM_ERR_FD_ENV_VAR_NAME, &custom_fds->err) &&
+	       _do_get_custom_fd(LVM_REPORT_FD_ENV_VAR_NAME, &custom_fds->report);
+}
+
 static const char *_get_cmdline(pid_t pid)
 {
 	static char _proc_cmdline[32];
@@ -1905,7 +1938,7 @@ static void _close_descriptor(int fd, unsigned suppress_warnings,
 	fprintf(stderr, " Parent PID %" PRIpid_t ": %s\n", ppid, parent_cmdline);
 }
 
-static int _close_stray_fds(const char *command)
+static int _close_stray_fds(const char *command, struct custom_fds *custom_fds)
 {
 #ifndef VALGRIND_POOL
 	struct rlimit rlim;
@@ -1939,17 +1972,27 @@ static int _close_stray_fds(const char *command)
 			return 1;
 		}
 
-		for (fd = 3; fd < (int)rlim.rlim_cur; fd++)
-			_close_descriptor(fd, suppress_warnings, command, ppid,
-					  parent_cmdline);
+		for (fd = 3; fd < (int)rlim.rlim_cur; fd++) {
+			if ((fd != custom_fds->out) &&
+			    (fd != custom_fds->err) &&
+			    (fd != custom_fds->report)) {
+				_close_descriptor(fd, suppress_warnings, command, ppid,
+						  parent_cmdline);
+			}
+		}
 		return 1;
 	}
 
 	while ((dirent = readdir(d))) {
 		fd = atoi(dirent->d_name);
-		if (fd > 2 && fd != dirfd(d))
+		if ((fd > 2) &&
+		    (fd != dirfd(d)) &&
+		    (fd != custom_fds->out) &&
+		    (fd != custom_fds->err) &&
+		    (fd != custom_fds->report)) {
 			_close_descriptor(fd, suppress_warnings,
 					  command, ppid, parent_cmdline);
+		}
 	}
 
 	if (closedir(d))
@@ -2111,6 +2154,7 @@ int lvm2_main(int argc, char **argv)
 {
 	const char *base;
 	int ret, alias = 0;
+	struct custom_fds custom_fds;
 	struct cmd_context *cmd;
 
 	if (!argv)
@@ -2124,7 +2168,13 @@ int lvm2_main(int argc, char **argv)
 	if (!_check_standard_fds())
 		return -1;
 
-	if (!_close_stray_fds(base))
+	if (!_get_custom_fds(&custom_fds))
+		return -1;
+
+	if (!_close_stray_fds(base, &custom_fds))
+		return -1;
+
+	if (!init_custom_log_streams(&custom_fds))
 		return -1;
 
 	if (is_static() && strcmp(base, "lvm.static") &&


