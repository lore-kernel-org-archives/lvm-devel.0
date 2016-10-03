From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:07 +0000 (UTC)
Subject: master - dmeventd: pthread_sigmask in single function
Message-ID: <20161003155107.A2F3960A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00f883a4aa10079bac21c294ce5ed34f11af8ac7
Commit:        00f883a4aa10079bac21c294ce5ed34f11af8ac7
Parent:        d70f1127624fa64ee691eb4c9d4bce5a4845f985
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 15:39:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:47:28 2016 +0200

dmeventd: pthread_sigmask in single function

Integrate back _unblock_sigalrm() and check for error code of
pthread_sigmask() function so we do not use uninitialized
sigmask_t on error path (Coverity).
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   25 ++++++++++---------------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4303dc9..c69eb27 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Check and report pthread_sigmask() failure in dmeventd.
   Check mem alloc fail in _canonicalize_field_ids().
   Use unsigned math when checking more then 31 legs of raid.
   Fix 'dmstats delete' with dmsetup older than v1.02.129
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 25b34a7..6024e56 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -829,17 +829,6 @@ static void _print_sigset(const char *prefix, const sigset_t *sigset)
 }
 #endif
 
-static sigset_t _unblock_sigalrm(void)
-{
-	sigset_t set, old;
-
-	sigemptyset(&set);
-	sigaddset(&set, SIGALRM);
-	pthread_sigmask(SIG_UNBLOCK, &set, &old);
-
-	return old;
-}
-
 enum {
 	DM_WAIT_RETRY,
 	DM_WAIT_INTR,
@@ -849,7 +838,7 @@ enum {
 /* Wait on a device until an event occurs. */
 static int _event_wait(struct thread_status *thread)
 {
-	sigset_t set;
+	sigset_t set, old;
 	int ret = DM_WAIT_RETRY;
 	struct dm_info info;
 
@@ -859,7 +848,12 @@ static int _event_wait(struct thread_status *thread)
 	 * This is so that you can break out of waiting on an event,
 	 * either for a timeout event, or to cancel the thread.
 	 */
-	set = _unblock_sigalrm();
+	sigemptyset(&set);
+	sigaddset(&set, SIGALRM);
+	if (pthread_sigmask(SIG_UNBLOCK, &set, &old) != 0) {
+		log_sys_error("pthread_sigmask", "unblock alarm");
+		return ret; /* What better */
+	}
 
 	if (dm_task_run(thread->wait_task)) {
 		thread->current_events |= DM_EVENT_DEVICE_ERROR;
@@ -883,10 +877,11 @@ static int _event_wait(struct thread_status *thread)
 		}
 	}
 
-	pthread_sigmask(SIG_SETMASK, &set, NULL);
+	if (pthread_sigmask(SIG_SETMASK, &old, NULL) != 0)
+		log_sys_error("pthread_sigmask", "block alarm");
 
 #ifdef DEBUG_SIGNALS
-	_print_sigset("dmeventd blocking ", &set);
+	_print_sigset("dmeventd blocking ", &old);
 #endif
 	DEBUGLOG("Completed waitevent task for %s.", thread->device.name);
 


