From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Jun 2018 15:08:41 -0400
Subject: master - scan: work around udev problems by avoiding open RDWR
Message-ID: <201806201908.w5KJ8fLC024342@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=42f7caf1c267a5b75ee38ea77a7e2fd7c582e704
Commit:        42f7caf1c267a5b75ee38ea77a7e2fd7c582e704
Parent:        f85a010a6bc9dc0414ccdf9c6b195c78231f1914
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 20 11:32:45 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 20 14:08:12 2018 -0500

scan: work around udev problems by avoiding open RDWR

udev creates a train wreck of events if we open devices
with RDWR.  Until we can fix/disable/scrap udev, work around
this by opening RDONLY and then closing/reopening RDWR when
a write is needed.  This invalidates the bcache blocks for
the device before writing so it can trigger unnecessary
rereading.
---
 lib/device/device.h |    1 +
 lib/label/label.c   |   56 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/lib/device/device.h b/lib/device/device.h
index 00e398a..e879dbb 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -35,6 +35,7 @@
 #define DEV_BCACHE_EXCL		0x00001000      /* bcache_fd should be open EXCL */
 #define DEV_FILTER_AFTER_SCAN	0x00002000	/* apply filter after bcache has data */
 #define DEV_FILTER_OUT_SCAN	0x00004000	/* filtered out during label scan */
+#define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
 
 /*
  * Support for external device info.
diff --git a/lib/label/label.c b/lib/label/label.c
index 065c01f..d2c8685 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -467,12 +467,24 @@ static int _scan_dev_open(struct device *dev)
 	name_sl = dm_list_item(name_list, struct dm_str_list);
 	name = name_sl->str;
 
-	flags |= O_RDWR;
 	flags |= O_DIRECT;
 	flags |= O_NOATIME;
 
-	if (dev->flags & DEV_BCACHE_EXCL)
+	/*
+	 * FIXME: udev is a train wreck when we open RDWR and close, so we
+	 * need to only use RDWR when we actually need to write, and use
+	 * RDONLY otherwise.  Fix, disable or scrap udev nonsense so we can
+	 * just open with RDWR by default.
+	 */
+
+	if (dev->flags & DEV_BCACHE_EXCL) {
 		flags |= O_EXCL;
+		flags |= O_RDWR;
+	} else if (dev->flags & DEV_BCACHE_WRITE) {
+		flags |= O_RDWR;
+	} else {
+		flags |= O_RDONLY;
+	}
 
 retry_open:
 
@@ -1124,7 +1136,14 @@ int label_scan_open(struct device *dev)
 
 int label_scan_open_excl(struct device *dev)
 {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_EXCL)) {
+		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
+		log_debug("Close and reopen excl %s", dev_name(dev));
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+	}
 	dev->flags |= DEV_BCACHE_EXCL;
+	dev->flags |= DEV_BCACHE_WRITE;
 	return label_scan_open(dev);
 }
 
@@ -1166,8 +1185,19 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		return false;
 	}
 
+	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
+		log_debug("Close and reopen to write %s", dev_name(dev));
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+
+		dev->flags |= DEV_BCACHE_WRITE;
+		label_scan_open(dev);
+	}
+
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
+		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for writing at %llu length %u.",
 				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
@@ -1201,8 +1231,19 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 		return false;
 	}
 
+	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
+		log_debug("Close and reopen to write %s", dev_name(dev));
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+
+		dev->flags |= DEV_BCACHE_WRITE;
+		label_scan_open(dev);
+	}
+
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
+		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for writing at %llu length %u.",
 				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
@@ -1236,8 +1277,19 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 		return false;
 	}
 
+	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
+		log_debug("Close and reopen to write %s", dev_name(dev));
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+
+		dev->flags |= DEV_BCACHE_WRITE;
+		label_scan_open(dev);
+	}
+
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
+		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for writing at %llu length %u.",
 				  dev_name(dev), (unsigned long long)start, (uint32_t)len);


