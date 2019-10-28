From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 28 Oct 2019 11:16:12 -0400
Subject: master - [label] Use bcache_abort_fd() to ensure blocks are no longer in the cache.
Message-ID: <201910281516.x9SFGCWK002147@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b0d969b2a85ba69046afa26af4d7bcddddbccd5
Commit:        6b0d969b2a85ba69046afa26af4d7bcddddbccd5
Parent:        2938b4dcca0a1df661758abfab7f402ea7aab018
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Oct 28 15:01:47 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Oct 28 15:01:47 2019 +0000

[label] Use bcache_abort_fd() to ensure blocks are no longer in the cache.

The return value from bcache_invalidate_fd() was not being checked.

So I've introduced a little function, _invalidate_fd() that always
calls bcache_abort_fd() if the write fails.
---
 lib/label/label.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index dc4d32d..7dcaf8a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -620,6 +620,14 @@ static void _drop_bad_aliases(struct device *dev)
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
@@ -731,7 +739,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		 * drop it from bcache.
 		 */
 		if (scan_failed || !is_lvm_device) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 
@@ -996,7 +1004,7 @@ int label_scan(struct cmd_context *cmd)
 		 * so this will usually not be true.
 		 */
 		if (_in_bcache(dev)) {
-			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+			_invalidate_fd(scan_bcache, dev->bcache_fd);
 			_scan_dev_close(dev);
 		}
 	};
@@ -1169,7 +1177,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 	}
@@ -1196,7 +1204,7 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 		/*
@@ -1218,7 +1226,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
-			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
 			_scan_dev_close(devl->dev);
 		}
 		/*
@@ -1238,7 +1246,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 void label_scan_invalidate(struct device *dev)
 {
 	if (_in_bcache(dev)) {
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 }
@@ -1320,7 +1328,7 @@ int label_read(struct device *dev)
 	dm_list_add(&one_dev, &devl->list);
 
 	if (_in_bcache(dev)) {
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 
@@ -1362,7 +1370,7 @@ int label_scan_open_excl(struct device *dev)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_EXCL)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen excl %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 	dev->flags |= DEV_BCACHE_EXCL;
@@ -1375,7 +1383,7 @@ int label_scan_open_rw(struct device *dev)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen rw %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 	}
 	dev->flags |= DEV_BCACHE_WRITE;
@@ -1423,7 +1431,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;
@@ -1469,7 +1477,7 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;
@@ -1520,7 +1528,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
-		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
 		/* goes to label_scan_open() since bcache_fd < 0 */
 	}


