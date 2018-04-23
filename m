From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:29 -0400
Subject: master - scan: create bcache with minimum number of blocks
Message-ID: <201804231355.w3NDtTab001717@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21057676a1f01c6b1f19b2e879d8385d76adb517
Commit:        21057676a1f01c6b1f19b2e879d8385d76adb517
Parent:        e49b114f7e437666caefa04aada31f32820e286e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 27 12:35:45 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: create bcache with minimum number of blocks

In some odd cases (e.g. tests) there are very few devices
which results in creating too few blocks in bcache, so
create bcache with a minimum number of blocks.
---
 lib/label/label.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 45a3ecf..88001a9 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -560,13 +560,15 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	return 1;
 }
 
+#define MIN_BCACHE_BLOCKS 32
+
 static int _setup_bcache(int cache_blocks)
 {
 	struct io_engine *ioe;
 
 	/* No devices can happen, just create bcache with any small number. */
-	if (!cache_blocks)
-		cache_blocks = 8;
+	if (cache_blocks < MIN_BCACHE_BLOCKS)
+		cache_blocks = MIN_BCACHE_BLOCKS;
 
 	/*
 	 * 100 is arbitrary, it's the max number of concurrent aio's
@@ -831,7 +833,7 @@ int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_s
 int label_scan_setup_bcache(void)
 {
 	if (!scan_bcache) {
-		if (!_setup_bcache(32))
+		if (!_setup_bcache(0))
 			return 0;
 	}
 


