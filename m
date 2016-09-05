From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  5 Sep 2016 11:19:39 +0000 (UTC)
Subject: master - lvmetad: check udev for mpath component several times if udev record not initialized yet
Message-ID: <20160905111939.02F8260D8A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29d03175574580424b634ac677336dbf8d14d9dd
Commit:        29d03175574580424b634ac677336dbf8d14d9dd
Parent:        939f5310b9e58a560247c44cbd8a8f8af86aae7c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 5 11:33:08 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 5 12:43:11 2016 +0200

lvmetad: check udev for mpath component several times if udev record not initialized yet

It's possible (mainly during boot) that udev has not finished
processing the device and hence the udev database record for that
device is still marked as uninitialized when we're trying to look
at it as part of multipath component check in pvscan --cache code.

So check several times with a short delay to wait for the udev db
record to be initialized before giving up completely.
---
 lib/cache/lvmetad.c |   32 ++++++++++++++++++++++++++------
 1 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c31219e..a7d330c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2043,23 +2043,43 @@ out:
 #ifdef UDEV_SYNC_SUPPORT
 static int _dev_is_mpath_component(struct udev *udev_context, struct device *dev)
 {
-	struct udev_device *udev_device;
+	struct udev_device *udev_device = NULL;
 	const char *value;
+	int initialized = 0;
+	int i;
 	int ret = 0;
 
-	if (!udev_context)
+	if (!udev_context) {
+		log_debug("_dev_is_mpath_component: device %s: no udev context", dev_name(dev));
 		return_0;
+	}
 	
-	if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
-		return_0;
+	for (i = 1; i <= 10; i++) {
+		if (udev_device)
+			udev_device_unref(udev_device);
+
+		if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
+			log_debug("_dev_is_mpath_component: device %s: no udev device", dev_name(dev));
+			return 0;
+		}
+
+		if (udev_device_get_is_initialized(udev_device)) {
+			initialized = 1;
+			break;
+		} else {
+			log_debug("_dev_is_mpath_component: device %s: not initialized (%d)", dev_name(dev), i);
+			initialized = 0;
+		}
+		usleep(100000);
 	}
 
-	if (!udev_device_get_is_initialized(udev_device)) {
-		ret = 0;
+	if (!initialized) {
+		log_debug("_dev_is_mpath_component: device %s: not initialized even after waiting", dev_name(dev));
 		goto_out;
 	}
 
 	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
+
 	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
 		log_debug("Dev %s is mpath component (%s)", dev_name(dev), value);
 		ret = 1;


