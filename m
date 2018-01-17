From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:38 -0500
Subject: master - dmeventd: add check for result code
Message-ID: <201801171346.w0HDkcWZ029980@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f41935909fec9eb8d64bc04530be2f38866f0b8e
Commit:        f41935909fec9eb8d64bc04530be2f38866f0b8e
Parent:        02621cffb0d5ff72adb8770e26c1b4adb95bd0d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 5 21:08:24 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:44:33 2018 +0100

dmeventd: add check for result code

Check result from pthread_kill.
---
 daemons/dmeventd/dmeventd.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 7ad7f81..8917422 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -754,6 +754,7 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 	struct thread_status *thread;
 	struct timespec timeout;
 	time_t curr_time;
+	int ret;
 
 	DEBUGLOG("Timeout thread starting.");
 	pthread_cleanup_push(_exit_timeout, NULL);
@@ -775,7 +776,10 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 				} else {
 					DEBUGLOG("Sending SIGALRM to Thr %x for timeout.",
 						 (int) thread->thread);
-					pthread_kill(thread->thread, SIGALRM);
+					ret = pthread_kill(thread->thread, SIGALRM);
+					if (ret && (ret != ESRCH))
+						log_error("Unable to wakeup Thr %x for timeout: %s.",
+							  (int) thread->thread, strerror(ret));
 				}
 				_unlock_mutex();
 			}


