From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:38 -0500
Subject: stable-2.02 - cleanup: move cast to det_t into MKDEV macro
Message-ID: <201903051353.x25DrcGP006769@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e974f6866af02f0d0727a434c3150ca408da2658
Commit:        e974f6866af02f0d0727a434c3150ca408da2658
Parent:        a93699ece9dfebe5dfa8a7c8008b12bdecf037c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 3 17:13:10 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:39:17 2019 +0100

cleanup: move cast to det_t into MKDEV macro

(cherry picked from commit aa8b2d6a0feb91bb5ea4364cdc53a00dfa233dca)

Conflicts:
	daemons/clvmd/clvmd-common.h
	device_mapper/ioctl/libdm-iface.c
	device_mapper/libdm-common.c
	device_mapper/libdm-deptree.c
---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 lib/activate/dev_manager.c      |    2 +-
 lib/device/dev-cache.c          |    4 ++--
 lib/device/dev-type.c           |    4 ++--
 lib/device/dev-type.h           |    2 +-
 libdm/ioctl/libdm-iface.c       |    8 ++++----
 libdm/libdm-common.c            |    2 +-
 libdm/libdm-deptree.c           |    4 ++--
 libdm/misc/kdev_t.h             |    2 +-
 tools/pvscan.c                  |    4 ++--
 10 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 79ddf18..a6e8c67 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -33,7 +33,7 @@
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))
-#  define MKDEV(x,y) makedev((x),(y))
+#  define MKDEV(x,y) makedev((dev_t)(x),(dev_t)(y))
 #endif
 
 /* limit to two updates/sec */
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1f4ec65..b6a188a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -366,7 +366,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 			if (!(tmp_dev = dev_create_file(buf, NULL, NULL, 0)))
 				goto_out;
 
-			tmp_dev->dev = MKDEV((dev_t)sm->logs[0].major, (dev_t)sm->logs[0].minor);
+			tmp_dev->dev = MKDEV(sm->logs[0].major, sm->logs[0].minor);
 			if (device_is_usable(tmp_dev, (struct dev_usable_check_params)
 					     { .check_empty = 1,
 					       .check_blocked = 1,
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 997d75f..04ee41e 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -480,7 +480,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return NULL;
 	}
 
-	devno = MKDEV((dev_t)major, (dev_t)minor);
+	devno = MKDEV(major, minor);
 	if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devno))) {
 		/*
 		 * If we get here, it means the device is referenced in sysfs, but it's not yet in /dev.
@@ -984,7 +984,7 @@ static int _dev_cache_iterate_sysfs_for_index(const char *path)
 			continue;
 		}
 
-		devno = MKDEV((dev_t)major, (dev_t)minor);
+		devno = MKDEV(major, minor);
 		if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devno)) &&
 		    !(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) devno))) {
 			if (!dm_device_get_name(major, minor, 1, devname, sizeof(devname)) ||
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e909c0f..ce4a05b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -505,7 +505,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 */
 	if ((parts = dt->dev_type_array[major].max_partitions) > 1) {
 		if ((residue = minor % parts)) {
-			*result = MKDEV((dev_t)major, (dev_t)(minor - residue));
+			*result = MKDEV(major, (minor - residue));
 			ret = 2;
 		} else {
 			*result = dev->dev;
@@ -575,7 +575,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 			  path, buffer);
 		goto out;
 	}
-	*result = MKDEV((dev_t)major, (dev_t)minor);
+	*result = MKDEV(major, minor);
 	ret = 2;
 out:
 	if (fp && fclose(fp))
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 2644383..bd989f8 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -26,7 +26,7 @@
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))
-#  define MKDEV(x,y) makedev((x),(y))
+#  define MKDEV(x,y) makedev((dev_t)(x),(dev_t)(y))
 #endif
 
 #define PARTITION_SCSI_DEVICE (1 << 0)
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5068d4c..cf7a279 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -30,7 +30,7 @@
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))
-#  define MKDEV(x,y) makedev((x),(y))
+#  define MKDEV(x,y) makedev(((dev_t)x),((dev_t)y))
 #endif
 
 #include "dm-ioctl.h"
@@ -259,7 +259,7 @@ static int _control_exists(const char *control, uint32_t major, uint32_t minor)
 		return -1;
 	}
 
-	if (major && buf.st_rdev != MKDEV((dev_t)major, (dev_t)minor)) {
+	if (major && buf.st_rdev != MKDEV(major, minor)) {
 		log_verbose("%s: Wrong device number: (%u, %u) instead of "
 			    "(%u, %u)", control,
 			    MAJOR(buf.st_mode), MINOR(buf.st_mode),
@@ -302,7 +302,7 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	(void) dm_prepare_selinux_context(control, S_IFCHR);
 	old_umask = umask(DM_CONTROL_NODE_UMASK);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
-		  MKDEV((dev_t)major, (dev_t)minor)) < 0)  {
+		  MKDEV(major, minor)) < 0)  {
 		log_sys_error("mknod", control);
 		ret = 0;
 	}
@@ -1194,7 +1194,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		}
 
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
-		dmi->dev = MKDEV((dev_t)dmt->major, (dev_t)dmt->minor);
+		dmi->dev = MKDEV(dmt->major, dmt->minor);
 	}
 
 	/* Does driver support device number referencing? */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 40b366b..e7934d1 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1040,7 +1040,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 {
 	char path[PATH_MAX];
 	struct stat info;
-	dev_t dev = MKDEV((dev_t)major, (dev_t)minor);
+	dev_t dev = MKDEV(major, minor);
 	mode_t old_mask;
 
 	if (!_build_dev_path(path, sizeof(path), dev_name))
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ab05456..a9d71a2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -523,7 +523,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	dm_list_init(&node->activated);
 	dm_list_init(&node->props.segs);
 
-	dev = MKDEV((dev_t)info->major, (dev_t)info->minor);
+	dev = MKDEV(info->major, info->minor);
 
 	if (!dm_hash_insert_binary(dtree->devs, (const char *) &dev,
 				   sizeof(dev), node)) {
@@ -546,7 +546,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 static struct dm_tree_node *_find_dm_tree_node(struct dm_tree *dtree,
 					       uint32_t major, uint32_t minor)
 {
-	dev_t dev = MKDEV((dev_t)major, (dev_t)minor);
+	dev_t dev = MKDEV(major, minor);
 
 	return dm_hash_lookup_binary(dtree->devs, (const char *) &dev,
 				     sizeof(dev));
diff --git a/libdm/misc/kdev_t.h b/libdm/misc/kdev_t.h
index f88bb0a..12780d2 100644
--- a/libdm/misc/kdev_t.h
+++ b/libdm/misc/kdev_t.h
@@ -17,6 +17,6 @@
 
 #define MAJOR(dev)      ((dev & 0xfff00) >> 8)
 #define MINOR(dev)      ((dev & 0xff) | ((dev >> 12) & 0xfff00))
-#define MKDEV(ma,mi)    ((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
+#define MKDEV(ma,mi)    (((dev_t)mi & 0xff) | ((dev_t)ma << 8) | (((dev_t)mi & ~0xff) << 12))
 
 #endif
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 877b6b2..5587928 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -496,7 +496,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 				log_warn("WARNING: Failed to parse major:minor from %s, skipping.", pv_name);
 				continue;
 			}
-			devno = MKDEV((dev_t)major, (dev_t)minor);
+			devno = MKDEV(major, minor);
 
 			if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
 				/* Remove major:minor from lvmetad. */
@@ -559,7 +559,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		if (major < 0 || minor < 0)
 			continue;
 
-		devno = MKDEV((dev_t)major, (dev_t)minor);
+		devno = MKDEV(major, minor);
 
 		if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
 			/* Remove major:minor from lvmetad. */


