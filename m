From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 May 2018 16:19:14 -0400
Subject: master - scan: use up to 1024 max bcache blocks
Message-ID: <201805152019.w4FKJE4P004074@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bbc17a6706b4ceae8a41da519d87945da27fd14
Commit:        3bbc17a6706b4ceae8a41da519d87945da27fd14
Parent:        fb0aca86f847fc13d9a9e4cc933085644e5ce29f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 15 12:16:58 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 15 15:17:31 2018 -0500

scan: use up to 1024 max bcache blocks

Create bcache with one block per device that
will be scanned up to 1024 max blocks.
---
 lib/label/label.c |   45 ++++++++++++++++++++++++++++-----------------
 1 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index b073647..40537d1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -623,32 +623,46 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 	return 1;
 }
 
+/*
+ * How many blocks to set up in bcache?  Is 1024 a good max?
+ *
+ * Currently, we tell bcache to set up N blocks where N
+ * is the number of devices that are going to be scanned.
+ * Reasons why this number may not be be a good choice:
+ *
+ * - there may be a lot of non-lvm devices, which
+ *   would make this number larger than necessary
+ *
+ * - each lvm device may use more than one cache
+ *   block if the metadata is large enough or it
+ *   uses more than one metadata area, which
+ *   would make this number smaller than it
+ *   should be for the best performance.
+ *
+ * This is even more tricky to estimate when lvmetad
+ * is used, because it's hard to predict how many
+ * devs might need to be scanned when using lvmetad.
+ * This currently just sets up bcache with MIN blocks.
+ */
+
 #define MIN_BCACHE_BLOCKS 32
+#define MAX_BCACHE_BLOCKS 1024
 
 static int _setup_bcache(int cache_blocks)
 {
 	struct io_engine *ioe;
 
-	/* No devices can happen, just create bcache with any small number. */
 	if (cache_blocks < MIN_BCACHE_BLOCKS)
 		cache_blocks = MIN_BCACHE_BLOCKS;
 
-	/*
-	 * 100 is arbitrary, it's the max number of concurrent aio's
-	 * possible, i.e, the number of devices that can be read at
-	 * once.  Should this be configurable?
-	 */
+	if (cache_blocks > MAX_BCACHE_BLOCKS)
+		cache_blocks = MAX_BCACHE_BLOCKS;
+
 	if (!(ioe = create_async_io_engine())) {
 		log_error("Failed to create bcache io engine.");
 		return 0;
 	}
 
-	/*
-	 * Configure one cache block for each device on the system.
-	 * We won't generally need to cache that many because some
-	 * of the devs will not be lvm devices, and we don't need
-	 * an entry for those.  We might want to change this.
-	 */
 	if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, cache_blocks, ioe))) {
 		log_error("Failed to create bcache with %d cache blocks.", cache_blocks);
 		return 0;
@@ -708,10 +722,6 @@ int label_scan(struct cmd_context *cmd)
 	log_debug_devs("Found %d devices to scan", dm_list_size(&all_devs));
 
 	if (!scan_bcache) {
-		/*
-		 * FIXME: there should probably be some max number of
-		 * cache blocks we use when setting up bcache.
-		 */
 		if (!_setup_bcache(dm_list_size(&all_devs)))
 			return 0;
 	}
@@ -939,7 +949,8 @@ out:
  * This is only needed when commands are using lvmetad, in which case they
  * don't do an initial label_scan, but may later need to rescan certain devs
  * from disk and call this function.  FIXME: is there some better number to
- * choose here?
+ * choose here?  How should we predict the number of devices that might need
+ * scanning when using lvmetad?
  */
 
 int label_scan_setup_bcache(void)


