From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:10:04 +0000 (UTC)
Subject: master - dmstats: use better interval estimate for usleep() timer
Message-ID: <20161218131004.3717860EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=886b4f755d7f33194f92dafbf2c22517db4de374
Commit:        886b4f755d7f33194f92dafbf2c22517db4de374
Parent:        68ec42ebaf288911b1cb95882678ca778b795953
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 12:39:26 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 13:03:44 2016 +0000

dmstats: use better interval estimate for usleep() timer

Although the usleep() interval timer is not used if the Linux
TIMERFD interface is available it should still provide reasonably
good timing.

Instead of trying to estimate the error from the duration of the
last sleep, peg it to the start time of the program, and use the
value of  ((start_time - now) % interval) to correct the current
interval duration.

This always pulls us back into sync at the end of each interval,
rather than relying on trying to incrementally adjust the time
duration at each interval start.

This greatly reduces drift when the usleep() clock is used.
---
 tools/dmsetup.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1be19d5..17c5742 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -282,6 +282,7 @@ const char *_stats_types[] = {
 
 /* report timekeeping */
 static struct dm_timestamp *_cycle_timestamp = NULL;
+static struct dm_timestamp *_start_timestamp = NULL;
 static uint64_t _interval = 0; /* configured interval in nsecs */
 static uint64_t _new_interval = 0; /* flag top-of-interval */
 static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
@@ -650,12 +651,14 @@ static int _do_timer_wait(void)
 static int _start_usleep_timer(void)
 {
 	log_debug("Using usleep for interval timekeeping.");
+	_start_timestamp = dm_timestamp_alloc();
+	dm_timestamp_get(_start_timestamp);
 	return 1;
 }
 
 static int _do_usleep_wait(void)
 {
-	static struct dm_timestamp *_last_sleep, *_now = NULL;
+	static struct dm_timestamp *_now = NULL;
 	uint64_t this_interval;
 	int64_t delta_t;
 
@@ -664,9 +667,7 @@ static int _do_usleep_wait(void)
 	 * message ioctls by keeping track of the last wake time and
 	 * adjusting the sleep interval accordingly.
 	 */
-	if (!_last_sleep && !_now) {
-		if (!(_last_sleep = dm_timestamp_alloc()))
-			return_0;
+	if (!_now) {
 		if (!(_now = dm_timestamp_alloc()))
 			return_0;
 		dm_timestamp_get(_now);
@@ -674,19 +675,19 @@ static int _do_usleep_wait(void)
 		log_error("Using "FMTu64" as first interval.", this_interval);
 	} else {
 		dm_timestamp_get(_now);
-		delta_t = dm_timestamp_delta(_now, _last_sleep);
-		log_debug("Interval timer delta_t: "FMTi64, delta_t);
+		delta_t = dm_timestamp_delta(_now, _start_timestamp);
+		log_debug("Interval timer drift: "FMTi64,
+			  (delta_t % _interval));
 
 		/* FIXME: usleep timer drift over large counts. */
 
 		/* adjust for time spent populating and reporting */
-		this_interval = 2 * _interval - delta_t;
+		this_interval = _interval - (delta_t % _interval);
 		log_debug("Using "FMTu64" as interval.", this_interval);
 	}
 
 	/* Signal that a new interval has begun. */
 	_new_interval = 1;
-	dm_timestamp_copy(_last_sleep, _now);
 
 	if (usleep(this_interval / NSEC_PER_USEC)) {
 		if (errno == EINTR)
@@ -699,8 +700,9 @@ static int _do_usleep_wait(void)
 	}
 
 	if (_count == 2) {
-		dm_timestamp_destroy(_last_sleep);
+		dm_timestamp_destroy(_start_timestamp);
 		dm_timestamp_destroy(_now);
+		_start_timestamp = _now = NULL;
 	}
 
 	return 1;


