From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:08 +0000 (UTC)
Subject: master - dmeventd: exit on idle
Message-ID: <20151022213408.DBDF16057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2af696c32f99b2951bcc7e2a73130e46dc4f383f
Commit:        2af696c32f99b2951bcc7e2a73130e46dc4f383f
Parent:        4284ba65ebe6401b2dbedc9abe850b650ed68f93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 20:36:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:43:03 2015 +0200

dmeventd: exit on idle

Implementing exit when 'dmeventd' is idle.
Default idle timeout set to 1 hour - after this time period
dmeventd will cleanly exit.

On systems with 'systemd' - service is automatically started with
next contact on dmeventd communication socket/fifo.

On other systems - new dmeventd starts again when lvm2 command detects
its missing and monitoring is needed.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   35 +++++++++++++++++++++++++++--------
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8524a6d..910f6d6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Support exit on idle for dmenventd (1 hour).
   Add support to allow unmonitor device from plugin itself.
   New design for thread co-operation in dmeventd.
   Dmeventd read device status with 'noflush'.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index a7c1c6e..606ef30 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -87,11 +87,15 @@ static pthread_mutex_t _global_mutex;
 
 static const size_t THREAD_STACK_SIZE = 300 * 1024;
 
+/* Default idle exit timeout 1 hour (in seconds) */
+static const time_t DMEVENTD_IDLE_EXIT_TIMEOUT = 60 * 60;
+
 static int _debug_level = 0;
 static int _use_syslog = 1;
 static int _systemd_activation = 0;
 static int _foreground = 0;
 static int _restart = 0;
+static time_t _idle_since = 0;
 static char **_initial_registrations = 0;
 
 /* FIXME Make configurable at runtime */
@@ -279,6 +283,7 @@ static void _lib_put(struct dso_data *data)
 			DEBUGLOG("Unholding control device.");
 			dm_hold_control_dev(0);
 			dm_lib_release();
+			_idle_since = time(NULL);
 		}
 	}
 }
@@ -346,6 +351,7 @@ static struct dso_data *_load_dso(struct message_data *data)
 	if (dm_list_empty(&_dso_registry)) {
 		DEBUGLOG("Holding control device open.");
 		dm_hold_control_dev(1);
+		_idle_since = 0;
 	}
 
 	/*
@@ -2106,7 +2112,7 @@ int main(int argc, char *argv[])
 		.client_path = DM_EVENT_FIFO_CLIENT,
 		.server_path = DM_EVENT_FIFO_SERVER
 	};
-	int nothreads;
+	time_t now, idle_exit_timeout = DMEVENTD_IDLE_EXIT_TIMEOUT;
 	//struct sys_log logdata = {DAEMON_NAME, LOG_DAEMON};
 
 	opterr = 0;
@@ -2197,23 +2203,36 @@ int main(int argc, char *argv[])
 		kill(getppid(), SIGTERM);
 	log_notice("dmeventd ready for processing.");
 
+	_idle_since = time(NULL);
+
 	if (_initial_registrations)
 		_process_initial_registrations();
 
 	for (;;) {
-		if (_exit_now) {
+		if (_idle_since) {
+			if (_exit_now) {
+				log_info("dmeventd detected break while being idle "
+					 "for %ld second(s), exiting.",
+					 (long) (time(NULL) - _idle_since));
+				break;
+			} else if (idle_exit_timeout) {
+				now = time(NULL);
+				if (now < _idle_since)
+					_idle_since = now; /* clock change? */
+				now -= _idle_since;
+				if (now >= idle_exit_timeout) {
+					log_info("dmeventd was idle for %ld second(s), "
+						 "exiting.", (long) now);
+					break;
+				}
+			}
+		} else if (_exit_now) {
 			_exit_now = 0;
 			/*
 			 * When '_exit_now' is set, signal has been received,
 			 * but can not simply exit unless all
 			 * threads are done processing.
 			 */
-			_lock_mutex();
-			nothreads = (dm_list_empty(&_thread_registry) &&
-				     dm_list_empty(&_thread_registry_unused));
-			_unlock_mutex();
-			if (nothreads)
-				break;
 			log_warn("WARNING: There are still devices being monitored.");
 			log_warn("WARNING: Refusing to exit.");
 		}


