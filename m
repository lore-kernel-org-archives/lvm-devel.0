From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 23 Apr 2009 15:07:19 +0200
Subject: [PATCH 3/5] Udev integration: add cookie support for dmsetup
Message-ID: <49F06807.7010607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

...resending updated and cleaned up patches for udev integration.


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 540924a..dbc369b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -528,6 +528,7 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 	int r = 0;
 	struct dm_task *dmt;
 	const char *file = NULL;
+	uint32_t cookie;
 
 	if (argc == 3)
 		file = argv[2];
@@ -570,8 +571,18 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 				    _read_ahead_flags))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_notification_sem_open(&cookie))
+		goto out;
+
+	if (!dm_notification_sem_inc(cookie) ||
+			!dm_task_set_cookie(dmt, cookie) ||
+			!dm_task_run(dmt)) {
+		dm_notification_sem_close(cookie);
 		goto out;
+	}
+
+	dm_notification_sem_wait_zero(cookie);
+	dm_notification_sem_close(cookie);
 
 	r = 1;
 
@@ -588,6 +599,7 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
+	uint32_t cookie;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
 		return 0;
@@ -602,8 +614,18 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_notification_sem_open(&cookie))
+		goto out;
+
+	if (!dm_notification_sem_inc(cookie) ||
+			!dm_task_set_cookie(dmt, cookie) ||
+			!dm_task_run(dmt)) {
+		dm_notification_sem_close(cookie);
 		goto out;
+	}
+
+	dm_notification_sem_wait_zero(cookie);
+	dm_notification_sem_close(cookie);
 
 	r = 1;
 
@@ -710,6 +732,19 @@ static int _setgeometry(int argc, char **argv, void *data __attribute((unused)))
 	return r;
 }
 
+static int _udevnotify(int argc, char **argv, void *data __attribute((unused)))
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
@@ -725,7 +760,8 @@ static int _version(int argc __attribute((unused)), char **argv __attribute((unu
 	return 1;
 }
 
-static int _simple(int task, const char *name, uint32_t event_nr, int display)
+static int _simple(int task, const char *name, uint32_t event_nr,
+			uint32_t cookie, int display)
 {
 	int r = 0;
 
@@ -754,6 +790,9 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 				    _read_ahead_flags))
 		goto out;
 
+	if (cookie && !dm_task_set_cookie(dmt, cookie))
+		goto out;
+
 	r = dm_task_run(dmt);
 
 	if (r && display && _switches[VERBOSE_ARG])
@@ -766,17 +805,31 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 
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
+	if (!dm_notification_sem_open(&cookie))
+		return 0;
+
+	if (!dm_notification_sem_inc(cookie) ||
+			!_simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, cookie, 1)) {
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
@@ -793,7 +846,7 @@ static int _wait(int argc, char **argv, void *data __attribute((unused)))
 	}
 
 	return _simple(DM_DEVICE_WAITEVENT, name,
-		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
+		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 0, 1);
 }
 
 static int _process_all(int argc, char **argv, int silent,
@@ -903,8 +956,8 @@ static int _error_device(int argc __attribute((unused)), char **argv __attribute
 	if (!dm_task_run(dmt))
 		goto error;
 
-	if (!_simple(DM_DEVICE_RESUME, name, 0, 0)) {
-		_simple(DM_DEVICE_CLEAR, name, 0, 0);
+	if (!_simple(DM_DEVICE_RESUME, name, 0, 0, 0)) {
+		_simple(DM_DEVICE_CLEAR, name, 0, 0, 0);
 		goto error;
 	}
 
@@ -918,11 +971,24 @@ error:
 static int _remove(int argc, char **argv, void *data __attribute((unused)))
 {
 	int r;
+	uint32_t cookie;
 
 	if (_switches[FORCE_ARG] && argc > 1)
 		r = _error_device(argc, argv, NULL);
 
-	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
+	if (!dm_notification_sem_open(&cookie))
+		return 0;
+
+	if (!dm_notification_sem_inc(cookie) ||
+			!_simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, cookie, 0)) {
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
@@ -937,7 +1003,7 @@ static int _remove_all(int argc __attribute((unused)), char **argv __attribute((
 	int r;
 
 	/* Remove all closed devices */
-	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
+	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0, 0) | dm_mknodes(NULL);
 
 	if (!_switches[FORCE_ARG])
 		return r;
@@ -950,7 +1016,7 @@ static int _remove_all(int argc __attribute((unused)), char **argv __attribute((
 		return r;
 
 	r |= _process_all(argc, argv, 1, _error_device);
-	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
+	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0, 0) | dm_mknodes(NULL);
 
 	_num_devices = 0;
 	r |= _process_all(argc, argv, 1, _count_devices);
@@ -2227,6 +2293,7 @@ static struct command _commands[] = {
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"udevnotify", "<cookie>", 1, 1, _udevnotify},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},


