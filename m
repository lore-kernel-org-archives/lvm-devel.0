From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:32 -0400
Subject: master - [device/bcache] more work on bcache
Message-ID: <201804231347.w3NDlWLm031278@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc8034f5eb8d14b621c3d99ff58c95f74153c448
Commit:        dc8034f5eb8d14b621c3d99ff58c95f74153c448
Parent:        1cde30eba0fc4404f092fb5106f7cc7fcd66795b
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Feb 6 15:10:44 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] more work on bcache

---
 lib/device/bcache.c  |    2 +-
 test/unit/bcache_t.c |  152 +++++++++++++++++++++++++++++++++----------------
 2 files changed, 103 insertions(+), 51 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 1d83306..dce05ef 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -365,7 +365,7 @@ static struct block *_hash_lookup(struct bcache *cache, int fd, uint64_t index)
 	unsigned h = _hash(cache, fd, index);
 
 	dm_list_iterate_items_gen (b, cache->buckets + h, hash)
-		if (b->index == index)
+		if (b->fd == fd && b->index == index)
 			return b;
 
 	return NULL;
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 5fb6789..07a45fe 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -54,6 +54,7 @@ struct mock_engine {
 	struct dm_list expected_calls;
 	struct dm_list issued_io;
 	unsigned max_io;
+	sector_t block_size;
 };
 
 enum method {
@@ -66,6 +67,11 @@ enum method {
 struct mock_call {
 	struct dm_list list;
 	enum method m;
+
+	bool match_args;
+	enum dir d;
+	int fd;
+	block_address b;
 };
 
 struct mock_io {
@@ -97,23 +103,35 @@ static void _expect(struct mock_engine *e, enum method m)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = m;
+	mc->match_args = false;
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_read(struct mock_engine *e)
+static void _expect_read(struct mock_engine *e, int fd, block_address b)
 {
-	// FIXME: finish
-	_expect(e, E_ISSUE);
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_write(struct mock_engine *e)
+static void _expect_write(struct mock_engine *e, int fd, block_address b)
 {
-	// FIXME: finish
-	_expect(e, E_ISSUE);
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _match(struct mock_engine *e, enum method m)
+static struct mock_call *_match_pop(struct mock_engine *e, enum method m)
 {
+
 	struct mock_call *mc;
 
 	if (dm_list_empty(&e->expected_calls))
@@ -129,7 +147,12 @@ static void _match(struct mock_engine *e, enum method m)
 		fprintf(stderr, "%s called (expected)\n", _show_method(m));
 #endif
 
-	free(mc);
+	return mc;
+}
+
+static void _match(struct mock_engine *e, enum method m)
+{
+	free(_match_pop(e, m));
 }
 
 static void _no_outstanding_expectations(struct mock_engine *e)
@@ -163,9 +186,18 @@ static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
 	      		sector_t sb, sector_t se, void *data, void *context)
 {
 	struct mock_io *io;
+	struct mock_call *mc;
 	struct mock_engine *me = _to_mock(e);
 
-	_match(me, E_ISSUE);
+	mc = _match_pop(me, E_ISSUE);
+	if (mc->match_args) {
+		T_ASSERT(d == mc->d);
+		T_ASSERT(fd == mc->fd);
+		T_ASSERT(sb == mc->b * me->block_size);
+		T_ASSERT(se == (mc->b + 1) * me->block_size);
+	}
+	free(mc);
+
 	io = malloc(sizeof(*io));
 	if (!io)
 		abort();
@@ -202,7 +234,7 @@ static unsigned _mock_max_io(struct io_engine *e)
 	return me->max_io;
 }
 
-static struct mock_engine *_mock_create(unsigned max_io)
+static struct mock_engine *_mock_create(unsigned max_io, sector_t block_size)
 {
 	struct mock_engine *m = malloc(sizeof(*m));
 
@@ -212,6 +244,7 @@ static struct mock_engine *_mock_create(unsigned max_io)
 	m->e.max_io = _mock_max_io;
 
 	m->max_io = max_io;
+	m->block_size = block_size;
 	dm_list_init(&m->expected_calls);
 	dm_list_init(&m->issued_io);
 
@@ -226,15 +259,15 @@ struct fixture {
 	struct bcache *cache;
 };
 
-static struct fixture *_fixture_init(unsigned nr_cache_blocks)
+static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_blocks)
 {
 	struct fixture *f = malloc(sizeof(*f));
 
-	f->me = _mock_create(16);
+	f->me = _mock_create(16, block_size);
 	T_ASSERT(f->me);
 
 	_expect(f->me, E_MAX_IO);
-	f->cache = bcache_create(128, nr_cache_blocks, &f->me->e);
+	f->cache = bcache_create(block_size, nr_cache_blocks, &f->me->e);
 	T_ASSERT(f->cache);
 
 	return f;
@@ -250,7 +283,7 @@ static void _fixture_exit(struct fixture *f)
 
 static void *_small_fixture_init(void)
 {
-	return _fixture_init(16);
+	return _fixture_init(128, 16);
 }
 
 static void _small_fixture_exit(void *context)
@@ -260,7 +293,7 @@ static void _small_fixture_exit(void *context)
 
 static void *_large_fixture_init(void)
 {
-	return _fixture_init(1024);
+	return _fixture_init(128, 1024);
 }
 
 static void _large_fixture_exit(void *context)
@@ -277,7 +310,7 @@ static void _large_fixture_exit(void *context)
 static void good_create(sector_t block_size, unsigned nr_cache_blocks)
 {
 	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
+	struct mock_engine *me = _mock_create(16, 128);
 
 	_expect(me, E_MAX_IO);
 	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
@@ -290,7 +323,7 @@ static void good_create(sector_t block_size, unsigned nr_cache_blocks)
 static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
 {
 	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16);
+	struct mock_engine *me = _mock_create(16, 128);
 
 	_expect(me, E_MAX_IO);
 	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
@@ -335,7 +368,7 @@ static void test_get_triggers_read(void *context)
 	int fd = 17;   // arbitrary key
 	struct block *b;
 
-	_expect(f->me, E_ISSUE);
+	_expect_read(f->me, fd, 0);
 	_expect(f->me, E_WAIT);
 	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
 	bcache_put(b);
@@ -349,7 +382,7 @@ static void test_repeated_reads_are_cached(void *context)
 	unsigned i;
 	struct block *b;
 
-	_expect(f->me, E_ISSUE);
+	_expect_read(f->me, fd, 0);
 	_expect(f->me, E_WAIT);
 	for (i = 0; i < 100; i++) {
 		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
@@ -370,14 +403,14 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 	struct block *b;
 
 	for (i = 0; i < nr_cache_blocks; i++) {
-		_expect(me, E_ISSUE);
+		_expect_read(me, fd, i);
 		_expect(me, E_WAIT);
 		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		bcache_put(b);
 	}
 
 	// Not enough cache blocks to hold this one
-	_expect(me, E_ISSUE);
+	_expect_read(me, fd, nr_cache_blocks);
 	_expect(me, E_WAIT);
 	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
 	bcache_put(b);
@@ -406,7 +439,7 @@ static void test_prefetch_issues_a_read(void *context)
 
 	for (i = 0; i < nr_cache_blocks; i++) {
 		// prefetch should not wait
-		_expect(me, E_ISSUE);
+		_expect_read(me, fd, i);
 		bcache_prefetch(cache, fd, i);
 	}
 
@@ -431,7 +464,7 @@ static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
 	for (i = 0; i < 10 * nr_cache_blocks; i++) {
 		// prefetch should not wait
 		if (i < nr_cache_blocks)
-			_expect(me, E_ISSUE);
+			_expect_read(me, fd, i);
 		bcache_prefetch(cache, fd, i);
 	}
 
@@ -446,19 +479,17 @@ static void test_dirty_data_gets_written_back(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 
-	const unsigned nr_cache_blocks = 16;
 	int fd = 17;   // arbitrary key
 	struct block *b;
 
-	// FIXME: be specific about the IO direction
 	// Expect the read
-	_expect(me, E_ISSUE);
+	_expect_read(me, fd, 0);
 	_expect(me, E_WAIT);
 	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
 	bcache_put(b);
 
 	// Expect the write
-	_expect(me, E_ISSUE);
+	_expect_write(me, fd, 0);
 	_expect(me, E_WAIT);
 }
 
@@ -468,7 +499,6 @@ static void test_zeroed_data_counts_as_dirty(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 
-	const unsigned nr_cache_blocks = 16;
 	int fd = 17;   // arbitrary key
 	struct block *b;
 
@@ -477,7 +507,7 @@ static void test_zeroed_data_counts_as_dirty(void *context)
 	bcache_put(b);
 
 	// Expect the write
-	_expect(me, E_ISSUE);
+	_expect_write(me, fd, 0);
 	_expect(me, E_WAIT);
 }
 
@@ -496,7 +526,7 @@ static void test_flush_waits_for_all_dirty(void *context)
 		if (i % 2) {
 			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
 		} else {
-			_expect_read(me);
+			_expect_read(me, fd, i);
 			_expect(me, E_WAIT);
 			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		}
@@ -505,7 +535,7 @@ static void test_flush_waits_for_all_dirty(void *context)
 
 	for (i = 0; i < count; i++) {
 		if (i % 2)
-			_expect_write(me);
+			_expect_write(me, fd, i);
 	}
 
 	for (i = 0; i < count; i++) {
@@ -517,6 +547,25 @@ static void test_flush_waits_for_all_dirty(void *context)
 	_no_outstanding_expectations(me);
 }
 
+static void test_multiple_files(void * context)
+{
+	static int _fds[] = {1, 128, 345, 678, 890};
+
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_fds); i++) {
+		_expect_read(me, _fds[i], 0);
+		_expect(me, E_WAIT);
+
+		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b));
+		bcache_put(b);
+	}
+}
+
 // Tests to be written
 // Open multiple files and prove the blocks are coming from the correct file
 // show invalidate works
@@ -525,31 +574,34 @@ static void test_flush_waits_for_all_dirty(void *context)
 // check zeroing
 
 struct test_details {
-	const char *name;
+	const char *path;
+	const char *desc;
 	void (*fn)(void *);
 	void *(*fixture_init)(void);
 	void (*fixture_exit)(void *);
 };
 
-#define TEST(name, fn) {name, fn, NULL, NULL}
-#define TEST_S(name, fn) {name, fn, _small_fixture_init, _small_fixture_exit}
-#define TEST_L(name, fn) {name, fn, _large_fixture_init, _large_fixture_exit}
+#define PATH "device/bcache/"
+#define TEST(path, name, fn) {PATH path, name, fn, NULL, NULL}
+#define TEST_S(path, name, fn) {PATH path, name, fn, _small_fixture_init, _small_fixture_exit}
+#define TEST_L(path, name, fn) {PATH path, name, fn, _large_fixture_init, _large_fixture_exit}
 
 int main(int argc, char **argv)
 {
 	static struct test_details _tests[] = {
-		TEST("simple create/destroy", test_create),
-		TEST("nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive),
-		TEST("block size must be positive", test_block_size_must_be_positive),
-		TEST("block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size),
-		TEST_S("bcache_get() triggers read", test_get_triggers_read),
-		TEST_S("repeated reads are cached", test_repeated_reads_are_cached),
-		TEST_S("block get evicted with many reads", test_block_gets_evicted_with_many_reads),
-		TEST_S("prefetch issues a read", test_prefetch_issues_a_read),
-		TEST_S("too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait),
-		TEST_S("dirty data gets written back", test_dirty_data_gets_written_back),
-		TEST_S("zeroed data counts as dirty", test_zeroed_data_counts_as_dirty),
-		TEST_L("flush waits for all dirty", test_flush_waits_for_all_dirty),
+		TEST("create-destroy", "simple create/destroy", test_create),
+		TEST("cache-blocks-positive", "nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive),
+		TEST("block-size-positive", "block size must be positive", test_block_size_must_be_positive),
+		TEST("block-size-multiple-page", "block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size),
+		TEST_S("get-reads", "bcache_get() triggers read", test_get_triggers_read),
+		TEST_S("reads-cached", "repeated reads are cached", test_repeated_reads_are_cached),
+		TEST_S("blocks-get-evicted", "block get evicted with many reads", test_block_gets_evicted_with_many_reads),
+		TEST_S("prefetch-reads", "prefetch issues a read", test_prefetch_issues_a_read),
+		TEST_S("prefetch-never-waits", "too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait),
+		TEST_S("writeback-occurs", "dirty data gets written back", test_dirty_data_gets_written_back),
+		TEST_S("zero-flag-dirties", "zeroed data counts as dirty", test_zeroed_data_counts_as_dirty),
+		TEST_L("flush waits for all dirty", "flush waits for all dirty", test_flush_waits_for_all_dirty),
+		TEST_S("read-multiple-files", "read from multiple files", test_multiple_files),
 	};
 
 	// We have to declare these as volatile because of the setjmp()
@@ -558,10 +610,10 @@ int main(int argc, char **argv)
 	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
 		void *fixture;
 		struct test_details *t = _tests + i;
-		fprintf(stderr, "[RUN    ] %s\n", t->name);
+		fprintf(stderr, "[RUN    ] %s\n", t->path);
 
 		if (setjmp(_test_k))
-			fprintf(stderr, "[   FAIL] %s\n", t->name);
+			fprintf(stderr, "[   FAIL] %s\n", t->path);
 		else {
 			if (t->fixture_init)
 				fixture = t->fixture_init();
@@ -574,7 +626,7 @@ int main(int argc, char **argv)
 				t->fixture_exit(fixture);
 
 			passed++;
-			fprintf(stderr, "[     OK] %s\n", t->name);
+			fprintf(stderr, "[     OK] %s\n", t->path);
 		}
 	}
 


