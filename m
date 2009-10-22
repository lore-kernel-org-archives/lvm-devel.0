From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Oct 2009 12:55:49 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20091022125549.3590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-22 12:55:48

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 

Log message:
	Add udev flags support in libdevmapper and provide 'dmsetup udevflags' command to decode them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.305&r2=1.306
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW_DM	2009/10/12 04:06:42	1.305
+++ LVM2/WHATS_NEW_DM	2009/10/22 12:55:47	1.306
@@ -1,5 +1,7 @@
 Version 1.02.39 - 
 =====================================
+  Add dmsetup udevflags command to decode udev flags in given cookie value.
+  Add udev flags support in libdevmapper.
   Make libdm ABI consistent when built with/without selinux support.
 
 Version 1.02.38 - 25th September 2009
--- LVM2/libdm/libdevmapper.h	2009/09/25 11:58:00	1.97
+++ LVM2/libdm/libdevmapper.h	2009/10/22 12:55:47	1.98
@@ -164,7 +164,7 @@
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
-int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie);
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags);
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
 int dm_task_set_message(struct dm_task *dmt, const char *message);
@@ -1014,7 +1014,38 @@
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+/* Cookie prefixes.
+ * The cookie value consists of a prefix (16 bits) and a base (16 bits).
+ * We can use the prefix to store the flags. These flags are sent to
+ * kernel within given dm task. When returned back to userspace in
+ * DM_COOKIE udev environment variable, we can control several aspects
+ * of udev rules we use by decoding the cookie prefix. When doing the
+ * notification, we replace the cookie prefix with DM_COOKIE_MAGIC,
+ * so we notify the right semaphore.
+ */
 #define DM_COOKIE_MAGIC 0x0D4D
+#define DM_UDEV_FLAGS_MASK 0xFFFF0000
+#define DM_UDEV_FLAGS_SHIFT 16
+/*
+ * DM_UDEV_DISABLE_SUBSYTEM_RULES_FLAG is set in case we need to disable
+ * subsystem udev rules, but still we need the general DM udev rules to
+ * be applied (to create the nodes and symlinks under /dev and /dev/disk).
+ */
+#define DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG 0x0001
+/*
+ * DM_UDEV_DISABLE_DISK_RULES_FLAG is set in case we need to disable
+ * general DM rules that set symlinks in /dev/disk directory.
+ */
+#define DM_UDEV_DISABLE_DISK_RULES_FLAG 0x0002
+/*
+ * DM_UDEV_LOW_PRIORITY_FLAG is set in case we need to instruct the
+ * udev rules to give low priority to the device that is currently
+ * processed. For example, this provides a way to select which symlinks
+ * could be overwritten by high priority ones if their names are equal.
+ * Common situation is a name based on FS UUID while using origin and
+ * snapshot devices.
+ */
+#define DM_UDEV_LOW_PRIORITY_FLAG 0x0004
 
 int dm_cookie_supported(void);
 
--- LVM2/libdm/libdm-common.c	2009/10/12 04:06:42	1.86
+++ LVM2/libdm/libdm-common.c	2009/10/22 12:55:47	1.87
@@ -876,7 +876,7 @@
 	return 0;
 }
 
-int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	*cookie = 0;
 
@@ -1129,7 +1129,7 @@
 	return 0;
 }
 
-int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	int semid;
 
@@ -1151,11 +1151,11 @@
 		goto bad;
 	}
 
-	dmt->event_nr = *cookie;
+	dmt->event_nr = (0x0000FFFF & *cookie) | (flags << 16);
 	dmt->cookie_set = 1;
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task",
-		  dmt->event_nr, semid);
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task "
+		  "with flags 0x%" PRIx16, *cookie, semid, flags);
 
 	return 1;
 
--- LVM2/libdm/libdm-deptree.c	2009/09/25 18:30:27	1.58
+++ LVM2/libdm/libdm-deptree.c	2009/10/22 12:55:48	1.59
@@ -841,7 +841,7 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie))
+	if (!dm_task_set_cookie(dmt, cookie, 0))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -881,7 +881,7 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie))
+	if (!dm_task_set_cookie(dmt, cookie, 0))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -924,7 +924,7 @@
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
 		log_error("Failed to set read ahead");
 
-	if (!dm_task_set_cookie(dmt, cookie))
+	if (!dm_task_set_cookie(dmt, cookie, 0))
 		goto out;
 
 	if ((r = dm_task_run(dmt)))
--- LVM2/libdm/ioctl/libdm-iface.c	2009/09/25 11:58:00	1.62
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/10/22 12:55:48	1.63
@@ -1492,8 +1492,14 @@
  */
 static int _udev_complete(struct dm_task *dmt)
 {
-	if (dmt->cookie_set)
-		return dm_udev_complete(dmt->event_nr);
+	uint32_t cookie;
+
+	if (dmt->cookie_set) {
+		/* strip flags from the cookie and use cookie magic instead */
+		cookie = (dmt->event_nr & ~DM_UDEV_FLAGS_MASK) |
+			  (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
+		return dm_udev_complete(cookie);
+	}
 
 	return 1;
 }
--- LVM2/tools/dmsetup.c	2009/09/11 15:53:58	1.124
+++ LVM2/tools/dmsetup.c	2009/10/22 12:55:48	1.125
@@ -595,7 +595,7 @@
 	if (_switches[NOTABLE_ARG])
 		dm_udev_set_sync_support(0);
 
-	if (!dm_task_set_cookie(dmt, &cookie) ||
+	if (!dm_task_set_cookie(dmt, &cookie, 0) ||
 	    !dm_task_run(dmt))
 		goto out;
 
@@ -630,7 +630,7 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
-	if (!dm_task_set_cookie(dmt, &cookie) ||
+	if (!dm_task_set_cookie(dmt, &cookie, 0) ||
 	    !dm_task_run(dmt))
 		goto out;
 
@@ -758,15 +758,70 @@
 	return r;
 }
 
-static int _udevcomplete(int argc, char **argv, void *data __attribute((unused)))
+static uint32_t _get_cookie_value(char *str_value)
 {
-	uint32_t cookie;
+	unsigned long int value;
 	char *p;
 
-	if (!(cookie = (uint32_t) strtoul(argv[1], &p, 0)) || *p) {
+	if (!(value = strtoul(str_value, &p, 0)) ||
+	    *p ||
+	    (value == ULONG_MAX && errno == ERANGE) ||
+	    value > 0xFFFFFFFF) {
 		err("Incorrect cookie value");
 		return 0;
 	}
+	else
+		return (uint32_t) value;
+}
+
+static int _udevflags(int args, char **argv, void *data __attribute((unused)))
+{
+	uint32_t cookie;
+	uint16_t flags;
+	int i;
+	static const char *dm_flag_names[] = {"DISABLE_SUBSYSTEM_RULES",
+					      "DISABLE_DISK_RULES",
+					      "LOW_PRIORITY",
+					       0, 0, 0, 0, 0};
+
+	if (!(cookie = _get_cookie_value(argv[1])))
+		return 0;
+
+	flags = cookie >> DM_UDEV_FLAGS_SHIFT;
+
+	for (i = 0; i < DM_UDEV_FLAGS_SHIFT; i++)
+		if (1 << i & flags) {
+			if (i < DM_UDEV_FLAGS_SHIFT / 2 && dm_flag_names[i])
+				printf("DM_UDEV_%s_FLAG='1'\n", dm_flag_names[i]);
+			else if (i < DM_UDEV_FLAGS_SHIFT / 2)
+				/*
+				 * This is just a fallback. Each new DM flag
+				 * should have its symbolic name assigned.
+				 */
+				printf("DM_UDEV_FLAG%d='1'\n", i);
+			else
+				/*
+				 * We can't assign symbolic names to subsystem
+				 * flags. Their semantics vary based on the
+				 * subsystem that is currently used.
+				 */
+				printf("DM_SUBSYSTEM_UDEV_FLAG%d='1'\n",
+					i - DM_UDEV_FLAGS_SHIFT / 2);
+		}
+
+	return 1;
+}
+
+static int _udevcomplete(int argc, char **argv, void *data __attribute((unused)))
+{
+	uint32_t cookie;
+
+	if (!(cookie = _get_cookie_value(argv[1])))
+		return 0;
+
+	/* strip flags from the cookie and use cookie magic instead */
+	cookie = (cookie & ~DM_UDEV_FLAGS_MASK) |
+		  (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
 
 	return dm_udev_complete(cookie);
 }
@@ -953,7 +1008,7 @@
 				    _read_ahead_flags))
 		goto out;
 
-	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie))
+	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, 0))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -2436,6 +2491,7 @@
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"udevflags", "<cookie>", 1, 1, _udevflags},
 	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
 	{"udevcomplete_all", "", 0, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, _udevcookies},


