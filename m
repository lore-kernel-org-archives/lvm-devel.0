From: Milan Broz <mbroz@redhat.com>
Date: Thu,  3 Feb 2011 01:20:39 +0100
Subject: [PATCH] Suport DM_SECURE_DATA_FLAG.
Message-ID: <1296692439-24120-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It will be user for cryptsetup to ensure buffers are properly
wiped when sending sensitive data (key).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 libdm/ioctl/libdm-iface.c   |   13 ++++++++++++-
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    1 +
 libdm/libdm-common.c        |    1 +
 libdm/misc/dm-ioctl.h       |   10 ++++++++--
 5 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index fbe4b14..956ccd5 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1273,6 +1273,13 @@ int dm_task_skip_lockfs(struct dm_task *dmt)
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
@@ -1521,6 +1528,8 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
+	if (dmt->secure_data)
+		dmi->flags |= DM_SECURE_DATA_FLAG;
 	if (dmt->query_inactive_table) {
 		if (_dm_version_minor < 16)
 			log_warn("WARNING: Inactive table query unsupported "
@@ -1737,6 +1746,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->read_only = dmt->read_only;
 	task->head = dmt->head;
 	task->tail = dmt->tail;
+	task->secure_data = dmt->secure_data;
 
 	r = dm_task_run(task);
 
@@ -1940,7 +1950,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	}
 
 	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
 		  dmt->new_uuid ? "UUID " : "",
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1954,6 +1964,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 		  dmt->no_open_count ? 'N' : 'O',
 		  dmt->no_flush ? 'N' : 'F',
 		  dmt->skip_lockfs ? "S " : "",
+		  dmt->secure_data ? "W " : "",
 		  dmt->query_inactive_table ? "I " : "",
 		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size);
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index d8cee45..24c01a7 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -63,6 +63,7 @@ struct dm_task {
 	uint64_t existing_table_size;
 	int cookie_set;
 	int new_uuid;
+	int secure_data;
 
 	char *uuid;
 };
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index eea1a6c..d0644ff 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -184,6 +184,7 @@ int dm_task_no_open_count(struct dm_task *dmt);
 int dm_task_skip_lockfs(struct dm_task *dmt);
 int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
+int dm_task_secure_data(struct dm_task *dmt);
 
 /*
  * Control read_ahead.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index a181c5f..0f6eb55 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -200,6 +200,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->cookie_set = 0;
 	dmt->query_inactive_table = 0;
 	dmt->new_uuid = 0;
+	dmt->secure_data = 0;
 
 	return dmt;
 }
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index fb11b5c..c031315 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -269,9 +269,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	19
+#define DM_VERSION_MINOR	20
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2010-10-14)"
+#define DM_VERSION_EXTRA	"-ioctl (2011-02-02)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -330,4 +330,10 @@ enum {
  */
 #define DM_UUID_FLAG			(1 << 14) /* In */
 
+/*
+ * If set, all buffers are wiped after use. Used when sending
+ * or requesting sensitive data like crypt key.
+ */
+#define DM_SECURE_DATA_FLAG		(1 << 15) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */
-- 
1.7.2.3


