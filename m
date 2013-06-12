From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:16:55 +0000 (UTC)
Subject: master - refactor: make device type recognition code common for general use
Message-ID: <20130612111655.E69C460F27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6f48b7c1a0271255405346c50d6bee8cc8b9241
Commit:        c6f48b7c1a0271255405346c50d6bee8cc8b9241
Parent:        1778d34cefdfe30055ac4a7e82438e4484004491
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 12:08:56 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 12:08:56 2013 +0200

refactor: make device type recognition code common for general use

Changes:

- move device type registration out of "type filter" (filter.c)
to a separate and new dev-type.[ch] for common use throughout the code

- the structure for keeping the major numbers detected for available
device types and available partitioning available is stored in
"dev_types" structure now

- move common partitioning detection code to dev-type.[ch] as well
together with other device-related functions bound to dev_types
(see dev-type.h for the interface)

The dev-type interface contains all common functions used to detect
subsystems/device types, signature/superblock recognition code,
type-specific device properties and other common device properties
(bound to dev_types), including partitioning support.

- add dev_types instance to cmd context as cmd->dev_types for common use

- use cmd->dev_types throughout as a central point for providing
information about device types
---
 include/.symlinks.in            |    1 +
 lib/cache/lvmcache.c            |   14 +-
 lib/cache/lvmcache.h            |    1 +
 lib/commands/toolcontext.c      |   28 ++-
 lib/commands/toolcontext.h      |    2 +
 lib/device/dev-cache.c          |    1 +
 lib/device/dev-luks.c           |    1 +
 lib/device/dev-md.c             |   39 ++--
 lib/device/dev-swap.c           |    1 +
 lib/device/dev-type.c           |  443 +++++++++++++++++++++++++++++----------
 lib/device/dev-type.h           |   76 +++++++
 lib/device/device-types.h       |   73 ++++----
 lib/device/device.h             |   16 --
 lib/filters/filter-composite.c  |    2 -
 lib/filters/filter-md.c         |    6 +-
 lib/filters/filter-md.h         |    3 +-
 lib/filters/filter-mpath.c      |   25 +--
 lib/filters/filter-mpath.h      |    3 +-
 lib/filters/filter-persistent.c |   17 +-
 lib/filters/filter-persistent.h |    4 +-
 lib/filters/filter-regex.c      |    1 -
 lib/filters/filter-regex.h      |    1 -
 lib/filters/filter-sysfs.h      |    1 -
 lib/filters/filter.c            |  274 +-----------------------
 lib/filters/filter.h            |   27 +--
 lib/format1/disk-rep.c          |   11 +-
 lib/format_pool/disk_rep.c      |    9 +-
 lib/metadata/metadata.c         |    8 +-
 lib/metadata/pv_manip.c         |    4 +-
 29 files changed, 559 insertions(+), 533 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 1c883ae..facadbe 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -15,6 +15,7 @@
 @top_srcdir@/lib/datastruct/lvm-types.h
 @top_srcdir@/lib/datastruct/str_list.h
 @top_srcdir@/lib/device/dev-cache.h
+ at top_srcdir@/lib/device/dev-type.h
 @top_srcdir@/lib/device/device.h
 @top_srcdir@/lib/display/display.h
 @top_srcdir@/lib/filters/filter-composite.h
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6f935db..c0b3299 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1452,6 +1452,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   const char *vgname, const char *vgid,
 				   uint32_t vgstatus)
 {
+	const struct format_type *fmt = (const struct format_type *) labeller->private;
+	struct dev_types *dt = fmt->cmd->dev_types;
 	struct label *label;
 	struct lvmcache_info *existing, *info;
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
@@ -1485,12 +1487,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	} else {
 		if (existing->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
-			if (dev_subsystem_part_major(existing->dev) &&
-			    !dev_subsystem_part_major(dev)) {
+			if (dev_subsystem_part_major(dt, existing->dev) &&
+			    !dev_subsystem_part_major(dt, dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s - using %s %s",
 						 pvid, dev_name(dev),
-						 dev_subsystem_name(existing->dev),
+						 dev_subsystem_name(dt, existing->dev),
 						 dev_name(existing->dev));
 				return NULL;
 			} else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
@@ -1500,12 +1502,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 						 pvid, dev_name(dev),
 						 dev_name(existing->dev));
 				return NULL;
-			} else if (!dev_subsystem_part_major(existing->dev) &&
-				   dev_subsystem_part_major(dev))
+			} else if (!dev_subsystem_part_major(dt, existing->dev) &&
+				   dev_subsystem_part_major(dt, dev))
 				log_very_verbose("Duplicate PV %s on %s - "
 						 "using %s %s", pvid,
 						 dev_name(existing->dev),
-						 dev_subsystem_name(existing->dev),
+						 dev_subsystem_name(dt, existing->dev),
 						 dev_name(dev));
 			else if (!dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 dm_is_dm_major(MAJOR(dev->dev)))
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 119b411..bf26664 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -17,6 +17,7 @@
 #define _LVM_CACHE_H
 
 #include "dev-cache.h"
+#include "dev-type.h"
 #include "uuid.h"
 #include "label.h"
 #include "locking.h"
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index dca2329..79c25a5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -820,8 +820,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 		nr_filt++;
 
 	/* device type filter. Required. */
-	cn = find_config_tree_node(cmd, devices_types_CFG);
-	if (!(filters[nr_filt] = lvm_type_filter_create(cmd->proc_dir, cn))) {
+	if (!(filters[nr_filt] = lvm_type_filter_create(cmd->dev_types))) {
 		log_error("Failed to create lvm type filter");
 		goto bad;
 	}
@@ -830,13 +829,13 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	/* md component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG)) {
 		init_md_filtering(1);
-		if ((filters[nr_filt] = md_filter_create()))
+		if ((filters[nr_filt] = md_filter_create(cmd->dev_types)))
 			nr_filt++;
 	}
 
 	/* mpath component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG)) {
-		if ((filters[nr_filt] = mpath_filter_create()))
+		if ((filters[nr_filt] = mpath_filter_create(cmd->dev_types)))
 			nr_filt++;
 	}
 
@@ -898,7 +897,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	if (!dev_cache)
 		dev_cache = cache_file;
 
-	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
+	if (!(f4 = persistent_filter_create(cmd->dev_types, f3, dev_cache))) {
 		log_verbose("Failed to create persistent device filter.");
 		f3->destroy(f3);
 		return_0;
@@ -1451,6 +1450,10 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_process_config(cmd))
 		goto_out;
 
+	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
+						find_config_tree_node(cmd, devices_types_CFG))))
+		goto_out;
+
 	if (!_init_dev_cache(cmd))
 		goto_out;
 
@@ -1541,6 +1544,15 @@ skip_dlclose:
 	}
 }
 
+static void _destroy_dev_types(struct cmd_context *cmd)
+{
+	if (!cmd->dev_types)
+		return;
+
+	dm_free(cmd->dev_types);
+	cmd->dev_types = NULL;
+}
+
 int refresh_filters(struct cmd_context *cmd)
 {
 	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
@@ -1584,6 +1596,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 		cmd->filter = NULL;
 	}
 	dev_cache_exit();
+	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
 
 	cft_cmdline = _destroy_tag_configs(cmd);
@@ -1623,6 +1636,10 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_process_config(cmd))
 		return 0;
 
+	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
+						find_config_tree_node(cmd, devices_types_CFG))))
+		return 0;
+
 	if (!_init_dev_cache(cmd))
 		return 0;
 
@@ -1667,6 +1684,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->mem)
 		dm_pool_destroy(cmd->mem);
 	dev_cache_exit();
+	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
 
 	if ((cft_cmdline = _destroy_tag_configs(cmd)))
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 307dc77..f6a09a7 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -17,6 +17,7 @@
 #define _LVM_TOOLCONTEXT_H
 
 #include "dev-cache.h"
+#include "dev-type.h"
 
 #include <stdio.h>
 #include <limits.h>
@@ -91,6 +92,7 @@ struct cmd_context {
 
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 
+	struct dev_types *dev_types;
 	struct dev_filter *filter;
 	struct dev_filter *lvmetad_filter;
 	int dump_filter;	/* Dump filter when exiting? */
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 0933549..9981967 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -18,6 +18,7 @@
 #include "lvm-types.h"
 #include "btree.h"
 #include "filter.h"
+#include "config.h"
 #include "toolcontext.h"
 
 #include <unistd.h>
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 10aae30..2c79a2b 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -13,6 +13,7 @@
  */
 
 #include "lib.h"
+#include "dev-type.h"
 #include "metadata.h"
 
 #define LUKS_SIGNATURE "LUKS\xba\xbe"
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index c4e2316..a8bbe81 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -14,9 +14,9 @@
  */
 
 #include "lib.h"
+#include "dev-type.h"
 #include "metadata.h"
 #include "xlate.h"
-#include "filter.h"
 
 #ifdef linux
 
@@ -127,6 +127,7 @@ out:
 }
 
 static int _md_sysfs_attribute_snprintf(char *path, size_t size,
+					struct dev_types *dt,
 					struct device *blkdev,
 					const char *attribute)
 {
@@ -138,13 +139,13 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 	if (!sysfs_dir || !*sysfs_dir)
 		return ret;
 
-	if (MAJOR(dev) == blkext_major()) {
+	if (MAJOR(dev) == dt->blkext_major) {
 		/* lookup parent MD device from blkext partition */
-		if (!get_primary_dev(blkdev, &dev))
+		if (!dev_get_primary_dev(dt, blkdev, &dev))
 			return ret;
 	}
 
-	if (MAJOR(dev) != md_major())
+	if (MAJOR(dev) != dt->md_major)
 		return ret;
 
 	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s", sysfs_dir,
@@ -171,7 +172,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 	return ret;
 }
 
-static int _md_sysfs_attribute_scanf(const char *sysfs_dir,
+static int _md_sysfs_attribute_scanf(struct dev_types *dt,
 				     struct device *dev,
 				     const char *attribute_name,
 				     const char *attribute_fmt,
@@ -181,8 +182,8 @@ static int _md_sysfs_attribute_scanf(const char *sysfs_dir,
 	FILE *fp;
 	int ret = 0;
 
-	if (_md_sysfs_attribute_snprintf(path, PATH_MAX, dev,
-					 attribute_name) < 0)
+	if (_md_sysfs_attribute_snprintf(path, PATH_MAX, dt,
+					 dev, attribute_name) < 0)
 		return ret;
 
 	if (!(fp = fopen(path, "r"))) {
@@ -211,13 +212,13 @@ out:
 /*
  * Retrieve chunk size from md device using sysfs.
  */
-static unsigned long dev_md_chunk_size(const char *sysfs_dir,
+static unsigned long dev_md_chunk_size(struct dev_types *dt,
 				       struct device *dev)
 {
 	const char *attribute = "chunk_size";
 	unsigned long chunk_size_bytes = 0UL;
 
-	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
+	if (_md_sysfs_attribute_scanf(dt, dev, attribute,
 				      "%lu", &chunk_size_bytes) != 1)
 		return 0;
 
@@ -230,13 +231,13 @@ static unsigned long dev_md_chunk_size(const char *sysfs_dir,
 /*
  * Retrieve level from md device using sysfs.
  */
-static int dev_md_level(const char *sysfs_dir, struct device *dev)
+static int dev_md_level(struct dev_types *dt, struct device *dev)
 {
 	char level_string[MD_MAX_SYSFS_SIZE];
 	const char *attribute = "level";
 	int level = -1;
 
-	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
+	if (_md_sysfs_attribute_scanf(dt, dev, attribute,
 				      "%s", &level_string) != 1)
 		return -1;
 
@@ -253,12 +254,12 @@ static int dev_md_level(const char *sysfs_dir, struct device *dev)
 /*
  * Retrieve raid_disks from md device using sysfs.
  */
-static int dev_md_raid_disks(const char *sysfs_dir, struct device *dev)
+static int dev_md_raid_disks(struct dev_types *dt, struct device *dev)
 {
 	const char *attribute = "raid_disks";
 	int raid_disks = 0;
 
-	if (_md_sysfs_attribute_scanf(sysfs_dir, dev, attribute,
+	if (_md_sysfs_attribute_scanf(dt, dev, attribute,
 				      "%d", &raid_disks) != 1)
 		return 0;
 
@@ -271,22 +272,21 @@ static int dev_md_raid_disks(const char *sysfs_dir, struct device *dev)
 /*
  * Calculate stripe width of md device using its sysfs files.
  */
-unsigned long dev_md_stripe_width(struct device *dev)
+unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev)
 {
-	const char *sysfs_dir = dm_sysfs_dir();
 	unsigned long chunk_size_sectors = 0UL;
 	unsigned long stripe_width_sectors = 0UL;
 	int level, raid_disks, data_disks;
 
-	chunk_size_sectors = dev_md_chunk_size(sysfs_dir, dev);
+	chunk_size_sectors = dev_md_chunk_size(dt, dev);
 	if (!chunk_size_sectors)
 		return 0;
 
-	level = dev_md_level(sysfs_dir, dev);
+	level = dev_md_level(dt, dev);
 	if (level < 0)
 		return 0;
 
-	raid_disks = dev_md_raid_disks(sysfs_dir, dev);
+	raid_disks = dev_md_raid_disks(dt, dev);
 	if (!raid_disks)
 		return 0;
 
@@ -333,7 +333,8 @@ int dev_is_md(struct device *dev __attribute__((unused)),
 	return 0;
 }
 
-unsigned long dev_md_stripe_width(struct device *dev  __attribute__((unused)))
+unsigned long dev_md_stripe_width(struct dev_types *dt __attribute__((unused)),
+				  struct device *dev __attribute__((unused)))
 {
 	return 0UL;
 }
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 346b60a..c3b121b 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -13,6 +13,7 @@
  */
 
 #include "lib.h"
+#include "dev-type.h"
 #include "metadata.h"
 
 #ifdef linux
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 52eb4a6..150daf4 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1,6 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -14,16 +13,240 @@
  */
 
 #include "lib.h"
-#include "lvm-types.h"
-#include "device.h"
-#include "metadata.h"
-#include "filter.h"
+#include "dev-type.h"
 #include "xlate.h"
+#include "config.h"
+#include "metadata.h"
 
-#include <libgen.h> /* dirname, basename */
+#include <libgen.h>
+#include <ctype.h>
 
-/* See linux/genhd.h and fs/partitions/msdos */
+#include "device-types.h"
+
+struct dev_types *create_dev_types(const char *proc_dir,
+				   const struct dm_config_node *cn)
+{
+	struct dev_types *dt;
+	char line[80];
+	char proc_devices[PATH_MAX];
+	FILE *pd = NULL;
+	int i, j = 0;
+	int line_maj = 0;
+	int blocksection = 0;
+	size_t dev_len = 0;
+	const struct dm_config_value *cv;
+	const char *name;
+	char *nl;
+
+	if (!(dt = dm_zalloc(sizeof(struct dev_types)))) {
+		log_error("Failed to allocate device type register.");
+		return NULL;
+	}
+
+	if (!*proc_dir) {
+		log_verbose("No proc filesystem found: using all block device types");
+		for (i = 0; i < NUMBER_OF_MAJORS; i++)
+			dt->dev_type_array[i].max_partitions = 1;
+		return dt;
+	}
+
+	if (dm_snprintf(proc_devices, sizeof(proc_devices),
+			 "%s/devices", proc_dir) < 0) {
+		log_error("Failed to create /proc/devices string");
+		goto bad;
+	}
+
+	if (!(pd = fopen(proc_devices, "r"))) {
+		log_sys_error("fopen", proc_devices);
+		goto bad;
+	}
+
+	while (fgets(line, sizeof(line), pd) != NULL) {
+		i = 0;
+		while (line[i] == ' ')
+			i++;
+
+		/* If it's not a number it may be name of section */
+		line_maj = atoi(((char *) (line + i)));
+
+		if (line_maj < 0 || line_maj >= NUMBER_OF_MAJORS) {
+			/*
+			 * Device numbers shown in /proc/devices are actually direct
+			 * numbers passed to registering function, however the kernel
+			 * uses only 12 bits, so use just 12 bits for major.
+			 */
+			if ((nl = strchr(line, '\n'))) *nl = '\0';
+			log_warn("WARNING: /proc/devices line: %s, replacing major with %d.",
+				 line, line_maj & (NUMBER_OF_MAJORS - 1));
+			line_maj &= (NUMBER_OF_MAJORS - 1);
+		}
+
+		if (!line_maj) {
+			blocksection = (line[i] == 'B') ? 1 : 0;
+			continue;
+		}
+
+		/* We only want block devices ... */
+		if (!blocksection)
+			continue;
+
+		/* Find the start of the device major name */
+		while (line[i] != ' ' && line[i] != '\0')
+			i++;
+		while (line[i] == ' ')
+			i++;
+
+		/* Look for md device */
+		if (!strncmp("md", line + i, 2) && isspace(*(line + i + 2)))
+			dt->md_major = line_maj;
+
+		/* Look for blkext device */
+		if (!strncmp("blkext", line + i, 6) && isspace(*(line + i + 6)))
+			dt->blkext_major = line_maj;
+
+		/* Look for drbd device */
+		if (!strncmp("drbd", line + i, 4) && isspace(*(line + i + 4)))
+			dt->drbd_major = line_maj;
+
+		/* Look for EMC powerpath */
+		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
+			dt->emcpower_major = line_maj;
+
+		if (!strncmp("power2", line + i, 6) && isspace(*(line + i + 6)))
+			dt->power2_major = line_maj;
+
+		/* Look for device-mapper device */
+		/* FIXME Cope with multiple majors */
+		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
+			dt->device_mapper_major = line_maj;
+
+		/* Major is SCSI device */
+		if (!strncmp("sd", line + i, 2) && isspace(*(line + i + 2)))
+			dt->dev_type_array[line_maj].flags |= PARTITION_SCSI_DEVICE;
+
+		/* Go through the valid device names and if there is a
+		   match store max number of partitions */
+		for (j = 0; _dev_known_types[j].name[0]; j++) {
+			dev_len = strlen(_dev_known_types[j].name);
+			if (dev_len <= strlen(line + i) &&
+			    !strncmp(_dev_known_types[j].name, line + i, dev_len) &&
+			    (line_maj < NUMBER_OF_MAJORS)) {
+				dt->dev_type_array[line_maj].max_partitions =
+					_dev_known_types[j].max_partitions;
+				break;
+			}
+		}
+
+		if (!cn)
+			continue;
+
+		/* Check devices/types for local variations */
+		for (cv = cn->v; cv; cv = cv->next) {
+			if (cv->type != DM_CFG_STRING) {
+				log_error("Expecting string in devices/types "
+					  "in config file");
+				if (fclose(pd))
+					log_sys_error("fclose", proc_devices);
+				goto bad;
+			}
+			dev_len = strlen(cv->v.str);
+			name = cv->v.str;
+			cv = cv->next;
+			if (!cv || cv->type != DM_CFG_INT) {
+				log_error("Max partition count missing for %s "
+					  "in devices/types in config file",
+					  name);
+				if (fclose(pd))
+					log_sys_error("fclose", proc_devices);
+				goto bad;
+			}
+			if (!cv->v.i) {
+				log_error("Zero partition count invalid for "
+					  "%s in devices/types in config file",
+					  name);
+				if (fclose(pd))
+					log_sys_error("fclose", proc_devices);
+				goto bad;
+			}
+			if (dev_len <= strlen(line + i) &&
+			    !strncmp(name, line + i, dev_len) &&
+			    (line_maj < NUMBER_OF_MAJORS)) {
+				dt->dev_type_array[line_maj].max_partitions = cv->v.i;
+				break;
+			}
+		}
+	}
+
+	if (fclose(pd))
+		log_sys_error("fclose", proc_devices);
+
+	return dt;
+bad:
+	dm_free(dt);
+	return NULL;
+}
+
+int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
+{
+	dev_t primary_dev;
+
+	if (MAJOR(dev->dev) == dt->device_mapper_major)
+		return 1;
+
+	if (MAJOR(dev->dev) == dt->drbd_major)
+		return 1;
+
+	if (MAJOR(dev->dev) == dt->emcpower_major)
+		return 1;
+
+	if (MAJOR(dev->dev) == dt->power2_major)
+		return 1;
 
+	if ((MAJOR(dev->dev) == dt->blkext_major) &&
+	    (dev_get_primary_dev(dt, dev, &primary_dev)) &&
+	    (MAJOR(primary_dev) == dt->md_major))
+		return 1;
+
+	return 0;
+}
+
+const char *dev_subsystem_name(struct dev_types *dt, struct device *dev)
+{
+	if (MAJOR(dev->dev) == dt->md_major)
+		return "MD";
+
+	if (MAJOR(dev->dev) == dt->drbd_major)
+		return "DRBD";
+
+	if (MAJOR(dev->dev) == dt->emcpower_major)
+		return "EMCPOWER";
+
+	if (MAJOR(dev->dev) == dt->power2_major)
+		return "POWER2";
+
+	if (MAJOR(dev->dev) == dt->blkext_major)
+		return "BLKEXT";
+
+	return "";
+}
+
+int major_max_partitions(struct dev_types *dt, int major)
+{
+	if (major >= NUMBER_OF_MAJORS)
+		return 0;
+
+	return dt->dev_type_array[major].max_partitions;
+}
+
+int major_is_scsi_device(struct dev_types *dt, int major)
+{
+	if (major >= NUMBER_OF_MAJORS)
+		return 0;
+
+	return (dt->dev_type_array[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
+}
+
+/* See linux/genhd.h and fs/partitions/msdos */
 #define PART_MAGIC 0xAA55
 #define PART_MAGIC_OFFSET UINT64_C(0x1FE)
 #define PART_OFFSET UINT64_C(0x1BE)
@@ -41,12 +264,12 @@ struct partition {
 	uint32_t nr_sects;
 } __attribute__((packed));
 
-static int _is_partitionable(struct device *dev)
+static int _is_partitionable(struct dev_types *dt, struct device *dev)
 {
-	int parts = max_partitions(MAJOR(dev->dev));
+	int parts = major_max_partitions(dt, MAJOR(dev->dev));
 
 	/* All MD devices are partitionable via blkext (as of 2.6.28) */
-	if (MAJOR(dev->dev) == md_major())
+	if (MAJOR(dev->dev) == dt->md_major)
 		return 1;
 
 	if ((parts <= 1) || (MINOR(dev->dev) % parts))
@@ -87,14 +310,93 @@ static int _has_partition_table(struct device *dev)
 	return ret;
 }
 
-int is_partitioned_dev(struct device *dev)
+int dev_is_partitioned(struct dev_types *dt, struct device *dev)
 {
-	if (!_is_partitionable(dev))
+	if (!_is_partitionable(dt, dev))
 		return 0;
 
 	return _has_partition_table(dev);
 }
 
+int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
+{
+	const char *sysfs_dir = dm_sysfs_dir();
+	char path[PATH_MAX+1];
+	char temp_path[PATH_MAX+1];
+	char buffer[64];
+	struct stat info;
+	FILE *fp;
+	uint32_t pri_maj, pri_min;
+	int size, ret = 0;
+
+	/* check if dev is a partition */
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
+			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
+		log_error("dm_snprintf partition failed");
+		return ret;
+	}
+
+	if (stat(path, &info) == -1) {
+		if (errno != ENOENT)
+			log_sys_error("stat", path);
+		return ret;
+	}
+
+	/*
+	 * extract parent's path from the partition's symlink, e.g.:
+	 * - readlink /sys/dev/block/259:0 = ../../block/md0/md0p1
+	 * - dirname ../../block/md0/md0p1 = ../../block/md0
+	 * - basename ../../block/md0/md0  = md0
+	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
+	 */
+	if ((size = readlink(dirname(path), temp_path, PATH_MAX)) < 0) {
+		log_sys_error("readlink", path);
+		return ret;
+	}
+
+	temp_path[size] = '\0';
+
+	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/dev",
+			sysfs_dir, basename(dirname(temp_path))) < 0) {
+		log_error("dm_snprintf dev failed");
+		return ret;
+	}
+
+	/* finally, parse 'dev' attribute and create corresponding dev_t */
+	if (stat(path, &info) == -1) {
+		if (errno == ENOENT)
+			log_error("sysfs file %s does not exist", path);
+		else
+			log_sys_error("stat", path);
+		return ret;
+	}
+
+	fp = fopen(path, "r");
+	if (!fp) {
+		log_sys_error("fopen", path);
+		return ret;
+	}
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", path);
+		goto out;
+	}
+
+	if (sscanf(buffer, "%d:%d", &pri_maj, &pri_min) != 2) {
+		log_error("sysfs file %s not in expected MAJ:MIN format: %s",
+			  path, buffer);
+		goto out;
+	}
+	*result = MKDEV((dev_t)pri_maj, pri_min);
+	ret = 1;
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return ret;
+}
+
 #if 0
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -278,86 +580,9 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 
 #ifdef linux
 
-int get_primary_dev(const struct device *dev, dev_t *result)
-{
-	const char *sysfs_dir = dm_sysfs_dir();
-	char path[PATH_MAX+1];
-	char temp_path[PATH_MAX+1];
-	char buffer[64];
-	struct stat info;
-	FILE *fp;
-	uint32_t pri_maj, pri_min;
-	int size, ret = 0;
-
-	/* check if dev is a partition */
-	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
-			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
-		log_error("dm_snprintf partition failed");
-		return ret;
-	}
-
-	if (stat(path, &info) == -1) {
-		if (errno != ENOENT)
-			log_sys_error("stat", path);
-		return ret;
-	}
-
-	/*
-	 * extract parent's path from the partition's symlink, e.g.:
-	 * - readlink /sys/dev/block/259:0 = ../../block/md0/md0p1
-	 * - dirname ../../block/md0/md0p1 = ../../block/md0
-	 * - basename ../../block/md0/md0  = md0
-	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
-	 */
-	if ((size = readlink(dirname(path), temp_path, PATH_MAX)) < 0) {
-		log_sys_error("readlink", path);
-		return ret;
-	}
-
-	temp_path[size] = '\0';
-
-	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/dev",
-			sysfs_dir, basename(dirname(temp_path))) < 0) {
-		log_error("dm_snprintf dev failed");
-		return ret;
-	}
-
-	/* finally, parse 'dev' attribute and create corresponding dev_t */
-	if (stat(path, &info) == -1) {
-		if (errno == ENOENT)
-			log_error("sysfs file %s does not exist", path);
-		else
-			log_sys_error("stat", path);
-		return ret;
-	}
-
-	fp = fopen(path, "r");
-	if (!fp) {
-		log_sys_error("fopen", path);
-		return ret;
-	}
-
-	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_sys_error("fgets", path);
-		goto out;
-	}
-
-	if (sscanf(buffer, "%d:%d", &pri_maj, &pri_min) != 2) {
-		log_error("sysfs file %s not in expected MAJ:MIN format: %s",
-			  path, buffer);
-		goto out;
-	}
-	*result = MKDEV((dev_t)pri_maj, pri_min);
-	ret = 1;
-
-out:
-	if (fclose(fp))
-		log_sys_error("fclose", path);
-
-	return ret;
-}
-
-static unsigned long _dev_topology_attribute(const char *attribute, struct device *dev)
+static unsigned long _dev_topology_attribute(struct dev_types *dt,
+					     const char *attribute,
+					     struct device *dev)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
 	static const char sysfs_fmt_str[] = "%s/dev/block/%d:%d/%s";
@@ -390,7 +615,7 @@ static unsigned long _dev_topology_attribute(const char *attribute, struct devic
 			log_sys_error("stat", path);
 			return 0;
 		}
-		if (!get_primary_dev(dev, &primary))
+		if (!dev_get_primary_dev(dt, dev, &primary))
 			return 0;
 
 		/* get attribute from partition's primary device */
@@ -433,29 +658,29 @@ out:
 	return result >> SECTOR_SHIFT;
 }
 
-unsigned long dev_alignment_offset(struct device *dev)
+unsigned long dev_alignment_offset(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute("alignment_offset", dev);
+	return _dev_topology_attribute(dt, "alignment_offset", dev);
 }
 
-unsigned long dev_minimum_io_size(struct device *dev)
+unsigned long dev_minimum_io_size(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute("queue/minimum_io_size", dev);
+	return _dev_topology_attribute(dt, "queue/minimum_io_size", dev);
 }
 
-unsigned long dev_optimal_io_size(struct device *dev)
+unsigned long dev_optimal_io_size(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute("queue/optimal_io_size", dev);
+	return _dev_topology_attribute(dt, "queue/optimal_io_size", dev);
 }
 
-unsigned long dev_discard_max_bytes(struct device *dev)
+unsigned long dev_discard_max_bytes(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute("queue/discard_max_bytes", dev);
+	return _dev_topology_attribute(dt, "queue/discard_max_bytes", dev);
 }
 
-unsigned long dev_discard_granularity(struct device *dev)
+unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute("queue/discard_granularity", dev);
+	return _dev_topology_attribute(dt, "queue/discard_granularity", dev);
 }
 
 #else
@@ -465,27 +690,27 @@ int get_primary_dev(struct device *dev, dev_t *result)
 	return 0;
 }
 
-unsigned long dev_alignment_offset(struct device *dev)
+unsigned long dev_alignment_offset(struct dev_types *dt, struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_minimum_io_size(struct device *dev)
+unsigned long dev_minimum_io_size(struct dev_types *dt, struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_optimal_io_size(struct device *dev)
+unsigned long dev_optimal_io_size(struct dev_types *dt, struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_discard_max_bytes(struct device *dev)
+unsigned long dev_discard_max_bytes(struct dev_types *dt, struct device *dev)
 {
 	return 0UL;
 }
 
-unsigned long dev_discard_granularity(struct device *dev)
+unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev)
 {
 	return 0UL;
 }
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
new file mode 100644
index 0000000..1227ab0
--- /dev/null
+++ b/lib/device/dev-type.h
@@ -0,0 +1,76 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DEV_TYPE_H
+#define _LVM_DEV_TYPE_H
+
+#include "device.h"
+
+#define NUMBER_OF_MAJORS 4096
+
+#ifdef linux
+#  define MAJOR(dev)	((dev & 0xfff00) >> 8)
+#  define MINOR(dev)	((dev & 0xff) | ((dev >> 12) & 0xfff00))
+#  define MKDEV(ma,mi)	((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
+#else
+#  define MAJOR(x) major((x))
+#  define MINOR(x) minor((x))
+#  define MKDEV(x,y) makedev((x),(y))
+#endif
+
+#define PARTITION_SCSI_DEVICE (1 << 0)
+
+struct dev_type_def {
+	int max_partitions; /* 0 means LVM won't use this major number. */
+	int flags;
+};
+
+struct dev_types {
+	int md_major;
+	int blkext_major;
+	int drbd_major;
+	int device_mapper_major;
+	int emcpower_major;
+	int power2_major;
+	struct dev_type_def dev_type_array[NUMBER_OF_MAJORS];
+};
+
+struct dev_types *create_dev_types(const char *proc_dir, const struct dm_config_node *cn);
+
+/* Subsystems */
+int dev_subsystem_part_major(struct dev_types *dt, struct device *dev);
+const char *dev_subsystem_name(struct dev_types *dt, struct device *dev);
+int major_is_scsi_device(struct dev_types *dt, int major);
+
+/* Signature/superblock recognition with position returned where found. */
+int dev_is_md(struct device *dev, uint64_t *sb);
+int dev_is_swap(struct device *dev, uint64_t *signature);
+int dev_is_luks(struct device *dev, uint64_t *signature);
+
+/* Type-specific device properties */
+unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
+
+/* Partitioning */
+int major_max_partitions(struct dev_types *dt, int major);
+int dev_is_partitioned(struct dev_types *dt, struct device *dev);
+int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result);
+
+/* Various device properties */
+unsigned long dev_alignment_offset(struct dev_types *dt, struct device *dev);
+unsigned long dev_minimum_io_size(struct dev_types *dt, struct device *dev);
+unsigned long dev_optimal_io_size(struct dev_types *dt, struct device *dev);
+unsigned long dev_discard_max_bytes(struct dev_types *dt, struct device *dev);
+unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev);
+
+#endif
diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 2e49f7f..48ae32a 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,7 +16,8 @@
 typedef struct {
 	const char name[15];
 	const int8_t max_partitions;
-} device_info_t;
+	const char *desc;
+} dev_known_type_t;
 
 /*
  * Devices are only checked for partition tables if their minor number
@@ -26,38 +27,38 @@ typedef struct {
  *
  * The list can be supplemented with devices/types in the config file.
  */
-static const device_info_t _device_info[] = {
-	{"ide", 64},		/* IDE disk */
-	{"sd", 16},		/* SCSI disk */
-	{"md", 1},		/* Multiple Disk driver (SoftRAID) */
-	{"mdp", 1},		/* Partitionable MD */
-	{"loop", 1},		/* Loop device */
-	{"dasd", 4},		/* DASD disk (IBM S/390, zSeries) */
-	{"dac960", 8},		/* DAC960 */
-	{"nbd", 16},		/* Network Block Device */
-	{"ida", 16},		/* Compaq SMART2 */
-	{"cciss", 16},		/* Compaq CCISS array */
-	{"ubd", 16},		/* User-mode virtual block device */
-	{"ataraid", 16},	/* ATA Raid */
-	{"drbd", 16},		/* Distributed Replicated Block Device */
-	{"emcpower", 16},	/* EMC Powerpath */
-	{"power2", 16},		/* EMC Powerpath */
-	{"i2o_block", 16},	/* i2o Block Disk */
-	{"iseries/vd", 8},	/* iSeries disks */
-	{"gnbd", 1},		/* Network block device */
-	{"ramdisk", 1},		/* RAM disk */
-	{"aoe", 16},		/* ATA over Ethernet */
-	{"device-mapper", 1},	/* Other mapped devices */
-	{"xvd", 16},		/* Xen virtual block device */
-	{"vdisk", 8},		/* SUN's LDOM virtual block device */
-	{"ps3disk", 16},	/* PlayStation 3 internal disk */
-	{"virtblk", 8},		/* VirtIO disk */
-	{"mmc", 16},		/* MMC block device */
-	{"blkext", 1},		/* Extended device partitions */
-	{"fio", 16},		/* Fusion */
-	{"mtip32xx", 16},	/* Micron PCIe SSDs */
-	{"vtms", 16},		/* Violin Memory */
-	{"skd", 16},		/* STEC */
-	{"scm", 8},		/* Storage Class Memory (IBM S/390) */
-	{"", 0}
+static const dev_known_type_t _dev_known_types[] = {
+	{"ide", 64, "IDE disk"},
+	{"sd", 16, "SCSI disk"},
+	{"md", 1, "Multiple Disk (MD/SoftRAID)"},
+	{"mdp", 1, "Partitionable MD"},
+	{"loop", 1, "Loop device"},
+	{"dasd", 4, "DASD disk (IBM S/390, zSeries)"},
+	{"dac960", 8, "DAC960"},
+	{"nbd", 16, "Network Block Device"},
+	{"ida", 16, "Compaq SMART2"},
+	{"cciss", 16, "Compaq CCISS array"},
+	{"ubd", 16, "User-mode virtual block device"},
+	{"ataraid", 16, "ATA Raid"},
+	{"drbd", 16, "Distributed Replicated Block Device (DRBD)"},
+	{"emcpower", 16, "EMC Powerpath"},
+	{"power2", 16, "EMC Powerpath"},
+	{"i2o_block", 16, "i2o Block Disk"},
+	{"iseries/vd", 8, "iSeries disks"},
+	{"gnbd", 1, "Network block device"},
+	{"ramdisk", 1, "RAM disk"},
+	{"aoe", 16, "ATA over Ethernet"},
+	{"device-mapper", 1, "Mapped device"},
+	{"xvd", 16, "Xen virtual block device"},
+	{"vdisk", 8, "SUN's LDOM virtual block device"},
+	{"ps3disk", 16, "PlayStation 3 internal disk"},
+	{"virtblk", 8, "VirtIO disk"},
+	{"mmc", 16, "MMC block device"},
+	{"blkext", 1, "Extended device partitions"},
+	{"fio", 16, "Fusion IO"},
+	{"mtip32xx", 16, "Micron PCIe SSD"},
+	{"vtms", 16, "Violin Memory"},
+	{"skd", 16, "STEC"},
+	{"scm", 8, "Storage Class Memory (IBM S/390)"},
+	{"", 0, ""}
 };
diff --git a/lib/device/device.h b/lib/device/device.h
index 025d4ca..1d6304d 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -99,20 +99,4 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);
 
-/* Does device contain md superblock?  If so, where? */
-int dev_is_md(struct device *dev, uint64_t *sb);
-int dev_is_swap(struct device *dev, uint64_t *signature);
-int dev_is_luks(struct device *dev, uint64_t *signature);
-unsigned long dev_md_stripe_width(struct device *dev);
-
-int is_partitioned_dev(struct device *dev);
-
-int get_primary_dev(const struct device *dev, dev_t *result);
-
-unsigned long dev_alignment_offset(struct device *dev);
-unsigned long dev_minimum_io_size(struct device *dev);
-unsigned long dev_optimal_io_size(struct device *dev);
-unsigned long dev_discard_max_bytes(struct device *dev);
-unsigned long dev_discard_granularity(struct device *dev);
-
 #endif
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index c2b103d..47d147e 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -16,8 +16,6 @@
 #include "lib.h"
 #include "filter-composite.h"
 
-#include <stdarg.h>
-
 static int _and_p(struct dev_filter *f, struct device *dev)
 {
 	struct dev_filter **filters;
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 6f289b0..b18cd07 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -50,7 +50,7 @@ static void _destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-struct dev_filter *md_filter_create(void)
+struct dev_filter *md_filter_create(struct dev_types *dt)
 {
 	struct dev_filter *f;
 
@@ -62,14 +62,14 @@ struct dev_filter *md_filter_create(void)
 	f->passes_filter = _ignore_md;
 	f->destroy = _destroy;
 	f->use_count = 0;
-	f->private = NULL;
+	f->private = dt;
 
 	return f;
 }
 
 #else
 
-struct dev_filter *md_filter_create(void)
+struct dev_filter *md_filter_create(struct dev_types *dt)
 {
 	return NULL;
 }
diff --git a/lib/filters/filter-md.h b/lib/filters/filter-md.h
index 6a98f0b..79e4f0e 100644
--- a/lib/filters/filter-md.h
+++ b/lib/filters/filter-md.h
@@ -16,8 +16,9 @@
 #define _LVM_FILTER_MD_H
 
 #include "dev-cache.h"
+#include "dev-type.h"
 
-struct dev_filter *md_filter_create(void);
+struct dev_filter *md_filter_create(struct dev_types *dt);
 
 #endif
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index f3af268..0e88e65 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -13,11 +13,11 @@
  */
 
 #include "lib.h"
-#include "filter.h"
 #include "filter-mpath.h"
 #include "activate.h"
 
 #ifdef linux
+
 #include <dirent.h>
 
 #define MPATH_PREFIX "mpath-"
@@ -115,15 +115,17 @@ static int get_parent_mpath(const char *dir, char *name, int max_size)
 
 static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 {
+	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *name;
 	char path[PATH_MAX+1];
 	char parent_name[PATH_MAX+1];
 	struct stat info;
 	const char *sysfs_dir = dm_sysfs_dir();
-	int major, minor;
+	int major = MAJOR(dev->dev);
+	int minor = MINOR(dev->dev);
 
 	/* Limit this filter only to SCSI devices */
-	if (!major_is_scsi_device(MAJOR(dev->dev)))
+	if (!major_is_scsi_device(dt, MAJOR(dev->dev)))
 		return 0;
 
 	if (!(name = get_sysfs_name(dev)))
@@ -149,8 +151,9 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 	if (!get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
 		return_0;
 
-	if (major != dm_major()) {
-		log_error("mpath major %d is not dm major %d.", major, dm_major());
+	if (major != dt->device_mapper_major) {
+		log_error("mpath major %d is not dm major %d.", major,
+			  dt->device_mapper_major);
 		return 0;
 	}
 
@@ -172,11 +175,10 @@ static void _destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
 
-	dm_free(f->private);
 	dm_free(f);
 }
 
-struct dev_filter *mpath_filter_create(void)
+struct dev_filter *mpath_filter_create(struct dev_types *dt)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
 	struct dev_filter *f;
@@ -194,19 +196,14 @@ struct dev_filter *mpath_filter_create(void)
 	f->passes_filter = _ignore_mpath;
 	f->destroy = _destroy;
 	f->use_count = 0;
-
-	if (!(f->private = dm_strdup(sysfs_dir))) {
-		log_error("Cannot duplicate sysfs dir.");
-		dm_free(f);
-		return NULL;
-	}
+	f->private = dt;
 
 	return f;
 }
 
 #else
 
-struct dev_filter *mpath_filter_create(const char *sysfs_dir __attribute__((unused)))
+struct dev_filter *mpath_filter_create(struct device_types *dt)
 {
 	return NULL;
 }
diff --git a/lib/filters/filter-mpath.h b/lib/filters/filter-mpath.h
index 31585eb..5665f3b 100644
--- a/lib/filters/filter-mpath.h
+++ b/lib/filters/filter-mpath.h
@@ -16,8 +16,9 @@
 #define _LVM_FILTER_MPATH_H
 
 #include "dev-cache.h"
+#include "dev-type.h"
 
-struct dev_filter *mpath_filter_create(void);
+struct dev_filter *mpath_filter_create(struct dev_types *dt);
 
 #endif
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 799e7d8..a59529d 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -14,23 +14,17 @@
  */
 
 #include "lib.h"
-#include "config.h"
-#include "dev-cache.h"
-#include "filter.h"
 #include "filter-persistent.h"
+#include "config.h"
 #include "lvm-file.h"
-#include "lvm-string.h"
 #include "activate.h"
 
-#include <sys/stat.h>
-#include <fcntl.h>
-#include <unistd.h>
-
 struct pfilter {
 	char *file;
 	struct dm_hash_table *devices;
 	struct dev_filter *real;
 	time_t ctime;
+	struct dev_types *dt;
 };
 
 /*
@@ -287,7 +281,7 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 	}
 
 	/* Test dm devices every time, so cache them as GOOD. */
-	if (MAJOR(dev->dev) == dm_major()) {
+	if (MAJOR(dev->dev) == pf->dt->device_mapper_major) {
 		if (!l)
 			dm_list_iterate_items(sl, &dev->aliases)
 				if (!dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE)) {
@@ -329,7 +323,8 @@ static void _persistent_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-struct dev_filter *persistent_filter_create(struct dev_filter *real,
+struct dev_filter *persistent_filter_create(struct dev_types *dt,
+					    struct dev_filter *real,
 					    const char *file)
 {
 	struct pfilter *pf;
@@ -341,6 +336,8 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 		return NULL;
 	}
 
+	pf->dt = dt;
+
 	if (!(pf->file = dm_strdup(file))) {
 		log_error("Filename duplication for persistent filter failed.");
 		goto bad;
diff --git a/lib/filters/filter-persistent.h b/lib/filters/filter-persistent.h
index 58fbc10..bdbf887 100644
--- a/lib/filters/filter-persistent.h
+++ b/lib/filters/filter-persistent.h
@@ -17,8 +17,10 @@
 #define _LVM_FILTER_PERSISTENT_H
 
 #include "dev-cache.h"
+#include "dev-type.h"
 
-struct dev_filter *persistent_filter_create(struct dev_filter *f,
+struct dev_filter *persistent_filter_create(struct dev_types *dt,
+					    struct dev_filter *f,
 					    const char *file);
 
 int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 7172c93..4fe9a7a 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "filter-regex.h"
-#include "device.h"
 
 struct rfilter {
 	struct dm_pool *mem;
diff --git a/lib/filters/filter-regex.h b/lib/filters/filter-regex.h
index bb71f56..de05206 100644
--- a/lib/filters/filter-regex.h
+++ b/lib/filters/filter-regex.h
@@ -16,7 +16,6 @@
 #ifndef _LVM_FILTER_REGEX_H
 #define _LVM_FILTER_REGEX_H
 
-#include "config.h"
 #include "dev-cache.h"
 
 /*
diff --git a/lib/filters/filter-sysfs.h b/lib/filters/filter-sysfs.h
index 6fb5591..4b26ea6 100644
--- a/lib/filters/filter-sysfs.h
+++ b/lib/filters/filter-sysfs.h
@@ -15,7 +15,6 @@
 #ifndef _LVM_FILTER_SYSFS_H
 #define _LVM_FILTER_SYSFS_H
 
-#include "config.h"
 #include "dev-cache.h"
 
 struct dev_filter *sysfs_filter_create(void);
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index a86b398..cf06f88 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -14,104 +14,21 @@
  */
 
 #include "lib.h"
-#include "dev-cache.h"
 #include "filter.h"
 #include "lvm-string.h"
 #include "config.h"
 #include "metadata.h"
 #include "activate.h"
 
-#include <dirent.h>
-#include <unistd.h>
-#include <ctype.h>
-#include <fcntl.h>
-#include <limits.h>
-
-#include "device/device-types.h"
-
-#define NUMBER_OF_MAJORS 4096
-
-#define PARTITION_SCSI_DEVICE (1 << 0)
-static struct {
-	int max_partitions; /* 0 means LVM won't use this major number. */
-	int flags;
-} _partitions[NUMBER_OF_MAJORS];
-
-static int _md_major = -1;
-static int _blkext_major = -1;
-static int _drbd_major = -1;
-static int _device_mapper_major = -1;
-static int _emcpower_major = -1;
-static int _power2_major = -1;
-
-int dm_major(void)
-{
-	return _device_mapper_major;
-}
-
-int md_major(void)
-{
-	return _md_major;
-}
-
-int blkext_major(void)
-{
-	return _blkext_major;
-}
-
-int dev_subsystem_part_major(const struct device *dev)
-{
-	dev_t primary_dev;
-
-	if (MAJOR(dev->dev) == _md_major)
-		return 1;
-
-	if (MAJOR(dev->dev) == _drbd_major)
-		return 1;
-
-	if (MAJOR(dev->dev) == _emcpower_major)
-		return 1;
-
-	if (MAJOR(dev->dev) == _power2_major)
-		return 1;
-
-	if ((MAJOR(dev->dev) == _blkext_major) &&
-	    (get_primary_dev(dev, &primary_dev)) &&
-	    (MAJOR(primary_dev) == _md_major))
-		return 1;
-
-	return 0;
-}
-
-const char *dev_subsystem_name(const struct device *dev)
-{
-	if (MAJOR(dev->dev) == _md_major)
-		return "MD";
-
-	if (MAJOR(dev->dev) == _drbd_major)
-		return "DRBD";
-
-	if (MAJOR(dev->dev) == _emcpower_major)
-		return "EMCPOWER";
-
-	if (MAJOR(dev->dev) == _power2_major)
-		return "POWER2";
-
-	if (MAJOR(dev->dev) == _blkext_major)
-		return "BLKEXT";
-
-	return "";
-}
-
-static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((unused)),
-					  struct device *dev)
+static int _passes_lvm_type_device_filter(struct dev_filter *f, struct device *dev)
 {
+	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *name = dev_name(dev);
 	int ret = 0;
 	uint64_t size;
 
 	/* Is this a recognised device type? */
-	if (!_partitions[MAJOR(dev->dev)].max_partitions) {
+	if (!dt->dev_type_array[MAJOR(dev->dev)].max_partitions) {
 		log_debug_devs("%s: Skipping: Unrecognised LVM device type %"
 			       PRIu64, name, (uint64_t) MAJOR(dev->dev));
 		return 0;
@@ -134,7 +51,7 @@ static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((un
 		goto out;
 	}
 
-	if (is_partitioned_dev(dev)) {
+	if (dev_is_partitioned(dt, dev)) {
 		log_debug_devs("%s: Skipping: Partition table signature found",
 			       name);
 		goto out;
@@ -149,179 +66,6 @@ static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((un
 	return ret;
 }
 
-static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
-{
-	char line[80];
-	char proc_devices[PATH_MAX];
-	FILE *pd = NULL;
-	int i, j = 0;
-	int line_maj = 0;
-	int blocksection = 0;
-	size_t dev_len = 0;
-	const struct dm_config_value *cv;
-	const char *name;
-	char *nl;
-
-	if (!*proc) {
-		log_verbose("No proc filesystem found: using all block device "
-			    "types");
-		for (i = 0; i < NUMBER_OF_MAJORS; i++)
-			_partitions[i].max_partitions = 1;
-		return 1;
-	}
-
-	/* All types unrecognised initially */
-	memset(_partitions, 0, sizeof(_partitions));
-
-	if (dm_snprintf(proc_devices, sizeof(proc_devices),
-			 "%s/devices", proc) < 0) {
-		log_error("Failed to create /proc/devices string");
-		return 0;
-	}
-
-	if (!(pd = fopen(proc_devices, "r"))) {
-		log_sys_error("fopen", proc_devices);
-		return 0;
-	}
-
-	while (fgets(line, sizeof(line), pd) != NULL) {
-		i = 0;
-		while (line[i] == ' ')
-			i++;
-
-		/* If it's not a number it may be name of section */
-		line_maj = atoi(((char *) (line + i)));
-
-		if (line_maj < 0 || line_maj >= NUMBER_OF_MAJORS) {
-			/*
-			 * Device numbers shown in /proc/devices are actually direct
-			 * numbers passed to registering function, however the kernel
-			 * uses only 12 bits, so use just 12 bits for major.
-			 */
-			if ((nl = strchr(line, '\n'))) *nl = '\0';
-			log_warn("WARNING: /proc/devices line: %s, replacing major with %d.",
-				 line, line_maj & (NUMBER_OF_MAJORS - 1));
-			line_maj &= (NUMBER_OF_MAJORS - 1);
-		}
-
-		if (!line_maj) {
-			blocksection = (line[i] == 'B') ? 1 : 0;
-			continue;
-		}
-
-		/* We only want block devices ... */
-		if (!blocksection)
-			continue;
-
-		/* Find the start of the device major name */
-		while (line[i] != ' ' && line[i] != '\0')
-			i++;
-		while (line[i] == ' ')
-			i++;
-
-		/* Look for md device */
-		if (!strncmp("md", line + i, 2) && isspace(*(line + i + 2)))
-			_md_major = line_maj;
-
-		/* Look for blkext device */
-		if (!strncmp("blkext", line + i, 6) && isspace(*(line + i + 6)))
-			_blkext_major = line_maj;
-
-		/* Look for drbd device */
-		if (!strncmp("drbd", line + i, 4) && isspace(*(line + i + 4)))
-			_drbd_major = line_maj;
-
-		/* Look for EMC powerpath */
-		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
-			_emcpower_major = line_maj;
-
-		if (!strncmp("power2", line + i, 6) && isspace(*(line + i + 6)))
-			_power2_major = line_maj;
-
-		/* Look for device-mapper device */
-		/* FIXME Cope with multiple majors */
-		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
-			_device_mapper_major = line_maj;
-
-		/* Major is SCSI device */
-		if (!strncmp("sd", line + i, 2) && isspace(*(line + i + 2)))
-			_partitions[line_maj].flags |= PARTITION_SCSI_DEVICE;
-
-		/* Go through the valid device names and if there is a
-		   match store max number of partitions */
-		for (j = 0; _device_info[j].name[0]; j++) {
-			dev_len = strlen(_device_info[j].name);
-			if (dev_len <= strlen(line + i) &&
-			    !strncmp(_device_info[j].name, line + i, dev_len) &&
-			    (line_maj < NUMBER_OF_MAJORS)) {
-				_partitions[line_maj].max_partitions =
-				    _device_info[j].max_partitions;
-				break;
-			}
-		}
-
-		if (!cn)
-			continue;
-
-		/* Check devices/types for local variations */
-		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Expecting string in devices/types "
-					  "in config file");
-				if (fclose(pd))
-					log_sys_error("fclose", proc_devices);
-				return 0;
-			}
-			dev_len = strlen(cv->v.str);
-			name = cv->v.str;
-			cv = cv->next;
-			if (!cv || cv->type != DM_CFG_INT) {
-				log_error("Max partition count missing for %s "
-					  "in devices/types in config file",
-					  name);
-				if (fclose(pd))
-					log_sys_error("fclose", proc_devices);
-				return 0;
-			}
-			if (!cv->v.i) {
-				log_error("Zero partition count invalid for "
-					  "%s in devices/types in config file",
-					  name);
-				if (fclose(pd))
-					log_sys_error("fclose", proc_devices);
-				return 0;
-			}
-			if (dev_len <= strlen(line + i) &&
-			    !strncmp(name, line + i, dev_len) &&
-			    (line_maj < NUMBER_OF_MAJORS)) {
-				_partitions[line_maj].max_partitions = cv->v.i;
-				break;
-			}
-		}
-	}
-
-	if (fclose(pd))
-		log_sys_error("fclose", proc_devices);
-
-	return 1;
-}
-
-int max_partitions(int major)
-{
-	if (major >= NUMBER_OF_MAJORS)
-		return 0;
-
-	return _partitions[major].max_partitions;
-}
-
-int major_is_scsi_device(int major)
-{
-	if (major >= NUMBER_OF_MAJORS)
-		return 0;
-
-	return (_partitions[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
-}
-
 static void _lvm_type_filter_destroy(struct dev_filter *f)
 {
 	if (f->use_count)
@@ -330,8 +74,7 @@ static void _lvm_type_filter_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-struct dev_filter *lvm_type_filter_create(const char *proc,
-					  const struct dm_config_node *cn)
+struct dev_filter *lvm_type_filter_create(struct dev_types *dt)
 {
 	struct dev_filter *f;
 
@@ -343,12 +86,7 @@ struct dev_filter *lvm_type_filter_create(const char *proc,
 	f->passes_filter = _passes_lvm_type_device_filter;
 	f->destroy = _lvm_type_filter_destroy;
 	f->use_count = 0;
-	f->private = NULL;
-
-	if (!_scan_proc_dev(proc, cn)) {
-		dm_free(f);
-		return_NULL;
-	}
+	f->private = dt;
 
 	return f;
 }
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index cdbcfe8..e0a0c6a 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -16,30 +16,9 @@
 #ifndef _LVM_FILTER_H
 #define _LVM_FILTER_H
 
-#include "config.h"
+#include "dev-cache.h"
+#include "dev-type.h"
 
-#include <sys/stat.h>
-
-#ifdef linux
-#  define MAJOR(dev)	((dev & 0xfff00) >> 8)
-#  define MINOR(dev)	((dev & 0xff) | ((dev >> 12) & 0xfff00))
-#  define MKDEV(ma,mi)	((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
-#else
-#  define MAJOR(x) major((x))
-#  define MINOR(x) minor((x))
-#  define MKDEV(x,y) makedev((x),(y))
-#endif
-
-struct dev_filter *lvm_type_filter_create(const char *proc,
-					  const struct dm_config_node *cn);
-
-int dm_major(void);
-int md_major(void);
-int blkext_major(void);
-int max_partitions(int major);
-int major_is_scsi_device(int major);
-
-int dev_subsystem_part_major(const struct device *dev);
-const char *dev_subsystem_name(const struct device *dev);
+struct dev_filter *lvm_type_filter_create(struct dev_types *dt);
 
 #endif
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index 19776e0..bbce317 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -18,6 +18,7 @@
 #include "xlate.h"
 #include "filter.h"
 #include "lvmcache.h"
+#include "metadata-exported.h"
 
 #include <fcntl.h>
 
@@ -426,7 +427,7 @@ struct disk_list *read_disk(const struct format_type *fmt, struct device *dev,
 	return dl;
 }
 
-static void _add_pv_to_list(struct dm_list *head, struct disk_list *data)
+static void _add_pv_to_list(struct cmd_context *cmd, struct dm_list *head, struct disk_list *data)
 {
 	struct pv_disk *pvd;
 	struct disk_list *diskl;
@@ -435,14 +436,14 @@ static void _add_pv_to_list(struct dm_list *head, struct disk_list *data)
 		pvd = &diskl->pvd;
 		if (!strncmp((char *)data->pvd.pv_uuid, (char *)pvd->pv_uuid,
 			     sizeof(pvd->pv_uuid))) {
-			if (!dev_subsystem_part_major(data->dev)) {
+			if (!dev_subsystem_part_major(cmd->dev_types, data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s", pvd->pv_uuid,
 						 dev_name(data->dev));
 				return;
 			}
 			log_very_verbose("Duplicate PV %s - using %s %s",
-					 pvd->pv_uuid, dev_subsystem_name(data->dev),
+					 pvd->pv_uuid, dev_subsystem_name(cmd->dev_types, data->dev),
 					 dev_name(data->dev));
 			dm_list_del(&diskl->list);
 			break;
@@ -469,7 +470,7 @@ static int _read_pv_in_vg(struct lvmcache_info *info, void *baton)
 	    !(b->data = read_disk(lvmcache_fmt(info), lvmcache_device(info), b->mem, b->vg_name)))
 		return 0; /* stop here */
 
-	_add_pv_to_list(b->head, b->data);
+	_add_pv_to_list(lvmcache_fmt(info)->cmd, b->head, b->data);
 	return 1;
 }
 
@@ -519,7 +520,7 @@ int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 	/* Otherwise do a complete scan */
 	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
 		if ((baton.data = read_disk(fmt, dev, mem, vg_name))) {
-			_add_pv_to_list(head, baton.data);
+			_add_pv_to_list(fmt->cmd, head, baton.data);
 		}
 	}
 	dev_iter_destroy(iter);
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 899a48d..f696463 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -20,6 +20,7 @@
 #include "filter.h"
 #include "xlate.h"
 #include "disk_rep.h"
+#include "toolcontext.h"
 
 #include <assert.h>
 
@@ -52,7 +53,7 @@ static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
 	return 1;
 }
 
-static void _add_pl_to_list(struct dm_list *head, struct pool_list *data)
+static void _add_pl_to_list(struct cmd_context *cmd, struct dm_list *head, struct pool_list *data)
 {
 	struct pool_list *pl;
 
@@ -62,14 +63,14 @@ static void _add_pl_to_list(struct dm_list *head, struct pool_list *data)
 
 			id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7);
 
-			if (!dev_subsystem_part_major(data->dev)) {
+			if (!dev_subsystem_part_major(cmd->dev_types, data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s", uuid,
 						 dev_name(data->dev));
 				return;
 			}
 			log_very_verbose("Duplicate PV %s - using %s %s",
-					 uuid, dev_subsystem_name(data->dev),
+					 uuid, dev_subsystem_name(cmd->dev_types, data->dev),
 					 dev_name(data->dev));
 			dm_list_del(&pl->list);
 			break;
@@ -288,7 +289,7 @@ static int _read_pool_pv(struct lvmcache_info *info, void *baton)
 	if (b->sp_count != b->pl->pd.pl_subpools)
 		return 0;
 
-	_add_pl_to_list(b->head, b->pl);
+	_add_pl_to_list(lvmcache_fmt(info)->cmd, b->head, b->pl);
 
 	if (b->sp_count > b->pl->pd.pl_sp_id && b->sp_devs[b->pl->pd.pl_sp_id] == 0)
 		b->sp_devs[b->pl->pd.pl_sp_id] = b->pl->pd.pl_sp_devs;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4e52bd4..c65144c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -84,7 +84,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 * Align to stripe-width of underlying md device if present
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG)) {
-		temp_pe_align = dev_md_stripe_width(pv->dev);
+		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->dev_types, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
 	}
@@ -97,11 +97,11 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 *   (e.g. MD's stripe width)
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG)) {
-		temp_pe_align = dev_minimum_io_size(pv->dev);
+		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->dev_types, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
 
-		temp_pe_align = dev_optimal_io_size(pv->dev);
+		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->dev_types, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
 			pv->pe_align = temp_pe_align;
 	}
@@ -129,7 +129,7 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 		goto out;
 
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_offset_detection_CFG)) {
-		int align_offset = dev_alignment_offset(pv->dev);
+		int align_offset = dev_alignment_offset(pv->fmt->cmd->dev_types, pv->dev);
 		/* must handle a -1 alignment_offset; means dev is misaligned */
 		if (align_offset < 0)
 			align_offset = 0;
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index ae453ae..dea49f8 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -216,8 +216,8 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 		return 1;
 	}
 
-	if (!dev_discard_max_bytes(peg->pv->dev) ||
-	    !dev_discard_granularity(peg->pv->dev))
+	if (!dev_discard_max_bytes(peg->pv->fmt->cmd->dev_types, peg->pv->dev) ||
+	    !dev_discard_granularity(peg->pv->fmt->cmd->dev_types, peg->pv->dev))
 		return 1;
 
 	discard_offset_sectors = (peg->pe + peg->lvseg->area_len - discard_area_reduction) *


