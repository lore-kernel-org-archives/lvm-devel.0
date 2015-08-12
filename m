From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 12 Aug 2015 14:13:47 +0000 (UTC)
Subject: master - dmsetup: use timerfd for interval timing if available
Message-ID: <20150812141347.E621460FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8b9e2eccdfccd63bc8816cea66f157b0257e351
Commit:        a8b9e2eccdfccd63bc8816cea66f157b0257e351
Parent:        99f55abc56bf1ce6b6f0e7d9cae67e347ace16b2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Aug 8 23:59:06 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Aug 12 15:09:57 2015 +0100

dmsetup: use timerfd for interval timing if available

If the Linux timerfd interface to POSIX timers is available at compile
time use it for all report interval timekeeping. This gives more
accurate interval timing when the per-interval processing time is less
than the configured interval and simplifies the timestamp bookkeeping
required to keep accurate time.

For systems without timerfd support fall back to the simple usleep based
timer.
---
 configure               |    2 +-
 configure.in            |    2 +-
 lib/misc/configure.h.in |    3 +
 tools/dmsetup.c         |  325 +++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 290 insertions(+), 42 deletions(-)

diff --git a/configure b/configure
index b17e5a3..630f12a 100755
--- a/configure
+++ b/configure
@@ -5734,7 +5734,7 @@ fi
 done
 
 
-for ac_header in termios.h sys/statvfs.h
+for ac_header in termios.h sys/statvfs.h sys/timerfd.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
diff --git a/configure.in b/configure.in
index 243b634..c3e55e9 100644
--- a/configure.in
+++ b/configure.in
@@ -103,7 +103,7 @@ AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
   unistd.h], , [AC_MSG_ERROR(bailing out)])
 
-AC_CHECK_HEADERS(termios.h sys/statvfs.h)
+AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h)
 
 case "$host_os" in
 	linux*)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 750c75c..0adb7b1 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -516,6 +516,9 @@
 /* Define to 1 if you have the <sys/time.h> header file. */
 #undef HAVE_SYS_TIME_H
 
+/* Define to 1 if you have the <sys/timerfd.h> header file. */
+#undef HAVE_SYS_TIMERFD_H
+
 /* Define to 1 if you have the <sys/types.h> header file. */
 #undef HAVE_SYS_TYPES_H
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ed3cbd1..9876bd2 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -15,7 +15,6 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-
 #include "tool.h"
 
 #include "dm-logging.h"
@@ -49,6 +48,10 @@
 #  include <sys/ioctl.h>
 #endif
 
+#if HAVE_SYS_TIMERFD_H
+# include <sys/timerfd.h>
+#endif
+
 #if HAVE_TERMIOS_H
 #  include <termios.h>
 #endif
@@ -208,9 +211,15 @@ static uint64_t _disp_factor = 512; /* display sizes in sectors */
 static char _disp_units = 's';
 
 /* report timekeeping */
-static struct dm_timestamp *_ts_start = NULL, *_ts_end = NULL;
-static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
+static struct dm_timestamp *_cycle_timestamp = NULL;
 static uint64_t _interval = 0; /* configured interval in nsecs */
+static uint64_t _new_interval = 0; /* flag top-of-interval */
+static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
+static double _mean_interval = 0.0; /* mean sample interval. */
+static int _timer_fd = -1; /* timerfd file descriptor. */
+
+/* Invalid fd value used to signal end-of-reporting. */
+#define TIMER_STOPPED -2
 
 #define NSEC_PER_USEC	UINT64_C(1000)
 #define NSEC_PER_MSEC	UINT64_C(1000000)
@@ -456,9 +465,266 @@ static void _destroy_split_name(struct dm_split_name *split_name)
 	dm_free(split_name);
 }
 
+/*
+ * Stats clock:
+ *
+ * Use either Linux timerfds or usleep to implement the reporting
+ * interval wait.
+ *
+ *  _start_timer()   - Start the timer running.
+ *  _do_timer_wait() - Wait until the beginning of the next interval.
+ *
+ *  _update_interval_times() - Update timestamps and interval estimate.
+ */
+
+#if HAVE_SYS_TIMERFD_H
+static int _start_timerfd_timer(void)
+{
+	struct itimerspec interval_timer;
+	time_t secs;
+	long nsecs;
+
+	log_debug("Using timerfd for interval timekeeping.");
+
+	/* timer running? */
+	if (_timer_fd != -1)
+		return 1;
+
+	memset(&interval_timer, 0, sizeof(interval_timer));
+
+	/* Use CLOCK_MONOTONIC to avoid warp on RTC adjustments. */
+	if ((_timer_fd = timerfd_create(CLOCK_MONOTONIC, TFD_CLOEXEC)) < 0) {
+		log_error("Could not create timer: %s", strerror(errno));
+		return 0;
+	}
+
+	secs = (time_t) _interval / NSEC_PER_SEC;
+	nsecs = (long) _interval % NSEC_PER_SEC;
+
+	/* Must set interval and value to create an armed periodic timer. */
+	interval_timer.it_interval.tv_sec = secs;
+	interval_timer.it_interval.tv_nsec = nsecs;
+	interval_timer.it_value.tv_sec = secs;
+	interval_timer.it_value.tv_nsec = nsecs;
+
+	log_debug("Setting interval timer to: "FMTu64"s "FMTu64"ns", secs, nsecs);
+	if (timerfd_settime(_timer_fd, 0, &interval_timer, NULL)) {
+		log_error("Could not set interval timer: %s", strerror(errno));
+		return 0;
+	}
+	return 1;
+}
+
+static int _do_timerfd_wait(void)
+{
+	uint64_t expired;
+
+	if (_timer_fd < 0)
+		return 0;
+
+	/* read on timerfd returns a uint64_t in host byte order. */
+	if (read(_timer_fd, &expired, sizeof(expired)) < 0) {
+		/* EBADF from invalid timerfd or EINVAL from too small buffer. */
+		log_error("Interval timer wait failed: %s",
+			  strerror(errno));
+		return 0;
+	}
+
+	/* FIXME: attempt to rebase clock? */
+	if (expired > 1)
+		log_warn("WARNING: Try increasing --interval ("FMTu64
+			 " missed timer events).", expired - 1);
+
+	/* Signal that a new interval has begun. */
+	_new_interval = 1;
+
+	/* Final interval? */
+	if (_count == 2) {
+		if (close(_timer_fd))
+			stack;
+		/* Tell _update_interval_times() to shut down. */
+		_timer_fd = TIMER_STOPPED;
+	}
+
+	return 1;
+}
+
+static int _start_timer(void)
+{
+	return _start_timerfd_timer();
+}
+
+static int _do_timer_wait(void)
+{
+	return _do_timerfd_wait();
+}
+
+#else /* !HAVE_SYS_TIMERFD_H */
+static int _start_usleep_timer(void)
+{
+	log_debug("Using usleep for interval timekeeping.");
+	return 1;
+}
+
+static int _do_usleep_wait(void)
+{
+	static struct dm_timestamp *_last_sleep, *_now = NULL;
+	uint64_t this_interval;
+	int64_t delta_t;
+
+	/*
+	 * Report clock: compensate for time spent in userspace and stats
+	 * message ioctls by keeping track of the last wake time and
+	 * adjusting the sleep interval accordingly.
+	 */
+	if (!_last_sleep && !_now) {
+		if (!(_last_sleep = dm_timestamp_alloc()))
+			goto_out;
+		if (!(_now = dm_timestamp_alloc()))
+			goto_out;
+		dm_timestamp_get(_now);
+		this_interval = _interval;
+		log_error("Using "FMTu64" as first interval.", this_interval);
+	} else {
+		dm_timestamp_get(_now);
+		delta_t = dm_timestamp_delta(_now, _last_sleep);
+		log_debug("Interval timer delta_t: "FMTi64, delta_t);
+
+		/* FIXME: usleep timer drift over large counts. */
+
+		/* adjust for time spent populating and reporting */
+		this_interval = 2 * _interval - delta_t;
+		log_debug("Using "FMTu64" as interval.", this_interval);
+	}
+
+	/* Signal that a new interval has begun. */
+	_new_interval = 1;
+	dm_timestamp_copy(_last_sleep, _now);
+
+	if (usleep(this_interval / NSEC_PER_USEC)) {
+		if (errno == EINTR)
+			log_error("Report interval interrupted by signal.");
+		if (errno == EINVAL)
+			log_error("Report interval too short.");
+		goto out;
+	}
+
+	if(_count == 2) {
+		dm_timestamp_destroy(_last_sleep);
+		dm_timestamp_destroy(_now);
+	}
+
+	return 1;
+out:
+	return 0;
+}
+
+static int _start_timer(void)
+{
+	return _start_usleep_timer();
+}
+
+static int _do_timer_wait(void)
+{
+	return _do_usleep_wait();
+}
+
+#endif /* HAVE_SYS_TIMERFD_H */
+
+static int _update_interval_times(void)
+{
+	static struct dm_timestamp *this_timestamp = NULL;
+	uint64_t delta_t;
+	int r = 0;
+
+	/*
+         * Current timestamp. If _new_interval is set this is used as
+         * the new cycle start timestamp.
+	 */
+	if (!this_timestamp) {
+		if (!(this_timestamp = dm_timestamp_alloc()))
+			return_0;
+	}
+
+	/*
+	 * Take cycle timstamp as close as possible to ioctl return.
+	 *
+	 * FIXME: use per-region timestamp deltas for interval estimate.
+	 */
+	if (!dm_timestamp_get(this_timestamp))
+		goto_out;
+
+	/*
+	 * Stats clock: maintain a single timestamp taken just after the
+	 * call to dm_stats_populate() and take a delta between the current
+	 * and last value to determine the sampling interval.
+	 *
+	 * A new interval is started when the _new_interval flag is set
+	 * on return from _do_report_wait().
+	 *
+	 * The first interval is treated as a special case: since the
+	 * time since the last clear of the counters is unknown (no
+	 * previous timestamp exists) the duration is assumed to be the
+	 * configured value.
+	 */
+	if (_cycle_timestamp)
+		/* Current delta_t: time from start of cycle to now. */
+		delta_t = dm_timestamp_delta(this_timestamp, _cycle_timestamp);
+	else {
+		_cycle_timestamp = dm_timestamp_alloc();
+		if (!_cycle_timestamp) {
+			log_error("Could not allocate timestamp object.");
+			goto out;
+		}
+
+		/* Pretend we have the configured interval. */
+		delta_t = _interval;
+		_mean_interval = (double) delta_t;
+
+		/* start the first cycle */
+		log_debug("Beginning first interval");
+		_new_interval = 1;
+	}
+
+	log_debug("Checking for interval end, dt="FMTu64, delta_t);
+	if (_new_interval) {
+		/* Update timestamp and interval and clear _new_interval */
+		dm_timestamp_copy(_cycle_timestamp, this_timestamp);
+		_last_interval = delta_t;
+		_new_interval = 0;
+
+		/* Track mean interval estimate. */
+		_mean_interval = ((double) delta_t + _mean_interval) / 2.0;
+
+		/*
+		 * Log interval duration, mean interval, the last interval
+		 * error and the difference between the mean and configured
+		 * intervals.
+		 */
+		log_debug("Ending interval, I="FMTu64" Imean=%f, Ierr="FMTi64
+			  ", Emean=%.2f", _last_interval, _mean_interval,
+			  ((int64_t)_last_interval - (int64_t)_interval),
+			  _mean_interval - (double) _interval);
+	}
+
+	r = 1;
+
+out:
+	if (!r || _timer_fd == TIMER_STOPPED) {
+		/* The _cycle_timestamp has not yet been allocated if we
+		 * fail to obtain this_timestamp on the first interval.
+		 */
+		if (_cycle_timestamp)
+			dm_timestamp_destroy(_cycle_timestamp);
+		dm_timestamp_destroy(this_timestamp);
+	}
+	return r;
+}
+
 static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dmsetup_report_obj obj;
+
 	int r = 0;
 
 	if (!info->exists) {
@@ -497,13 +763,17 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		if (!(obj.stats = dm_stats_create(DM_STATS_PROGRAM_ID)))
 			goto_out;
 
-		/* FIXME: use a single timestamp to measure _last_interval. */
-		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
-
 		dm_stats_bind_devno(obj.stats, info->major, info->minor);
-		if (!(dm_stats_populate(obj.stats, DM_STATS_PROGRAM_ID, DM_STATS_REGIONS_ALL))) {
+
+		if (!(dm_stats_populate(obj.stats, DM_STATS_PROGRAM_ID, DM_STATS_REGIONS_ALL)))
 			goto out;
-		}
+
+		/* Update timestamps and handle end-of-interval accounting. */
+		_update_interval_times();
+
+		log_debug("Setting interval, I="FMTu64, _last_interval);
+		/* use measured approximation for calculations */
+		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
 	}
 
 	/*
@@ -5416,26 +5686,7 @@ static int _perform_command_for_all_repeatable_args(CMD_ARGS)
 
 static int _do_report_wait(void)
 {
-	if (!dm_timestamp_get(_ts_start))
-		goto_out;
-
-	/* FIXME: compensate for interval drift from time spent reporting. */
-	if (usleep((useconds_t) (_interval / NSEC_PER_USEC))) {
-		if (errno == EINTR)
-			log_error("Report interval interrupted by signal.");
-		if (errno == EINVAL)
-			log_error("Report interval too short.");
-		goto out;
-	}
-
-	if (!dm_timestamp_get(_ts_end))
-		goto_out;
-
-	_last_interval = dm_timestamp_delta(_ts_end, _ts_start);
-
-	return 1;
-out:
-	return 0;
+	return _do_timer_wait();
 }
 
 int main(int argc, char **argv)
@@ -5553,14 +5804,11 @@ unknown:
 		argc--, argv++;
 	}
 
-	_ts_start = dm_timestamp_alloc();
-	_ts_end = dm_timestamp_alloc();
-	if (!_ts_start || !_ts_end) {
-		log_error("Could not allocate timestamp objects.");
-		goto out;
-	}
-	/* Pretend we have the configured interval for the first iteration. */
-	_last_interval = _interval;
+	/* Start interval timer. */
+	if (_count > 1)
+		if (!_start_timer())
+			goto_out;
+
 doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
 			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
@@ -5581,19 +5829,16 @@ doit:
 					goto_out;
 			}
 		}
-
 	} while (--_count);
 
 out:
+
 	if (_report)
 		dm_report_free(_report);
 
 	if (_dtree)
 		dm_tree_free(_dtree);
 
-	dm_timestamp_destroy(_ts_start);
-	dm_timestamp_destroy(_ts_end);
-
 	dm_free(_table);
 
 	if (_initial_timestamp)


