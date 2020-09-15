From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:15 +0000 (GMT)
Subject: master - label: code deduplication
Message-ID: <20200915212115.11249397249F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b0813384463d9c6e0e5d815658350f75d55ebb5
Commit:        7b0813384463d9c6e0e5d815658350f75d55ebb5
Parent:        6d344b4ac05cab54d65cc5380afeb7931873d6f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 16:20:16 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

label: code deduplication

---
 lib/label/label.c | 29 ++++++-----------------------
 1 file changed, 6 insertions(+), 23 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 8e68f9303..6c86e9ab2 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1060,10 +1060,7 @@ int label_scan(struct cmd_context *cmd)
 		 * label_scan should not generally be called a second time,
 		 * so this will usually not be true.
 		 */
-		if (_in_bcache(dev)) {
-			_invalidate_fd(scan_bcache, dev->bcache_fd);
-			_scan_dev_close(dev);
-		}
+		label_scan_invalidate(dev);
 	};
 	dev_iter_destroy(iter);
 
@@ -1232,12 +1229,8 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 			return 0;
 	}
 
-	dm_list_iterate_items(devl, devs) {
-		if (_in_bcache(devl->dev)) {
-			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
-			_scan_dev_close(devl->dev);
-		}
-	}
+	dm_list_iterate_items(devl, devs)
+		label_scan_invalidate(devl->dev);
 
 	_scan_list(cmd, f, devs, NULL);
 
@@ -1260,10 +1253,7 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 	}
 
 	dm_list_iterate_items(devl, devs) {
-		if (_in_bcache(devl->dev)) {
-			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
-			_scan_dev_close(devl->dev);
-		}
+		label_scan_invalidate(devl->dev);
 		/*
 		 * With this flag set, _scan_dev_open() done by
 		 * _scan_list() will do open RW
@@ -1282,10 +1272,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 	int failed = 0;
 
 	dm_list_iterate_items(devl, devs) {
-		if (_in_bcache(devl->dev)) {
-			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
-			_scan_dev_close(devl->dev);
-		}
+		label_scan_invalidate(devl->dev);
 		/*
 		 * With this flag set, _scan_dev_open() done by
 		 * _scan_list() will do open EXCL
@@ -1384,10 +1371,7 @@ int label_read(struct device *dev)
 	dm_list_init(&one_dev);
 	dm_list_add(&one_dev, &devl->list);
 
-	if (_in_bcache(dev)) {
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
-		_scan_dev_close(dev);
-	}
+	label_scan_invalidate(dev);
 
 	_scan_list(NULL, NULL, &one_dev, &failed);
 
@@ -1665,4 +1649,3 @@ void dev_unset_last_byte(struct device *dev)
 {
 	bcache_unset_last_byte(scan_bcache, dev->bcache_fd);
 }
-


