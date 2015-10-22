From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:02 +0000 (UTC)
Subject: master - dmeventd: handle signal from plugin
Message-ID: <20151022213402.828D96057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12aa56d29867b962257d7d2789a661a22c649347
Commit:        12aa56d29867b962257d7d2789a661a22c649347
Parent:        9156c5d0888bf95b79d931682b51fc63c96ba236
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 15:48:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:40:07 2015 +0200

dmeventd: handle signal from plugin

Add support to unmonitor device when monitor recognizes there is
nothing to monitor anymore.

TODO: possibly API change with return value could be also used.
---
 WHATS_NEW_DM                |    3 ++-
 daemons/dmeventd/dmeventd.c |   11 +++++++++++
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8c27139..8524a6d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,7 @@
 Version 1.02.110 - 
 ======================================
-  New design for thread cooperation in dmeventd.
+  Add support to allow unmonitor device from plugin itself.
+  New design for thread co-operation in dmeventd.
   Dmeventd read device status with 'noflush'.
   Dmeventd closes control device when no device is monitored.
   Thin plugin for dmeventd improved percentage usage.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index d8c317e..2706ad6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -973,6 +973,17 @@ static void *_monitor_thread(void *arg)
 
 			_lock_mutex();
 			thread->processing = 0;
+
+			/*
+			 * Thread can terminate itself from plugin via SIGALRM
+			 * Timer thread will not send signal while processing
+			 * TODO: maybe worth API change and return value for
+			 *       _do_process_event() instead of this signal solution
+			 */
+			if (sigpending(&pendmask) < 0)
+				log_sys_error("sigpending", "");
+			else if (sigismember(&pendmask, SIGALRM))
+				break;
 		} else {
 			_unlock_mutex();
 


