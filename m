From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 24 Jan 2013 15:13:00 -0500 (EST)
Subject: [PATCH] userspace: dm statistics
In-Reply-To: <Pine.LNX.4.64.1301241507590.8036@file.rdu.redhat.com>
References: <Pine.LNX.4.64.1301241507590.8036@file.rdu.redhat.com>
Message-ID: <Pine.LNX.4.64.1301241511050.8036@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the userspace patch for two-way messages that are needed for 
statistics.

BTW. when querying large data sets, dmsetup fails with "Huge memory 
allocation (size 67108864) rejected - metadata corruption?"

- do you think this limit should be removed from dmsetup?

Mikulas

---
 libdm/ioctl/libdm-iface.c |   19 +++++++++++++++++++
 libdm/libdevmapper.h      |    1 +
 libdm/misc/dm-ioctl.h     |    5 +++++
 tools/dmsetup.c           |    9 +++++++++
 4 files changed, 34 insertions(+)

Index: LVM2.2.02.98/libdm/misc/dm-ioctl.h
===================================================================
--- LVM2.2.02.98.orig/libdm/misc/dm-ioctl.h	2012-10-15 16:24:58.000000000 +0200
+++ LVM2.2.02.98/libdm/misc/dm-ioctl.h	2013-01-23 10:18:48.000000000 +0100
@@ -338,4 +338,9 @@ enum {
  */
 #define DM_SECURE_DATA_FLAG		(1 << 15) /* In */
 
+/*
+ * If set, message generated output.
+ */
+#define DM_MESSAGE_OUT_FLAG		(1 << 16) /* Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */
Index: LVM2.2.02.98/libdm/ioctl/libdm-iface.c
===================================================================
--- LVM2.2.02.98.orig/libdm/ioctl/libdm-iface.c	2013-01-23 10:22:09.000000000 +0100
+++ LVM2.2.02.98/libdm/ioctl/libdm-iface.c	2013-01-23 13:03:38.000000000 +0100
@@ -700,6 +700,24 @@ struct dm_versions *dm_task_get_versions
 				       dmt->dmi.v4->data_start);
 }
 
+const char *dm_task_get_message_result(struct dm_task *dmt)
+{
+	const char *start, *end;
+	if (!(dmt->dmi.v4->flags & DM_MESSAGE_OUT_FLAG))
+		return NULL;
+	start = (const char *) dmt->dmi.v4 + dmt->dmi.v4->data_start;
+	end = (const char *) dmt->dmi.v4 + dmt->dmi.v4->data_size;
+	if (end < start) {
+		log_error(INTERNAL_ERROR "Corrupted message structure returned: %d > %d", (int)dmt->dmi.v4->data_start, (int)dmt->dmi.v4->data_size);
+		return NULL;
+	}
+	if (!memchr(start, 0, end - start)) {
+		log_error(INTERNAL_ERROR "Message result doesn't contain terminating nul character");
+		return NULL;
+	}
+	return start;
+}
+
 int dm_task_set_ro(struct dm_task *dmt)
 {
 	dmt->read_only = 1;
@@ -1870,6 +1888,7 @@ repeat_ioctl:
 		case DM_DEVICE_STATUS:
 		case DM_DEVICE_TABLE:
 		case DM_DEVICE_WAITEVENT:
+		case DM_DEVICE_TARGET_MSG:
 			_ioctl_buffer_double_factor++;
 			_dm_zfree_dmi(dmi);
 			goto repeat_ioctl;
Index: LVM2.2.02.98/libdm/libdevmapper.h
===================================================================
--- LVM2.2.02.98.orig/libdm/libdevmapper.h	2013-01-23 10:42:52.000000000 +0100
+++ LVM2.2.02.98/libdm/libdevmapper.h	2013-01-23 10:46:26.000000000 +0100
@@ -178,6 +178,7 @@ const char *dm_task_get_uuid(const struc
 
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt);
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt);
+const char *dm_task_get_message_result(struct dm_task *dmt);
 
 /*
  * These functions return device-mapper names based on the value
Index: LVM2.2.02.98/tools/dmsetup.c
===================================================================
--- LVM2.2.02.98.orig/tools/dmsetup.c	2013-01-23 10:50:18.000000000 +0100
+++ LVM2.2.02.98/tools/dmsetup.c	2013-01-24 12:28:47.000000000 +0100
@@ -770,6 +770,7 @@ static int _message(CMD_ARGS)
 	size_t sz = 1;
 	struct dm_task *dmt;
 	char *str;
+	const char *result;
 	uint64_t sector;
 	char *endptr;
 
@@ -833,6 +834,14 @@ static int _message(CMD_ARGS)
 	if (!dm_task_run(dmt))
 		goto out;
 
+	result = dm_task_get_message_result(dmt);
+	if (result) {
+		if (!*result || result[strlen(result) - 1] == '\n')
+			fputs(result, stdout);
+		else
+			puts(result);
+	}
+
 	r = 1;
 
       out:


