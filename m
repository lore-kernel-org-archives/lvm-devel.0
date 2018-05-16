From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 16 May 2018 05:14:47 -0400
Subject: master - bcache: nr_ios_pending wasn't being incremented
Message-ID: <201805160914.w4G9ElFS025616@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df2acbbb97dbda000053afd40d2e4a707e226b52
Commit:        df2acbbb97dbda000053afd40d2e4a707e226b52
Parent:        413488edc6dd077e79517e44a8d3b9a51c5138e5
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 16 10:09:17 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 16 10:09:17 2018 +0100

bcache: nr_ios_pending wasn't being incremented

... but it was being decremented on completion.  Which meant
it wrapped, and no prefetches were ever issued after the
first completion.
---
 lib/device/bcache.c  |    1 +
 test/unit/bcache_t.c |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 9085d87..652441f 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -667,6 +667,7 @@ static void _issue_low_level(struct block *b, enum dir d)
 
 	b->io_dir = d;
 	_set_flags(b, BF_IO_PENDING);
+	cache->nr_io_pending++;
 
 	dm_list_move(&cache->io_pending, &b->list);
 
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index e1c0e85..803a088 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -504,7 +504,7 @@ static void test_prefetch_issues_a_read(void *context)
 		_expect_read(me, fd, i);
 		bcache_prefetch(cache, fd, i);
 	}
-
+	_no_outstanding_expectations(me);
 
 	for (i = 0; i < nr_cache_blocks; i++) {
 		_expect(me, E_WAIT);
@@ -810,6 +810,47 @@ static void test_invalidate_held_block(void *context)
 	bcache_put(b);
 }
 
+//----------------------------------------------------------------
+// Chasing a bug reported by dct
+
+static void _cycle(struct fixture *f, unsigned nr_cache_blocks)
+{
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		// prefetch should not wait
+		_expect_read(me, i, 0);
+		bcache_prefetch(cache, i, 0);
+	}
+
+	// This double checks the reads occur in response to the prefetch
+	_no_outstanding_expectations(me);
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, i, 0, 0, &b));
+		bcache_put(b);
+	}
+
+	_no_outstanding_expectations(me);
+}
+
+static void test_concurrent_reads_after_invalidate(void *context)
+{
+	struct fixture *f = context;
+	unsigned i, nr_cache_blocks = 16;
+
+	_cycle(f, nr_cache_blocks);
+	fprintf(stderr, "cycle 1 complete\n");
+	for (i = 0; i < nr_cache_blocks; i++)
+        	bcache_invalidate_fd(f->cache, i);
+        _cycle(f, nr_cache_blocks);
+	fprintf(stderr, "cycle 2 complete\n");
+}
 
 /*----------------------------------------------------------------
  * Top level
@@ -859,6 +900,8 @@ static struct test_suite *_small_tests(void)
 	T("invalidate-read-error", "invalidate a block that errored", test_invalidate_after_read_error);
 	T("invalidate-write-error", "invalidate a block that errored", test_invalidate_after_write_error);
 	T("invalidate-fails-in-held", "invalidating a held block fails", test_invalidate_held_block);
+	T("concurrent-reads-after-invalidate", "prefetch should still issue concurrent reads after invalidate",
+          test_concurrent_reads_after_invalidate);
 
 	return ts;
 }


