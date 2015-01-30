From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:31:59 +0000 (UTC)
Subject: master - filter-md: use new 'udev' external device info source to get MD component status
Message-ID: <20150130123159.7E3D361152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=590fbd89618fa8fb2556c89c1d12b5deb5b5f1a4
Commit:        590fbd89618fa8fb2556c89c1d12b5deb5b5f1a4
Parent:        bf8943b0f63336272f3434455b906e0167e27b52
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 3 15:47:52 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:01:12 2015 +0100

filter-md: use new 'udev' external device info source to get MD component status

MD components are marked in udev db as:
  ID_FS_TYPE="linux_raid_member"
---
 lib/device/dev-md.c     |   47 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/filters/filter-md.c |    3 ++-
 2 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 76e3093..535259f 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -16,6 +16,9 @@
 #include "lib.h"
 #include "dev-type.h"
 #include "xlate.h"
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h> /* for MD detection using udev db records */
+#endif
 
 #ifdef __linux__
 
@@ -81,10 +84,31 @@ static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 	return sb_offset;
 }
 
+#ifdef UDEV_SYNC_SUPPORT
+static int _udev_dev_is_md(struct device *dev)
+{
+	const char *value;
+	struct dev_ext *ext;
+
+	if (!(ext = dev_ext_get(dev)))
+		return_0;
+
+	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_FS_TYPE")))
+		return 0;
+
+	return !strcmp(value, "linux_raid_member");
+}
+#else
+static int _udev_dev_is_md(struct device *dev)
+{
+	return 0;
+}
+#endif
+
 /*
  * Returns -1 on error
  */
-int dev_is_md(struct device *dev, uint64_t *offset_found)
+static int _native_dev_is_md(struct device *dev, uint64_t *offset_found)
 {
 	int ret = 1;
 	md_minor_version_t minor;
@@ -129,6 +153,27 @@ out:
 	return ret;
 }
 
+int dev_is_md(struct device *dev, uint64_t *offset_found)
+{
+
+	/*
+	 * If non-native device status source is selected, use it
+	 * only if offset_found is not requested as this
+	 * information is not in udev db.
+	 */
+	if ((dev->ext.src == DEV_EXT_NONE) || offset_found)
+		return _native_dev_is_md(dev, offset_found);
+
+	if (dev->ext.src == DEV_EXT_UDEV)
+		return _udev_dev_is_md(dev);
+
+	log_error(INTERNAL_ERROR "Missing hook for MD device recognition "
+		  "using external device info source %s", dev_ext_name(dev));
+
+	return -1;
+
+}
+
 static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 					struct dev_types *dt,
 					struct device *blkdev,
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index fe79f3d..ad9f540 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -29,7 +29,8 @@ static int _ignore_md(struct dev_filter *f __attribute__((unused)),
 	ret = dev_is_md(dev, NULL);
 
 	if (ret == 1) {
-		log_debug_devs("%s: Skipping md component device", dev_name(dev));
+		log_debug_devs("%s: Skipping md component device [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
 		return 0;
 	}
 


