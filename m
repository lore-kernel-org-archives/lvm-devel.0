From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Apr 2015 10:14:05 +0000 (UTC)
Subject: master - debug: add new envvar
Message-ID: <20150420101405.B862460DA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5723a7cd7e857c4b5899b19060d17cac1b14e6b6
Commit:        5723a7cd7e857c4b5899b19060d17cac1b14e6b6
Parent:        de4791c052b1576bb9de73b3fa8e51b771522f7e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 20 10:04:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 20 12:12:22 2015 +0200

debug: add new envvar

Add support for 2 new envvars for internal lvm2 test suite
(though it could be possible usable for other cases)

LVM_LOG_FILE_EPOCH

Whether to add 'epoch' extension that consist from
the envvar 'string' + pid + starttime in kernel units
obtained from /proc/self/stat.

LVM_LOG_FILE_UNLINK_STATUS

Whether to unlink the log depending on return status value,
so if the command is successful the log is automatically
deleted.

API is still for now experimental to catch various issue.
---
 lib/log/log.c         |   68 +++++++++++++++++++++++++++++++++++++++++++++++-
 lib/log/lvm-logging.h |    1 +
 tools/lvmcmdline.c    |    2 +
 3 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 2d1fe74..141d02d 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -18,10 +18,12 @@
 #include "memlock.h"
 #include "defaults.h"
 
+#include <stdio.h>
 #include <stdarg.h>
 #include <syslog.h>
 
 static FILE *_log_file;
+static char _log_file_path[PATH_MAX];
 static struct device _log_dev;
 static struct dm_str_list _log_dev_alias;
 
@@ -52,11 +54,48 @@ void init_log_fn(lvm2_log_fn_t log_fn)
 		_lvm2_log_fn = NULL;
 }
 
+/*
+ * Support envvar LVM_LOG_FILE_EPOCH and allow to attach
+ * extra keyword to openned log file. After this word pid
+ * and starttime (in kernel units, read from /proc/self/stat
+ * is automatically attached.
+ * If command/daemon forks multiple times, it could create multiple
+ * log files ensure, there are no overwrites.
+ */
 void init_log_file(const char *log_file, int append)
 {
-	const char *open_mode = append ? "a" : "w";
+	static const char statfile[] = "/proc/self/stat";
+	const char *env;
+	int pid;
+	long long starttime;
+	FILE *st;
+
+	_log_file_path[0] = '\0';
+	if ((env = getenv("LVM_LOG_FILE_EPOCH"))) {
+		if (!(st = fopen(statfile, "r")))
+			log_sys_error("fopen", statfile);
+		else if (fscanf(st, "%d %*s %*c %*d %*d %*d %*d " /* tty_nr */
+			   "%*d %*u %*u %*u %*u " /* mjflt */
+			   "%*u %*u %*u %*d %*d " /* cstim */
+			   "%*d %*d %*d %*d " /* itrealvalue */
+			   "%llu", &pid, &starttime) != 2) {
+			log_warn("WARNING: Cannot parse content of %s.", statfile);
+		} else {
+			if (fclose(st))
+				log_sys_debug("fclose", statfile);
+
+			if (dm_snprintf(_log_file_path, sizeof(_log_file_path),
+					"%s_%s_%d_%lld", log_file, env, pid, starttime) < 0) {
+				log_warn("WARNING: Debug log file path is too long for epoch.");
+				_log_file_path[0] = '\0';
+			} else {
+				log_file = _log_file_path;
+				append = 1; /* force */
+			}
+		}
+	}
 
-	if (!(_log_file = fopen(log_file, open_mode))) {
+	if (!(_log_file = fopen(log_file, append ? "a" : "w"))) {
 		log_sys_error("fopen", log_file);
 		return;
 	}
@@ -64,6 +103,31 @@ void init_log_file(const char *log_file, int append)
 	_log_to_file = 1;
 }
 
+/*
+ * Unlink the log file depeding on command's return value
+ *
+ * When envvar LVM_LOG_FILE_UNLINK_STATUS is set, compare
+ * resulting status with this string.
+ *
+ * It's possible to specify 2 variants - having it equal to
+ * a single number or having it different from a single number.
+ *
+ * i.e.  LVM_LOG_FILE_UNLINK_STATUS="!1"  # delete when ret != 1.
+ */
+void unlink_log_file(int ret)
+{
+	const char *env;
+
+	if (_log_file_path[0] &&
+	    (env = getenv("LVM_LOG_FILE_UNLINK_STATUS")) &&
+	    ((env[0] == '!' && atoi(env + 1) != ret) ||
+	     (atoi(env) == ret))) {
+		if (unlink(_log_file_path))
+			log_sys_error("unlink", _log_file_path);
+		_log_file_path[0] = '\0';
+	}
+}
+
 void init_log_direct(const char *log_file, int append)
 {
 	int open_flags = append ? 0 : O_TRUNC;
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 145e2a1..983da5b 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -40,6 +40,7 @@ void init_indent(int indent);
 void init_msg_prefix(const char *prefix);
 
 void init_log_file(const char *log_file, int append);
+void unlink_log_file(int ret);
 void init_log_direct(const char *log_file, int append);
 void init_log_while_suspended(int log_while_suspended);
 void init_abort_on_internal_errors(int fatal);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f9acd60..26c48f9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1561,6 +1561,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 int lvm_return_code(int ret)
 {
+	unlink_log_file(ret);
+
 	return (ret == ECMD_PROCESSED ? 0 : ret);
 }
 


