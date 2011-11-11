From: Milan Broz <mbroz@redhat.com>
Date: Fri, 11 Nov 2011 14:55:52 +0100
Subject: [PATCH v2] Do not scan device if it is part of active multipath.
In-Reply-To: <1319038907-2655-1-git-send-email-mbroz@redhat.com>
References: <1319038907-2655-1-git-send-email-mbroz@redhat.com>
Message-ID: <1321019752-5389-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add filter which tries to check if scanned device is part
of active multipath.

Firstly, only SCSI major number devices are handled in filter.

Then it checks if device has exactly one holder (in sysfs) and
if it is device-mapper device and DM-UUID is prefixed by "MPATH-".

If so, this device is filtered out.

The whole filter can be switched off by setting
mpath_component_detection in lvm.conf.

https://bugzilla.redhat.com/show_bug.cgi?id=597010

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 doc/example.conf.in        |    5 +
 include/.symlinks.in       |    1 +
 lib/Makefile.in            |    1 +
 lib/activate/activate.c    |   27 ++++++
 lib/activate/activate.h    |    1 +
 lib/commands/toolcontext.c |   10 ++-
 lib/config/defaults.h      |    1 +
 lib/filters/filter-mpath.c |  190 ++++++++++++++++++++++++++++++++++++++++++++
 lib/filters/filter-mpath.h |   23 ++++++
 lib/filters/filter.c       |   34 ++++++--
 lib/filters/filter.h       |    1 +
 11 files changed, 285 insertions(+), 9 deletions(-)
 create mode 100644 lib/filters/filter-mpath.c
 create mode 100644 lib/filters/filter-mpath.h

diff --git a/doc/example.conf.in b/doc/example.conf.in
index ed15db6..2dd1808 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -103,6 +103,11 @@ devices {
     # 1 enables; 0 disables.
     sysfs_scan = 1
 
+    # By default, LVM2 will ignore devices used as component paths
+    # of device-mapper multipath devices.
+    # 1 enables; 0 disables.
+    multipath_component_detection = 1
+
     # By default, LVM2 will ignore devices used as components of
     # software RAID (md) devices by looking for md superblocks.
     # 1 enables; 0 disables.
diff --git a/include/.symlinks.in b/include/.symlinks.in
index c16e107..00d7d55 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -16,6 +16,7 @@
 @top_srcdir@/lib/display/display.h
 @top_srcdir@/lib/filters/filter-composite.h
 @top_srcdir@/lib/filters/filter-md.h
+ at top_srcdir@/lib/filters/filter-mpath.h
 @top_srcdir@/lib/filters/filter-persistent.h
 @top_srcdir@/lib/filters/filter-regex.h
 @top_srcdir@/lib/filters/filter-sysfs.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index a46e596..4e9afd9 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -65,6 +65,7 @@ SOURCES =\
 	filters/filter-regex.c \
 	filters/filter-sysfs.c \
 	filters/filter-md.c \
+	filters/filter-mpath.c \
 	filters/filter.c \
 	format_text/archive.c \
 	format_text/archiver.c \
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2b44b19..37c10f5 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -147,6 +147,10 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 {
 	return 0;
 }
+int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
+{
+	return 0;
+}
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, unsigned origin_only,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
@@ -439,6 +443,29 @@ int target_version(const char *target_name, uint32_t *maj,
 	return r;
 }
 
+int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
+{
+	struct dm_task *dmt;
+	const char *uuid;
+	int r;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return 0;
+
+	if (!dm_task_set_minor(dmt, minor) ||
+	    !dm_task_set_major(dmt, major) ||
+	    !dm_task_run(dmt) ||
+	    !(uuid = dm_task_get_uuid(dmt))) {
+		dm_task_destroy(dmt);
+		return 0;
+	}
+
+	r = strncasecmp(uuid, prefix, strlen(prefix));
+	dm_task_destroy(dmt);
+
+	return (r == 0) ? 1 : 0;
+}
+
 int module_present(struct cmd_context *cmd, const char *target_name)
 {
 	int ret = 0;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 119211d..7de1703 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -53,6 +53,7 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
 		   uint32_t *min, uint32_t *patchlevel);
+int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 			 struct dm_list *modules);
 int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4dc4c26..ec6e400 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -22,6 +22,7 @@
 #include "filter.h"
 #include "filter-composite.h"
 #include "filter-md.h"
+#include "filter-mpath.h"
 #include "filter-persistent.h"
 #include "filter-regex.h"
 #include "filter-sysfs.h"
@@ -714,7 +715,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 4
+#define MAX_FILTERS 5
 
 static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
@@ -766,6 +767,13 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
+	/* mpath component filter. Optional, non-critical. */
+	if (find_config_tree_bool(cmd, "devices/multipath_component_detection",
+			     DEFAULT_MULTIPATH_COMPONENT_DETECTION)) {
+		if ((filters[nr_filt] = mpath_filter_create(cmd->sysfs_dir)))
+			nr_filt++;
+	}
+
 	/* Only build a composite filter if we really need it. */
 	return (nr_filt == 1) ?
 	    filters[0] : composite_filter_create(nr_filt, filters);
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6819a9a..9b91aea 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -33,6 +33,7 @@
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
+#define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
new file mode 100644
index 0000000..26462e8
--- /dev/null
+++ b/lib/filters/filter-mpath.c
@@ -0,0 +1,190 @@
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
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "filter.h"
+#include "filter-mpath.h"
+#include "activate.h"
+
+#ifdef linux
+#include <dirent.h>
+
+#define MPATH_PREFIX "mpath-"
+
+static const char *get_sysfs_name(struct device *dev)
+{
+	const char *name;
+
+	name = strrchr(dev_name(dev), '/');
+	if (!name)
+		return NULL;
+	name++;
+
+	if (!*name)
+		return NULL;
+
+	return name;
+}
+
+static int get_sysfs_string(const char *path, char *buffer, int max_size)
+{
+	FILE *fp;
+	int r = 0;
+
+	if (!(fp = fopen(path, "r")))
+		return_0;
+
+	if (!fgets(buffer, max_size, fp))
+		stack;
+	else
+		r = 1;
+
+	if (fclose(fp))
+		stack;
+
+	return r;
+}
+
+static int get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname, int *major, int *minor)
+{
+	char path[PATH_MAX], buffer[64];
+
+	if (snprintf(path, sizeof(path), "%s/block/%s/dev", sysfs_dir, kname) < 0)
+		return_0;
+
+	if (!get_sysfs_string(path, buffer, sizeof(buffer)))
+		return 0;
+
+	if (sscanf(buffer, "%d:%d", major, minor) != 2)
+		return 0;
+
+	return 1;
+}
+
+static int get_parent_mpath(const char *dir, char *name, int max_size)
+{
+	struct dirent *d;
+	DIR *dr;
+	int r = 0;
+
+	if (!(dr = opendir(dir)))
+		return_0;
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
+		stack;
+
+	return r;
+}
+
+static int dev_is_mpath(struct dev_filter *f, struct device *dev)
+{
+	const char *name;
+	char path[PATH_MAX+1];
+	char parent_name[PATH_MAX+1];
+	struct stat info;
+	const char *sysfs_dir = f->private;
+	int major, minor, r;
+
+	/* Limit this filter only to SCSI devices */
+	if (!major_is_scsi_device(MAJOR(dev->dev)))
+		return 0;
+
+	name = get_sysfs_name(dev);
+	if (!name)
+		return_0;
+
+	r = dm_snprintf(path, PATH_MAX, "%s/block/%s/holders", sysfs_dir, name);
+	if (r < 0)
+		return_0;
+
+	/* also will filter out partitions */
+	if (stat(path, &info) == -1 || !S_ISDIR(info.st_mode))
+		return 0;
+
+	if (!get_parent_mpath(path, parent_name, PATH_MAX))
+		return 0;
+
+	if (!get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
+		return 0;
+
+	if (major != dm_major())
+		return 0;
+
+	return dm_prefix_check(sysfs_dir, major, minor, MPATH_PREFIX);
+}
+
+static int _ignore_mpath(struct dev_filter *f, struct device *dev)
+{
+	if (dev_is_mpath(f, dev) == 1) {
+		log_debug("%s: Skipping mpath component device", dev_name(dev));
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
+
+	dm_free(f->private);
+	dm_free(f);
+}
+
+struct dev_filter *mpath_filter_create(const char *sysfs_dir)
+{
+	struct dev_filter *f;
+
+	if (!*sysfs_dir) {
+		log_verbose("No proc filesystem found: skipping multipath filter");
+		return NULL;
+	}
+
+	if (!(f = dm_malloc(sizeof(*f)))) {
+		log_error("mpath filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _ignore_mpath;
+	f->destroy = _destroy;
+	f->use_count = 0;
+	f->private = dm_strdup(sysfs_dir);
+
+	return f;
+}
+
+#else
+
+struct dev_filter *mpath_filter_create(const char *sysfs_dir __attribute__((unused)))
+{
+	return NULL;
+}
+
+#endif
diff --git a/lib/filters/filter-mpath.h b/lib/filters/filter-mpath.h
new file mode 100644
index 0000000..0b5373f
--- /dev/null
+++ b/lib/filters/filter-mpath.h
@@ -0,0 +1,23 @@
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
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_FILTER_MPATH_H
+#define _LVM_FILTER_MPATH_H
+
+#include "dev-cache.h"
+
+struct dev_filter *mpath_filter_create(const char *sysfs_dir);
+
+#endif
+
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index f2398a1..68f65a0 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -29,8 +29,11 @@
 
 #define NUMBER_OF_MAJORS 4096
 
-/* 0 means LVM won't use this major number. */
-static int _max_partitions_by_major[NUMBER_OF_MAJORS];
+#define PARTITION_SCSI_DEVICE (1 << 0)
+static struct {
+	int max_partitions; /* 0 means LVM won't use this major number. */
+	int flags;
+} _partitions[NUMBER_OF_MAJORS];
 
 typedef struct {
 	const char *name;
@@ -140,7 +143,7 @@ static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute__((un
 	uint64_t size;
 
 	/* Is this a recognised device type? */
-	if (!_max_partitions_by_major[MAJOR(dev->dev)]) {
+	if (!_partitions[MAJOR(dev->dev)].max_partitions) {
 		log_debug("%s: Skipping: Unrecognised LVM device type %"
 			  PRIu64, name, (uint64_t) MAJOR(dev->dev));
 		return 0;
@@ -194,12 +197,12 @@ static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 		log_verbose("No proc filesystem found: using all block device "
 			    "types");
 		for (i = 0; i < NUMBER_OF_MAJORS; i++)
-			_max_partitions_by_major[i] = 1;
+			_partitions[i].max_partitions = 1;
 		return 1;
 	}
 
 	/* All types unrecognised initially */
-	memset(_max_partitions_by_major, 0, sizeof(int) * NUMBER_OF_MAJORS);
+	memset(_partitions, 0, sizeof(_partitions));
 
 	if (dm_snprintf(proc_devices, sizeof(proc_devices),
 			 "%s/devices", proc) < 0) {
@@ -251,6 +254,10 @@ static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
 			_device_mapper_major = line_maj;
 
+		/* Major is SCSI device */
+		if (!strncmp("sd", line + i, 2) && isspace(*(line + i + 2)))
+			_partitions[line_maj].flags |= PARTITION_SCSI_DEVICE;
+
 		/* Go through the valid device names and if there is a
 		   match store max number of partitions */
 		for (j = 0; device_info[j].name != NULL; j++) {
@@ -258,7 +265,7 @@ static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 			if (dev_len <= strlen(line + i) &&
 			    !strncmp(device_info[j].name, line + i, dev_len) &&
 			    (line_maj < NUMBER_OF_MAJORS)) {
-				_max_partitions_by_major[line_maj] =
+				_partitions[line_maj].max_partitions =
 				    device_info[j].max_partitions;
 				break;
 			}
@@ -298,7 +305,7 @@ static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 			if (dev_len <= strlen(line + i) &&
 			    !strncmp(name, line + i, dev_len) &&
 			    (line_maj < NUMBER_OF_MAJORS)) {
-				_max_partitions_by_major[line_maj] = cv->v.i;
+				_partitions[line_maj].max_partitions = cv->v.i;
 				break;
 			}
 		}
@@ -312,7 +319,18 @@ static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 
 int max_partitions(int major)
 {
-	return _max_partitions_by_major[major];
+	if (major > NUMBER_OF_MAJORS)
+		return 0;
+
+	return _partitions[major].max_partitions;
+}
+
+int major_is_scsi_device(int major)
+{
+	if (major > NUMBER_OF_MAJORS)
+		return 0;
+
+	return (_partitions[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
 }
 
 struct dev_filter *lvm_type_filter_create(const char *proc,
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 5c6047a..21cb89b 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -39,6 +39,7 @@ int dm_major(void);
 int md_major(void);
 int blkext_major(void);
 int max_partitions(int major);
+int major_is_scsi_device(int major);
 
 int dev_subsystem_part_major(const struct device *dev);
 const char *dev_subsystem_name(const struct device *dev);
-- 
1.7.7.2


