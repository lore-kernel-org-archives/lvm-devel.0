From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 12:56:38 +0000 (UTC)
Subject: master - dmsetup: do not track moving average for interval estimate
Message-ID: <20150814125638.B1DB660275@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8852b25fc7a676720abef99757ec073b882107a6
Commit:        8852b25fc7a676720abef99757ec073b882107a6
Parent:        4d5b618d52f9f26537f8044bd4e6b139032c46c1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 13:52:33 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 13:55:26 2015 +0100

dmsetup: do not track moving average for interval estimate

When run with full verbosity dmsetup or dmstats reports will
output a figure that tracks a moving average over a window of the
last two intervals:

Interval     #3        time delta:    999991087ns
Interval     #3     mean duration:    999907064ns, current err: -8913ns
End interval #3          duration:    999991087ns
Adjusted sample interval duration:    999991087ns

Due to the narrow window this is a very crude estimate and is only
of use to someone debugging or modifying the stats clock: remove
the value and the global variables used to track it.

Anyone with a particular use for this information can construct a
better mean by calculating the value of a greater number of
intervals.
---
 tools/dmsetup.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5472985..d386ca3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -261,7 +261,6 @@ static struct dm_timestamp *_cycle_timestamp = NULL;
 static uint64_t _interval = 0; /* configured interval in nsecs */
 static uint64_t _new_interval = 0; /* flag top-of-interval */
 static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
-static double _mean_interval = 0.0; /* mean sample interval. */
 static int _timer_fd = -1; /* timerfd file descriptor. */
 
 /* Invalid fd value used to signal end-of-reporting. */
@@ -739,7 +738,6 @@ static int _update_interval_times(void)
 
 		/* Pretend we have the configured interval. */
 		delta_t = _interval;
-		_mean_interval = (double) delta_t;
 
 		/* start the first cycle */
 		log_debug("Beginning first interval");
@@ -755,16 +753,11 @@ static int _update_interval_times(void)
 		_last_interval = delta_t;
 		_new_interval = 0;
 
-		/* Track mean interval estimate. */
-		_mean_interval = ((double) delta_t + _mean_interval) / 2.0;
-
 		/*
-		 * Log interval duration, mean duration and interval error.
+		 * Log interval duration and current error.
 		 */
-		log_debug("Interval     #%-5"PRIu64" mean duration: %12.0fns, "
-			  "current err: "FMTi64"ns", interval_num,
-			  _mean_interval, ((int64_t)_last_interval
-					   - (int64_t)_interval));
+		log_debug("Interval     #%-5"PRIu64"   current err: %12"PRIi64"ns",
+			  interval_num, ((int64_t)_last_interval - (int64_t)_interval));
 		log_debug("End interval #%-9"PRIu64"  duration: %12"PRIu64"ns",
 			  interval_num, _last_interval);
 	}


