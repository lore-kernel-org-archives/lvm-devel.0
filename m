From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:10:06 +0000 (UTC)
Subject: master - dmstats: separate TIMERFD and useleep() exit conditions
Message-ID: <20161218131006.47A1D60EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5635cd3b0337ac854a82a1a15cef2609c2091e6c
Commit:        5635cd3b0337ac854a82a1a15cef2609c2091e6c
Parent:        886b4f755d7f33194f92dafbf2c22517db4de374
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 12:42:47 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 13:03:44 2016 +0000

dmstats: separate TIMERFD and useleep() exit conditions

The time management code mixes tests of the _timer_fd value with
code that should be timer agnostic: this causes problems for users
of the usleep() timer, since it cannot properly detect the start
of a new interval:

Beginning first interval
Interval     #18446744069414584348     time delta:   1000000000ns
Interval     #18446744069414584348   current err:            0ns
End interval #18446744069414584348  duration:   1000000000ns
Adjusted sample interval duration:   1000000000ns
[...]
Beginning first interval
Interval     #18446744069414584349     time delta:   1000000000ns
Interval     #18446744069414584349   current err:            0ns
End interval #18446744069414584349  duration:   1000000000ns
Adjusted sample interval duration:   1000000000ns

Separate these out, by defining a _timer_running() call that each
timer implements, and only define _timer_fd if we are compiling
with TIMERFD enabled.
---
 tools/dmsetup.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 17c5742..b1967db 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -286,7 +286,9 @@ static struct dm_timestamp *_start_timestamp = NULL;
 static uint64_t _interval = 0; /* configured interval in nsecs */
 static uint64_t _new_interval = 0; /* flag top-of-interval */
 static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
+#ifdef HAVE_SYS_TIMERFD_H
 static int _timer_fd = -1; /* timerfd file descriptor. */
+#endif /* HAVE_SYS_TIMERFD_H */
 
 /* Invalid fd value used to signal end-of-reporting. */
 #define TIMER_STOPPED -2
@@ -647,6 +649,14 @@ static int _do_timer_wait(void)
 	return _do_timerfd_wait();
 }
 
+static int _timer_running(void)
+{
+	/*
+	 * Clock shutdown for exit - nothing to do.
+	 */
+	return ((_timer_fd == TIMER_STOPPED) && !_cycle_timestamp);
+}
+
 #else /* !HAVE_SYS_TIMERFD_H */
 static int _start_usleep_timer(void)
 {
@@ -718,6 +728,11 @@ static int _do_timer_wait(void)
 	return _do_usleep_wait();
 }
 
+static int _timer_running(void)
+{
+	return (_start_timestamp != NULL);
+}
+
 #endif /* HAVE_SYS_TIMERFD_H */
 
 static int _update_interval_times(void)
@@ -729,7 +744,7 @@ static int _update_interval_times(void)
 	/*
 	 * Clock shutdown for exit - nothing to do.
 	 */
-	if ((_timer_fd == TIMER_STOPPED) && !_cycle_timestamp)
+	if (!_timer_running())
 		goto out;
 
 	/* clock is running */
@@ -805,7 +820,7 @@ static int _update_interval_times(void)
 
 out:
 	/* timer stopped or never started */
-	if (!r || _timer_fd < 0) {
+	if (!r || !_timer_running()) {
 		/* The _cycle_timestamp has not yet been allocated if we
 		 * fail to obtain this_timestamp on the first interval.
 		 */


