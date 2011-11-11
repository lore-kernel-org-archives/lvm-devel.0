From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Nov 2011 15:11:20 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in include/. ...
Message-ID: <20111111151120.9763.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-11-11 15:11:13

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	include        : .symlinks.in 
	lib            : Makefile.in 
	lib/activate   : activate.c activate.h 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/filters    : filter.c filter.h 

Log message:
	Do not scan device if it is part of active multipath.
	
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

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2180&r2=1.2181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2011/11/08 12:16:53	1.2180
+++ LVM2/WHATS_NEW	2011/11/11 15:11:08	1.2181
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add filter to avoid scan of device if it is part of active multipath.
   Add missing default $LVM_VG_NAME usage for snapshots.
   Fix extent_count overflow with lvextend.
   Add missing lvrename mirrored log recursion in for_each_sub_lv.
--- LVM2/doc/example.conf.in	2011/11/04 22:44:21	1.35
+++ LVM2/doc/example.conf.in	2011/11/11 15:11:09	1.36
@@ -103,6 +103,11 @@
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
--- LVM2/include/.symlinks.in	2010/11/30 11:53:31	1.7
+++ LVM2/include/.symlinks.in	2011/11/11 15:11:09	1.8
@@ -16,6 +16,7 @@
 @top_srcdir@/lib/display/display.h
 @top_srcdir@/lib/filters/filter-composite.h
 @top_srcdir@/lib/filters/filter-md.h
+ at top_srcdir@/lib/filters/filter-mpath.h
 @top_srcdir@/lib/filters/filter-persistent.h
 @top_srcdir@/lib/filters/filter-regex.h
 @top_srcdir@/lib/filters/filter-sysfs.h
--- LVM2/lib/Makefile.in	2011/09/06 19:25:43	1.113
+++ LVM2/lib/Makefile.in	2011/11/11 15:11:10	1.114
@@ -65,6 +65,7 @@
 	filters/filter-regex.c \
 	filters/filter-sysfs.c \
 	filters/filter-md.c \
+	filters/filter-mpath.c \
 	filters/filter.c \
 	format_text/archive.c \
 	format_text/archiver.c \
--- LVM2/lib/activate/activate.c	2011/11/07 10:58:13	1.220
+++ LVM2/lib/activate/activate.c	2011/11/11 15:11:10	1.221
@@ -147,6 +147,10 @@
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
@@ -439,6 +443,29 @@
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
--- LVM2/lib/activate/activate.h	2011/11/03 14:52:09	1.85
+++ LVM2/lib/activate/activate.h	2011/11/11 15:11:10	1.86
@@ -53,6 +53,7 @@
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
 		   uint32_t *min, uint32_t *patchlevel);
+int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 			 struct dm_list *modules);
 int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
--- LVM2/lib/commands/toolcontext.c	2011/10/28 20:06:49	1.139
+++ LVM2/lib/commands/toolcontext.c	2011/11/11 15:11:11	1.140
@@ -22,6 +22,7 @@
 #include "filter.h"
 #include "filter-composite.h"
 #include "filter-md.h"
+#include "filter-mpath.h"
 #include "filter-persistent.h"
 #include "filter-regex.h"
 #include "filter-sysfs.h"
@@ -714,7 +715,7 @@
 	return 1;
 }
 
-#define MAX_FILTERS 4
+#define MAX_FILTERS 5
 
 static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
@@ -766,6 +767,13 @@
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
--- LVM2/lib/config/defaults.h	2011/11/04 22:44:21	1.87
+++ LVM2/lib/config/defaults.h	2011/11/11 15:11:11	1.88
@@ -33,6 +33,7 @@
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
+#define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
--- LVM2/lib/filters/filter.c	2011/08/30 14:55:17	1.63
+++ LVM2/lib/filters/filter.c	2011/11/11 15:11:12	1.64
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
@@ -140,7 +143,7 @@
 	uint64_t size;
 
 	/* Is this a recognised device type? */
-	if (!_max_partitions_by_major[MAJOR(dev->dev)]) {
+	if (!_partitions[MAJOR(dev->dev)].max_partitions) {
 		log_debug("%s: Skipping: Unrecognised LVM device type %"
 			  PRIu64, name, (uint64_t) MAJOR(dev->dev));
 		return 0;
@@ -194,12 +197,12 @@
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
@@ -251,6 +254,10 @@
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))
 			_device_mapper_major = line_maj;
 
+		/* Major is SCSI device */
+		if (!strncmp("sd", line + i, 2) && isspace(*(line + i + 2)))
+			_partitions[line_maj].flags |= PARTITION_SCSI_DEVICE;
+
 		/* Go through the valid device names and if there is a
 		   match store max number of partitions */
 		for (j = 0; device_info[j].name != NULL; j++) {
@@ -258,7 +265,7 @@
 			if (dev_len <= strlen(line + i) &&
 			    !strncmp(device_info[j].name, line + i, dev_len) &&
 			    (line_maj < NUMBER_OF_MAJORS)) {
-				_max_partitions_by_major[line_maj] =
+				_partitions[line_maj].max_partitions =
 				    device_info[j].max_partitions;
 				break;
 			}
@@ -298,7 +305,7 @@
 			if (dev_len <= strlen(line + i) &&
 			    !strncmp(name, line + i, dev_len) &&
 			    (line_maj < NUMBER_OF_MAJORS)) {
-				_max_partitions_by_major[line_maj] = cv->v.i;
+				_partitions[line_maj].max_partitions = cv->v.i;
 				break;
 			}
 		}
@@ -312,7 +319,18 @@
 
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
--- LVM2/lib/filters/filter.h	2011/08/30 14:55:17	1.19
+++ LVM2/lib/filters/filter.h	2011/11/11 15:11:12	1.20
@@ -39,6 +39,7 @@
 int md_major(void);
 int blkext_major(void);
 int max_partitions(int major);
+int major_is_scsi_device(int major);
 
 int dev_subsystem_part_major(const struct device *dev);
 const char *dev_subsystem_name(const struct device *dev);


