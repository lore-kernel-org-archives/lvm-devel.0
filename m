From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 28 Oct 2019 11:16:11 -0400
Subject: master - [bcache] add bcache_abort()
Message-ID: <201910281516.x9SFGBcW002141@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2938b4dcca0a1df661758abfab7f402ea7aab018
Commit:        2938b4dcca0a1df661758abfab7f402ea7aab018
Parent:        6163b733e1564b4c322204b9a8208e2ea4e63181
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Oct 28 14:29:47 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Oct 28 15:00:53 2019 +0000

[bcache] add bcache_abort()

This gives us a way to cope with write failures.
---
 lib/device/bcache.c  |   33 ++++++++++++++++++++++++
 lib/device/bcache.h  |    7 +++++
 test/unit/bcache_t.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 106 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index d100419..b0edf28 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1382,6 +1382,39 @@ bool bcache_invalidate_fd(struct bcache *cache, int fd)
 
 //----------------------------------------------------------------
 
+static bool _abort_v(struct radix_tree_iterator *it,
+                     uint8_t *kb, uint8_t *ke, union radix_value v)
+{
+	struct block *b = v.ptr;
+
+	if (b->ref_count) {
+		log_fatal("bcache_abort: block (%d, %llu) still held",
+			 b->fd, (unsigned long long) b->index);
+		return true;
+	}
+
+	_unlink_block(b);
+	_free_block(b);
+
+	// We can't remove the block from the radix tree yet because
+	// we're in the middle of an iteration.
+	return true;
+}
+
+void bcache_abort_fd(struct bcache *cache, int fd)
+{
+        union key k;
+	struct radix_tree_iterator it;
+
+	k.parts.fd = fd;
+
+	it.visit = _abort_v;
+	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it);
+	radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd));
+}
+
+//----------------------------------------------------------------
+
 void bcache_set_last_byte(struct bcache *cache, int fd, uint64_t offset, int sector_size)
 {
 	_last_byte_fd = fd;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 8c16caa..7622fd3 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -144,6 +144,13 @@ bool bcache_invalidate(struct bcache *cache, int fd, block_address index);
  */
 bool bcache_invalidate_fd(struct bcache *cache, int fd);
 
+/*
+ * Call this function if flush, or invalidate fail and you do not
+ * wish to retry the writes.  This will throw away any dirty data
+ * not written.  If any blocks for fd are held, then it will call
+ * abort().
+ */
+void bcache_abort_fd(struct bcache *cache, int fd);
 
 //----------------------------------------------------------------
 // The next four functions are utilities written in terms of the above api.
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 92c2d57..668d24d 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -793,7 +793,6 @@ static void test_invalidate_after_write_error(void *context)
 
 static void test_invalidate_held_block(void *context)
 {
-
 	struct fixture *f = context;
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
@@ -810,6 +809,67 @@ static void test_invalidate_held_block(void *context)
 }
 
 //----------------------------------------------------------------
+// abort tests
+
+static void test_abort_no_blocks(void *context)
+{
+	struct fixture *f = context;
+	struct bcache *cache = f->cache;
+	int fd = 17;
+
+	// We have no expectations
+	bcache_abort_fd(cache, fd);
+}
+
+static void test_abort_single_block(void *context)
+{
+	struct fixture *f = context;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+	bcache_put(b);
+
+	bcache_abort_fd(cache, fd);
+
+	// no write should be issued
+	T_ASSERT(bcache_flush(cache));
+}
+
+static void test_abort_only_specific_fd(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd1 = 17, fd2 = 18;
+
+	T_ASSERT(bcache_get(cache, fd1, 0, GF_ZERO, &b));
+	bcache_put(b);
+
+	T_ASSERT(bcache_get(cache, fd1, 1, GF_ZERO, &b));
+	bcache_put(b);
+
+	T_ASSERT(bcache_get(cache, fd2, 0, GF_ZERO, &b));
+	bcache_put(b);
+
+	T_ASSERT(bcache_get(cache, fd2, 1, GF_ZERO, &b));
+	bcache_put(b);
+
+	bcache_abort_fd(cache, fd2);
+
+	// writes for fd1 should still be issued
+	_expect_write(me, fd1, 0);
+	_expect_write(me, fd1, 1);
+
+	_expect(me, E_WAIT);
+	_expect(me, E_WAIT);
+
+	T_ASSERT(bcache_flush(cache));
+}
+
+//----------------------------------------------------------------
 // Chasing a bug reported by dct
 
 static void _cycle(struct fixture *f, unsigned nr_cache_blocks)
@@ -897,6 +957,11 @@ static struct test_suite *_small_tests(void)
 	T("invalidate-read-error", "invalidate a block that errored", test_invalidate_after_read_error);
 	T("invalidate-write-error", "invalidate a block that errored", test_invalidate_after_write_error);
 	T("invalidate-fails-in-held", "invalidating a held block fails", test_invalidate_held_block);
+
+	T("abort-with-no-blocks", "you can call abort, even if there are no blocks in the cache", test_abort_no_blocks);
+	T("abort-single-block", "single block get silently discarded", test_abort_single_block);
+	T("abort-specific-fd", "abort doesn't effect other fds", test_abort_only_specific_fd);
+
 	T("concurrent-reads-after-invalidate", "prefetch should still issue concurrent reads after invalidate",
           test_concurrent_reads_after_invalidate);
 


