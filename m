From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:13 +0000 (UTC)
Subject: master - logging: add more log macros
Message-ID: <20161103114313.4AA7F60DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6af26273cb8c0ef310296ba0f4dd42751ab25b0a
Commit:        6af26273cb8c0ef310296ba0f4dd42751ab25b0a
Parent:        96118a2508e1cd3aaf5ba7a0129ff8ecc7ac4af2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 2 14:39:13 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

logging: add more log macros

Introduce macros:

log_level(), log_stderr(), log_once(), log_bypass_report()

For easier and more consisten way how to 'decoder' bits
of info from passed 'level'.

This patch fixes potential problem when 'level' of message
might not have always masked right bits.
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/libdevmapper-event.c |    4 ++--
 lib/log/log.c                         |   12 ++++++------
 lib/log/log.h                         |    4 ++++
 libdm/libdm-common.c                  |    4 ++--
 5 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 58a302e..0b2cd3d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Use log_level() macro to consistently decode message log level in dmeventd.
   Still produce output when dmsetup dependency tree building finds dev missing.
   Check and report pthread_sigmask() failure in dmeventd.
   Check mem alloc fail in _canonicalize_field_ids().
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index d395ed3..8c21537 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -868,11 +868,11 @@ void dm_event_log(const char *subsys, int level, const char *file,
 	static pthread_mutex_t _log_mutex = PTHREAD_MUTEX_INITIALIZER;
 	static time_t start = 0;
 	const char *indent = "";
-	FILE *stream = stdout;
+	FILE *stream = log_stderr(level) ? stderr : stdout;
 	int prio;
 	time_t now;
 
-	switch (level & ~(_LOG_STDERR | _LOG_ONCE)) {
+	switch (log_level(level)) {
 	case _LOG_DEBUG:
 		if (_debug_level < 3)
 			return;
diff --git a/lib/log/log.c b/lib/log/log.c
index c933154..2207c7e 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -476,9 +476,9 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	int bufused, n;
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
-	int use_stderr = level & _LOG_STDERR;
-	int log_once = level & _LOG_ONCE;
-	int log_bypass_report = level & _LOG_BYPASS_REPORT;
+	int use_stderr = log_stderr(level);
+	int log_once = log_once(level);
+	int log_bypass_report = log_bypass_report(level);
 	int fatal_internal_error = 0;
 	size_t msglen;
 	const char *indent_spaces = "";
@@ -489,7 +489,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 	struct dm_report *orig_report;
 	int logged_via_report = 0;
 
-	level &= ~(_LOG_STDERR|_LOG_ONCE|_LOG_BYPASS_REPORT);
+	level = log_level(level);
 
 	if (_abort_on_internal_errors_env_present < 0) {
 		if ((env_str = getenv("DM_ABORT_ON_INTERNAL_ERRORS"))) {
@@ -715,8 +715,8 @@ void print_log_libdm(int level, const char *file, int line, int dm_errno_or_clas
 	 * LOG_WARN level and it's not going to stderr (so we're
 	 * printing common message that is not an error/warning).
 	*/
-	if (!(level & _LOG_STDERR) &&
-	    ((level & ~(_LOG_STDERR|_LOG_ONCE|_LOG_BYPASS_REPORT)) == _LOG_WARN))
+	if (!log_stderr(level) &&
+	    (log_level(level) == _LOG_WARN))
 		level |= _LOG_BYPASS_REPORT;
 
 	_log_stream.out.stream = report_stream;
diff --git a/lib/log/log.h b/lib/log/log.h
index dac627e..0ce4fda 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -50,6 +50,10 @@
 #define _LOG_STDERR        0x0080 /* force things to go to stderr, even if loglevel would make them go to stdout */
 #define _LOG_ONCE          0x0100 /* downgrade to NOTICE if this has been already logged */
 #define _LOG_BYPASS_REPORT 0x0200 /* do not log through report even if report available */
+#define log_level(x)  ((x) & 0x0f)			/* obtain message level */
+#define log_stderr(x)  ((x) & _LOG_STDERR)		/* obtain stderr bit */
+#define log_once(x)  ((x) & _LOG_ONCE)			/* obtain once bit */
+#define log_bypass_report(x)  ((x) & _LOG_BYPASS_REPORT)/* obtain bypass bit */
 
 #define INTERNAL_ERROR "Internal error: "
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 6ac936f..7756009 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -114,9 +114,9 @@ static void _default_log_line(int level,
 	    const char *f, va_list ap)
 {
 	static int _abort_on_internal_errors = -1;
-	FILE *out = (level & _LOG_STDERR) ? stderr : stdout;
+	FILE *out = log_stderr(level) ? stderr : stdout;
 
-	level &= ~(_LOG_STDERR | _LOG_BYPASS_REPORT);
+	level = log_level(level);
 
 	if (level <= _LOG_WARN || _verbose) {
 		if (level < _LOG_WARN)


