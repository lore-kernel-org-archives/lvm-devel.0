From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 07:49:18 -0400
Subject: master - bcache: switch to storing blocks in a radix tree.
Message-ID: <201806011149.w51BnIDr027221@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7635df8cce131b07b45024e690e4e6917cceb198
Commit:        7635df8cce131b07b45024e690e4e6917cceb198
Parent:        272ec3fa73c92764ef6fe5466fc367fed66dd7f9
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 30 14:17:26 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 30 14:17:26 2018 +0100

bcache: switch to storing blocks in a radix tree.

Rather than a hash table.  This will make invalidate_fd() more
efficient since we can iterate just those blocks that are on
a particular dev.
---
 lib/Makefile.in     |    1 +
 lib/device/bcache.c |  212 ++++++++++++++++++++++++++++-----------------------
 make.tmpl.in        |    2 +-
 3 files changed, 117 insertions(+), 98 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 1d42235..4fb4fcf 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -21,6 +21,7 @@ ifeq ("@CLUSTER@", "shared")
 endif
 
 SOURCES =\
+	../base/data-struct/radix-tree.c \
 	activate/activate.c \
 	cache/lvmcache.c \
 	cache_segtype/cache.c \
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 9e94fcc..d9bacf8 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -15,6 +15,8 @@
 #define _GNU_SOURCE
 
 #include "bcache.h"
+
+#include "base/data-struct/radix-tree.h"
 #include "lvm-logging.h"
 #include "log.h"
 
@@ -453,12 +455,7 @@ struct bcache {
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
@@ -473,75 +470,50 @@ struct bcache {
 
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
-
-	if (n < 8)
-		n = 8;
+        union key k;
+        union radix_value v;
 
-	while (r < n)
-		r <<= 1;
+        k.parts.fd = b->fd;
+        k.parts.b = b->index;
+        v.ptr = b;
 
-	return r;
+	return radix_tree_insert(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes), v);
 }
 
-static bool _hash_table_init(struct bcache *cache, unsigned nr_entries)
+static void _block_remove(struct block *b)
 {
-	unsigned i;
-
-	cache->nr_buckets = _calc_nr_buckets(nr_entries);
-	cache->hash_mask = cache->nr_buckets - 1;
-	cache->buckets = dm_malloc(cache->nr_buckets * sizeof(*cache->buckets));
-	if (!cache->buckets)
-		return false;
+        union key k;
 
-	for (i = 0; i < cache->nr_buckets; i++)
-		dm_list_init(cache->buckets + i);
+        k.parts.fd = b->fd;
+        k.parts.b = b->index;
 
-	return true;
-}
-
-static void _hash_table_exit(struct bcache *cache)
-{
-	dm_free(cache->buckets);
+	radix_tree_remove(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes));
 }
 
 //----------------------------------------------------------------
@@ -587,6 +559,11 @@ static struct block *_alloc_block(struct bcache *cache)
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
@@ -742,7 +719,7 @@ static struct block *_find_unused_clean_block(struct bcache *cache)
 	dm_list_iterate_items (b, &cache->clean) {
 		if (!b->ref_count) {
 			_unlink_block(b);
-			_hash_remove(b);
+			_block_remove(b);
 			return b;
 		}
 	}
@@ -779,22 +756,12 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
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
@@ -833,7 +800,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 				  	   int fd, block_address i,
 					   unsigned flags)
 {
-	struct block *b = _hash_lookup(cache, fd, i);
+	struct block *b = _block_lookup(cache, fd, i);
 
 	if (b) {
 		// FIXME: this is insufficient.  We need to also catch a read
@@ -937,7 +904,8 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	dm_list_init(&cache->clean);
 	dm_list_init(&cache->io_pending);
 
-	if (!_hash_table_init(cache, nr_cache_blocks)) {
+        cache->rtree = radix_tree_create(NULL, NULL);
+	if (!cache->rtree) {
 		cache->engine->destroy(cache->engine);
 		dm_free(cache);
 		return NULL;
@@ -952,7 +920,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 
 	if (!_init_free_list(cache, nr_cache_blocks, pgsize)) {
 		cache->engine->destroy(cache->engine);
-		_hash_table_exit(cache);
+		radix_tree_destroy(cache->rtree);
 		dm_free(cache);
 		return NULL;
 	}
@@ -968,7 +936,7 @@ void bcache_destroy(struct bcache *cache)
 	bcache_flush(cache);
 	_wait_all(cache);
 	_exit_free_list(cache);
-	_hash_table_exit(cache);
+	radix_tree_destroy(cache->rtree);
 	cache->engine->destroy(cache->engine);
 	dm_free(cache);
 }
@@ -990,7 +958,7 @@ unsigned bcache_max_prefetches(struct bcache *cache)
 
 void bcache_prefetch(struct bcache *cache, int fd, block_address i)
 {
-	struct block *b = _hash_lookup(cache, fd, i);
+	struct block *b = _block_lookup(cache, fd, i);
 
 	if (!b) {
 		if (cache->nr_io_pending < cache->max_io) {
@@ -1003,11 +971,13 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address i)
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
@@ -1041,6 +1011,8 @@ bool bcache_get(struct bcache *cache, int fd, block_address i,
 	return false;
 }
 
+//----------------------------------------------------------------
+
 static void _put_ref(struct block *b)
 {
 	if (!b->ref_count) {
@@ -1061,6 +1033,8 @@ void bcache_put(struct block *b)
 		_preemptive_writeback(b->cache);
 }
 
+//----------------------------------------------------------------
+
 bool bcache_flush(struct bcache *cache)
 {
 	// Only dirty data is on the errored list, since bad read blocks get
@@ -1083,6 +1057,7 @@ bool bcache_flush(struct bcache *cache)
 	return dm_list_empty(&cache->errored);
 }
 
+//----------------------------------------------------------------
 /*
  * You can safely call this with a NULL block.
  */
@@ -1115,29 +1090,72 @@ static bool _invalidate_block(struct bcache *cache, struct block *b)
 
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
diff --git a/make.tmpl.in b/make.tmpl.in
index 9d5d367..1f999ec 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -306,7 +306,7 @@ LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)
 
 LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
-INCLUDES += -I$(srcdir) -I$(top_builddir)/include
+INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
 
 INC_LNS = $(top_builddir)/include/.symlinks_created
 


