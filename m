From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Apr 2020 13:36:25 +0000 (GMT)
Subject: stable-2.02 - dmeventd: enhance time waiting loop
Message-ID: <20200408133625.D87A3385DC0B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d93892d4ae67b355ab6b418c0c404e1536d055f
Commit:        5d93892d4ae67b355ab6b418c0c404e1536d055f
Parent:        8f3d2d5e11305b5f3fc7ced7bd2f81412c9e7d93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 4 15:56:09 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 15:22:54 2020 +0200

dmeventd: enhance time waiting loop

dmeventd is 'scanning' statuses in loop (most usually in 10sec
intervals) - and meanwhile it sleeps within:
pthread_cond_timedwait()

However this function call tends to wakeup sometimes a short amount of
time sooner - and our code still believe the 'right time' has not yet
arrived and basically for a moment 'busy-looped' on calling this
function - so for systems with 'clock_gettime()' present we obtain
time and we go 10ms to the future second - this avoids unneeded
repeated invocation of our time scheduling loop.

TODO: monitoring during 1 hour 'time-change'...
---
 daemons/dmeventd/dmeventd.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 8917422fc..1b84c28ba 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -752,7 +752,7 @@ static void _exit_timeout(void *unused __attribute__((unused)))
 static void *_timeout_thread(void *unused __attribute__((unused)))
 {
 	struct thread_status *thread;
-	struct timespec timeout;
+	struct timespec timeout, real_time;
 	time_t curr_time;
 	int ret;
 
@@ -763,7 +763,16 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 	while (!dm_list_empty(&_timeout_registry)) {
 		timeout.tv_sec = 0;
 		timeout.tv_nsec = 0;
+#ifndef HAVE_REALTIME
 		curr_time = time(NULL);
+#else
+		if (clock_gettime(CLOCK_REALTIME, &real_time)) {
+			log_error("Failed to read clock_gettime().");
+			break;
+		}
+		/* 10ms back to the future */
+		curr_time = real_time.tv_sec + ((real_time.tv_nsec > (1000000000 - 10000000)) ? 1 : 0);
+#endif
 
 		dm_list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {
 			if (thread->next_time <= curr_time) {



