From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 16 Sep 2019 05:55:42 -0400 (EDT)
Subject: [PATCH] dm: introduce DM_GET_TARGET_VERSION
Message-ID: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch introduces a new ioctl DM_GET_TARGET_VERSION. It will load a
target that is specified in the "name" entry in the parameter structure
and return its version.

This functionality is intended to be used by cryptsetup, so that it can
query kernel capabilities before activating the device.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/md/dm-ioctl.c         |   32 +++++++++++++++++++++++++++++---
 include/uapi/linux/dm-ioctl.h |    6 ++++--
 2 files changed, 33 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/md/dm-ioctl.c
===================================================================
--- linux-2.6.orig/drivers/md/dm-ioctl.c	2019-09-16 11:42:45.000000000 +0200
+++ linux-2.6/drivers/md/dm-ioctl.c	2019-09-16 11:50:10.000000000 +0200
@@ -601,17 +601,27 @@ static void list_version_get_info(struct
     info->vers = align_ptr(((void *) ++info->vers) + strlen(tt->name) + 1);
 }
 
-static int list_versions(struct file *filp, struct dm_ioctl *param, size_t param_size)
+static int __list_versions(struct dm_ioctl *param, size_t param_size, const char *name)
 {
 	size_t len, needed = 0;
 	struct dm_target_versions *vers;
 	struct vers_iter iter_info;
+	struct target_type *tt = NULL;
+
+	if (name) {
+		tt = dm_get_target_type(name);
+		if (!tt)
+			return -EINVAL;
+	}
 
 	/*
 	 * Loop through all the devices working out how much
 	 * space we need.
 	 */
-	dm_target_iterate(list_version_get_needed, &needed);
+	if (!tt)
+		dm_target_iterate(list_version_get_needed, &needed);
+	else
+		list_version_get_needed(tt, &needed);
 
 	/*
 	 * Grab our output buffer.
@@ -632,13 +642,28 @@ static int list_versions(struct file *fi
 	/*
 	 * Now loop through filling out the names & versions.
 	 */
-	dm_target_iterate(list_version_get_info, &iter_info);
+	if (!tt)
+		dm_target_iterate(list_version_get_info, &iter_info);
+	else
+		list_version_get_info(tt, &iter_info);
 	param->flags |= iter_info.flags;
 
  out:
+	if (tt)
+		dm_put_target_type(tt);
 	return 0;
 }
 
+static int list_versions(struct file *filp, struct dm_ioctl *param, size_t param_size)
+{
+	return __list_versions(param, param_size, NULL);
+}
+
+static int get_target_version(struct file *filp, struct dm_ioctl *param, size_t param_size)
+{
+	return __list_versions(param, param_size, param->name);
+}
+
 static int check_name(const char *name)
 {
 	if (strchr(name, '/')) {
@@ -1664,6 +1689,7 @@ static ioctl_fn lookup_ioctl(unsigned in
 		{DM_TARGET_MSG_CMD, 0, target_message},
 		{DM_DEV_SET_GEOMETRY_CMD, 0, dev_set_geometry},
 		{DM_DEV_ARM_POLL, IOCTL_FLAGS_NO_PARAMS, dev_arm_poll},
+		{DM_GET_TARGET_VERSION, 0, get_target_version},
 	};
 
 	if (unlikely(cmd >= ARRAY_SIZE(_ioctls)))
Index: linux-2.6/include/uapi/linux/dm-ioctl.h
===================================================================
--- linux-2.6.orig/include/uapi/linux/dm-ioctl.h	2019-09-16 11:42:45.000000000 +0200
+++ linux-2.6/include/uapi/linux/dm-ioctl.h	2019-09-16 11:50:37.000000000 +0200
@@ -243,6 +243,7 @@ enum {
 	DM_TARGET_MSG_CMD,
 	DM_DEV_SET_GEOMETRY_CMD,
 	DM_DEV_ARM_POLL_CMD,
+	DM_GET_TARGET_VERSION_CMD,
 };
 
 #define DM_IOCTL 0xfd
@@ -265,14 +266,15 @@ enum {
 #define DM_TABLE_STATUS  _IOWR(DM_IOCTL, DM_TABLE_STATUS_CMD, struct dm_ioctl)
 
 #define DM_LIST_VERSIONS _IOWR(DM_IOCTL, DM_LIST_VERSIONS_CMD, struct dm_ioctl)
+#define DM_GET_TARGET_VERSION _IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_TARGET_MSG	 _IOWR(DM_IOCTL, DM_TARGET_MSG_CMD, struct dm_ioctl)
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	40
+#define DM_VERSION_MINOR	41
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2019-01-18)"
+#define DM_VERSION_EXTRA	"-ioctl (2019-09-16)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */


