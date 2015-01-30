From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:32:05 +0000 (UTC)
Subject: master - filter-partitioned: use new 'udev' device status source to get partition status
Message-ID: <20150130123205.C66D96107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=787f6ce04ab2d2420cda199c34fdd795153b593f
Commit:        787f6ce04ab2d2420cda199c34fdd795153b593f
Parent:        2fc126b00d83991c6a2f3ed9aa61457294a4c45e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 3 15:49:36 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:17:12 2015 +0100

filter-partitioned: use new 'udev' device status source to get partition status

Partitioned devices are marked in udev db as:
  ID_PART_TABLE="<partition table type name>"
and at the same time they are *not* marked with:
  ID_PART_ENTRY_DISK="<parent disk major:minor>"

Where partition table type name is dos/gpt/... But checking the presence
of this variable is enough for LVM here - it just needs to know whether
there's a partition table or not, not interested in the actual type.
The same applies for parent disk major:minor.
---
 lib/device/dev-type.c            |   59 ++++++++++++++++++++++++++++++++++++-
 lib/filters/filter-partitioned.c |   21 ++++---------
 2 files changed, 64 insertions(+), 16 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index dc8b61d..58bd177 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -25,6 +25,10 @@
 #include <blkid.h>
 #endif
 
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
+
 #include "device-types.h"
 
 struct dev_types *create_dev_types(const char *proc_dir,
@@ -324,8 +328,34 @@ static int _has_partition_table(struct device *dev)
 	return ret;
 }
 
-int dev_is_partitioned(struct dev_types *dt, struct device *dev)
+#ifdef UDEV_SYNC_SUPPORT
+static int _udev_dev_is_partitioned(struct device *dev)
+{
+	const char *value;
+	struct dev_ext *ext;
+
+	if (!(ext = dev_ext_get(dev)))
+		return_0;
+
+	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_PART_TABLE_TYPE")))
+		return 0;
+
+	if ((value = udev_device_get_property_value((struct udev_device *)ext->handle, "ID_PART_ENTRY_DISK")))
+		return 0;
+
+	return 1;
+}
+#else
+static int _udev_dev_is_partitioned(struct device *dev)
+{
+	return 0;
+}
+#endif
+
+static int _native_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 {
+	int r;
+
 	if (!_is_partitionable(dt, dev))
 		return 0;
 
@@ -333,7 +363,32 @@ int dev_is_partitioned(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->dasd_major)
 		return 1;
 
-	return _has_partition_table(dev);
+	if (!dev_open_readonly_quiet(dev)) {
+		log_debug_devs("%s: failed to open device, considering device "
+			       "is partitioned", dev_name(dev));
+		return 1;
+	}
+
+	r = _has_partition_table(dev);
+
+	if (!dev_close(dev))
+		stack;
+
+	return r;
+}
+
+int dev_is_partitioned(struct dev_types *dt, struct device *dev)
+{
+	if (dev->ext.src == DEV_EXT_NONE)
+		return _native_dev_is_partitioned(dt, dev);
+
+	if (dev->ext.src == DEV_EXT_UDEV)
+		return _udev_dev_is_partitioned(dev);
+
+	log_error(INTERNAL_ERROR "Missing hook for partition table recognition "
+		  "using external device info source %s", dev_ext_name(dev));
+
+	return 0;
 }
 
 /*
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 9a90557..2c21452 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -15,28 +15,21 @@
 
 #include "lib.h"
 #include "filter.h"
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
 
 static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
-	int ret = 0;
-
-	if (!dev_open_readonly_quiet(dev)) {
-		log_debug_devs("%s: Skipping: open failed", dev_name(dev));
-		return 0;
-	}
 
 	if (dev_is_partitioned(dt, dev)) {
-		log_debug_devs("%s: Skipping: Partition table signature found",
-			       dev_name(dev));
-		goto out;
+		log_debug_devs("%s: Skipping: Partition table signature found [%s:%p]",
+			       dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+		return 0;
 	}
 
-	ret = 1;
-out:
-	if (!dev_close(dev))
-		stack;
-	return ret;
+	return 1;
 }
 
 static void _partitioned_filter_destroy(struct dev_filter *f)


