From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 15 Aug 2014 13:41:24 -0400 (EDT)
Subject: [PATCH] dmsetup: provide deferred remove feature
Message-ID: <alpine.LRH.2.02.1408151338180.11441@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Here I'm sending the update deferred remove patch. I tested that lvm 
compiled without this patch works with libdevmapper compiled with this 
patch.


From: Mikulas Patocka <mpatocka@redhat.com>

This patch adds a new flag --deferred to dmsetup remove. If this flag is
specified and the device is open, it is scheduled to be deleted on close.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libdm/.exported_symbols     |    1 +
 libdm/ioctl/libdm-iface.c   |   39 ++++++++++++++++++++++++++++++++++++++-
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    5 +++++
 libdm/misc/dm-ioctl.h       |   14 ++++++++++++++
 man/dmsetup.8.in            |   41 ++++++++++++++++++++---------------------
 tools/dmsetup.c             |   14 +++++++++++---
 7 files changed, 90 insertions(+), 25 deletions(-)

Index: lvm2-copy/tools/dmsetup.c
===================================================================
--- lvm2-copy.orig/tools/dmsetup.c	2014-08-15 16:45:02.000000000 +0200
+++ lvm2-copy/tools/dmsetup.c	2014-08-15 16:50:13.000000000 +0200
@@ -120,6 +120,7 @@ enum {
 	ADD_NODE_ON_RESUME_ARG,
 	CHECKS_ARG,
 	COLS_ARG,
+	DEFERRED_ARG,
 	SELECT_ARG,
 	EXEC_ARG,
 	FORCE_ARG,
@@ -468,9 +469,10 @@ static void _display_info_long(struct dm
 
 	printf("Name:              %s\n", dm_task_get_name(dmt));
 
-	printf("State:             %s%s\n",
+	printf("State:             %s%s%s\n",
 	       info->suspended ? "SUSPENDED" : "ACTIVE",
-	       info->read_only ? " (READ-ONLY)" : "");
+	       info->read_only ? " (READ-ONLY)" : "",
+	       info->deferred_remove ? " (DEFERRED REMOVE)" : "");
 
 	/* FIXME Old value is being printed when it's being changed. */
 	if (dm_task_get_read_ahead(dmt, &read_ahead))
@@ -1321,6 +1323,9 @@ static int _simple(int task, const char 
 	if (_switches[RETRY_ARG] && task == DM_DEVICE_REMOVE)
 		dm_task_retry_remove(dmt);
 
+	if (_switches[DEFERRED_ARG] && (task == DM_DEVICE_REMOVE || task == DM_DEVICE_REMOVE_ALL))
+		dm_task_deferred_remove(dmt);
+
 	r = dm_task_run(dmt);
 
       out:
@@ -3071,7 +3076,7 @@ static struct command _commands[] = {
 	  "\t                  [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
 	  "\t                  [--notable | --table <table> | <table_file>]",
 	 1, 2,0,  _create},
-	{"remove", "[-f|--force] <device>", 0, -1, 1, _remove},
+	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, 0,  _remove_all},
 	{"suspend", "[--noflush] <device>", 0, -1, 1, _suspend},
 	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, _resume},
@@ -3521,6 +3526,7 @@ static int _process_switches(int *argc, 
 		{"readonly", 0, &ind, READ_ONLY},
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"columns", 0, &ind, COLS_ARG},
+		{"deferred", 0, &ind, DEFERRED_ARG},
 		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
@@ -3694,6 +3700,8 @@ static int _process_switches(int *argc, 
 			/* FIXME Accept modes as per chmod */
 			_int_args[MODE_ARG] = (int) strtol(optarg, NULL, 8);
 		}
+		if (ind == DEFERRED_ARG)
+			_switches[DEFERRED_ARG]++;
 		if (ind == EXEC_ARG) {
 			_switches[EXEC_ARG]++;
 			_command = optarg;
Index: lvm2-copy/libdm/ioctl/libdm-iface.c
===================================================================
--- lvm2-copy.orig/libdm/ioctl/libdm-iface.c	2014-08-15 16:45:02.000000000 +0200
+++ lvm2-copy/libdm/ioctl/libdm-iface.c	2014-08-15 17:22:11.000000000 +0200
@@ -17,6 +17,7 @@
 #include "libdm-targets.h"
 #include "libdm-common.h"
 
+#include <stddef.h>
 #include <fcntl.h>
 #include <dirent.h>
 #include <sys/ioctl.h>
@@ -654,6 +655,7 @@ int dm_task_get_info(struct dm_task *dmt
 	info->live_table = dmt->dmi.v4->flags & DM_ACTIVE_PRESENT_FLAG ? 1 : 0;
 	info->inactive_table = dmt->dmi.v4->flags & DM_INACTIVE_PRESENT_FLAG ?
 	    1 : 0;
+	info->deferred_remove = dmt->dmi.v4->flags & DM_DEFERRED_REMOVE;
 	info->target_count = dmt->dmi.v4->target_count;
 	info->open_count = dmt->dmi.v4->open_count;
 	info->event_nr = dmt->dmi.v4->event_nr;
@@ -862,6 +864,13 @@ int dm_task_retry_remove(struct dm_task 
 	return 1;
 }
 
+int dm_task_deferred_remove(struct dm_task *dmt)
+{
+	dmt->deferred_remove = 1;
+
+	return 1;
+}
+
 int dm_task_query_inactive_table(struct dm_task *dmt)
 {
 	dmt->query_inactive_table = 1;
@@ -1137,6 +1146,9 @@ static struct dm_ioctl *_flatten(struct 
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
+	if (dmt->deferred_remove && (dmt->type == DM_DEVICE_REMOVE || dmt->type == DM_DEVICE_REMOVE_ALL))
+		dmi->flags |= DM_DEFERRED_REMOVE;
+
 	if (dmt->secure_data) {
 		if (_dm_version_minor < 20)
 			log_verbose("Secure data flag unsupported by kernel. "
@@ -1732,7 +1744,7 @@ static struct dm_ioctl *_do_dm_ioctl(str
 	}
 
 	log_debug_activation("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-			     "%s%c%c%s%s%s%s%s%s %.0" PRIu64 " %s [%u] (*%u)",
+			     "%s%c%c%s%s%s%s%s%s%s %.0" PRIu64 " %s [%u] (*%u)",
 			     _cmd_data_v4[dmt->type].name,
 			     dmt->new_uuid ? "UUID " : "",
 			     dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1748,6 +1760,7 @@ static struct dm_ioctl *_do_dm_ioctl(str
 			     dmt->read_only ? "R" : "",
 			     dmt->skip_lockfs ? "S " : "",
 			     dmt->retry_remove ? "T " : "",
+			     dmt->deferred_remove ? "D " : "",
 			     dmt->secure_data ? "W " : "",
 			     dmt->query_inactive_table ? "I " : "",
 			     dmt->enable_checks ? "C" : "",
@@ -2006,3 +2019,27 @@ void dm_lib_exit(void)
 	_version_ok = 1;
 	_version_checked = 0;
 }
+
+/*
+ * This is a trick to add the field deferred_remove to struct dm_info and keep
+ * ABI compatibility.
+ *
+ * The old binaries linked against old version of libdevmapper will use this
+ * function that returns dm_info without the deferred_remove field.
+ *
+ * The new binaries will use dm_task_get_info_with_deferred_remove because of
+ * #define dm_task_get_info dm_task_get_info_with_deferred_remove
+ *
+ * Note that this function must be kept at the end of the file to make sure that
+ * no code in this file accidentally calls it.
+ */
+#undef dm_task_get_info
+int dm_task_get_info(struct dm_task *dmt, struct dm_info *info);
+int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
+{
+	struct dm_info new_info;
+	if (!dm_task_get_info_with_deferred_remove(dmt, &new_info))
+		return 0;
+	memcpy(info, &new_info, offsetof(struct dm_info, deferred_remove));
+	return 1;
+}
Index: lvm2-copy/libdm/ioctl/libdm-targets.h
===================================================================
--- lvm2-copy.orig/libdm/ioctl/libdm-targets.h	2014-08-15 16:45:02.000000000 +0200
+++ lvm2-copy/libdm/ioctl/libdm-targets.h	2014-08-15 16:50:13.000000000 +0200
@@ -65,6 +65,7 @@ struct dm_task {
 	int new_uuid;
 	int secure_data;
 	int retry_remove;
+	int deferred_remove;
 	int enable_checks;
 	int expected_errno;
 
Index: lvm2-copy/libdm/libdevmapper.h
===================================================================
--- lvm2-copy.orig/libdm/libdevmapper.h	2014-08-15 16:45:02.000000000 +0200
+++ lvm2-copy/libdm/libdevmapper.h	2014-08-15 16:58:32.000000000 +0200
@@ -149,6 +149,8 @@ struct dm_info {
 	int read_only;		/* 0:read-write; 1:read-only */
 
 	int32_t target_count;
+
+	int deferred_remove;
 };
 
 struct dm_deps {
@@ -172,6 +174,8 @@ struct dm_versions {
 
 int dm_get_library_version(char *version, size_t size);
 int dm_task_get_driver_version(struct dm_task *dmt, char *version, size_t size);
+
+#define dm_task_get_info dm_task_get_info_with_deferred_remove
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *dmi);
 
 /*
@@ -222,6 +226,7 @@ int dm_task_query_inactive_table(struct 
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
 int dm_task_retry_remove(struct dm_task *dmt);
+int dm_task_deferred_remove(struct dm_task *dmt);
 
 /*
  * Enable checks for common mistakes such as issuing ioctls in an unsafe order.
Index: lvm2-copy/libdm/misc/dm-ioctl.h
===================================================================
--- lvm2-copy.orig/libdm/misc/dm-ioctl.h	2014-08-15 16:45:02.000000000 +0200
+++ lvm2-copy/libdm/misc/dm-ioctl.h	2014-08-15 16:50:13.000000000 +0200
@@ -343,4 +343,18 @@ enum {
  */
 #define DM_DATA_OUT_FLAG		(1 << 16) /* Out */
 
+/*
+ * Remove the device when it is closed.
+ *
+ * This flag may be set on DM_DEV_REMOVE or DM_REMOVE_ALL to indicate that
+ * the device should be remove on close if it is open.
+ *
+ * On return from DM_DEV_REMOVE, this flag indicates that the device was not
+ * removed because it was open, but it is scheduled to be removed on close.
+ *
+ * When this flag is returned in DM_DEV_STATUS or other ioctls, it indicates
+ * that the device is scheduled to be removed on close.
+ */
+#define DM_DEFERRED_REMOVE		(1 << 17) /* In/Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */
Index: lvm2-copy/libdm/.exported_symbols
===================================================================
--- lvm2-copy.orig/libdm/.exported_symbols	2014-08-15 17:10:02.000000000 +0200
+++ lvm2-copy/libdm/.exported_symbols	2014-08-15 17:10:06.000000000 +0200
@@ -1,2 +1,3 @@
 dm_log
 dm_log_with_errno
+dm_task_get_info
Index: lvm2-copy/man/dmsetup.8.in
===================================================================
--- lvm2-copy.orig/man/dmsetup.8.in	2014-08-15 17:22:56.000000000 +0200
+++ lvm2-copy/man/dmsetup.8.in	2014-08-15 18:52:24.000000000 +0200
@@ -81,10 +81,12 @@ dmsetup \(em low level logical volume ma
 .B dmsetup remove
 .RB [ \-f | \-\-force ]
 .RB [ \-\-retry ]
+.RB [ \-\-deferred ]
 .I device_name
 .br
 .B dmsetup remove_all
 .RB [ \-f | \-\-force ]
+.RB [ \-\-deferred ]
 .br
 .B dmsetup rename
 .I device_name new_name
@@ -436,34 +438,31 @@ reactivating it with proper mangling mod
 .B remove
 .RB [ \-f | \-\-force ]
 .RB [ \-\-retry ]
+.RB [ \-\-deferred ]
 .I device_name
 .br
-Removes a device.  It will no longer be visible to dmsetup.
-Open devices cannot be removed except with older kernels
-that contain a version of device-mapper prior to 4.8.0.
-In this case the device will be deleted when its open_count
-drops to zero.  From version 4.8.0 onwards, if a device can't
-be removed because an uninterruptible process is waiting for
-I/O to return from it, adding \fB\-\-force\fP will replace the table
-with one that fails all I/O, which might allow the
-process to be killed. If an attempt to remove a device fails,
-perhaps because a process run from a quick udev rule
-temporarily opened the device, the \fB\-\-retry\fP option will cause
-the operation to be retried for a few seconds before failing.
-Do NOT combine \fB\-\-force\fP and \fB\-\-udevcookie\fP,
-as udev may start to process udev rules in the middle of error target
-replacement and result in nondeterministic result.
+Removes a device.  It will no longer be visible to dmsetup.  Open devices cannot
+be removed, adding \fB\-\-force\fP will replace the table with one that fails
+all I/O.  \fB\-\-deferred\fP will enable deferred removal of open devices - the
+device will be removed when the last user closes it. The deferred removal
+feature is present in kernels starting with 3.13.  If an attempt to remove a
+device fails, perhaps because a process run from a quick udev rule temporarily
+opened the device, the \fB\-\-retry\fP option will cause the operation to be
+retried for a few seconds before failing.  Do NOT combine \fB\-\-force\fP and
+\fB\-\-udevcookie\fP, as udev may start to process udev rules in the middle of
+error target replacement and result in nondeterministic result.
 .br
 .HP
 .B remove_all
 .RB [ \-f | \-\-force ]
+.RB [ \-\-deferred ]
 .br
-Attempts to remove all device definitions i.e. reset the driver.
-Use with care!  From version 4.8.0 onwards, if devices can't
-be removed because uninterruptible processes are waiting for
-I/O to return from them, adding \fB\-\-force\fP will replace the table
-with one that fails all I/O, which might allow the
-process to be killed.  This also runs \fBmknodes\fP afterwards.
+Attempts to remove all device definitions i.e. reset the driver.  This also runs
+\fBmknodes\fP afterwards.  Use with care!  Open devices cannot be removed,
+adding \fB\-\-force\fP will replace the table with one that fails all I/O.
+\fB\-\-deferred\fP will enable deferred removal of open devices - the device
+will be removed when the last user closes it. The deferred removal feature is
+present in kernels starting with 3.13.
 .br
 .HP
 .B rename


