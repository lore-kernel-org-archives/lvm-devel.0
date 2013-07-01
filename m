From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:19 +0000 (UTC)
Subject: master - dmeventd: move code from signal handler
Message-ID: <20130701211319.58789610D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd399d52a920b2b2974e53f2f36524fa7431033f
Commit:        fd399d52a920b2b2974e53f2f36524fa7431033f
Parent:        0ca168813437375d8dc96326b0d74f97f3866b5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 15:53:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:06:11 2013 +0200

dmeventd: move code from signal handler

Instead of calling syslog() from signal event handler,
run all logging code in the main loop.

Also it needs to take the lock and check for list
only when really needed.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   41 +++++++++++++++++++----------------------
 2 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c4bdcbf..4819a0b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Move syslog code out of signal handle in dmeventd.
   Add DM_TO_STRING public macro.
   Always return success on dmeventd -V command call.
   Fix parsing of 64bit snapshot status in dmeventd snapshot plugin.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b912ead..9c5757e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -68,7 +68,6 @@
 #include <syslog.h>
 
 static volatile sig_atomic_t _exit_now = 0;	/* set to '1' when signal is given to exit */
-static volatile sig_atomic_t _thread_registries_empty = 1;	/* registries are empty initially */
 
 /* List (un)link macros. */
 #define	LINK(x, head)		dm_list_add(head, &(x)->list)
@@ -1602,19 +1601,7 @@ static void _init_thread_signals(void)
  */
 static void _exit_handler(int sig __attribute__((unused)))
 {
-	/*
-	 * We exit when '_exit_now' is set.
-	 * That is, when a signal has been received.
-	 *
-	 * We can not simply set '_exit_now' unless all
-	 * threads are done processing.
-	 */
-	if (!_thread_registries_empty) {
-		syslog(LOG_ERR, "There are still devices being monitored.");
-		syslog(LOG_ERR, "Refusing to exit.");
-	} else
-		_exit_now = 1;
-
+	_exit_now = 1;
 }
 
 #ifdef linux
@@ -1918,6 +1905,7 @@ int main(int argc, char *argv[])
 {
 	signed char opt;
 	struct dm_event_fifos fifos;
+	int nothreads;
 	//struct sys_log logdata = {DAEMON_NAME, LOG_DAEMON};
 
 	opterr = 0;
@@ -2008,16 +1996,25 @@ int main(int argc, char *argv[])
 	if (_initial_registrations)
 		_process_initial_registrations();
 
-	while (!_exit_now) {
+	for (;;) {
+		if (_exit_now) {
+			_exit_now = 0;
+			/*
+			 * When '_exit_now' is set, signal has been received,
+			 * but can not simply exit unless all
+			 * threads are done processing.
+			 */
+			_lock_mutex();
+			nothreads = (dm_list_empty(&_thread_registry) &&
+				     dm_list_empty(&_thread_registry_unused));
+			_unlock_mutex();
+			if (nothreads)
+				break;
+			syslog(LOG_ERR, "There are still devices being monitored.");
+			syslog(LOG_ERR, "Refusing to exit.");
+		}
 		_process_request(&fifos);
 		_cleanup_unused_threads();
-		_lock_mutex();
-		if (!dm_list_empty(&_thread_registry)
-		    || !dm_list_empty(&_thread_registry_unused))
-			_thread_registries_empty = 0;
-		else
-			_thread_registries_empty = 1;
-		_unlock_mutex();
 	}
 
 	_exit_dm_lib();


