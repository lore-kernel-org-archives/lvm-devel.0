From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Apr 2015 17:21:59 +0000 (UTC)
Subject: master - debug: change envvar
Message-ID: <20150420172159.34D2D60221@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b4f10ac668f01e63528ccea71545c06120fa9aa
Commit:        2b4f10ac668f01e63528ccea71545c06120fa9aa
Parent:        cf4df9e3496d60e7183952e44863250e64618748
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 20 19:10:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 20 19:18:56 2015 +0200

debug: change envvar

Rename envvar LVM_LOG_FILE_UNLINK_STATUS to LVM_EXPECTED_EXIT_STATUS
and change compare sign from  '!' to  '>'.

Validate LVM_LOG_FILE_EPOCH and support strictly only
up-to 32 alpha chars. If the content doesn't pass
epoch is simply ignored.
---
 lib/log/log.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 141d02d..d8d65ee 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -21,6 +21,7 @@
 #include <stdio.h>
 #include <stdarg.h>
 #include <syslog.h>
+#include <ctype.h>
 
 static FILE *_log_file;
 static char _log_file_path[PATH_MAX];
@@ -56,11 +57,12 @@ void init_log_fn(lvm2_log_fn_t log_fn)
 
 /*
  * Support envvar LVM_LOG_FILE_EPOCH and allow to attach
- * extra keyword to openned log file. After this word pid
- * and starttime (in kernel units, read from /proc/self/stat
+ * extra keyword (consist of upto 32 alpha chars) to
+ * opened log file. After this 'epoch' word pid and starttime
+ * (in kernel units, read from /proc/self/stat)
  * is automatically attached.
  * If command/daemon forks multiple times, it could create multiple
- * log files ensure, there are no overwrites.
+ * log files ensuring, there are no overwrites.
  */
 void init_log_file(const char *log_file, int append)
 {
@@ -69,9 +71,18 @@ void init_log_file(const char *log_file, int append)
 	int pid;
 	long long starttime;
 	FILE *st;
+	int i = 0;
 
 	_log_file_path[0] = '\0';
 	if ((env = getenv("LVM_LOG_FILE_EPOCH"))) {
+		while (isalpha(env[i]) && i < 32) /* Up to 32 alphas */
+			i++;
+		if (env[i]) {
+			if (i)
+				log_warn("WARNING: Ignoring invalid LVM_LOG_FILE_EPOCH envvar \"%s\".", env);
+			goto no_epoch;
+		}
+
 		if (!(st = fopen(statfile, "r")))
 			log_sys_error("fopen", statfile);
 		else if (fscanf(st, "%d %*s %*c %*d %*d %*d %*d " /* tty_nr */
@@ -94,7 +105,7 @@ void init_log_file(const char *log_file, int append)
 			}
 		}
 	}
-
+no_epoch:
 	if (!(_log_file = fopen(log_file, append ? "a" : "w"))) {
 		log_sys_error("fopen", log_file);
 		return;
@@ -106,21 +117,21 @@ void init_log_file(const char *log_file, int append)
 /*
  * Unlink the log file depeding on command's return value
  *
- * When envvar LVM_LOG_FILE_UNLINK_STATUS is set, compare
+ * When envvar LVM_EXPECTED_EXIT_STATUS is set, compare
  * resulting status with this string.
  *
  * It's possible to specify 2 variants - having it equal to
  * a single number or having it different from a single number.
  *
- * i.e.  LVM_LOG_FILE_UNLINK_STATUS="!1"  # delete when ret != 1.
+ * i.e.  LVM_EXPECTED_EXIT_STATUS=">1"  # delete when ret > 1.
  */
 void unlink_log_file(int ret)
 {
 	const char *env;
 
 	if (_log_file_path[0] &&
-	    (env = getenv("LVM_LOG_FILE_UNLINK_STATUS")) &&
-	    ((env[0] == '!' && atoi(env + 1) != ret) ||
+	    (env = getenv("LVM_EXPECTED_EXIT_STATUS")) &&
+	    ((env[0] == '>' && ret > atoi(env + 1)) ||
 	     (atoi(env) == ret))) {
 		if (unlink(_log_file_path))
 			log_sys_error("unlink", _log_file_path);


