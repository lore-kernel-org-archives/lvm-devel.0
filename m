From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:32:03 +0000 (UTC)
Subject: master - filter-usable: move check for pv_min_size from filter-partitioned to filter-usable and use new 'udev' external device info source for this check
Message-ID: <20150130123203.ACF2260D3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fc126b00d83991c6a2f3ed9aa61457294a4c45e
Commit:        2fc126b00d83991c6a2f3ed9aa61457294a4c45e
Parent:        9c030e81a4e2d1e6b7024991c29114c59337553e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 29 14:24:06 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:01:12 2015 +0100

filter-usable: move check for pv_min_size from filter-partitioned to filter-usable and use new 'udev' external device info source for this check

The filter-partitioned code should contain only checks in "partition" domain.

The check for pv_min_size should actually be a part of filter-usable.
If the device size is less than pv_min_size, such device is not usable
as a PV so this check clearly belongs here logically.

With udev external info source, we can get device size via libudev's
sysfs reading interface and we can avoid opening the device this way
effectively.
---
 lib/filters/filter-partitioned.c |   22 +-------
 lib/filters/filter-usable.c      |  109 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 111 insertions(+), 20 deletions(-)

diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index e3caa0e..9a90557 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -19,39 +19,23 @@
 static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
-	const char *name = dev_name(dev);
 	int ret = 0;
-	uint64_t size;
 
-	/* Check it's accessible */
 	if (!dev_open_readonly_quiet(dev)) {
-		log_debug_devs("%s: Skipping: open failed", name);
+		log_debug_devs("%s: Skipping: open failed", dev_name(dev));
 		return 0;
 	}
 
-	/* Check it's not too small */
-	if (!dev_get_size(dev, &size)) {
-		log_debug_devs("%s: Skipping: dev_get_size failed", name);
-		goto out;
-	}
-
-	if (size < pv_min_size()) {
-		log_debug_devs("%s: Skipping: Too small to hold a PV", name);
-		goto out;
-	}
-
 	if (dev_is_partitioned(dt, dev)) {
 		log_debug_devs("%s: Skipping: Partition table signature found",
-			       name);
+			       dev_name(dev));
 		goto out;
 	}
 
 	ret = 1;
-
-      out:
+out:
 	if (!dev_close(dev))
 		stack;
-
 	return ret;
 }
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index f34a325..667cdac 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -15,6 +15,100 @@
 #include "lib.h"
 #include "filter.h"
 #include "activate.h" /* device_is_usable */
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
+
+static const char *_too_small_to_hold_pv_msg = "Too small to hold a PV";
+
+static int _native_check_pv_min_size(struct device *dev)
+{
+	uint64_t size;
+	int ret = 0;
+
+	/* Check it's accessible */
+	if (!dev_open_readonly_quiet(dev)) {
+		log_debug_devs("%s: Skipping: open failed [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		return 0;
+	}
+
+	/* Check it's not too small */
+	if (!dev_get_size(dev, &size)) {
+		log_debug_devs("%s: Skipping: dev_get_size failed [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		goto out;
+	}
+
+	if (size < pv_min_size()) {
+		log_debug_devs("%s: Skipping: %s [%s:%p]", dev_name(dev),
+				_too_small_to_hold_pv_msg,
+				dev_ext_name(dev), dev->ext.handle);
+		goto out;
+	}
+
+	ret = 1;
+out:
+	if (!dev_close(dev))
+		stack;
+
+	return ret;
+}
+
+#ifdef UDEV_SYNC_SUPPORT
+static int _udev_check_pv_min_size(struct device *dev)
+{
+	struct dev_ext *ext;
+	const char *size_str;
+	char *endp;
+	uint64_t size;
+
+	if (!(ext = dev_ext_get(dev)))
+		return_0;
+
+	if (!(size_str = udev_device_get_sysattr_value((struct udev_device *)ext->handle, "size"))) {
+		log_debug_devs("%s: Skipping: failed to get size from sysfs [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		return 0;
+	}
+
+	errno = 0;
+	size = strtoull(size_str, &endp, 10);
+	if (errno || !endp || *endp) {
+		log_debug_devs("%s: Skipping: failed to parse size from sysfs [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		return 0;
+	}
+
+	if (size < pv_min_size()) {
+		log_debug_devs("%s: Skipping: %s [%s:%p]", dev_name(dev),
+				_too_small_to_hold_pv_msg,
+				dev_ext_name(dev), dev->ext.handle);
+		return 0;
+	}
+
+	return 1;
+}
+#else
+static int _udev_check_pv_min_size(struct device *dev)
+{
+	return 1;
+}
+#endif
+
+static int _check_pv_min_size(struct device *dev)
+{
+	if (dev->ext.src == DEV_EXT_NONE)
+		return _native_check_pv_min_size(dev);
+
+	if (dev->ext.src == DEV_EXT_UDEV)
+		return _udev_check_pv_min_size(dev);
+
+	log_error(INTERNAL_ERROR "Missing hook for PV min size check "
+		  "using external device info source %s", dev_ext_name(dev));
+
+	return 0;
+}
 
 static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 {
@@ -22,7 +116,20 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 	struct dev_usable_check_params ucp = {0};
 	int r;
 
-	/* filter only device-mapper devices */
+	/* check if the device is not too small to hold a PV */
+	switch (mode) {
+		case FILTER_MODE_NO_LVMETAD:
+			/* fall through */
+		case FILTER_MODE_PRE_LVMETAD:
+			if (!_check_pv_min_size(dev))
+				return 0;
+			break;
+		case FILTER_MODE_POST_LVMETAD:
+			/* nothing to do here */
+			break;
+	}
+
+	/* further checks are done on dm devices only */
 	if (!dm_is_dm_major(MAJOR(dev->dev)))
 		return 1;
 


