From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:32:10 +0000 (UTC)
Subject: master - cleanup: add dev-ext-udev-constants.h with constants/names of the properties/values used from udev db
Message-ID: <20150130123210.02AB360DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28ba0450e93db30ee4dd815cbe85478b3c6a719a
Commit:        28ba0450e93db30ee4dd815cbe85478b3c6a719a
Parent:        1c7a509bed900e27932df585f70c0c2ad994d1a9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 29 16:44:34 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:17:12 2015 +0100

cleanup: add dev-ext-udev-constants.h with constants/names of the properties/values used from udev db

---
 include/.symlinks.in                |    1 +
 lib/device/dev-ext-udev-constants.h |   52 +++++++++++++++++++++++++++++++++++
 lib/device/dev-md.c                 |    5 ++-
 lib/device/dev-type.c               |    5 ++-
 lib/filters/filter-fwraid.c         |    5 ++-
 lib/filters/filter-mpath.c          |    7 +++--
 lib/filters/filter-usable.c         |    3 +-
 7 files changed, 68 insertions(+), 10 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 48c4d9d..96f4a01 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -13,6 +13,7 @@
 @top_srcdir@/lib/datastruct/btree.h
 @top_srcdir@/lib/datastruct/str_list.h
 @top_srcdir@/lib/device/dev-cache.h
+ at top_srcdir@/lib/device/dev-ext-udev-constants.h
 @top_srcdir@/lib/device/dev-type.h
 @top_srcdir@/lib/device/device.h
 @top_srcdir@/lib/device/device-types.h
diff --git a/lib/device/dev-ext-udev-constants.h b/lib/device/dev-ext-udev-constants.h
new file mode 100644
index 0000000..a84d7bc
--- /dev/null
+++ b/lib/device/dev-ext-udev-constants.h
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
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
+/*************************************************************************
+ * Properties saved in udev db and accesible via libudev and used by LVM *
+ *************************************************************************/
+
+/*
+ * DEV_EXT_UDEV_BLKID_TYPE property with various DEV_EXT_UDEV_BLKID_TYPE_*
+ * values that is saved in udev db via blkid call in udev rules
+ */
+#define DEV_EXT_UDEV_BLKID_TYPE                 "ID_FS_TYPE"
+/*
+ * mpath_member is forced by multipath - it's set in udev db via
+ * multipath call overwriting any existing ID_FS_TYPE value for
+ * a device which is a multipath component which prevents incorrect
+ * claim of the device by any other block device subsystem
+ */
+#define DEV_EXT_UDEV_BLKID_TYPE_MPATH           "mpath_member"
+/* FW RAIDs are all *_raid_member types except linux_raid_member which denotes SW RAID */
+#define DEV_EXT_UDEV_BLKID_TYPE_RAID_SUFFIX     "_raid_member"
+#define DEV_EXT_UDEV_BLKID_TYPE_SW_RAID         "linux_raid_member"
+#define DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE      "ID_PART_TABLE_TYPE"
+#define DEV_EXT_UDEV_BLKID_PART_ENTRY_DISK      "ID_PART_ENTRY_DISK"
+
+/*
+ * DEV_EXT_UDEV_MPATH_DEVICE_PATH is set by multipath in udev db
+ * with value either 0 or 1. The same functionality as
+ * DEV_EXT_UDEV_BLKID_TYPE_MPATH actually, but introduced later
+ * for some reason.
+ */
+#define DEV_EXT_UDEV_MPATH_DEVICE_PATH          "DM_MULTIPATH_DEVICE_PATH"
+
+
+/***********************************************************
+ * Sysfs attributes accessible via libudev and used by LVM *
+ ***********************************************************/
+
+/* the value of size sysfs attribute is size in bytes */
+#define DEV_EXT_UDEV_SYSFS_ATTR_SIZE            "size"
+
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 535259f..603010c 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -18,6 +18,7 @@
 #include "xlate.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h> /* for MD detection using udev db records */
+#include "dev-ext-udev-constants.h"
 #endif
 
 #ifdef __linux__
@@ -93,10 +94,10 @@ static int _udev_dev_is_md(struct device *dev)
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_FS_TYPE")))
+	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE)))
 		return 0;
 
-	return !strcmp(value, "linux_raid_member");
+	return !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID);
 }
 #else
 static int _udev_dev_is_md(struct device *dev)
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 58bd177..ba30982 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -27,6 +27,7 @@
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
+#include "dev-ext-udev-constants.h"
 #endif
 
 #include "device-types.h"
@@ -337,10 +338,10 @@ static int _udev_dev_is_partitioned(struct device *dev)
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_PART_TABLE_TYPE")))
+	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE)))
 		return 0;
 
-	if ((value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_PART_ENTRY_DISK")))
+	if ((value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_ENTRY_DISK)))
 		return 0;
 
 	return 1;
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index 2a0c598..f16833e 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -17,6 +17,7 @@
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
+#include "dev-ext-udev-constants.h"
 #endif
 
 #ifdef __linux__
@@ -26,8 +27,8 @@ static int _udev_dev_is_fwraid(struct device *dev)
 {
 	const char *value;
 
-	value = udev_device_get_property_value((struct udev_device *)dev->ext.handle, "ID_FS_TYPE");
-	if (value && strcmp(value, "linux_raid_member") && strstr(value, "_raid_member"))
+	value = udev_device_get_property_value((struct udev_device *)dev->ext.handle, DEV_EXT_UDEV_BLKID_TYPE);
+	if (value && strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID) && strstr(value, DEV_EXT_UDEV_BLKID_TYPE_RAID_SUFFIX))
 		return 1;
 
 	return 0;
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index fefc8e0..0016a51 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -17,6 +17,7 @@
 #include "activate.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
+#include "dev-ext-udev-constants.h"
 #endif
 
 #ifdef __linux__
@@ -153,11 +154,11 @@ static int _udev_dev_is_mpath(struct device *dev)
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_FS_TYPE");
-	if (value && !strcmp(value, "mpath_member"))
+	value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE);
+	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH))
 		return 1;
 
-	value = udev_device_get_property_value((struct udev_device *)ext->handle, "DM_MULTIPATH_DEVICE_PATH");
+	value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
 	if (value && !strcmp(value, "1"))
 		return 1;
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 667cdac..a4cfc69 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -17,6 +17,7 @@
 #include "activate.h" /* device_is_usable */
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
+#include "dev-ext-udev-constants.h"
 #endif
 
 static const char *_too_small_to_hold_pv_msg = "Too small to hold a PV";
@@ -66,7 +67,7 @@ static int _udev_check_pv_min_size(struct device *dev)
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!(size_str = udev_device_get_sysattr_value((struct udev_device *)ext->handle, "size"))) {
+	if (!(size_str = udev_device_get_sysattr_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_SYSFS_ATTR_SIZE))) {
 		log_debug_devs("%s: Skipping: failed to get size from sysfs [%s:%p]",
 				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
 		return 0;


