From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Apr 2021 21:01:37 +0000 (GMT)
Subject: main - remove unused flag DEV_UDEV_INFO_MISSING
Message-ID: <20210416210137.E501E386102F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b94f2a8b552a6089774d5e65082b98cf9579dc6e
Commit:        b94f2a8b552a6089774d5e65082b98cf9579dc6e
Parent:        8daf5cd45f7767d9b0cfdfde67e95e23d21f859c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 16 16:01:19 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 16 16:01:19 2021 -0500

remove unused flag DEV_UDEV_INFO_MISSING

---
 lib/device/dev-md.c   | 5 +----
 lib/device/dev-type.c | 5 +----
 lib/device/device.h   | 5 ++---
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 3049b81b7..78a77a968 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -166,17 +166,14 @@ static int _udev_dev_is_md_component(struct device *dev)
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE))) {
-		dev->flags |= DEV_UDEV_INFO_MISSING;
+	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE)))
 		return 0;
-	}
 
 	return !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID);
 }
 #else
 static int _udev_dev_is_md_component(struct device *dev)
 {
-	dev->flags |= DEV_UDEV_INFO_MISSING;
 	return 0;
 }
 #endif
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 7cbb7fbed..1b335722d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1261,10 +1261,8 @@ int udev_dev_is_md_component(struct device *dev)
 	const char *value;
 	int ret = 0;
 
-	if (!obtain_device_list_from_udev()) {
-		dev->flags |= DEV_UDEV_INFO_MISSING;
+	if (!obtain_device_list_from_udev())
 		return 0;
-	}
 
 	if (!(udev_device = _udev_get_dev(dev)))
 		return 0;
@@ -1291,7 +1289,6 @@ int udev_dev_is_mpath_component(struct device *dev)
 
 int udev_dev_is_md_component(struct device *dev)
 {
-	dev->flags |= DEV_UDEV_INFO_MISSING;
 	return 0;
 }
 
diff --git a/lib/device/device.h b/lib/device/device.h
index aed1a0342..ca8b3cdd8 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -37,9 +37,8 @@
 #define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
 #define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
-#define DEV_UDEV_INFO_MISSING   0x00040000	/* we have no udev info for this device */
-#define DEV_IS_NVME		0x00080000	/* set if dev is nvme */
-#define DEV_MATCHED_USE_ID	0x00100000	/* matched an entry from cmd->use_devices */
+#define DEV_IS_NVME		0x00040000	/* set if dev is nvme */
+#define DEV_MATCHED_USE_ID	0x00080000	/* matched an entry from cmd->use_devices */
 
 /*
  * Support for external device info.


