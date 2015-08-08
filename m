From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat,  8 Aug 2015 10:49:47 +0000 (UTC)
Subject: master - libdm: remove report interval support
Message-ID: <20150808104947.0F3CA6136C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54815fff0694ab562d041a4de1ee54ac0cd10f48
Commit:        54815fff0694ab562d041a4de1ee54ac0cd10f48
Parent:        666c77c0f27f1ea3d0df411b5ad64719f750c177
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 7 16:15:21 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 8 11:48:12 2015 +0100

libdm: remove report interval support

Don't do interval management and external timekeeping for stats in
dm_report: let applications handle this on their own.

Since this has not been included in a release remove it from the
library entirely and handle report timing directly inside dmsetup.
---
 libdm/.exported_symbols.DM_1_02_104 |    5 ---
 libdm/libdevmapper.h                |   44 --------------------------------
 libdm/libdm-report.c                |   44 --------------------------------
 tools/dmsetup.c                     |   47 +++++++++++++++++++++++++++++++---
 4 files changed, 42 insertions(+), 98 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 2ec5689..ba290e8 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -1,9 +1,4 @@
 dm_report_column_headings
-dm_report_get_interval_ms
-dm_report_get_interval_ns
-dm_report_set_interval_ms
-dm_report_set_interval_ns
-dm_report_wait
 dm_size_to_string
 dm_task_get_ioctl_timestamp
 dm_task_set_record_timestamp
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2289d12..895fbe6 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1941,50 +1941,6 @@ int dm_report_field_percent(struct dm_report *rh, struct dm_report_field *field,
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
-/*
- * Set an interval (in nanoseconds) for this dm_report object that will
- * be used by any subsequent call to dm_report_wait_interval. This is
- * only useful for repeating reports (e.g. statistics).
- *
- * The default value is zero: no interval.
- */
-void dm_report_set_interval_ns(struct dm_report *rh, uint64_t interval_ns);
-
-/*
- * Set an interval in milliseconds for this dm_report object that will
- * be used by any subsequent call to dm_report_wait. This is only
- * useful for repeating reports (e.g. statistics).
- *
- * The default value is zero: no interval.
- */
-void dm_report_set_interval_ms(struct dm_report *rh, uint64_t interval_ms);
-
-/*
- * Retrieve the configured interval of the dm_report handle rh in
- * nanoseconds.
- */
-uint64_t dm_report_get_interval_ns(struct dm_report *rh);
-
-/*
- * Retrieve the configured interval of the dm_report handle rh in
- * milliseconds.
- */
-uint64_t dm_report_get_interval_ms(struct dm_report *rh);
-
-/*
- * Suspend the calling thread until the current reporting interval
- * expires. When this function returns the caller should obtain updated
- * report data and call dm_report_object() and dm_report_output() as
- * necessary in order to produce the new interval's reporting output.
- *
- * Delivery of a non-blocked signal to the thread carrying out the
- * wait will cause the function to return prematurely with an error.
- *
- * Attempting to wait on a report that has no interval set is also
- * treated as an error.
- */
-int dm_report_wait(struct dm_report *rh);
-
 /*************************
  * config file parse/print
  *************************/
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 4b09854..de87ca4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -49,8 +49,6 @@ struct dm_report {
 	uint32_t flags;
 	const char *separator;
 
-	uint64_t interval_ns;	/* Reporting interval in nanoseconds */
-
 	uint32_t keys_count;
 
 	/* Ordered list of fields needed for this report */
@@ -4317,45 +4315,3 @@ int dm_report_output(struct dm_report *rh)
 	else
 		return _output_as_columns(rh);
 }
-
-#define NSEC_PER_USEC	UINT64_C(1000)
-#define NSEC_PER_MSEC	UINT64_C(1000000)
-#define NSEC_PER_SEC	UINT64_C(1000000000)
-
-void dm_report_set_interval_ns(struct dm_report *rh, uint64_t interval_ns)
-{
-	rh->interval_ns = interval_ns;
-}
-
-void dm_report_set_interval_ms(struct dm_report *rh, uint64_t interval_ms)
-{
-	rh->interval_ns = interval_ms * NSEC_PER_MSEC;
-}
-
-uint64_t dm_report_get_interval_ns(struct dm_report *rh)
-{
-	return rh->interval_ns;
-}
-
-uint64_t dm_report_get_interval_ms(struct dm_report *rh)
-{
-	return (rh->interval_ns / NSEC_PER_MSEC);
-}
-
-int dm_report_wait(struct dm_report *rh)
-{
-	int r = 1;
-
-	if (!rh->interval_ns)
-		return_0;
-
-	if (usleep(rh->interval_ns / NSEC_PER_USEC)) {
-		if (errno == EINTR)
-			log_error("Report interval interrupted by signal.");
-		if (errno == EINVAL)
-			log_error("Report interval too short.");
-		r = 0;
-	}
-
-	return r;
-}
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 3d675fd..12e6fa9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -186,6 +186,9 @@ static report_type_t _report_type;
 static dev_name_t _dev_name_type;
 static uint32_t _count = 1; /* count of repeating reports */
 static struct dm_timestamp *_initial_timestamp = NULL;
+static struct dm_timestamp *_ts_start = NULL, *_ts_end = NULL;
+static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
+static uint64_t _interval = 0; /* configured interval in nsecs */
 
 #define NSEC_PER_USEC	UINT64_C(1000)
 #define NSEC_PER_MSEC	UINT64_C(1000000)
@@ -2871,7 +2874,6 @@ static int _report_init(const struct command *cmd)
 	int aligned = 1, headings = 1, buffered = 1, field_prefixes = 0;
 	int quoted = 1, columns_as_rows = 0;
 	uint32_t flags = 0;
-	uint32_t interval;
 	size_t len = 0;
 	int r = 0;
 
@@ -2963,10 +2965,10 @@ static int _report_init(const struct command *cmd)
 		goto out;
 	}
 
-	/* Default interval is 1 second. */
-	interval = _switches[INTERVAL_ARG] ? _int_args[INTERVAL_ARG] : 1;
+	if (!_switches[INTERVAL_ARG])
+		_int_args[INTERVAL_ARG] = 1; /* 1s default. */
 
-	dm_report_set_interval_ns(_report, NSEC_PER_SEC * interval);
+	_interval = NSEC_PER_SEC * _int_args[INTERVAL_ARG];
 
 	if (field_prefixes)
 		dm_report_set_output_field_name_prefix(_report, "dm_");
@@ -3874,6 +3876,29 @@ static int _perform_command_for_all_repeatable_args(CMD_ARGS)
 	return 0;
 }
 
+static int _do_report_wait(void)
+{
+	if (!dm_timestamp_get(_ts_start))
+		goto_out;
+
+	if (usleep(_interval / NSEC_PER_USEC)) {
+		if (errno == EINTR)
+			log_error("Report interval interrupted by signal.");
+		if (errno == EINVAL)
+			log_error("Report interval too short.");
+		goto out;
+	}
+
+	if (!dm_timestamp_get(_ts_end))
+		goto_out;
+
+	_last_interval = dm_timestamp_delta(_ts_end, _ts_start);
+
+	return 1;
+out:
+	return 0;
+}
+
 int main(int argc, char **argv)
 {
 	int r = 1;
@@ -3962,6 +3987,16 @@ unknown:
 		argc--, argv++;
 	}
 
+	if (_count > 1) {
+		_ts_start = dm_timestamp_alloc();
+		_ts_end = dm_timestamp_alloc();
+		if (!_ts_start || !_ts_end) {
+			log_error("Could not allocate timestamp objects.");
+			goto out;
+		}
+		/* Pretend we have the configured interval for the first iteration. */
+		_last_interval = _interval;
+	}
 doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
 			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
@@ -3976,7 +4011,9 @@ doit:
 
 			if (_count > 1) {
 				printf("\n");
-				dm_report_wait(_report);
+				/* wait for --interval and update timestamps */
+				if (!_do_report_wait())
+					goto_out;
 			}
 		}
 	} while (--_count);


