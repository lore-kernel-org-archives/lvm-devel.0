From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:24 +0000 (GMT)
Subject: stable-2.02 - label: code deduplication
Message-ID: <20201018210224.B16A93850423@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1998825e12c431855b87314d1430d24e37526548
Commit:        1998825e12c431855b87314d1430d24e37526548
Parent:        ba7740df50e93d9a7a2ec919511ba2541e9cc52c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 16:20:16 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:27:51 2020 +0200

label: code deduplication

---
 lib/label/label.c | 29 ++++++-----------------------
 1 file changed, 6 insertions(+), 23 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 019fd09ca..91f456b62 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -888,10 +888,7 @@ int label_scan(struct cmd_context *cmd)
 		 * label_scan should not generally be called a second time,
 		 * so this will usually not be true.
 		 */
-		if (_in_bcache(dev)) {
-			_invalidate_fd(scan_bcache, dev->bcache_fd);
-			_scan_dev_close(dev);
-		}
+		label_scan_invalidate(dev);
 
 		/*
 		 * When md devices exist that use the old superblock at the
@@ -1072,12 +1069,8 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
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
 
@@ -1092,10 +1085,7 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 	int failed = 0;
 
 	dm_list_iterate_items(devl, devs) {
-		if (_in_bcache(devl->dev)) {
-			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
-			_scan_dev_close(devl->dev);
-		}
+		label_scan_invalidate(devl->dev);
 
 		/* _scan_dev_open will open(RDWR) when this flag is set */
 		devl->dev->flags |= DEV_BCACHE_WRITE;
@@ -1114,10 +1104,7 @@ int label_scan_devs_excl(struct dm_list *devs)
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
@@ -1215,10 +1202,7 @@ int label_read(struct device *dev)
 	dm_list_init(&one_dev);
 	dm_list_add(&one_dev, &devl->list);
 
-	if (_in_bcache(dev)) {
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
-		_scan_dev_close(dev);
-	}
+	label_scan_invalidate(dev);
 
 	_scan_list(NULL, NULL, &one_dev, &failed);
 
@@ -1562,4 +1546,3 @@ void dev_unset_last_byte(struct device *dev)
 {
 	bcache_unset_last_byte(scan_bcache, dev->bcache_fd);
 }
-


