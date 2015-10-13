From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:50 +0000 (UTC)
Subject: master - dmeventd: drop changing logging
Message-ID: <20151013140350.601E161207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13086c2523a00bc8501113f56094312bda4881e1
Commit:        13086c2523a00bc8501113f56094312bda4881e1
Parent:        42a9c8b4a659a44bef1b3150eb6359d562938ca3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 22:08:01 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:15:43 2015 +0200

dmeventd: drop changing logging

As we now use 'unified' logging macro system - we no longer need
to protect from change of logging function pointer - it's set
once at the start of dmeventd and not change anymore
(as lvm2 library no longer interferers here).
---
 daemons/dmeventd/dmeventd.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 6f25379..0acb919 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -648,7 +648,6 @@ static sigset_t _unblock_sigalrm(void)
 /* Wait on a device until an event occurs. */
 static int _event_wait(struct thread_status *thread, struct dm_task **task)
 {
-	static unsigned _in_event_counter = 0;
 	sigset_t set;
 	int ret = DM_WAIT_RETRY;
 	struct dm_task *dmt;
@@ -667,16 +666,11 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	    !dm_task_set_event_nr(dmt, thread->event_nr))
 		goto out;
 
-	_lock_mutex();
 	/*
 	 * Check if there are already some waiting events,
 	 * in this case the logging is unmodified.
 	 * TODO: audit libdm thread usage
 	 */
-	if (!_in_event_counter++)
-		dm_log_init(_dmeventd_log);
-	_unlock_mutex();
-
 	DEBUGLOG("Starting waitevent task for %s", thread->device.uuid);
 	/*
 	 * This is so that you can break out of waiting on an event,
@@ -708,10 +702,6 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	DEBUGLOG("Completed waitevent task for %s", thread->device.uuid);
 
 	pthread_sigmask(SIG_SETMASK, &set, NULL);
-	_lock_mutex();
-	if (--_in_event_counter == 0)
-		dm_log_init(NULL);
-	_unlock_mutex();
 
       out:
 	if (ret == DM_WAIT_FATAL || ret == DM_WAIT_RETRY) {


