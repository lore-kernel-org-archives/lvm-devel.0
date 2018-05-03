From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:42 -0400
Subject: master - bcache-utils: rewrite
Message-ID: <201805031917.w43JHgAB012460@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dfc320f5b8c24c1a430b8f044da3ee925815a447
Commit:        dfc320f5b8c24c1a430b8f044da3ee925815a447
Parent:        2688aafefbc937fc319c59ca1c77cdc24bb2c214
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 11:36:15 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 11:36:29 2018 +0100

bcache-utils: rewrite

They take care to avoid redundant reads now.
---
 lib/device/bcache-utils.c |  223 ++++++++++++++++++++++++++-------------------
 1 files changed, 131 insertions(+), 92 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index d946cc4..92e25c8 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -29,6 +29,16 @@ static void byte_range_to_block_range(struct bcache *cache, uint64_t start, size
 	*be = (start + len + block_size - 1) / block_size;
 }
 
+static uint64_t _min(uint64_t lhs, uint64_t rhs)
+{
+	if (rhs < lhs)
+		return rhs;
+
+	return lhs;
+}
+
+//----------------------------------------------------------------
+
 void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
 {
 	block_address bb, be;
@@ -40,109 +50,149 @@ void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t
 	}
 }
 
-static uint64_t _min(uint64_t lhs, uint64_t rhs)
-{
-	if (rhs < lhs)
-		return rhs;
-
-	return lhs;
-}
+//----------------------------------------------------------------
 
-// FIXME: there's common code that can be factored out of these 3
 bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
 {
 	struct block *b;
-	block_address bb, be, i;
-	unsigned char *udata = data;
+	block_address bb, be;
 	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
-	int errors = 0;
+	uint64_t block_offset = start % block_size;
+
+	bcache_prefetch_bytes(cache, fd, start, len);
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
-	for (i = bb; i < be; i++)
-		bcache_prefetch(cache, fd, i);
-
-	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
-			errors++;
-			continue;
-		}
-
-		if (i == bb) {
-			uint64_t block_offset = start % block_size;
-			size_t blen = _min(block_size - block_offset, len);
-			memcpy(udata, ((unsigned char *) b->data) + block_offset, blen);
-			len -= blen;
-			udata += blen;
-		} else {
-			size_t blen = _min(block_size, len);
-			memcpy(udata, b->data, blen);
-			len -= blen;
-			udata += blen;
-		}
 
+	for (; bb != be; bb++) {
+        	if (!bcache_get(cache, fd, bb, 0, &b, NULL))
+			return false;
+
+		size_t blen = _min(block_size - block_offset, len);
+		memcpy(data, ((unsigned char *) b->data) + block_offset, blen);
 		bcache_put(b);
+
+		block_offset = 0;
+		len -= blen;
+		data = ((unsigned char *) data) + blen;
 	}
 
-	return errors ? false : true;
+	return true;
 }
 
-bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
+//----------------------------------------------------------------
+
+// Writing bytes and zeroing bytes are very similar, so we factor out
+// this common code.
+ 
+struct updater;
+
+typedef bool (*partial_update_fn)(struct updater *u, int fd, block_address bb, uint64_t offset, size_t len);
+typedef bool (*whole_update_fn)(struct updater *u, int fd, block_address bb, block_address be);
+
+struct updater {
+	struct bcache *cache;
+	partial_update_fn partial_fn;
+	whole_update_fn whole_fn;
+	void *data;
+};
+
+static bool _update_bytes(struct updater *u, int fd, uint64_t start, size_t len)
 {
-	struct block *b;
-	block_address bb, be, i;
-	unsigned char *udata = data;
+        struct bcache *cache = u->cache;
+	block_address bb, be;
 	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
-	int errors = 0;
+	uint64_t block_offset = start % block_size;
+	uint64_t nr_whole;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
-	for (i = bb; i < be; i++)
-		bcache_prefetch(cache, fd, i);
-
-	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
-			errors++;
-			continue;
-		}
-
-		if (i == bb) {
-			uint64_t block_offset = start % block_size;
-			size_t blen = _min(block_size - block_offset, len);
-			memcpy(((unsigned char *) b->data) + block_offset, udata, blen);
-			len -= blen;
-			udata += blen;
-		} else {
-			size_t blen = _min(block_size, len);
-			memcpy(b->data, udata, blen);
-			len -= blen;
-			udata += blen;
-		}
 
-		bcache_put(b);
+	// If the last block is partial, we will require a read, so let's 
+	// prefetch it.
+	if ((start + len) % block_size)
+        	bcache_prefetch(cache, fd, (start + len) / block_size);
+
+	// First block may be partial
+	if (block_offset) {
+        	size_t blen = _min(block_size - block_offset, len);
+		if (!u->partial_fn(u, fd, bb, block_offset, blen))
+        		return false;
+
+		len -= blen;
+        	if (!len)
+                	return true;
+
+                bb++;
 	}
 
-	return errors ? false : true;
+        // Now we write out a set of whole blocks
+        nr_whole = len / block_size;
+        if (!u->whole_fn(u, fd, bb, bb + nr_whole))
+                return false;
+
+	bb += nr_whole;
+	len -= nr_whole * block_size;
+
+	if (!len)
+        	return true;
+
+        // Finally we write a partial end block
+        return u->partial_fn(u, fd, bb, 0, len);
 }
 
 //----------------------------------------------------------------
 
-static bool _zero_whole_blocks(struct bcache *cache, int fd, block_address bb, block_address be)
+static bool _write_partial(struct updater *u, int fd, block_address bb,
+                           uint64_t offset, size_t len)
+{
+	struct block *b;
+
+	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b, NULL))
+		return false;
+
+	memcpy(((unsigned char *) b->data) + offset, u->data, len);
+	u->data = ((unsigned char *) u->data) + len;
+
+	bcache_put(b);
+	return true;
+}
+
+static bool _write_whole(struct updater *u, int fd, block_address bb, block_address be)
 {
 	struct block *b;
+	uint64_t block_size = bcache_block_sectors(u->cache) << SECTOR_SHIFT;
 
 	for (; bb != be; bb++) {
-		if (!bcache_get(cache, fd, bb, GF_ZERO, &b, NULL))
+        	// We don't need to read the block since we are overwriting
+        	// it completely.
+		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b, NULL))
         		return false;
+		memcpy(b->data, u->data, block_size);
+		u->data = ((unsigned char *) u->data) + block_size;
         	bcache_put(b);
 	}
 
 	return true;
 }
 
-static bool _zero_partial(struct bcache *cache, int fd, block_address bb, uint64_t offset, size_t len)
+bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
+{
+        struct updater u;
+
+        u.cache = cache;
+        u.partial_fn = _write_partial;
+        u.whole_fn = _write_whole;
+        u.data = data;
+
+	return _update_bytes(&u, fd, start, len);
+}
+
+//----------------------------------------------------------------
+
+static bool _zero_partial(struct updater *u, int fd, block_address bb, uint64_t offset, size_t len)
 {
 	struct block *b;
 
-	if (!bcache_get(cache, fd, bb, GF_DIRTY, &b, NULL))
+	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b, NULL))
 		return false;
 
 	memset(((unsigned char *) b->data) + offset, 0, len);
@@ -151,40 +201,29 @@ static bool _zero_partial(struct bcache *cache, int fd, block_address bb, uint64
 	return true;
 }
 
-bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+static bool _zero_whole(struct updater *u, int fd, block_address bb, block_address be)
 {
-	block_address bb, be;
-	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
-	uint64_t block_offset = start % block_size;
-	uint64_t nr_whole;
-
-	byte_range_to_block_range(cache, start, len, &bb, &be);
+	struct block *b;
 
-	// First block may be partial
-	if (block_offset) {
-        	size_t blen = _min(block_size - block_offset, len);
-		if (!_zero_partial(cache, fd, bb, block_offset, blen))
+	for (; bb != be; bb++) {
+		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b, NULL))
         		return false;
-
-		len -= blen;
-        	if (!len)
-                	return true;
-
-                bb++;
+        	bcache_put(b);
 	}
 
-        // Now we write out a set of whole blocks
-        nr_whole = len / block_size;
-        if (!_zero_whole_blocks(cache, fd, bb, bb + nr_whole))
-                return false;
-	bb += nr_whole;
-	len -= nr_whole * block_size;
+	return true;
+}
 
-	if (!len)
-        	return true;
+bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+{
+        struct updater u;
 
-        // Finally we write a partial end block
-        return _zero_partial(cache, fd, bb, 0, len);
+        u.cache = cache;
+        u.partial_fn = _zero_partial;
+        u.whole_fn = _zero_whole;
+        u.data = NULL;
+
+	return _update_bytes(&u, fd, start, len);
 }
 
 //----------------------------------------------------------------


