From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jan 2007 14:24:21 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirr ...
Message-ID: <20070108142421.11203.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-08 14:24:20

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 
	tools          : lvmcmdlib.c 

Log message:
	Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.526&r2=1.527
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2007/01/05 15:53:40	1.526
+++ LVM2/WHATS_NEW	2007/01/08 14:24:20	1.527
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.
   Fix create mirror with name longer than 22 chars.
   Fix some activate.c prototypes when compiled without devmapper.
   Fix dmeventd mirror to cope if monitored device disappears.
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2006/12/20 14:34:05	1.9
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/08 14:24:20	1.10
@@ -32,19 +32,30 @@
 #define ME_INSYNC    1
 #define ME_FAILURE   2
 
-static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
-
-/* FIXME: We may need to lock around operations to these */
+/*
+ * register_device() is called first and performs initialisation.
+ * Only one device may be registered or unregistered at a time.
+ */
+static pthread_mutex_t _register_mutex = PTHREAD_MUTEX_INITIALIZER;
+
+/*
+ * Number of active registrations.
+ */
 static int _register_count = 0;
 
-/* FIXME Unsafe static? */
 static struct dm_pool *_mem_pool = NULL;
+static void *_lvm_handle = NULL;
+
+/*
+ * Currently only one event can be processed at a time.
+ */
+static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
 static int _get_mirror_event(char *params)
 {
 	int i, r = ME_INSYNC;
 
-#define MAX_ARGS 30;  /* should support at least 8-way mirrors */
+#define MAX_ARGS 30	/* should support at least 8-way mirrors */
 /* FIXME Remove unnecessary limit.  It tells you how many devices there are - use it! */
 
 	char *args[MAX_ARGS];
@@ -122,7 +133,6 @@
 static int _remove_failed_devices(const char *device)
 {
 	int r;
-	void *handle;
 #define CMD_SIZE 256	/* FIXME Use system restriction */
 	char cmd_str[CMD_SIZE];
 	char *vg = NULL, *lv = NULL, *layer = NULL;
@@ -144,10 +154,7 @@
 		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
-	lvm2_log_fn(_temporary_log_fn);
-	handle = lvm2_init();
-	lvm2_log_level(handle, 1);
-	r = lvm2_run(handle, cmd_str);
+	r = lvm2_run(_lvm_handle, cmd_str);
 
 	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 	return (r == 1) ? 0 : -1;
@@ -161,9 +168,9 @@
 	char *target_type = NULL;
 	char *params;
 
-	if (pthread_mutex_trylock(&_lock)) {
+	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
-		pthread_mutex_lock(&_lock);
+		pthread_mutex_lock(&_event_mutex);
 	}
 	/* FIXME Move inside libdevmapper */
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
@@ -185,9 +192,10 @@
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 
-		if (!target_type)
+		if (!target_type) {
 			syslog(LOG_INFO, "%s mapping lost.\n", device);
 			continue;
+		}
 
 		if (strcmp(target_type, "mirror")) {
 			syslog(LOG_INFO, "%s has unmirrored portion.\n", device);
@@ -225,11 +233,15 @@
  fail:
 	if (dmt)
 		dm_task_destroy(dmt);
-	pthread_mutex_unlock(&_lock);
+	pthread_mutex_unlock(&_event_mutex);
 }
 
 int register_device(const char *device)
 {
+	int r = 0;
+
+	pthread_mutex_lock(&_register_mutex);
+
 	syslog(LOG_INFO, "Monitoring mirror device, %s for events\n", device);
 
 	/*
@@ -237,19 +249,42 @@
 	 * than enough for what we need (device mapper name splitting)
 	 */
 	if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024)))
-		return 0;
+		goto out;
+
+	if (!_lvm_handle) {
+		lvm2_log_fn(_temporary_log_fn);
+		if (!(_lvm_handle = lvm2_init())) {
+			dm_pool_destroy(_mem_pool);
+			_mem_pool = NULL;
+			goto out;
+		}
+		lvm2_log_level(_lvm_handle, LVM2_LOG_SUPPRESS);
+		/* FIXME Temporary: move to dmeventd core */
+		lvm2_run(_lvm_handle, "_memlock_inc");
+	}
 
 	_register_count++;
+	r = 1;
+
+out:
+	pthread_mutex_unlock(&_register_mutex);
 
-        return 1;
+	return r;
 }
 
 int unregister_device(const char *device)
 {
+	pthread_mutex_lock(&_register_mutex);
+
 	if (!--_register_count) {
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
+		lvm2_run(_lvm_handle, "_memlock_dec");
+		lvm2_exit(_lvm_handle);
+		_lvm_handle = NULL;
 	}
 
-        return 1;
+	pthread_mutex_unlock(&_register_mutex);
+
+	return 1;
 }
--- LVM2/tools/lvmcmdlib.c	2006/08/22 15:56:06	1.2
+++ LVM2/tools/lvmcmdlib.c	2007/01/08 14:24:20	1.3
@@ -77,7 +77,13 @@
 		goto out;
 	}
 
-	ret = lvm_run_command(cmd, argc, argv);
+	/* FIXME Temporary - move to libdevmapper */
+	if (!strcmp(cmdline, "_memlock_inc"))
+		memlock_inc();
+	if (!strcmp(cmdline, "_memlock_dec"))
+		memlock_dec();
+	else
+		ret = lvm_run_command(cmd, argc, argv);
 
       out:
 	dm_free(cmdcopy);


