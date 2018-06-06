From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 11:08:53 -0400
Subject: master - devices: clean up io error messages
Message-ID: <201806061508.w56F8rDm020719@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c67bd8b47b755a33104e942abc49e516d2a6dace
Commit:        c67bd8b47b755a33104e942abc49e516d2a6dace
Parent:        3e781ea446bb7ddc9a494cbba6b6104dd51c3910
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 10:05:08 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 10:08:25 2018 -0500

devices: clean up io error messages

Remove the io error message from bcache.c since it is not
very useful without the device path.

Make the io error messages from dev_read_bytes/dev_write_bytes
more user friendly.
---
 lib/device/bcache.c |    1 -
 lib/label/label.c   |   40 ++++++++++++++++++++++------------------
 2 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 8fda0bd..561f68e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -623,7 +623,6 @@ static void _complete_io(void *context, int err)
 	dm_list_del(&b->list);
 
 	if (b->error) {
-		log_warn("bcache io error %d fd %d", b->error, b->fd);
 		dm_list_add(&cache->errored, &b->list);
 
 	} else {
diff --git a/lib/label/label.c b/lib/label/label.c
index f36c706..ce995d6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1122,14 +1122,15 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
 		if (!label_scan_open(dev)) {
-			log_error("dev_read_bytes %s cannot open dev", dev_name(dev));
+			log_error("Error opening device %s for reading@%llu length %u.",
+				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 			return false;
 		}
 	}
 
 	if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
-		log_error("dev_read_bytes %s at %u failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error reading device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -1151,21 +1152,22 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
 		if (!label_scan_open(dev)) {
-			log_error("dev_write_bytes %s cannot open dev", dev_name(dev));
+			log_error("Error opening device %s for writing@%llu length %u.",
+				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 			return false;
 		}
 	}
 
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
-		log_error("dev_write_bytes %s at %u bcache write failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error writing device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}
 
 	if (!bcache_flush(scan_bcache)) {
-		log_error("dev_write_bytes %s at %u bcache flush failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error writing device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -1185,21 +1187,22 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
 		if (!label_scan_open(dev)) {
-			log_error("dev_write_zeros %s cannot open dev", dev_name(dev));
+			log_error("Error opening device %s for writing@%llu length %u.",
+				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 			return false;
 		}
 	}
 
 	if (!bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len)) {
-		log_error("dev_write_zeros %s at %u bcache write failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error writing device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}
 
 	if (!bcache_flush(scan_bcache)) {
-		log_error("dev_write_zeros %s at %u bcache flush failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error writing device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -1219,21 +1222,22 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed, perhaps only with lvmetad. */
 		if (!label_scan_open(dev)) {
-			log_error("dev_set_bytes %s cannot open dev", dev_name(dev));
+			log_error("Error opening device %s for writing@%llu length %u.",
+				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 			return false;
 		}
 	}
 
 	if (!bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val)) {
-		log_error("dev_set_bytes %s at %u bcache write failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error writing device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}
 
 	if (!bcache_flush(scan_bcache)) {
-		log_error("dev_set_bytes %s at %u bcache flush failed invalidate fd %d",
-			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		log_error("Error writing device %s at %llu length %u.",
+			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
 		return false;
 	}


