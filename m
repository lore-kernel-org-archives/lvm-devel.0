From: Sergei Shtepa <sergei.shtepa@veeam.com>
Date: Thu, 28 Jan 2021 20:15:18 +0300
Subject: [PATCH 1/1] add dm remap functionality.
In-Reply-To: <1611854118-32204-1-git-send-email-sergei.shtepa@veeam.com>
References: <1611854118-32204-1-git-send-email-sergei.shtepa@veeam.com>
Message-ID: <1611854118-32204-2-git-send-email-sergei.shtepa@veeam.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dm remap allow to use blk_interposer.
Now we can use the "dmsetup remap" command to insert
any dm device into the block layer stack.

changes:
  * add DM_DEV_REMAP ioctl.
  * added bin_data field in struct dm_task. This can become
    a more universal abstraction instead of the newname,
    message and geometry fields.
Signed-off-by: Sergei Shtepa <sergei.shtepa@veeam.com>
---
 device_mapper/all.h                 |  6 +-
 device_mapper/ioctl/libdm-iface.c   | 99 ++++++++++++++++++++++++-----
 device_mapper/ioctl/libdm-targets.h |  2 +
 device_mapper/libdm-common.c        | 10 +--
 device_mapper/misc/dm-ioctl.h       | 16 ++++-
 libdm/.exported_symbols.Base        |  2 +
 libdm/dm-tools/dmsetup.c            | 63 ++++++++++++++++--
 libdm/ioctl/libdm-iface.c           | 91 +++++++++++++++++++++-----
 libdm/ioctl/libdm-targets.h         |  2 +
 libdm/libdevmapper.h                | 12 ++--
 libdm/libdm-common.c                | 10 +--
 libdm/misc/dm-ioctl.h               | 16 ++++-
 12 files changed, 276 insertions(+), 53 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index 1080d25ad..c248c6470 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -123,7 +123,9 @@ enum {
 
 	DM_DEVICE_ARM_POLL,
 
-	DM_DEVICE_GET_TARGET_VERSION
+	DM_DEVICE_GET_TARGET_VERSION,
+
+	DM_DEVICE_REMAP
 };
 
 /*
@@ -226,6 +228,8 @@ int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
 int dm_task_set_message(struct dm_task *dmt, const char *message);
 int dm_task_set_sector(struct dm_task *dmt, uint64_t sector);
+int dm_task_set_remap_start(struct dm_task *dmt, const char *donor_device);
+int dm_task_set_remap_finish(struct dm_task *dmt);
 int dm_task_no_flush(struct dm_task *dmt);
 int dm_task_no_open_count(struct dm_task *dmt);
 int dm_task_skip_lockfs(struct dm_task *dmt);
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 8e7240673..cfe18705e 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -37,8 +37,8 @@
 #endif
 
 /*
- * Ensure build compatibility.  
- * The hard-coded versions here are the highest present 
+ * Ensure build compatibility.
+ * The hard-coded versions here are the highest present
  * in the _cmd_data arrays.
  */
 
@@ -122,6 +122,9 @@ static struct cmd_data _cmd_data_v4[] = {
 #ifdef DM_GET_TARGET_VERSION
 	{"target-version", DM_GET_TARGET_VERSION, {4, 41, 0}},
 #endif
+#ifdef DM_DEV_REMAP
+	{"remap", DM_DEV_REMAP,	 {4, 44, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
@@ -451,7 +454,7 @@ static int _open_control(void)
 	 */
 	if (!_open_and_assign_control_fd(control))
 		goto_bad;
-	
+
 	if (!_create_dm_bitset(1)) {
 		log_error("Failed to set up list of device-mapper major numbers");
 		return 0;
@@ -510,6 +513,7 @@ void dm_task_destroy(struct dm_task *dmt)
 	free(dmt->newname);
 	free(dmt->message);
 	free(dmt->geometry);
+	free(dmt->bin_data);
 	free(dmt->uuid);
 	free(dmt->mangled_uuid);
 	free(dmt);
@@ -567,7 +571,7 @@ static int _check_version(char *version, size_t size, int log_suppress)
 }
 
 /*
- * Find out device-mapper's major version number the first time 
+ * Find out device-mapper's major version number the first time
  * this is called and whether or not we support it.
  */
 int dm_check_version(void)
@@ -879,6 +883,59 @@ int dm_task_set_sector(struct dm_task *dmt, uint64_t sector)
 	return 1;
 }
 
+int dm_task_set_remap_start(struct dm_task *dmt, const char *donor_device)
+{
+	size_t len;
+	uint32_t param_sz;
+	struct dm_remap_param *param;
+
+	len = strlen(donor_device);
+	if (!len) {
+		log_error("Invalid donor device name");
+		return 0;
+	}
+
+	param_sz = sizeof(struct dm_remap_param) + len + 1;
+	param = malloc(param_sz);
+	if (!param) {
+		log_error("Insufficient memory");
+		return 0;
+	}
+
+	param->cmd = REMAP_START_CMD;
+	if (!strcpy((char*)(param->params), donor_device)) {
+		log_error("Failed to copy donor device name");
+
+		free(param);
+		return 0;
+	}
+
+	dmt->bin_data = (uint8_t *)param;
+	dmt->bin_data_sz = param_sz;
+
+	return 1;
+}
+
+int dm_task_set_remap_finish(struct dm_task *dmt)
+{
+	uint32_t param_sz;
+	struct dm_remap_param *param;
+
+	param_sz = sizeof(struct dm_remap_param);
+	param = malloc(param_sz);
+	if (!param) {
+		log_error("Insufficient memory");
+		return 0;
+	}
+
+	param->cmd = REMAP_FINISH_CMD;
+
+	dmt->bin_data = (uint8_t *)param;
+	dmt->bin_data_sz = param_sz;
+
+	return 1;
+}
+
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads,
 			 const char *sectors, const char *start)
 {
@@ -1066,19 +1123,19 @@ static int _lookup_dev_name(uint64_t dev, char *buf, size_t len)
 	unsigned next = 0;
 	struct dm_task *dmt;
 	int r = 0;
- 
+
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
 		return 0;
- 
+
 	if (!dm_task_run(dmt))
 		goto out;
 
 	if (!(names = dm_task_get_names(dmt)))
 		goto out;
- 
+
 	if (!names->dev)
 		goto out;
- 
+
 	do {
 		names = (struct dm_names *)((char *) names + next);
 		if (names->dev == dev) {
@@ -1167,6 +1224,11 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		return NULL;
 	}
 
+	if (dmt->bin_data && (dmt->geometry || dmt->message || dmt->newname)) {
+		log_error("binary data parameter are incompatible with geometry, message or newname");
+		return NULL;
+	}
+
 	if (dmt->newname)
 		len += strlen(dmt->newname) + 1;
 
@@ -1176,6 +1238,8 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	if (dmt->geometry)
 		len += strlen(dmt->geometry) + 1;
 
+	if (dmt->bin_data)
+		len += dmt->bin_data_sz;
 	/*
 	 * Give len a minimum size so that we have space to store
 	 * dependencies or status information.
@@ -1288,15 +1352,20 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	if (dmt->newname)
 		strcpy(b, dmt->newname);
 
-	if (dmt->message) {
+	else if (dmt->message) {
 		tmsg = (struct dm_target_msg *) b;
 		tmsg->sector = dmt->sector;
 		strcpy(tmsg->message, dmt->message);
-	}
 
-	if (dmt->geometry)
+	} else if (dmt->geometry)
 		strcpy(b, dmt->geometry);
 
+	else if (dmt->bin_data) {
+		uint8_t *data = (uint8_t *)(dmi) + dmi->data_start;
+
+		memcpy(data, dmt->bin_data, dmt->bin_data_sz);
+	}
+
 	return dmi;
 
       bad:
@@ -1606,7 +1675,7 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 		t1 = t1->next;
 		t2 = t2->next;
 	}
-	
+
 	if (!t1 && !t2) {
 		dmt->dmi.v4 = task->dmi.v4;
 		task->dmi.v4 = NULL;
@@ -1658,7 +1727,7 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 	task->event_nr = dmt->event_nr & DM_UDEV_FLAGS_MASK;
 	task->cookie_set = dmt->cookie_set;
 	task->add_node = dmt->add_node;
-	
+
 	if (!(r = dm_task_run(task)))
 		goto out;
 
@@ -1675,7 +1744,7 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 					     "(%u:%u)", info.major, info.minor);
 		else
 			log_error(INTERNAL_ERROR "Attempt to suspend device %s%s%s%.0d%s%.0d%s%s"
-				  "that uses already-suspended device (%u:%u)", 
+				  "that uses already-suspended device (%u:%u)",
 				  DEV_NAME(dmt) ? : "", DEV_UUID(dmt) ? : "",
 				  dmt->major > 0 ? "(" : "",
 				  dmt->major > 0 ? dmt->major : 0,
@@ -2117,7 +2186,7 @@ repeat_ioctl:
 					MAJOR(dmi->dev), MINOR(dmi->dev),
 					dmt->read_ahead, dmt->read_ahead_flags);
 		break;
-	
+
 	case DM_DEVICE_MKNODES:
 		if (dmi->flags & DM_EXISTS_FLAG)
 			add_dev_node(dmi->name, MAJOR(dmi->dev),
diff --git a/device_mapper/ioctl/libdm-targets.h b/device_mapper/ioctl/libdm-targets.h
index 9786a7eda..a4feae23d 100644
--- a/device_mapper/ioctl/libdm-targets.h
+++ b/device_mapper/ioctl/libdm-targets.h
@@ -50,6 +50,8 @@ struct dm_task {
 	union {
 		struct dm_ioctl *v4;
 	} dmi;
+	uint8_t *bin_data;
+	uint32_t bin_data_sz;
 	char *newname;
 	char *message;
 	char *geometry;
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index 9b87e4e74..a47e16e77 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -619,7 +619,7 @@ static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
 		/*
 		 * Found directly.
 		 * If supplied path points to same device as last component
-		 * under /dev/mapper, use that name directly.  
+		 * under /dev/mapper, use that name directly.
 		 */
 		if (dm_snprintf(buf, sizeof(buf), "%s/%s", _dm_dir, name) == -1) {
 			log_error("Couldn't create path for %s", name);
@@ -1371,7 +1371,7 @@ static int _set_dev_node_read_ahead(const char *dev_name,
 
 		if (current_read_ahead >= read_ahead) {
 			log_debug_activation("%s: retaining kernel read ahead of %" PRIu32
-				  " (requested %" PRIu32 ")",           
+				  " (requested %" PRIu32 ")",
 				  dev_name, current_read_ahead, read_ahead);
 			return 1;
 		}
@@ -2438,7 +2438,7 @@ static int _udev_notify_sem_inc(uint32_t cookie, int semid)
 		log_error("semid %d: sem_ctl GETVAL failed for "
 			  "cookie 0x%" PRIx32 ": %s",
 			  semid, cookie, strerror(errno));
-		return 0;		
+		return 0;
 	}
 
 	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
@@ -2642,6 +2642,8 @@ static const char *_task_type_disp(int type)
 		return "TARGET_MSG";
         case DM_DEVICE_SET_GEOMETRY:
 		return "SET_GEOMETRY";
+	case DM_DEVICE_REMAP:
+		return "REMAP";
 	}
 	return "unknown";
 }
@@ -2744,7 +2746,7 @@ static int _udev_wait(uint32_t cookie, int *nowait)
 			log_error("semid %d: sem_ctl GETVAL failed for "
 				  "cookie 0x%" PRIx32 ": %s",
 				  semid, cookie, strerror(errno));
-			return 0;		
+			return 0;
 		}
 
 		if (val > 1)
diff --git a/device_mapper/misc/dm-ioctl.h b/device_mapper/misc/dm-ioctl.h
index 49954a764..f18564c7a 100644
--- a/device_mapper/misc/dm-ioctl.h
+++ b/device_mapper/misc/dm-ioctl.h
@@ -215,6 +215,16 @@ struct dm_target_msg {
 	char message[];
 };
 
+enum {
+	REMAP_START_CMD = 1,
+	REMAP_FINISH_CMD,
+};
+
+struct dm_remap_param {
+	uint8_t cmd;
+	uint8_t params[0];
+};
+
 /*
  * If you change this make sure you make the corresponding change
  * to dm-ioctl.c:lookup_ioctl()
@@ -245,6 +255,7 @@ enum {
 	DM_DEV_SET_GEOMETRY_CMD,
 	DM_DEV_ARM_POLL_CMD,
 	DM_GET_TARGET_VERSION_CMD,
+	DM_DEV_REMAP_CMD
 };
 
 #define DM_IOCTL 0xfd
@@ -260,6 +271,7 @@ enum {
 #define DM_DEV_STATUS    _IOWR(DM_IOCTL, DM_DEV_STATUS_CMD, struct dm_ioctl)
 #define DM_DEV_WAIT      _IOWR(DM_IOCTL, DM_DEV_WAIT_CMD, struct dm_ioctl)
 #define DM_DEV_ARM_POLL  _IOWR(DM_IOCTL, DM_DEV_ARM_POLL_CMD, struct dm_ioctl)
+#define DM_DEV_REMAP     _IOWR(DM_IOCTL, DM_DEV_REMAP_CMD, struct dm_ioctl)
 
 #define DM_TABLE_LOAD    _IOWR(DM_IOCTL, DM_TABLE_LOAD_CMD, struct dm_ioctl)
 #define DM_TABLE_CLEAR   _IOWR(DM_IOCTL, DM_TABLE_CLEAR_CMD, struct dm_ioctl)
@@ -274,9 +286,9 @@ enum {
 #define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	36
+#define DM_VERSION_MINOR	44
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2017-06-09)"
+#define DM_VERSION_EXTRA	"-ioctl (2020-12-25)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 4dc5c936c..333e926eb 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -214,6 +214,8 @@ dm_task_set_name
 dm_task_set_newname
 dm_task_set_newuuid
 dm_task_set_read_ahead
+dm_task_set_remap_start
+dm_task_set_remap_finish
 dm_task_set_ro
 dm_task_set_sector
 dm_task_set_uid
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 46fa81069..c027daef6 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -889,7 +889,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 
 	if (!(_report_type & (DR_STATS | DR_STATS_META))) {
 		/*
-		 * If _selection_cmd is set we are applying -S to some other command, so suppress 
+		 * If _selection_cmd is set we are applying -S to some other command, so suppress
 		 * output and run that other command if the device matches the criteria.
 		 */
 		if (!dm_report_object_is_selected(_report, &obj, _selection_cmd ? 0 : 1, &selected))
@@ -1297,7 +1297,7 @@ static int _create_concise(const struct command *cmd, int argc, char **argv)
 			*n++ = *c++;
 
 			continue;
-		} 
+		}
 
 		/* Comma marking end of field? */
 		if (*c == ',' && f < 4) {
@@ -1312,7 +1312,7 @@ static int _create_concise(const struct command *cmd, int argc, char **argv)
 				c++;
 
 			continue;
-		} 
+		}
 
 		/* Comma marking end of a table line? */
 		if (*c == ',' && f >= 4) {
@@ -1320,7 +1320,7 @@ static int _create_concise(const struct command *cmd, int argc, char **argv)
 			*n++ = '\n', c++;
 
 			continue;
-		} 
+		}
 
 		/* Semi-colon marking end of device? */
 		if (*c == ';' || *(c + 1) == '\0') {
@@ -1381,7 +1381,7 @@ static int _create_concise(const struct command *cmd, int argc, char **argv)
 				c++;
 
 			continue;
-		} 
+		}
 
 		/* Normal character */
 		*n++ = *c++;
@@ -1634,6 +1634,56 @@ static int _splitname(CMD_ARGS)
 	return r;
 }
 
+static int _remap(CMD_ARGS)
+{
+	int r = 0;
+	struct dm_task *dmt;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_REMAP)))
+		return_0;
+
+	if (argc < 1) {
+		log_error("Please provide remap command 'start' or 'finish'.");
+		goto out;
+	}
+	if (strcmp(argv[0], "start") == 0) {
+		if (argc < 3) {
+			log_error("Please provide a name for the acceptor dm device and donor device.");
+			goto out;
+		}
+
+		if (!_set_task_device(dmt, argv[1], 0))
+			goto_out;
+
+		if (!dm_task_set_remap_start(dmt, argv[2]))
+			goto_out;
+
+	} else if (strcmp(argv[0], "finish") == 0) {
+		if (argc < 2) {
+			log_error("Please provide a name for the acceptor dm device.");
+			goto out;
+		}
+
+		if (!_set_task_device(dmt, argv[1], 0))
+			goto_out;
+
+		if (!dm_task_set_remap_finish(dmt))
+			goto_out;
+	} else {
+		log_error("Invalid remap command. Supported only 'start' or 'finish'.");
+		goto out;
+	}
+
+	/* run the task */
+	if (!_task_run(dmt))
+		goto_out;
+
+	r = 1; /* success */
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
 static uint32_t _get_cookie_value(const char *str_value)
 {
 	unsigned long int value;
@@ -2196,7 +2246,7 @@ static int _error_device(CMD_ARGS)
 		log_error("No device specified.");
 		return 0;
 	}
-		
+
 	size = _get_device_size(name);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD)))
@@ -6275,6 +6325,7 @@ static struct command _dmsetup_commands[] = {
 	{"version", "", 0, 0, 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, 0, _setgeometry},
 	{"splitname", "<device> [<subsystem>]", 1, 2, 0, 0, _splitname},
+	{"remap", "<start | finish> <acceptor dm device> [<donor device>]", 2, 3, 0, 0, _remap},
 	{NULL, NULL, 0, 0, 0, 0, NULL}
 };
 
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index f4be478da..e7c618657 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -36,8 +36,8 @@
 #include "libdm/misc/dm-ioctl.h"
 
 /*
- * Ensure build compatibility.  
- * The hard-coded versions here are the highest present 
+ * Ensure build compatibility.
+ * The hard-coded versions here are the highest present
  * in the _cmd_data arrays.
  */
 
@@ -121,6 +121,9 @@ static struct cmd_data _cmd_data_v4[] = {
 #ifdef DM_GET_TARGET_VERSION
 	{"target-version", DM_GET_TARGET_VERSION, {4, 41, 0}},
 #endif
+#ifdef DM_DEV_REMAP
+	{"remap", DM_DEV_REMAP,	 {4, 44, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
@@ -450,7 +453,7 @@ static int _open_control(void)
 	 */
 	if (!_open_and_assign_control_fd(control))
 		goto_bad;
-	
+
 	if (!_create_dm_bitset(1)) {
 		log_error("Failed to set up list of device-mapper major numbers");
 		return 0;
@@ -566,7 +569,7 @@ static int _check_version(char *version, size_t size, int log_suppress)
 }
 
 /*
- * Find out device-mapper's major version number the first time 
+ * Find out device-mapper's major version number the first time
  * this is called and whether or not we support it.
  */
 int dm_check_version(void)
@@ -887,6 +890,59 @@ int dm_task_set_sector(struct dm_task *dmt, uint64_t sector)
 	return 1;
 }
 
+int dm_task_set_remap_start(struct dm_task *dmt, const char *donor_device)
+{
+	size_t len;
+	uint32_t param_sz;
+	struct dm_remap_param *param;
+
+	len = strlen(donor_device);
+	if (!len) {
+		log_error("Invalid donor device name");
+		return 0;
+	}
+
+	param_sz = sizeof(struct dm_remap_param) + len + 1;
+	param = malloc(param_sz);
+	if (!param) {
+		log_error("Insufficient memory");
+		return 0;
+	}
+
+	param->cmd = REMAP_START_CMD;
+	if (!strcpy((char*)(param->params), donor_device)) {
+		log_error("Failed to copy donor device name");
+
+		free(param);
+		return 0;
+	}
+
+	dmt->bin_data = (uint8_t *)param;
+	dmt->bin_data_sz = param_sz;
+
+	return 1;
+}
+
+int dm_task_set_remap_finish(struct dm_task *dmt)
+{
+	uint32_t param_sz;
+	struct dm_remap_param *param;
+
+	param_sz = sizeof(struct dm_remap_param);
+	param = malloc(param_sz);
+	if (!param) {
+		log_error("Insufficient memory");
+		return 0;
+	}
+
+	param->cmd = REMAP_FINISH_CMD;
+
+	dmt->bin_data = (uint8_t *)param;
+	dmt->bin_data_sz = param_sz;
+
+	return 1;
+}
+
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads,
 			 const char *sectors, const char *start)
 {
@@ -1074,19 +1130,19 @@ static int _lookup_dev_name(uint64_t dev, char *buf, size_t len)
 	unsigned next = 0;
 	struct dm_task *dmt;
 	int r = 0;
- 
+
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
 		return 0;
- 
+
 	if (!dm_task_run(dmt))
 		goto out;
 
 	if (!(names = dm_task_get_names(dmt)))
 		goto out;
- 
+
 	if (!names->dev)
 		goto out;
- 
+
 	do {
 		names = (struct dm_names *)((char *) names + next);
 		if (names->dev == dev) {
@@ -1300,15 +1356,20 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	if (dmt->newname)
 		strcpy(b, dmt->newname);
 
-	if (dmt->message) {
+	else if (dmt->message) {
 		tmsg = (struct dm_target_msg *) b;
 		tmsg->sector = dmt->sector;
 		strcpy(tmsg->message, dmt->message);
-	}
 
-	if (dmt->geometry)
+	} else if (dmt->geometry)
 		strcpy(b, dmt->geometry);
 
+	else if (dmt->bin_data) {
+		uint8_t *data = (uint8_t *)(dmi) + dmi->data_start;
+
+		memcpy(data, dmt->bin_data, dmt->bin_data_sz);
+	}
+
 	return dmi;
 
       bad:
@@ -1606,7 +1667,7 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 		t1 = t1->next;
 		t2 = t2->next;
 	}
-	
+
 	if (!t1 && !t2) {
 		dmt->dmi.v4 = task->dmi.v4;
 		task->dmi.v4 = NULL;
@@ -1658,7 +1719,7 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 	task->event_nr = dmt->event_nr & DM_UDEV_FLAGS_MASK;
 	task->cookie_set = dmt->cookie_set;
 	task->add_node = dmt->add_node;
-	
+
 	if (!(r = dm_task_run(task)))
 		goto out;
 
@@ -1675,7 +1736,7 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 					     "(%u:%u)", info.major, info.minor);
 		else
 			log_error(INTERNAL_ERROR "Attempt to suspend device %s%s%s%.0d%s%.0d%s%s"
-				  "that uses already-suspended device (%u:%u)", 
+				  "that uses already-suspended device (%u:%u)",
 				  DEV_NAME(dmt) ? : "", DEV_UUID(dmt) ? : "",
 				  dmt->major > 0 ? "(" : "",
 				  dmt->major > 0 ? dmt->major : 0,
@@ -2119,7 +2180,7 @@ repeat_ioctl:
 					MAJOR(dmi->dev), MINOR(dmi->dev),
 					dmt->read_ahead, dmt->read_ahead_flags);
 		break;
-	
+
 	case DM_DEVICE_MKNODES:
 		if (dmi->flags & DM_EXISTS_FLAG)
 			add_dev_node(dmi->name, MAJOR(dmi->dev),
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index b5b20d5e9..16b9d87db 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -50,6 +50,8 @@ struct dm_task {
 	union {
 		struct dm_ioctl *v4;
 	} dmi;
+	uint8_t *bin_data;
+	uint32_t bin_data_sz;
 	char *newname;
 	char *message;
 	char *geometry;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a61ffe17e..a2064debc 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -117,14 +117,16 @@ enum {
 	DM_DEVICE_MKNODES,
 
 	DM_DEVICE_LIST_VERSIONS,
-	
+
 	DM_DEVICE_TARGET_MSG,
 
 	DM_DEVICE_SET_GEOMETRY,
 
 	DM_DEVICE_ARM_POLL,
 
-	DM_DEVICE_GET_TARGET_VERSION
+	DM_DEVICE_GET_TARGET_VERSION,
+
+	DM_DEVICE_REMAP
 };
 
 /*
@@ -227,6 +229,8 @@ int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
 int dm_task_set_message(struct dm_task *dmt, const char *message);
 int dm_task_set_sector(struct dm_task *dmt, uint64_t sector);
+int dm_task_set_remap_start(struct dm_task *dmt, const char *donor_device);
+int dm_task_set_remap_finish(struct dm_task *dmt);
 int dm_task_no_flush(struct dm_task *dmt);
 int dm_task_no_open_count(struct dm_task *dmt);
 int dm_task_skip_lockfs(struct dm_task *dmt);
@@ -544,7 +548,7 @@ int dm_message_supports_precise_timestamps(void);
 
 /*
  * Precise timetamps and histogram support.
- * 
+ *
  * Test for the presence of precise_timestamps and histogram support.
  */
 int dm_stats_driver_supports_precise(void);
@@ -3744,7 +3748,7 @@ int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 
 /*
- * dm_dev_wait_immediate 
+ * dm_dev_wait_immediate
  * If *ready is 1 on return, the wait is complete.
  * If *ready is 0 on return, the wait is incomplete and either
  * this function or dm_udev_wait() must be called again.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index a28829765..c2390cf90 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -617,7 +617,7 @@ static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
 		/*
 		 * Found directly.
 		 * If supplied path points to same device as last component
-		 * under /dev/mapper, use that name directly.  
+		 * under /dev/mapper, use that name directly.
 		 */
 		if (dm_snprintf(buf, sizeof(buf), "%s/%s", _dm_dir, name) == -1) {
 			log_error("Couldn't create path for %s", name);
@@ -1369,7 +1369,7 @@ static int _set_dev_node_read_ahead(const char *dev_name,
 
 		if (current_read_ahead >= read_ahead) {
 			log_debug_activation("%s: retaining kernel read ahead of %" PRIu32
-				  " (requested %" PRIu32 ")",           
+				  " (requested %" PRIu32 ")",
 				  dev_name, current_read_ahead, read_ahead);
 			return 1;
 		}
@@ -2437,7 +2437,7 @@ static int _udev_notify_sem_inc(uint32_t cookie, int semid)
 		log_error("semid %d: sem_ctl GETVAL failed for "
 			  "cookie 0x%" PRIx32 ": %s",
 			  semid, cookie, strerror(errno));
-		return 0;		
+		return 0;
 	}
 
 	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",
@@ -2641,6 +2641,8 @@ static const char *_task_type_disp(int type)
 		return "TARGET_MSG";
         case DM_DEVICE_SET_GEOMETRY:
 		return "SET_GEOMETRY";
+	case DM_DEVICE_REMAP:
+		return "REMAP";
 	}
 	return "unknown";
 }
@@ -2743,7 +2745,7 @@ static int _udev_wait(uint32_t cookie, int *nowait)
 			log_error("semid %d: sem_ctl GETVAL failed for "
 				  "cookie 0x%" PRIx32 ": %s",
 				  semid, cookie, strerror(errno));
-			return 0;		
+			return 0;
 		}
 
 		if (val > 1)
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 55dee2148..5c49aea12 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -215,6 +215,16 @@ struct dm_target_msg {
 	char message[];
 };
 
+enum {
+	REMAP_START_CMD = 1,
+	REMAP_FINISH_CMD,
+};
+
+struct dm_remap_param {
+	uint8_t cmd;
+	uint8_t params[0];
+};
+
 /*
  * If you change this make sure you make the corresponding change
  * to dm-ioctl.c:lookup_ioctl()
@@ -245,6 +255,7 @@ enum {
 	DM_DEV_SET_GEOMETRY_CMD,
 	DM_DEV_ARM_POLL_CMD,
 	DM_GET_TARGET_VERSION_CMD,
+	DM_DEV_REMAP_CMD
 };
 
 #define DM_IOCTL 0xfd
@@ -260,6 +271,7 @@ enum {
 #define DM_DEV_STATUS    _IOWR(DM_IOCTL, DM_DEV_STATUS_CMD, struct dm_ioctl)
 #define DM_DEV_WAIT      _IOWR(DM_IOCTL, DM_DEV_WAIT_CMD, struct dm_ioctl)
 #define DM_DEV_ARM_POLL  _IOWR(DM_IOCTL, DM_DEV_ARM_POLL_CMD, struct dm_ioctl)
+#define DM_DEV_REMAP     _IOWR(DM_IOCTL, DM_DEV_REMAP_CMD, struct dm_ioctl)
 
 #define DM_TABLE_LOAD    _IOWR(DM_IOCTL, DM_TABLE_LOAD_CMD, struct dm_ioctl)
 #define DM_TABLE_CLEAR   _IOWR(DM_IOCTL, DM_TABLE_CLEAR_CMD, struct dm_ioctl)
@@ -273,9 +285,9 @@ enum {
 #define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	36
+#define DM_VERSION_MINOR	44
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2017-06-09)"
+#define DM_VERSION_EXTRA	"-ioctl (2020-12-25)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
-- 
2.20.1


