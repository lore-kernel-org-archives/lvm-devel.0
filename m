From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 16 Jan 2020 10:34:41 -0500
Subject: stable-2.02 - [bcache] Bring bcache into sync with master branch
Message-ID: <76394.120011610343600301@us-mta-22.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6e6ea2d65785f03f3cee7938be635bcb8ad4944
Commit:        b6e6ea2d65785f03f3cee7938be635bcb8ad4944
Parent:        e55210302787d063d3037835316ca06d5cd63bd5
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Jan 16 14:20:35 2020 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jan 16 14:20:35 2020 +0000

[bcache] Bring bcache into sync with master branch

---
 lib/device/bcache.c        | 350 ++++++++++++++++++---------------------------
 lib/device/bcache.h        |   1 -
 test/unit/bcache_t.c       |   7 +-
 test/unit/bcache_utils_t.c |   3 +-
 test/unit/unit-test.sh     |   2 -
 5 files changed, 143 insertions(+), 220 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index d487ca2a7..9f67a274e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
-
 #include "bcache.h"
+
+#include "base/data-struct/radix-tree.h"
 #include "lvm-logging.h"
 #include "log.h"
 
@@ -67,14 +67,14 @@ struct cb_set {
 static struct cb_set *_cb_set_create(unsigned nr)
 {
 	int i;
-	struct cb_set *cbs = dm_malloc(sizeof(*cbs));
+	struct cb_set *cbs = malloc(sizeof(*cbs));
 
 	if (!cbs)
 		return NULL;
 
-	cbs->vec = dm_malloc(nr * sizeof(*cbs->vec));
+	cbs->vec = malloc(nr * sizeof(*cbs->vec));
 	if (!cbs->vec) {
-		dm_free(cbs);
+		free(cbs);
 		return NULL;
 	}
 
@@ -97,8 +97,8 @@ static void _cb_set_destroy(struct cb_set *cbs)
 		return;
 	}
 
-	dm_free(cbs->vec);
-	dm_free(cbs);
+	free(cbs->vec);
+	free(cbs);
 }
 
 static struct control_block *_cb_alloc(struct cb_set *cbs, void *context)
@@ -152,7 +152,7 @@ static void _async_destroy(struct io_engine *ioe)
 	if (r)
 		log_sys_warn("io_destroy");
 
-	dm_free(e);
+	free(e);
 }
 
 static int _last_byte_fd;
@@ -169,7 +169,6 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	sector_t offset;
 	sector_t nbytes;
 	sector_t limit_nbytes;
-	sector_t orig_nbytes;
 	sector_t extra_nbytes = 0;
 
 	if (((uintptr_t) data) & e->page_mask) {
@@ -192,41 +191,11 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 			return false;
 		}
 
-		/*
-		 * If the bcache block offset+len goes beyond where lvm is
-		 * intending to write, then reduce the len being written
-		 * (which is the bcache block size) so we don't write past
-		 * the limit set by lvm.  If after applying the limit, the
-		 * resulting size is not a multiple of the sector size (512
-		 * or 4096) then extend the reduced size to be a multiple of
-		 * the sector size (we don't want to write partial sectors.)
-		 */
 		if (offset + nbytes > _last_byte_offset) {
 			limit_nbytes = _last_byte_offset - offset;
-
-			if (limit_nbytes % _last_byte_sector_size) {
+			if (limit_nbytes % _last_byte_sector_size)
 				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
 
-				/*
-				 * adding extra_nbytes to the reduced nbytes (limit_nbytes)
-				 * should make the final write size a multiple of the
-				 * sector size.  This should never result in a final size
-				 * larger than the bcache block size (as long as the bcache
-				 * block size is a multiple of the sector size).
-				 */
-				if (limit_nbytes + extra_nbytes > nbytes) {
-					log_warn("Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu",
-						 (unsigned long long)offset,
-						 (unsigned long long)nbytes,
-						 (unsigned long long)limit_nbytes,
-						 (unsigned long long)extra_nbytes,
-						 (unsigned long long)_last_byte_sector_size);
-					extra_nbytes = 0;
-				}
-			}
-
-			orig_nbytes = nbytes;
-
 			if (extra_nbytes) {
 				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
 					  (unsigned long long)offset,
@@ -241,22 +210,6 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes);
 				nbytes = limit_nbytes;
 			}
-
-			/*
-			 * This shouldn't happen, the reduced+extended
-			 * nbytes value should never be larger than the
-			 * bcache block size.
-			 */
-			if (nbytes > orig_nbytes) {
-				log_error("Invalid adjusted write at %llu len %llu adjusted %llu limit %llu extra %llu sector_size %llu",
-					  (unsigned long long)offset,
-					  (unsigned long long)orig_nbytes,
-					  (unsigned long long)nbytes,
-					  (unsigned long long)limit_nbytes,
-					  (unsigned long long)extra_nbytes,
-					  (unsigned long long)_last_byte_sector_size);
-				return false;
-			}
 		}
 	}
 
@@ -361,7 +314,7 @@ static unsigned _async_max_io(struct io_engine *e)
 struct io_engine *create_async_io_engine(void)
 {
 	int r;
-	struct async_engine *e = dm_malloc(sizeof(*e));
+	struct async_engine *e = malloc(sizeof(*e));
 
 	if (!e)
 		return NULL;
@@ -375,14 +328,14 @@ struct io_engine *create_async_io_engine(void)
 	r = io_setup(MAX_IO, &e->aio_context);
 	if (r < 0) {
 		log_debug("io_setup failed %d", r);
-		dm_free(e);
+		free(e);
 		return NULL;
 	}
 
 	e->cbs = _cb_set_create(MAX_IO);
 	if (!e->cbs) {
 		log_warn("couldn't create control block set");
-		dm_free(e);
+		free(e);
 		return NULL;
 	}
 
@@ -411,7 +364,7 @@ static struct sync_engine *_to_sync(struct io_engine *e)
 static void _sync_destroy(struct io_engine *ioe)
 {
         struct sync_engine *e = _to_sync(ioe);
-        dm_free(e);
+        free(e);
 }
 
 static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
@@ -430,7 +383,6 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 	}
 
 	where = sb * 512;
-
 	off = lseek(fd, where, SEEK_SET);
 	if (off == (off_t) -1) {
 		log_warn("Device seek error %d for offset %llu", errno, (unsigned long long)where);
@@ -451,7 +403,6 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 		uint64_t nbytes = len;
 		sector_t limit_nbytes = 0;
 		sector_t extra_nbytes = 0;
-		sector_t orig_nbytes = 0;
 
 		if (offset > _last_byte_offset) {
 			log_error("Limit write at %llu len %llu beyond last byte %llu",
@@ -464,30 +415,9 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
 		if (offset + nbytes > _last_byte_offset) {
 			limit_nbytes = _last_byte_offset - offset;
-
-			if (limit_nbytes % _last_byte_sector_size) {
+			if (limit_nbytes % _last_byte_sector_size)
 				extra_nbytes = _last_byte_sector_size - (limit_nbytes % _last_byte_sector_size);
 
-				/*
-				 * adding extra_nbytes to the reduced nbytes (limit_nbytes)
-				 * should make the final write size a multiple of the
-				 * sector size.  This should never result in a final size
-				 * larger than the bcache block size (as long as the bcache
-				 * block size is a multiple of the sector size).
-				 */
-				if (limit_nbytes + extra_nbytes > nbytes) {
-					log_warn("Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu",
-						 (unsigned long long)offset,
-						 (unsigned long long)nbytes,
-						 (unsigned long long)limit_nbytes,
-						 (unsigned long long)extra_nbytes,
-						 (unsigned long long)_last_byte_sector_size);
-					extra_nbytes = 0;
-				}
-			}
-
-			orig_nbytes = nbytes;
-
 			if (extra_nbytes) {
 				log_debug("Limit write at %llu len %llu to len %llu rounded to %llu",
 					  (unsigned long long)offset,
@@ -502,23 +432,6 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes);
 				nbytes = limit_nbytes;
 			}
-
-			/*
-			 * This shouldn't happen, the reduced+extended
-			 * nbytes value should never be larger than the
-			 * bcache block size.
-			 */
-			if (nbytes > orig_nbytes) {
-				log_error("Invalid adjusted write at %llu len %llu adjusted %llu limit %llu extra %llu sector_size %llu",
-					  (unsigned long long)offset,
-					  (unsigned long long)orig_nbytes,
-					  (unsigned long long)nbytes,
-					  (unsigned long long)limit_nbytes,
-					  (unsigned long long)extra_nbytes,
-					  (unsigned long long)_last_byte_sector_size);
-                                free(io);
-				return false;
-			}
 		}
 
 		where = offset;
@@ -580,7 +493,7 @@ static bool _sync_wait(struct io_engine *ioe, io_complete_fn fn)
 	dm_list_iterate_items_safe(io, tmp, &e->complete) {
 		fn(io->context, 0);
 		dm_list_del(&io->list);
-		dm_free(io);
+		free(io);
 	}
 
 	return true;
@@ -593,7 +506,7 @@ static unsigned _sync_max_io(struct io_engine *e)
 
 struct io_engine *create_sync_io_engine(void)
 {
-	struct sync_engine *e = dm_malloc(sizeof(*e));
+	struct sync_engine *e = malloc(sizeof(*e));
 
 	if (!e)
         	return NULL;
@@ -673,12 +586,7 @@ struct bcache {
 	struct dm_list clean;
 	struct dm_list io_pending;
 
-	/*
-	 * Hash table.
-	 */
-	unsigned nr_buckets;
-	unsigned hash_mask;
-	struct dm_list *buckets;
+	struct radix_tree *rtree;
 
 	/*
 	 * Statistics
@@ -693,75 +601,50 @@ struct bcache {
 
 //----------------------------------------------------------------
 
-/*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
-#define GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001ULL
+struct key_parts {
+	uint32_t fd;
+	uint64_t b;
+} __attribute__ ((packed));
 
-static unsigned _hash(struct bcache *cache, int fd, uint64_t i)
-{
-	uint64_t h = (i << 10) & fd;
-	h *= GOLDEN_RATIO_PRIME_64;
-	return h & cache->hash_mask;
-}
+union key {
+	struct key_parts parts;
+        uint8_t bytes[12];
+};
 
-static struct block *_hash_lookup(struct bcache *cache, int fd, uint64_t i)
+static struct block *_block_lookup(struct bcache *cache, int fd, uint64_t i)
 {
-	struct block *b;
-	unsigned h = _hash(cache, fd, i);
-
-	dm_list_iterate_items_gen (b, cache->buckets + h, hash)
-		if (b->fd == fd && b->index == i)
-			return b;
+	union key k;
+	union radix_value v;
 
-	return NULL;
-}
+	k.parts.fd = fd;
+	k.parts.b = i;
 
-static void _hash_insert(struct block *b)
-{
-	unsigned h = _hash(b->cache, b->fd, b->index);
-	dm_list_add_h(b->cache->buckets + h, &b->hash);
-}
+	if (radix_tree_lookup(cache->rtree, k.bytes, k.bytes + sizeof(k.bytes), &v))
+		return v.ptr;
 
-static inline void _hash_remove(struct block *b)
-{
-	dm_list_del(&b->hash);
+	return NULL;
 }
 
-/*
- * Must return a power of 2.
- */
-static unsigned _calc_nr_buckets(unsigned nr_blocks)
+static bool _block_insert(struct block *b)
 {
-	unsigned r = 8;
-	unsigned n = nr_blocks / 4;
+        union key k;
+        union radix_value v;
 
-	if (n < 8)
-		n = 8;
+        k.parts.fd = b->fd;
+        k.parts.b = b->index;
+        v.ptr = b;
 
-	while (r < n)
-		r <<= 1;
-
-	return r;
+	return radix_tree_insert(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes), v);
 }
 
-static bool _hash_table_init(struct bcache *cache, unsigned nr_entries)
+static void _block_remove(struct block *b)
 {
-	unsigned i;
+        union key k;
 
-	cache->nr_buckets = _calc_nr_buckets(nr_entries);
-	cache->hash_mask = cache->nr_buckets - 1;
-	cache->buckets = dm_malloc(cache->nr_buckets * sizeof(*cache->buckets));
-	if (!cache->buckets)
-		return false;
+        k.parts.fd = b->fd;
+        k.parts.b = b->index;
 
-	for (i = 0; i < cache->nr_buckets; i++)
-		dm_list_init(cache->buckets + i);
-
-	return true;
-}
-
-static void _hash_table_exit(struct bcache *cache)
-{
-	dm_free(cache->buckets);
+	radix_tree_remove(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes));
 }
 
 //----------------------------------------------------------------
@@ -777,7 +660,7 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 	if (!data)
 		return false;
 
-	cache->raw_blocks = dm_malloc(count * sizeof(*cache->raw_blocks));
+	cache->raw_blocks = malloc(count * sizeof(*cache->raw_blocks));
 	if (!cache->raw_blocks) {
 		free(data);
 		return false;
@@ -797,8 +680,8 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 
 static void _exit_free_list(struct bcache *cache)
 {
-	dm_free(cache->raw_data);
-	dm_free(cache->raw_blocks);
+	free(cache->raw_data);
+	free(cache->raw_blocks);
 }
 
 static struct block *_alloc_block(struct bcache *cache)
@@ -809,6 +692,11 @@ static struct block *_alloc_block(struct bcache *cache)
 	return dm_list_struct_base(_list_pop(&cache->free), struct block, list);
 }
 
+static void _free_block(struct block *b)
+{
+	dm_list_add(&b->cache->free, &b->list);
+}
+
 /*----------------------------------------------------------------
  * Clean/dirty list management.
  * Always use these methods to ensure nr_dirty_ is correct.
@@ -963,7 +851,7 @@ static struct block *_find_unused_clean_block(struct bcache *cache)
 	dm_list_iterate_items (b, &cache->clean) {
 		if (!b->ref_count) {
 			_unlink_block(b);
-			_hash_remove(b);
+			_block_remove(b);
 			return b;
 		}
 	}
@@ -993,29 +881,18 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 
 	if (b) {
 		dm_list_init(&b->list);
-		dm_list_init(&b->hash);
 		b->flags = 0;
 		b->fd = fd;
 		b->index = i;
 		b->ref_count = 0;
 		b->error = 0;
 
-		_hash_insert(b);
-	}
-
-#if 0
-	if (!b) {
-		log_error("bcache no new blocks for fd %d index %u "
-			  "clean %u free %u dirty %u pending %u nr_data_blocks %u nr_cache_blocks %u",
-			  fd, (uint32_t) i,
-			  dm_list_size(&cache->clean),
-			  dm_list_size(&cache->free),
-			  dm_list_size(&cache->dirty),
-			  dm_list_size(&cache->io_pending),
-			  (uint32_t)cache->nr_data_blocks,
-			  (uint32_t)cache->nr_cache_blocks);
+		if (!_block_insert(b)) {
+        		log_error("bcache unable to insert block in radix tree (OOM?)");
+			_free_block(b);
+			return NULL;
+		}
 	}
-#endif
 
 	return b;
 }
@@ -1054,7 +931,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 				  	   int fd, block_address i,
 					   unsigned flags)
 {
-	struct block *b = _hash_lookup(cache, fd, i);
+	struct block *b = _block_lookup(cache, fd, i);
 
 	if (b) {
 		// FIXME: this is insufficient.  We need to also catch a read
@@ -1125,8 +1002,8 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	unsigned max_io = engine->max_io(engine);
 	long pgsize = sysconf(_SC_PAGESIZE);
 
-	if ((pgsize = sysconf(_SC_PAGESIZE)) < 0) {
-		log_warn("bcache cannot read pagesize.");
+	if (pgsize < 0) {
+		log_warn("WARNING: _SC_PAGESIZE returns negative value.");
 		return NULL;
 	}
 
@@ -1145,7 +1022,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 		return NULL;
 	}
 
-	cache = dm_malloc(sizeof(*cache));
+	cache = malloc(sizeof(*cache));
 	if (!cache)
 		return NULL;
 
@@ -1163,9 +1040,10 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	dm_list_init(&cache->clean);
 	dm_list_init(&cache->io_pending);
 
-	if (!_hash_table_init(cache, nr_cache_blocks)) {
+        cache->rtree = radix_tree_create(NULL, NULL);
+	if (!cache->rtree) {
 		cache->engine->destroy(cache->engine);
-		dm_free(cache);
+		free(cache);
 		return NULL;
 	}
 
@@ -1178,8 +1056,8 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 
 	if (!_init_free_list(cache, nr_cache_blocks, pgsize)) {
 		cache->engine->destroy(cache->engine);
-		_hash_table_exit(cache);
-		dm_free(cache);
+		radix_tree_destroy(cache->rtree);
+		free(cache);
 		return NULL;
 	}
 
@@ -1192,12 +1070,12 @@ void bcache_destroy(struct bcache *cache)
 		log_warn("some blocks are still locked");
 
 	if (!bcache_flush(cache))
-		log_warn("cache flushing failed.");
+		stack;
 	_wait_all(cache);
 	_exit_free_list(cache);
-	_hash_table_exit(cache);
+	radix_tree_destroy(cache->rtree);
 	cache->engine->destroy(cache->engine);
-	dm_free(cache);
+	free(cache);
 }
 
 sector_t bcache_block_sectors(struct bcache *cache)
@@ -1217,7 +1095,7 @@ unsigned bcache_max_prefetches(struct bcache *cache)
 
 void bcache_prefetch(struct bcache *cache, int fd, block_address i)
 {
-	struct block *b = _hash_lookup(cache, fd, i);
+	struct block *b = _block_lookup(cache, fd, i);
 
 	if (!b) {
 		if (cache->nr_io_pending < cache->max_io) {
@@ -1230,11 +1108,13 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address i)
 	}
 }
 
+//----------------------------------------------------------------
+
 static void _recycle_block(struct bcache *cache, struct block *b)
 {
 	_unlink_block(b);
-	_hash_remove(b);
-	dm_list_add(&cache->free, &b->list);
+	_block_remove(b);
+	_free_block(b);
 }
 
 bool bcache_get(struct bcache *cache, int fd, block_address i,
@@ -1268,6 +1148,8 @@ bool bcache_get(struct bcache *cache, int fd, block_address i,
 	return false;
 }
 
+//----------------------------------------------------------------
+
 static void _put_ref(struct block *b)
 {
 	if (!b->ref_count) {
@@ -1288,6 +1170,8 @@ void bcache_put(struct block *b)
 		_preemptive_writeback(b->cache);
 }
 
+//----------------------------------------------------------------
+
 bool bcache_flush(struct bcache *cache)
 {
 	// Only dirty data is on the errored list, since bad read blocks get
@@ -1310,6 +1194,7 @@ bool bcache_flush(struct bcache *cache)
 	return dm_list_empty(&cache->errored);
 }
 
+//----------------------------------------------------------------
 /*
  * You can safely call this with a NULL block.
  */
@@ -1342,29 +1227,72 @@ static bool _invalidate_block(struct bcache *cache, struct block *b)
 
 bool bcache_invalidate(struct bcache *cache, int fd, block_address i)
 {
-	return _invalidate_block(cache, _hash_lookup(cache, fd, i));
+	return _invalidate_block(cache, _block_lookup(cache, fd, i));
+}
+
+//----------------------------------------------------------------
+
+struct invalidate_iterator {
+	bool success;
+	struct radix_tree_iterator it;
+};
+
+static bool _writeback_v(struct radix_tree_iterator *it,
+                         uint8_t *kb, uint8_t *ke, union radix_value v)
+{
+	struct block *b = v.ptr;
+
+	if (_test_flags(b, BF_DIRTY))
+        	_issue_write(b);
+
+        return true;
+}
+
+static bool _invalidate_v(struct radix_tree_iterator *it,
+                          uint8_t *kb, uint8_t *ke, union radix_value v)
+{
+	struct block *b = v.ptr;
+        struct invalidate_iterator *iit = container_of(it, struct invalidate_iterator, it);
+
+	if (b->error || _test_flags(b, BF_DIRTY)) {
+        	log_warn("bcache_invalidate: block (%d, %llu) still dirty",
+                         b->fd, (unsigned long long) b->index);
+        	iit->success = false;
+        	return true;
+	}
+
+	if (b->ref_count) {
+		log_warn("bcache_invalidate: block (%d, %llu) still held",
+			 b->fd, (unsigned long long) b->index);
+		iit->success = false;
+		return true;
+	}
+
+	_unlink_block(b);
+	_free_block(b);
+
+	// We can't remove the block from the radix tree yet because
+	// we're in the middle of an iteration.
+	return true;
 }
 
-// FIXME: switch to a trie, or maybe 1 hash table per fd?  To save iterating
-// through the whole cache.
 bool bcache_invalidate_fd(struct bcache *cache, int fd)
 {
-	struct block *b, *tmp;
-	bool r = true;
+        union key k;
+	struct invalidate_iterator it;
 
-	// Start writing back any dirty blocks on this fd.
-	dm_list_iterate_items_safe (b, tmp, &cache->dirty)
-		if (b->fd == fd)
-			_issue_write(b);
+	k.parts.fd = fd;
 
-	_wait_all(cache);
+	it.it.visit = _writeback_v;
+	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it.it);
 
-	// Everything should be in the clean list now.
-	dm_list_iterate_items_safe (b, tmp, &cache->clean)
-		if (b->fd == fd)
-			r = _invalidate_block(cache, b) && r;
+	_wait_all(cache);
 
-       return r;
+	it.success = true;
+	it.it.visit = _invalidate_v;
+	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it.it);
+	radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd));
+	return it.success;
 }
 
 //----------------------------------------------------------------
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index cb902ef36..790d0fec3 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -61,7 +61,6 @@ struct block {
 
 	struct bcache *cache;
 	struct dm_list list;
-	struct dm_list hash;
 
 	unsigned flags;
 	unsigned ref_count;
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 925b95d3d..92c2d57d4 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -12,15 +12,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "units.h"
+#include "lib/device/bcache.h"
+
 #include <errno.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
 
-#include "bcache.h"
-#include "framework.h"
-#include "units.h"
-
 #define SHOW_MOCK_CALLS 0
 
 /*----------------------------------------------------------------
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 9ddc19469..2e0832096 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -14,9 +14,8 @@
 
 #define _GNU_SOURCE
 
-#include "bcache.h"
-#include "framework.h"
 #include "units.h"
+#include "lib/device/bcache.h"
 
 #include <errno.h>
 #include <stdio.h>
diff --git a/test/unit/unit-test.sh b/test/unit/unit-test.sh
index e8332d62d..f545f1490 100644
--- a/test/unit/unit-test.sh
+++ b/test/unit/unit-test.sh
@@ -13,8 +13,6 @@
 
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMETAD=1
-SKIP_WITH_CLVMD=1
 
 SKIP_ROOT_DM_CHECK=1
 



