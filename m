From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Feb 2011 16:08:13 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110204160813.1233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-02-04 16:08:12

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 
	libdm/misc     : dm-ioctl.h 

Log message:
	Suport DM_SECURE_DATA_FLAG.
	
	It will be user for cryptsetup to ensure buffers are properly
	wiped when sending sensitive data (key).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.440&r2=1.441
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-ioctl.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW_DM	2011/01/28 11:41:51	1.440
+++ LVM2/WHATS_NEW_DM	2011/02/04 16:08:11	1.441
@@ -1,5 +1,6 @@
 Version 1.02.62 - 
 ===================================
+  Add dm_task_secure_data to libdevmapper to wipe ioctl buffers in kernel.
   Set DM_UDEV_DISABLE_OTHER_RULES_FLAG for suspended DM devices in udev rules.
   Initialize pool object for each row in _output_as_rows().
 
--- LVM2/libdm/libdevmapper.h	2011/01/10 13:42:31	1.133
+++ LVM2/libdm/libdevmapper.h	2011/02/04 16:08:11	1.134
@@ -184,6 +184,7 @@
 int dm_task_skip_lockfs(struct dm_task *dmt);
 int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
+int dm_task_secure_data(struct dm_task *dmt);
 
 /*
  * Control read_ahead.
--- LVM2/libdm/libdm-common.c	2011/01/12 20:42:51	1.107
+++ LVM2/libdm/libdm-common.c	2011/02/04 16:08:12	1.108
@@ -200,6 +200,7 @@
 	dmt->cookie_set = 0;
 	dmt->query_inactive_table = 0;
 	dmt->new_uuid = 0;
+	dmt->secure_data = 0;
 
 	return dmt;
 }
--- LVM2/libdm/ioctl/libdm-iface.c	2011/01/31 11:54:55	1.89
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/02/04 16:08:12	1.90
@@ -1273,6 +1273,13 @@
 	return 1;
 }
 
+int dm_task_secure_data(struct dm_task *dmt)
+{
+	dmt->secure_data = 1;
+
+	return 1;
+}
+
 int dm_task_query_inactive_table(struct dm_task *dmt)
 {
 	dmt->query_inactive_table = 1;
@@ -1521,6 +1528,8 @@
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
+	if (dmt->secure_data)
+		dmi->flags |= DM_SECURE_DATA_FLAG;
 	if (dmt->query_inactive_table) {
 		if (_dm_version_minor < 16)
 			log_warn("WARNING: Inactive table query unsupported "
@@ -1737,6 +1746,7 @@
 	task->read_only = dmt->read_only;
 	task->head = dmt->head;
 	task->tail = dmt->tail;
+	task->secure_data = dmt->secure_data;
 
 	r = dm_task_run(task);
 
@@ -1940,7 +1950,7 @@
 	}
 
 	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
 		  dmt->new_uuid ? "UUID " : "",
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1954,6 +1964,7 @@
 		  dmt->no_open_count ? 'N' : 'O',
 		  dmt->no_flush ? 'N' : 'F',
 		  dmt->skip_lockfs ? "S " : "",
+		  dmt->secure_data ? "W " : "",
 		  dmt->query_inactive_table ? "I " : "",
 		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size);
--- LVM2/libdm/ioctl/libdm-targets.h	2010/10/15 01:10:28	1.27
+++ LVM2/libdm/ioctl/libdm-targets.h	2011/02/04 16:08:12	1.28
@@ -63,6 +63,7 @@
 	uint64_t existing_table_size;
 	int cookie_set;
 	int new_uuid;
+	int secure_data;
 
 	char *uuid;
 };
--- LVM2/libdm/misc/dm-ioctl.h	2010/10/25 11:44:21	1.7
+++ LVM2/libdm/misc/dm-ioctl.h	2011/02/04 16:08:12	1.8
@@ -269,9 +269,9 @@
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	19
+#define DM_VERSION_MINOR	20
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2010-10-14)"
+#define DM_VERSION_EXTRA	"-ioctl (2011-02-02)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -330,4 +330,10 @@
  */
 #define DM_UUID_FLAG			(1 << 14) /* In */
 
+/*
+ * If set, all buffers are wiped after use. Used when sending
+ * or requesting sensitive data like crypt key.
+ */
+#define DM_SECURE_DATA_FLAG		(1 << 15) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */


