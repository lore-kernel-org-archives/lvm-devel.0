From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 13:21:23 -0400
Subject: master - hints: exclude md components
Message-ID: <201905211721.x4LHLNn1013679@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60bf9c9f331fb0282b1ceca57148aad54cb943a0
Commit:        60bf9c9f331fb0282b1ceca57148aad54cb943a0
Parent:        6422b9ddc5c46968e2bef6ced12cd38e0b44c49d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 11:58:01 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 11:58:01 2019 -0500

hints: exclude md components

In some cases md components could be included in
the hints, so add a check to hint creation to make
sure they are excluded.
---
 lib/device/dev-md.c   |   12 +++++++++---
 lib/device/dev-type.c |    1 +
 lib/device/device.h   |    1 +
 lib/label/hints.c     |    5 +++++
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index ab93206..261f3f1 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -216,14 +216,20 @@ int dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
 		if (!full) {
 			if (!ret || (ret == -EAGAIN)) {
 				if (udev_dev_is_md_component(dev))
-					return 1;
+					ret = 1;
 			}
 		}
+		if (ret && (ret != -EAGAIN))
+			dev->flags |= DEV_IS_MD_COMPONENT;
 		return ret;
 	}
 
-	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_dev_is_md_component(dev);
+	if (dev->ext.src == DEV_EXT_UDEV) {
+		ret = _udev_dev_is_md_component(dev);
+		if (ret && (ret != -EAGAIN))
+			dev->flags |= DEV_IS_MD_COMPONENT;
+		return ret;
+	}
 
 	log_error(INTERNAL_ERROR "Missing hook for MD device recognition "
 		  "using external device info source %s", dev_ext_name(dev));
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index f0faa3d..73e55ca 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1180,6 +1180,7 @@ int udev_dev_is_md_component(struct device *dev)
 	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID)) {
 		log_debug("Device %s is md raid component based on blkid variable in udev db (%s=\"%s\").",
 			   dev_name(dev), DEV_EXT_UDEV_BLKID_TYPE, value);
+		dev->flags |= DEV_IS_MD_COMPONENT;
 		ret = 1;
 		goto out;
 	}
diff --git a/lib/device/device.h b/lib/device/device.h
index afeee7f..395405a 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -36,6 +36,7 @@
 #define DEV_FILTER_OUT_SCAN	0x00004000	/* filtered out during label scan */
 #define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
 #define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
+#define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
 
 /*
  * Support for external device info.
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 00bfbe3..72dc91e 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -901,6 +901,11 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 		if (!(dev->flags & DEV_SCAN_FOUND_LABEL))
 			continue;
 
+		if (dev->flags & DEV_IS_MD_COMPONENT) {
+			log_debug("exclude md component from hints %s", dev_name(dev));
+			continue;
+		}
+
 		/*
 		 * No vgname will be found here for a PV with no mdas,
 		 * in which case the vgname hint will be incomplete.


