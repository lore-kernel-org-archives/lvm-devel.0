From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2011 16:17:15 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20110705161715.28010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-05 16:17:14

Modified files:
	libdm          : libdm-common.c 

Log message:
	decode cookie flags in debug msgs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/libdm/libdm-common.c	2011/07/01 14:09:20	1.122
+++ LVM2/libdm/libdm-common.c	2011/07/05 16:17:14	1.123
@@ -1391,6 +1391,51 @@
 	return _udev_notify_sem_create(cookie, &semid);
 }
 
+static const char *_task_type_disp(int type)
+{
+	switch(type) {
+	case DM_DEVICE_CREATE:
+		return "CREATE";
+        case DM_DEVICE_RELOAD:
+		return "RELOAD";
+        case DM_DEVICE_REMOVE:
+		return "REMOVE";
+        case DM_DEVICE_REMOVE_ALL:
+		return "REMOVE_ALL";
+        case DM_DEVICE_SUSPEND:
+		return "SUSPEND";
+        case DM_DEVICE_RESUME:
+		return "RESUME";
+        case DM_DEVICE_INFO:
+		return "INFO";
+        case DM_DEVICE_DEPS:
+		return "DEPS";
+        case DM_DEVICE_RENAME:
+		return "RENAME";
+        case DM_DEVICE_VERSION:
+		return "VERSION";
+        case DM_DEVICE_STATUS:
+		return "STATUS";
+        case DM_DEVICE_TABLE:
+		return "TABLE";
+        case DM_DEVICE_WAITEVENT:
+		return "WAITEVENT";
+        case DM_DEVICE_LIST:
+		return "LIST";
+        case DM_DEVICE_CLEAR:
+		return "CLEAR";
+        case DM_DEVICE_MKNODES:
+		return "MKNODES";
+        case DM_DEVICE_LIST_VERSIONS:
+		return "LIST_VERSIONS";
+        case DM_DEVICE_TARGET_MSG:
+		return "TARGET_MSG";
+        case DM_DEVICE_SET_GEOMETRY:
+		return "SET_GEOMETRY";
+	}
+	return "unknown";
+}
+
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	int semid;
@@ -1419,8 +1464,16 @@
 	dmt->event_nr |= ~DM_UDEV_FLAGS_MASK & *cookie;
 	dmt->cookie_set = 1;
 
-	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task "
-		  "type %d with flags 0x%" PRIx16, *cookie, semid, dmt->type, flags);
+	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to "
+		  "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, semid, _task_type_disp(dmt->type), dmt->type, 
+		  (flags & DM_UDEV_DISABLE_DM_RULES_FLAG) ? " DISABLE_DM_RULES" : "",
+		  (flags & DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) ? " DISABLE_SUBSYSTEM_RULES" : "",
+		  (flags & DM_UDEV_DISABLE_DISK_RULES_FLAG) ? " DISABLE_DISK_RULES" : "",
+		  (flags & DM_UDEV_DISABLE_OTHER_RULES_FLAG) ? " DISABLE_OTHER_RULES" : "",
+		  (flags & DM_UDEV_LOW_PRIORITY_FLAG) ? " LOW_PRIORITY" : "",
+		  (flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK) ? " DISABLE_LIBRARY_FALLBACK" : "",
+		  (flags & DM_UDEV_PRIMARY_SOURCE_FLAG) ? " PRIMARY_SOURCE" : "",
+		  flags);
 
 	return 1;
 


