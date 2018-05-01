From: David Teigland <teigland@sourceware.org>
Date: Tue, 1 May 2018 10:35:36 -0400
Subject: master - bcache_write_bytes needs to be followed by flush
Message-ID: <201805011435.w41EZaEw013813@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8dcc973bbb2372edaac8f4df4d8480225c04cfe5
Commit:        8dcc973bbb2372edaac8f4df4d8480225c04cfe5
Parent:        a418f88b76d6b67c58af6b8a7d75db29106ff0e1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 1 09:33:55 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 1 09:33:55 2018 -0500

bcache_write_bytes needs to be followed by flush

The improved bcache_write_bytes is not flushing, so
the caller needs to do that.
---
 lib/label/label.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 97e2a0b..a981809 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -946,7 +946,14 @@ bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
-		log_error("dev_write_bytes %s at %u failed invalidate fd %d",
+		log_error("dev_write_bytes %s at %u bcache write failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		label_scan_invalidate(dev);
+		return false;
+	}
+
+	if (!bcache_flush(scan_bcache)) {
+		log_error("dev_write_bytes %s at %u bcache flush failed invalidate fd %d",
 			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
 		label_scan_invalidate(dev);
 		return false;
@@ -982,7 +989,14 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 	}
 
 	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len)) {
-		log_error("dev_write_zeros %s at %u failed invalidate fd %d",
+		log_error("dev_write_zeros %s at %u bcache write failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		label_scan_invalidate(dev);
+		return false;
+	}
+
+	if (!bcache_flush(scan_bcache)) {
+		log_error("dev_write_zeros %s at %u bcache flush failed invalidate fd %d",
 			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
 		label_scan_invalidate(dev);
 		return false;


