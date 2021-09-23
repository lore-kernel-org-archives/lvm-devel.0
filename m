From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Sep 2021 14:52:39 +0000 (GMT)
Subject: main - devicemapper: in sync with libdm
Message-ID: <20210923145239.914663858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1cb33b633c7d4c76e86bc71ceae043555366a4e
Commit:        a1cb33b633c7d4c76e86bc71ceae043555366a4e
Parent:        f853a1bc7afdebb44aeb8c1167e8784d155cad84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 22 17:30:42 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 23 16:49:58 2021 +0200

devicemapper: in sync with libdm

---
 device_mapper/all.h                 |  1 +
 device_mapper/ioctl/libdm-iface.c   | 19 ++++++++++++++++++-
 device_mapper/ioctl/libdm-targets.h |  1 +
 device_mapper/libdm-common.c        |  1 +
 device_mapper/misc/dm-ioctl.h       | 13 ++++++++++---
 5 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index 489ca1c69..17f78d989 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -234,6 +234,7 @@ int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
 int dm_task_retry_remove(struct dm_task *dmt);
 int dm_task_deferred_remove(struct dm_task *dmt);
+int dm_task_ima_measurement(struct dm_task *dmt);
 void dm_task_skip_reload_params_compare(struct dm_task *dmt);
 
 /*
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index b4f7a986d..533bb9eea 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -926,6 +926,13 @@ int dm_task_secure_data(struct dm_task *dmt)
 	return 1;
 }
 
+int dm_task_ima_measurement(struct dm_task *dmt)
+{
+	dmt->ima_measurement = 1;
+
+	return 1;
+}
+
 int dm_task_retry_remove(struct dm_task *dmt)
 {
 	dmt->retry_remove = 1;
@@ -1293,6 +1300,14 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		}
 		dmi->flags |= DM_UUID_FLAG;
 	}
+	if (dmt->ima_measurement) {
+		if (_dm_version_minor < 45) {
+			log_error("WARNING: IMA measurement unsupported by "
+				  "kernel.  Aborting operation.");
+			goto bad;
+		}
+		dmi->flags |= DM_IMA_MEASUREMENT_FLAG;
+	}
 
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
@@ -1488,6 +1503,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->head = dmt->head;
 	task->tail = dmt->tail;
 	task->secure_data = dmt->secure_data;
+	task->ima_measurement = dmt->ima_measurement;
 
 	r = dm_task_run(task);
 
@@ -1901,7 +1917,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	}
 
 	log_debug_activation("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-			     "%s[ %s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
+			     "%s[ %s%s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
 			     _cmd_data_v4[dmt->type].name,
 			     dmt->new_uuid ? "UUID " : "",
 			     dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1919,6 +1935,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			     dmt->retry_remove ? "retryremove " : "",
 			     dmt->deferred_remove ? "deferredremove " : "",
 			     dmt->secure_data ? "securedata " : "",
+			     dmt->ima_measurement ? "ima_measurement " : "",
 			     dmt->query_inactive_table ? "inactive " : "",
 			     dmt->enable_checks ? "enablechecks " : "",
 			     dmt->sector, _sanitise_message(dmt->message),
diff --git a/device_mapper/ioctl/libdm-targets.h b/device_mapper/ioctl/libdm-targets.h
index 9786a7eda..c853e22aa 100644
--- a/device_mapper/ioctl/libdm-targets.h
+++ b/device_mapper/ioctl/libdm-targets.h
@@ -70,6 +70,7 @@ struct dm_task {
 	int enable_checks;
 	int expected_errno;
 	int ioctl_errno;
+	int ima_measurement;
 
 	int record_timestamp;
 
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index a90ece78a..2a03aff10 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -338,6 +338,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->new_uuid = 0;
 	dmt->secure_data = 0;
 	dmt->record_timestamp = 0;
+	dmt->ima_measurement = 0;
 
 	return dmt;
 }
diff --git a/device_mapper/misc/dm-ioctl.h b/device_mapper/misc/dm-ioctl.h
index c00fa5b4f..f727e0f70 100644
--- a/device_mapper/misc/dm-ioctl.h
+++ b/device_mapper/misc/dm-ioctl.h
@@ -1,6 +1,7 @@
+/* SPDX-License-Identifier: LGPL-2.0+ WITH Linux-syscall-note */
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2021 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -288,9 +289,9 @@ enum {
 #define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	36
+#define DM_VERSION_MINOR	45
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2017-06-09)"
+#define DM_VERSION_EXTRA	"-ioctl (2021-03-22)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -378,4 +379,10 @@ enum {
  */
 #define DM_INTERNAL_SUSPEND_FLAG	(1 << 18) /* Out */
 
+/*
+ * If set, returns in the in buffer passed by UM, the raw table information
+ * that would be measured by IMA subsystem on device state change.
+ */
+#define DM_IMA_MEASUREMENT_FLAG	(1 << 19) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */


