From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2006 14:34:05 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirror.c
Message-ID: <20061220143405.13152.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-20 14:34:05

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 

Log message:
	Fix dmeventd mirror to cope if monitored device disappears.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.523&r2=1.524
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2006/12/14 22:21:32	1.523
+++ LVM2/WHATS_NEW	2006/12/20 14:34:04	1.524
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Fix dmeventd mirror to cope if monitored device disappears.
 
 Version 2.02.17 - 14th December 2006
 ====================================
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2006/08/21 12:04:54	1.8
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2006/12/20 14:34:05	1.9
@@ -26,6 +26,7 @@
 #include <unistd.h>
 
 #include <syslog.h> /* FIXME Replace syslog with multilog */
+/* FIXME Missing openlog? */
 
 #define ME_IGNORE    0
 #define ME_INSYNC    1
@@ -34,23 +35,29 @@
 static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
 
 /* FIXME: We may need to lock around operations to these */
-static int register_count = 0;
-static struct dm_pool *mem_pool = NULL;
+static int _register_count = 0;
+
+/* FIXME Unsafe static? */
+static struct dm_pool *_mem_pool = NULL;
 
 static int _get_mirror_event(char *params)
 {
-	int i, rtn = ME_INSYNC;
-	int max_args = 30;  /* should support at least 8-way mirrors */
-	char *args[max_args];
+	int i, r = ME_INSYNC;
+
+#define MAX_ARGS 30;  /* should support at least 8-way mirrors */
+/* FIXME Remove unnecessary limit.  It tells you how many devices there are - use it! */
+
+	char *args[MAX_ARGS];
 	char *dev_status_str;
 	char *log_status_str;
 	char *sync_str;
 	char *p;
 	int log_argc, num_devs, num_failures=0;
 
-	if (max_args <= dm_split_words(params, max_args, 0, args)) {
+	/* FIXME Remove unnecessary limit - get num_devs here */
+	if (MAX_ARGS <= dm_split_words(params, MAX_ARGS, 0, args)) {
 		syslog(LOG_ERR, "Unable to split mirror parameters: Arg list too long");
-		return -E2BIG;
+		return -E2BIG;	/* FIXME Why? Unused */
 	}
 
 	/*
@@ -58,18 +65,20 @@
 	 * Used  :  2 253:4 253:5 400/400 1 AA 3 cluster 253:3 A
 	*/
 	num_devs = atoi(args[0]);
+
+	/* FIXME *Now* split rest of args */
+
 	dev_status_str = args[3 + num_devs];
 	log_argc = atoi(args[4 + num_devs]);
 	log_status_str = args[4 + num_devs + log_argc];
 	sync_str = args[1 + num_devs];
 
 	/* Check for bad mirror devices */
-	for (i = 0; i < num_devs; i++) {
+	for (i = 0; i < num_devs; i++)
 		if (dev_status_str[i] == 'D') {
 			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i+1]);
 			num_failures++;
 		}
-	}
 
 	/* Check for bad log device */
 	if (log_status_str[0] == 'D') {
@@ -79,7 +88,7 @@
 	}
 
 	if (num_failures) {
-		rtn = ME_FAILURE;
+		r = ME_FAILURE;
 		goto out;
 	}
 
@@ -87,7 +96,7 @@
 	if (p) {
 		p[0] = '\0';
 		if (strcmp(sync_str, p+1))
-			rtn = ME_IGNORE;
+			r = ME_IGNORE;
 		p[0] = '/';
 	} else {
 		/*
@@ -95,10 +104,10 @@
 		 * Might mean all our parameters are screwed.
 		 */
 		syslog(LOG_ERR, "Unable to parse sync string.");
-		rtn = ME_IGNORE;
+		r = ME_IGNORE;
 	}
  out:
-	return rtn;
+	return r;
 }
 
 static void _temporary_log_fn(int level, const char *file,
@@ -114,25 +123,25 @@
 {
 	int r;
 	void *handle;
-	int cmd_size = 256;	/* FIXME Use system restriction */
-	char cmd_str[cmd_size];
+#define CMD_SIZE 256	/* FIXME Use system restriction */
+	char cmd_str[CMD_SIZE];
 	char *vg = NULL, *lv = NULL, *layer = NULL;
 
-	if (strlen(device) > 200)
-		return -ENAMETOOLONG;
+	if (strlen(device) > 200)  /* FIXME Use real restriction */
+		return -ENAMETOOLONG;	/* FIXME These return code distinctions are not used so remove them! */
 
-	if (!dm_split_lvm_name(mem_pool, device, &vg, &lv, &layer)) {
+	if (!dm_split_lvm_name(_mem_pool, device, &vg, &lv, &layer)) {
 		syslog(LOG_ERR, "Unable to determine VG name from %s",
 		       device);
-		return -ENOMEM;
+		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
 	/* FIXME Is any sanity-checking required on %s? */
-	if (cmd_size <= snprintf(cmd_str, cmd_size, "vgreduce --removemissing %s", vg)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s", vg)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
-		dm_pool_empty(mem_pool);  /* FIXME: not safe with multiple threads */
-		return -ENAMETOOLONG;
+		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
+		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
 	lvm2_log_fn(_temporary_log_fn);
@@ -140,8 +149,8 @@
 	lvm2_log_level(handle, 1);
 	r = lvm2_run(handle, cmd_str);
 
-	dm_pool_empty(mem_pool);  /* FIXME: not safe with multiple threads */
-	return (r == 1)? 0: -1;
+	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
+	return (r == 1) ? 0 : -1;
 }
 
 void process_event(const char *device, enum dm_event_type event)
@@ -176,6 +185,10 @@
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 
+		if (!target_type)
+			syslog(LOG_INFO, "%s mapping lost.\n", device);
+			continue;
+
 		if (strcmp(target_type, "mirror")) {
 			syslog(LOG_INFO, "%s has unmirrored portion.\n", device);
 			continue;
@@ -192,6 +205,7 @@
 		case ME_FAILURE:
 			syslog(LOG_ERR, "Device failure in %s\n", device);
 			if (_remove_failed_devices(device))
+				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
 				       device);
 			/* Should check before warning user that device is now linear
@@ -203,6 +217,7 @@
 		case ME_IGNORE:
 			break;
 		default:
+			/* FIXME Wrong: it can also return -E2BIG but it's never used! */
 			syslog(LOG_INFO, "Unknown event received.\n");
 		}
 	} while (next);
@@ -221,34 +236,20 @@
 	 * Need some space for allocations.  1024 should be more
 	 * than enough for what we need (device mapper name splitting)
 	 */
-	if (!mem_pool)
-		mem_pool = dm_pool_create("mirror_dso", 1024);
-
-	if (!mem_pool)
+	if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024)))
 		return 0;
 
-	register_count++;
+	_register_count++;
 
         return 1;
 }
 
 int unregister_device(const char *device)
 {
-	if (!(--register_count)) {
-		dm_pool_destroy(mem_pool);
-		mem_pool = NULL;
+	if (!--_register_count) {
+		dm_pool_destroy(_mem_pool);
+		_mem_pool = NULL;
 	}
 
         return 1;
 }
-
-/*
- * Overrides for Emacs so that we follow Linus's tabbing style.
- * Emacs will notice this stuff at the end of the file and automatically
- * adjust the settings for this buffer only.  This must remain@the end
- * of the file.
- * ---------------------------------------------------------------------------
- * Local variables:
- * c-file-style: "linux"
- * End:
- */


