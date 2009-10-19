From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 19 Oct 2009 13:46:26 +0200
Subject: [PATCH 1/4] Introduce flags to control udev rules
Message-ID: <4ADC5192.7050607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch add flag support to control udev rules. The cookie value
consists of a prefix (16 bits) and a base (16 bits). We can use the
prefix to store the flags. These flags are sent to kernel within
given dm task. When returned back to userspace in DM_COOKIE udev
environment variable, we can control several aspects of udev rules we
use by decoding the cookie prefix. When doing the notification, we
replace the cookie prefix with DM_COOKIE_MAGIC, so we notify the right
semaphore.

The flags themselves are divided in two parts -- DM related flags (8 bits)
and subsystem related flags (8bits) But we can discuss this allocation.
any comments are welcome as well as any tips for adding more flags for
any other special situations.

I've defined these flags for now:

DM_UDEV_FLAG_NULL
  - not a flag in a sense to be processed in udev rule, but used just
    for initialisation throughout the code.

DM_UDEV_FLAG_DISABLE_SUBSYSTEM_RULES
  - general DM udev rules are applied (10-dm.rules), but instructs the
    all the subsystem rules to be skipped

DM_UDEV_FLAG_DISABLE_DISK_RULES
  - disables general "/dev/disk" rules (12-dm-disk.rules)

DM_UDEV_FLAG_HIGH_SYMLINK_PRIORITY
  - instructs the rules to give higher priority for symlinks of the
    device being processed that could have the same name as another
    device (example scenario: symlink names based on FS UUID and
    origin/snapshot situation -- we don't want the symlink for the
    snapshot to overwrite the symlink for the origin)

The flags are passed in with dm_task_set_cookie function call. To decode
the flag so it can be imported into udev environment as a variable, we
call "dmsetup udevflags <cookie>". The format here is:

DM_UDEV_FLAG_<flag_name>='1' (for DM flags with symbolic names)
DM_UDEV_FLAG_<flag_position>='1' (for DM flags without symbolic names)
DM_SUBSYSTEM_UDEV_FLAG_<flag_position>='1' (for all subsystem flags, these
ones don't have a symbolic names assigned)

Peter


diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 861c009..090e35c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1492,8 +1492,13 @@ static int _mknodes_v4(struct dm_task *dmt)
  */
 static int _udev_complete(struct dm_task *dmt)
 {
-	if (dmt->cookie_set)
-		return dm_udev_complete(dmt->event_nr);
+	uint32_t cookie;
+
+	if (dmt->cookie_set) {
+		/* strip flags from the cookie and use cookie magic instead */
+		cookie = (dmt->event_nr & 0x0000FFFF) | (DM_COOKIE_MAGIC << 16);
+		return dm_udev_complete(cookie);
+	}
 
 	return 1;
 }
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 204372a..a40a843 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -164,7 +164,7 @@ int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor, int allow
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
-int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie);
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags);
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
 int dm_task_set_message(struct dm_task *dmt, const char *message);
@@ -1014,7 +1014,33 @@ int dm_report_field_uint64(struct dm_report *rh, struct dm_report_field *field,
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+/* Cookie prefixes.
+ * The cookie value consists of a prefix (16 bits) and a base (16 bits).
+ * We can use the prefix to store the flags. These flags are sent to
+ * kernel within given dm task. When returned back to userspace in
+ * DM_COOKIE udev enviroment variable, we can control several aspects
+ * of udev rules we use by decoding the cookie prefix. When doing the
+ * notification, we replace the cookie prefix with DM_COOKIE_MAGIC,
+ * so we notify the right semaphore.
+ */
 #define DM_COOKIE_MAGIC 0x0D4D
+#define DM_UDEV_FLAG_NULL 0x0000
+/*
+ * DM_UDEV_FLAG_DISABLE_SUBSYTEM_RULES flag is set in case we need to disable
+ * subsystem udev rules, but still we need the general DM udev rules to
+ * be applied (to create the nodes and symlinks in DM directory under /dev).
+ */
+#define DM_UDEV_FLAG_DISABLE_SUBSYSTEM_RULES 0x0001
+/*
+ * DM_UDEV_FLAG_DISABLE_DISK_RULES flag is set in case we need to disable
+ * general DM rules that set symlinks in /dev/disk directory.
+ */
+#define DM_UDEV_FLAG_DISABLE_DISK_RULES 0x0002
+/*
+ * DM_UDEV_FLAG_HIGH_SYMLINK_PRIORITY flag is set in case we need to instruct the
+ * udev rules to give higher priority to the symlinks being created for a device.
+ */
+#define DM_UDEV_FLAG_HIGH_SYMLINK_PRIORITY 0x0004
 
 int dm_cookie_supported(void);
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 248d3ac..3079c24 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -876,7 +876,7 @@ int dm_udev_get_sync_support(void)
 	return 0;
 }
 
-int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	*cookie = 0;
 
@@ -1129,7 +1129,7 @@ bad:
 	return 0;
 }
 
-int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
+int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	int semid;
 
@@ -1151,11 +1151,11 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie)
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
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 75fb201..4b8ffc9 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -841,7 +841,7 @@ static int _deactivate_node(const char *name, uint32_t major, uint32_t minor, ui
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie))
+	if (!dm_task_set_cookie(dmt, cookie, DM_UDEV_FLAG_NULL))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -881,7 +881,7 @@ static int _rename_node(const char *old_name, const char *new_name, uint32_t maj
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie))
+	if (!dm_task_set_cookie(dmt, cookie, DM_UDEV_FLAG_NULL))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -924,7 +924,7 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
 		log_error("Failed to set read ahead");
 
-	if (!dm_task_set_cookie(dmt, cookie))
+	if (!dm_task_set_cookie(dmt, cookie, DM_UDEV_FLAG_NULL))
 		goto out;
 
 	if ((r = dm_task_run(dmt)))
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index c3539a7..dda5063 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -595,7 +595,7 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 	if (_switches[NOTABLE_ARG])
 		dm_udev_set_sync_support(0);
 
-	if (!dm_task_set_cookie(dmt, &cookie) ||
+	if (!dm_task_set_cookie(dmt, &cookie, DM_UDEV_FLAG_NULL) ||
 	    !dm_task_run(dmt))
 		goto out;
 
@@ -630,7 +630,7 @@ static int _rename(int argc, char **argv, void *data __attribute((unused)))
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
-	if (!dm_task_set_cookie(dmt, &cookie) ||
+	if (!dm_task_set_cookie(dmt, &cookie, DM_UDEV_FLAG_NULL) ||
 	    !dm_task_run(dmt))
 		goto out;
 
@@ -758,6 +758,34 @@ static int _splitname(int argc, char **argv, void *data __attribute((unused)))
 	return r;
 }
 
+static int _udevflags(int args, char **argv, void *data __attribute((unused)))
+{
+	uint16_t flags;
+	char *p;
+	uint32_t i;
+	static const char *dm_flag_names[] = {"DISABLE_SUBSYSTEM_RULES",
+					      "DISABLE_DISK_RULES",
+					      "HIGH_SYMLINK_PRIORITY",
+					       0, 0, 0, 0, 0};
+
+	if (!(flags = (uint16_t) (strtoul(argv[1], &p, 0) >> 16)) || *p) {
+		err("Incorrect cookie value");
+		return 0;
+	}
+
+	for (i = 0; i < 16; i++)
+		if (1 << i & flags) {
+			if (i < 8 && dm_flag_names[i])
+				printf("DM_UDEV_FLAG_%s='1'\n", dm_flag_names[i]);
+			else if (i < 8)
+				printf("DM_UDEV_FLAG_%d='1'\n", i);
+			else
+				printf("DM_SUBSYSTEM_UDEV_FLAG_%d='1'\n", i - 8);
+		}
+
+	return 1;
+}
+
 static int _udevcomplete(int argc, char **argv, void *data __attribute((unused)))
 {
 	uint32_t cookie;
@@ -768,6 +796,9 @@ static int _udevcomplete(int argc, char **argv, void *data __attribute((unused))
 		return 0;
 	}
 
+	/* strip flags from the cookie and use cookie magic instead */
+	cookie = (cookie & 0x0000FFFF) | (DM_COOKIE_MAGIC << 16);
+
 	return dm_udev_complete(cookie);
 }
 
@@ -953,7 +984,7 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 				    _read_ahead_flags))
 		goto out;
 
-	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie))
+	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, DM_UDEV_FLAG_NULL))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -2436,6 +2467,7 @@ static struct command _commands[] = {
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"udevflags", "<cookie>", 1, 1, _udevflags},
 	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
 	{"udevcomplete_all", "", 0, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, _udevcookies},


