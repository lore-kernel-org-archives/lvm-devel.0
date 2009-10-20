From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 20 Oct 2009 17:06:55 -0400
Subject: [PATCH] dmsetup: add inactive support to status and table
Message-ID: <1256072815-5583-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When using 'table' or 'status' display the inactive table instead of
the active table.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>

---
 libdm/.exported_symbols     |    1 +
 libdm/ioctl/libdm-iface.c   |   12 +++++++++++-
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    1 +
 libdm/misc/dm-ioctl.h       |   10 ++++++++--
 man/dmsetup.8.in            |   12 ++++++++----
 tools/dmsetup.c             |   11 +++++++++--
 7 files changed, 39 insertions(+), 9 deletions(-)

Index: lvm2/libdm/.exported_symbols
===================================================================
--- lvm2.orig/libdm/.exported_symbols
+++ lvm2/libdm/.exported_symbols
@@ -40,6 +40,7 @@ dm_task_add_target
 dm_task_no_flush
 dm_task_no_open_count
 dm_task_skip_lockfs
+dm_task_status_inactive
 dm_task_update_nodes
 dm_task_run
 dm_get_next_target
Index: lvm2/libdm/ioctl/libdm-iface.c
===================================================================
--- lvm2.orig/libdm/ioctl/libdm-iface.c
+++ lvm2/libdm/ioctl/libdm-iface.c
@@ -1135,6 +1135,13 @@ int dm_task_skip_lockfs(struct dm_task *
 	return 1;
 }
 
+int dm_task_status_inactive(struct dm_task *dmt)
+{
+	dmt->status_inactive = 1;
+
+	return 1;
+}
+
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr)
 {
 	dmt->event_nr = event_nr;
@@ -1382,6 +1389,8 @@ static struct dm_ioctl *_flatten(struct 
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
+	if (dmt->status_inactive)
+		dmi->flags |= DM_STATUS_INACTIVE_FLAG;
 
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
@@ -1685,7 +1694,7 @@ static struct dm_ioctl *_do_dm_ioctl(str
 		dmi->flags |= DM_SKIP_BDGET_FLAG;
 
 	log_debug("dm %s %s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
 		  dmt->newname ? dmt->newname : "",
@@ -1698,6 +1707,7 @@ static struct dm_ioctl *_do_dm_ioctl(str
 		  dmt->no_open_count ? 'N' : 'O',
 		  dmt->no_flush ? 'N' : 'F',
 		  dmt->skip_lockfs ? "S " : "",
+		  dmt->status_inactive ? "I " : "",
 		  dmt->sector, dmt->message ? dmt->message : "",
 		  dmi->data_size);
 #ifdef DM_IOCTLS
Index: lvm2/libdm/ioctl/libdm-targets.h
===================================================================
--- lvm2.orig/libdm/ioctl/libdm-targets.h
+++ lvm2/libdm/ioctl/libdm-targets.h
@@ -58,6 +58,7 @@ struct dm_task {
 	int no_flush;
 	int no_open_count;
 	int skip_lockfs;
+	int status_inactive;
 	int suppress_identical_reload;
 	uint64_t existing_table_size;
 	int cookie_set;
Index: lvm2/libdm/libdevmapper.h
===================================================================
--- lvm2.orig/libdm/libdevmapper.h
+++ lvm2/libdm/libdevmapper.h
@@ -172,6 +172,7 @@ int dm_task_set_sector(struct dm_task *d
 int dm_task_no_flush(struct dm_task *dmt);
 int dm_task_no_open_count(struct dm_task *dmt);
 int dm_task_skip_lockfs(struct dm_task *dmt);
+int dm_task_status_inactive(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 
 /*
Index: lvm2/libdm/misc/dm-ioctl.h
===================================================================
--- lvm2.orig/libdm/misc/dm-ioctl.h
+++ lvm2/libdm/misc/dm-ioctl.h
@@ -268,9 +268,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	15
+#define DM_VERSION_MINOR	16
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2009-04-01)"
+#define DM_VERSION_EXTRA	"-ioctl (2009-10-20)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -284,6 +284,12 @@ enum {
 #define DM_STATUS_TABLE_FLAG	(1 << 4) /* In */
 
 /*
+ * Flag passed into ioctl STATUS command to get table information
+ * or current status from the inactive table.
+ */
+#define DM_STATUS_INACTIVE_FLAG        (1 << 7) /* In */
+
+/*
  * Flags that indicate whether a table is present in either of
  * the two table slots that a device has.
  */
Index: lvm2/man/dmsetup.8.in
===================================================================
--- lvm2.orig/man/dmsetup.8.in
+++ lvm2/man/dmsetup.8.in
@@ -50,11 +50,11 @@ dmsetup \- low level logical volume mana
 .I [device_name]
 .br
 .B dmsetup status
-.I [--target target_type]
+.I [--target target_type] [--inactive]
 .I [device_name]
 .br
 .B dmsetup table
-.I [--target target_type]
+.I [--target target_type] [--inactive]
 .I [device_name]
 .br
 .B dmsetup wait
@@ -104,6 +104,10 @@ Invoking the command as \fBdevmap_name\f
 .IP \fB-c|-C|--columns
 .br
 Display output in columns rather than as Field: Value lines.
+.IP \fB--inactive
+.br
+When displaying table or status use the inactive table instead of the
+active table.
 .IP \fB-j|--major\ \fImajor
 .br
 Specify the major number.
@@ -274,7 +278,7 @@ Sets the device geometry to C/H/S.
 Splits given device name into subsystem constituents.
 Default subsystem is LVM.
 .IP \fBstatus
-.I [--target target_type]
+.I [--target target_type] [--inactive]
 .I [device_name]
 .br
 Outputs status information for each of the device's targets.
@@ -293,7 +297,7 @@ Some targets such as recent (October 200
 the --noflush option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .IP \fBtable
-.I [--target target_type]
+.I [--target target_type] [--inactive]
 .I [device_name]
 .br
 Outputs the current table for the device in a format that can be fed
Index: lvm2/tools/dmsetup.c
===================================================================
--- lvm2.orig/tools/dmsetup.c
+++ lvm2/tools/dmsetup.c
@@ -117,6 +117,7 @@ enum {
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
+	INACTIVE_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
 	MODE_ARG,
@@ -1277,6 +1278,9 @@ static int _status(int argc, char **argv
 	if (!_set_task_device(dmt, name, 0))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_status_inactive(dmt))
+		goto out;
+
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
@@ -2432,8 +2436,8 @@ static struct command _commands[] = {
 	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, _ls},
 	{"info", "[<device>]", 0, 1, _info},
 	{"deps", "[<device>]", 0, 1, _deps},
-	{"status", "[<device>] [--target <target_type>]", 0, 1, _status},
-	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
+	{"status", "[<device>] [--target <target_type>] [--inactive]", 0, 1, _status},
+	{"table", "[<device>] [--target <target_type>] [--inactive] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
 	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
@@ -2808,6 +2812,7 @@ static int _process_switches(int *argc, 
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
+		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
@@ -2952,6 +2957,8 @@ static int _process_switches(int *argc, 
 			_switches[TARGET_ARG]++;
 			_target = optarg;
 		}
+		if ((ind == INACTIVE_ARG))
+			_switches[INACTIVE_ARG]++;
 		if ((ind == NAMEPREFIXES_ARG))
 			_switches[NAMEPREFIXES_ARG]++;
 		if ((ind == NOFLUSH_ARG))


