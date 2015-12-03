From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:22:22 +0000 (UTC)
Subject: master - log: use full buffer size for printf
Message-ID: <20151203172222.C48B160F6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20acc66a237429d81b699b56be57d4d043362098
Commit:        20acc66a237429d81b699b56be57d4d043362098
Parent:        20483ead5bbc74b68126dfadec7b5f98f41b3400
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 3 15:28:01 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 3 18:01:42 2015 +0100

log: use full buffer size for printf

Pass full buffer size to printf() function - no reason to make
buffer 1 char smaller.

Also rename locn buffer to message buffer directly since it's
not used for anything else.

TODO: we may use same buffer also for 'buf[]' since there is
no collision - so may safe 1K on stack usage.
---
 WHATS_NEW     |    1 +
 lib/log/log.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7ade066..c39eae4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Cleaned logging code for buffer size usage.
   Added internal id_read_format_try() function to check and read valid UUID.
   Use dm_get_status_mirror() instead of individual parsers.
   Add mem pool arg for check_transient_status() target function.
diff --git a/lib/log/log.c b/lib/log/log.c
index c44c3d4..fc52bdd 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -264,9 +264,8 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	       const char *format, ...)
 {
 	va_list ap;
-	char buf[1024], locn[4096];
+	char buf[1024], message[4096];
 	int bufused, n;
-	const char *message;
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
 	int use_stderr = level & _LOG_STDERR;
@@ -315,17 +314,16 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	    (_store_errmsg && (level <= _LOG_ERR)) ||
 	    log_once) {
 		va_start(ap, format);
-		n = vsnprintf(locn, sizeof(locn) - 1, trformat, ap);
+		n = vsnprintf(message, sizeof(message), trformat, ap);
 		va_end(ap);
 
+		/* When newer glibc returns >= sizeof(locn), we will just log what
+                 * has fit into buffer, it's '\0' terminated string */
 		if (n < 0) {
 			fprintf(stderr, _("vsnprintf failed: skipping external "
 					"logging function"));
 			goto log_it;
 		}
-
-		locn[sizeof(locn) - 1] = '\0';
-		message = locn;
 	}
 
 /* FIXME Avoid pointless use of message buffer when it'll never be read! */
@@ -441,20 +439,24 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		_already_logging = 1;
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
-		if ((n = dm_snprintf(buf, sizeof(buf) - 1,
+		if ((n = dm_snprintf(buf, sizeof(buf),
 				      "%s:%d %s%s", file, line, log_command_name(),
 				      _msg_prefix)) == -1)
 			goto done;
 
-		bufused += n;
+		bufused += n;		/* n does not include '\0' */
 
 		va_start(ap, format);
-		n = vsnprintf(buf + bufused - 1, sizeof(buf) - bufused - 1,
+		n = vsnprintf(buf + bufused, sizeof(buf) - bufused,
 			      trformat, ap);
 		va_end(ap);
-		bufused += n;
 
-		buf[bufused - 1] = '\n';
+		if (n < 0)
+			goto done;
+
+		bufused += n;
+		if (n >= sizeof(buf))
+			bufused = sizeof(buf) - 1;
 	      done:
 		buf[bufused] = '\n';
 		buf[sizeof(buf) - 1] = '\n';


