From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 14 Nov 2013 08:43:09 -0600
Subject: [PATCH 12/13] lvm2app: Add LVM2APP_DEBUG env variable for debug
In-Reply-To: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
References: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
Message-ID: <1384440190-5759-13-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows a user to define the LVM2APP_DEBUG
environmental variable and log debug messages to stderr
for bug reports.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/log/log.c     | 11 +++++++++++
 lib/log/log.h     |  2 ++
 liblvm/lvm_base.c | 14 +++++++++++---
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 25f2264..1de7a3e 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -34,6 +34,7 @@ static int _log_suppress = 0;
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
 static int _abort_on_internal_errors = 0;
+static int _force_to_std_error = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -44,6 +45,11 @@ static size_t _lvm_errmsg_size = 0;
 static size_t _lvm_errmsg_len = 0;
 #define MAX_ERRMSG_LEN (512 * 1024)  /* Max size of error buffer 512KB */
 
+void init_force_stderr(int yes_no)
+{
+	_force_to_std_error = yes_no;
+}
+
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
 	if (log_fn)
@@ -202,6 +208,11 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
+	/* lvm2app debug will be outputting everything to STDERR */
+	if (_force_to_std_error) {
+		use_stderr = 1;
+	}
+
 	if (_abort_on_internal_errors &&
 	    !strncmp(format, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1)) {
 		fatal_internal_error = 1;
diff --git a/lib/log/log.h b/lib/log/log.h
index 99e7623..6059663 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -107,6 +107,8 @@
 #define log_sys_debug(x, y) \
 		log_debug("%s: %s failed: %s", y, x, strerror(errno))
 
+void init_force_stderr(int yes_no);
+
 #define return_0	do { stack; return 0; } while (0)
 #define return_NULL	do { stack; return NULL; } while (0)
 #define return_ECMD_FAILED do { stack; return ECMD_FAILED; } while (0)
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 891cdab..f7a71df 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -68,10 +68,18 @@ lvm_t lvm_init(const char *system_dir)
 	cmd->cmd_line = "liblvm";
 
 	/*
-	 * Turn off writing to stdout/stderr.
-	 * FIXME Fix lib/ to support a non-interactive mode instead.
+	 * If a user defines LVM2APP_DEBUG we will log at a high level to stderr
 	 */
-	log_suppress(1);
+	if (getenv("LVM2APP_DEBUG")) {
+		init_verbose(_LOG_DEBUG);
+		init_force_stderr(1);
+	} else {
+		/*
+		 * Turn off writing to stdout/stderr.
+		 * FIXME Fix lib/ to support a non-interactive mode instead.
+		 */
+		log_suppress(1);
+	}
 
 	return (lvm_t) cmd;
 }
-- 
1.8.2.1


