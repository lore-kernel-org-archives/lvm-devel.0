From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:31:53 +0000 (UTC)
Subject: master - device: add infrastructure to support external device info
Message-ID: <20150130123153.251DF61152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fbfde21e7cdc770f0a1189d40f983aa046d605bb
Commit:        fbfde21e7cdc770f0a1189d40f983aa046d605bb
Parent:        578b236a19fab565a4416b17cbc26d53a72b66db
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 12 12:55:41 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:01:12 2015 +0100

device: add infrastructure to support external device info

---
 lib/Makefile.in        |    1 +
 lib/device/dev-cache.c |    3 +
 lib/device/dev-ext.c   |  164 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h    |   27 ++++++++
 4 files changed, 195 insertions(+), 0 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index bad5d8c..99cc0fe 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -56,6 +56,7 @@ SOURCES =\
 	datastruct/btree.c \
 	datastruct/str_list.c \
 	device/dev-cache.c \
+	device/dev-ext.c \
 	device/dev-io.c \
 	device/dev-md.c \
 	device/dev-swap.c \
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index ba4ee54..7ad9fb8 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -64,6 +64,9 @@ static void _dev_init(struct device *dev, int max_error_count)
 	dev->read_ahead = -1;
 	dev->max_error_count = max_error_count;
 
+	dev->ext.enabled = 0;
+	dev->ext.src = DEV_EXT_NONE;
+
 	dm_list_init(&dev->aliases);
 	dm_list_init(&dev->open_list);
 }
diff --git a/lib/device/dev-ext.c b/lib/device/dev-ext.c
new file mode 100644
index 0000000..8f2024e
--- /dev/null
+++ b/lib/device/dev-ext.c
@@ -0,0 +1,164 @@
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
+#include "device.h"
+
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#endif
+
+struct ext_registry_item {
+	const char *name;
+	struct dev_ext *(* dev_ext_get) (struct device *dev);
+	int (*dev_ext_release) (struct device *dev);
+};
+
+#define EXT_REGISTER(id,name) [id] = { #name, &_dev_ext_get_ ## name, &_dev_ext_release_ ## name }
+
+/*
+ * DEV_EXT_NONE
+ */
+static struct dev_ext *_dev_ext_get_none(struct device *dev)
+{
+	dev->ext.handle = NULL;
+	return &dev->ext;
+}
+
+static int _dev_ext_release_none(struct device *dev)
+{
+	dev->ext.handle = NULL;
+	return 1;
+}
+
+/*
+ * DEV_EXT_UDEV
+ */
+static struct dev_ext *_dev_ext_get_udev(struct device *dev)
+{
+#ifdef UDEV_SYNC_SUPPORT
+	struct udev *udev;
+	struct udev_device *udev_device;
+
+	if (dev->ext.handle)
+		return &dev->ext;
+
+	if (!(udev = udev_get_library_context()))
+		return_NULL;
+
+	if (!(udev_device = udev_device_new_from_devnum(udev, 'b', dev->dev)))
+		return_NULL;
+
+	dev->ext.handle = (void *) udev_device;
+	return &dev->ext;
+#else
+	return NULL;
+#endif
+}
+
+static int _dev_ext_release_udev(struct device *dev)
+{
+#ifdef UDEV_SYNC_SUPPORT
+	if (!dev->ext.handle)
+		return 1;
+
+	/* udev_device_unref can't fail - it has no return value */
+	udev_device_unref((struct udev_device *) dev->ext.handle);
+	dev->ext.handle = NULL;
+	return 1;
+#else
+	return 0;
+#endif
+}
+
+static struct ext_registry_item _ext_registry[DEV_EXT_NUM] = {
+	EXT_REGISTER(DEV_EXT_NONE, none),
+	EXT_REGISTER(DEV_EXT_UDEV, udev)
+};
+
+const char *dev_ext_name(struct device *dev)
+{
+	return _ext_registry[dev->ext.src].name;
+}
+
+static const char *_ext_attached_msg = "External handle attached to device";
+
+struct dev_ext *dev_ext_get(struct device *dev)
+{
+	struct dev_ext *ext;
+	void *handle_ptr;
+
+	handle_ptr = dev->ext.handle;
+
+	if (!(ext = _ext_registry[dev->ext.src].dev_ext_get(dev)))
+		log_error("Failed to get external handle for device %s [%s].",
+			   dev_name(dev), dev_ext_name(dev));
+	else if (handle_ptr != dev->ext.handle)
+		log_debug_devs("%s %s [%s:%p]", _ext_attached_msg, dev_name(dev),
+				dev_ext_name(dev), dev->ext.handle);
+
+	return ext;
+}
+
+int dev_ext_release(struct device *dev)
+{
+	int r;
+	void *handle_ptr;
+
+	if (!dev->ext.enabled ||
+	    !dev->ext.handle)
+		return 1;
+
+	handle_ptr = dev->ext.handle;
+
+	if (!(r = _ext_registry[dev->ext.src].dev_ext_release(dev)))
+		log_error("Failed to release external handle for device %s [%s:%p].",
+			  dev_name(dev), dev_ext_name(dev), dev->ext.handle);
+	else
+		log_debug_devs("External handle detached from device %s [%s:%p]",
+				dev_name(dev), dev_ext_name(dev), handle_ptr);
+
+	return r;
+}
+
+int dev_ext_enable(struct device *dev, dev_ext_t src)
+{
+	if (dev->ext.enabled && (dev->ext.src != src) && !dev_ext_release(dev)) {
+		log_error("Failed to enable external handle for device %s [%s].",
+			   dev_name(dev), _ext_registry[src].name); 
+		return 0;
+	}
+
+	dev->ext.src = src;
+	dev->ext.enabled = 1;
+
+	return 1;
+}
+
+int dev_ext_disable(struct device *dev)
+{
+	if (!dev->ext.enabled)
+		return 1;
+
+	if (!dev_ext_release(dev)) {
+		log_error("Failed to disable external handle for device %s [%s].",
+			   dev_name(dev), dev_ext_name(dev));
+		return 0;
+	}
+
+	dev->ext.enabled = 0;
+	dev->ext.src = DEV_EXT_NONE;
+
+	return 1;
+}
diff --git a/lib/device/device.h b/lib/device/device.h
index c916a4b..0d38f96 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -29,6 +29,23 @@
 #define DEV_O_DIRECT_TESTED	0x00000040	/* DEV_O_DIRECT is reliable */
 
 /*
+ * Support for external device info.
+ * Any new external device info source needs to be
+ * registered using EXT_REGISTER macro in dev-ext.c.
+ */
+typedef enum {
+	DEV_EXT_NONE,
+	DEV_EXT_UDEV,
+	DEV_EXT_NUM
+} dev_ext_t;
+
+struct dev_ext {
+	int enabled;
+	dev_ext_t src;
+	void *handle;
+};
+
+/*
  * All devices in LVM will be represented by one of these.
  * pointer comparisons are valid.
  */
@@ -47,6 +64,7 @@ struct device {
 	uint32_t flags;
 	uint64_t end;
 	struct dm_list open_list;
+	struct dev_ext ext;
 
 	char pvid[ID_LEN + 1];
 	char _padding[7];
@@ -64,6 +82,15 @@ struct device_area {
 };
 
 /*
+ * Support for external device info.
+ */
+const char *dev_ext_name(struct device *dev);
+int dev_ext_enable(struct device *dev, dev_ext_t src);
+int dev_ext_disable(struct device *dev);
+struct dev_ext *dev_ext_get(struct device *dev);
+int dev_ext_release(struct device *dev);
+
+/*
  * All io should use these routines.
  */
 int dev_get_block_size(struct device *dev, unsigned int *phys_block_size, unsigned int *block_size);


