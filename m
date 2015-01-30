From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:32:07 +0000 (UTC)
Subject: master - filters: add firmware RAID filter
Message-ID: <20150130123207.E120C6107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c7a509bed900e27932df585f70c0c2ad994d1a9
Commit:        1c7a509bed900e27932df585f70c0c2ad994d1a9
Parent:        787f6ce04ab2d2420cda199c34fdd795153b593f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 9 15:05:57 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:17:12 2015 +0100

filters: add firmware RAID filter

Just like MD filtering that detects components of software RAID (md),
add detection for firmware RAID.

We're not adding any native code to detect this - there are lots of
firmware RAIDs out there which is just out of LVM scope. However,
with current changes with which we're able to get device info from
external sources (e.g. external_device_info_source="udev"), we can
do this easily if the external device status source has this kind
of information - which is the case of "udev" source where the results
of blkid scans are stored.

This detection should cover all firmware RAIDs that blkid can detect and
which are identified as:
  ID_FS_TYPE = {adaptec,ddf,hpt45x,hpt37x,isw,jmicron,lsi_mega,nvidia,promise_fasttrack,silicon_medley,via}_raid_member
---
 conf/example.conf.in         |    8 +++
 lib/Makefile.in              |    1 +
 lib/commands/toolcontext.c   |   13 ++++-
 lib/config/config_settings.h |    1 +
 lib/config/defaults.h        |    1 +
 lib/filters/filter-fwraid.c  |  122 ++++++++++++++++++++++++++++++++++++++++++
 lib/filters/filter.h         |    1 +
 lib/misc/lvm-globals.c       |   11 ++++
 lib/misc/lvm-globals.h       |    2 +
 9 files changed, 157 insertions(+), 3 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index df28a7b..d9f10bf 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -178,6 +178,14 @@ devices {
     # 1 enables; 0 disables.
     md_component_detection = 1
 
+    # By default, LVM2 will not ignore devices used as components of
+    # firmware RAID devices. Set to 1 to enable this detection.
+    # N.B. LVM2 itself is not detecting firmware RAID - an
+    # auxiliary_device_status_source other than "native" must
+    # be used for this detection to be successful.
+    # 1 enables; 0 disables
+    fw_raid_component_detection = 0
+
     # By default, if a PV is placed directly upon an md device, LVM2
     # will align its data blocks with the md device's stripe-width.
     # 1 enables; 0 disables.
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 99cc0fe..62600d5 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -70,6 +70,7 @@ SOURCES =\
 	filters/filter-regex.c \
 	filters/filter-sysfs.c \
 	filters/filter-md.c \
+	filters/filter-fwraid.c \
 	filters/filter-mpath.c \
 	filters/filter-partitioned.c \
 	filters/filter-type.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e914e93..7f92ef6 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -846,7 +846,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 7
+#define MAX_FILTERS 8
 
 static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 {
@@ -916,6 +916,13 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
+	/* firmware raid filter. Optional, non-critical. */
+	if (find_config_tree_bool(cmd, devices_fw_raid_component_detection_CFG, NULL)) {
+		init_fwraid_filtering(1);
+		if ((filters[nr_filt] = fwraid_filter_create(cmd->dev_types)))
+			nr_filt++;
+	}
+
 	if (!(composite = composite_filter_create(nr_filt, 1, filters)))
 		goto_bad;
 
@@ -937,7 +944,7 @@ bad:
  *     sysfs filter -> global regex filter -> type filter ->
  *     usable device filter(FILTER_MODE_PRE_LVMETAD) ->
  *     mpath component filter -> partitioned filter ->
- *     md component filter
+ *     md component filter -> fw raid filter
  *
  *   - cmd->filter - the filter chain used for lvmetad responses:
  *     persistent filter -> usable device filter(FILTER_MODE_POST_LVMETAD) ->
@@ -953,7 +960,7 @@ bad:
  *     global regex filter -> type filter ->
  *     usable device filter(FILTER_MODE_NO_LVMETAD) ->
  *     mpath component filter -> partitioned filter ->
- *     md component filter
+ *     md component filter -> fw raid filter
  *
  */
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 52d7f0f..f916a5f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -103,6 +103,7 @@ cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED
 cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL)
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL)
 cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL)
+cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL)
 cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL)
 cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL)
 cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index dfbfea8..9d2cff9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -33,6 +33,7 @@
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
+#define DEFAULT_FW_RAID_COMPONENT_DETECTION 0
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_LVM_MIRRORS 1
 #define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
new file mode 100644
index 0000000..2a0c598
--- /dev/null
+++ b/lib/filters/filter-fwraid.c
@@ -0,0 +1,122 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
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
+
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
+
+#ifdef __linux__
+
+#ifdef UDEV_SYNC_SUPPORT
+static int _udev_dev_is_fwraid(struct device *dev)
+{
+	const char *value;
+
+	value = udev_device_get_property_value((struct udev_device *)dev->ext.handle, "ID_FS_TYPE");
+	if (value && strcmp(value, "linux_raid_member") && strstr(value, "_raid_member"))
+		return 1;
+
+	return 0;
+}
+#else
+static int _udev_dev_is_fwraid(struct device *dev)
+{
+	return 0;
+}
+#endif
+
+static int _native_dev_is_fwraid(struct device *dev)
+{
+	log_verbose("%s: Firmware RAID detection is not supported by LVM natively. "
+		    "Skipping firmware raid detection. ", dev_name(dev));
+	return 0;
+}
+
+static int _dev_is_fwraid(struct device *dev)
+{
+	if (dev->ext.src == DEV_EXT_NONE)
+		return _native_dev_is_fwraid(dev);
+
+	if (dev->ext.src == DEV_EXT_UDEV)
+		return _udev_dev_is_fwraid(dev);
+
+	log_error(INTERNAL_ERROR "Missing hook for firmware RAID recognition "
+		  "using external device info source %s", dev_ext_name(dev));
+
+	return 0;
+}
+
+static int _ignore_fwraid(struct dev_filter *f __attribute__((unused)),
+			   struct device *dev)
+{
+	int ret;
+
+	if (!fwraid_filtering())
+		return 1;
+
+	ret = _dev_is_fwraid(dev);
+
+	if (ret == 1) {
+		log_debug_devs("%s: Skipping firmware RAID component device [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		return 0;
+	}
+
+	if (ret < 0) {
+		log_debug_devs("%s: Skipping: error in firmware RAID component detection",
+			       dev_name(dev));
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying firmware RAID filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
+struct dev_filter *fwraid_filter_create(struct dev_types *dt __attribute__((unused)))
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_zalloc(sizeof(*f)))) {
+		log_error("Firmware RAID filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _ignore_fwraid;
+	f->destroy = _destroy;
+	f->use_count = 0;
+	f->private = NULL;
+
+	log_debug_devs("Firmware RAID filter initialised.");
+
+	return f;
+}
+
+#else
+
+struct dev_filter *fwraid_filter_create(struct dev_types *dt __attribute__((unused)))
+{
+	return NULL;
+}
+
+#endif
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index e73cf9c..c03d8e2 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -24,6 +24,7 @@ struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct d
 
 struct dev_filter *lvm_type_filter_create(struct dev_types *dt);
 struct dev_filter *md_filter_create(struct dev_types *dt);
+struct dev_filter *fwraid_filter_create(struct dev_types *dt);
 struct dev_filter *mpath_filter_create(struct dev_types *dt);
 struct dev_filter *partitioned_filter_create(struct dev_types *dt);
 struct dev_filter *persistent_filter_create(struct dev_types *dt,
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index f0dab88..6455788 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -26,6 +26,7 @@ static int _verbose_level = VERBOSE_BASE_LEVEL;
 static int _silent = 0;
 static int _test = 0;
 static int _md_filtering = 0;
+static int _fwraid_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
 static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
@@ -75,6 +76,11 @@ void init_md_filtering(int level)
 	_md_filtering = level;
 }
 
+void init_fwraid_filtering(int level)
+{
+	_fwraid_filtering = level;
+}
+
 void init_pvmove(int level)
 {
 	_pvmove = level;
@@ -221,6 +227,11 @@ int md_filtering(void)
 	return _md_filtering;
 }
 
+int fwraid_filtering(void)
+{
+	return _fwraid_filtering;
+}
+
 int pvmove_mode(void)
 {
 	return _pvmove;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 4c4cc1a..b25f4ae 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -24,6 +24,7 @@ void init_verbose(int level);
 void init_silent(int silent);
 void init_test(int level);
 void init_md_filtering(int level);
+void init_fwraid_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
 void init_external_device_info_source(unsigned src);
@@ -54,6 +55,7 @@ void set_sysfs_dir_path(const char *path);
 
 int test_mode(void);
 int md_filtering(void);
+int fwraid_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
 int obtain_device_list_from_udev(void);


