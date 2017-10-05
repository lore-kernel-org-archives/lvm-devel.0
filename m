From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 5 Oct 2017 04:25:58 -0400
Subject: master - dmeventd: schedule exit on break
Message-ID: <201710050825.v958PwCf026273@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9940c2f754e3292b6d96628682c254941ae6cc58
Commit:        9940c2f754e3292b6d96628682c254941ae6cc58
Parent:        a95f656d0df0fb81d68fa27bfee2350953677174
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 4 13:58:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 5 10:19:21 2017 +0200

dmeventd: schedule exit on break

When dmeventd receives SIGTERM/INT/HUP/QUIT it validates if exit is possible.
If there was any device still monitored, such exit request used to
be ignored/refused. This 'usually' worked reasonably well, however if there
is very short time period between last device is unmonitored and signal
reception - there was possibility such EXIT was ignored, as dmeventd has
not yet got into idle state even commands like 'vgchange -an' has already
finished.

This patch changes logic towards scheduling EXIT to the nearest
point when there is no monitored device.

EXIT is never forgotten.

NOTE: if there is only a single monitored device and someone sends
SIGTERM and later someone uses i.e. 'lvchange --refresh' after
unmonitoring dmeventd will exit and new instance needs to be
started.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   13 ++++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5a11e2e..ea01089 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Schedule exit when received SIGTERM in dmeventd.
   Also try to unmount /boot on blkdeactivate -u if on top of supported device.
   Use blkdeactivate -r wait in blk-availability systemd service/initscript.
   Add blkdeactivate -r wait option to wait for MD resync/recovery/reshape.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 3a92ab6..cc520d3 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -62,6 +62,8 @@
 
 #include <syslog.h>
 
+#define DM_SIGNALED_EXIT  1
+#define DM_SCHEDULED_EXIT 2
 static volatile sig_atomic_t _exit_now = 0;	/* set to '1' when signal is given to exit */
 
 /* List (un)link macros. */
@@ -1750,7 +1752,7 @@ static void _init_thread_signals(void)
  */
 static void _exit_handler(int sig __attribute__((unused)))
 {
-	_exit_now = 1;
+	_exit_now = DM_SIGNALED_EXIT;
 }
 
 #ifdef __linux__
@@ -2248,6 +2250,8 @@ int main(int argc, char *argv[])
 	for (;;) {
 		if (_idle_since) {
 			if (_exit_now) {
+				if (_exit_now == DM_SCHEDULED_EXIT)
+					break; /* Only prints shutdown message */
 				log_info("dmeventd detected break while being idle "
 					 "for %ld second(s), exiting.",
 					 (long) (time(NULL) - _idle_since));
@@ -2264,15 +2268,14 @@ int main(int argc, char *argv[])
 					break;
 				}
 			}
-		} else if (_exit_now) {
-			_exit_now = 0;
+		} else if (_exit_now == DM_SIGNALED_EXIT) {
+			_exit_now = DM_SCHEDULED_EXIT;
 			/*
 			 * When '_exit_now' is set, signal has been received,
 			 * but can not simply exit unless all
 			 * threads are done processing.
 			 */
-			log_warn("WARNING: There are still devices being monitored.");
-			log_warn("WARNING: Refusing to exit.");
+			log_info("dmeventd received break, scheduling exit.");
 		}
 		_process_request(&fifos);
 		_cleanup_unused_threads();


