From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 08 Apr 2009 14:24:46 +0200
Subject: [PATCH 3/4] Udev integration: add cookie support for dmsetup
Message-ID: <49DC978E.4040101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds cookie support for dmsetup commands using the
semaphore IPC mechanism (we wait for udev rule completion in
resume, rename and remove commands).

A new command is added "notify" with the cookie value as the
parameter. This is called from udev rule to decrease the value
of the semaphore (and so to notify that it is completed).

Peter


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 21d2dfe..df6237b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -523,6 +523,7 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 	int r = 0;
 	struct dm_task *dmt;
 	const char *file = NULL;
+	uint32_t cookie;
 
 	if (argc == 3)
 		file = argv[2];
@@ -565,9 +566,19 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 				    _read_ahead_flags))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_notification_sem_open(&cookie) ||
+			!dm_notification_sem_inc(cookie) ||
+			!dm_task_set_cookie(dmt, cookie))
 		goto out;
 
+	if (!dm_task_run(dmt)) {
+		dm_notification_sem_close(cookie);
+		goto out;
+	}
+
+	dm_notification_sem_wait_zero(cookie);
+	dm_notification_sem_close(cookie);
+
 	r = 1;
 
 	if (_switches[VERBOSE_ARG])
@@ -583,6 +594,7 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
+	uint32_t cookie;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
 		return 0;
@@ -597,8 +609,18 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_notification_sem_open(&cookie) ||
+			!dm_notification_sem_inc(cookie) ||
+			!dm_task_set_cookie(dmt, cookie))
+		goto out;
+
+	if (!dm_task_run(dmt)) {
+		dm_notification_sem_close(cookie);
 		goto out;
+	}
+
+	dm_notification_sem_wait_zero(cookie);
+	dm_notification_sem_close(cookie);
 
 	r = 1;
 
@@ -705,6 +727,19 @@ static int _setgeometry(int argc, char **argv, void *data __attribute((unused)))
 	return r;
 }
 
+static int _notify(int argc, char **argv, void *data __attribute((unused)))
+{
+	uint32_t cookie;
+	char *p;
+
+	if (!(cookie = strtoul(argv[1], &p, 0)) || *p) {
+		err("Incorrect cookie value");
+		return 0;
+	}
+
+	return dm_notification_sem_dec(cookie);
+}
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -720,7 +755,8 @@ static int _version(int argc __attribute((unused)), char **argv __attribute((unu
 	return 1;
 }
 
-static int _simple(int task, const char *name, uint32_t event_nr, int display)
+static int _simple(int task, const char *name, uint32_t event_nr,
+										uint32_t cookie, int display)
 {
 	int r = 0;
 
@@ -749,6 +785,9 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 				    _read_ahead_flags))
 		goto out;
 
+	if (cookie && !dm_task_set_cookie(dmt, cookie))
+		goto out;
+
 	r = dm_task_run(dmt);
 
 	if (r && display && _switches[VERBOSE_ARG])
@@ -761,17 +800,31 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 
 static int _suspend(int argc, char **argv, void *data __attribute((unused)))
 {
-	return _simple(DM_DEVICE_SUSPEND, argc > 1 ? argv[1] : NULL, 0, 1);
+	return _simple(DM_DEVICE_SUSPEND, argc > 1 ? argv[1] : NULL, 0, 0, 1);
 }
 
 static int _resume(int argc, char **argv, void *data __attribute((unused)))
 {
-	return _simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, 1);
+	uint32_t cookie;
+
+	if (!dm_notification_sem_open(&cookie) ||
+		  !dm_notification_sem_inc(cookie))
+		return 0;
+
+	if (!_simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, cookie, 1)) {
+		dm_notification_sem_close(cookie);
+		return 0;
+	}
+
+	dm_notification_sem_wait_zero(cookie);
+	dm_notification_sem_close(cookie);
+
+	return 1;
 }
 
 static int _clear(int argc, char **argv, void *data __attribute((unused)))
 {
-	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 1);
+	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 0, 1);
 }
 
 static int _wait(int argc, char **argv, void *data __attribute((unused)))
@@ -788,7 +841,7 @@ static int _wait(int argc, char **argv, void *data __attribute((unused)))
 	}
 
 	return _simple(DM_DEVICE_WAITEVENT, name,
-		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
+		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 0, 1);
 }
 
 static int _process_all(int argc, char **argv, int silent,
@@ -898,8 +951,8 @@ static int _error_device(int argc __attribute((unused)), char **argv __attribute
 	if (!dm_task_run(dmt))
 		goto error;
 
-	if (!_simple(DM_DEVICE_RESUME, name, 0, 0)) {
-		_simple(DM_DEVICE_CLEAR, name, 0, 0);
+	if (!_simple(DM_DEVICE_RESUME, name, 0, 0, 0)) {
+		_simple(DM_DEVICE_CLEAR, name, 0, 0, 0);
 		goto error;
 	}
 
@@ -913,11 +966,24 @@ error:
 static int _remove(int argc, char **argv, void *data __attribute((unused)))
 {
 	int r;
+	uint32_t cookie;
 
 	if (_switches[FORCE_ARG] && argc > 1)
 		r = _error_device(argc, argv, NULL);
 
-	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
+	if (!dm_notification_sem_open(&cookie) ||
+			!dm_notification_sem_inc(cookie))
+		return 0;
+
+	if (!_simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, cookie, 0)) {
+		dm_notification_sem_close(cookie);
+		return 0;
+	}
+
+	dm_notification_sem_wait_zero(cookie);
+	dm_notification_sem_close(cookie);
+
+	return 1;
 }
 
 static int _count_devices(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
@@ -932,7 +998,7 @@ static int _remove_all(int argc __attribute((unused)), char **argv __attribute((
 	int r;
 
 	/* Remove all closed devices */
-	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
+	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0, 0) | dm_mknodes(NULL);
 
 	if (!_switches[FORCE_ARG])
 		return r;
@@ -945,7 +1011,7 @@ static int _remove_all(int argc __attribute((unused)), char **argv __attribute((
 		return r;
 
 	r |= _process_all(argc, argv, 1, _error_device);
-	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
+	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0, 0) | dm_mknodes(NULL);
 
 	_num_devices = 0;
 	r |= _process_all(argc, argv, 1, _count_devices);
@@ -2222,6 +2288,7 @@ static struct command _commands[] = {
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"notify", "<cookie>", 1, 1, _notify},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},


