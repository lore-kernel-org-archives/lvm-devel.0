From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Jul 2019 17:15:27 -0400
Subject: stable-2.02 - Fix rounding writes up to sector size
Message-ID: <201907302115.x6ULFR48018133@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7550665ba49ac7d497d5b212e14b69298ef01361
Commit:        7550665ba49ac7d497d5b212e14b69298ef01361
Parent:        3d980172b076547865efe5ca0839cabedc05a7b9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 24 11:32:13 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 25 17:06:43 2019 -0500

Fix rounding writes up to sector size

Do this at two levels, although one would be enough to
fix the problem seen recently:

- Ignore any reported sector size other than 512 of 4096.
  If either sector size (physical or logical) is reported
  as 512, then use 512.  If neither are reported as 512,
  and one or the other is reported as 4096, then use 4096.
  If neither is reported as either 512 or 4096, then use 512.

- When rounding up a limited write in bcache to be a multiple
  of the sector size, check that the resulting write size is
  not larger than the bcache block itself.  (This shouldn't
  happen if the sector size is 512 or 4096.)
---
 lib/device/bcache.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/device/dev-io.c |   52 +++++++++++++++++++++++++++++
 lib/device/device.h |    8 +++-
 lib/label/label.c   |   27 +++++++++++++--
 4 files changed, 168 insertions(+), 8 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 261164e..a250bfd 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -169,6 +169,7 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	sector_t offset;
 	sector_t nbytes;
 	sector_t limit_nbytes;
+	sector_t orig_nbytes;
 	sector_t extra_nbytes = 0;
 
 	if (((uintptr_t) data) & e->page_mask) {
@@ -191,11 +192,41 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 			return false;
 		}
 
+		/*
+		 * If the bcache block offset+len goes beyond where lvm is
+		 * intending to write, then reduce the len being written
+		 * (which is the bcache block size) so we don't write past
+		 * the limit set by lvm.  If after applying the limit, the
+		 * resulting size is not a multiple of the sector size (512
+		 * or 4096) then extend the reduced size to be a multiple of
+		 * the sector size (we don't want to write partial sectors.)
+		 */
 		if (offset + nbytes > _last_byte_offset) {
 			limit_nbytes = _last_byte_offset - offset;
-			if (limit_nbytes % _last_byte_sector_size)
+
+			if (limit_nbytes % _last_byte_sector_size) {
 				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
 
+				/*
+				 * adding extra_nbytes to the reduced nbytes (limit_nbytes)
+				 * should make the final write size a multiple of the
+				 * sector size.  This should never result in a final size
+				 * larger than the bcache block size (as long as the bcache
+				 * block size is a multiple of the sector size).
+				 */
+				if (limit_nbytes + extra_nbytes > nbytes) {
+					log_warn("Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu",
+						 (unsigned long long)offset,
+						 (unsigned long long)nbytes,
+						 (unsigned long long)limit_nbytes,
+						 (unsigned long long)extra_nbytes,
+						 (unsigned long long)_last_byte_sector_size);
+					extra_nbytes = 0;
+				}
+			}
+
+			orig_nbytes = nbytes;
+
 			if (extra_nbytes) {
 				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
 					  (unsigned long long)offset,
@@ -210,6 +241,22 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes);
 				nbytes = limit_nbytes;
 			}
+
+			/*
+			 * This shouldn't happen, the reduced+extended
+			 * nbytes value should never be larger than the
+			 * bcache block size.
+			 */
+			if (nbytes > orig_nbytes) {
+				log_error("Invalid adjusted write at %llu len %llu adjusted %llu limit %llu extra %llu sector_size %llu",
+					  (unsigned long long)offset,
+					  (unsigned long long)orig_nbytes,
+					  (unsigned long long)nbytes,
+					  (unsigned long long)limit_nbytes,
+					  (unsigned long long)extra_nbytes,
+					  (unsigned long long)_last_byte_sector_size);
+				return false;
+			}
 		}
 	}
 
@@ -404,6 +451,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 		uint64_t nbytes = len;
 		sector_t limit_nbytes = 0;
 		sector_t extra_nbytes = 0;
+		sector_t orig_nbytes = 0;
 
 		if (offset > _last_byte_offset) {
 			log_error("Limit write at %llu len %llu beyond last byte %llu",
@@ -416,9 +464,30 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
 		if (offset + nbytes > _last_byte_offset) {
 			limit_nbytes = _last_byte_offset - offset;
-			if (limit_nbytes % _last_byte_sector_size)
+
+			if (limit_nbytes % _last_byte_sector_size) {
 				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
 
+				/*
+				 * adding extra_nbytes to the reduced nbytes (limit_nbytes)
+				 * should make the final write size a multiple of the
+				 * sector size.  This should never result in a final size
+				 * larger than the bcache block size (as long as the bcache
+				 * block size is a multiple of the sector size).
+				 */
+				if (limit_nbytes + extra_nbytes > nbytes) {
+					log_warn("Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu",
+						 (unsigned long long)offset,
+						 (unsigned long long)nbytes,
+						 (unsigned long long)limit_nbytes,
+						 (unsigned long long)extra_nbytes,
+						 (unsigned long long)_last_byte_sector_size);
+					extra_nbytes = 0;
+				}
+			}
+
+			orig_nbytes = nbytes;
+
 			if (extra_nbytes) {
 				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
 					  (unsigned long long)offset,
@@ -433,6 +502,22 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes);
 				nbytes = limit_nbytes;
 			}
+
+			/*
+			 * This shouldn't happen, the reduced+extended
+			 * nbytes value should never be larger than the
+			 * bcache block size.
+			 */
+			if (nbytes > orig_nbytes) {
+				log_error("Invalid adjusted write at %llu len %llu adjusted %llu limit %llu extra %llu sector_size %llu",
+					  (unsigned long long)offset,
+					  (unsigned long long)orig_nbytes,
+					  (unsigned long long)nbytes,
+					  (unsigned long long)limit_nbytes,
+					  (unsigned long long)extra_nbytes,
+					  (unsigned long long)_last_byte_sector_size);
+				return false;
+			}
 		}
 
 		where = offset;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 99ff803..fd8d349 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -135,6 +135,58 @@ static int _io(struct device_area *where, char *buffer, int should_write, dev_io
 	return (total == (size_t) where->size);
 }
 
+int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_size,
+				unsigned int *logical_block_size)
+{
+	int fd = dev->bcache_fd;
+	int do_close = 0;
+	unsigned int pbs = 0;
+	unsigned int lbs = 0;
+
+	if (dev->physical_block_size || dev->logical_block_size) {
+		*physical_block_size = dev->physical_block_size;
+		*logical_block_size = dev->logical_block_size;
+		return 1;
+	}
+
+	if (fd <= 0) {
+		if (!dev_open_readonly(dev))
+			return 0;
+		fd = dev_fd(dev);
+		do_close = 1;
+	}
+
+	/*
+	 * BLKPBSZGET from kernel comment for blk_queue_physical_block_size:
+	 * "the lowest possible sector size that the hardware can operate on
+	 * without reverting to read-modify-write operations"
+	 */
+	if (ioctl(fd, BLKPBSZGET, &pbs)) {
+		stack;
+		pbs = 0;
+	}
+
+	/*
+	 * BLKSSZGET from kernel comment for blk_queue_logical_block_size:
+	 * "the lowest possible block size that the storage device can address."
+	 */
+	if (ioctl(fd, BLKSSZGET, &lbs)) {
+		stack;
+		lbs = 0;
+	}
+
+	dev->physical_block_size = pbs;
+	dev->logical_block_size = lbs;
+
+	*physical_block_size = pbs;
+	*logical_block_size = lbs;
+
+	if (do_close && !dev_close_immediate(dev))
+		stack;
+
+	return 1;
+}
+
 /*-----------------------------------------------------------------
  * LVM2 uses O_DIRECT when performing metadata io, which requires
  * block size aligned accesses.  If any io is not aligned we have
diff --git a/lib/device/device.h b/lib/device/device.h
index bbd965a..aafc401 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -67,8 +67,10 @@ struct device {
 	int open_count;
 	int error_count;
 	int max_error_count;
-	int phys_block_size;
-	int block_size;
+	int phys_block_size;     /* From either BLKPBSZGET or BLKSSZGET, don't use */
+	int block_size;          /* From BLKBSZGET, returns bdev->bd_block_size, likely set by fs, probably don't use */
+	int physical_block_size; /* From BLKPBSZGET: lowest possible sector size that the hardware can operate on without reverting to read-modify-write operations */
+	int logical_block_size;  /* From BLKSSZGET: lowest possible block size that the storage device can address */
 	int read_ahead;
 	int bcache_fd;
 	uint32_t flags;
@@ -132,6 +134,8 @@ void dev_size_seqno_inc(void);
  * All io should use these routines.
  */
 int dev_get_block_size(struct device *dev, unsigned int *phys_block_size, unsigned int *block_size);
+int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_size,
+                               unsigned int *logical_block_size);
 int dev_get_size(struct device *dev, uint64_t *size);
 int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
 int dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_bytes);
diff --git a/lib/label/label.c b/lib/label/label.c
index bc31a7c..8107e33 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1498,15 +1498,34 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 
 void dev_set_last_byte(struct device *dev, uint64_t offset)
 {
-	unsigned int phys_block_size = 0;
-	unsigned int block_size = 0;
+	unsigned int physical_block_size = 0;
+	unsigned int logical_block_size = 0;
+	unsigned int bs;
 
-	if (!dev_get_block_size(dev, &phys_block_size, &block_size)) {
+	if (!dev_get_direct_block_sizes(dev, &physical_block_size, &logical_block_size)) {
 		stack;
 		return; /* FIXME: error path ? */
 	}
 
-	bcache_set_last_byte(scan_bcache, dev->bcache_fd, offset, phys_block_size);
+	if ((physical_block_size == 512) && (logical_block_size == 512))
+		bs = 512;
+	else if ((physical_block_size == 4096) && (logical_block_size == 4096))
+		bs = 4096;
+	else if ((physical_block_size == 512) || (logical_block_size == 512)) {
+		log_debug("Set last byte mixed block sizes physical %u logical %u using 512",
+			  physical_block_size, logical_block_size);
+		bs = 512;
+	} else if ((physical_block_size == 4096) || (logical_block_size == 4096)) {
+		log_debug("Set last byte mixed block sizes physical %u logical %u using 4096",
+			  physical_block_size, logical_block_size);
+		bs = 4096;
+	} else {
+		log_debug("Set last byte mixed block sizes physical %u logical %u using 512",
+			  physical_block_size, logical_block_size);
+		bs = 512;
+	}
+
+	bcache_set_last_byte(scan_bcache, dev->bcache_fd, offset, bs);
 }
 
 void dev_unset_last_byte(struct device *dev)


