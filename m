From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  5 Sep 2016 12:37:54 +0000 (UTC)
Subject: master - dev-type: use more appropriate messages in udev_dev_is_mpath_component and use 10s timeout
Message-ID: <20160905123754.A427A60AD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7b282c6013c6317e9b092d56652cd4b7e43deef
Commit:        d7b282c6013c6317e9b092d56652cd4b7e43deef
Parent:        5d323c37f3e0324e2599cb98dbb2969cffa41805
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 5 14:31:09 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 5 14:37:13 2016 +0200

dev-type: use more appropriate messages in udev_dev_is_mpath_component and use 10s timeout

---
 lib/device/dev-type.c |   58 +++++++++++++++++++++++++++++++++++-------------
 1 files changed, 42 insertions(+), 16 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 07c6346..f1828f4 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -978,55 +978,81 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev)
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
+
+/*
+ * Udev daemon usually has 30s timeout to process each event by default.
+ * But still, that value can be changed in udev configuration and we
+ * don't have libudev API to read the actual timeout value used.
+ */
+
+/* FIXME: Is this long enough to wait for udev db to get initialized?
+ *
+ *        Take also into consideration that this check is done for each
+ *        device that is scanned so we don't want to wait for a long time
+ *        if there's something wrong with udev, e.g. timeouts! With current
+ *        libudev API, we can't recognize whether the event processing has
+ *        not finished yet and it's still being processed or whether it has
+ *        failed already due to timeout in udev - in both cases the
+ *        udev_device_get_is_initialized returns 0.
+ */
+#define UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT 100
+#define UDEV_DEV_IS_MPATH_COMPONENT_USLEEP 100000
+
 int udev_dev_is_mpath_component(struct device *dev)
 {
 	struct udev *udev_context = udev_get_library_context();
 	struct udev_device *udev_device = NULL;
 	const char *value;
 	int initialized = 0;
-	int i;
+	unsigned i = 0;
 	int ret = 0;
 
 	if (!udev_context) {
-		log_debug("udev_dev_is_mpath_component: device %s: no udev context", dev_name(dev));
+		log_warn("WARNING: No udev context available to check if device %s is multipath component.", dev_name(dev));
 		return_0;
 	}
 
-	for (i = 1; i <= 10; i++) {
+	while (1) {
+		if (i >= UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT)
+			break;
+
 		if (udev_device)
 			udev_device_unref(udev_device);
 
 		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
-			log_debug("udev_dev_is_mpath_component: device %s: no udev device", dev_name(dev));
+			log_warn("WARNING: Failed to get udev device handler for device %s.", dev_name(dev));
 			return 0;
 		}
 
-		if (udev_device_get_is_initialized(udev_device)) {
-			initialized = 1;
+		if ((initialized = udev_device_get_is_initialized(udev_device)))
 			break;
-		} else {
-			log_debug("udev_dev_is_mpath_component: device %s: not initialized (%d)", dev_name(dev), i);
-			initialized = 0;
-		}
-		usleep(100000);
+
+		log_debug("Device %s not initialized in udev database (%u/%u, %u microseconds).", dev_name(dev),
+			   i + 1, UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT,
+			   i * UDEV_DEV_IS_MPATH_COMPONENT_USLEEP);
+
+		usleep(UDEV_DEV_IS_MPATH_COMPONENT_USLEEP);
+		i++;
 	}
 
 	if (!initialized) {
-		log_debug("udev_dev_is_mpath_component: device %s: not initialized even after waiting", dev_name(dev));
-		goto_out;
+		log_warn("WARNING: Device %s not initialized in udev database even after waiting %u microseconds.",
+			  dev_name(dev), i * UDEV_DEV_IS_MPATH_COMPONENT_USLEEP);
+		goto out;
 	}
 
 	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
-
 	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
-		log_debug("Dev %s is mpath component (%s)", dev_name(dev), value);
+		log_debug("Device %s is multipath component based on blkid variable in udev db (%s=\"%s\").",
+			   dev_name(dev), DEV_EXT_UDEV_BLKID_TYPE, value);
 		ret = 1;
 		goto out;
 	}
 
 	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
 	if (value && !strcmp(value, "1")) {
-		log_debug("Dev %s is mpath component (%s)", dev_name(dev), DEV_EXT_UDEV_MPATH_DEVICE_PATH);
+		log_debug("Device %s is multipath component based on multipath variable in udev db (%s=\"%s\").",
+			   dev_name(dev), DEV_EXT_UDEV_MPATH_DEVICE_PATH, value);
 		ret = 1;
 		goto out;
 	}


