From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jul 2011 14:09:23 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM doc/example.co ...
Message-ID: <20110701140923.17426.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-01 14:09:21

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	doc            : example.conf.in 
	lib/activate   : activate.c dev_manager.c 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/misc       : lvm-globals.c lvm-globals.h 
	libdm          : libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 
	man            : dmsetup.8.in 
	test/lib       : aux.sh 
	tools          : dmsetup.c 

Log message:
	Add framework for validation of ioctls.  Doesn't do any checks yet.
	dmsetup --checks
	libdevmapper: dm_task_enable_checks()
	lvm.conf: activation/checks=1

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2034&r2=1.2035
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.476&r2=1.477
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.204&r2=1.205
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.221&r2=1.222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/WHATS_NEW	2011/06/30 18:25:18	1.2034
+++ LVM2/WHATS_NEW	2011/07/01 14:09:19	1.2035
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Add activation/checks to lvm.conf to perform additional ioctl validation.
   When suspending, automatically preload newly-visible existing LVs.
   Report internal error when parameters are missing on table load.
   Teardown any stray devices with $COMMON_PREFIX during test runs.
--- LVM2/WHATS_NEW_DM	2011/06/29 21:56:46	1.476
+++ LVM2/WHATS_NEW_DM	2011/07/01 14:09:19	1.477
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Add dmsetup --checks and dm_task_enable_checks framework to validate ioctls.
   Add age_in_minutes parameter to dmsetup udevcomplete_all.
   Return immediately from dm_lib_exit() if called more than once.
   Disable udev fallback by default and add --verifyudev option to dmsetup.
--- LVM2/doc/example.conf.in	2011/06/27 21:43:59	1.27
+++ LVM2/doc/example.conf.in	2011/07/01 14:09:19	1.28
@@ -411,6 +411,12 @@
 }
 
 activation {
+    # Set to 1 to perform internal checks on the operations issued to
+    # libdevmapper.  Useful for debugging problems with activation.
+    # Some of the checks may be expensive, so it's best to use this
+    # only when there seems to be a problem.
+    checks = 0
+
     # Set to 0 to disable udev synchronisation (if compiled into the binaries).
     # Processes will not wait for notification from udev.
     # They will continue irrespective of any possible udev processing
--- LVM2/lib/activate/activate.c	2011/06/30 18:25:18	1.204
+++ LVM2/lib/activate/activate.c	2011/07/01 14:09:19	1.205
@@ -394,6 +394,9 @@
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST_VERSIONS)))
 		return_0;
 
+        if (activation_checks() && !dm_task_enable_checks(dmt))
+                goto_out;
+
 	if (!dm_task_run(dmt)) {
 		log_debug("Failed to get %s target version", target_name);
 		/* Assume this was because LIST_VERSIONS isn't supported */
--- LVM2/lib/activate/dev_manager.c	2011/06/30 18:25:18	1.221
+++ LVM2/lib/activate/dev_manager.c	2011/07/01 14:09:19	1.222
@@ -88,6 +88,9 @@
 	if (major && !dm_task_set_major_minor(dmt, major, minor, 1))
 		goto_out;
 
+	if (activation_checks() && !dm_task_enable_checks(dmt))
+		goto_out;
+		
 	return dmt;
       out:
 	dm_task_destroy(dmt);
@@ -148,6 +151,9 @@
 	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
 		goto_out;
 
+	if (activation_checks() && !dm_task_enable_checks(dmt))
+		goto_out;
+		
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device");
 		goto out;
--- LVM2/lib/commands/toolcontext.c	2011/06/28 00:23:06	1.123
+++ LVM2/lib/commands/toolcontext.c	2011/07/01 14:09:19	1.124
@@ -285,6 +285,9 @@
 								"activation/udev_sync",
 								DEFAULT_UDEV_SYNC);
 
+	init_activation_checks(find_config_tree_int(cmd, "activation/checks",
+						      DEFAULT_ACTIVATION_CHECKS));
+
 #ifdef UDEV_SYNC_SUPPORT
 	/*
 	 * We need udev rules to be applied, otherwise we would end up with no
--- LVM2/lib/config/defaults.h	2011/06/27 21:43:59	1.77
+++ LVM2/lib/config/defaults.h	2011/07/01 14:09:20	1.78
@@ -79,6 +79,7 @@
 #define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 0
 #define DEFAULT_VERIFY_UDEV_OPERATIONS 0
+#define DEFAULT_ACTIVATION_CHECKS 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
 #define DEFAULT_MAX_LV 0
--- LVM2/lib/misc/lvm-globals.c	2011/04/22 12:05:33	1.11
+++ LVM2/lib/misc/lvm-globals.c	2011/07/01 14:09:20	1.12
@@ -42,6 +42,7 @@
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
+static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
@@ -131,6 +132,14 @@
 		log_debug("LVM udev checking disabled");
 }
 
+void init_activation_checks(int checks)
+{
+	if ((_activation_checks = checks))
+		log_debug("LVM activation checks enabled");
+	else
+		log_debug("LVM activation checks disabled");
+}
+
 void init_dev_disable_after_error_count(int value)
 {
 	_dev_disable_after_error_count = value;
@@ -256,6 +265,11 @@
 	return _udev_checking;
 }
 
+int activation_checks(void)
+{
+	return _activation_checks;
+}
+
 const char *sysfs_dir_path(void)
 {
 	return _sysfs_dir_path;
--- LVM2/lib/misc/lvm-globals.h	2011/04/28 17:33:34	1.11
+++ LVM2/lib/misc/lvm-globals.h	2011/07/01 14:09:20	1.12
@@ -40,6 +40,7 @@
 void init_udev_checking(int checking);
 void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
+void init_activation_checks(int checks);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -63,6 +64,7 @@
 int udev_checking(void);
 const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
+int activation_checks(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
--- LVM2/libdm/libdevmapper.h	2011/06/13 03:32:46	1.138
+++ LVM2/libdm/libdevmapper.h	2011/07/01 14:09:20	1.139
@@ -190,6 +190,12 @@
 int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
+
+/*
+ * Enable checks for common mistakes such as issuing ioctls in an unsafe order.
+ */
+int dm_task_enable_checks(struct dm_task *dmt);
+
 typedef enum {
 	DM_ADD_NODE_ON_RESUME, /* add /dev/mapper node with dmsetup resume */
 	DM_ADD_NODE_ON_CREATE  /* add /dev/mapper node with dmsetup create */
--- LVM2/libdm/libdm-common.c	2011/06/28 09:24:13	1.121
+++ LVM2/libdm/libdm-common.c	2011/07/01 14:09:20	1.122
@@ -395,6 +395,13 @@
 	return 1;
 }
 
+int dm_task_enable_checks(struct dm_task *dmt)
+{
+	dmt->enable_checks = 1;
+
+	return 1;
+}
+
 int dm_task_add_target(struct dm_task *dmt, uint64_t start, uint64_t size,
 		       const char *ttype, const char *params)
 {
--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/29 16:08:33	1.111
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/07/01 14:09:20	1.112
@@ -1884,6 +1884,16 @@
 	return r;
 }
 
+static int _suspend_with_validation_v4(struct dm_task *dmt)
+{
+	/*
+	 * FIXME Ensure we can't leave any I/O trapped between suspended devices.
+	 */
+	dmt->enable_checks = 0;
+	
+	return dm_task_run(dmt);
+}
+
 static const char *_sanitise_message(char *message)
 {
 	const char *sanitised_message = message ?: "";
@@ -1963,7 +1973,7 @@
 	}
 
 	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s%s%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s%s%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
 		  dmt->new_uuid ? "UUID " : "",
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1980,6 +1990,7 @@
 		  dmt->skip_lockfs ? "S " : "",
 		  dmt->secure_data ? "W " : "",
 		  dmt->query_inactive_table ? "I " : "",
+		  dmt->enable_checks ? "C" : "",
 		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size);
 #ifdef DM_IOCTLS
@@ -2054,6 +2065,9 @@
 	if ((dmt->type == DM_DEVICE_RELOAD) && dmt->suppress_identical_reload)
 		return _reload_with_suppression_v4(dmt);
 
+	if ((dmt->type == DM_DEVICE_SUSPEND) && dmt->enable_checks)
+		return _suspend_with_validation_v4(dmt);
+
 	if (!_open_control()) {
 		_udev_complete(dmt);
 		return 0;
--- LVM2/libdm/ioctl/libdm-targets.h	2011/02/04 19:33:54	1.29
+++ LVM2/libdm/ioctl/libdm-targets.h	2011/07/01 14:09:20	1.30
@@ -65,6 +65,7 @@
 	int cookie_set;
 	int new_uuid;
 	int secure_data;
+	int enable_checks;
 
 	char *uuid;
 };
--- LVM2/man/dmsetup.8.in	2011/06/29 21:56:46	1.41
+++ LVM2/man/dmsetup.8.in	2011/07/01 14:09:20	1.42
@@ -114,6 +114,10 @@
 .br
 \fBdmsetup info -c --noheadings -j \fImajor\fB -m \fIminor\fP.
 .SH OPTIONS
+.IP \fB--checks
+Perform additional checks on the operations requested and report
+potential problems.  Useful when debugging scripts.
+In some cases these checks may slow down operations noticeably.
 .IP \fB-c|-C|--columns
 .br
 Display output in columns rather than as Field: Value lines.
--- LVM2/test/lib/aux.sh	2011/06/30 09:17:49	1.25
+++ LVM2/test/lib/aux.sh	2011/07/01 14:09:20	1.26
@@ -381,6 +381,7 @@
 global/locking_type=$LVM_TEST_LOCKING
 global/si_unit_consistency = 1
 global/fallback_to_local_locking = 0
+activation/checks = 1
 activation/udev_sync = 1
 activation/udev_rules = 1
 activation/verify_udev_operations = $VERIFY_UDEV
--- LVM2/tools/dmsetup.c	2011/06/29 21:56:46	1.163
+++ LVM2/tools/dmsetup.c	2011/07/01 14:09:20	1.164
@@ -117,6 +117,9 @@
  */
 enum {
 	READ_ONLY = 0,
+	ADD_NODE_ON_CREATE_ARG,
+	ADD_NODE_ON_RESUME_ARG,
+	CHECKS_ARG,
 	COLS_ARG,
 	EXEC_ARG,
 	FORCE_ARG,
@@ -153,8 +156,6 @@
 	VERIFYUDEV_ARG,
 	VERSION_ARG,
 	YES_ARG,
-	ADD_NODE_ON_RESUME_ARG,
-	ADD_NODE_ON_CREATE_ARG,
 	NUM_SWITCHES
 };
 
@@ -317,6 +318,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto err;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto err;
+
 	if (!dm_task_run(dmt))
 		goto err;
 
@@ -572,6 +576,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -645,6 +652,8 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
 
 	if (!_set_task_add_node(dmt))
                 goto out;
@@ -699,6 +708,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (_switches[NOUDEVRULES_ARG])
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
@@ -778,6 +790,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -816,6 +831,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	/* run the task */
 	if (!dm_task_run(dmt))
 		goto out;
@@ -1234,6 +1252,9 @@
 	if (_switches[NOLOCKFS_ARG] && !dm_task_skip_lockfs(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	/* FIXME: needs to coperate with udev */
 	if (!_set_task_add_node(dmt))
                 goto out;
@@ -1314,6 +1335,9 @@
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
 		return 0;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt)) {
 		r = 0;
 		goto out;
@@ -1362,6 +1386,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1411,6 +1438,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto error;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto error;
+
 	if (!dm_task_run(dmt))
 		goto error;
 
@@ -1586,6 +1616,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1659,6 +1692,9 @@
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST_VERSIONS)))
 		return 0;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1709,6 +1745,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1749,6 +1788,9 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -2764,7 +2806,7 @@
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [-v|--verbose [-v|--verbose ...]]\n"
+		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
@@ -3119,6 +3161,7 @@
 #ifdef HAVE_GETOPTLONG
 	static struct option long_options[] = {
 		{"readonly", 0, &ind, READ_ONLY},
+		{"checks", 0, &ind, CHECKS_ARG},
 		{"columns", 0, &ind, COLS_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
@@ -3258,6 +3301,8 @@
 			_switches[ADD_NODE_ON_RESUME_ARG]++;
 		if (ind == ADD_NODE_ON_CREATE_ARG)
 			_switches[ADD_NODE_ON_CREATE_ARG]++;
+		if (ind == CHECKS_ARG)
+			_switches[CHECKS_ARG]++;
 		if (ind == UDEVCOOKIE_ARG) {
 			_switches[UDEVCOOKIE_ARG]++;
 			_udev_cookie = _get_cookie_value(optarg);


