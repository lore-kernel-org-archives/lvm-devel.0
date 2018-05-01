From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 08:22:22 -0400
Subject: master - bcache: squash some warnings on rhel6
Message-ID: <201805011222.w41CMMnb025155@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfc61a9543f3fc669d265d9b6e384cef0ab78ef2
Commit:        bfc61a9543f3fc669d265d9b6e384cef0ab78ef2
Parent:        de042fa13ddaecc9b4512ceb4196b2a2345f1f90
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 13:21:53 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 13:21:53 2018 +0100

bcache: squash some warnings on rhel6

---
 lib/device/bcache.c |   50 +++++++++++++++++++++++++-------------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 2464e59..68d2e53 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -36,9 +36,9 @@
 
 //----------------------------------------------------------------
 
-static void log_sys_warn(const char *syscall)
+static void log_sys_warn(const char *call)
 {
-	log_warn("%s failed: %s", syscall, strerror(errno));
+	log_warn("%s failed: %s", call, strerror(errno));
 }
 
 // Assumes the list is not empty.
@@ -164,7 +164,7 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	struct control_block *cb;
 	struct async_engine *e = _to_async(ioe);
 
-	if (((uint64_t) data) & (PAGE_SIZE - 1)) {
+	if (((uintptr_t) data) & (PAGE_SIZE - 1)) {
 		log_warn("misaligned data buffer");
 		return false;
 	}
@@ -366,22 +366,22 @@ struct bcache {
 //----------------------------------------------------------------
 
 /*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
-#define GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001UL
+#define GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001ULL
 
-static unsigned _hash(struct bcache *cache, int fd, uint64_t index)
+static unsigned _hash(struct bcache *cache, int fd, uint64_t i)
 {
-	uint64_t h = (index << 10) & fd;
+	uint64_t h = (i << 10) & fd;
 	h *= GOLDEN_RATIO_PRIME_64;
 	return h & cache->hash_mask;
 }
 
-static struct block *_hash_lookup(struct bcache *cache, int fd, uint64_t index)
+static struct block *_hash_lookup(struct bcache *cache, int fd, uint64_t i)
 {
 	struct block *b;
-	unsigned h = _hash(cache, fd, index);
+	unsigned h = _hash(cache, fd, i);
 
 	dm_list_iterate_items_gen (b, cache->buckets + h, hash)
-		if (b->fd == fd && b->index == index)
+		if (b->fd == fd && b->index == i)
 			return b;
 
 	return NULL;
@@ -641,7 +641,7 @@ static struct block *_find_unused_clean_block(struct bcache *cache)
 	return NULL;
 }
 
-static struct block *_new_block(struct bcache *cache, int fd, block_address index, bool can_wait)
+static struct block *_new_block(struct bcache *cache, int fd, block_address i, bool can_wait)
 {
 	struct block *b;
 
@@ -655,7 +655,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 				_wait_io(cache);
 			} else {
 				log_error("bcache no new blocks for fd %d index %u",
-					  fd, (uint32_t)index);
+					  fd, (uint32_t) i);
 				return NULL;
 			}
 		}
@@ -666,7 +666,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 		dm_list_init(&b->hash);
 		b->flags = 0;
 		b->fd = fd;
-		b->index = index;
+		b->index = i;
 		b->ref_count = 0;
 		b->error = 0;
 
@@ -677,7 +677,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 	if (!b) {
 		log_error("bcache no new blocks for fd %d index %u "
 			  "clean %u free %u dirty %u pending %u nr_data_blocks %u nr_cache_blocks %u",
-			  fd, (uint32_t)index,
+			  fd, (uint32_t) i,
 			  dm_list_size(&cache->clean),
 			  dm_list_size(&cache->free),
 			  dm_list_size(&cache->dirty),
@@ -721,10 +721,10 @@ static void _miss(struct bcache *cache, unsigned flags)
 }
 
 static struct block *_lookup_or_read_block(struct bcache *cache,
-				  	   int fd, block_address index,
+				  	   int fd, block_address i,
 					   unsigned flags)
 {
-	struct block *b = _hash_lookup(cache, fd, index);
+	struct block *b = _hash_lookup(cache, fd, i);
 
 	if (b) {
 		// FIXME: this is insufficient.  We need to also catch a read
@@ -749,7 +749,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 	} else {
 		_miss(cache, flags);
 
-		b = _new_block(cache, fd, index, true);
+		b = _new_block(cache, fd, i, true);
 		if (b) {
 			if (flags & GF_ZERO)
 				_zero_block(b);
@@ -873,13 +873,13 @@ unsigned bcache_max_prefetches(struct bcache *cache)
 	return cache->max_io;
 }
 
-void bcache_prefetch(struct bcache *cache, int fd, block_address index)
+void bcache_prefetch(struct bcache *cache, int fd, block_address i)
 {
-	struct block *b = _hash_lookup(cache, fd, index);
+	struct block *b = _hash_lookup(cache, fd, i);
 
 	if (!b) {
 		if (cache->nr_io_pending < cache->max_io) {
-			b = _new_block(cache, fd, index, false);
+			b = _new_block(cache, fd, i, false);
 			if (b) {
 				cache->prefetches++;
 				_issue_read(b);
@@ -895,12 +895,12 @@ static void _recycle_block(struct bcache *cache, struct block *b)
 	dm_list_add(&cache->free, &b->list);
 }
 
-bool bcache_get(struct bcache *cache, int fd, block_address index,
+bool bcache_get(struct bcache *cache, int fd, block_address i,
 	        unsigned flags, struct block **result, int *error)
 {
 	struct block *b;
 
-	b = _lookup_or_read_block(cache, fd, index, flags);
+	b = _lookup_or_read_block(cache, fd, i, flags);
 	if (b) {
 		if (b->error) {
 			*error = b->error;
@@ -926,7 +926,7 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 	if (error)
 		*error = -BCACHE_NO_BLOCK;
 
-	log_error("bcache failed to get block %u fd %d", (uint32_t)index, fd);
+	log_error("bcache failed to get block %u fd %d", (uint32_t) i, fd);
 	return false;
 }
 
@@ -985,7 +985,7 @@ static bool _invalidate_block(struct bcache *cache, struct block *b)
 
 	if (b->ref_count) {
 		log_warn("bcache_invalidate: block (%d, %llu) still held",
-			 b->fd, (unsigned long long) index);
+			 b->fd, (unsigned long long) b->index);
 		return false;
 	}
 
@@ -1002,9 +1002,9 @@ static bool _invalidate_block(struct bcache *cache, struct block *b)
 	return true;
 }
 
-bool bcache_invalidate(struct bcache *cache, int fd, block_address index)
+bool bcache_invalidate(struct bcache *cache, int fd, block_address i)
 {
-	return _invalidate_block(cache, _hash_lookup(cache, fd, index));
+	return _invalidate_block(cache, _hash_lookup(cache, fd, i));
 }
 
 // FIXME: switch to a trie, or maybe 1 hash table per fd?  To save iterating


