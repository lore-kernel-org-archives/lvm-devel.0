From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Sep 2016 11:22:22 +0000 (UTC)
Subject: master - dev-type: check for DEVLINKS udev db variable existence if udev_device_get_is_initialized fn is not present
Message-ID: <20160906112223.0280960678@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8a14a29cdcf7e800af16f9b6a8fa9ed49250d30
Commit:        c8a14a29cdcf7e800af16f9b6a8fa9ed49250d30
Parent:        2e4821a847debe9a7c48b9dd0f218eff030dfce2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 6 13:12:02 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 6 13:21:29 2016 +0200

dev-type: check for DEVLINKS udev db variable existence if udev_device_get_is_initialized fn is not present

Older udev versions (udev < v165), don't have the official
udev_device_get_is_initialized function available to query for
device initialization state in udev database. Also, devices don't
have USEC_INITIALIZED udev db variable set - this is bound to the
udev_device_get_is_initialized fn functionality.

In this case, check for "DEVLINKS" variable instead - all block devices
have@least one symlink set for the node (the "/dev/block/<major:minor>".
This symlink is set by default basic udev rules provided by udev directly.
We'll use this as an alternative for the check that initial udev
processing for a device has already finished.
---
 lib/device/dev-ext-udev-constants.h |    3 +++
 lib/device/dev-type.c               |    5 +++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-ext-udev-constants.h b/lib/device/dev-ext-udev-constants.h
index 5b9a096..168f8f1 100644
--- a/lib/device/dev-ext-udev-constants.h
+++ b/lib/device/dev-ext-udev-constants.h
@@ -36,6 +36,9 @@
 #define DEV_EXT_UDEV_DEVTYPE			"DEVTYPE"
 #define DEV_EXT_UDEV_DEVTYPE_DISK		"disk"
 
+/* the list of symlinks associated with device node */
+#define DEV_EXT_UDEV_DEVLINKS			"DEVLINKS"
+
 /*
  * DEV_EXT_UDEV_MPATH_DEVICE_PATH is set by multipath in udev db
  * with value either 0 or 1. The same functionality as
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index f1828f4..32471aa 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1024,8 +1024,13 @@ int udev_dev_is_mpath_component(struct device *dev)
 			return 0;
 		}
 
+#ifdef HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED
 		if ((initialized = udev_device_get_is_initialized(udev_device)))
 			break;
+#else
+		if ((initialized = (udev_device_get_property_value(udev_device, DEV_EXT_UDEV_DEVLINKS) != NULL)))
+			break;
+#endif
 
 		log_debug("Device %s not initialized in udev database (%u/%u, %u microseconds).", dev_name(dev),
 			   i + 1, UDEV_DEV_IS_MPATH_COMPONENT_ITERATION_COUNT,


