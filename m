From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Jul 2021 16:11:33 +0000 (GMT)
Subject: main - devices: rework libudev usage
Message-ID: <20210713161133.A8D7D396E05B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90485650931d3fc04d00c92a729050c8743969e5
Commit:        90485650931d3fc04d00c92a729050c8743969e5
Parent:        db22a389cfb12eef77dfc2e1ce124ac83ed6c5a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 8 17:12:09 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 13 11:11:23 2021 -0500

devices: rework libudev usage

related to config settings:
  obtain_device_info_from_udev (controls if lvm gets
    a list of devices from readdir /dev or from libudev)
  external_device_info_source (controls if lvm asks
    libudev for device information)

. Make the obtain_device_list_from_udev setting
  affect only the choice of readdir /dev vs libudev.
  The setting no longer controls if udev is used for
  device type checks.

. Change obtain_device_list_from_udev default to 0.
  This helps avoid boot timeouts due to slow libudev
  queries, avoids reported failures from
  udev_enumerate_scan_devices, and avoids delays from
  "device not initialized in udev database" errors.
  Even without errors, for a system booting with 1024 PVs,
  lvm2-pvscan times improve from about 100 sec to 15 sec,
  and the pvscan command from about 64 sec to about 4 sec.

. For external_device_info_source="none", remove all
  libudev device info queries, and use only lvm
  native device info.

. For external_device_info_source="udev", first check
  lvm native device info, then check libudev info.

. Remove sleep/retry loop when attempting libudev
  queries for device info.  udev info will simply
  be skipped if it's not immediately available.

. Only set up a libdev connection if it will be used by
  obtain_device_list_from_udev/external_device_info_source.

. For native multipath component detection, use
  /etc/multipath/wwids.  If a device has a wwid
  matching an entry in the wwids file, then it's
  considered a multipath component.  This is
  necessary to natively detect multipath
  components when the mpath device is not set up.
---
 lib/Makefile.in                  |   1 +
 lib/cache/lvmcache.c             |   6 +-
 lib/commands/toolcontext.c       |  56 ++---
 lib/config/config_settings.h     |  24 +-
 lib/config/defaults.h            |   4 +-
 lib/device/dev-luks.c            |   2 +-
 lib/device/dev-md.c              |  75 ++----
 lib/device/dev-mpath.c           | 486 +++++++++++++++++++++++++++++++++++++++
 lib/device/dev-swap.c            |   2 +-
 lib/device/dev-type.c            | 197 +++-------------
 lib/device/dev-type.h            |  11 +-
 lib/device/device.h              |   3 +
 lib/device/device_id.c           |  38 +--
 lib/device/device_id.h           |   2 +
 lib/filters/filter-composite.c   |  25 +-
 lib/filters/filter-md.c          |   2 +-
 lib/filters/filter-mpath.c       | 362 +----------------------------
 lib/filters/filter-partitioned.c |   4 +-
 lib/filters/filter.h             |   2 +-
 lib/misc/lvm-wrappers.c          |  14 +-
 tools/lvmcmdline.c               |  14 +-
 tools/pvscan.c                   |  12 +-
 22 files changed, 659 insertions(+), 683 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 900ae2f83..8b3eac60a 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -34,6 +34,7 @@ SOURCES =\
 	device/dev-ext.c \
 	device/dev-io.c \
 	device/dev-md.c \
+	device/dev-mpath.c \
 	device/dev-swap.c \
 	device/dev-type.c \
 	device/dev-luks.c \
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e15b6ce85..f5df5e10c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -692,7 +692,7 @@ next:
 	 */
 
 	info = lvmcache_info_from_pvid(pvid, NULL, 0);
-	if (info && dev_is_md_component(info->dev, NULL, 1)) {
+	if (info && dev_is_md_component(cmd, info->dev, NULL, 1)) {
 		/* does not go in del_cache_devs which become unused_duplicates */
 		log_debug_cache("PV %s drop MD component from scan selection %s", pvid, dev_name(info->dev));
 		lvmcache_del(info);
@@ -700,7 +700,7 @@ next:
 	}
 
 	dm_list_iterate_items_safe(devl, devl_safe, &altdevs) {
-		if (dev_is_md_component(devl->dev, NULL, 1)) {
+		if (dev_is_md_component(cmd, devl->dev, NULL, 1)) {
 			log_debug_cache("PV %s drop MD component from scan duplicates %s", pvid, dev_name(devl->dev));
 			dm_list_del(&devl->list);
 		}
@@ -1204,7 +1204,7 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 				  (unsigned long long)pvsize, (unsigned long long)devsize,
 				  device_hint ?: "none", dev_name(dev));
 
-			if (dev_is_md_component(dev, NULL, 1)) {
+			if (dev_is_md_component(cmd, dev, NULL, 1)) {
 				log_debug("dropping PV from md component %s", dev_name(dev));
 				dev->flags &= ~DEV_SCAN_FOUND_LABEL;
 				/* lvmcache_del will also delete vginfo if info was last one */
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 742bdd9c2..ecd50dbf7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -402,15 +402,12 @@ static void _init_logging(struct cmd_context *cmd)
 	reset_lvm_errno(1);
 }
 
-static int _check_disable_udev(const char *msg) {
+static int _check_disable_udev(const char *msg)
+{
 	if (getenv("DM_DISABLE_UDEV")) {
-		log_very_verbose("DM_DISABLE_UDEV environment variable set. "
-				 "Overriding configuration to use "
-				 "udev_rules=0, udev_sync=0, verify_udev_operations=1.");
-		if (udev_is_running())
-			log_warn("Udev is running and DM_DISABLE_UDEV environment variable is set. "
-				 "Bypassing udev, LVM will %s.", msg);
-
+		log_very_verbose("DM_DISABLE_UDEV environment variable set.");
+		log_very_verbose("Overriding configuration to use udev_rules=0, udev_sync=0, verify_udev_operations=1.");
+		log_very_verbose("LVM will %s.", msg);
 		return 1;
 	}
 
@@ -563,7 +560,7 @@ static int _init_system_id(struct cmd_context *cmd)
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
-	const char *dev_ext_info_src;
+	const char *dev_ext_info_src = NULL;
 	const char *read_ahead;
 	struct stat st;
 	const struct dm_config_node *cn;
@@ -597,15 +594,26 @@ static int _process_config(struct cmd_context *cmd)
 #endif
 
 	dev_ext_info_src = find_config_tree_str(cmd, devices_external_device_info_source_CFG, NULL);
-	if (dev_ext_info_src && !strcmp(dev_ext_info_src, "none"))
-		init_external_device_info_source(DEV_EXT_NONE);
-	else if (dev_ext_info_src && !strcmp(dev_ext_info_src, "udev"))
-		init_external_device_info_source(DEV_EXT_UDEV);
-	else {
-		log_error("Invalid external device info source specification.");
-		return 0;
+
+	if (dev_ext_info_src &&
+	    strcmp(dev_ext_info_src, "none") &&
+	    strcmp(dev_ext_info_src, "udev")) {
+		log_warn("WARNING: unknown external device info source, using none.");
+		dev_ext_info_src = NULL;
 	}
 
+	if (dev_ext_info_src && !strcmp(dev_ext_info_src, "udev")) {
+		if (udev_init_library_context()) {
+			init_external_device_info_source(DEV_EXT_UDEV);
+		} else {
+			log_warn("WARNING: failed to init udev for external device info, using none.");
+			dev_ext_info_src = NULL;
+		}
+	}
+
+	if (!dev_ext_info_src || !strcmp(dev_ext_info_src, "none"))
+		init_external_device_info_source(DEV_EXT_NONE);
+
 	/* proc dir */
 	if (dm_snprintf(cmd->proc_dir, sizeof(cmd->proc_dir), "%s",
 			 find_config_tree_str(cmd, global_proc_CFG, NULL)) < 0) {
@@ -1018,16 +1026,10 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	if (!dev_cache_init(cmd))
 		return_0;
 
-	/*
-	 * Override existing config and hardcode device_list_from_udev = 0 if:
-	 *   - udev is not running
-	 *   - udev is disabled using DM_DISABLE_UDEV environment variable
-	 */
-	if (_check_disable_udev("obtain device list by scanning device directory"))
-		device_list_from_udev = 0;
-	else
-		device_list_from_udev = udev_is_running() ?
-			find_config_tree_bool(cmd, devices_obtain_device_list_from_udev_CFG, NULL) : 0;
+	if ((device_list_from_udev = find_config_tree_bool(cmd, devices_obtain_device_list_from_udev_CFG, NULL))) {
+		if (!udev_init_library_context())
+			device_list_from_udev = 0;
+	}
 
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
@@ -1182,7 +1184,7 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
-	if (!(composite = composite_filter_create(nr_filt, 1, filters)))
+	if (!(composite = composite_filter_create(nr_filt, filters)))
 		goto_bad;
 
 	return composite;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d66a9a3a7..fa87bea23 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -238,22 +238,10 @@ cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", de
 	"udev support for this setting to apply.\n")
 
 cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116), NULL, 0, NULL,
-	"Select an external device information source.\n"
-	"Some information may already be available in the system and LVM can\n"
-	"use this information to determine the exact type or use of devices it\n"
-	"processes. Using an existing external device information source can\n"
-	"speed up device processing as LVM does not need to run its own native\n"
-	"routines to acquire this information. For example, this information\n"
-	"is used to drive LVM filtering like MD component detection, multipath\n"
-	"component detection, partition detection and others.\n"
-	"#\n"
-	"Accepted values:\n"
-	"  none\n"
-	"    No external device information source is used.\n"
-	"  udev\n"
-	"    Reuse existing udev database records. Applicable only if LVM is\n"
-	"    compiled with udev support.\n"
-	"#\n")
+	"Enable device information from udev.\n"
+	"If set to \"udev\", lvm will supplement its own native device information\n"
+	"with information from libudev. This can potentially improve the detection\n"
+	"of MD component devices and multipath component devices.\n")
 
 cfg(devices_hints_CFG, "hints", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_HINTS, vsn(2, 3, 2), NULL, 0, NULL,
 	"Use a local file to remember which devices have PVs on them.\n"
@@ -393,6 +381,10 @@ cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEF
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")
 
+cfg(devices_multipath_wwids_file_CFG, "multipath_wwids_file", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_WWIDS_FILE, vsn(2, 3, 13), NULL, 0, NULL,
+	"The path to the multipath wwids file used for multipath component detection.\n"
+	"Set this to an empty string to disable the use of the multipath wwids file.\n")
+
 cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL, 0, NULL,
 	"Enable detection and exclusion of MD component devices.\n"
 	"An MD component device is a block device that MD uses as part\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d5e5b3b1a..66eece53a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -42,7 +42,7 @@
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
 #define DEFAULT_SYSTEM_ID_SOURCE "none"
-#define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
+#define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 0
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
@@ -327,4 +327,6 @@
 
 #define DEFAULT_SEARCH_FOR_DEVNAMES "auto"
 
+#define DEFAULT_WWIDS_FILE "/etc/multipath/wwids"
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 344a55432..d8c422519 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -18,7 +18,7 @@
 #define LUKS_SIGNATURE "LUKS\xba\xbe"
 #define LUKS_SIGNATURE_SIZE 6
 
-int dev_is_luks(struct device *dev, uint64_t *offset_found, int full)
+int dev_is_luks(struct cmd_context *cmd, struct device *dev, uint64_t *offset_found, int full)
 {
 	char buf[LUKS_SIGNATURE_SIZE];
 	int ret = -1;
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 6ddeb5b9e..4debe9e99 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -17,6 +17,7 @@
 #include "lib/device/dev-type.h"
 #include "lib/mm/xlate.h"
 #include "lib/misc/crc.h"
+#include "lib/commands/toolcontext.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h> /* for MD detection using udev db records */
 #include "lib/device/dev-ext-udev-constants.h"
@@ -144,25 +145,16 @@ static int _dev_has_ddf_magic(struct device *dev, uint64_t devsize_sectors, uint
 	return 0;
 }
 
-/*
- * _udev_dev_is_md_component() only works if
- *   external_device_info_source="udev"
- *
- * but
- *
- * udev_dev_is_md_component() in dev-type.c only works if
- *   obtain_device_list_from_udev=1
- *
- * and neither of those config setting matches very well
- * with what we're doing here.
- */
-
 #ifdef UDEV_SYNC_SUPPORT
-static int _udev_dev_is_md_component(struct device *dev)
+static int _dev_is_md_component_udev(struct device *dev)
 {
 	const char *value;
 	struct dev_ext *ext;
 
+	/*
+	 * external_device_info_source="udev" enables these udev checks.
+	 * external_device_info_source="none" disables them.
+	 */
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
@@ -172,7 +164,7 @@ static int _udev_dev_is_md_component(struct device *dev)
 	return !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID);
 }
 #else
-static int _udev_dev_is_md_component(struct device *dev)
+static int _dev_is_md_component_udev(struct device *dev)
 {
 	return 0;
 }
@@ -181,13 +173,16 @@ static int _udev_dev_is_md_component(struct device *dev)
 /*
  * Returns -1 on error
  */
-static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
+static int _dev_is_md_component_native(struct device *dev, uint64_t *offset_found, int full)
 {
 	uint64_t size, sb_offset = 0;
 	int ret;
 
-	if (!scan_bcache)
-		return -EAGAIN;
+	/* i/o layer has not been set up */
+	if (!scan_bcache) {
+		log_error(INTERNAL_ERROR "dev_is_md_component_native requires io layer.");
+		return -1;
+	}
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
@@ -295,41 +290,20 @@ out:
 	return ret;
 }
 
-int dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
+int dev_is_md_component(struct cmd_context *cmd, struct device *dev, uint64_t *offset_found, int full)
 {
-	int ret;
+	if (_dev_is_md_component_native(dev, offset_found, full) == 1)
+		goto found;
 
-	/*
-	 * If non-native device status source is selected, use it
-	 * only if offset_found is not requested as this
-	 * information is not in udev db.
-	 */
-	if ((dev->ext.src == DEV_EXT_NONE) || offset_found) {
-		ret = _native_dev_is_md_component(dev, offset_found, full);
-
-		if (!full) {
-			if (!ret || (ret == -EAGAIN)) {
-				if (udev_dev_is_md_component(dev))
-					ret = 1;
-			}
-		}
-		if (ret && (ret != -EAGAIN))
-			dev->flags |= DEV_IS_MD_COMPONENT;
-		return ret;
-	}
-
-	if (dev->ext.src == DEV_EXT_UDEV) {
-		ret = _udev_dev_is_md_component(dev);
-		if (ret && (ret != -EAGAIN))
-			dev->flags |= DEV_IS_MD_COMPONENT;
-		return ret;
+	if (external_device_info_source() == DEV_EXT_UDEV) {
+		if (_dev_is_md_component_udev(dev) == 1)
+			goto found;
 	}
+	return 0;
 
-	log_error(INTERNAL_ERROR "Missing hook for MD device recognition "
-		  "using external device info source %s", dev_ext_name(dev));
-
-	return -1;
-
+found:
+	dev->flags |= DEV_IS_MD_COMPONENT;
+	return 1;
 }
 
 static int _md_sysfs_attribute_snprintf(char *path, size_t size,
@@ -552,7 +526,8 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev)
 
 #else
 
-int dev_is_md_component(struct device *dev __attribute__((unused)),
+int dev_is_md_component(struct cmd_context *cmd __attribute__((unused)),
+	      struct device *dev __attribute__((unused)),
 	      uint64_t *sb __attribute__((unused)))
 {
 	return 0;
diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
new file mode 100644
index 000000000..1fb281d41
--- /dev/null
+++ b/lib/device/dev-mpath.c
@@ -0,0 +1,486 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/device/device_id.h"
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#include "lib/device/dev-ext-udev-constants.h"
+#endif
+
+#include <dirent.h>
+
+#define MPATH_PREFIX "mpath-"
+
+/*
+ * This hash table keeps track of whether a given dm device
+ * is a mpath device or not.
+ *
+ * If dm-3 is an mpath device, then the constant "2" is stored in
+ * the hash table with the key of the dm minor number ("3" for dm-3).
+ * If dm-3 is not an mpath device, then the constant "1" is stored in
+ * the hash table with the key of the dm minor number.
+ */
+static struct dm_pool *_hash_mem;
+static struct dm_hash_table *_minor_hash_tab;
+static struct dm_hash_table *_wwid_hash_tab;
+
+#define MAX_WWID_LINE 512
+
+/*
+ * do we need to check the multipath.conf blacklist?
+ */
+
+static void _read_wwid_file(const char *config_wwids_file)
+{
+	FILE *fp;
+	char line[MAX_WWID_LINE];
+	char *wwid, *p;
+	int count = 0;
+
+	if (config_wwids_file[0] != '/') {
+		log_print("Ignoring unknown multipath_wwids_file.");
+		return;
+	}
+
+	if (!(fp = fopen(config_wwids_file, "r"))) {
+		log_debug("multipath wwids file not found");
+		return;
+	}
+
+	while (fgets(line, sizeof(line), fp)) {
+		if (line[0] == '#')
+			continue;
+
+		wwid = line;
+
+		if (line[0] == '/')
+			wwid++;
+
+		/* skip the initial '3' */
+		wwid++;
+
+		if ((p = strchr(wwid, '/')))
+			*p = '\0';
+
+		(void) dm_hash_insert_binary(_wwid_hash_tab, wwid, strlen(wwid), (void*)1);
+		count++;
+	}
+
+	if (fclose(fp))
+		stack;
+
+	log_debug("multipath wwids read %d from %s", count, config_wwids_file);
+}
+
+int dev_mpath_init(const char *config_wwids_file)
+{
+	struct dm_pool *mem;
+	struct dm_hash_table *minor_tab;
+	struct dm_hash_table *wwid_tab;
+
+	if (!(mem = dm_pool_create("mpath", 256))) {
+		log_error("mpath pool creation failed.");
+		return 0;
+	}
+
+	if (!(minor_tab = dm_hash_create(110))) {
+		log_error("mpath hash table creation failed.");
+		dm_pool_destroy(mem);
+		return 0;
+	}
+
+	_hash_mem = mem;
+	_minor_hash_tab = minor_tab;
+
+	/* multipath_wwids_file="" disables the use of the file */
+	if (config_wwids_file && !strlen(config_wwids_file)) {
+		log_debug("multipath wwids file disabled.");
+		return 1;
+	}
+
+	if (!(wwid_tab = dm_hash_create(110))) {
+		log_error("mpath hash table creation failed.");
+		dm_hash_destroy(_minor_hash_tab);
+		dm_pool_destroy(_hash_mem);
+		_minor_hash_tab = NULL;
+		_hash_mem = NULL;
+		return 0;
+	}
+
+	_wwid_hash_tab = wwid_tab;
+
+	_read_wwid_file(config_wwids_file);
+
+	return 1;
+}
+
+void dev_mpath_exit(void)
+{
+	if (_minor_hash_tab)
+		dm_hash_destroy(_minor_hash_tab);
+	if (_wwid_hash_tab)
+		dm_hash_destroy(_wwid_hash_tab);
+	if (_hash_mem)
+		dm_pool_destroy(_hash_mem);
+
+	_minor_hash_tab = NULL;
+	_wwid_hash_tab = NULL;
+	_hash_mem = NULL;
+}
+
+
+/*
+ * given "/dev/foo" return "foo"
+ */
+static const char *_get_sysfs_name(struct device *dev)
+{
+	const char *name;
+
+	if (!(name = strrchr(dev_name(dev), '/'))) {
+		log_error("Cannot find '/' in device name.");
+		return NULL;
+	}
+	name++;
+
+	if (!*name) {
+		log_error("Device name is not valid.");
+		return NULL;
+	}
+
+	return name;
+}
+
+/*
+ * given major:minor
+ * readlink translates /sys/dev/block/major:minor to /sys/.../foo
+ * from /sys/.../foo return "foo"
+ */
+static const char *_get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
+					  char *buf, size_t buf_size)
+{
+	const char *name;
+	char path[PATH_MAX];
+	int size;
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d", sysfs_dir,
+			(int) MAJOR(devno), (int) MINOR(devno)) < 0) {
+		log_error("Sysfs path string is too long.");
+		return NULL;
+	}
+
+	if ((size = readlink(path, buf, buf_size - 1)) < 0) {
+		log_sys_error("readlink", path);
+		return NULL;
+	}
+	buf[size] = '\0';
+
+	if (!(name = strrchr(buf, '/'))) {
+		log_error("Cannot find device name in sysfs path.");
+		return NULL;
+	}
+	name++;
+
+	return name;
+}
+
+static int _get_sysfs_string(const char *path, char *buffer, int max_size)
+{
+	FILE *fp;
+	int r = 0;
+
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return 0;
+	}
+
+	if (!fgets(buffer, max_size, fp))
+		log_sys_error("fgets", path);
+	else
+		r = 1;
+
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return r;
+}
+
+static int _get_sysfs_dm_mpath(struct dev_types *dt, const char *sysfs_dir, const char *holder_name)
+{
+	char path[PATH_MAX];
+	char buffer[128];
+
+	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dm/uuid", sysfs_dir, holder_name) < 0) {
+		log_error("Sysfs path string is too long.");
+		return 0;
+	}
+
+	buffer[0] = '\0';
+
+	if (!_get_sysfs_string(path, buffer, sizeof(buffer)))
+		return_0;
+
+	if (!strncmp(buffer, MPATH_PREFIX, 6))
+		return 1;
+
+	return 0;
+}
+
+static int _get_holder_name(const char *dir, char *name, int max_size)
+{
+	struct dirent *d;
+	DIR *dr;
+	int r = 0;
+
+	if (!(dr = opendir(dir))) {
+		log_sys_error("opendir", dir);
+		return 0;
+	}
+
+	*name = '\0';
+	while ((d = readdir(dr))) {
+		if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
+			continue;
+
+		/* There should be only one holder if it is multipath */
+		if (*name) {
+			r = 0;
+			break;
+		}
+
+		strncpy(name, d->d_name, max_size);
+		r = 1;
+	}
+
+	if (closedir(dr))
+		log_sys_debug("closedir", dir);
+
+	return r;
+}
+
+#ifdef UDEV_SYNC_SUPPORT
+static int _dev_is_mpath_component_udev(struct device *dev)
+{
+	const char *value;
+	struct dev_ext *ext;
+
+	/*
+	 * external_device_info_source="udev" enables these udev checks.
+	 * external_device_info_source="none" disables them.
+	 */
+
+	if (!(ext = dev_ext_get(dev)))
+		return_0;
+
+	value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE);
+	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH))
+		return 1;
+
+	value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
+	if (value && !strcmp(value, "1"))
+		return 1;
+
+	return 0;
+}
+#else
+static int _dev_is_mpath_component_udev(struct device *dev)
+{
+	return 0;
+}
+#endif
+
+static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device *dev)
+{
+	struct dev_types *dt = cmd->dev_types;
+	const char *part_name;
+	const char *name;               /* e.g. "sda" for "/dev/sda" */
+	char link_path[PATH_MAX];       /* some obscure, unpredictable sysfs path */
+	char holders_path[PATH_MAX];    /* e.g. "/sys/block/sda/holders/" */
+	char dm_dev_path[PATH_MAX];    /* e.g. "/dev/dm-1" */
+	char holder_name[256];		/* e.g. "dm-1" */
+	const char *sysfs_dir = dm_sysfs_dir();
+	int dev_major = MAJOR(dev->dev);
+	int dev_minor = MINOR(dev->dev);
+	int dm_dev_major;
+	int dm_dev_minor;
+	struct stat info;
+	dev_t primary_dev;
+
+	/* multipathing is only known to exist for SCSI or NVME devices */
+	if (!major_is_scsi_device(dt, dev_major) && !dev_is_nvme(dt, dev))
+		return 0;
+
+	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
+
+	case 2: /* The dev is partition. */
+		part_name = dev_name(dev); /* name of original dev for log_debug msg */
+
+		/* gets "foo" for "/dev/foo" where "/dev/foo" comes from major:minor */
+		if (!(name = _get_sysfs_name_by_devt(sysfs_dir, primary_dev, link_path, sizeof(link_path))))
+			return_0;
+
+		log_debug_devs("%s: Device is a partition, using primary "
+			       "device %s for mpath component detection",
+			       part_name, name);
+		break;
+
+	case 1: /* The dev is already a primary dev. Just continue with the dev. */
+
+		/* gets "foo" for "/dev/foo" */
+		if (!(name = _get_sysfs_name(dev)))
+			return_0;
+		break;
+
+	default: /* 0, error. */
+		log_warn("Failed to get primary device for %d:%d.", dev_major, dev_minor);
+		return 0;
+	}
+
+	if (dm_snprintf(holders_path, sizeof(holders_path), "%sblock/%s/holders", sysfs_dir, name) < 0) {
+		log_warn("Sysfs path to check mpath is too long.");
+		return 0;
+	}
+
+	/* also will filter out partitions */
+	if (stat(holders_path, &info))
+		return 0;
+
+	if (!S_ISDIR(info.st_mode)) {
+		log_warn("Path %s is not a directory.", holders_path);
+		return 0;
+	}
+
+	/*
+	 * If holders dir contains an entry such as "dm-1", then this sets
+	 * holder_name to "dm-1".
+	 *
+	 * If holders dir is empty, return 0 (this is generally where
+	 * devs that are not mpath components return.)
+	 */
+	if (!_get_holder_name(holders_path, holder_name, sizeof(holder_name)))
+		return 0;
+
+	if (dm_snprintf(dm_dev_path, sizeof(dm_dev_path), "%s/%s", cmd->dev_dir, holder_name) < 0) {
+		log_warn("dm device path to check mpath is too long.");
+		return 0;
+	}
+
+	/*
+	 * stat "/dev/dm-1" which is the holder of the dev we're checking
+	 * dm_dev_major:dm_dev_minor come from stat("/dev/dm-1")
+	 */
+	if (stat(dm_dev_path, &info)) {
+		log_debug_devs("dev_is_mpath_component %s holder %s stat result %d",
+			       dev_name(dev), dm_dev_path, errno);
+		return 0;
+	}
+	dm_dev_major = (int)MAJOR(info.st_rdev);
+	dm_dev_minor = (int)MINOR(info.st_rdev);
+	
+	if (dm_dev_major != dt->device_mapper_major) {
+		log_debug_devs("dev_is_mpath_component %s holder %s %d:%d does not have dm major",
+			       dev_name(dev), dm_dev_path, dm_dev_major, dm_dev_minor);
+		return 0;
+	}
+
+	/*
+	 * Save the result of checking that "/dev/dm-1" is an mpath device
+	 * to avoid repeating it for each path component.
+	 * The minor number of "/dev/dm-1" is added to the hash table with
+	 * const value 2 meaning that dm minor 1 (for /dev/dm-1) is a multipath dev
+	 * and const value 1 meaning that dm minor 1 is not a multipath dev.
+	 */
+	if (_minor_hash_tab) {
+		long look = (long) dm_hash_lookup_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor));
+		if (look > 0) {
+			log_debug_devs("dev_is_mpath_component %s holder %s %u:%u already checked as %sbeing mpath.",
+					dev_name(dev), holder_name, dm_dev_major, dm_dev_minor, (look > 1) ? "" : "not ");
+			return (look > 1) ? 1 : 0;
+		}
+	}
+
+	/*
+	 * Returns 1 if /sys/block/<holder_name>/dm/uuid indicates that
+	 * <holder_name> is a dm device with dm uuid prefix mpath-.
+	 * When true, <holder_name> will be something like "dm-1".
+	 */
+	if (_get_sysfs_dm_mpath(dt, sysfs_dir, holder_name)) {
+		log_debug_devs("dev_is_mpath_component %s holder %s %u:%u ignore mpath component",
+			       dev_name(dev), holder_name, dm_dev_major, dm_dev_minor);
+		if (_minor_hash_tab)
+			(void) dm_hash_insert_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor), (void*)2);
+		return 1;
+	}
+
+	if (_minor_hash_tab)
+		(void) dm_hash_insert_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor), (void*)1);
+	return 0;
+}
+
+static int _dev_in_wwid_file(struct cmd_context *cmd, struct device *dev)
+{
+	char sysbuf[PATH_MAX] = { 0 };
+	char *wwid;
+	long look;
+
+	if (!_wwid_hash_tab)
+		return 0;
+
+	if (!read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf)))
+		return 0;
+
+	if (!sysbuf[0])
+		return 0;
+
+	/*
+	 * sysfs prints wwid as <typestr>.<value>
+	 * multipath wwid uses '3'<value>
+	 * does "<typestr>." always correspond to "3"?
+	 */
+	if (!(wwid = strchr(sysbuf, '.')))
+		return 0;
+
+	/* skip the type and dot, just as '3' was skipped from wwids entry */
+	wwid++;
+	
+	look = (long) dm_hash_lookup_binary(_wwid_hash_tab, wwid, strlen(wwid));
+
+	if (look) {
+		log_debug_devs("dev_is_mpath_component %s multipath wwid %s", dev_name(dev), wwid);
+		return 1;
+	}
+	return 0;
+}
+
+int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev)
+{
+	if (_dev_is_mpath_component_sysfs(cmd, dev) == 1)
+		goto found;
+
+	if (_dev_in_wwid_file(cmd, dev))
+		goto found;
+
+	if (external_device_info_source() == DEV_EXT_UDEV) {
+		if (_dev_is_mpath_component_udev(dev) == 1)
+			goto found;
+	}
+
+	return 0;
+found:
+	return 1;
+}
+
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 564bb58ec..1d2a4c9d1 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -35,7 +35,7 @@ static int _swap_detect_signature(const char *buf)
 	return 0;
 }
 
-int dev_is_swap(struct device *dev, uint64_t *offset_found, int full)
+int dev_is_swap(struct cmd_context *cmd, struct device *dev, uint64_t *offset_found, int full)
 {
 	char buf[10];
 	uint64_t size;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 3c6dd1693..067a9ffad 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -621,12 +621,16 @@ static int _has_partition_table(struct device *dev)
 }
 
 #ifdef UDEV_SYNC_SUPPORT
-static int _udev_dev_is_partitioned(struct dev_types *dt, struct device *dev)
+static int _dev_is_partitioned_udev(struct dev_types *dt, struct device *dev)
 {
 	struct dev_ext *ext;
 	struct udev_device *device;
 	const char *value;
 
+	/*
+	 * external_device_info_source="udev" enables these udev checks.
+	 * external_device_info_source="none" disables them.
+	 */
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
@@ -657,21 +661,20 @@ static int _udev_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 	return !strcmp(value, DEV_EXT_UDEV_DEVTYPE_DISK);
 }
 #else
-static int _udev_dev_is_partitioned(struct dev_types *dt, struct device *dev)
+static int _dev_is_partitioned_udev(struct dev_types *dt, struct device *dev)
 {
 	return 0;
 }
 #endif
 
-static int _native_dev_is_partitioned(struct dev_types *dt, struct device *dev)
+static int _dev_is_partitioned_native(struct dev_types *dt, struct device *dev)
 {
 	int r;
 
-	if (!scan_bcache)
-		return -EAGAIN;
-
-	if (!_is_partitionable(dt, dev))
-		return 0;
+	if (!scan_bcache) {
+		log_error(INTERNAL_ERROR "dev_is_partitioned_native requires i/o.");
+		return -1;
+	}
 
 	/* Unpartitioned DASD devices are not supported. */
 	if ((MAJOR(dev->dev) == dt->dasd_major) && dasd_is_cdl_formatted(dev))
@@ -682,16 +685,20 @@ static int _native_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 	return r;
 }
 
-int dev_is_partitioned(struct dev_types *dt, struct device *dev)
+int dev_is_partitioned(struct cmd_context *cmd, struct device *dev)
 {
-	if (dev->ext.src == DEV_EXT_NONE)
-		return _native_dev_is_partitioned(dt, dev);
+	struct dev_types *dt = cmd->dev_types;
 
-	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_dev_is_partitioned(dt, dev);
+	if (!_is_partitionable(dt, dev))
+		return 0;
 
-	log_error(INTERNAL_ERROR "Missing hook for partition table recognition "
-		  "using external device info source %s", dev_ext_name(dev));
+	if (_dev_is_partitioned_native(dt, dev) == 1)
+		return 1;
+
+	if (external_device_info_source() == DEV_EXT_UDEV) {
+		if (_dev_is_partitioned_udev(dt, dev) == 1)
+			return 1;
+	}
 
 	return 0;
 }
@@ -1003,14 +1010,14 @@ out:
 
 #endif /* BLKID_WIPING_SUPPORT */
 
-static int _wipe_signature(struct device *dev, const char *type, const char *name,
+static int _wipe_signature(struct cmd_context *cmd, struct device *dev, const char *type, const char *name,
 			   int wipe_len, int yes, force_t force, int *wiped,
-			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found, int full))
+			   int (*signature_detection_fn)(struct cmd_context *cmd, struct device *dev, uint64_t *offset_found, int full))
 {
 	int wipe;
 	uint64_t offset_found = 0;
 
-	wipe = signature_detection_fn(dev, &offset_found, 1);
+	wipe = signature_detection_fn(cmd, dev, &offset_found, 1);
 	if (wipe == -1) {
 		log_error("Fatal error while trying to detect %s on %s.",
 			  type, name);
@@ -1038,7 +1045,7 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 	return 1;
 }
 
-static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
+static int _wipe_known_signatures_with_lvm(struct cmd_context *cmd, struct device *dev, const char *name,
 					   uint32_t types_to_exclude __attribute__((unused)),
 					   uint32_t types_no_prompt __attribute__((unused)),
 					   int yes, force_t force, int *wiped)
@@ -1049,9 +1056,9 @@ static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
 		wiped = &wiped_tmp;
 	*wiped = 0;
 
-	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, wiped, dev_is_md_component) ||
-	    !_wipe_signature(dev, "swap signature", name, 10, yes, force, wiped, dev_is_swap) ||
-	    !_wipe_signature(dev, "LUKS signature", name, 8, yes, force, wiped, dev_is_luks))
+	if (!_wipe_signature(cmd, dev, "software RAID md superblock", name, 4, yes, force, wiped, dev_is_md_component) ||
+	    !_wipe_signature(cmd, dev, "swap signature", name, 10, yes, force, wiped, dev_is_swap) ||
+	    !_wipe_signature(cmd, dev, "LUKS signature", name, 8, yes, force, wiped, dev_is_luks))
 		return 0;
 
 	return 1;
@@ -1076,7 +1083,7 @@ int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
 			 "while LVM is not compiled with blkid wiping support.");
 		log_warn("WARNING: Falling back to native LVM signature detection.");
 	}
-	return _wipe_known_signatures_with_lvm(dev, name,
+	return _wipe_known_signatures_with_lvm(cmd, dev, name,
 					       types_to_exclude,
 					       types_no_prompt,
 					       yes, force, wiped);
@@ -1266,147 +1273,3 @@ int dev_is_pmem(struct dev_types *dt, struct device *dev)
 }
 #endif
 
-#ifdef UDEV_SYNC_SUPPORT
-
-/*
- * Udev daemon usually has 30s timeout to process each event by default.
- * But still, that value can be changed in udev configuration and we
- * don't have libudev API to read the actual timeout value used.
- */
-
-/* FIXME: Is this long enough to wait for udev db to get initialized?
- *
- *        Take also into consideration that this check is done for each
- *        device that is scanned so we don't want to wait for a long time
- *        if there's something wrong with udev, e.g. timeouts! With current
- *        libudev API, we can't recognize whether the event processing has
- *        not finished yet and it's still being processed or whether it has
- *        failed already due to timeout in udev - in both cases the
- *        udev_device_get_is_initialized returns 0.
- */
-#define UDEV_DEV_IS_COMPONENT_ITERATION_COUNT 100
-#define UDEV_DEV_IS_COMPONENT_USLEEP 100000
-
-static struct udev_device *_udev_get_dev(struct device *dev)
-{
-	struct udev *udev_context = udev_get_library_context();
-	struct udev_device *udev_device = NULL;
-	int initialized = 0;
-	unsigned i = 0;
-
-	if (!udev_context) {
-		log_warn("WARNING: No udev context available to check if device %s is multipath component.", dev_name(dev));
-		return NULL;
-	}
-
-	while (1) {
-		if (i >= UDEV_DEV_IS_COMPONENT_ITERATION_COUNT)
-			break;
-
-		if (udev_device)
-			udev_device_unref(udev_device);
-
-		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
-			log_warn("WARNING: Failed to get udev device handler for device %s.", dev_name(dev));
-			return NULL;
-		}
-
-#ifdef HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED
-		if ((initialized = udev_device_get_is_initialized(udev_device)))
-			break;
-#else
-		if ((initialized = (udev_device_get_property_value(udev_device, DEV_EXT_UDEV_DEVLINKS) != NULL)))
-			break;
-#endif
-
-		log_debug("Device %s not initialized in udev database (%u/%u, %u microseconds).", dev_name(dev),
-			   i + 1, UDEV_DEV_IS_COMPONENT_ITERATION_COUNT,
-			   i * UDEV_DEV_IS_COMPONENT_USLEEP);
-
-		if (!udev_sleeping())
-			break;
-
-		usleep(UDEV_DEV_IS_COMPONENT_USLEEP);
-		i++;
-	}
-
-	if (!initialized) {
-		log_warn("WARNING: Device %s not initialized in udev database even after waiting %u microseconds.",
-			  dev_name(dev), i * UDEV_DEV_IS_COMPONENT_USLEEP);
-		goto out;
-	}
-
-out:
-	return udev_device;
-}
-
-int udev_dev_is_mpath_component(struct device *dev)
-{
-	struct udev_device *udev_device;
-	const char *value;
-	int ret = 0;
-
-	if (!obtain_device_list_from_udev())
-		return 0;
-
-	if (!(udev_device = _udev_get_dev(dev)))
-		return 0;
-
-	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
-	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
-		log_debug("Device %s is multipath component based on blkid variable in udev db (%s=\"%s\").",
-			   dev_name(dev), DEV_EXT_UDEV_BLKID_TYPE, value);
-		ret = 1;
-		goto out;
-	}
-
-	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
-	if (value && !strcmp(value, "1")) {
-		log_debug("Device %s is multipath component based on multipath variable in udev db (%s=\"%s\").",
-			   dev_name(dev), DEV_EXT_UDEV_MPATH_DEVICE_PATH, value);
-		ret = 1;
-		goto out;
-	}
-out:
-	udev_device_unref(udev_device);
-	return ret;
-}
-
-int udev_dev_is_md_component(struct device *dev)
-{
-	struct udev_device *udev_device;
-	const char *value;
-	int ret = 0;
-
-	if (!obtain_device_list_from_udev())
-		return 0;
-
-	if (!(udev_device = _udev_get_dev(dev)))
-		return 0;
-
-	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
-	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID)) {
-		log_debug("Device %s is md raid component based on blkid variable in udev db (%s=\"%s\").",
-			   dev_name(dev), DEV_EXT_UDEV_BLKID_TYPE, value);
-		dev->flags |= DEV_IS_MD_COMPONENT;
-		ret = 1;
-		goto out;
-	}
-out:
-	udev_device_unref(udev_device);
-	return ret;
-}
-
-#else
-
-int udev_dev_is_mpath_component(struct device *dev)
-{
-	return 0;
-}
-
-int udev_dev_is_md_component(struct device *dev)
-{
-	return 0;
-}
-
-#endif
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 097be72cd..f3521c6e0 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -57,12 +57,11 @@ const char *dev_subsystem_name(struct dev_types *dt, struct device *dev);
 int major_is_scsi_device(struct dev_types *dt, int major);
 
 /* Signature/superblock recognition with position returned where found. */
-int dev_is_md_component(struct device *dev, uint64_t *sb, int full);
-int dev_is_swap(struct device *dev, uint64_t *signature, int full);
-int dev_is_luks(struct device *dev, uint64_t *signature, int full);
+int dev_is_md_component(struct cmd_context *cmd, struct device *dev, uint64_t *sb, int full);
+int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev);
+int dev_is_swap(struct cmd_context *cmd, struct device *dev, uint64_t *signature, int full);
+int dev_is_luks(struct cmd_context *cmd, struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
-int udev_dev_is_mpath_component(struct device *dev);
-int udev_dev_is_md_component(struct device *dev);
 
 int dev_is_lvm1(struct device *dev, char *buf, int buflen);
 int dev_is_pool(struct device *dev, char *buf, int buflen);
@@ -81,7 +80,7 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev);
 
 /* Partitioning */
 int major_max_partitions(struct dev_types *dt, int major);
-int dev_is_partitioned(struct dev_types *dt, struct device *dev);
+int dev_is_partitioned(struct cmd_context *cmd, struct device *dev);
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result);
 int dev_get_partition_number(struct device *dev, int *num);
 
diff --git a/lib/device/device.h b/lib/device/device.h
index ca8b3cdd8..a30a1288b 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -205,4 +205,7 @@ void dev_destroy_file(struct device *dev);
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);
 
+int dev_mpath_init(const char *config_wwids_file);
+void dev_mpath_exit(void);
+
 #endif
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 87a46a73a..baba48c05 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -180,7 +180,7 @@ void free_dids(struct dm_list *ids)
 	}
 }
 
-static int _read_sys_block(struct cmd_context *cmd, struct device *dev, const char *suffix, char *sysbuf, int sysbufsize)
+int read_sys_block(struct cmd_context *cmd, struct device *dev, const char *suffix, char *sysbuf, int sysbufsize)
 {
 	char path[PATH_MAX];
 	dev_t devt = dev->dev;
@@ -246,7 +246,7 @@ static int _dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, cons
 	char sysbuf[PATH_MAX] = { 0 };
 	const char *idname;
 
-	if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+	if (!read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
 		return 0;
 
 	if (!_dm_uuid_has_prefix(sysbuf, "mpath-"))
@@ -265,7 +265,7 @@ static int _dev_has_crypt_uuid(struct cmd_context *cmd, struct device *dev, cons
 	char sysbuf[PATH_MAX] = { 0 };
 	const char *idname;
 
-	if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+	if (!read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
 		return 0;
 
 	if (!_dm_uuid_has_prefix(sysbuf, "CRYPT-"))
@@ -284,7 +284,7 @@ static int _dev_has_lvmlv_uuid(struct cmd_context *cmd, struct device *dev, cons
 	char sysbuf[PATH_MAX] = { 0 };
 	const char *idname;
 
-	if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+	if (!read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
 		return 0;
 
 	if (!_dm_uuid_has_prefix(sysbuf, "LVM-"))
@@ -304,10 +304,10 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	const char *idname = NULL;
 
 	if (idtype == DEV_ID_TYPE_SYS_WWID) {
-		_read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf));
 
 		if (!sysbuf[0])
-			_read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
+			read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
 
 		/* scsi_debug wwid begins "t10.Linux   scsi_debug ..." */
 		if (strstr(sysbuf, "scsi_debug"))
@@ -319,22 +319,22 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	}
 
 	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
-		_read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf));
 
 	else if (idtype == DEV_ID_TYPE_MPATH_UUID)
-		_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
 
 	else if (idtype == DEV_ID_TYPE_CRYPT_UUID)
-		_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
 
 	else if (idtype == DEV_ID_TYPE_LVMLV_UUID)
-		_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
 
 	else if (idtype == DEV_ID_TYPE_MD_UUID)
-		_read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf));
 
 	else if (idtype == DEV_ID_TYPE_LOOP_FILE) {
-		_read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf));
+		read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf));
 		/* if backing file is deleted, fall back to devname */
 		if (strstr(sysbuf, "(deleted)"))
 			sysbuf[0] = '\0';
@@ -372,17 +372,17 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 			return 1;
 	}
 
-	if (_read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf)))
+	if (read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf)))
 		return 1;
 
-	if (_read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf)))
+	if (read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf)))
 		return 1;
 
-	if (_read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf)))
+	if (read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf)))
 		return 1;
 
 	if ((MAJOR(dev->dev) == cmd->dev_types->device_mapper_major)) {
-		if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+		if (!read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
 			goto_out;
 
 		if (_dm_uuid_has_prefix(sysbuf, "mpath-"))
@@ -394,11 +394,11 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 	}
 
 	if ((MAJOR(dev->dev) == cmd->dev_types->md_major) &&
-	    _read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf)))
+	    read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf)))
 		return 1;
 
 	if ((MAJOR(dev->dev) == cmd->dev_types->loop_major) &&
-	    _read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf)))
+	    read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf)))
 		return 1;
  out:
 	/* DEV_ID_TYPE_DEVNAME would be used for this dev. */
@@ -1190,7 +1190,7 @@ id_done:
 			if (!label_scan_open(du_devid->dev))
 				log_warn("Cannot open %s", dev_name(du_devid->dev));
 
-			if (dev_is_partitioned(cmd->dev_types, du_devid->dev)) {
+			if (dev_is_partitioned(cmd, du_devid->dev)) {
 				/* Check if existing entry is whole device and new entry is a partition of it. */
 				ret1 = dev_get_primary_dev(cmd->dev_types, dev, &devt1);
 				if ((ret1 == 2) && (devt1 == du_devid->dev->dev))
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 1167373d9..a1a53f253 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -52,4 +52,6 @@ void devices_file_exit(struct cmd_context *cmd);
 
 void unlink_searched_devnames(struct cmd_context *cmd);
 
+int read_sys_block(struct cmd_context *cmd, struct device *dev, const char *suffix, char *sysbuf, int sysbufsize);
+
 #endif
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index f4cbeefe8..46a6724f1 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -21,29 +21,24 @@
 static int _and_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct dev_filter **filters;
-	int ret;
+	int ret = 1;
+
+	dev_ext_enable(dev, external_device_info_source());
 
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters) {
 		if (use_filter_name && strcmp((*filters)->name, use_filter_name))
 			continue;
 		ret = (*filters)->passes_filter(cmd, *filters, dev, use_filter_name);
 
-		if (!ret)
-			return 0;	/* No 'stack': a filter, not an error. */
+		if (!ret) {
+			ret = 0;	/* No 'stack': a filter, not an error. */
+			break;
+		}
 	}
 
-	return 1;
-}
-
-static int _and_p_with_dev_ext_info(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
-{
-	int r;
-
-	dev_ext_enable(dev, external_device_info_source());
-	r = _and_p(cmd, f, dev, use_filter_name);
 	dev_ext_disable(dev);
 
-	return r;
+	return ret;
 }
 
 static void _composite_destroy(struct dev_filter *f)
@@ -72,7 +67,7 @@ static void _wipe(struct cmd_context *cmd, struct dev_filter *f, struct device *
 	}
 }
 
-struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters)
+struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 {
 	struct dev_filter **filters_copy, *cft;
 
@@ -93,7 +88,7 @@ struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct d
 		return NULL;
 	}
 
-	cft->passes_filter = use_dev_ext_info ? _and_p_with_dev_ext_info : _and_p;
+	cft->passes_filter = _and_p;
 	cft->destroy = _composite_destroy;
 	cft->wipe = _wipe;
 	cft->use_count = 0;
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index f72c52123..865fde1a2 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -98,7 +98,7 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 	if (!md_filtering())
 		return 1;
 
-	ret = dev_is_md_component(dev, NULL, cmd->use_full_md_check);
+	ret = dev_is_md_component(cmd, dev, NULL, cmd->use_full_md_check);
 
 	if (ret == -EAGAIN) {
 		/* let pass, call again after scan */
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 471f0b4b9..ebd40a457 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -17,333 +17,17 @@
 #include "lib/filters/filter.h"
 #include "lib/activate/activate.h"
 #include "lib/commands/toolcontext.h"
-#ifdef UDEV_SYNC_SUPPORT
-#include <libudev.h>
-#include "lib/device/dev-ext-udev-constants.h"
-#endif
 
 #ifdef __linux__
 
 #include <dirent.h>
 
-#define MPATH_PREFIX "mpath-"
-
-struct mpath_priv {
-	struct dm_pool *mem;
-	struct dev_filter f;
-	struct dev_types *dt;
-	struct dm_hash_table *hash;
-};
-
-/*
- * given "/dev/foo" return "foo"
- */
-static const char *_get_sysfs_name(struct device *dev)
-{
-	const char *name;
-
-	if (!(name = strrchr(dev_name(dev), '/'))) {
-		log_error("Cannot find '/' in device name.");
-		return NULL;
-	}
-	name++;
-
-	if (!*name) {
-		log_error("Device name is not valid.");
-		return NULL;
-	}
-
-	return name;
-}
-
-/*
- * given major:minor
- * readlink translates /sys/dev/block/major:minor to /sys/.../foo
- * from /sys/.../foo return "foo"
- */
-static const char *_get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
-					  char *buf, size_t buf_size)
-{
-	const char *name;
-	char path[PATH_MAX];
-	int size;
-
-	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d", sysfs_dir,
-			(int) MAJOR(devno), (int) MINOR(devno)) < 0) {
-		log_error("Sysfs path string is too long.");
-		return NULL;
-	}
-
-	if ((size = readlink(path, buf, buf_size - 1)) < 0) {
-		log_sys_error("readlink", path);
-		return NULL;
-	}
-	buf[size] = '\0';
-
-	if (!(name = strrchr(buf, '/'))) {
-		log_error("Cannot find device name in sysfs path.");
-		return NULL;
-	}
-	name++;
-
-	return name;
-}
-
-static int _get_sysfs_string(const char *path, char *buffer, int max_size)
-{
-	FILE *fp;
-	int r = 0;
-
-	if (!(fp = fopen(path, "r"))) {
-		log_sys_error("fopen", path);
-		return 0;
-	}
-
-	if (!fgets(buffer, max_size, fp))
-		log_sys_error("fgets", path);
-	else
-		r = 1;
-
-	if (fclose(fp))
-		log_sys_error("fclose", path);
-
-	return r;
-}
-
-static int _get_sysfs_dm_mpath(struct dev_types *dt, const char *sysfs_dir, const char *holder_name)
-{
-	char path[PATH_MAX];
-	char buffer[128];
-
-	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dm/uuid", sysfs_dir, holder_name) < 0) {
-		log_error("Sysfs path string is too long.");
-		return 0;
-	}
-
-	buffer[0] = '\0';
-
-	if (!_get_sysfs_string(path, buffer, sizeof(buffer)))
-		return_0;
-
-	if (!strncmp(buffer, MPATH_PREFIX, 6))
-		return 1;
-
-	return 0;
-}
-
-static int _get_holder_name(const char *dir, char *name, int max_size)
-{
-	struct dirent *d;
-	DIR *dr;
-	int r = 0;
-
-	if (!(dr = opendir(dir))) {
-		log_sys_error("opendir", dir);
-		return 0;
-	}
-
-	*name = '\0';
-	while ((d = readdir(dr))) {
-		if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
-			continue;
-
-		/* There should be only one holder if it is multipath */
-		if (*name) {
-			r = 0;
-			break;
-		}
-
-		strncpy(name, d->d_name, max_size);
-		r = 1;
-	}
-
-	if (closedir(dr))
-		log_sys_debug("closedir", dir);
-
-	return r;
-}
-
-#ifdef UDEV_SYNC_SUPPORT
-static int _udev_dev_is_mpath_component(struct device *dev)
-{
-	const char *value;
-	struct dev_ext *ext;
-
-	if (!(ext = dev_ext_get(dev)))
-		return_0;
-
-	value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE);
-	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH))
-		return 1;
-
-	value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
-	if (value && !strcmp(value, "1"))
-		return 1;
-
-	return 0;
-}
-#else
-static int _udev_dev_is_mpath_component(struct device *dev)
-{
-	return 0;
-}
-#endif
-
-static int _native_dev_is_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
-{
-	struct mpath_priv *mp = (struct mpath_priv *) f->private;
-	struct dev_types *dt = mp->dt;
-	const char *part_name;
-	const char *name;               /* e.g. "sda" for "/dev/sda" */
-	char link_path[PATH_MAX];       /* some obscure, unpredictable sysfs path */
-	char holders_path[PATH_MAX];    /* e.g. "/sys/block/sda/holders/" */
-	char dm_dev_path[PATH_MAX];    /* e.g. "/dev/dm-1" */
-	char holder_name[256];		/* e.g. "dm-1" */
-	const char *sysfs_dir = dm_sysfs_dir();
-	int dev_major = MAJOR(dev->dev);
-	int dev_minor = MINOR(dev->dev);
-	int dm_dev_major;
-	int dm_dev_minor;
-	struct stat info;
-	dev_t primary_dev;
-	long look;
-
-	/* Limit this filter to SCSI or NVME devices */
-	if (!major_is_scsi_device(dt, dev_major) && !dev_is_nvme(dt, dev))
-		return 0;
-
-	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
-
-	case 2: /* The dev is partition. */
-		part_name = dev_name(dev); /* name of original dev for log_debug msg */
-
-		/* gets "foo" for "/dev/foo" where "/dev/foo" comes from major:minor */
-		if (!(name = _get_sysfs_name_by_devt(sysfs_dir, primary_dev, link_path, sizeof(link_path))))
-			return_0;
-
-		log_debug_devs("%s: Device is a partition, using primary "
-			       "device %s for mpath component detection",
-			       part_name, name);
-		break;
-
-	case 1: /* The dev is already a primary dev. Just continue with the dev. */
-
-		/* gets "foo" for "/dev/foo" */
-		if (!(name = _get_sysfs_name(dev)))
-			return_0;
-		break;
-
-	default: /* 0, error. */
-		log_warn("Failed to get primary device for %d:%d.", dev_major, dev_minor);
-		return 0;
-	}
-
-	if (dm_snprintf(holders_path, sizeof(holders_path), "%sblock/%s/holders", sysfs_dir, name) < 0) {
-		log_warn("Sysfs path to check mpath is too long.");
-		return 0;
-	}
-
-	/* also will filter out partitions */
-	if (stat(holders_path, &info))
-		return 0;
-
-	if (!S_ISDIR(info.st_mode)) {
-		log_warn("Path %s is not a directory.", holders_path);
-		return 0;
-	}
-
-	/*
-	 * If holders dir contains an entry such as "dm-1", then this sets
-	 * holder_name to "dm-1".
-	 *
-	 * If holders dir is empty, return 0 (this is generally where
-	 * devs that are not mpath components return.)
-	 */
-	if (!_get_holder_name(holders_path, holder_name, sizeof(holder_name)))
-		return 0;
-
-	if (dm_snprintf(dm_dev_path, sizeof(dm_dev_path), "%s/%s", cmd->dev_dir, holder_name) < 0) {
-		log_warn("dm device path to check mpath is too long.");
-		return 0;
-	}
-
-	/*
-	 * stat "/dev/dm-1" which is the holder of the dev we're checking
-	 * dm_dev_major:dm_dev_minor come from stat("/dev/dm-1")
-	 */
-	if (stat(dm_dev_path, &info)) {
-		log_debug("filter-mpath %s holder %s stat result %d",
-			  dev_name(dev), dm_dev_path, errno);
-		return 0;
-	}
-	dm_dev_major = (int)MAJOR(info.st_rdev);
-	dm_dev_minor = (int)MINOR(info.st_rdev);
-	
-	if (dm_dev_major != dt->device_mapper_major) {
-		log_debug_devs("filter-mpath %s holder %s %d:%d does not have dm major",
-			       dev_name(dev), dm_dev_path, dm_dev_major, dm_dev_minor);
-		return 0;
-	}
-
-	/*
-	 * Save the result of checking that "/dev/dm-1" is an mpath device
-	 * to avoid repeating it for each path component.
-	 * The minor number of "/dev/dm-1" is added to the hash table with
-	 * const value 2 meaning that dm minor 1 (for /dev/dm-1) is a multipath dev
-	 * and const value 1 meaning that dm minor 1 is not a multipath dev.
-	 */
-	look = (long) dm_hash_lookup_binary(mp->hash, &dm_dev_minor, sizeof(dm_dev_minor));
-	if (look > 0) {
-		log_debug_devs("filter-mpath %s holder %s %u:%u already checked as %sbeing mpath.",
-			       dev_name(dev), holder_name, dm_dev_major, dm_dev_minor, (look > 1) ? "" : "not ");
-		return (look > 1) ? 1 : 0;
-	}
-
-	/*
-	 * Returns 1 if /sys/block/<holder_name>/dm/uuid indicates that
-	 * <holder_name> is a dm device with dm uuid prefix mpath-.
-	 * When true, <holder_name> will be something like "dm-1".
-	 *
-	 * (Is a hash table worth it to avoid reading one sysfs file?)
-	 */
-	if (_get_sysfs_dm_mpath(dt, sysfs_dir, holder_name)) {
-		log_debug_devs("filter-mpath %s holder %s %u:%u ignore mpath component",
-			       dev_name(dev), holder_name, dm_dev_major, dm_dev_minor);
-		(void) dm_hash_insert_binary(mp->hash, &dm_dev_minor, sizeof(dm_dev_minor), (void*)2);
-		return 1;
-	}
-
-	(void) dm_hash_insert_binary(mp->hash, &dm_dev_minor, sizeof(dm_dev_minor), (void*)1);
-
-	return 0;
-}
-
-static int _dev_is_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
-{
-	if (dev->ext.src == DEV_EXT_NONE)
-		return _native_dev_is_mpath_component(cmd, f, dev);
-
-	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_dev_is_mpath_component(dev);
-
-	log_error(INTERNAL_ERROR "Missing hook for mpath recognition "
-		  "using external device info source %s", dev_ext_name(dev));
-
-	return 0;
-}
-
-#define MSG_SKIPPING "%s: Skipping mpath component device"
-
 static int _ignore_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	dev->filtered_flags &= ~DEV_FILTERED_MPATH_COMPONENT;
 
-	if (_dev_is_mpath_component(cmd, f, dev) == 1) {
-		if (dev->ext.src == DEV_EXT_NONE)
-			log_debug_devs(MSG_SKIPPING, dev_name(dev));
-		else
-			log_debug_devs(MSG_SKIPPING " [%s:%p]", dev_name(dev),
-					dev_ext_name(dev), dev->ext.handle);
+	if (dev_is_mpath_component(cmd, dev)) {
+		log_debug_devs("%s: Skipping mpath component device", dev_name(dev));
 		dev->filtered_flags |= DEV_FILTERED_MPATH_COMPONENT;
 		return 0;
 	}
@@ -353,59 +37,33 @@ static int _ignore_mpath_component(struct cmd_context *cmd, struct dev_filter *f
 
 static void _destroy(struct dev_filter *f)
 {
-	struct mpath_priv *mp = (struct mpath_priv*) f->private;
-
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
-
-	dm_hash_destroy(mp->hash);
-	dm_pool_destroy(mp->mem);
 }
 
 struct dev_filter *mpath_filter_create(struct dev_types *dt)
 {
+	struct dev_filter *f;
 	const char *sysfs_dir = dm_sysfs_dir();
-	struct mpath_priv *mp;
-	struct dm_pool *mem;
-	struct dm_hash_table *hash;
 
 	if (!*sysfs_dir) {
 		log_verbose("No proc filesystem found: skipping multipath filter");
 		return NULL;
 	}
 
-	if (!(hash = dm_hash_create(110))) {
-		log_error("mpath hash table creation failed.");
+	if (!(f = zalloc(sizeof(*f)))) {
+		log_error("mpath filter allocation failed");
 		return NULL;
 	}
 
-	if (!(mem = dm_pool_create("mpath", 256))) {
-		log_error("mpath pool creation failed.");
-		dm_hash_destroy(hash);
-		return NULL;
-	}
-
-	if (!(mp = dm_pool_zalloc(mem, sizeof(*mp)))) {
-		log_error("mpath filter allocation failed.");
-		goto bad;
-	}
-
-	mp->f.passes_filter = _ignore_mpath_component;
-	mp->f.destroy = _destroy;
-	mp->f.use_count = 0;
-	mp->f.private = mp;
-	mp->f.name = "mpath";
-	mp->dt = dt;
-	mp->mem = mem;
-	mp->hash = hash;
+	f->passes_filter = _ignore_mpath_component;
+	f->destroy = _destroy;
+	f->use_count = 0;
+	f->name = "mpath";
 
 	log_debug_devs("mpath filter initialised.");
 
-	return &mp->f;
-bad:
-	dm_pool_destroy(mem);
-	dm_hash_destroy(hash);
-	return NULL;
+	return f;
 }
 
 #else
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index c0b5554c5..642553ef2 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -22,7 +22,6 @@
 
 static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
-	struct dev_types *dt = (struct dev_types *) f->private;
 	int ret;
 
 	if (cmd->filter_nodata_only)
@@ -30,7 +29,7 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 
 	dev->filtered_flags &= ~DEV_FILTERED_PARTITIONED;
 
-	ret = dev_is_partitioned(dt, dev);
+	ret = dev_is_partitioned(cmd, dev);
 
 	if (ret == -EAGAIN) {
 		/* let pass, call again after scan */
@@ -72,7 +71,6 @@ struct dev_filter *partitioned_filter_create(struct dev_types *dt)
 	f->passes_filter = _passes_partitioned_filter;
 	f->destroy = _partitioned_filter_destroy;
 	f->use_count = 0;
-	f->private = dt;
 	f->name = "partitioned";
 
 	log_debug_devs("Partitioned filter initialised.");
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index f9de65273..bff58c9a4 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -20,7 +20,7 @@
 #include "lib/device/dev-cache.h"
 #include "lib/device/dev-type.h"
 
-struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters);
+struct dev_filter *composite_filter_create(int n, struct dev_filter **filters);
 
 struct dev_filter *lvm_type_filter_create(struct dev_types *dt);
 struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *dt);
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index c36e2cfc7..2e0cfd514 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -25,19 +25,29 @@ struct udev *_udev;
 int udev_init_library_context(void)
 {
 	if (_udev)
-		udev_unref(_udev);
+		return 1;
+
+	if (getenv("DM_DISABLE_UDEV"))
+		return 0;
 
 	if (!(_udev = udev_new())) {
 		log_error("Failed to create udev library context.");
 		return 0;
 	}
 
+	if (!udev_is_running()) {
+		udev_unref(_udev);
+		_udev = NULL;
+		return 0;
+	}
+
 	return 1;
 }
 
 void udev_fin_library_context(void)
 {
-	udev_unref(_udev);
+	if (_udev)
+		udev_unref(_udev);
 	_udev = NULL;
 }
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 490c9c73d..134697aa3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3228,6 +3228,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	_init_md_checks(cmd);
 
+	if (!dev_mpath_init(find_config_tree_str_allow_empty(cmd, devices_multipath_wwids_file_CFG, NULL))) {
+		ret = ECMD_FAILED;
+		goto_out;
+	}
+
 	if (!_cmd_no_meta_proc(cmd) && !_init_lvmlockd(cmd)) {
 		ret = ECMD_FAILED;
 		goto_out;
@@ -3248,6 +3253,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
       out:
 
+	dev_mpath_exit();
 	hints_exit(cmd);
 	lvmcache_destroy(cmd, 1, 1);
 	label_scan_destroy(cmd);
@@ -3541,9 +3547,6 @@ struct cmd_context *init_lvm(unsigned set_connections,
 {
 	struct cmd_context *cmd;
 
-	if (!udev_init_library_context())
-		stack;
-
 	/*
 	 * It's not necessary to use name mangling for LVM:
 	 *   - the character set used for LV names is subset of udev character set
@@ -3551,9 +3554,7 @@ struct cmd_context *init_lvm(unsigned set_connections,
 	 */
 	dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
-	if (!(cmd = create_toolcontext(0, NULL, 1, threaded,
-			set_connections, set_filters))) {
-		udev_fin_library_context();
+	if (!(cmd = create_toolcontext(0, NULL, 1, threaded, set_connections, set_filters))) {
 		return_NULL;
 	}
 
@@ -3561,7 +3562,6 @@ struct cmd_context *init_lvm(unsigned set_connections,
 
 	if (stored_errno()) {
 		destroy_toolcontext(cmd);
-		udev_fin_library_context();
 		return_NULL;
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 464501ad5..40a93957c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1193,16 +1193,6 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 
 		log_debug("online_devs %s %s", dev_name(dev), dev->pvid);
 
-		/*
-		 * This should already have been done by the filter, but make
-		 * another check directly with udev in case the filter was not
-		 * using udev and the native version didn't catch it.
-		 */
-		if (udev_dev_is_mpath_component(dev)) {
-			log_print("pvscan[%d] ignore multipath component %s.", getpid(), dev_name(dev));
-			continue;
-		}
-
 		if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
 			if (!do_all)
 				log_print("pvscan[%d] ignore %s with no lvm info.", getpid(), dev_name(dev));
@@ -1257,7 +1247,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 			if (pv->device_hint && !strncmp(pv->device_hint, "/dev/md", 7))
 				do_full_check = 1;
 		}
-		if (do_full_check && dev_is_md_component(dev, NULL, 1)) {
+		if (do_full_check && dev_is_md_component(cmd, dev, NULL, 1)) {
 			log_print("pvscan[%d] ignore md component %s.", getpid(), dev_name(dev));
 			release_vg(vg);
 			continue;


