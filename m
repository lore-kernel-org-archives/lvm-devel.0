From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Feb 2021 19:01:40 +0000 (GMT)
Subject: main - filter-mpath: work with nvme devices
Message-ID: <20210202190140.D7696383440B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bee9f4efdd8195f383f026290b741314cdc42439
Commit:        bee9f4efdd8195f383f026290b741314cdc42439
Parent:        48dfc388f7bde964d8e4d6816f27de858c984fb3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 3 10:48:21 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 2 13:01:20 2021 -0600

filter-mpath: work with nvme devices

Recognize when a device is nvme, and apply filter-mpath to
nvme devices in addition to scsi devices.
---
 lib/device/dev-type.c      |  81 +++++++++++++++++++----
 lib/device/dev-type.h      |   2 +
 lib/device/device.h        |   1 +
 lib/filters/filter-mpath.c | 156 ++++++++++++++++++++++++++++++---------------
 4 files changed, 177 insertions(+), 63 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 896821de8..379afa89c 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -21,6 +21,7 @@
 #include "lib/metadata/metadata.h"
 #include "lib/device/bcache.h"
 #include "lib/label/label.h"
+#include "lib/commands/toolcontext.h"
 
 #ifdef BLKID_WIPING_SUPPORT
 #include <blkid.h>
@@ -67,6 +68,31 @@ int dev_is_pmem(struct device *dev)
 	return is_pmem ? 1 : 0;
 }
 
+/*
+ * An nvme device has major number 259 (BLKEXT), minor number <minor>,
+ * and reading /sys/dev/block/259:<minor>/device/dev shows a character
+ * device cmajor:cminor where cmajor matches the major number of the
+ * nvme character device entry in /proc/devices.  Checking all of that
+ * is excessive and unnecessary compared to just comparing /dev/name*.
+ */
+
+int dev_is_nvme(struct dev_types *dt, struct device *dev)
+{
+	struct dm_str_list *strl;
+
+	if (dev->flags & DEV_IS_NVME)
+		return 1;
+
+	dm_list_iterate_items(strl, &dev->aliases) {
+		if (!strncmp(strl->str, "/dev/nvme", 9)) {
+			log_debug("Found nvme device %s", dev_name(dev));
+			dev->flags |= DEV_IS_NVME;
+			return 1;
+		}
+	}
+	return 0;
+}
+
 int dev_is_lv(struct device *dev)
 {
 	FILE *fp;
@@ -302,6 +328,9 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 
 const char *dev_subsystem_name(struct dev_types *dt, struct device *dev)
 {
+	if (dev->flags & DEV_IS_NVME)
+		return "NVME";
+
 	if (MAJOR(dev->dev) == dt->device_mapper_major)
 		return "DM";
 
@@ -348,7 +377,6 @@ int major_is_scsi_device(struct dev_types *dt, int major)
 	return (dt->dev_type_array[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
 }
 
-
 static int _loop_is_with_partscan(struct device *dev)
 {
 	FILE *fp;
@@ -398,6 +426,28 @@ struct partition {
 	uint32_t nr_sects;
 } __attribute__((packed));
 
+static int _has_sys_partition(struct device *dev)
+{
+	char path[PATH_MAX];
+	struct stat info;
+	int major = (int) MAJOR(dev->dev);
+	int minor = (int) MINOR(dev->dev);
+
+	/* check if dev is a partition */
+	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d/partition",
+			dm_sysfs_dir(), major, minor) < 0) {
+		log_error("dm_snprintf partition failed");
+		return 0;
+	}
+
+	if (stat(path, &info) == -1) {
+		if (errno != ENOENT)
+			log_sys_error("stat", path);
+		return 0;
+	}
+	return 1;
+}
+
 static int _is_partitionable(struct dev_types *dt, struct device *dev)
 {
 	int parts = major_max_partitions(dt, MAJOR(dev->dev));
@@ -414,6 +464,13 @@ static int _is_partitionable(struct dev_types *dt, struct device *dev)
 	    _loop_is_with_partscan(dev))
 		return 1;
 
+	if (dev_is_nvme(dt, dev)) {
+		/* If this dev is already a partition then it's not partitionable. */
+		if (_has_sys_partition(dev))
+			return 0;
+		return 1;
+	}
+
 	if ((parts <= 1) || (MINOR(dev->dev) % parts))
 		return 0;
 
@@ -557,10 +614,17 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	char path[PATH_MAX];
 	char temp_path[PATH_MAX];
 	char buffer[64];
-	struct stat info;
 	FILE *fp = NULL;
 	int parts, residue, size, ret = 0;
 
+	/*
+	 * /dev/nvme devs don't use the major:minor numbering like
+	 * block dev types that have their own major number, so
+	 * the calculation based on minor number doesn't work.
+	 */
+	if (dev_is_nvme(dt, dev))
+		goto sys_partition;
+
 	/*
 	 * Try to get the primary dev out of the
 	 * list of known device types first.
@@ -576,23 +640,14 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 		goto out;
 	}
 
+ sys_partition:
 	/*
 	 * If we can't get the primary dev out of the list of known device
 	 * types, try to look at sysfs directly then. This is more complex
 	 * way and it also requires certain sysfs layout to be present
 	 * which might not be there in old kernels!
 	 */
-
-	/* check if dev is a partition */
-	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d/partition",
-			sysfs_dir, major, minor) < 0) {
-		log_error("dm_snprintf partition failed");
-		goto out;
-	}
-
-	if (stat(path, &info) == -1) {
-		if (errno != ENOENT)
-			log_sys_error("stat", path);
+	if (!_has_sys_partition(dev)) {
 		*result = dev->dev;
 		ret = 1;
 		goto out; /* dev is not a partition! */
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index fdf7791cf..8b94b7997 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -95,6 +95,8 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev);
 
 int dev_is_pmem(struct device *dev);
 
+int dev_is_nvme(struct dev_types *dt, struct device *dev);
+
 int dev_is_lv(struct device *dev);
 
 int get_fs_block_size(struct device *dev, uint32_t *fs_block_size);
diff --git a/lib/device/device.h b/lib/device/device.h
index a58bff8e3..816db3166 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -38,6 +38,7 @@
 #define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
 #define DEV_UDEV_INFO_MISSING   0x00040000	/* we have no udev info for this device */
+#define DEV_IS_NVME		0x00080000	/* set if dev is nvme */
 
 /*
  * Support for external device info.
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 889a2dd96..853a2c569 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -16,6 +16,7 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
 #include "lib/device/dev-ext-udev-constants.h"
@@ -27,7 +28,6 @@
 
 #define MPATH_PREFIX "mpath-"
 
-
 struct mpath_priv {
 	struct dm_pool *mem;
 	struct dev_filter f;
@@ -35,6 +35,9 @@ struct mpath_priv {
 	struct dm_hash_table *hash;
 };
 
+/*
+ * given "/dev/foo" return "foo"
+ */
 static const char *_get_sysfs_name(struct device *dev)
 {
 	const char *name;
@@ -53,6 +56,11 @@ static const char *_get_sysfs_name(struct device *dev)
 	return name;
 }
 
+/*
+ * given major:minor
+ * readlink translates /sys/dev/block/major:minor to /sys/.../foo
+ * from /sys/.../foo return "foo"
+ */
 static const char *_get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
 					  char *buf, size_t buf_size)
 {
@@ -102,27 +110,28 @@ static int _get_sysfs_string(const char *path, char *buffer, int max_size)
 	return r;
 }
 
-static int _get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname, int *major, int *minor)
+static int _get_sysfs_dm_mpath(struct dev_types *dt, const char *sysfs_dir, const char *holder_name)
 {
-	char path[PATH_MAX], buffer[64];
+	char path[PATH_MAX];
+	char buffer[128];
 
-	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", sysfs_dir, kname) < 0) {
+	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dm/uuid", sysfs_dir, holder_name) < 0) {
 		log_error("Sysfs path string is too long.");
 		return 0;
 	}
 
+	buffer[0] = '\0';
+
 	if (!_get_sysfs_string(path, buffer, sizeof(buffer)))
 		return_0;
 
-	if (sscanf(buffer, "%d:%d", major, minor) != 2) {
-		log_error("Failed to parse major minor from %s", buffer);
-		return 0;
-	}
+	if (!strncmp(buffer, MPATH_PREFIX, 6))
+		return 1;
 
-	return 1;
+	return 0;
 }
 
-static int _get_parent_mpath(const char *dir, char *name, int max_size)
+static int _get_holder_name(const char *dir, char *name, int max_size)
 {
 	struct dirent *d;
 	DIR *dr;
@@ -155,7 +164,7 @@ static int _get_parent_mpath(const char *dir, char *name, int max_size)
 }
 
 #ifdef UDEV_SYNC_SUPPORT
-static int _udev_dev_is_mpath(struct device *dev)
+static int _udev_dev_is_mpath_component(struct device *dev)
 {
 	const char *value;
 	struct dev_ext *ext;
@@ -174,95 +183,148 @@ static int _udev_dev_is_mpath(struct device *dev)
 	return 0;
 }
 #else
-static int _udev_dev_is_mpath(struct device *dev)
+static int _udev_dev_is_mpath_component(struct device *dev)
 {
 	return 0;
 }
 #endif
 
-static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
+static int _native_dev_is_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	struct mpath_priv *mp = (struct mpath_priv *) f->private;
 	struct dev_types *dt = mp->dt;
-	const char *part_name, *name;
-	struct stat info;
-	char path[PATH_MAX], parent_name[PATH_MAX];
+	const char *part_name;
+	const char *name;               /* e.g. "sda" for "/dev/sda" */
+	char link_path[PATH_MAX];       /* some obscure, unpredictable sysfs path */
+	char holders_path[PATH_MAX];    /* e.g. "/sys/block/sda/holders/" */
+	char dm_dev_path[PATH_MAX];    /* e.g. "/dev/dm-1" */
+	char holder_name[128] = { 0 };  /* e.g. "dm-1" */
 	const char *sysfs_dir = dm_sysfs_dir();
-	int major = MAJOR(dev->dev);
-	int minor = MINOR(dev->dev);
+	int dev_major = MAJOR(dev->dev);
+	int dev_minor = MINOR(dev->dev);
+	int dm_dev_major;
+	int dm_dev_minor;
+	struct stat info;
 	dev_t primary_dev;
 	long look;
 
-	/* Limit this filter only to SCSI devices */
-	if (!major_is_scsi_device(dt, MAJOR(dev->dev)))
+	/* Limit this filter to SCSI or NVME devices */
+	if (!major_is_scsi_device(dt, dev_major) && !dev_is_nvme(dt, dev))
 		return 0;
 
 	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
+
 	case 2: /* The dev is partition. */
 		part_name = dev_name(dev); /* name of original dev for log_debug msg */
-		if (!(name = _get_sysfs_name_by_devt(sysfs_dir, primary_dev, parent_name, sizeof(parent_name))))
+
+		/* gets "foo" for "/dev/foo" where "/dev/foo" comes from major:minor */
+		if (!(name = _get_sysfs_name_by_devt(sysfs_dir, primary_dev, link_path, sizeof(link_path))))
 			return_0;
+
 		log_debug_devs("%s: Device is a partition, using primary "
 			       "device %s for mpath component detection",
 			       part_name, name);
 		break;
+
 	case 1: /* The dev is already a primary dev. Just continue with the dev. */
+
+		/* gets "foo" for "/dev/foo" */
 		if (!(name = _get_sysfs_name(dev)))
 			return_0;
 		break;
+
 	default: /* 0, error. */
-		log_warn("Failed to get primary device for %d:%d.", major, minor);
+		log_warn("Failed to get primary device for %d:%d.", dev_major, dev_minor);
 		return 0;
 	}
 
-	if (dm_snprintf(path, sizeof(path), "%sblock/%s/holders", sysfs_dir, name) < 0) {
+	if (dm_snprintf(holders_path, sizeof(holders_path), "%sblock/%s/holders", sysfs_dir, name) < 0) {
 		log_warn("Sysfs path to check mpath is too long.");
 		return 0;
 	}
 
 	/* also will filter out partitions */
-	if (stat(path, &info))
+	if (stat(holders_path, &info))
 		return 0;
 
 	if (!S_ISDIR(info.st_mode)) {
-		log_warn("Path %s is not a directory.", path);
+		log_warn("Path %s is not a directory.", holders_path);
 		return 0;
 	}
 
-	if (!_get_parent_mpath(path, parent_name, sizeof(parent_name)))
+	/*
+	 * If holders dir contains an entry such as "dm-1", then this sets
+	 * holder_name to "dm-1".
+	 *
+	 * If holders dir is empty, return 0 (this is generally where
+	 * devs that are not mpath components return.)
+	 */
+	if (!_get_holder_name(holders_path, holder_name, sizeof(holder_name)))
 		return 0;
 
-	if (!_get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
-		return_0;
+	if (dm_snprintf(dm_dev_path, sizeof(dm_dev_path), "%s/%s", cmd->dev_dir, holder_name) < 0) {
+		log_warn("dm device path to check mpath is too long.");
+		return 0;
+	}
 
-	if (major != dt->device_mapper_major)
+	/*
+	 * stat "/dev/dm-1" which is the holder of the dev we're checking
+	 * dm_dev_major:dm_dev_minor come from stat("/dev/dm-1")
+	 */
+	if (stat(dm_dev_path, &info)) {
+		log_debug("filter-mpath %s holder %s stat result %d",
+			  dev_name(dev), dm_dev_path, errno);
 		return 0;
+	}
+	dm_dev_major = (int)MAJOR(info.st_rdev);
+	dm_dev_minor = (int)MINOR(info.st_rdev);
+	
+	if (dm_dev_major != dt->device_mapper_major) {
+		log_debug_devs("filter-mpath %s holder %s %d:%d does not have dm major",
+			       dev_name(dev), dm_dev_path, dm_dev_major, dm_dev_minor);
+		return 0;
+	}
 
-	/* Avoid repeated detection of multipath device and use first checked result */
-	look = (long) dm_hash_lookup_binary(mp->hash, &minor, sizeof(minor));
+	/*
+	 * Save the result of checking that "/dev/dm-1" is an mpath device
+	 * to avoid repeating it for each path component.
+	 * The minor number of "/dev/dm-1" is added to the hash table with
+	 * const value 2 meaning that dm minor 1 (for /dev/dm-1) is a multipath dev
+	 * and const value 1 meaning that dm minor 1 is not a multipath dev.
+	 */
+	look = (long) dm_hash_lookup_binary(mp->hash, &dm_dev_minor, sizeof(dm_dev_minor));
 	if (look > 0) {
-		log_debug_devs("%s(%u:%u): already checked as %sbeing mpath.",
-			       parent_name, major, minor, (look > 1) ? "" : "not ");
+		log_debug_devs("filter-mpath %s holder %s %u:%u already checked as %sbeing mpath.",
+			       dev_name(dev), holder_name, dm_dev_major, dm_dev_minor, (look > 1) ? "" : "not ");
 		return (look > 1) ? 1 : 0;
 	}
 
-	if (lvm_dm_prefix_check(major, minor, MPATH_PREFIX)) {
-		(void) dm_hash_insert_binary(mp->hash, &minor, sizeof(minor), (void*)2);
+	/*
+	 * Returns 1 if /sys/block/<holder_name>/dm/uuid indicates that
+	 * <holder_name> is a dm device with dm uuid prefix mpath-.
+	 * When true, <holder_name> will be something like "dm-1".
+	 *
+	 * (Is a hash table worth it to avoid reading one sysfs file?)
+	 */
+	if (_get_sysfs_dm_mpath(dt, sysfs_dir, holder_name)) {
+		log_debug_devs("filter-mpath %s holder %s %u:%u ignore mpath component",
+			       dev_name(dev), holder_name, dm_dev_major, dm_dev_minor);
+		(void) dm_hash_insert_binary(mp->hash, &dm_dev_minor, sizeof(dm_dev_minor), (void*)2);
 		return 1;
 	}
 
-	(void) dm_hash_insert_binary(mp->hash, &minor, sizeof(minor), (void*)1);
+	(void) dm_hash_insert_binary(mp->hash, &dm_dev_minor, sizeof(dm_dev_minor), (void*)1);
 
 	return 0;
 }
 
-static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
+static int _dev_is_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
 	if (dev->ext.src == DEV_EXT_NONE)
-		return _native_dev_is_mpath(f, dev);
+		return _native_dev_is_mpath_component(cmd, f, dev);
 
 	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_dev_is_mpath(dev);
+		return _udev_dev_is_mpath_component(dev);
 
 	log_error(INTERNAL_ERROR "Missing hook for mpath recognition "
 		  "using external device info source %s", dev_ext_name(dev));
@@ -272,11 +334,11 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 
 #define MSG_SKIPPING "%s: Skipping mpath component device"
 
-static int _ignore_mpath(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
+static int _ignore_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	dev->filtered_flags &= ~DEV_FILTERED_MPATH_COMPONENT;
 
-	if (_dev_is_mpath(f, dev) == 1) {
+	if (_dev_is_mpath_component(cmd, f, dev) == 1) {
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
 		else
@@ -303,8 +365,8 @@ static void _destroy(struct dev_filter *f)
 struct dev_filter *mpath_filter_create(struct dev_types *dt)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
-	struct dm_pool *mem;
 	struct mpath_priv *mp;
+	struct dm_pool *mem;
 	struct dm_hash_table *hash;
 
 	if (!*sysfs_dir) {
@@ -328,19 +390,13 @@ struct dev_filter *mpath_filter_create(struct dev_types *dt)
 		goto bad;
 	}
 
-	if (!(mp = dm_pool_zalloc(mem, sizeof(*mp)))) {
-		log_error("mpath filter allocation failed.");
-		goto bad;
-	}
-
-	mp->f.passes_filter = _ignore_mpath;
+	mp->f.passes_filter = _ignore_mpath_component;
 	mp->f.destroy = _destroy;
 	mp->f.use_count = 0;
 	mp->f.private = mp;
 	mp->f.name = "mpath";
-
-	mp->mem = mem;
 	mp->dt = dt;
+	mp->mem = mem;
 	mp->hash = hash;
 
 	log_debug_devs("mpath filter initialised.");


