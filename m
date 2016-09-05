From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  5 Sep 2016 11:19:41 +0000 (UTC)
Subject: master - refactor: move and rename _dev_is_mpath_component in lvmetad.c to udev_dev_is_mpath_component in dev-type.c
Message-ID: <20160905111941.21828601D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d323c37f3e0324e2599cb98dbb2969cffa41805
Commit:        5d323c37f3e0324e2599cb98dbb2969cffa41805
Parent:        29d03175574580424b634ac677336dbf8d14d9dd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 5 12:13:10 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 5 12:55:25 2016 +0200

refactor: move and rename _dev_is_mpath_component in lvmetad.c to udev_dev_is_mpath_component in dev-type.c

---
 WHATS_NEW             |    1 +
 lib/cache/lvmetad.c   |   64 +----------------------------------------------
 lib/device/dev-type.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h |    1 +
 4 files changed, 69 insertions(+), 63 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3f7eaf1..4cee0e4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Use udev db to check for mpath components before running pvscan for lvmetad.
   Use lsblk -s and lsblk -O in lvmdump only if these options are supported.
   Fix number of stripes shown in lvcreate raid10 message when too many.
   Do not monitor cache-pool metadata when LV is just being cleared.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a7d330c..94cc67d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2040,64 +2040,6 @@ out:
 	return vg_ret;
 }
 
-#ifdef UDEV_SYNC_SUPPORT
-static int _dev_is_mpath_component(struct udev *udev_context, struct device *dev)
-{
-	struct udev_device *udev_device = NULL;
-	const char *value;
-	int initialized = 0;
-	int i;
-	int ret = 0;
-
-	if (!udev_context) {
-		log_debug("_dev_is_mpath_component: device %s: no udev context", dev_name(dev));
-		return_0;
-	}
-	
-	for (i = 1; i <= 10; i++) {
-		if (udev_device)
-			udev_device_unref(udev_device);
-
-		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
-			log_debug("_dev_is_mpath_component: device %s: no udev device", dev_name(dev));
-			return 0;
-		}
-
-		if (udev_device_get_is_initialized(udev_device)) {
-			initialized = 1;
-			break;
-		} else {
-			log_debug("_dev_is_mpath_component: device %s: not initialized (%d)", dev_name(dev), i);
-			initialized = 0;
-		}
-		usleep(100000);
-	}
-
-	if (!initialized) {
-		log_debug("_dev_is_mpath_component: device %s: not initialized even after waiting", dev_name(dev));
-		goto_out;
-	}
-
-	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
-
-	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
-		log_debug("Dev %s is mpath component (%s)", dev_name(dev), value);
-		ret = 1;
-		goto out;
-	}
-
-	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
-	if (value && !strcmp(value, "1")) {
-		log_debug("Dev %s is mpath component (device path)", dev_name(dev));
-		ret = 1;
-		goto out;
-	}
-out:
-	udev_device_unref(udev_device);
-	return ret;
-}
-#endif
-
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  struct dm_list *found_vgnames,
 			  struct dm_list *changed_vgnames)
@@ -2113,14 +2055,10 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		return 0;
 	}
 
-#ifdef UDEV_SYNC_SUPPORT
-	struct udev *udev_context = udev_get_library_context();
-
-	if (_dev_is_mpath_component(udev_context, dev)) {
+	if (udev_dev_is_mpath_component(dev)) {
 		log_debug("Ignore multipath component for pvscan.");
 		return 1;
 	}
-#endif
 
 	if (!label_read(dev, &label, 0)) {
 		log_print_unless_silent("No PV label found on %s.", dev_name(dev));
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 0246c09..07c6346 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -976,3 +976,69 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev)
 	return 1;
 }
 #endif
+
+#ifdef UDEV_SYNC_SUPPORT
+int udev_dev_is_mpath_component(struct device *dev)
+{
+	struct udev *udev_context = udev_get_library_context();
+	struct udev_device *udev_device = NULL;
+	const char *value;
+	int initialized = 0;
+	int i;
+	int ret = 0;
+
+	if (!udev_context) {
+		log_debug("udev_dev_is_mpath_component: device %s: no udev context", dev_name(dev));
+		return_0;
+	}
+
+	for (i = 1; i <= 10; i++) {
+		if (udev_device)
+			udev_device_unref(udev_device);
+
+		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
+			log_debug("udev_dev_is_mpath_component: device %s: no udev device", dev_name(dev));
+			return 0;
+		}
+
+		if (udev_device_get_is_initialized(udev_device)) {
+			initialized = 1;
+			break;
+		} else {
+			log_debug("udev_dev_is_mpath_component: device %s: not initialized (%d)", dev_name(dev), i);
+			initialized = 0;
+		}
+		usleep(100000);
+	}
+
+	if (!initialized) {
+		log_debug("udev_dev_is_mpath_component: device %s: not initialized even after waiting", dev_name(dev));
+		goto_out;
+	}
+
+	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
+
+	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
+		log_debug("Dev %s is mpath component (%s)", dev_name(dev), value);
+		ret = 1;
+		goto out;
+	}
+
+	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
+	if (value && !strcmp(value, "1")) {
+		log_debug("Dev %s is mpath component (%s)", dev_name(dev), DEV_EXT_UDEV_MPATH_DEVICE_PATH);
+		ret = 1;
+		goto out;
+	}
+out:
+	udev_device_unref(udev_device);
+	return ret;
+}
+#else
+
+int udev_dev_is_mpath_component(struct device *dev)
+{
+	return 0;
+}
+
+#endif
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 267b79f..33622fe 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -59,6 +59,7 @@ int dev_is_md(struct device *dev, uint64_t *sb);
 int dev_is_swap(struct device *dev, uint64_t *signature);
 int dev_is_luks(struct device *dev, uint64_t *signature);
 int dasd_is_cdl_formatted(struct device *dev);
+int udev_dev_is_mpath_component(struct device *dev);
 
 /* Signature wiping. */
 #define TYPE_LVM1_MEMBER	0x001


