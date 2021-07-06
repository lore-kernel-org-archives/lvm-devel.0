From: David Teigland <teigland@sourceware.org>
Date: Tue,  6 Jul 2021 15:10:57 +0000 (GMT)
Subject: main - scan: don't hold bcache block during scan
Message-ID: <20210706151057.02E27388F01F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d89942d157e49168d069a65f77a6ecb2c155b3fb
Commit:        d89942d157e49168d069a65f77a6ecb2c155b3fb
Parent:        a47e20a0929bc0d399851c398e7e3d06e97daf65
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 28 17:09:09 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 6 10:10:23 2021 -0500

scan: don't hold bcache block during scan

This allows data from the bcache block to be
invalidated and reread if needed.
---
 lib/label/label.c | 71 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 38 insertions(+), 33 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index cfb9ebc80..50107edc8 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -264,9 +264,8 @@ static bool _in_bcache(struct device *dev)
 }
 
 static struct labeller *_find_lvm_header(struct device *dev,
-				   char *scan_buf,
-				   uint32_t scan_buf_sectors,
-				   char *label_buf,
+				   char *headers_buf,
+				   int headers_buf_size,
 				   uint64_t *label_sector,
 				   uint64_t block_sector,
 				   uint64_t start_sector)
@@ -277,24 +276,13 @@ static struct labeller *_find_lvm_header(struct device *dev,
 	uint64_t sector;
 	int found = 0;
 
-	/*
-	 * Find which sector in scan_buf starts with a valid label,
-	 * and copy it into label_buf.
-	 */
-
 	for (sector = start_sector; sector < start_sector + LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
 
-		/*
-		 * The scan_buf passed in is a bcache block, which is
-		 * BCACHE_BLOCK_SIZE_IN_SECTORS large.  So if start_sector is
-		 * one of the last couple sectors in that buffer, we need to
-		 * break early.
-		 */
-		if (sector >= scan_buf_sectors)
+		if ((sector * 512) >= headers_buf_size)
 			break;
 
-		lh = (struct label_header *) (scan_buf + (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (headers_buf + (sector << SECTOR_SHIFT));
 
 		if (!memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (found) {
@@ -332,7 +320,6 @@ static struct labeller *_find_lvm_header(struct device *dev,
 				labeller_ret = li->l;
 				found = 1;
 
-				memcpy(label_buf, lh, LABEL_SIZE);
 				if (label_sector)
 					*label_sector = block_sector + sector;
 				break;
@@ -354,13 +341,13 @@ static struct labeller *_find_lvm_header(struct device *dev,
  * are performed in the processing functions to get that data.
  */
 static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
-			  struct device *dev, struct block *bb,
+			  struct device *dev, char *headers_buf, int headers_buf_size,
 			  uint64_t block_sector, uint64_t start_sector,
 			  int *is_lvm_device)
 {
-	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
+	char *label_buf;
 	struct labeller *labeller;
-	uint64_t sector = 0;
+	uint64_t label_sector = 0;
 	int is_duplicate = 0;
 	int ret = 0;
 
@@ -396,13 +383,9 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	}
 
 	/*
-	 * Finds the data sector containing the label and copies into label_buf.
-	 * label_buf: struct label_header + struct pv_header + struct pv_header_extension
-	 *
-	 * FIXME: we don't need to copy one sector from bb->data into label_buf,
-	 * we can just point label_buf at one sector in ld->buf.
+	 * Finds the data sector containing the label.
 	 */
-	if (!(labeller = _find_lvm_header(dev, bb->data, BCACHE_BLOCK_SIZE_IN_SECTORS, label_buf, &sector, block_sector, start_sector))) {
+	if (!(labeller = _find_lvm_header(dev, headers_buf, headers_buf_size, &label_sector, block_sector, start_sector))) {
 
 		/*
 		 * Non-PVs exit here
@@ -427,6 +410,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 	dev->flags |= DEV_SCAN_FOUND_LABEL;
 	*is_lvm_device = 1;
+	label_buf = headers_buf + (label_sector * 512);
 
 	/*
 	 * This is the point where the scanning code dives into the rest of
@@ -436,7 +420,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	 * info/vginfo structs.  That lvmcache info is used later when the
 	 * command wants to read the VG to do something to it.
 	 */
-	ret = labeller->ops->read(cmd, labeller, dev, label_buf, sector, &is_duplicate);
+	ret = labeller->ops->read(cmd, labeller, dev, label_buf, label_sector, &is_duplicate);
 
 	if (!ret) {
 		if (is_duplicate) {
@@ -670,9 +654,12 @@ static void _invalidate_di(struct bcache *cache, int di)
  * its info is removed from lvmcache.
  */
 
+#define HEADERS_BUF_SIZE 4096
+
 static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		      struct dm_list *devs, int want_other_devs, int *failed)
 {
+	char headers_buf[HEADERS_BUF_SIZE];
 	struct dm_list wait_devs;
 	struct dm_list done_devs;
 	struct dm_list reopen_devs;
@@ -738,14 +725,35 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 			scan_read_errors++;
 			scan_failed_count++;
 			lvmcache_del_dev(devl->dev);
+			if (bb)
+				bcache_put(bb);
 		} else {
-			log_debug_devs("Processing data from device %s %d:%d di %d block %p",
+			/* copy the first 4k from bb that will contain label_header */
+
+			memcpy(headers_buf, bb->data, HEADERS_BUF_SIZE);
+
+			/*
+			 * "put" the bcache block before process_block because
+			 * processing metadata may need to invalidate and reread
+			 * metadata that's covered by bb. invalidate/reread is
+			 * not allowed while bb is held.  The functions for
+			 * filtering and scanning metadata for this device use
+			 * dev_read_bytes(), which will generally grab the
+			 * bcache block/data that we're putting here.  Since
+			 * we're doing put, it's possible but not likely that
+			 * bcache could drop the block before dev_read_bytes()
+			 * uses it again, in which case bcache will reread it
+			 * from disk for dev_read_bytes().
+			 */
+			bcache_put(bb);
+
+			log_debug_devs("Processing data from device %s %d:%d di %d",
 				       dev_name(devl->dev),
 				       (int)MAJOR(devl->dev->dev),
 				       (int)MINOR(devl->dev->dev),
-				       devl->dev->bcache_di, (void *)bb);
+				       devl->dev->bcache_di);
 
-			ret = _process_block(cmd, f, devl->dev, bb, 0, 0, &is_lvm_device);
+			ret = _process_block(cmd, f, devl->dev, headers_buf, sizeof(headers_buf), 0, 0, &is_lvm_device);
 
 			if (!ret && is_lvm_device) {
 				log_debug_devs("Scan failed to process %s", dev_name(devl->dev));
@@ -754,9 +762,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 			}
 		}
 
-		if (bb)
-			bcache_put(bb);
-
 		/*
 		 * Keep the bcache block of lvm devices we have processed so
 		 * that the vg_read phase can reuse it.  If bcache failed to


