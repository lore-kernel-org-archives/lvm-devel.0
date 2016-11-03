From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:21 +0000 (UTC)
Subject: master - dmeventd: separate dm and dmeventd logging
Message-ID: <20161103114321.BA9E860DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b4d19e3aa1da061fed35edb979e1ca2a29fb7ed
Commit:        4b4d19e3aa1da061fed35edb979e1ca2a29fb7ed
Parent:        cd468b6218fc5c46e98ee0061010724c298c312c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 3 12:10:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

dmeventd: separate dm and dmeventd logging

Ensure different logging function for dmeventd.c logging
and dm and lvm library.

We can recognize we want to show every log_info() and
log_notice() message from dmeventd.c code while not
exposing those from libdm/libdevmapper-event

Also switch to use log with errno - it's not changing
anything and doesn't bring any more features yet to dmeventd
logging but we just properly pass dm_errno_or_class properly
through the whole code stack for possible future use
(i.e. support of class logging for dmeventd).
---
 WHATS_NEW_DM                                 |    1 +
 daemons/dmeventd/dmeventd.c                  |   23 +++++++++++++++++++----
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    2 +-
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 73a5171..d2d44ac 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Make log messages from dm and lvm library differnt from dmeventd.
   Notice and Info messages are again logged from dmeventd and its plugins.
   Dmeventd now also respects DM_ABORT_ON_INTERNAL_ERRORS as libdm based tool.
   Report as non default dm logging also when logging with errno was changed.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 6024e56..58922ac 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -99,13 +99,28 @@ static time_t _idle_since = 0;
 static char **_initial_registrations = 0;
 
 /* FIXME Make configurable at runtime */
-__attribute__((format(printf, 4, 5)))
+
+/* All libdm messages */
+__attribute__((format(printf, 5, 6)))
+static void _libdm_log(int level, const char *file, int line,
+		       int dm_errno_or_class, const char *format, ...)
+{
+	va_list ap;
+	va_start(ap, format);
+	dm_event_log("#dm", level, file, line, dm_errno_or_class, format, ap);
+	va_end(ap);
+}
+
+/* All dmeventd messages */
+#undef LOG_MESG
+#define LOG_MESG(l, f, ln, e, x...) _dmeventd_log(l, f, ln, e, ## x)
+__attribute__((format(printf, 5, 6)))
 static void _dmeventd_log(int level, const char *file, int line,
-			  const char *format, ...)
+			  int dm_errno_or_class, const char *format, ...)
 {
 	va_list ap;
 	va_start(ap, format);
-	dm_event_log("dm", level, file, line, 0, format, ap);
+	dm_event_log("dmeventd", level, file, line, dm_errno_or_class, format, ap);
 	va_end(ap);
 }
 
@@ -2191,7 +2206,7 @@ int main(int argc, char *argv[])
 		openlog("dmeventd", LOG_PID, LOG_DAEMON);
 
 	dm_event_log_set(_debug_level, _use_syslog);
-	dm_log_init(_dmeventd_log);
+	dm_log_with_errno_init(_libdm_log);
 
 	(void) dm_prepare_selinux_context(DMEVENTD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(DMEVENTD_PIDFILE) == 0)
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index f36feb4..0cca98f 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -32,7 +32,7 @@ static int _register_count = 0;
 static struct dm_pool *_mem_pool = NULL;
 static void *_lvm_handle = NULL;
 
-DM_EVENT_LOG_FN("lvm")
+DM_EVENT_LOG_FN("#lvm")
 
 static void _lvm2_print_log(int level, const char *file, int line,
 			    int dm_errno_or_class, const char *msg)


