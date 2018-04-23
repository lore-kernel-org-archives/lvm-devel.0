From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:42 -0400
Subject: master - scan: invalidate bcache for dev after errors
Message-ID: <201804231355.w3NDtgUk001798@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da2b155a9da4c4c9caf502b87ad263de6e678b30
Commit:        da2b155a9da4c4c9caf502b87ad263de6e678b30
Parent:        4331182964e37ad75690007f5f874f2606944a34
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 27 15:03:56 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: invalidate bcache for dev after errors

If there are errors reading or writing dev,
invalidate bcache for it.
---
 lib/label/label.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 88001a9..0514ddf 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -871,11 +871,16 @@ bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_read_bytes %s with invalid bcache_fd", dev_name(dev));
+		log_error("dev_read_bytes %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
 		return false;
 	}
 
-	return bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data);
+	if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
+		label_scan_invalidate(dev);
+		return false;
+	}
+	return true;
+
 }
 
 bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
@@ -895,11 +900,15 @@ bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_write_bytes %s with invalid bcache_fd", dev_name(dev));
+		log_error("dev_write_bytes %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
 		return false;
 	}
 
-	return bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data);
+	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
+		label_scan_invalidate(dev);
+		return false;
+	}
+	return true;
 }
 
 bool dev_write_zeros(struct device *dev, off_t start, size_t len)
@@ -919,10 +928,14 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_write_bytes %s with invalid bcache_fd", dev_name(dev));
+		log_error("dev_write_bytes %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
 		return false;
 	}
 
-	return bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len);
+	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len)) {
+		label_scan_invalidate(dev);
+		return false;
+	}
+	return true;
 }
 


