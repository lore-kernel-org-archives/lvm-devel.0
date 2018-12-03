From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Dec 2018 12:06:52 -0500
Subject: 2018-06-01-stable - pvscan lvmetad: use udev info to improve md component detection
Message-ID: <201812031706.wB3H6q4t018424@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a188b1e513ed5ca0f5f3702c823490f5610d4495
Commit:        a188b1e513ed5ca0f5f3702c823490f5610d4495
Parent:        9764ee0b3f21ed717e1b6248ce4c41dd552bb0ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 30 16:32:32 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 3 11:05:35 2018 -0600

pvscan lvmetad: use udev info to improve md component detection

When no md devs are started, pvscan will only scan the start of
an md component, and if it has a superblock at the end may not
exclude it.  udev may already have info identifying it as an
md component, so use that.
---
 lib/device/dev-md.c   |   14 +++++++++-
 lib/device/dev-type.c |   62 +++++++++++++++++++++++++++++++++++++++---------
 lib/device/dev-type.h |    1 +
 lib/label/label.c     |    6 ++++
 tools/pvscan.c        |    3 +-
 5 files changed, 71 insertions(+), 15 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 185499b..9728507 100644
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
index af4b407..33ebb73 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1004,25 +1004,23 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev)
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
@@ -1030,7 +1028,7 @@ int udev_dev_is_mpath_component(struct device *dev)
 
 		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
 			log_warn("WARNING: Failed to get udev device handler for device %s.", dev_name(dev));
-			return 0;
+			return NULL;
 		}
 
 #ifdef HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED
@@ -1042,19 +1040,32 @@ int udev_dev_is_mpath_component(struct device *dev)
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
@@ -1074,6 +1085,28 @@ out:
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
@@ -1081,4 +1114,9 @@ int udev_dev_is_mpath_component(struct device *dev)
 	return 0;
 }
 
+int udev_dev_is_md_component(struct device *dev)
+{
+	return 0;
+}
+
 #endif
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index f629a02..2644383 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -62,6 +62,7 @@ int dev_is_swap(struct device *dev, uint64_t *signature, int full);
 int dev_is_luks(struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
 int udev_dev_is_mpath_component(struct device *dev);
+int udev_dev_is_md_component(struct device *dev);
 
 int dev_is_lvm1(struct device *dev, char *buf, int buflen);
 int dev_is_pool(struct device *dev, char *buf, int buflen);
diff --git a/lib/label/label.c b/lib/label/label.c
index b26ff33..e01608d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -957,6 +957,12 @@ int label_scan_pvscan_all(struct cmd_context *cmd, struct dm_list *scan_devs)
 			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
 			_scan_dev_close(dev);
 		}
+
+		if (dev_is_md_with_end_superblock(cmd->dev_types, dev)) {
+			cmd->use_full_md_check = 1;
+			use_full_md_check = 1;
+			log_debug("Found md component in sysfs with end superblock %s", dev_name(dev));
+		}
 	};
 	dev_iter_destroy(iter);
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3755684..877b6b2 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -455,7 +455,8 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		if (dev_is_md_with_end_superblock(cmd->dev_types, dev)) {
 			cmd->use_full_md_check = 1;
 			use_full_md_check = 1;
-			log_debug("Found md with end superblock %s", dev_name(dev));
+			log_debug("Found md component in sysfs with end superblock %s", dev_name(dev));
+			break;
 		}
 	}
 	dev_iter_destroy(iter);


