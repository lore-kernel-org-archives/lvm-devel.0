From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jan 2007 21:22:31 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/activate ...
Message-ID: <20070125212231.13385.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-25 21:22:30

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/activate   : activate.h dev_manager.c 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/filters    : filter.c 
	lib/log        : log.c log.h 

Log message:
	Add devices/ignore_suspended_devices to ignore suspended dm devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.558&r2=1.559
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2007/01/25 14:37:46	1.558
+++ LVM2/WHATS_NEW	2007/01/25 21:22:29	1.559
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Add devices/ignore_suspended_devices to ignore suspended dm devices.
   Add some missing close() and fclose() return code checks.
   Fix exit statuses of reporting tools (2.02.19).
   Add init script for dmeventd monitoring.
--- LVM2/doc/example.conf	2006/09/02 01:18:17	1.27
+++ LVM2/doc/example.conf	2007/01/25 21:22:30	1.28
@@ -79,6 +79,12 @@
     # software RAID (md) devices by looking for md superblocks.
     # 1 enables; 0 disables.
     md_component_detection = 1
+
+    # If, while scanning the system for PVs, LVM2 encounters a device-mapper
+    # device that has its I/O suspended, it waits for it to become accessible.
+    # Set this to 1 to skip such devices.  This should only be needed
+    # in recovery situations.
+    ignore_suspended_devices = 0
 }
 
 # This section that allows you to configure the nature of the
--- LVM2/lib/activate/activate.h	2007/01/19 22:21:45	1.53
+++ LVM2/lib/activate/activate.h	2007/01/25 21:22:30	1.54
@@ -95,4 +95,9 @@
 int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg);
 
+/*
+ * Returns 1 if mapped device is not suspended.
+ */
+int device_is_usable(dev_t dev);
+
 #endif
--- LVM2/lib/activate/dev_manager.c	2007/01/09 20:31:08	1.118
+++ LVM2/lib/activate/dev_manager.c	2007/01/25 21:22:30	1.119
@@ -25,6 +25,7 @@
 #include "targets.h"
 #include "config.h"
 #include "filter.h"
+#include "activate.h"
 
 #include <limits.h>
 #include <dirent.h>
@@ -154,6 +155,42 @@
 	return r;
 }
 
+int device_is_usable(dev_t dev)
+{
+	struct dm_task *dmt;
+	struct dm_info info;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
+		log_error("Failed to allocate dm_task struct to check dev status");
+		return 0;
+	}
+
+	if (!dm_task_set_major(dmt, MAJOR(dev)) || !dm_task_set_minor(dmt, MINOR(dev)))
+		goto_out;
+
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to get state of mapped device");
+		goto out;
+	}
+
+	if (!dm_task_get_info(dmt, &info))
+		goto_out;
+
+	if (!info.exists || info.suspended)
+		goto out;
+
+	/* FIXME Also check for mirror block_on_error and mpath no paths */
+
+	/* FIXME Also check dependencies? */
+
+	r = 1;
+
+      out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
 static int _info(const char *name, const char *dlid, int mknodes,
 		 int with_open_count, struct dm_info *info,
 		 struct dm_pool *mem, char **uuid_out)
--- LVM2/lib/commands/toolcontext.c	2007/01/25 14:37:47	1.46
+++ LVM2/lib/commands/toolcontext.c	2007/01/25 21:22:30	1.47
@@ -592,6 +592,9 @@
 		return 0;
 	}
 
+	init_ignore_suspended_devices(find_config_tree_int(cmd,
+	    "devices/ignore_suspended_devices", DEFAULT_IGNORE_SUSPENDED_DEVICES));
+
 	dev_cache = find_config_tree_str(cmd, "devices/cache",
 				    cache_file);
 	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
--- LVM2/lib/config/defaults.h	2006/09/02 01:18:17	1.29
+++ LVM2/lib/config/defaults.h	2007/01/25 21:22:30	1.30
@@ -30,6 +30,7 @@
 #define DEFAULT_PROC_DIR "/proc"
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
+#define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
--- LVM2/lib/filters/filter.c	2007/01/25 14:37:47	1.37
+++ LVM2/lib/filters/filter.c	2007/01/25 21:22:30	1.38
@@ -19,6 +19,7 @@
 #include "lvm-string.h"
 #include "config.h"
 #include "metadata.h"
+#include "activate.h"
 
 #include <dirent.h>
 #include <unistd.h>
@@ -37,6 +38,7 @@
 } device_info_t;
 
 static int _md_major = -1;
+static int _device_mapper_major = -1;
 
 int md_major(void)
 {
@@ -90,6 +92,13 @@
 		return 0;
 	}
 
+	/* Skip suspended devices */
+	if (MAJOR(dev->dev) == _device_mapper_major &&
+	    ignore_suspended_devices() && device_is_usable(dev->dev)) {
+		log_debug("%s: Skipping: Suspended dm device", name);
+		return 0;
+	}
+
 	/* Check it's accessible */
 	if (!dev_open_flags(dev, O_RDONLY, 0, 1)) {
 		log_debug("%s: Skipping: open failed", name);
@@ -182,10 +191,14 @@
 		if (!strncmp("md", line + i, 2) && isspace(*(line + i + 2)))
 			_md_major = line_maj;
 
+		/* Look for device-mapper device */
+		/* FIXME Cope with multiple majors */
+		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
+			_device_mapper_major = line_maj;
+
 		/* Go through the valid device names and if there is a
 		   match store max number of partitions */
 		for (j = 0; device_info[j].name != NULL; j++) {
-
 			dev_len = strlen(device_info[j].name);
 			if (dev_len <= strlen(line + i) &&
 			    !strncmp(device_info[j].name, line + i, dev_len) &&
--- LVM2/lib/log/log.c	2007/01/25 14:37:48	1.37
+++ LVM2/lib/log/log.c	2007/01/25 21:22:30	1.38
@@ -49,6 +49,7 @@
 static int _already_logging = 0;
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
+static int _ignore_suspended_devices = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -195,6 +196,11 @@
 	_dmeventd_monitor = reg;
 }
 
+void init_ignore_suspended_devices(int ignore)
+{
+	_ignore_suspended_devices = ignore;
+}
+
 void init_cmd_name(int status)
 {
 	_log_cmd_name = status;
@@ -274,6 +280,11 @@
 	return _dmeventd_monitor;
 }
 
+int ignore_suspended_devices(void)
+{
+	return _ignore_suspended_devices;
+}
+
 void init_debug(int level)
 {
 	_debug_level = level;
--- LVM2/lib/log/log.h	2007/01/24 23:43:27	1.34
+++ LVM2/lib/log/log.h	2007/01/25 21:22:30	1.35
@@ -76,6 +76,7 @@
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
+void init_ignore_suspended_devices(int ignore);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -90,6 +91,7 @@
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
+int ignore_suspended_devices(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);


