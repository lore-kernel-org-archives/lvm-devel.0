From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 27 Apr 2018 05:58:54 -0400
Subject: master - [bcache] Some work on bcache_invalidate()
Message-ID: <201804270958.w3R9wsx6014891@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e890c37704be3482a5d66e59baa2811d99e3eb93
Commit:        e890c37704be3482a5d66e59baa2811d99e3eb93
Parent:        8a14b8a733b95ccb92fc8b907dc330bac474b712
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 27 10:56:13 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Apr 27 10:56:13 2018 +0100

[bcache] Some work on bcache_invalidate()

bcache_invalidate() now returns a bool to indicate success.  If fails
if the block is currently held, or the block is dirty and writeback
fails.

Added a bunch of unit tests for the invalidate functions.

Fixed some bugs to do with invalidating errored blocks.
---
 lib/device/bcache.c  |   67 ++++++++++++++++++++++++++------------------------
 lib/device/bcache.h  |   13 ++++++---
 unit-test/bcache_t.c |   63 ++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 97 insertions(+), 46 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 641838f..0995ba9 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -537,10 +537,8 @@ static void _complete_io(void *context, int err)
 	 */
 	dm_list_del(&b->list);
 
-	/* Things don't work with this block of code, but work without it. */
 	if (b->error) {
 		log_warn("bcache io error %d fd %d", b->error, b->fd);
-
 		dm_list_add(&cache->errored, &b->list);
 
 	} else {
@@ -564,14 +562,14 @@ static void _issue_low_level(struct block *b, enum dir d)
 
 	b->io_dir = d;
 	_set_flags(b, BF_IO_PENDING);
-	dm_list_add(&cache->io_pending, &b->list);
+
+	dm_list_move(&cache->io_pending, &b->list);
 
 	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
 		/* FIXME: if io_submit() set an errno, return that instead of EIO? */
 		_complete_io(b, -EIO);
 		return;
 	}
-
 }
 
 static inline void _issue_read(struct block *b)
@@ -675,6 +673,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 		_hash_insert(b);
 	}
 
+#if 0
 	if (!b) {
 		log_error("bcache no new blocks for fd %d index %u "
 			  "clean %u free %u dirty %u pending %u nr_data_blocks %u nr_cache_blocks %u",
@@ -686,6 +685,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 			  (uint32_t)cache->nr_data_blocks,
 			  (uint32_t)cache->nr_cache_blocks);
 	}
+#endif
 
 	return b;
 }
@@ -888,6 +888,13 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 	}
 }
 
+static void _recycle_block(struct bcache *cache, struct block *b)
+{
+	_unlink_block(b);
+	_hash_remove(b);
+	dm_list_add(&cache->free, &b->list);
+}
+
 bool bcache_get(struct bcache *cache, int fd, block_address index,
 	        unsigned flags, struct block **result, int *error)
 {
@@ -896,14 +903,13 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 	b = _lookup_or_read_block(cache, fd, index, flags);
 	if (b) {
 		if (b->error) {
+			*error = b->error;
 			if (b->io_dir == DIR_READ) {
 				// Now we know the read failed we can just forget
 				// about this block, since there's no dirty data to
 				// be written back.
-				_hash_remove(b);
-				dm_list_add(&cache->free, &b->list);
+				_recycle_block(cache, b);
 			}
-			*error = b->error;
 			return false;
 		}
 
@@ -957,7 +963,7 @@ bool bcache_flush(struct bcache *cache)
 			// The superblock may well be still locked.
 			continue;
 		}
-		
+
 		_issue_write(b);
 	}
 
@@ -966,47 +972,47 @@ bool bcache_flush(struct bcache *cache)
 	return dm_list_empty(&cache->errored);
 }
 
-static void _recycle_block(struct bcache *cache, struct block *b)
-{
-	_unlink_block(b);
-	_hash_remove(b);
-	dm_list_add(&cache->free, &b->list);
-}
-
 /*
  * You can safely call this with a NULL block.
  */
-static void _invalidate_block(struct bcache *cache, struct block *b)
+static bool _invalidate_block(struct bcache *cache, struct block *b)
 {
 	if (!b)
-		return;
+		return true;
 
 	if (_test_flags(b, BF_IO_PENDING))
 		_wait_specific(b);
 
-	if (b->ref_count)
+	if (b->ref_count) {
 		log_warn("bcache_invalidate: block (%d, %llu) still held",
 			 b->fd, (unsigned long long) index);
-	else {
-		if (_test_flags(b, BF_DIRTY)) {
-			_issue_write(b);
-			_wait_specific(b);
-		}
+		return false;
+	}
 
-		_recycle_block(cache, b);
+	if (_test_flags(b, BF_DIRTY)) {
+		_issue_write(b);
+		_wait_specific(b);
+
+		if (b->error)
+        		return false;
 	}
+
+	_recycle_block(cache, b);
+
+	return true;
 }
 
-void bcache_invalidate(struct bcache *cache, int fd, block_address index)
+bool bcache_invalidate(struct bcache *cache, int fd, block_address index)
 {
-	_invalidate_block(cache, _hash_lookup(cache, fd, index));
+	return _invalidate_block(cache, _hash_lookup(cache, fd, index));
 }
 
 // FIXME: switch to a trie, or maybe 1 hash table per fd?  To save iterating
 // through the whole cache.
-void bcache_invalidate_fd(struct bcache *cache, int fd)
+bool bcache_invalidate_fd(struct bcache *cache, int fd)
 {
 	struct block *b, *tmp;
+	bool r = true;
 
 	// Start writing back any dirty blocks on this fd.
 	dm_list_iterate_items_safe (b, tmp, &cache->dirty)
@@ -1018,12 +1024,9 @@ void bcache_invalidate_fd(struct bcache *cache, int fd)
 	// Everything should be in the clean list now.
 	dm_list_iterate_items_safe (b, tmp, &cache->clean)
 		if (b->fd == fd)
-			_invalidate_block(cache, b);
+			r = _invalidate_block(cache, b) && r;
 
-	// Except they could be in the errored list :)
-	dm_list_iterate_items_safe (b, tmp, &cache->errored)
-		if (b->fd == fd)
-			_recycle_block(cache, b);
+       return r;
 }
 
 static void byte_range_to_block_range(struct bcache *cache, off_t start, size_t len,
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 4ce137a..a72b83b 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -135,17 +135,20 @@ void bcache_put(struct block *b);
 bool bcache_flush(struct bcache *cache);
 
 /*
- * Removes a block from the cache.  If the block is dirty it will be written
- * back first.  If the block is currently held a warning will be issued, and it
- * will not be removed.
+ * Removes a block from the cache.
+ * 
+ * If the block is dirty it will be written back first.  If the writeback fails
+ * false will be returned.
+ * 
+ * If the block is currently held false will be returned.
  */
-void bcache_invalidate(struct bcache *cache, int fd, block_address index);
+bool bcache_invalidate(struct bcache *cache, int fd, block_address index);
 
 /*
  * Invalidates all blocks on the given descriptor.  Call this before closing
  * the descriptor to make sure everything is written back.
  */
-void bcache_invalidate_fd(struct bcache *cache, int fd);
+bool bcache_invalidate_fd(struct bcache *cache, int fd);
 
 /*
  * Prefetches the blocks neccessary to satisfy a byte range.
diff --git a/unit-test/bcache_t.c b/unit-test/bcache_t.c
index 23498a8..d06d5fe 100644
--- a/unit-test/bcache_t.c
+++ b/unit-test/bcache_t.c
@@ -729,7 +729,7 @@ static void test_invalidate_not_present(void *context)
 	struct bcache *cache = f->cache;
 	int fd = 17;
 
-	bcache_invalidate(cache, fd, 0);
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
 }
 
 static void test_invalidate_present(void *context)
@@ -746,10 +746,10 @@ static void test_invalidate_present(void *context)
 	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
 	bcache_put(b);
 
-	bcache_invalidate(cache, fd, 0);
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
 }
 
-static void test_invalidate_after_error(void *context)
+static void test_invalidate_after_read_error(void *context)
 {
 	struct fixture *f = context;
 	struct mock_engine *me = f->me;
@@ -760,13 +760,56 @@ static void test_invalidate_after_error(void *context)
 
 	_expect_read_bad_issue(me, fd, 0);
 	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
-	bcache_invalidate(cache, fd, 0);
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
 }
 
-// Tests to be written
-// show invalidate works
-// show invalidate_fd works
-// show writeback is working
+static void test_invalidate_after_write_error(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	bcache_put(b);
+
+	// invalidate should fail if the write fails
+	_expect_write_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(!bcache_invalidate(cache, fd, 0));
+
+	// and should succeed if the write does
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
+
+	// a read is not required to get the block
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_invalidate_held_block(void *context)
+{
+
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+
+	T_ASSERT(!bcache_invalidate(cache, fd, 0));
+
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	bcache_put(b);
+}
 
 /*----------------------------------------------------------------
  * Top level
@@ -801,7 +844,9 @@ static struct test_suite *_small_tests(void)
 	T("write-bad-io-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_io_stops_flush);
 	T("invalidate-not-present", "invalidate a block that isn't in the cache", test_invalidate_not_present);
 	T("invalidate-present", "invalidate a block that is in the cache", test_invalidate_present);
-	T("invalidate-error", "invalidate a block that errored", test_invalidate_after_error);
+	T("invalidate-read-error", "invalidate a block that errored", test_invalidate_after_read_error);
+	T("invalidate-write-error", "invalidate a block that errored", test_invalidate_after_write_error);
+	T("invalidate-fails-in-held", "invalidating a held block fails", test_invalidate_held_block);
 
 	return ts;
 }


