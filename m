From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:32:01 +0000 (UTC)
Subject: master - filter-mpath: use new 'udev' external device info source to get mpath component status
Message-ID: <20150130123201.949C96109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c030e81a4e2d1e6b7024991c29114c59337553e
Commit:        9c030e81a4e2d1e6b7024991c29114c59337553e
Parent:        590fbd89618fa8fb2556c89c1d12b5deb5b5f1a4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 3 15:48:37 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:01:12 2015 +0100

filter-mpath: use new 'udev' external device info source to get mpath component status

mpath components are marked in udev db as:
  ID_FS_TYPE="mpath_member"
or
  DM_MULTIPATH_DEVICE_PATH="1"

(it depends on udev rule/blkid version used for handling mpath)
---
 lib/filters/filter-mpath.c |   48 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 0f12c73..fefc8e0 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -15,6 +15,9 @@
 #include "lib.h"
 #include "filter.h"
 #include "activate.h"
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
 
 #ifdef __linux__
 
@@ -141,7 +144,33 @@ static int _get_parent_mpath(const char *dir, char *name, int max_size)
 	return r;
 }
 
-static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
+#ifdef UDEV_SYNC_SUPPORT
+static int _udev_dev_is_mpath(struct device *dev)
+{
+	const char *value;
+	struct dev_ext *ext;
+
+	if (!(ext = dev_ext_get(dev)))
+		return_0;
+
+	value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_FS_TYPE");
+	if (value && !strcmp(value, "mpath_member"))
+		return 1;
+
+	value = udev_device_get_property_value((struct udev_device *)ext->handle, "DM_MULTIPATH_DEVICE_PATH");
+	if (value && !strcmp(value, "1"))
+		return 1;
+
+	return 0;
+}
+#else
+static int _udev_dev_is_mpath(struct device *dev)
+{
+	return 0;
+}
+#endif
+
+static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *part_name, *name;
@@ -200,10 +229,25 @@ static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 	return lvm_dm_prefix_check(major, minor, MPATH_PREFIX);
 }
 
+static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
+{
+	if (dev->ext.src == DEV_EXT_NONE)
+		return _native_dev_is_mpath(f, dev);
+
+	if (dev->ext.src == DEV_EXT_UDEV)
+		return _udev_dev_is_mpath(dev);
+
+	log_error(INTERNAL_ERROR "Missing hook for mpath recognition "
+		  "using external device info source %s", dev_ext_name(dev));
+
+	return 0;
+}
+
 static int _ignore_mpath(struct dev_filter *f, struct device *dev)
 {
 	if (_dev_is_mpath(f, dev) == 1) {
-		log_debug_devs("%s: Skipping mpath component device", dev_name(dev));
+		log_debug_devs("%s: Skipping mpath component device [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), dev->ext.handle);
 		return 0;
 	}
 


