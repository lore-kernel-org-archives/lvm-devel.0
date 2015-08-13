From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 13 Aug 2015 18:06:25 +0000 (UTC)
Subject: master - dmsetup: make timekeeping debug messages more readable
Message-ID: <20150813180625.3E97E609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86adb6ca63358ca09d3a886915f30fcec997787f
Commit:        86adb6ca63358ca09d3a886915f30fcec997787f
Parent:        b22b7d7ba9208c5ead5ea6d7353cd903ebb3c075
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Aug 12 19:46:11 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Aug 13 19:05:45 2015 +0100

dmsetup: make timekeeping debug messages more readable

Don't use cryptic abbreviations and make sure that all values can
be understood by someone not familiar with the clock internals.

Include the current interval number (inverse of the _count) in all
interval update messages and attempt to align interval timestamp
logs for interval counts < 99,999.
---
 tools/dmsetup.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4a1a396..3473244 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -482,6 +482,14 @@ static void _destroy_split_name(struct dm_split_name *split_name)
  *  _update_interval_times() - Update timestamps and interval estimate.
  */
 
+/*
+ * Return the current interval number counting upwards from one.
+ */
+static uint64_t _interval_num(void)
+{
+	return 1 + (uint64_t) _int_args[COUNT_ARG] - _count;
+}
+
 #if HAVE_SYS_TIMERFD_H
 static int _start_timerfd_timer(void)
 {
@@ -639,7 +647,7 @@ static int _do_timer_wait(void)
 static int _update_interval_times(void)
 {
 	static struct dm_timestamp *this_timestamp = NULL;
-	uint64_t delta_t;
+	uint64_t delta_t, interval_num = _interval_num();
 	int r = 0;
 
 	/*
@@ -697,7 +705,9 @@ static int _update_interval_times(void)
 		_new_interval = 1;
 	}
 
-	log_debug("Checking for interval end, dt="FMTu64, delta_t);
+	log_debug("Interval     #%-4"PRIu64"     time delta: %12"
+		  PRIu64"ns", interval_num, delta_t);
+
 	if (_new_interval) {
 		/* Update timestamp and interval and clear _new_interval */
 		dm_timestamp_copy(_cycle_timestamp, this_timestamp);
@@ -708,14 +718,14 @@ static int _update_interval_times(void)
 		_mean_interval = ((double) delta_t + _mean_interval) / 2.0;
 
 		/*
-		 * Log interval duration, mean interval, the last interval
-		 * error and the difference between the mean and configured
-		 * intervals.
+		 * Log interval duration, mean duration and interval error.
 		 */
-		log_debug("Ending interval, I="FMTu64" Imean=%f, Ierr="FMTi64
-			  ", Emean=%.2f", _last_interval, _mean_interval,
-			  ((int64_t)_last_interval - (int64_t)_interval),
-			  _mean_interval - (double) _interval);
+		log_debug("Interval     #%-5"PRIu64" mean duration: %12.0fns, "
+			  "current err: "FMTi64"ns", interval_num,
+			  _mean_interval, ((int64_t)_last_interval
+					   - (int64_t)_interval));
+		log_debug("End interval #%-9"PRIu64"  duration: %12"PRIu64"ns",
+			  interval_num, _last_interval);
 	}
 
 	r = 1;
@@ -785,7 +795,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		/* Update timestamps and handle end-of-interval accounting. */
 		_update_interval_times();
 
-		log_debug("Setting interval, I="FMTu64, _last_interval);
+		log_debug("Adjusted sample interval duration: %12"PRIu64"ns", _last_interval);
 		/* use measured approximation for calculations */
 		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
 	}


