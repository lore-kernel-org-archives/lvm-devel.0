From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:38 -0400
Subject: master - bcache: switch off_t -> uint64_t
Message-ID: <201805031917.w43JHcBJ012437@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc30d4b2f2712568f4d7163c790c51655f047ed4
Commit:        dc30d4b2f2712568f4d7163c790c51655f047ed4
Parent:        efad84ebc297a652a2b88ced57128fc51edcf8ef
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 09:37:43 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 09:37:43 2018 +0100

bcache: switch off_t -> uint64_t

We always want it to be 64bit
---
 lib/device/bcache-utils.c |   24 ++++++++++++------------
 lib/device/bcache.h       |    8 ++++----
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index c9a685c..3a256fc 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -21,7 +21,7 @@
 
 //----------------------------------------------------------------
 
-static void byte_range_to_block_range(struct bcache *cache, off_t start, size_t len,
+static void byte_range_to_block_range(struct bcache *cache, uint64_t start, size_t len,
 				      block_address *bb, block_address *be)
 {
 	block_address block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
@@ -29,7 +29,7 @@ static void byte_range_to_block_range(struct bcache *cache, off_t start, size_t
 	*be = (start + len + block_size - 1) / block_size;
 }
 
-void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len)
+void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
 {
 	block_address bb, be;
 
@@ -40,7 +40,7 @@ void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len
 	}
 }
 
-static off_t _min(off_t lhs, off_t rhs)
+static uint64_t _min(uint64_t lhs, uint64_t rhs)
 {
 	if (rhs < lhs)
 		return rhs;
@@ -51,12 +51,12 @@ static off_t _min(off_t lhs, off_t rhs)
 // These functions are all utilities, they should only use the public
 // interface to bcache.
 // FIXME: there's common code that can be factored out of these 3
-bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
+bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
 {
 	struct block *b;
 	block_address bb, be, i;
 	unsigned char *udata = data;
-	off_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
+	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
 	int errors = 0;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
@@ -70,7 +70,7 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 		}
 
 		if (i == bb) {
-			off_t block_offset = start % block_size;
+			uint64_t block_offset = start % block_size;
 			size_t blen = _min(block_size - block_offset, len);
 			memcpy(udata, ((unsigned char *) b->data) + block_offset, blen);
 			len -= blen;
@@ -88,12 +88,12 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 	return errors ? false : true;
 }
 
-bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
+bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
 {
 	struct block *b;
 	block_address bb, be, i;
 	unsigned char *udata = data;
-	off_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
+	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
 	int errors = 0;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
@@ -107,7 +107,7 @@ bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, v
 		}
 
 		if (i == bb) {
-			off_t block_offset = start % block_size;
+			uint64_t block_offset = start % block_size;
 			size_t blen = _min(block_size - block_offset, len);
 			memcpy(((unsigned char *) b->data) + block_offset, udata, blen);
 			len -= blen;
@@ -125,11 +125,11 @@ bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, v
 	return errors ? false : true;
 }
 
-bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len)
+bool bcache_write_zeros(struct bcache *cache, int fd, uint64_t start, size_t len)
 {
 	struct block *b;
 	block_address bb, be, i;
-	off_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
+	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
 	int errors = 0;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
@@ -143,7 +143,7 @@ bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len)
 		}
 
 		if (i == bb) {
-			off_t block_offset = start % block_size;
+			uint64_t block_offset = start % block_size;
 			size_t blen = _min(block_size - block_offset, len);
 			memset(((unsigned char *) b->data) + block_offset, 0, blen);
 			len -= blen;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index db41eeb..c6b6fb7 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -156,12 +156,12 @@ bool bcache_invalidate_fd(struct bcache *cache, int fd);
 // The next four functions are utilities written in terms of the above api.
  
 // Prefetches the blocks neccessary to satisfy a byte range.
-void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len);
+void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
 
 // Reads, writes and zeroes bytes.  Returns false if errors occur.
-bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
-bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
-bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len);
+bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
+bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
+bool bcache_write_zeros(struct bcache *cache, int fd, uint64_t start, size_t len);
 
 //----------------------------------------------------------------
 


