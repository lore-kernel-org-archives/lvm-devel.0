From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 16 Jan 2020 10:34:46 -0500
Subject: stable-2.02 - [label] Use bcache_abort_fd() to ensure blocks are no longer in the cache.
Message-ID: <42300.120011610344400355@us-mta-340.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=babde3da5530e4bbda5fb474fb5ea32a55adf16f
Commit:        babde3da5530e4bbda5fb474fb5ea32a55adf16f
Parent:        232f779db4a4cb3c9a1cc628f011f7b28fb6f158
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Oct 28 15:01:47 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jan 16 14:57:49 2020 +0000

[label] Use bcache_abort_fd() to ensure blocks are no longer in the cache.

The return value from bcache_invalidate_fd() was not being checked.

So I've introduced a little function, _invalidate_fd() that always
calls bcache_abort_fd() if the write fails.
---
 lib/label/label.c | 42 +++++++++++++++++++++++++++++++-----------
 1 file changed, 31 insertions(+), 11 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ae5c1427e..70b793441 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -594,6 +594,14 @@ static void _drop_bad_aliases(struct device *dev)
 	}
 }
 
+// Like bcache_invalidate, only it throws any dirty data away if the
+// write fails.
+static void _invalidate_fd(struct bcache *cache, int fd)
+{
+	if (!bcache_invalidate_fd(cache, fd))
+		bcache_abort_fd(cache, fd);
+}
+
 /*
  * Read or reread label/metadata from selected devs.
  *
@@ -704,7 +712,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		 * drop it from bcache.
 		 */
 		if (scan_failed || !is_lvm_device) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 
@@ -881,7 +889,7 @@ int label_scan(struct cmd_context *cmd)
 		 * so this will usually not be true.
 		 */
 		if (_in_bcache(dev)) {
-			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+			_invalidate_fd(scan_bcache, dev->bcache_fd);
 			_scan_dev_close(dev);
 		}
 
@@ -1066,7 +1074,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 	}
@@ -1085,7 +1093,7 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 
@@ -1107,7 +1115,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 		/*
@@ -1127,7 +1135,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 void label_scan_invalidate(struct device *dev)
 {
 	if (_in_bcache(dev)) {
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 }
@@ -1208,7 +1216,7 @@ int label_read(struct device *dev)
 	dm_list_add(&one_dev, &devl->list);
 
 	if (_in_bcache(dev)) {
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 
@@ -1314,7 +1322,7 @@ int label_scan_open_excl(struct device *dev)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_EXCL)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen excl %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 	dev->flags |= DEV_BCACHE_EXCL;
@@ -1322,6 +1330,18 @@ int label_scan_open_excl(struct device *dev)
 	return label_scan_open(dev);
 }
 
+int label_scan_open_rw(struct device *dev)
+{
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
+		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
+		log_debug("Close and reopen rw %s", dev_name(dev));
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+	}
+	dev->flags |= DEV_BCACHE_WRITE;
+	return label_scan_open(dev);
+}
+
 bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
 	if (!scan_bcache) {
@@ -1363,7 +1383,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;
@@ -1411,7 +1431,7 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;
@@ -1462,7 +1482,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;



