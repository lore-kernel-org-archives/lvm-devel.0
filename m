From: Milan Broz <gmazyland@gmail.com>
Date: Tue,  6 Sep 2022 15:27:11 +0200
Subject: [PATCH] Support new DM_RETURN_ERROR_FLAG in libdevmapper.
Message-ID: <20220906132711.74114-1-gmazyland@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds support for new flag defined here:
https://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm.git/commit/?h=dm-6.1&id=0abd2cd1e80ec866107fb496c139034dbb2a60a4

As the patch overloads the name field in ioctl structure,
all parsing must bu skipped.

Also libdevmapps generates more ioctl on error path, so
error string must be preserved from the actuall failing call.

I am not sure that I understand all the magic here, but
at least basic testing works and I get error string.

Signed-off-by: Milan Broz <gmazyland@gmail.com>
---
 libdm/.exported_symbols.DM_1_02_187 |  2 ++
 libdm/ioctl/libdm-iface.c           | 33 +++++++++++++++++++++++++----
 libdm/ioctl/libdm-targets.h         |  2 ++
 libdm/libdevmapper.h                |  3 +++
 libdm/libdm-common.c                |  9 ++++++++
 libdm/misc/dm-ioctl.h               | 15 ++++++++++---
 6 files changed, 57 insertions(+), 7 deletions(-)
 create mode 100644 libdm/.exported_symbols.DM_1_02_187

diff --git a/libdm/.exported_symbols.DM_1_02_187 b/libdm/.exported_symbols.DM_1_02_187
new file mode 100644
index 000000000..5fb30ae6e
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_187
@@ -0,0 +1,2 @@
+dm_task_return_error
+dm_task_get_error
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 0fba79ce4..06d01cebf 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -959,6 +959,13 @@ int dm_task_ima_measurement(struct dm_task *dmt)
 	return 1;
 }
 
+int dm_task_return_error(struct dm_task *dmt)
+{
+	dmt->return_error = 1;
+
+	return 1;
+}
+
 int dm_task_retry_remove(struct dm_task *dmt)
 {
 	dmt->retry_remove = 1;
@@ -1326,6 +1333,14 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		}
 		dmi->flags |= DM_IMA_MEASUREMENT_FLAG;
 	}
+	if (dmt->return_error) {
+		if (_dm_version_minor < 48) {
+			log_error("WARNING: Return error flag unsupported by "
+				  "kernel.  Aborting operation.");
+			goto bad;
+		}
+		dmi->flags |= DM_RETURN_ERROR_FLAG;
+	}
 
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
@@ -1527,8 +1542,11 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->tail = dmt->tail;
 	task->secure_data = dmt->secure_data;
 	task->ima_measurement = dmt->ima_measurement;
+	task->return_error = dmt->return_error;
 
 	r = dm_task_run(task);
+	if (!r && task->return_error)
+		strncpy(dmt->dm_error, task->dm_error, sizeof(dmt->dm_error));
 
 	task->head = NULL;
 	task->tail = NULL;
@@ -1815,7 +1833,7 @@ static int _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
 	char *uuid_ptr;
 	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
 
-	if ((name = dmi->name))
+	if ((name = dmi->name) && !dmi->error)
 		r &= _do_dm_ioctl_unmangle_string(name, "name", buf, sizeof(buf),
 						  mangling_mode);
 
@@ -1926,7 +1944,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	}
 
 	log_debug_activation("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-			     "%s[ %s%s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
+			     "%s[ %s%s%s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
 			     _cmd_data_v4[dmt->type].name,
 			     dmt->new_uuid ? "UUID " : "",
 			     dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1945,6 +1963,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			     dmt->deferred_remove ? "deferredremove " : "",
 			     dmt->secure_data ? "securedata " : "",
 			     dmt->ima_measurement ? "ima_measurement " : "",
+			     dmt->return_error ? "return_error " : "",
 			     dmt->query_inactive_table ? "inactive " : "",
 			     dmt->enable_checks ? "enablechecks " : "",
 			     dmt->sector, _sanitise_message(dmt->message),
@@ -1952,6 +1971,12 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 #ifdef DM_IOCTLS
 	r = ioctl(_control_fd, command, dmi);
 
+	if (!r && dmt->return_error && dmi->error) {
+		if (!*dmt->dm_error)
+			strncpy(dmt->dm_error, dmi->name, sizeof(dmt->dm_error));
+		r = dmi->error;
+	}
+
 	if (dmt->record_timestamp)
 		if (!dm_timestamp_get(_dm_ioctl_timestamp))
 			stack;
@@ -1967,7 +1992,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				log_verbose("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
 					    "failed: %s",
 					    _cmd_data_v4[dmt->type].name,
-					    dmi->name[0] ? dmi->name : DEV_NAME(dmt) ? : "",
+					    !dmt->return_error && dmi->name[0] ? dmi->name : DEV_NAME(dmt) ? : "",
 					    dmi->uuid[0] ? dmi->uuid : DEV_UUID(dmt) ? : "",
 					    dmt->major > 0 ? "(" : "",
 					    dmt->major > 0 ? dmt->major : 0,
@@ -1980,7 +2005,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				log_error("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
-					  dmi->name[0] ? dmi->name : DEV_NAME(dmt) ? : "",
+					  !dmt->return_error && dmi->name[0] ? dmi->name : DEV_NAME(dmt) ? : "",
 					  dmi->uuid[0] ? dmi->uuid : DEV_UUID(dmt) ? : "",
 					  dmt->major > 0 ? "(" : "",
 					  dmt->major > 0 ? dmt->major : 0,
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 022b02c72..914a1bab3 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -70,6 +70,8 @@ struct dm_task {
 	int expected_errno;
 	int ioctl_errno;
 	int ima_measurement;
+	int return_error;
+	char dm_error[130]; /* At least DM_NAME_LEN */
 
 	int record_timestamp;
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c1c6cb40e..d69567d36 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -199,6 +199,8 @@ const char *dm_task_get_uuid(const struct dm_task *dmt);
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt);
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt);
 const char *dm_task_get_message_response(struct dm_task *dmt);
+const char *dm_task_get_error(const struct dm_task *dmt);
+
 
 /*
  * These functions return device-mapper names based on the value
@@ -236,6 +238,7 @@ int dm_task_secure_data(struct dm_task *dmt);
 int dm_task_retry_remove(struct dm_task *dmt);
 int dm_task_deferred_remove(struct dm_task *dmt);
 int dm_task_ima_measurement(struct dm_task *dmt);
+int dm_task_return_error(struct dm_task *dmt);
 
 /*
  * Record timestamp immediately after the ioctl returns.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 734a0127e..308d7599d 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -337,6 +337,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->secure_data = 0;
 	dmt->record_timestamp = 0;
 	dmt->ima_measurement = 0;
+	dmt->return_error = 0;
 
 	return dmt;
 }
@@ -745,6 +746,14 @@ const char *dm_task_get_uuid(const struct dm_task *dmt)
 	return (dmt->dmi.v4->uuid);
 }
 
+const char *dm_task_get_error(const struct dm_task *dmt)
+{
+	if (dmt->return_error)
+		return dmt->dm_error;
+
+	return NULL;
+}
+
 char *dm_task_get_uuid_mangled(const struct dm_task *dmt)
 {
 	const char *s = dm_task_get_uuid(dmt);
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index cdb38f639..c8ceb0c0e 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -137,7 +137,8 @@ struct dm_ioctl {
 	 * For output, the ioctls return the event number, not the cookie.
 	 */
 	uint32_t event_nr;      	/* in/out */
-	uint32_t padding;
+
+	uint32_t error;		/* out */
 
 	uint64_t dev;		/* in/out */
 
@@ -287,9 +288,9 @@ enum {
 #define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	45
+#define DM_VERSION_MINOR	48
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2021-03-22)"
+#define DM_VERSION_EXTRA	"-ioctl (2022-08-24)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -383,4 +384,12 @@ enum {
  */
 #define DM_IMA_MEASUREMENT_FLAG	(1 << 19) /* In */
 
+/*
+ * If this flag is set, the caller wants to receive the error string.
+ * The error string is returned in the "name" field of the ioctl and
+ * the error number is returned in the "error" field. The ioctl returns
+ * zero.
+ */
+#define DM_RETURN_ERROR_FLAG	(1 << 20) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */
-- 
2.37.2

