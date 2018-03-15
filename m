From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:08 -0400
Subject: master - libdm: support for DM_DEBUG_WITH_LINE_NUMBERS
Message-ID: <201803151004.w2FA48Ua023533@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b3b486a371bd9e98f20d14bbad320d610f3ece7
Commit:        2b3b486a371bd9e98f20d14bbad320d610f3ece7
Parent:        eae54b67d8b7e6236816aa6c4b9bfa95f81d65fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 18:08:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 10:49:24 2018 +0100

libdm: support for DM_DEBUG_WITH_LINE_NUMBERS

For any libdm tool using default debugging function allow
to show source filename and code line number when this
functionality is available.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   17 +++++++++++++----
 man/lvm.8_main       |    3 +++
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5c1f4a1..09e6fc0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Support DM_DEBUG_WITH_LINE_NUMBERS envvar for debug msg with source:line.
   Configured command for thin pool threshold handling gets whole environment.
   Fix tests for failing dm_snprintf() in stats code.
   Parsing mirror status accepts 'userspace' keyword in status.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 2ab5bd1..99cf0c8 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -108,12 +108,12 @@ void dm_lib_init(void)
  */
 
 __attribute__((format(printf, 5, 0)))
-static void _default_log_line(int level,
-	    const char *file __attribute__((unused)),
-	    int line __attribute__((unused)), int dm_errno_or_class,
-	    const char *f, va_list ap)
+static void _default_log_line(int level, const char *file,
+			      int line, int dm_errno_or_class,
+			      const char *f, va_list ap)
 {
 	static int _abort_on_internal_errors = -1;
+	static int _debug_with_line_numbers = -1;
 	FILE *out = log_stderr(level) ? stderr : stdout;
 
 	level = log_level(level);
@@ -121,6 +121,15 @@ static void _default_log_line(int level,
 	if (level <= _LOG_WARN || _verbose) {
 		if (level < _LOG_WARN)
 			out = stderr;
+
+		if (_debug_with_line_numbers < 0)
+			/* Set when env DM_DEBUG_WITH_LINE_NUMBERS is not "0" */
+			_debug_with_line_numbers =
+				strcmp(getenv("DM_DEBUG_WITH_LINE_NUMBERS") ? : "0", "0");
+
+		if (_debug_with_line_numbers)
+			fprintf(out, "%s:%d     ", file, line);
+
 		vfprintf(out, f, ap);
 		fputc('\n', out);
 	}
diff --git a/man/lvm.8_main b/man/lvm.8_main
index bd5d8a7..7bbf44a 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -481,6 +481,9 @@ Abort processing if the code detects a non-fatal internal error.
 .B DM_DISABLE_UDEV
 Avoid interaction with udev.  LVM will manage the relevant nodes in /dev
 directly.
+.TP
+.B DM_DEBUG_WITH_LINE_NUMBERS
+Prepends source file name and code line number with libdm debugging.
 .
 .SH FILES
 .


