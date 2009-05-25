From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:19:01 +0200
Subject: [PATCH 4/9] Udev integration: add cookie support for dmsetup
Message-ID: <4A1A8CB5.1080508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've just added the "--noudevwait" option for dmsetup -- this will
disable the wait-for-udev, if somebody wants to do it for any reason...

Peter


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 934b3ec..8db38b0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -119,6 +119,7 @@ enum {
 	NOLOCKFS_ARG,
 	NOOPENCOUNT_ARG,
 	NOTABLE_ARG,
+	NOUDEVWAIT_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
 	ROWS_ARG,
@@ -528,6 +529,7 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 	int r = 0;
 	struct dm_task *dmt;
 	const char *file = NULL;
+	uint32_t cookie;
 
 	if (argc == 3)
 		file = argv[2];
@@ -570,8 +572,18 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 				    _read_ahead_flags))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_udev_notif_sem_open(&cookie))
+		goto out;
+
+	if (!dm_udev_notif_sem_inc(cookie) ||
+	    !dm_task_set_cookie(dmt, cookie) ||
+	    !dm_task_run(dmt)) {
+		dm_udev_notif_sem_close(cookie);
 		goto out;
+	}
+
+	dm_udev_notif_sem_wait_zero(cookie);
+	dm_udev_notif_sem_close(cookie);
 
 	r = 1;
 
@@ -588,6 +600,7 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 {
 	int r = 0;
 	struct dm_task *dmt;
+	uint32_t cookie;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
 		return 0;
@@ -602,8 +615,18 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_udev_notif_sem_open(&cookie))
+		goto out;
+
+	if (!dm_udev_notif_sem_inc(cookie) ||
+	    !dm_task_set_cookie(dmt, cookie) ||
+	    !dm_task_run(dmt)) {
+		dm_udev_notif_sem_close(cookie);
 		goto out;
+	}
+
+	dm_udev_notif_sem_wait_zero(cookie);
+	dm_udev_notif_sem_close(cookie);
 
 	r = 1;
 
@@ -710,6 +733,19 @@ static int _setgeometry(int argc, char **argv, void *data __attribute((unused)))
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
+	return dm_udev_notif_sem_dec(cookie);
+}
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -725,7 +761,8 @@ static int _version(int argc __attribute((unused)), char **argv __attribute((unu
 	return 1;
 }
 
-static int _simple(int task, const char *name, uint32_t event_nr, int display)
+static int _simple(int task, const char *name, uint32_t event_nr,
+			uint32_t cookie, int display)
 {
 	int r = 0;
 
@@ -754,6 +791,9 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 				    _read_ahead_flags))
 		goto out;
 
+	if (cookie && !dm_task_set_cookie(dmt, cookie))
+		goto out;
+
 	r = dm_task_run(dmt);
 
 	if (r && display && _switches[VERBOSE_ARG])
@@ -766,17 +806,31 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 
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
+	if (!dm_udev_notif_sem_open(&cookie))
+		return 0;
+
+	if (!dm_udev_notif_sem_inc(cookie) ||
+	    !_simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, cookie, 1)) {
+		dm_udev_notif_sem_close(cookie);
+		return 0;
+	}
+
+	dm_udev_notif_sem_wait_zero(cookie);
+	dm_udev_notif_sem_close(cookie);
+
+	return 1;
 }
 
 static int _clear(int argc, char **argv, void *data __attribute((unused)))
 {
-	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 1);
+	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 0, 1);
 }
 
 static int _wait(int argc, char **argv, void *data __attribute((unused)))
@@ -793,7 +847,7 @@ static int _wait(int argc, char **argv, void *data __attribute((unused)))
 	}
 
 	return _simple(DM_DEVICE_WAITEVENT, name,
-		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
+		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 0, 1);
 }
 
 static int _process_all(int argc, char **argv, int silent,
@@ -903,8 +957,8 @@ static int _error_device(int argc __attribute((unused)), char **argv __attribute
 	if (!dm_task_run(dmt))
 		goto error;
 
-	if (!_simple(DM_DEVICE_RESUME, name, 0, 0)) {
-		_simple(DM_DEVICE_CLEAR, name, 0, 0);
+	if (!_simple(DM_DEVICE_RESUME, name, 0, 0, 0)) {
+		_simple(DM_DEVICE_CLEAR, name, 0, 0, 0);
 		goto error;
 	}
 
@@ -918,11 +972,24 @@ error:
 static int _remove(int argc, char **argv, void *data __attribute((unused)))
 {
 	int r;
+	uint32_t cookie;
 
 	if (_switches[FORCE_ARG] && argc > 1)
 		r = _error_device(argc, argv, NULL);
 
-	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
+	if (!dm_udev_notif_sem_open(&cookie))
+		return 0;
+
+	if (!dm_udev_notif_sem_inc(cookie) ||
+	    !_simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, cookie, 0)) {
+		dm_udev_notif_sem_close(cookie);
+		return 0;
+	}
+
+	dm_udev_notif_sem_wait_zero(cookie);
+	dm_udev_notif_sem_close(cookie);
+
+	return 1;
 }
 
 static int _count_devices(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
@@ -937,7 +1004,7 @@ static int _remove_all(int argc __attribute((unused)), char **argv __attribute((
 	int r;
 
 	/* Remove all closed devices */
-	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
+	r =  _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0, 0) | dm_mknodes(NULL);
 
 	if (!_switches[FORCE_ARG])
 		return r;
@@ -950,7 +1017,7 @@ static int _remove_all(int argc __attribute((unused)), char **argv __attribute((
 		return r;
 
 	r |= _process_all(argc, argv, 1, _error_device);
-	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
+	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0, 0) | dm_mknodes(NULL);
 
 	_num_devices = 0;
 	r |= _process_all(argc, argv, 1, _count_devices);
@@ -2227,6 +2294,7 @@ static struct command _commands[] = {
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"udevnotify", "<cookie>", 1, 1, _udevnotify},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},
@@ -2240,7 +2308,7 @@ static void _usage(FILE *out)
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs]\n"
-		"        [--readahead [+]<sectors>|auto|none]\n"
+		"        [--noudevwait] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -2604,6 +2672,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
 		{"noopencount", 0, &ind, NOOPENCOUNT_ARG},
 		{"notable", 0, &ind, NOTABLE_ARG},
+		{"noudevwait", 0, &ind, NOUDEVWAIT_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
@@ -2712,6 +2781,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			_switches[UUID_ARG]++;
 			_uuid = optarg;
 		}
+		if (ind == NOUDEVWAIT_ARG)
+			_switches[NOUDEVWAIT_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);
@@ -2850,6 +2921,9 @@ int main(int argc, char **argv)
 	if (_switches[COLS_ARG] && !_report_init(c))
 		goto out;
 
+	if (_switches[NOUDEVWAIT_ARG])
+		dm_udev_notif_disable();
+
       doit:
 	if (!c->fn(argc, argv, NULL)) {
 		fprintf(stderr, "Command failed\n");


