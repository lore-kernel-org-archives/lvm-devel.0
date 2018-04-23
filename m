From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:14 -0400
Subject: master - scan: setup bcache for commands using lvmetad
Message-ID: <201804231350.w3NDoE3w031842@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bce66c5e83296398e2eee99140b3d6e409236c9
Commit:        7bce66c5e83296398e2eee99140b3d6e409236c9
Parent:        6e580465b50edcd5fef0eb95180a620cb785d835
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 14 15:45:31 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: setup bcache for commands using lvmetad

Commands using lvmetad will not begin with a proper
label_scan which initializes bcache, but may later
decide they need to scan a set of devs, in which case
they'll need bcache set up at that point.
---
 lib/label/label.c |   66 +++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 19beecf..bf1070c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -570,6 +570,38 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	return 1;
 }
 
+static int _setup_bcache(int cache_blocks)
+{
+	struct io_engine *ioe;
+
+	/* No devices can happen, just create bcache with any small number. */
+	if (!cache_blocks)
+		cache_blocks = 8;
+
+	/*
+	 * 100 is arbitrary, it's the max number of concurrent aio's
+	 * possible, i.e, the number of devices that can be read at
+	 * once.  Should this be configurable?
+	 */
+	if (!(ioe = create_async_io_engine(100))) {
+		log_error("Failed to create bcache io engine.");
+		return 0;
+	}
+
+	/*
+	 * Configure one cache block for each device on the system.
+	 * We won't generally need to cache that many because some
+	 * of the devs will not be lvm devices, and we don't need
+	 * an entry for those.  We might want to change this.
+	 */
+	if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, cache_blocks, ioe))) {
+		log_error("Failed to create bcache with %d cache blocks.", cache_blocks);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Scan and cache lvm data from all devices on the system.
  * The cache should be empty/reset before calling this.
@@ -581,8 +613,6 @@ int label_scan(struct cmd_context *cmd)
 	struct dev_iter *iter;
 	struct device_list *devl;
 	struct device *dev;
-	struct io_engine *ioe;
-	int cache_blocks;
 
 	log_debug_devs("Finding devices to scan");
 
@@ -621,25 +651,11 @@ int label_scan(struct cmd_context *cmd)
 	dev_iter_destroy(iter);
 
 	if (!scan_bcache) {
-		/* No devices can happen, just create bcache with any small number. */
-		if (!(cache_blocks = dm_list_size(&all_devs)))
-			cache_blocks = 8;
-
-		/*
-		 * 100 is arbitrary, it's the max number of concurrent aio's
-		 * possible, i.e, the number of devices that can be read at
-		 * once.  Should this be configurable?
-		 */
-		if (!(ioe = create_async_io_engine(100)))
-			return 0;
-
 		/*
-		 * Configure one cache block for each device on the system.
-		 * We won't generally need to cache that many because some
-		 * of the devs will not be lvm devices, and we don't need
-		 * an entry for those.  We might want to change this.
+		 * FIXME: there should probably be some max number of
+		 * cache blocks we use when setting up bcache.
 		 */
-		if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, cache_blocks, ioe)))
+		if (!_setup_bcache(dm_list_size(&all_devs)))
 			return 0;
 	}
 
@@ -660,6 +676,18 @@ int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
 {
 	struct device_list *devl;
 
+	if (!scan_bcache) {
+		/*
+		 * This is only needed when commands are using lvmetad, in
+		 * which case they don't do an initial label_scan, but may
+		 * later need to rescan certain devs from disk and call this
+		 * function.
+		 * FIXME: is there some better number to choose here?
+		 */
+		if (!_setup_bcache(32))
+			return 0;
+	}
+
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
 			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);


