From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  5 Aug 2015 07:30:32 +0000 (UTC)
Subject: master - dmsetup: Report timestamps of ioctls with -vvv.
Message-ID: <20150805073032.9855660E1D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=559ca8bc6593a9ef0b0b012ff0933b80f5d3e367
Commit:        559ca8bc6593a9ef0b0b012ff0933b80f5d3e367
Parent:        2f334afb9836a792fd4e277d02ad6f317faa78ab
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 5 08:28:35 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 5 08:28:35 2015 +0100

dmsetup: Report timestamps of ioctls with -vvv.

If enabled, record timestamp immediately after the ioctl() returns.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_104 |    2 +
 libdm/ioctl/libdm-iface.c           |   31 ++++++++++++++++-
 libdm/ioctl/libdm-targets.h         |    2 +
 libdm/libdevmapper.h                |    9 ++++-
 libdm/libdm-common.c                |    1 +
 libdm/libdm-timestamp.c             |    4 ++
 tools/dmsetup.c                     |   63 ++++++++++++++++++++++++++---------
 8 files changed, 93 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 57cfce4..c0cdadc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.104 -
 =================================
+  Report timestamps of ioctls with dmsetup -vvv.
   Recognize report field name variants without any underscores too.
   Add dmsetup --interval and --count to repeat reports at specified intervals.
   Add report interval and waiting functions to libdevmapper.
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 0039419..ec5c50b 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -4,6 +4,8 @@ dm_report_set_interval_ms
 dm_report_set_interval_ns
 dm_report_wait
 dm_size_to_string
+dm_task_get_ioctl_timestamp
+dm_task_set_record_timestamp
 dm_timestamp_alloc
 dm_timestamp_compare
 dm_timestamp_delta
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index e3b33b8..73af12b 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -68,6 +68,7 @@ static unsigned _dm_version = DM_VERSION_MAJOR;
 static unsigned _dm_version_minor = 0;
 static unsigned _dm_version_patchlevel = 0;
 static int _log_suppress = 0;
+static struct dm_timestamp *_dm_ioctl_timestamp = NULL;
 
 /*
  * If the kernel dm driver only supports one major number
@@ -919,6 +920,24 @@ int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr)
 	return 1;
 }
 
+int dm_task_set_record_timestamp(struct dm_task *dmt)
+{
+	if (!_dm_ioctl_timestamp)
+		_dm_ioctl_timestamp = dm_timestamp_alloc();
+
+	if (!_dm_ioctl_timestamp)
+		return_0;
+
+	dmt->record_timestamp = 1;
+
+	return 1;
+}
+
+struct dm_timestamp *dm_task_get_ioctl_timestamp(struct dm_task *dmt)
+{
+	return dmt->record_timestamp ? _dm_ioctl_timestamp : NULL;
+}
+
 struct target *create_target(uint64_t start, uint64_t len, const char *type,
 			     const char *params)
 {
@@ -1716,6 +1735,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 {
 	struct dm_ioctl *dmi;
 	int ioctl_with_uevent;
+	int r;
 
 	dmt->ioctl_errno = 0;
 
@@ -1803,8 +1823,13 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			     dmt->sector, _sanitise_message(dmt->message),
 			     dmi->data_size, retry_repeat_count);
 #ifdef DM_IOCTLS
-	if (ioctl(_control_fd, command, dmi) < 0 &&
-	    dmt->expected_errno != errno) {
+	r = ioctl(_control_fd, command, dmi);
+
+	if (dmt->record_timestamp)
+		if (!dm_timestamp_get(_dm_ioctl_timestamp))
+			stack;
+
+	if (r < 0 && dmt->expected_errno != errno) {
 		dmt->ioctl_errno = errno;
 		if (dmt->ioctl_errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
 						  (dmt->type == DM_DEVICE_MKNODES) ||
@@ -2049,6 +2074,8 @@ repeat_ioctl:
 void dm_lib_release(void)
 {
 	_close_control_fd();
+	dm_timestamp_destroy(_dm_ioctl_timestamp);
+	_dm_ioctl_timestamp = NULL;
 	update_devs();
 }
 
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 5545459..a3c1cb7 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -70,6 +70,8 @@ struct dm_task {
 	int expected_errno;
 	int ioctl_errno;
 
+	int record_timestamp;
+
 	char *uuid;
 	char *mangled_uuid;
 };
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 4a1703e..ed9a79e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -128,6 +128,7 @@ enum {
  */
 
 struct dm_task;
+struct dm_timestamp;
 
 struct dm_task *dm_task_create(int type);
 void dm_task_destroy(struct dm_task *dmt);
@@ -229,6 +230,12 @@ int dm_task_retry_remove(struct dm_task *dmt);
 int dm_task_deferred_remove(struct dm_task *dmt);
 
 /*
+ * Record timestamp immediately after the ioctl returns.
+ */
+int dm_task_set_record_timestamp(struct dm_task *dmt);
+struct dm_timestamp *dm_task_get_ioctl_timestamp(struct dm_task *dmt);
+
+/*
  * Enable checks for common mistakes such as issuing ioctls in an unsafe order.
  */
 int dm_task_enable_checks(struct dm_task *dmt);
@@ -1669,8 +1676,6 @@ dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator);
  * timestamp handling
  ********************/
 
-struct dm_timestamp;
-
 /*
  * Create a dm_timestamp object to use with dm_timestamp_get.
  */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 0811db0..e1bd44e 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -277,6 +277,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->query_inactive_table = 0;
 	dmt->new_uuid = 0;
 	dmt->secure_data = 0;
+	dmt->record_timestamp = 0;
 
 	return dmt;
 }
diff --git a/libdm/libdm-timestamp.c b/libdm/libdm-timestamp.c
index d2bd7bf..7690ccb 100644
--- a/libdm/libdm-timestamp.c
+++ b/libdm/libdm-timestamp.c
@@ -67,6 +67,8 @@ int dm_timestamp_get(struct dm_timestamp *ts)
 
 	if (clock_gettime(CLOCK_MONOTONIC, &ts->t)) {
 		log_sys_error("clock_gettime", "get_timestamp");
+		ts->t.tv_sec = 0;
+		ts->t.tv_nsec = 0;
 		return 0;
 	}
 
@@ -113,6 +115,8 @@ int dm_timestamp_get(struct dm_timestamp *ts)
 
 	if (gettimeofday(&ts->t, NULL)) {
 		log_sys_error("gettimeofday", "get_timestamp");
+		ts->t.tv_sec = 0;
+		ts->t.tv_usec = 0;
 		return 0;
 	}
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 25789dc..485301a 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -185,6 +185,7 @@ static struct dm_report *_report;
 static report_type_t _report_type;
 static dev_name_t _dev_name_type;
 static uint32_t _count = 1; /* count of repeating reports */
+static struct dm_timestamp *_initial_timestamp = NULL;
 
 #define NSEC_PER_USEC	UINT64_C(1000)
 #define NSEC_PER_MSEC	UINT64_C(1000000)
@@ -309,6 +310,24 @@ struct dmsetup_report_obj {
 	struct dm_split_name *split_name;
 };
 
+static int _task_run(struct dm_task *dmt)
+{
+	int r;
+	uint64_t delta;
+
+	if (_initial_timestamp)
+		dm_task_set_record_timestamp(dmt);
+
+	r = dm_task_run(dmt);
+
+	if (_initial_timestamp) {
+		delta = dm_timestamp_delta(dm_task_get_ioctl_timestamp(dmt), _initial_timestamp);
+		log_debug("Timestamp: %7" PRIu64 ".%09" PRIu64 " seconds", delta / NSEC_PER_SEC, delta % NSEC_PER_SEC);
+	}
+
+	return r;
+}
+
 static struct dm_task *_get_deps_task(int major, int minor)
 {
 	struct dm_task *dmt;
@@ -330,7 +349,7 @@ static struct dm_task *_get_deps_task(int major, int minor)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto err;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto err;
 
 	if (!dm_task_get_info(dmt, &info))
@@ -601,7 +620,7 @@ static int _load(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	r = 1;
@@ -687,7 +706,7 @@ static int _create(CMD_ARGS)
 		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
-	    !dm_task_run(dmt))
+	    !_task_run(dmt))
 		goto out;
 
 	r = 1;
@@ -743,7 +762,7 @@ static int _do_rename(const char *name, const char *new_name, const char *new_uu
 		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
-	    !dm_task_run(dmt))
+	    !_task_run(dmt))
 		goto out;
 
 	r = 1;
@@ -833,7 +852,7 @@ static int _message(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	if ((response = dm_task_get_message_response(dmt))) {
@@ -882,7 +901,7 @@ static int _setgeometry(CMD_ARGS)
 		goto out;
 
 	/* run the task */
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	r = 1;
@@ -1322,7 +1341,7 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 	if (_switches[DEFERRED_ARG] && (task == DM_DEVICE_REMOVE || task == DM_DEVICE_REMOVE_ALL))
 		dm_task_deferred_remove(dmt);
 
-	r = dm_task_run(dmt);
+	r = _task_run(dmt);
 
       out:
 	if (!_udev_cookie && udev_wait_flag)
@@ -1383,7 +1402,7 @@ static int _process_all(const struct command *cmd, const char *subcommand, int a
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt)) {
+	if (!_task_run(dmt)) {
 		r = 0;
 		goto out;
 	}
@@ -1434,7 +1453,7 @@ static uint64_t _get_device_size(const char *name)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
@@ -1483,7 +1502,7 @@ static int _error_device(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto error;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto error;
 
 	if (!_simple(DM_DEVICE_RESUME, name, 0, 0)) {
@@ -1671,7 +1690,7 @@ static int _status(CMD_ARGS)
 	if (_switches[NOFLUSH_ARG] && !dm_task_no_flush(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
@@ -1747,7 +1766,7 @@ static int _targets(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	target = dm_task_get_versions(dmt);
@@ -1799,7 +1818,7 @@ static int _info(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	r = _display_info(dmt);
@@ -1843,7 +1862,7 @@ static int _deps(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	if (!dm_task_get_info(dmt, &info))
@@ -3001,7 +3020,7 @@ static int _mangle(CMD_ARGS)
 	if (!_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!_task_run(dmt))
 		goto out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
@@ -3808,8 +3827,17 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[VERSION_ARG]++;
 	}
 
-	if (_switches[VERBOSE_ARG] > 1)
+	if (_switches[VERBOSE_ARG] > 1) {
 		dm_log_init_verbose(_switches[VERBOSE_ARG] - 1);
+		if (_switches[VERBOSE_ARG] > 2) {
+			if (!(_initial_timestamp = dm_timestamp_alloc()))
+				stack;
+			else if (!dm_timestamp_get(_initial_timestamp))
+				stack;
+			else
+				log_debug("Timestamp:       0.000000000 seconds");
+		}
+	}
 
 	if ((_switches[MAJOR_ARG] && !_switches[MINOR_ARG]) ||
 	    (!_switches[MAJOR_ARG] && _switches[MINOR_ARG])) {
@@ -3960,5 +3988,8 @@ out:
 
 	dm_free(_table);
 
+	if (_initial_timestamp)
+		dm_timestamp_destroy(_initial_timestamp);
+
 	return r;
 }


