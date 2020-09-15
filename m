From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:16 +0000 (GMT)
Subject: master - label: deduplicate dev_set_bytes
Message-ID: <20200915212116.334BE3857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bcc99477638eee4c813acf1ca60233ed0c6bb61
Commit:        7bcc99477638eee4c813acf1ca60233ed0c6bb61
Parent:        7b0813384463d9c6e0e5d815658350f75d55ebb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 16:29:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

label: deduplicate dev_set_bytes

As dev_write_zeros() is same as dev_set_bytes() reused the code
directly.
---
 lib/label/label.c | 51 +++------------------------------------------------
 1 file changed, 3 insertions(+), 48 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 6c86e9ab2..ba3b1f9c7 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1514,53 +1514,7 @@ bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len)
 
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 {
-	if (test_mode())
-		return true;
-
-	if (!scan_bcache) {
-		log_error("dev_write_zeros bcache not set up %s", dev_name(dev));
-		return false;
-	}
-
-	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
-		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
-		log_debug("Close and reopen to write %s", dev_name(dev));
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
-		_scan_dev_close(dev);
-
-		dev->flags |= DEV_BCACHE_WRITE;
-		label_scan_open(dev);
-	}
-
-	if (dev->bcache_fd <= 0) {
-		/* This is not often needed. */
-		dev->flags |= DEV_BCACHE_WRITE;
-		if (!label_scan_open(dev)) {
-			log_error("Error opening device %s for writing at %llu length %u.",
-				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
-			return false;
-		}
-	}
-
-	dev_set_last_byte(dev, start + len);
-
-	if (!bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len)) {
-		log_error("Error writing device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
-		dev_unset_last_byte(dev);
-		label_scan_invalidate(dev);
-		return false;
-	}
-
-	if (!bcache_flush(scan_bcache)) {
-		log_error("Error writing device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
-		dev_unset_last_byte(dev);
-		label_scan_invalidate(dev);
-		return false;
-	}
-	dev_unset_last_byte(dev);
-	return true;
+	return dev_set_bytes(dev, start, len, 0);
 }
 
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
@@ -1593,7 +1547,8 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 
 	dev_set_last_byte(dev, start + len);
 
-	if (!bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val)) {
+	if ((!val && !bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len)) ||
+	    !bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		dev_unset_last_byte(dev);


