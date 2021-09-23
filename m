From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Sep 2021 14:52:38 +0000 (GMT)
Subject: main - libdm: dmsetup measure support for IMA
Message-ID: <20210923145238.713663858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f853a1bc7afdebb44aeb8c1167e8784d155cad84
Commit:        f853a1bc7afdebb44aeb8c1167e8784d155cad84
Parent:        707e7d762e2668af308457fd6d8b8375e18b0207
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 13 02:06:04 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 23 16:49:28 2021 +0200

libdm: dmsetup measure support for IMA

Add support for DM_IMA_MEASUREMENT_FLAG with
DM_TABLE_STATUS_CMD.

This feature requires DM version 4.45  (5.15+ kernels)
---
 WHATS_NEW_DM                        |  1 +
 libdm/.exported_symbols.DM_1_02_181 |  1 +
 libdm/dm-tools/dmsetup.c            |  4 ++++
 libdm/ioctl/libdm-iface.c           | 19 ++++++++++++++++++-
 libdm/ioctl/libdm-targets.h         |  1 +
 libdm/libdevmapper.h                |  1 +
 libdm/libdm-common.c                |  1 +
 libdm/misc/dm-ioctl.h               | 12 +++++++++---
 man/dmsetup.8_main                  | 15 +++++++++++++++
 9 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 94d782c56..c7029e437 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.181 - 
 ===================================
+  Add IMA support with 'dmsetup measure' command.
   Add defines DM_NAME_LIST_FLAG_HAS_UUID, DM_NAME_LIST_FLAG_DOESNT_HAVE_UUID.
   Enhance tracking of activated devices when preloading dm tree.
   Fix bug in construction of cache table line (regression from 1.02.159).
diff --git a/libdm/.exported_symbols.DM_1_02_181 b/libdm/.exported_symbols.DM_1_02_181
new file mode 100644
index 000000000..4ab603b68
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_181
@@ -0,0 +1 @@
+dm_task_ima_measurement
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 0f260b3f4..4641c1f18 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -2446,6 +2446,9 @@ static int _status(CMD_ARGS)
 	if (_switches[NOFLUSH_ARG] && !dm_task_no_flush(dmt))
 		goto_out;
 
+	if (!dm_task_ima_measurement(dmt))
+		goto_out;
+
 	if (!_task_run(dmt))
 		goto_out;
 
@@ -6255,6 +6258,7 @@ static struct command _dmsetup_commands[] = {
 	{"reload", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
 	{"wipe_table", "[-f|--force] [--noflush] [--nolockfs] <device>...", 0, -1, 2, 0, _error_device},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, 0, _rename},
+	{"measure", "[<device>...]", 0, -1, 2, 0, _status},
 	{"message", "<device> <sector> <message>", 2, -1, 0, 0, _message},
 	{"ls", "[--target <target_type>] [--exec <command>] [-o <options>] [--tree]", 0, 0, 0, 0, _ls},
 	{"info", "[<device>...]", 0, -1, 1, 0, _info},
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index d8f1c389d..28589a15c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -929,6 +929,13 @@ int dm_task_secure_data(struct dm_task *dmt)
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
@@ -1288,6 +1295,14 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
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
@@ -1489,6 +1504,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->head = dmt->head;
 	task->tail = dmt->tail;
 	task->secure_data = dmt->secure_data;
+	task->ima_measurement = dmt->ima_measurement;
 
 	r = dm_task_run(task);
 
@@ -1877,7 +1893,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	}
 
 	log_debug_activation("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-			     "%s[ %s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
+			     "%s[ %s%s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
 			     _cmd_data_v4[dmt->type].name,
 			     dmt->new_uuid ? "UUID " : "",
 			     dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1895,6 +1911,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			     dmt->retry_remove ? "retryremove " : "",
 			     dmt->deferred_remove ? "deferredremove " : "",
 			     dmt->secure_data ? "securedata " : "",
+			     dmt->ima_measurement ? "ima_measurement " : "",
 			     dmt->query_inactive_table ? "inactive " : "",
 			     dmt->enable_checks ? "enablechecks " : "",
 			     dmt->sector, _sanitise_message(dmt->message),
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 294210d2b..022b02c72 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -69,6 +69,7 @@ struct dm_task {
 	int enable_checks;
 	int expected_errno;
 	int ioctl_errno;
+	int ima_measurement;
 
 	int record_timestamp;
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ac31b59da..e9412da7d 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -235,6 +235,7 @@ int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
 int dm_task_retry_remove(struct dm_task *dmt);
 int dm_task_deferred_remove(struct dm_task *dmt);
+int dm_task_ima_measurement(struct dm_task *dmt);
 
 /*
  * Record timestamp immediately after the ioctl returns.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 27be1d02f..734a0127e 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -336,6 +336,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->new_uuid = 0;
 	dmt->secure_data = 0;
 	dmt->record_timestamp = 0;
+	dmt->ima_measurement = 0;
 
 	return dmt;
 }
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index cecfd5909..cdb38f639 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2021 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -287,9 +287,9 @@ enum {
 #define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	36
+#define DM_VERSION_MINOR	45
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2017-06-09)"
+#define DM_VERSION_EXTRA	"-ioctl (2021-03-22)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -377,4 +377,10 @@ enum {
  */
 #define DM_INTERNAL_SUSPEND_FLAG	(1 << 18) /* Out */
 
+/*
+ * If set, returns in the in buffer passed by UM, the raw table information
+ * that would be measured by IMA subsystem on device state change.
+ */
+#define DM_IMA_MEASUREMENT_FLAG	(1 << 19) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 359b06ce3..7576b54bc 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -140,6 +140,14 @@ dmsetup \(em low level logical volume management
 .
 .HP
 .B dmsetup
+.de CMD_MEASURE
+.  BR measure
+.  RI [ device_name ...]
+..
+.CMD_MEASURE
+.
+.HP
+.B dmsetup
 .de CMD_MESSAGE
 .  BR message
 .  IR device_name
@@ -710,6 +718,13 @@ must be manually corrected by deactivating the device first and then
 reactivating it with proper mangling mode used (see also \fB--manglename\fP).
 .
 .HP
+.CMD_MEASURE
+.br
+Show the data that \fIdevice_name\fP would report to the IMA subsystem
+if a measurement was triggered@the current time.
+This is for debugging and does not actually trigger a measurement.
+.
+.HP
 .CMD_MESSAGE
 .br
 Send message to target. If sector not needed use 0.


