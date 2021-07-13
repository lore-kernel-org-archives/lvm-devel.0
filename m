From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Jul 2021 16:11:34 +0000 (GMT)
Subject: main - filter-usable: remove udev dev size check
Message-ID: <20210713161134.DD2A8396E058@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=deaf43d6f0341d8d15e8ff5ffd25d7e0a7d2092a
Commit:        deaf43d6f0341d8d15e8ff5ffd25d7e0a7d2092a
Parent:        90485650931d3fc04d00c92a729050c8743969e5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 15 11:22:32 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 13 11:11:23 2021 -0500

filter-usable: remove udev dev size check

For the pv_min_size check, always use dev_get_size()
which is commonly used elsewhere, and don't bother
asking libudev for the device size when
external_device_info_source=udev.
---
 lib/filters/filter-usable.c | 77 +++------------------------------------------
 1 file changed, 4 insertions(+), 73 deletions(-)

diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 43a37afd0..062fb6c74 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -16,10 +16,6 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/activate/activate.h"
-#ifdef UDEV_SYNC_SUPPORT
-#include <libudev.h>
-#include "lib/device/dev-ext-udev-constants.h"
-#endif
 
 struct filter_data {
 	filter_mode_t mode;
@@ -28,7 +24,7 @@ struct filter_data {
 
 static const char *_too_small_to_hold_pv_msg = "Too small to hold a PV";
 
-static int _native_check_pv_min_size(struct device *dev)
+static int _check_pv_min_size(struct device *dev)
 {
 	uint64_t size;
 	int ret = 0;
@@ -50,61 +46,6 @@ out:
 	return ret;
 }
 
-#ifdef UDEV_SYNC_SUPPORT
-static int _udev_check_pv_min_size(struct device *dev)
-{
-	struct dev_ext *ext;
-	const char *size_str;
-	char *endp;
-	uint64_t size;
-
-	if (!(ext = dev_ext_get(dev)))
-		return_0;
-
-	if (!(size_str = udev_device_get_sysattr_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_SYSFS_ATTR_SIZE))) {
-		log_debug_devs("%s: Skipping: failed to get size from sysfs [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
-		return 0;
-	}
-
-	errno = 0;
-	size = strtoull(size_str, &endp, 10);
-	if (errno || !endp || *endp) {
-		log_debug_devs("%s: Skipping: failed to parse size from sysfs [%s:%p]",
-				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
-		return 0;
-	}
-
-	if (size < pv_min_size()) {
-		log_debug_devs("%s: Skipping: %s [%s:%p]", dev_name(dev),
-				_too_small_to_hold_pv_msg,
-				dev_ext_name(dev), dev->ext.handle);
-		return 0;
-	}
-
-	return 1;
-}
-#else
-static int _udev_check_pv_min_size(struct device *dev)
-{
-	return 1;
-}
-#endif
-
-static int _check_pv_min_size(struct device *dev)
-{
-	if (dev->ext.src == DEV_EXT_NONE)
-		return _native_check_pv_min_size(dev);
-
-	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_check_pv_min_size(dev);
-
-	log_error(INTERNAL_ERROR "Missing hook for PV min size check "
-		  "using external device info source %s", dev_ext_name(dev));
-
-	return 0;
-}
-
 static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	struct filter_data *data = f->private;
@@ -156,19 +97,9 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 	}
 
 	if (r) {
-		/* check if the device is not too small to hold a PV */
-		switch (mode) {
-		case FILTER_MODE_NO_LVMETAD:
-			/* fall through */
-		case FILTER_MODE_PRE_LVMETAD:
-			r = _check_pv_min_size(dev);
-			if (!r)
-				dev->filtered_flags |= DEV_FILTERED_MINSIZE;
-			break;
-		case FILTER_MODE_POST_LVMETAD:
-			/* nothing to do here */
-			break;
-		}
+		r = _check_pv_min_size(dev);
+		if (!r)
+			dev->filtered_flags |= DEV_FILTERED_MINSIZE;
 	}
 
 	return r;


