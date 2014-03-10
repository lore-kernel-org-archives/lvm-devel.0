From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:26:58 +0000 (UTC)
Subject: master - dmeventd: remember number of log disablings
Message-ID: <20140310112658.7DC4460CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a9b62c7f9948238f4ba8f60546b2fb1ae44c2c6
Commit:        2a9b62c7f9948238f4ba8f60546b2fb1ae44c2c6
Parent:        460c19df621d35260caceec7f598da1566263cd4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 09:47:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:22:47 2014 +0100

dmeventd: remember number of log disablings

Individual events are handled through separate threads,
so once we have more then a single thread in this eventwait
sleeping, we got race on the dm_log setting, since
if one event is timeout out on alarm, while another is still waiting,
then dm log has been restored to NULL and the next sigalarm
has been reported as error.

Fix it by introducing counter which is protected via mutex,
and only when the last event is released, logging is restored.

TODO: libdm seems to have some static vars which may audit
for this type of use.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 32c2265..e470cd2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Fix dmeventd logging with parallel wait event processing.
   Reuse _node_send_messages() for validation of transaction_id in preload.
   Transaction_id could be lower by one only when messages are prepared.
   Do not call callback when preload fails.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4a17fb2..f27444c 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -661,6 +661,7 @@ static sigset_t _unblock_sigalrm(void)
 /* Wait on a device until an event occurs. */
 static int _event_wait(struct thread_status *thread, struct dm_task **task)
 {
+	static unsigned _in_event_counter = 0;
 	sigset_t set;
 	int ret = DM_WAIT_RETRY;
 	struct dm_task *dmt;
@@ -677,12 +678,20 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	    !dm_task_set_event_nr(dmt, thread->event_nr))
 		goto out;
 
+	_lock_mutex();
+	/*
+	 * Check if there are already some waiting events,
+	 * in this case the logging is unmodified.
+	 * TODO: audit libdm thread usage
+	 */
+	if (!_in_event_counter++)
+		dm_log_init(_no_intr_log);
+	_unlock_mutex();
 	/*
 	 * This is so that you can break out of waiting on an event,
 	 * either for a timeout event, or to cancel the thread.
 	 */
 	set = _unblock_sigalrm();
-	dm_log_init(_no_intr_log);
 	errno = 0;
 	if (dm_task_run(dmt)) {
 		thread->current_events |= DM_EVENT_DEVICE_ERROR;
@@ -706,7 +715,10 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	}
 
 	pthread_sigmask(SIG_SETMASK, &set, NULL);
-	dm_log_init(NULL);
+	_lock_mutex();
+	if (--_in_event_counter == 0)
+		dm_log_init(NULL);
+	_unlock_mutex();
 
       out:
 	if (ret == DM_WAIT_FATAL || ret == DM_WAIT_RETRY) {


