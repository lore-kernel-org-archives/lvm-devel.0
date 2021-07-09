From: David Teigland <teigland@sourceware.org>
Date: Fri,  9 Jul 2021 19:57:07 +0000 (GMT)
Subject: main - skip indexing devices used by LVs in more commands
Message-ID: <20210709195707.984163857C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66daedc6d27d07e4bcd43ee0286e21a69fdc33d9
Commit:        66daedc6d27d07e4bcd43ee0286e21a69fdc33d9
Parent:        70c32d1e74b92f6055bcb688ed0e3bc8630f5489
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 7 16:59:56 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 9 13:59:31 2021 -0500

skip indexing devices used by LVs in more commands

expands commit d5a06f9a7df5a43b2e2311db62ff8d3011217d74
  "pvscan: skip indexing devices used by LVs"

The dev cache index is expensive and slow, so limit it
to commands that are used to observe the state of lvm.
The index is only used to print warnings about incorrect
device use by active LVs, e.g. if an LV is using a
multipath component device instead of the multipath
device.  Commands that continue to use the index and
print the warnings:

  fullreport, lvmdiskscan, vgs, lvs, pvs,
  vgdisplay, lvdisplay, pvdisplay,
  vgscan, lvscan, pvscan (excluding --cache)

A couple other commands were borrowing the DEV_USED_FOR_LV
flag to just check if a device was actively in use by LVs.
These are converted to the new dev_is_used_by_active_lv().
---
 lib/cache/lvmcache.c   |   4 +-
 lib/device/dev-cache.c |   4 +-
 lib/device/dev-cache.h |   3 +-
 lib/device/dev-type.c  | 117 +++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h  |   3 ++
 tools/command.c        |   2 +-
 tools/commands.h       |  22 +++++-----
 tools/lvmcmdline.c     |   2 +
 tools/lvmdevices.c     |   5 ++-
 tools/tools.h          |   2 +
 tools/vgimportclone.c  |   4 +-
 11 files changed, 146 insertions(+), 22 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a798f5ab8..e15b6ce85 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -799,8 +799,8 @@ next:
 				same_id2 = !strcmp(idname2, device_id);
 		}
 
-		has_lv1 = (dev1->flags & DEV_USED_FOR_LV) ? 1 : 0;
-		has_lv2 = (dev2->flags & DEV_USED_FOR_LV) ? 1 : 0;
+		has_lv1 = dev_is_used_by_active_lv(cmd, dev1, NULL, NULL, NULL, NULL);
+		has_lv2 = dev_is_used_by_active_lv(cmd, dev2, NULL, NULL, NULL, NULL);
 
 		in_subsys1 = dev_subsystem_part_major(dt, dev1);
 		in_subsys2 = dev_subsystem_part_major(dt, dev2);
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index bb0d0f211..b1d477ebb 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -412,7 +412,7 @@ out:
 	return r;
 }
 
-static int _get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor)
+int get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor)
 {
 	char path[PATH_MAX];
 
@@ -533,7 +533,7 @@ static int _get_vgid_and_lvid_for_dev(struct device *dev)
 	char uuid[DM_UUID_LEN];
 	size_t uuid_len;
 
-	if (!_get_dm_uuid_from_sysfs(uuid, sizeof(uuid), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)))
+	if (!get_dm_uuid_from_sysfs(uuid, sizeof(uuid), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)))
 		return_0;
 
 	uuid_len = strlen(uuid);
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index c3f5eddda..30ef1cdbe 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -68,13 +68,12 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int unused);
 void dev_iter_destroy(struct dev_iter *iter);
 struct device *dev_iter_get(struct cmd_context *cmd, struct dev_iter *iter);
 
-void dev_reset_error_count(struct cmd_context *cmd);
-
 void dev_cache_failed_path(struct device *dev, const char *path);
 
 bool dev_cache_has_md_with_end_superblock(struct dev_types *dt);
 
 int get_sysfs_value(const char *path, char *buf, size_t buf_size, int error_if_no_value);
+int get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor);
 
 int setup_devices_file(struct cmd_context *cmd);
 int setup_devices(struct cmd_context *cmd);
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 706061814..3c6dd1693 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -22,6 +22,7 @@
 #include "lib/device/bcache.h"
 #include "lib/label/label.h"
 #include "lib/commands/toolcontext.h"
+#include "device_mapper/misc/dm-ioctl.h"
 
 #ifdef BLKID_WIPING_SUPPORT
 #include <blkid.h>
@@ -34,6 +35,7 @@
 
 #include <libgen.h>
 #include <ctype.h>
+#include <dirent.h>
 
 /*
  * An nvme device has major number 259 (BLKEXT), minor number <minor>,
@@ -77,6 +79,121 @@ int dev_is_lv(struct device *dev)
 	return ret;
 }
 
+int dev_is_used_by_active_lv(struct cmd_context *cmd, struct device *dev, int *used_by_lv_count,
+			     char **used_by_dm_name, char **used_by_vg_uuid, char **used_by_lv_uuid)
+{
+	char holders_path[PATH_MAX];
+	char dm_dev_path[PATH_MAX];
+	char dm_uuid[DM_UUID_LEN];
+	struct stat info;
+	DIR *d;
+	struct dirent *dirent;
+	char *holder_name;
+	int dm_dev_major, dm_dev_minor;
+	size_t lvm_prefix_len = sizeof(UUID_PREFIX) - 1;
+	size_t lvm_uuid_len = sizeof(UUID_PREFIX) - 1 + 2 * ID_LEN;
+	size_t uuid_len;
+	int used_count = 0;
+	char *used_name = NULL;
+	char *used_vgid = NULL;
+	char *used_lvid = NULL;
+
+	/*
+	 * An LV using this device will be listed as a "holder" in the device's
+	 * sysfs "holders" dir.
+	 */
+
+	if (dm_snprintf(holders_path, sizeof(holders_path), "%sdev/block/%d:%d/holders/", dm_sysfs_dir(), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)) < 0) {
+		log_error("%s: dm_snprintf failed for path to holders directory.", dev_name(dev));
+		return 0;
+	}
+
+	if (!(d = opendir(holders_path)))
+		return 0;
+
+	while ((dirent = readdir(d))) {
+		if (!strcmp(".", dirent->d_name) || !strcmp("..", dirent->d_name))
+			continue;
+
+		holder_name = dirent->d_name;
+
+		/*
+		 * dirent->d_name is the dev name of the holder, e.g. "dm-1"
+		 * from this name, create path "/dev/dm-1" to run stat on.
+		 */
+		
+		if (dm_snprintf(dm_dev_path, sizeof(dm_dev_path), "%s/%s", cmd->dev_dir, holder_name) < 0)
+			continue;
+
+		/*
+		 * stat "/dev/dm-1" which is the holder of the dev we're checking
+		 * dm_dev_major:dm_dev_minor come from stat("/dev/dm-1")
+		 */
+		if (stat(dm_dev_path, &info))
+			continue;
+
+		dm_dev_major = (int)MAJOR(info.st_rdev);
+		dm_dev_minor = (int)MINOR(info.st_rdev);
+        
+		if (dm_dev_major != cmd->dev_types->device_mapper_major)
+			continue;
+
+		/*
+		 * if "dm-1" is a dm device, then check if it's an LVM LV
+		 * by reading /sys/block/<holder_name>/dm/uuid and seeing
+		 * if the uuid begins with LVM-
+		 * UUID_PREFIX is "LVM-"
+		 */
+
+		dm_uuid[0] = '\0';
+
+		if (!get_dm_uuid_from_sysfs(dm_uuid, sizeof(dm_uuid), dm_dev_major, dm_dev_minor))
+			continue;
+
+		if (!strncmp(dm_uuid, UUID_PREFIX, 4))
+			used_count++;
+
+		if (used_by_dm_name && !used_name)
+			used_name = dm_pool_strdup(cmd->mem, holder_name);
+
+		if (!used_by_vg_uuid && !used_by_lv_uuid)
+			continue;
+
+		/*
+		 * UUID for LV is either "LVM-<vg_uuid><lv_uuid>" or
+		 * "LVM-<vg_uuid><lv_uuid>-<suffix>", where vg_uuid and lv_uuid
+		 * has length of ID_LEN and suffix len is not restricted (only
+		 * restricted by whole DM UUID max len).
+		 */
+
+		uuid_len = strlen(dm_uuid);
+
+		if (((uuid_len == lvm_uuid_len) ||
+		    ((uuid_len > lvm_uuid_len) && (dm_uuid[lvm_uuid_len] == '-'))) &&
+		    !strncmp(dm_uuid, UUID_PREFIX, lvm_prefix_len)) {
+
+			if (used_by_vg_uuid && !used_vgid)
+				used_vgid = dm_pool_strndup(cmd->mem, dm_uuid + lvm_prefix_len, ID_LEN);
+
+			if (used_by_lv_uuid && !used_lvid)
+				used_lvid = dm_pool_strndup(cmd->mem, dm_uuid + lvm_prefix_len + ID_LEN, ID_LEN);
+		}
+	}
+
+	if (used_by_lv_count)
+		*used_by_lv_count = used_count;
+	if (used_by_dm_name)
+		*used_by_dm_name = used_name;
+	if (used_by_vg_uuid)
+		*used_by_vg_uuid = used_vgid;
+	if (used_by_lv_uuid)
+		*used_by_lv_uuid = used_lvid;
+
+	if (used_count)
+		return 1;
+	return 0;
+}
+
 struct dev_types *create_dev_types(const char *proc_dir,
 				   const struct dm_config_node *cn)
 {
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index d358520df..097be72cd 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -102,4 +102,7 @@ int dev_is_lv(struct device *dev);
 
 int get_fs_block_size(const char *pathname, uint32_t *fs_block_size);
 
+int dev_is_used_by_active_lv(struct cmd_context *cmd, struct device *dev, int *used_by_lv_count,
+			     char **used_by_dm_name, char **used_by_vg_uuid, char **used_by_lv_uuid);
+
 #endif
diff --git a/tools/command.c b/tools/command.c
index 7205969e1..b987e49b0 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -141,7 +141,7 @@ static inline int dumptype_arg(struct cmd_context *cmd __attribute__((unused)),
 #define CAN_USE_ONE_SCAN	 0x00002000
 #define ALLOW_HINTS              0x00004000
 #define ALLOW_EXPORTED           0x00008000
-
+#define CHECK_DEVS_USED          0x00010000
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
 
diff --git a/tools/commands.h b/tools/commands.h
index fa5359afe..a38d2b4f5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -31,7 +31,7 @@ xx(formats,
 
 xx(fullreport,
    "Display full report",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(help,
    "Display help for commands",
@@ -55,7 +55,7 @@ xx(lvcreate,
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | CHECK_DEVS_USED)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -75,7 +75,7 @@ xx(lvmdevices,
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(lvmsadc,
    "Collect activity data",
@@ -107,11 +107,11 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | CHECK_DEVS_USED)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CHECK_DEVS_USED)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -131,7 +131,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -149,11 +149,11 @@ xx(pvresize,
 
 xx(pvs,
    "Display information about physical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(segtypes,
    "List available segment types",
@@ -197,7 +197,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -241,11 +241,11 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED | CHECK_DEVS_USED)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d97ff5720..490c9c73d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2473,6 +2473,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 
 	cmd->allow_mixed_block_sizes = find_config_tree_bool(cmd, devices_allow_mixed_block_sizes_CFG, NULL);
 
+	cmd->check_devs_used = (cmd->cname->flags & CHECK_DEVS_USED) ? 1 : 0;
+
 	/*
 	 * enable_hints is set to 1 if any commands are using hints.
 	 * use_hints is set to 1 if this command should use the hints.
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 5117277a0..87c39eec4 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -15,6 +15,7 @@
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device_id.h"
+#include "lib/device/dev-type.h"
 
 static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *search_pvids, struct dm_list *found_devs)
 {
@@ -389,7 +390,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * dev_cache_scan uses sysfs to check if an LV is using each dev
 		 * and sets this flag is so.
 		 */
-		if (dev->flags & DEV_USED_FOR_LV) {
+		if (dev_is_used_by_active_lv(cmd, dev, NULL, NULL, NULL, NULL)) {
 			if (!arg_count(cmd, yes_ARG) &&
 			    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", devname) == 'n') {
 				log_error("Device not removed.");
@@ -435,7 +436,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 
 		if (du->devname && (du->devname[0] != '.')) {
 			if ((dev = dev_cache_get(cmd, du->devname, NULL)) &&
-			    (dev->flags & DEV_USED_FOR_LV)) {
+			    dev_is_used_by_active_lv(cmd, dev, NULL, NULL, NULL, NULL)) {
 				if (!arg_count(cmd, yes_ARG) &&
 			    	    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", du->devname) == 'n') {
 					log_error("Device not removed.");
diff --git a/tools/tools.h b/tools/tools.h
index efbe1f44c..d4d3b9866 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -139,6 +139,8 @@ struct arg_value_group_list {
 #define ALLOW_HINTS		 0x00004000
 /* Command can access exported vg. */
 #define ALLOW_EXPORTED           0x00008000
+/* Command checks and reports warning if devs used by LV are incorrect. */
+#define CHECK_DEVS_USED		 0x00010000
 
 
 void usage(const char *name);
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index a47782771..55a2deb4d 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -61,14 +61,14 @@ static int _update_vg(struct cmd_context *cmd, struct volume_group *vg,
 	/*
 	 * N.B. lvs_in_vg_activated() is not smart enough to distinguish
 	 * between LVs that are active in the original VG vs the cloned VG
-	 * that's being imported, so check DEV_USED_FOR_LV.
+	 * that's being imported, so check dev_is_used_by_active_lv.
 	 */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (is_missing_pv(pvl->pv) || !pvl->pv->dev) {
 			log_error("VG is missing a device.");
 			goto bad;
 		}
-		if (pvl->pv->dev->flags & DEV_USED_FOR_LV) {
+		if (dev_is_used_by_active_lv(cmd, pvl->pv->dev, NULL, NULL, NULL, NULL)) {
 			log_error("Device %s has active LVs, deactivate first.", dev_name(pvl->pv->dev));
 			devs_used_for_lv++;
 		}


