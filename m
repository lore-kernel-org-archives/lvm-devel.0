From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 12:24:35 -0400
Subject: master - pvck: allow checking at user specified offsets
Message-ID: <201805111624.w4BGOZlO026735@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=228ed56455b9510ed7943997987ae28459efc1b4
Commit:        228ed56455b9510ed7943997987ae28459efc1b4
Parent:        413488edc6dd077e79517e44a8d3b9a51c5138e5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 10 16:27:34 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 11:23:51 2018 -0500

pvck: allow checking at user specified offsets

with the --labelsector option.  We probably don't
need all this code to support any value for this
option; it's unclear how, when, why it would be
used.
---
 lib/label/label.c |  105 ++++++++++++++++++++++++++++++++++++++++-------------
 lib/label/label.h |    2 +-
 tools/pvck.c      |   28 ++++++++++-----
 3 files changed, 99 insertions(+), 36 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 071c2e7..f5f30c6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -251,9 +251,11 @@ static bool _in_bcache(struct device *dev)
 
 static struct labeller *_find_lvm_header(struct device *dev,
 				   char *scan_buf,
+				   uint32_t scan_buf_sectors,
 				   char *label_buf,
 				   uint64_t *label_sector,
-				   uint64_t scan_sector)
+				   uint64_t block_sector,
+				   uint64_t start_sector)
 {
 	struct labeller_i *li;
 	struct labeller *labeller_ret = NULL;
@@ -266,25 +268,34 @@ static struct labeller *_find_lvm_header(struct device *dev,
 	 * and copy it into label_buf.
 	 */
 
-	for (sector = 0; sector < LABEL_SCAN_SECTORS;
+	for (sector = start_sector; sector < start_sector + LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
+
+		/*
+		 * The scan_buf passed in is a bcache block, which is
+		 * BCACHE_BLOCK_SIZE_IN_SECTORS large.  So if start_sector is
+		 * one of the last couple sectors in that buffer, we need to
+		 * break early.
+		 */
+		if (sector >= scan_buf_sectors)
+			break;
+
 		lh = (struct label_header *) (scan_buf + (sector << SECTOR_SHIFT));
 
 		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (found) {
 				log_error("Ignoring additional label on %s at sector %llu",
-					  dev_name(dev), (unsigned long long)(sector + scan_sector));
+					  dev_name(dev), (unsigned long long)(block_sector + sector));
 			}
-			if (xlate64(lh->sector_xl) != sector + scan_sector) {
-				log_very_verbose("%s: Label for sector %llu found at sector %llu - ignoring.",
-						 dev_name(dev),
-						 (unsigned long long)xlate64(lh->sector_xl),
-						 (unsigned long long)(sector + scan_sector));
+			if (xlate64(lh->sector_xl) != sector) {
+				log_warn("%s: Label for sector %llu found at sector %llu - ignoring.",
+					 dev_name(dev),
+					 (unsigned long long)xlate64(lh->sector_xl),
+					 (unsigned long long)(block_sector + sector));
 				continue;
 			}
-			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
-				     ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)) !=
-			    xlate32(lh->crc_xl)) {
+			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl,
+				     LABEL_SIZE - ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)) != xlate32(lh->crc_xl)) {
 				log_very_verbose("Label checksum incorrect on %s - ignoring", dev_name(dev));
 				continue;
 			}
@@ -293,14 +304,14 @@ static struct labeller *_find_lvm_header(struct device *dev,
 		}
 
 		dm_list_iterate_items(li, &_labellers) {
-			if (li->l->ops->can_handle(li->l, (char *) lh, sector + scan_sector)) {
+			if (li->l->ops->can_handle(li->l, (char *) lh, block_sector + sector)) {
 				log_very_verbose("%s: %s label detected at sector %llu", 
 						 dev_name(dev), li->name,
-						 (unsigned long long)(sector + scan_sector));
+						 (unsigned long long)(block_sector + sector));
 				if (found) {
 					log_error("Ignoring additional label on %s at sector %llu",
 						  dev_name(dev),
-						  (unsigned long long)(sector + scan_sector));
+						  (unsigned long long)(block_sector + sector));
 					continue;
 				}
 
@@ -309,7 +320,7 @@ static struct labeller *_find_lvm_header(struct device *dev,
 
 				memcpy(label_buf, lh, LABEL_SIZE);
 				if (label_sector)
-					*label_sector = sector + scan_sector;
+					*label_sector = block_sector + sector;
 				break;
 			}
 		}
@@ -329,7 +340,9 @@ static struct labeller *_find_lvm_header(struct device *dev,
  * are performed in the processing functions to get that data.
  */
 static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
-			  struct device *dev, struct block *bb, int *is_lvm_device)
+			  struct device *dev, struct block *bb,
+			  uint64_t block_sector, uint64_t start_sector,
+			  int *is_lvm_device)
 {
 	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label *label = NULL;
@@ -345,7 +358,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	 * data had been read (here).  They set this flag to indicate that the
 	 * filters should be retested now that data from the device is ready.
 	 */
-	if (cmd && (dev->flags & DEV_FILTER_AFTER_SCAN)) {
+	if (f && (dev->flags & DEV_FILTER_AFTER_SCAN)) {
 		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
 
 		log_debug_devs("Scan filtering %s", dev_name(dev));
@@ -374,7 +387,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	 * FIXME: we don't need to copy one sector from bb->data into label_buf,
 	 * we can just point label_buf at one sector in ld->buf.
 	 */
-	if (!(labeller = _find_lvm_header(dev, bb->data, label_buf, &sector, 0))) {
+	if (!(labeller = _find_lvm_header(dev, bb->data, BCACHE_BLOCK_SIZE_IN_SECTORS, label_buf, &sector, block_sector, start_sector))) {
 
 		/*
 		 * Non-PVs exit here
@@ -567,7 +580,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		} else {
 			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->bcache_fd, bb);
 
-			ret = _process_block(cmd, f, devl->dev, bb, &is_lvm_device);
+			ret = _process_block(cmd, f, devl->dev, bb, 0, 0, &is_lvm_device);
 
 			if (!ret && is_lvm_device) {
 				log_debug_devs("Scan failed to process %s", dev_name(devl->dev));
@@ -875,18 +888,58 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 
 /*
  * Read a label from a specfic, non-zero sector.  This is used in only
- * one place: pvck -> pv_analyze.
+ * one place: pvck/pv_analyze.
  */
 
-int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector)
+int label_read_sector(struct device *dev, uint64_t read_sector)
 {
-	if (scan_sector) {
-		/* TODO: not yet implemented */
-		/* When is this done?  When does it make sense?  Is it actually possible? */
-		return 0;
+	struct block *bb = NULL;
+	uint64_t block_num;
+	uint64_t block_sector;
+	uint64_t start_sector;
+	int is_lvm_device = 0;
+	int result;
+	int ret;
+
+	block_num = read_sector / BCACHE_BLOCK_SIZE_IN_SECTORS;
+	block_sector = block_num * BCACHE_BLOCK_SIZE_IN_SECTORS;
+	start_sector = read_sector % BCACHE_BLOCK_SIZE_IN_SECTORS;
+
+	label_scan_open(dev);
+
+	bcache_prefetch(scan_bcache, dev->bcache_fd, block_num);
+
+	if (!bcache_get(scan_bcache, dev->bcache_fd, block_num, 0, &bb)) {
+		log_error("Scan failed to read %s at %llu",
+			  dev_name(dev), (unsigned long long)block_num);
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * TODO: check if scan_sector is larger than the bcache block size.
+	 * If it is, we need to fetch a later block from bcache.
+	 */
+
+	result = _process_block(NULL, NULL, dev, bb, block_sector, start_sector, &is_lvm_device);
+
+	if (!result && is_lvm_device) {
+		log_error("Scan failed to process %s", dev_name(dev));
+		ret = 0;
+		goto out;
 	}
 
-	return label_read(dev, labelp, 0);
+	if (!result || !is_lvm_device) {
+		log_error("Could not find LVM label on %s", dev_name(dev));
+		ret = 0;
+		goto out;
+	}
+
+	ret = 1;
+out:
+	if (bb)
+		bcache_put(bb);
+	return ret;
 }
 
 /*
diff --git a/lib/label/label.h b/lib/label/label.h
index 3483321..508cb6f 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -110,7 +110,7 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 void label_scan_drop(struct cmd_context *cmd);
 void label_scan_destroy(struct cmd_context *cmd);
 int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
-int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);
+int label_read_sector(struct device *dev, uint64_t scan_sector);
 void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
diff --git a/tools/pvck.c b/tools/pvck.c
index 5d3c7d1..9030496 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -25,17 +25,8 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	int i;
 	int ret_max = ECMD_PROCESSED;
 
-	/* FIXME: validate cmdline options */
-	/* FIXME: what does the cmdline look like? */
-
 	labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
 
-	if (labelsector) {
-		/* FIXME: see label_read_sector */
-		log_error("TODO: reading label from non-zero sector");
-		return ECMD_FAILED;
-	}
-
 	dm_list_init(&devs);
 
 	for (i = 0; i < argc; i++) {
@@ -61,6 +52,25 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	label_scan_devs(cmd, cmd->filter, &devs);
 
 	dm_list_iterate_items(devl, &devs) {
+
+		/*
+		 * The scan above will populate lvmcache with any info from the
+		 * standard locations at the start of the device.  Now populate
+		 * lvmcache with any info from non-standard offsets.
+		 *
+		 * FIXME: is it possible for a real lvm label sector to be
+		 * anywhere other than the first four sectors of the disk?
+		 * If not, drop the code in label_read_sector/find_lvm_header
+		 * that supports searching at any sector.
+		 */
+		if (labelsector) {
+			if (!label_read_sector(devl->dev, labelsector)) {
+				stack;
+				ret_max = ECMD_FAILED;
+				continue;
+			}
+		}
+
 		if (!pv_analyze(cmd, devl->dev, labelsector)) {
 			stack;
 			ret_max = ECMD_FAILED;


