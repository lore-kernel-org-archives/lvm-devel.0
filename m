From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:18 -0400
Subject: master - scan: handle no devices
Message-ID: <201804231354.w3NDsIsf001408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1e3398ffcf5def36934eabbb9ea26db221bbe74
Commit:        a1e3398ffcf5def36934eabbb9ea26db221bbe74
Parent:        9d2add136192a08be7b3441b6fbe583c27b03dc8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 13 13:37:10 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: handle no devices

Still create bcache.
---
 lib/label/label.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 5da781e..f0ec92f 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -577,6 +577,7 @@ int label_scan(struct cmd_context *cmd)
 	struct device_list *devl;
 	struct device *dev;
 	struct io_engine *ioe;
+	int cache_blocks;
 
 	log_debug_devs("Finding devices to scan");
 
@@ -615,6 +616,9 @@ int label_scan(struct cmd_context *cmd)
 	dev_iter_destroy(iter);
 
 	if (!scan_bcache) {
+		/* No devices can happen, just create bcache with any small number. */
+		if (!(cache_blocks = dm_list_size(&all_devs)))
+			cache_blocks = 8;
 
 		/*
 		 * 100 is arbitrary, it's the max number of concurrent aio's
@@ -630,7 +634,7 @@ int label_scan(struct cmd_context *cmd)
 		 * of the devs will not be lvm devices, and we don't need
 		 * an entry for those.  We might want to change this.
 		 */
-		if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, dm_list_size(&all_devs), ioe)))
+		if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, cache_blocks, ioe)))
 			return 0;
 	}
 


