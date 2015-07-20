From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 20 Jul 2015 14:51:51 +0000 (UTC)
Subject: master - log: Add DM_ABORT_ON_INTERNAL_ERRORS lvm override.
Message-ID: <20150720145151.9747761471@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=500fd8b9bfc6f15d2417c829bce33ea4768261b8
Commit:        500fd8b9bfc6f15d2417c829bce33ea4768261b8
Parent:        b4be988732e909d34ae7b4868bf30cf44c087518
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 20 15:48:59 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 20 15:48:59 2015 +0100

log: Add DM_ABORT_ON_INTERNAL_ERRORS lvm override.

Recognise DM_ABORT_ON_INTERNAL_ERRORS in the lvm logging function as
well as the default dm function it replaces.
---
 WHATS_NEW     |    1 +
 lib/log/log.c |   21 ++++++++++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 596a92f..3cd9111 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Recognise DM_ABORT_ON_INTERNAL_ERRORS env var override in lvm logging fn.
   Fix alloc segfault when extending LV with fewer stripes than in first seg.
   Fix handling of cache policy name.
   Set cache policy before with the first lvm2 cache pool metadata commit.
diff --git a/lib/log/log.c b/lib/log/log.c
index a439d1d..9929090 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -36,7 +36,7 @@ static int _indent = 1;
 static int _log_suppress = 0;
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
-static int _abort_on_internal_errors = 0;
+static int _abort_on_internal_errors_config = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -218,9 +218,10 @@ void init_indent(int indent)
 	_indent = indent;
 }
 
+/* If present, environment setting will override this. */
 void init_abort_on_internal_errors(int fatal)
 {
-	_abort_on_internal_errors = fatal;
+	_abort_on_internal_errors_config = fatal;
 }
 
 void reset_lvm_errno(int store_errmsg)
@@ -277,10 +278,24 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	size_t msglen;
 	const char *indent_spaces = "";
 	FILE *stream;
+	static int _abort_on_internal_errors_env_present = -1;
+	static int _abort_on_internal_errors_env = 0;
+	char *env_str;
 
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
-	if (_abort_on_internal_errors &&
+	if (_abort_on_internal_errors_env_present < 0) {
+		if ((env_str = getenv("DM_ABORT_ON_INTERNAL_ERRORS"))) {
+			_abort_on_internal_errors_env_present = 1;
+			/* Set when env DM_ABORT_ON_INTERNAL_ERRORS is not "0" */
+			_abort_on_internal_errors_env = strcmp(env_str, "0");
+		} else
+			_abort_on_internal_errors_env_present = 0;
+	}
+
+	/* Use value from environment if present, otherwise use value from config. */
+	if (((_abort_on_internal_errors_env_present && _abort_on_internal_errors_env) ||
+	     (!_abort_on_internal_errors_env_present && _abort_on_internal_errors_config)) &&
 	    !strncmp(format, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1)) {
 		fatal_internal_error = 1;
 		/* Internal errors triggering abort cannot be suppressed. */


