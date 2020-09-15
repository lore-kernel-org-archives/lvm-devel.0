From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:20 +0000 (GMT)
Subject: master - label: use formaters FMTu64 and FMTsize_t
Message-ID: <20200915212120.C63B83857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0ccb2521ba4f34455078f87f46cc41f5761ffc0
Commit:        d0ccb2521ba4f34455078f87f46cc41f5761ffc0
Parent:        2b36542f419ca66c0ee7de4537b5a9dd7a902e3d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 21:47:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 23:07:06 2020 +0200

label: use formaters FMTu64 and FMTsize_t

Produces code without casts to differntly signed types
and also shortens and enhances readbility.
---
 lib/label/label.c | 73 +++++++++++++++++++++++++++----------------------------
 1 file changed, 36 insertions(+), 37 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ba3b1f9c7..1b138a5a3 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -132,8 +132,8 @@ int label_remove(struct device *dev)
 		memset(readbuf, 0, sizeof(readbuf));
 
 		if (!dev_read_bytes(dev, sector << SECTOR_SHIFT, LABEL_SIZE, readbuf)) {
-			log_error("Failed to read label from %s sector %llu",
-				  dev_name(dev), (unsigned long long)sector);
+			log_error("Failed to read label from %s sector " FMTu64,
+				  dev_name(dev), sector);
 			continue;
 		}
 
@@ -154,12 +154,12 @@ int label_remove(struct device *dev)
 		}
 
 		if (wipe) {
-			log_very_verbose("%s: Wiping label at sector %llu",
-					 dev_name(dev), (unsigned long long)sector);
+			log_very_verbose("%s: Wiping label at sector " FMTu64,
+					 dev_name(dev), sector);
 
 			if (!dev_write_zeros(dev, sector << SECTOR_SHIFT, LABEL_SIZE)) {
-				log_error("Failed to remove label from %s at sector %llu",
-					  dev_name(dev), (unsigned long long)sector);
+				log_error("Failed to remove label from %s@sector " FMTu64,
+					  dev_name(dev), sector);
 				r = 0;
 			} else {
 				/* Also remove the PV record from cache. */
@@ -187,7 +187,7 @@ int label_write(struct device *dev, struct label *label)
 	}
 
 	if ((LABEL_SIZE + (label->sector << SECTOR_SHIFT)) > LABEL_SCAN_SIZE) {
-		log_error("Label sector %" PRIu64 " beyond range (%ld)",
+		log_error("Label sector " FMTu64 " beyond range (%ld)",
 			  label->sector, LABEL_SCAN_SECTORS);
 		return 0;
 	}
@@ -204,8 +204,8 @@ int label_write(struct device *dev, struct label *label)
 	lh->crc_xl = xlate32(calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
 				      ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)));
 
-	log_very_verbose("%s: Writing label to sector %" PRIu64 " with stored offset %"
-			 PRIu32 ".", dev_name(dev), label->sector,
+	log_very_verbose("%s: Writing label to sector " FMTu64 " with stored offset "
+			 FMTu32 ".", dev_name(dev), label->sector,
 			 xlate32(lh->offset_xl));
 
 	if (!label_scan_open(dev)) {
@@ -297,14 +297,13 @@ static struct labeller *_find_lvm_header(struct device *dev,
 
 		if (!memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (found) {
-				log_error("Ignoring additional label on %s at sector %llu",
-					  dev_name(dev), (unsigned long long)(block_sector + sector));
+				log_error("Ignoring additional label on %s at sector " FMTu64,
+					  dev_name(dev), (block_sector + sector));
 			}
 			if (xlate64(lh->sector_xl) != sector) {
-				log_warn("%s: Label for sector %llu found at sector %llu - ignoring.",
-					 dev_name(dev),
-					 (unsigned long long)xlate64(lh->sector_xl),
-					 (unsigned long long)(block_sector + sector));
+				log_warn("%s: Label for sector " FMTu64 " found at sector " FMTu64 " - ignoring.",
+					 dev_name(dev), xlate64(lh->sector_xl),
+					 (block_sector + sector));
 				continue;
 			}
 			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl,
@@ -318,13 +317,13 @@ static struct labeller *_find_lvm_header(struct device *dev,
 
 		dm_list_iterate_items(li, &_labellers) {
 			if (li->l->ops->can_handle(li->l, (char *) lh, block_sector + sector)) {
-				log_very_verbose("%s: %s label detected at sector %llu", 
+				log_very_verbose("%s: %s label detected at sector " FMTu64,
 						 dev_name(dev), li->name,
-						 (unsigned long long)(block_sector + sector));
+						 (block_sector + sector));
 				if (found) {
-					log_error("Ignoring additional label on %s at sector %llu",
+					log_error("Ignoring additional label on %s at sector " FMTu64,
 						  dev_name(dev),
-						  (unsigned long long)(block_sector + sector));
+						  (block_sector + sector));
 					continue;
 				}
 
@@ -1137,8 +1136,8 @@ int label_scan(struct cmd_context *cmd)
 
 		log_warn("WARNING: metadata may not be usable with current io_memory_size %d KiB",
 			 io_memory_size());
-		log_warn("WARNING: increase lvm.conf io_memory_size to at least %llu KiB",
-			 (unsigned long long)want_size_kb);
+		log_warn("WARNING: increase lvm.conf io_memory_size to at least " FMTu64 " KiB",
+			 want_size_kb);
 	}
 
 	dm_list_init(&cmd->hints);
@@ -1442,15 +1441,15 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (dev->bcache_fd <= 0) {
 		/* This is not often needed. */
 		if (!label_scan_open(dev)) {
-			log_error("Error opening device %s for reading at %llu length %u.",
-				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+			log_error("Error opening device %s for reading@" FMTu64 " length " FMTsize_t ".",
+				  dev_name(dev), start, len);
 			return false;
 		}
 	}
 
 	if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
-		log_error("Error reading device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		log_error("Error reading device %s at " FMTu64 " length " FMTsize_t ".",
+			  dev_name(dev), start, len);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -1483,23 +1482,23 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
-			log_error("Error opening device %s for writing at %llu length %u.",
-				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+			log_error("Error opening device %s for writing at " FMTu64 " length " FMTsize_t ".",
+				  dev_name(dev), start, len);
 			return false;
 		}
 	}
 
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
-		log_error("Error writing device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		log_error("Error writing device %s at " FMTu64 " length " FMTsize_t ".",
+			  dev_name(dev), start, len);
 		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
 	}
 
 	if (!bcache_flush(scan_bcache)) {
-		log_error("Error writing device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		log_error("Error writing device %s at " FMTu64 " length " FMTsize_t ".",
+			  dev_name(dev), start, len);
 		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
@@ -1539,8 +1538,8 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
-			log_error("Error opening device %s for writing at %llu length %u.",
-				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+			log_error("Error opening device %s for writing at " FMTu64 " length " FMTsize_t ".",
+				  dev_name(dev), start, len);
 			return false;
 		}
 	}
@@ -1549,16 +1548,16 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 
 	if ((!val && !bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len)) ||
 	    !bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val)) {
-		log_error("Error writing device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		log_error("Error writing device %s at " FMTu64 " length " FMTsize_t ".",
+			  dev_name(dev), start, len);
 		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
 	}
 
 	if (!bcache_flush(scan_bcache)) {
-		log_error("Error writing device %s at %llu length %u.",
-			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		log_error("Error writing device %s at " FMTu64 " length " FMTsize_t ".",
+			  dev_name(dev), start, len);
 		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;


