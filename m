From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:32 -0400
Subject: master - [device/bcache] More fiddling with tests
Message-ID: <201804231347.w3NDlW2f031277@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cde30eba0fc4404f092fb5106f7cc7fcd66795b
Commit:        1cde30eba0fc4404f092fb5106f7cc7fcd66795b
Parent:        6a57ed17a28aee0e8fb9557ec3c03a02f0b2a4be
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Feb 6 13:06:15 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] More fiddling with tests

---
 test/unit/bcache_t.c |  484 ++++++++++++++++++++++----------------------------
 1 files changed, 214 insertions(+), 270 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index c2d2df0..5fb6789 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -219,6 +219,56 @@ static struct mock_engine *_mock_create(unsigned max_io)
 }
 
 /*----------------------------------------------------------------
+ * Fixtures
+ *--------------------------------------------------------------*/
+struct fixture {
+	struct mock_engine *me;
+	struct bcache *cache;
+};
+
+static struct fixture *_fixture_init(unsigned nr_cache_blocks)
+{
+	struct fixture *f = malloc(sizeof(*f));
+
+	f->me = _mock_create(16);
+	T_ASSERT(f->me);
+
+	_expect(f->me, E_MAX_IO);
+	f->cache = bcache_create(128, nr_cache_blocks, &f->me->e);
+	T_ASSERT(f->cache);
+
+	return f;
+}
+
+static void _fixture_exit(struct fixture *f)
+{
+	_expect(f->me, E_DESTROY);
+	bcache_destroy(f->cache);
+
+	free(f);
+}
+
+static void *_small_fixture_init(void)
+{
+	return _fixture_init(16);
+}
+
+static void _small_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
+static void *_large_fixture_init(void)
+{
+	return _fixture_init(1024);
+}
+
+static void _large_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
+/*----------------------------------------------------------------
  * Tests
  *--------------------------------------------------------------*/
 #define MEG 2048
@@ -250,22 +300,22 @@ static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
 	me->e.destroy(&me->e);
 }
 
-static void test_create(void)
+static void test_create(void *fixture)
 {
 	good_create(8, 16);
 }
 
-static void test_nr_cache_blocks_must_be_positive(void)
+static void test_nr_cache_blocks_must_be_positive(void *fixture)
 {
 	bad_create(8, 0);
 }
 
-static void test_block_size_must_be_positive(void)
+static void test_block_size_must_be_positive(void *fixture)
 {
 	bad_create(0, 16);
 }
 
-static void test_block_size_must_be_multiple_of_page_size(void)
+static void test_block_size_must_be_multiple_of_page_size(void *fixture)
 {
 	static unsigned _bad_examples[] = {3, 9, 13, 1025};
 
@@ -278,312 +328,195 @@ static void test_block_size_must_be_multiple_of_page_size(void)
 		good_create(i * 8, 16);
 }
 
-static void test_get_triggers_read(void)
+static void test_get_triggers_read(void *context)
 {
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
+	struct fixture *f = context;
 
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, 16, &me->e);
-	T_ASSERT(cache);
+	int fd = 17;   // arbitrary key
+	struct block *b;
 
-	{
-		int fd = 17;   // arbitrary key
-		struct block *b;
-
-		_expect(me, E_ISSUE);
-		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
-		bcache_put(b);
-	}
-
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
+	_expect(f->me, E_ISSUE);
+	_expect(f->me, E_WAIT);
+	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
+	bcache_put(b);
 }
 
-static void test_repeated_reads_are_cached(void)
+static void test_repeated_reads_are_cached(void *context)
 {
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
+	struct fixture *f = context;
 
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, 16, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		unsigned i;
-		struct block *b;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
 
-		_expect(me, E_ISSUE);
-		_expect(me, E_WAIT);
-		for (i = 0; i < 100; i++) {
-			T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
-			bcache_put(b);
-		}
+	_expect(f->me, E_ISSUE);
+	_expect(f->me, E_WAIT);
+	for (i = 0; i < 100; i++) {
+		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
+		bcache_put(b);
 	}
-
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
 }
 
-static void test_block_gets_evicted_with_many_reads(void)
+static void test_block_gets_evicted_with_many_reads(void *context)
 {
-	const unsigned nr_cache_blocks = 16;
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
+	struct fixture *f = context;
 
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		unsigned i;
-		struct block *b;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	const unsigned nr_cache_blocks = 16;
 
-		for (i = 0; i < nr_cache_blocks; i++) {
-			_expect(me, E_ISSUE);
-			_expect(me, E_WAIT);
-			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
-			bcache_put(b);
-		}
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
 
-		// Not enough cache blocks to hold this one
+	for (i = 0; i < nr_cache_blocks; i++) {
 		_expect(me, E_ISSUE);
 		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		bcache_put(b);
-
-		// Now if we run through we should find one block has been
-		// evicted.  We go backwards because the oldest is normally
-		// evicted first.
-		_expect(me, E_ISSUE);
-		_expect(me, E_WAIT);
-		for (i = nr_cache_blocks; i; i--) {
-			T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b));
-			bcache_put(b);
-		}
 	}
 
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
-}
-
-static void test_prefetch_issues_a_read(void)
-{
-	const unsigned nr_cache_blocks = 16;
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
-
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		unsigned i;
-		struct block *b;
-
-		for (i = 0; i < nr_cache_blocks; i++) {
-			// prefetch should not wait
-			_expect(me, E_ISSUE);
-			bcache_prefetch(cache, fd, i);
-		}
-
-
-		for (i = 0; i < nr_cache_blocks; i++) {
-			_expect(me, E_WAIT);
-			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
-			bcache_put(b);
-		}
+	// Not enough cache blocks to hold this one
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
+	bcache_put(b);
+
+	// Now if we run through we should find one block has been
+	// evicted.  We go backwards because the oldest is normally
+	// evicted first.
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
+	for (i = nr_cache_blocks; i; i--) {
+		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b));
+		bcache_put(b);
 	}
-
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
 }
 
-static void test_too_many_prefetches_does_not_trigger_a_wait(void)
+static void test_prefetch_issues_a_read(void *context)
 {
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
 	const unsigned nr_cache_blocks = 16;
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
-
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		unsigned i;
 
-		for (i = 0; i < 10 * nr_cache_blocks; i++) {
-			// prefetch should not wait
-			if (i < nr_cache_blocks)
-				_expect(me, E_ISSUE);
-			bcache_prefetch(cache, fd, i);
-		}
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
 
-		// Destroy will wait for any in flight IO triggered by prefetches.
-		for (i = 0; i < nr_cache_blocks; i++)
-			_expect(me, E_WAIT);
+	for (i = 0; i < nr_cache_blocks; i++) {
+		// prefetch should not wait
+		_expect(me, E_ISSUE);
+		bcache_prefetch(cache, fd, i);
 	}
 
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
-}
 
-static void test_dirty_data_gets_written_back(void)
-{
-	const unsigned nr_cache_blocks = 16;
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
-
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		struct block *b;
-
-		// FIXME: be specific about the IO direction
-		// Expect the read
-		_expect(me, E_ISSUE);
+	for (i = 0; i < nr_cache_blocks; i++) {
 		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		bcache_put(b);
-
-		// Expect the write
-		_expect(me, E_ISSUE);
-		_expect(me, E_WAIT);
 	}
-
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
 }
 
-static void test_zeroed_data_counts_as_dirty(void)
+static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
 {
-	const unsigned nr_cache_blocks = 16;
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
-
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(64, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		struct block *b;
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
 
-		// No read
-		T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
-		bcache_put(b);
+	const unsigned nr_cache_blocks = 16;
+	int fd = 17;   // arbitrary key
+	unsigned i;
 
-		// Expect the write
-		_expect(me, E_ISSUE);
-		_expect(me, E_WAIT);
+	for (i = 0; i < 10 * nr_cache_blocks; i++) {
+		// prefetch should not wait
+		if (i < nr_cache_blocks)
+			_expect(me, E_ISSUE);
+		bcache_prefetch(cache, fd, i);
 	}
 
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
+	// Destroy will wait for any in flight IO triggered by prefetches.
+	for (i = 0; i < nr_cache_blocks; i++)
+		_expect(me, E_WAIT);
 }
 
-static void test_flush_waits_for_all_dirty(void)
+static void test_dirty_data_gets_written_back(void *context)
 {
-	const unsigned nr_cache_blocks = 128, count = 16;
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
 
-	// FIXME: use a fixture
-	_expect(me, E_MAX_IO);
-
-	// I'm using a large nr of cache blocks to avoid triggering writeback
-	// early.
-	cache = bcache_create(64, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	{
-		int fd = 17;   // arbitrary key
-		unsigned i;
-		struct block *b;
-
-		for (i = 0; i < count; i++) {
-			if (i % 2) {
-				T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
-			} else {
-				_expect_read(me);
-				_expect(me, E_WAIT);
-				T_ASSERT(bcache_get(cache, fd, i, 0, &b));
-			}
-			bcache_put(b);
-		}
+	const unsigned nr_cache_blocks = 16;
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	// FIXME: be specific about the IO direction
+	// Expect the read
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
+	bcache_put(b);
+
+	// Expect the write
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
+}
 
-		for (i = 0; i < count; i++) {
-			if (i % 2)
-				_expect_write(me);
-		}
+static void test_zeroed_data_counts_as_dirty(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
 
-		for (i = 0; i < count; i++) {
-			if (i % 2)
-				_expect(me, E_WAIT);
-		}
+	const unsigned nr_cache_blocks = 16;
+	int fd = 17;   // arbitrary key
+	struct block *b;
 
-		bcache_flush(cache);
-		_no_outstanding_expectations(me);
-	}
+	// No read
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+	bcache_put(b);
 
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
+	// Expect the write
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
 }
 
-#if 0
-#define NR_FILES 4
-static void test_read_multiple_files(void)
+static void test_flush_waits_for_all_dirty(void *context)
 {
-	unsigned i;
-	int fd[NR_FILES];
-	char buffer[128];
-
-
-	// FIXME: add fixtures.
-	test_init();
-	for (i = 0; i < NR_FILES; i++) {
-		snprintf(buffer, sizeof(buffer), "./test%u.bin", i);
-		unlink(buffer);
-		_prep_file(buffer);
-		fd[i] = open_file(buffer);
-		CU_ASSERT(fd[i] >= 0);
-	}
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
 
-	{
-		struct block *b;
-		struct bcache *cache = bcache_create(8, 16);
+	const unsigned count = 16;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
 
-		for (i = 0; i < 64; i++) {
-			if (!bcache_get(cache, fd[i % NR_FILES], i, 0, &b)) {
-				CU_ASSERT(false);
-			} else
-				bcache_put(b);
+	for (i = 0; i < count; i++) {
+		if (i % 2) {
+			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
+		} else {
+			_expect_read(me);
+			_expect(me, E_WAIT);
+			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		}
+		bcache_put(b);
+	}
 
-		bcache_destroy(cache);
+	for (i = 0; i < count; i++) {
+		if (i % 2)
+			_expect_write(me);
 	}
 
-	for (i = 0; i < NR_FILES; i++)
-		close(fd[i]);
+	for (i = 0; i < count; i++) {
+		if (i % 2)
+			_expect(me, E_WAIT);
+	}
 
-	test_exit();
+	bcache_flush(cache);
+	_no_outstanding_expectations(me);
 }
-#endif
+
 // Tests to be written
 // Open multiple files and prove the blocks are coming from the correct file
 // show invalidate works
@@ -593,37 +526,53 @@ static void test_read_multiple_files(void)
 
 struct test_details {
 	const char *name;
-	void (*fn)(void);
+	void (*fn)(void *);
+	void *(*fixture_init)(void);
+	void (*fixture_exit)(void *);
 };
 
+#define TEST(name, fn) {name, fn, NULL, NULL}
+#define TEST_S(name, fn) {name, fn, _small_fixture_init, _small_fixture_exit}
+#define TEST_L(name, fn) {name, fn, _large_fixture_init, _large_fixture_exit}
+
 int main(int argc, char **argv)
 {
 	static struct test_details _tests[] = {
-		{"simple create/destroy", test_create},
-		{"nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive},
-		{"block size must be positive", test_block_size_must_be_positive},
-		{"block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size},
-		{"bcache_get() triggers read", test_get_triggers_read},
-		{"repeated reads are cached", test_repeated_reads_are_cached},
-		{"block get evicted with many reads", test_block_gets_evicted_with_many_reads},
-		{"prefetch issues a read", test_prefetch_issues_a_read},
-		{"too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait},
-		{"dirty data gets written back", test_dirty_data_gets_written_back},
-		{"zeroed data counts as dirty", test_zeroed_data_counts_as_dirty},
-		{"flush waits for all dirty", test_flush_waits_for_all_dirty},
+		TEST("simple create/destroy", test_create),
+		TEST("nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive),
+		TEST("block size must be positive", test_block_size_must_be_positive),
+		TEST("block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size),
+		TEST_S("bcache_get() triggers read", test_get_triggers_read),
+		TEST_S("repeated reads are cached", test_repeated_reads_are_cached),
+		TEST_S("block get evicted with many reads", test_block_gets_evicted_with_many_reads),
+		TEST_S("prefetch issues a read", test_prefetch_issues_a_read),
+		TEST_S("too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait),
+		TEST_S("dirty data gets written back", test_dirty_data_gets_written_back),
+		TEST_S("zeroed data counts as dirty", test_zeroed_data_counts_as_dirty),
+		TEST_L("flush waits for all dirty", test_flush_waits_for_all_dirty),
 	};
 
 	// We have to declare these as volatile because of the setjmp()
 	volatile unsigned i = 0, passed = 0;
 
 	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
+		void *fixture;
 		struct test_details *t = _tests + i;
 		fprintf(stderr, "[RUN    ] %s\n", t->name);
 
 		if (setjmp(_test_k))
 			fprintf(stderr, "[   FAIL] %s\n", t->name);
 		else {
-			t->fn();
+			if (t->fixture_init)
+				fixture = t->fixture_init();
+			else
+				fixture = NULL;
+
+			t->fn(fixture);
+
+			if (t->fixture_exit)
+				t->fixture_exit(fixture);
+
 			passed++;
 			fprintf(stderr, "[     OK] %s\n", t->name);
 		}
@@ -631,10 +580,5 @@ int main(int argc, char **argv)
 
 	fprintf(stderr, "\n%u/%lu tests passed\n", passed, DM_ARRAY_SIZE(_tests));
 
-#if 0
-	test_prefetch_works();
-	test_read_multiple_files();
-#endif
-
 	return 0;
 }


