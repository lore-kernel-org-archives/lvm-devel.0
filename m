From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Dec 2018 15:05:28 -0500
Subject: master - devs: use udev info to improve md component detection
Message-ID: <201812032005.wB3K5SY9014386@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a063d2d123c56c4ccead986625a260df16556b9f
Commit:        a063d2d123c56c4ccead986625a260df16556b9f
Parent:        5a5e3bcf153eddc6a03554e26f6f8d795fead96e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 3 11:22:45 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 3 12:58:28 2018 -0600

devs: use udev info to improve md component detection

Use udev info to supplement native md component detection.
---
 lib/device/dev-md.c     |   14 +++++++++-
 lib/device/dev-type.c   |   62 +++++++++++++++++++++++++++++++++++++---------
 lib/device/dev-type.h   |    1 +
 lib/filters/filter-md.c |    1 +
 4 files changed, 64 insertions(+), 14 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 9c626dd..15e1280 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -190,14 +190,24 @@ out:
 
 int dev_is_md(struct device *dev, uint64_t *offset_found, int full)
 {
+	int ret;
 
 	/*
 	 * If non-native device status source is selected, use it
 	 * only if offset_found is not requested as this
 	 * information is not in udev db.
 	 */
-	if ((dev->ext.src == DEV_EXT_NONE) || offset_found)
-		return _native_dev_is_md(dev, offset_found, full);
+	if ((dev->ext.src == DEV_EXT_NONE) || offset_found) {
+		ret = _native_dev_is_md(dev, offset_found, full);
+
+		if (!full) {
+			if (!ret || (ret == -EAGAIN)) {
+				if (udev_dev_is_md_component(dev))
+					return 1;
+			}
+		}
+		return ret;
+	}
 
 	if (dev->ext.src == DEV_EXT_UDEV)
 		return _udev_dev_is_md(dev);
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 1f74fdc..693550a 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1047,25 +1047,23 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev)
  *        failed already due to timeout in udev - in both cases the
  *        udev_device_get_is_initialized returns 0.
  */
-#define UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT 100
-#define UDEV_DEV_IS_MPATH_COMPONENT_USLEEP 100000
+#define UDEV_DEV_IS_COMPONENT_ITERATION_COUNT 100
+#define UDEV_DEV_IS_COMPONENT_USLEEP 100000
 
-int udev_dev_is_mpath_component(struct device *dev)
+static struct udev_device *_udev_get_dev(struct device *dev)
 {
 	struct udev *udev_context = udev_get_library_context();
 	struct udev_device *udev_device = NULL;
-	const char *value;
 	int initialized = 0;
 	unsigned i = 0;
-	int ret = 0;
 
 	if (!udev_context) {
 		log_warn("WARNING: No udev context available to check if device %s is multipath component.", dev_name(dev));
-		return 0;
+		return NULL;
 	}
 
 	while (1) {
-		if (i >= UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT)
+		if (i >= UDEV_DEV_IS_COMPONENT_ITERATION_COUNT)
 			break;
 
 		if (udev_device)
@@ -1073,7 +1071,7 @@ int udev_dev_is_mpath_component(struct device *dev)
 
 		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
 			log_warn("WARNING: Failed to get udev device handler for device %s.", dev_name(dev));
-			return 0;
+			return NULL;
 		}
 
 #ifdef HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED
@@ -1085,19 +1083,32 @@ int udev_dev_is_mpath_component(struct device *dev)
 #endif
 
 		log_debug("Device %s not initialized in udev database (%u/%u, %u microseconds).", dev_name(dev),
-			   i + 1, UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT,
-			   i * UDEV_DEV_IS_MPATH_COMPONENT_USLEEP);
+			   i + 1, UDEV_DEV_IS_COMPONENT_ITERATION_COUNT,
+			   i * UDEV_DEV_IS_COMPONENT_USLEEP);
 
-		usleep(UDEV_DEV_IS_MPATH_COMPONENT_USLEEP);
+		usleep(UDEV_DEV_IS_COMPONENT_USLEEP);
 		i++;
 	}
 
 	if (!initialized) {
 		log_warn("WARNING: Device %s not initialized in udev database even after waiting %u microseconds.",
-			  dev_name(dev), i * UDEV_DEV_IS_MPATH_COMPONENT_USLEEP);
+			  dev_name(dev), i * UDEV_DEV_IS_COMPONENT_USLEEP);
 		goto out;
 	}
 
+out:
+	return udev_device;
+}
+
+int udev_dev_is_mpath_component(struct device *dev)
+{
+	struct udev_device *udev_device;
+	const char *value;
+	int ret = 0;
+
+	if (!(udev_device = _udev_get_dev(dev)))
+		return 0;
+
 	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
 	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
 		log_debug("Device %s is multipath component based on blkid variable in udev db (%s=\"%s\").",
@@ -1117,6 +1128,28 @@ out:
 	udev_device_unref(udev_device);
 	return ret;
 }
+
+int udev_dev_is_md_component(struct device *dev)
+{
+	struct udev_device *udev_device;
+	const char *value;
+	int ret = 0;
+
+	if (!(udev_device = _udev_get_dev(dev)))
+		return 0;
+
+	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
+	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID)) {
+		log_debug("Device %s is md raid component based on blkid variable in udev db (%s=\"%s\").",
+			   dev_name(dev), DEV_EXT_UDEV_BLKID_TYPE, value);
+		ret = 1;
+		goto out;
+	}
+out:
+	udev_device_unref(udev_device);
+	return ret;
+}
+
 #else
 
 int udev_dev_is_mpath_component(struct device *dev)
@@ -1124,4 +1157,9 @@ int udev_dev_is_mpath_component(struct device *dev)
 	return 0;
 }
 
+int udev_dev_is_md_component(struct device *dev)
+{
+	return 0;
+}
+
 #endif
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index e8f0fcb..75539e8 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -62,6 +62,7 @@ int dev_is_swap(struct device *dev, uint64_t *signature, int full);
 int dev_is_luks(struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
 int udev_dev_is_mpath_component(struct device *dev);
+int udev_dev_is_md_component(struct device *dev);
 
 int dev_is_lvm1(struct device *dev, char *buf, int buflen);
 int dev_is_pool(struct device *dev, char *buf, int buflen);
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 0275923..9cc1a06 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -106,6 +106,7 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 		return 1;
 
 	if (ret == 1) {
+		log_debug_devs("md filter full %d excluding md component %s", cmd->use_full_md_check, dev_name(dev));
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
 		else


