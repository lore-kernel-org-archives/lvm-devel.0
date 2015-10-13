From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:46 +0000 (UTC)
Subject: master - dmeventd: enable new logging
Message-ID: <20151013140346.2B4A860EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e50583d7219e01228d697f91a16e91ed1f5efe86
Commit:        e50583d7219e01228d697f91a16e91ed1f5efe86
Parent:        c90363b585a41de2a65872f9be359db22ee64325
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 10 18:32:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:09:35 2015 +0200

dmeventd: enable new logging

---
 daemons/dmeventd/dmeventd.c |   40 +++++++++++-----------------------------
 1 files changed, 11 insertions(+), 29 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 581ce18..26609db 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -16,14 +16,13 @@
  * dmeventd - dm event daemon to monitor active mapped devices
  */
 
-#include "tool.h"
-
-//#include "libmultilog.h"
 #include "dm-logging.h"
 
 #include "libdevmapper-event.h"
 #include "dmeventd.h"
 
+#include "tool.h"
+
 #include <dlfcn.h>
 #include <pthread.h>
 #include <sys/file.h>
@@ -61,7 +60,6 @@
 
 #endif
 
-/* FIXME We use syslog for now, because multilog is not yet implemented */
 #include <syslog.h>
 
 static volatile sig_atomic_t _exit_now = 0;	/* set to '1' when signal is given to exit */
@@ -114,15 +112,14 @@ static char **_initial_registrations = 0;
 
 /* FIXME Make configurable at runtime */
 #ifdef DEBUG
-#  define DEBUGLOG(fmt, args...) debuglog("[Thr %x]: " fmt, (int)pthread_self(), ## args)
-void debuglog(const char *fmt, ... ) __attribute__ ((format(printf, 1, 2)));
-
-void debuglog(const char *fmt, ...)
+#  define DEBUGLOG  log_debug
+__attribute__((format(printf, 4, 5)))
+static void _dmeventd_log(int level, const char *file, int line,
+			  const char *format, ...)
 {
 	va_list ap;
-
-	va_start(ap, fmt);
-	vsyslog(LOG_DEBUG, fmt, ap);
+	va_start(ap, format);
+	dm_event_log("dm", level, file, line, 0, format, ap);
 	va_end(ap);
 }
 
@@ -634,24 +631,6 @@ static void _unregister_for_timeout(struct thread_status *thread)
 	pthread_mutex_unlock(&_timeout_mutex);
 }
 
-__attribute__((format(printf, 4, 5)))
-static void _no_intr_log(int level, const char *file, int line,
-			const char *f, ...)
-{
-	va_list ap;
-
-	if (errno == EINTR)
-		return;
-	if (level > _LOG_WARN)
-		return;
-
-	va_start(ap, f);
-	vfprintf((level < _LOG_WARN) ? stderr : stdout, f, ap);
-	va_end(ap);
-
-	fputc('\n', (level < _LOG_WARN) ? stderr : stdout);
-}
-
 static sigset_t _unblock_sigalrm(void)
 {
 	sigset_t set, old;
@@ -2139,6 +2118,9 @@ int main(int argc, char *argv[])
 
 	openlog("dmeventd", LOG_PID, LOG_DAEMON);
 
+	dm_event_log_set(_debug_level, _use_syslog);
+	dm_log_init(_dmeventd_log);
+
 	(void) dm_prepare_selinux_context(DMEVENTD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(DMEVENTD_PIDFILE) == 0)
 		exit(EXIT_FAILURE);


