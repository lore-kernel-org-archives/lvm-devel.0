From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:36 -0400
Subject: master - bcache: rewrite bcache_write_zeros()
Message-ID: <201805031917.w43JHaW2012423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b755f1e042555c5c90cb5766fe90429f143f089
Commit:        8b755f1e042555c5c90cb5766fe90429f143f089
Parent:        dc30d4b2f2712568f4d7163c790c51655f047ed4
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 10:14:56 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 10:14:56 2018 +0100

bcache: rewrite bcache_write_zeros()

It now uses GF_ZERO to avoid reading blocks that are going to be
completely zeroed.
---
 lib/device/bcache-utils.c |   76 ++++++++++++++++++++++++++++++--------------
 1 files changed, 52 insertions(+), 24 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index 3a256fc..fb02a4b 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -48,8 +48,6 @@ static uint64_t _min(uint64_t lhs, uint64_t rhs)
 	return lhs;
 }
 
-// These functions are all utilities, they should only use the public
-// interface to bcache.
 // FIXME: there's common code that can be factored out of these 3
 bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
 {
@@ -125,38 +123,68 @@ bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len
 	return errors ? false : true;
 }
 
-bool bcache_write_zeros(struct bcache *cache, int fd, uint64_t start, size_t len)
+//----------------------------------------------------------------
+
+static bool _zero_whole_blocks(struct bcache *cache, int fd, block_address bb, block_address be)
 {
 	struct block *b;
-	block_address bb, be, i;
+
+	for (; bb != be; bb++) {
+		if (!bcache_get(cache, fd, bb, GF_ZERO, &b, NULL))
+        		return false;
+        	bcache_put(b);
+	}
+
+	return true;
+}
+
+static bool _zero_partial(struct bcache *cache, int fd, block_address bb, uint64_t offset, size_t len)
+{
+	struct block *b;
+
+	if (!bcache_get(cache, fd, bb, GF_DIRTY, &b, NULL))
+		return false;
+
+	memset(((unsigned char *) b->data) + offset, 0, len);
+	bcache_put(b);
+
+	return true;
+}
+
+bool bcache_write_zeros(struct bcache *cache, int fd, uint64_t start, size_t len)
+{
+	block_address bb, be;
 	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
-	int errors = 0;
+	uint64_t block_offset = start % block_size;
+	uint64_t nr_whole;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
-	for (i = bb; i < be; i++)
-		bcache_prefetch(cache, fd, i);
 
-	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
-			errors++;
-			continue;
-		}
+	// First block may be partial
+	if (block_offset) {
+        	size_t blen = _min(block_size - block_offset, len);
+		if (!_zero_partial(cache, fd, bb, block_offset, blen))
+        		return false;
 
-		if (i == bb) {
-			uint64_t block_offset = start % block_size;
-			size_t blen = _min(block_size - block_offset, len);
-			memset(((unsigned char *) b->data) + block_offset, 0, blen);
-			len -= blen;
-		} else {
-			size_t blen = _min(block_size, len);
-			memset(b->data, 0, blen);
-			len -= blen;
-		}
+		len -= blen;
+        	if (!len)
+                	return true;
 
-		bcache_put(b);
+                bb++;
 	}
 
-	return errors ? false : true;
+        // Now we write out a set of whole blocks
+        nr_whole = len / block_size;
+        if (!_zero_whole_blocks(cache, fd, bb, bb + nr_whole))
+                return false;
+	bb += nr_whole;
+	len -= nr_whole * block_size;
+
+	if (!len)
+        	return true;
+
+        // Finally we write a partial end block
+        return _zero_partial(cache, fd, bb, 0, len);
 }
 
 //----------------------------------------------------------------


