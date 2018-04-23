From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:23 -0400
Subject: master - [device/bcache] More tests and some bug fixes
Message-ID: <201804231347.w3NDlNIv031240@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=467adfa082c3be10d012fa156db7810d23221648
Commit:        467adfa082c3be10d012fa156db7810d23221648
Parent:        8ae3b244fcbc207b51a81514e51008fe64d13368
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Feb 5 16:04:23 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] More tests and some bug fixes

---
 lib/device/bcache.c   |  127 ++++++-----
 lib/device/bcache.h   |   32 +++-
 test/unit/Makefile.in |   26 ++-
 test/unit/bcache_t.c  |  589 +++++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 616 insertions(+), 158 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index e5d0e1b..86b56c0 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -130,44 +130,21 @@ static struct control_block *_iocb_to_cb(struct iocb *icb)
 //----------------------------------------------------------------
 
 // FIXME: write a sync engine too
-enum dir {
-	DIR_READ,
-	DIR_WRITE
-};
-
-struct io_engine {
+struct async_engine {
+	struct io_engine e;
 	io_context_t aio_context;
 	struct cb_set *cbs;
 };
 
-static struct io_engine *_engine_create(unsigned max_io)
+static struct async_engine *_to_async(struct io_engine *e)
 {
-	int r;
-	struct io_engine *e = dm_malloc(sizeof(*e));
-
-	if (!e)
-		return NULL;
-
-	e->aio_context = 0;
-	r = io_setup(max_io, &e->aio_context);
-	if (r < 0) {
-		log_warn("io_setup failed");
-		return NULL;
-	}
-
-	e->cbs = _cb_set_create(max_io);
-	if (!e->cbs) {
-		log_warn("couldn't create control block set");
-		dm_free(e);
-		return NULL;
-	}
-
-	return e;
+	return container_of(e, struct async_engine, e);
 }
 
-static void _engine_destroy(struct io_engine *e)
+static void _async_destroy(struct io_engine *ioe)
 {
 	int r;
+	struct async_engine *e = _to_async(ioe);
 
 	_cb_set_destroy(e->cbs);
 
@@ -179,12 +156,13 @@ static void _engine_destroy(struct io_engine *e)
 	dm_free(e);
 }
 
-static bool _engine_issue(struct io_engine *e, enum dir d, int fd,
-			  sector_t sb, sector_t se, void *data, void *context)
+static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
+			 sector_t sb, sector_t se, void *data, void *context)
 {
 	int r;
 	struct iocb *cb_array[1];
 	struct control_block *cb;
+	struct async_engine *e = _to_async(ioe);
 
 	if (((uint64_t) data) & (PAGE_SIZE - 1)) {
 		log_warn("misaligned data buffer");
@@ -218,13 +196,13 @@ static bool _engine_issue(struct io_engine *e, enum dir d, int fd,
 
 #define MAX_IO 1024
 #define MAX_EVENT 64
-typedef void complete_fn(void *context, int io_error);
 
-static bool _engine_wait(struct io_engine *e, complete_fn fn)
+static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 {
 	int i, r;
 	struct io_event event[MAX_EVENT];
 	struct control_block *cb;
+	struct async_engine *e = _to_async(ioe);
 
 	memset(&event, 0, sizeof(event));
 	r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
@@ -255,6 +233,36 @@ static bool _engine_wait(struct io_engine *e, complete_fn fn)
 	return true;
 }
 
+struct io_engine *create_async_io_engine(unsigned max_io)
+{
+	int r;
+	struct async_engine *e = dm_malloc(sizeof(*e));
+
+	if (!e)
+		return NULL;
+
+	e->e.destroy = _async_destroy;
+	e->e.issue = _async_issue;
+	e->e.wait = _async_wait;
+
+	e->aio_context = 0;
+	r = io_setup(max_io, &e->aio_context);
+	if (r < 0) {
+		log_warn("io_setup failed");
+		dm_free(e);
+		return NULL;
+	}
+
+	e->cbs = _cb_set_create(max_io);
+	if (!e->cbs) {
+		log_warn("couldn't create control block set");
+		dm_free(e);
+		return NULL;
+	}
+
+	return &e->e;
+}
+
 //----------------------------------------------------------------
 
 #define MIN_BLOCKS 16
@@ -536,7 +544,9 @@ static bool _issue_low_level(struct block *b, enum dir d)
 		return false;
 
 	_set_flags(b, BF_IO_PENDING);
-	if (!_engine_issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
+	dm_list_add(&cache->io_pending, &b->list);
+
+	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
 		_complete_io(b, -EIO);
 		return false;
 	}
@@ -557,7 +567,7 @@ static inline bool _issue_write(struct block *b)
 
 static bool _wait_io(struct bcache *cache)
 {
-	return _engine_wait(cache->engine, _complete_io);
+	return cache->engine->wait(cache->engine, _complete_io);
 }
 
 /*----------------------------------------------------------------
@@ -614,17 +624,20 @@ static struct block *_find_unused_clean_block(struct bcache *cache)
 	return NULL;
 }
 
-static struct block *_new_block(struct bcache *cache, int fd, block_address index)
+static struct block *_new_block(struct bcache *cache, int fd, block_address index, bool can_wait)
 {
 	struct block *b;
 
 	b = _alloc_block(cache);
-	while (!b && cache->nr_locked < cache->nr_cache_blocks) {
+	while (!b && !dm_list_empty(&cache->clean)) {
 		b = _find_unused_clean_block(cache);
 		if (!b) {
-			if (dm_list_empty(&cache->io_pending))
-				_writeback(cache, 16);
-			_wait_io(cache);
+			if (can_wait) {
+				if (dm_list_empty(&cache->io_pending))
+					_writeback(cache, 16);  // FIXME: magic number
+				_wait_io(cache);
+			} else
+				return NULL;
 		}
 	}
 
@@ -702,7 +715,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 	} else {
 		_miss(cache, flags);
 
-		b = _new_block(cache, fd, index);
+		b = _new_block(cache, fd, index, true);
 		if (b) {
 			if (flags & GF_ZERO)
 				_zero_block(b);
@@ -741,9 +754,11 @@ static void _preemptive_writeback(struct bcache *cache)
 /*----------------------------------------------------------------
  * Public interface
  *--------------------------------------------------------------*/
-struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks)
+struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
+			     struct io_engine *engine)
 {
 	struct bcache *cache;
+	unsigned max_io = engine->max_io(engine);
 
 	if (!nr_cache_blocks) {
 		log_warn("bcache must have at least one cache block");
@@ -766,13 +781,8 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks)
 
 	cache->block_sectors = block_sectors;
 	cache->nr_cache_blocks = nr_cache_blocks;
-	cache->max_io = nr_cache_blocks < MAX_IO ? nr_cache_blocks : MAX_IO;
-	cache->engine = _engine_create(cache->max_io);
-	if (!cache->engine) {
-		dm_free(cache);
-		return NULL;
-	}
-
+	cache->max_io = nr_cache_blocks < max_io ? nr_cache_blocks : max_io;
+	cache->engine = engine;
 	cache->nr_locked = 0;
 	cache->nr_dirty = 0;
 	cache->nr_io_pending = 0;
@@ -784,7 +794,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks)
 	dm_list_init(&cache->io_pending);
 
 	if (!_hash_table_init(cache, nr_cache_blocks)) {
-		_engine_destroy(cache->engine);
+		cache->engine->destroy(cache->engine);
 		dm_free(cache);
 		return NULL;
 	}
@@ -797,7 +807,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks)
 	cache->prefetches = 0;
 
 	if (!_init_free_list(cache, nr_cache_blocks)) {
-		_engine_destroy(cache->engine);
+		cache->engine->destroy(cache->engine);
 		_hash_table_exit(cache);
 		dm_free(cache);
 		return NULL;
@@ -815,7 +825,7 @@ void bcache_destroy(struct bcache *cache)
 	_wait_all(cache);
 	_exit_free_list(cache);
 	_hash_table_exit(cache);
-	_engine_destroy(cache->engine);
+	cache->engine->destroy(cache->engine);
 	dm_free(cache);
 }
 
@@ -834,10 +844,12 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 	struct block *b = _hash_lookup(cache, fd, index);
 
 	if (!b) {
-		b = _new_block(cache, fd, index);
-		if (b && (cache->nr_io_pending < cache->max_io)) {
-			cache->prefetches++;
-			_issue_read(b);
+		if (cache->nr_io_pending < cache->max_io) {
+			b = _new_block(cache, fd, index, false);
+			if (b) {
+				cache->prefetches++;
+				_issue_read(b);
+			}
 		}
 	}
 }
@@ -881,9 +893,10 @@ int bcache_flush(struct bcache *cache)
 {
 	while (!dm_list_empty(&cache->dirty)) {
 		struct block *b = dm_list_item(_list_pop(&cache->dirty), struct block);
-		if (b->ref_count || _test_flags(b, BF_IO_PENDING))
+		if (b->ref_count || _test_flags(b, BF_IO_PENDING)) {
 			// The superblock may well be still locked.
 			continue;
+		}
 
 		_issue_write(b);
 	}
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 14204be..818dee2 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -15,6 +15,7 @@
 #ifndef BCACHE_H
 #define BCACHE_H
 
+#include <linux/fs.h>
 #include <stdint.h>
 #include <stdbool.h>
 
@@ -22,9 +23,34 @@
 
 /*----------------------------------------------------------------*/
 
+// FIXME: move somewhere more sensible
+#define container_of(v, t, head) \
+    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+
+/*----------------------------------------------------------------*/
+
+enum dir {
+	DIR_READ,
+	DIR_WRITE
+};
+
 typedef uint64_t block_address;
 typedef uint64_t sector_t;
 
+typedef void io_complete_fn(void *context, int io_error);
+
+struct io_engine {
+	void (*destroy)(struct io_engine *e);
+	bool (*issue)(struct io_engine *e, enum dir d, int fd,
+		      sector_t sb, sector_t se, void *data, void *context);
+	bool (*wait)(struct io_engine *e, io_complete_fn fn);
+	unsigned (*max_io)(struct io_engine *e);
+};
+
+struct io_engine *create_async_io_engine(unsigned max_io);
+
+/*----------------------------------------------------------------*/
+
 struct bcache;
 struct block {
 	/* clients may only access these three fields */
@@ -41,7 +67,11 @@ struct block {
 	int error;
 };
 
-struct bcache *bcache_create(sector_t block_size, unsigned nr_cache_blocks);
+/*
+ * Ownership of engine passes.  Engine will be destroyed even if this fails.
+ */
+struct bcache *bcache_create(sector_t block_size, unsigned nr_cache_blocks,
+			     struct io_engine *engine);
 void bcache_destroy(struct bcache *cache);
 
 enum bcache_get_flags {
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 2e2c819..a070329 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -12,22 +12,28 @@
 
 UNIT_SOURCE=\
 	test/unit/bcache_t.c \
-	test/unit/bitset_t.c\
-	test/unit/config_t.c\
-	test/unit/dmlist_t.c\
-	test/unit/dmstatus_t.c\
-	test/unit/matcher_t.c\
-	test/unit/percent_t.c\
-	test/unit/string_t.c\
-	test/unit/run.c
+
+
+#	test/unit/run.c
+
+#	test/unit/bitset_t.c\
+#	test/unit/config_t.c\
+#	test/unit/dmlist_t.c\
+#	test/unit/dmstatus_t.c\
+#	test/unit/matcher_t.c\
+#	test/unit/percent_t.c\
+#	test/unit/string_t.c\
+
 UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
 
-UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio -lcunit
+UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
 
 test/unit/run: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
+	@echo "    [LD] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
 	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
 
+.PHONEY: unit-test
 unit-test: test/unit/run
 	@echo Running unit tests
 	LD_LIBRARY_PATH=libdm test/unit/run
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 3db9cc7..c2d2df0 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -12,168 +12,540 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#define _GNU_SOURCE
-
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
 #include <unistd.h>
+#include <setjmp.h>
 
-#include "units.h"
 #include "bcache.h"
 
-#define MEG 2048
-#define SECTOR_SHIFT 9
+#define SHOW_MOCK_CALLS 0
+
+/*----------------------------------------------------------------
+ * Assertions
+ *--------------------------------------------------------------*/
+
+static jmp_buf _test_k;
+#define TEST_FAILED 1
+
+static void _fail(const char *fmt, ...)
+	__attribute__((format (printf, 1, 2)));
 
-static const char *_test_path = "test.bin";
 
-int bcache_init(void)
+static void _fail(const char *fmt, ...)
 {
-	return 0;
+	va_list ap;
+
+	va_start(ap, fmt);
+	vfprintf(stderr, fmt, ap);
+	va_end(ap);
+	fprintf(stderr, "\n");
+
+	longjmp(_test_k, TEST_FAILED);
 }
 
-int bcache_fini(void)
+#define T_ASSERT(e) if (!(e)) {_fail("assertion failed: '%s'", # e);}
+
+/*----------------------------------------------------------------
+ * Mock engine
+ *--------------------------------------------------------------*/
+struct mock_engine {
+	struct io_engine e;
+	struct dm_list expected_calls;
+	struct dm_list issued_io;
+	unsigned max_io;
+};
+
+enum method {
+	E_DESTROY,
+	E_ISSUE,
+	E_WAIT,
+	E_MAX_IO
+};
+
+struct mock_call {
+	struct dm_list list;
+	enum method m;
+};
+
+struct mock_io {
+	struct dm_list list;
+	int fd;
+	sector_t sb;
+	sector_t se;
+	void *data;
+	void *context;
+};
+
+static const char *_show_method(enum method m)
 {
-	return 0;
+	switch (m) {
+	case E_DESTROY:
+		return "destroy()";
+	case E_ISSUE:
+		return "issue()";
+	case E_WAIT:
+		return "wait()";
+	case E_MAX_IO:
+		return "max_io()";
+	}
+
+	return "<unknown>";
+}
+
+static void _expect(struct mock_engine *e, enum method m)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = m;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read(struct mock_engine *e)
+{
+	// FIXME: finish
+	_expect(e, E_ISSUE);
 }
 
-static int open_file(const char *path)
+static void _expect_write(struct mock_engine *e)
 {
-	return open(path, O_EXCL | O_RDWR | O_DIRECT, 0666);
+	// FIXME: finish
+	_expect(e, E_ISSUE);
 }
 
-static int _prep_file(const char *path)
+static void _match(struct mock_engine *e, enum method m)
 {
-	int fd, r;
+	struct mock_call *mc;
+
+	if (dm_list_empty(&e->expected_calls))
+		_fail("unexpected call to method %s\n", _show_method(m));
 
-	fd = open(path, O_CREAT | O_TRUNC | O_EXCL | O_RDWR | O_DIRECT, 0666);
-	if (fd < 0)
-		return -1;
+	mc = dm_list_item(e->expected_calls.n, struct mock_call);
+	dm_list_del(&mc->list);
 
-	r = fallocate(fd, FALLOC_FL_ZERO_RANGE, 0, (1 * MEG) << SECTOR_SHIFT);
-	if (r) {
-		close(fd);
-		return -1;
+	if (mc->m != m)
+		_fail("expected %s, but got %s\n", _show_method(mc->m), _show_method(m));
+#if SHOW_MOCK_CALLS
+	else
+		fprintf(stderr, "%s called (expected)\n", _show_method(m));
+#endif
+
+	free(mc);
+}
+
+static void _no_outstanding_expectations(struct mock_engine *e)
+{
+	struct mock_call *mc;
+
+	if (!dm_list_empty(&e->expected_calls)) {
+		fprintf(stderr, "unsatisfied expectations:\n");
+		dm_list_iterate_items (mc, &e->expected_calls)
+			fprintf(stderr, "  %s\n", _show_method(mc->m));
 	}
+	T_ASSERT(dm_list_empty(&e->expected_calls));
+}
 
-	close(fd);
-	return 0;
+static struct mock_engine *_to_mock(struct io_engine *e)
+{
+	return container_of(e, struct mock_engine, e);
 }
 
+static void _mock_destroy(struct io_engine *e)
+{
+	struct mock_engine *me = _to_mock(e);
+
+	_match(me, E_DESTROY);
+	T_ASSERT(dm_list_empty(&me->issued_io));
+	T_ASSERT(dm_list_empty(&me->expected_calls));
+	free(_to_mock(e));
+}
 
-static int test_init(void)
+static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
+	      		sector_t sb, sector_t se, void *data, void *context)
 {
-	unlink(_test_path);
-	return _prep_file(_test_path);
+	struct mock_io *io;
+	struct mock_engine *me = _to_mock(e);
+
+	_match(me, E_ISSUE);
+	io = malloc(sizeof(*io));
+	if (!io)
+		abort();
+
+	io->fd = fd;
+	io->sb = sb;
+	io->se = se;
+	io->data = data;
+	io->context = context;
+
+	dm_list_add(&me->issued_io, &io->list);
+	return true;
 }
 
-static int test_exit(void)
+static bool _mock_wait(struct io_engine *e, io_complete_fn fn)
 {
-	unlink(_test_path);
-	return 0;
+	struct mock_io *io;
+	struct mock_engine *me = _to_mock(e);
+	_match(me, E_WAIT);
+
+	// FIXME: provide a way to control how many are completed and whether
+	// they error.
+	T_ASSERT(!dm_list_empty(&me->issued_io));
+	io = dm_list_item(me->issued_io.n, struct mock_io);
+	dm_list_del(&io->list);
+	fn(io->context, 0);
+	return true;
 }
 
-static void test_create(void)
+static unsigned _mock_max_io(struct io_engine *e)
+{
+	struct mock_engine *me = _to_mock(e);
+	_match(me, E_MAX_IO);
+	return me->max_io;
+}
+
+static struct mock_engine *_mock_create(unsigned max_io)
+{
+	struct mock_engine *m = malloc(sizeof(*m));
+
+	m->e.destroy = _mock_destroy;
+	m->e.issue = _mock_issue;
+	m->e.wait = _mock_wait;
+	m->e.max_io = _mock_max_io;
+
+	m->max_io = max_io;
+	dm_list_init(&m->expected_calls);
+	dm_list_init(&m->issued_io);
+
+	return m;
+}
+
+/*----------------------------------------------------------------
+ * Tests
+ *--------------------------------------------------------------*/
+#define MEG 2048
+#define SECTOR_SHIFT 9
+
+static void good_create(sector_t block_size, unsigned nr_cache_blocks)
 {
-	struct bcache *cache = bcache_create(8, 16);
-	CU_ASSERT_PTR_NOT_NULL(cache);
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	_expect(me, E_DESTROY);
 	bcache_destroy(cache);
 }
 
+static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
+	T_ASSERT(!cache);
+
+	_expect(me, E_DESTROY);
+	me->e.destroy(&me->e);
+}
+
+static void test_create(void)
+{
+	good_create(8, 16);
+}
+
 static void test_nr_cache_blocks_must_be_positive(void)
 {
-	struct bcache *cache = bcache_create(8, 0);
-	CU_ASSERT_PTR_NULL(cache);
+	bad_create(8, 0);
 }
 
 static void test_block_size_must_be_positive(void)
 {
-	struct bcache *cache = bcache_create(0, 16);
-	CU_ASSERT_PTR_NULL(cache);
+	bad_create(0, 16);
 }
 
 static void test_block_size_must_be_multiple_of_page_size(void)
 {
+	static unsigned _bad_examples[] = {3, 9, 13, 1025};
+
 	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++)
+		bad_create(_bad_examples[i], 16);
+
+	for (i = 1; i < 1000; i++)
+		good_create(i * 8, 16);
+}
+
+static void test_get_triggers_read(void)
+{
 	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, 16, &me->e);
+	T_ASSERT(cache);
 
 	{
-		static unsigned _bad_examples[] = {3, 9, 13, 1025};
+		int fd = 17;   // arbitrary key
+		struct block *b;
 
-		for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++) {
-			cache = bcache_create(_bad_examples[i], 16);
-			CU_ASSERT_PTR_NULL(cache);
-		}
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+		bcache_put(b);
 	}
 
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
+
+static void test_repeated_reads_are_cached(void)
+{
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, 16, &me->e);
+	T_ASSERT(cache);
+
 	{
-		// Only testing a few sizes because io_destroy is seriously
-		// slow.
-		for (i = 1; i < 25; i++) {
-			cache = bcache_create(8 * i, 16);
-			CU_ASSERT_PTR_NOT_NULL(cache);
-			bcache_destroy(cache);
+		int fd = 17;   // arbitrary key
+		unsigned i;
+		struct block *b;
+
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+		for (i = 0; i < 100; i++) {
+			T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+			bcache_put(b);
 		}
 	}
+
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
 }
 
-static void test_reads_work(void)
+static void test_block_gets_evicted_with_many_reads(void)
 {
-	int fd;
+	const unsigned nr_cache_blocks = 16;
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
 
-	// FIXME: add fixtures.
-	test_init();
-	fd = open_file("./test.bin");
-	CU_ASSERT(fd >= 0);
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
 
 	{
-		int i;
+		int fd = 17;   // arbitrary key
+		unsigned i;
 		struct block *b;
-		struct bcache *cache = bcache_create(8, 16);
 
-		CU_ASSERT(bcache_get(cache, fd, 0, 0, &b));
-		for (i = 0; i < 8 << SECTOR_SHIFT; i++)
-			CU_ASSERT(((unsigned char *) b->data)[i] == 0);
+		for (i = 0; i < nr_cache_blocks; i++) {
+			_expect(me, E_ISSUE);
+			_expect(me, E_WAIT);
+			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
+			bcache_put(b);
+		}
+
+		// Not enough cache blocks to hold this one
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
 		bcache_put(b);
 
-		bcache_destroy(cache);
+		// Now if we run through we should find one block has been
+		// evicted.  We go backwards because the oldest is normally
+		// evicted first.
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+		for (i = nr_cache_blocks; i; i--) {
+			T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b));
+			bcache_put(b);
+		}
 	}
 
-	close(fd);
-
-	test_exit();
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
 }
 
-static void test_prefetch_works(void)
+static void test_prefetch_issues_a_read(void)
 {
-	int fd;
+	const unsigned nr_cache_blocks = 16;
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
 
-	// FIXME: add fixtures.
-	test_init();
-	fd = open_file("./test.bin");
-	CU_ASSERT(fd >= 0);
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
 
 	{
-		int i;
+		int fd = 17;   // arbitrary key
+		unsigned i;
 		struct block *b;
-		struct bcache *cache = bcache_create(8, 16);
 
-		for (i = 0; i < 16; i++)
+		for (i = 0; i < nr_cache_blocks; i++) {
+			// prefetch should not wait
+			_expect(me, E_ISSUE);
 			bcache_prefetch(cache, fd, i);
+		}
+
 
-		for (i = 0; i < 16; i++) {
-			CU_ASSERT(bcache_get(cache, fd, i, 0, &b));
+		for (i = 0; i < nr_cache_blocks; i++) {
+			_expect(me, E_WAIT);
+			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 			bcache_put(b);
 		}
+	}
 
-		bcache_destroy(cache);
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
+
+static void test_too_many_prefetches_does_not_trigger_a_wait(void)
+{
+	const unsigned nr_cache_blocks = 16;
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	{
+		int fd = 17;   // arbitrary key
+		unsigned i;
+
+		for (i = 0; i < 10 * nr_cache_blocks; i++) {
+			// prefetch should not wait
+			if (i < nr_cache_blocks)
+				_expect(me, E_ISSUE);
+			bcache_prefetch(cache, fd, i);
+		}
+
+		// Destroy will wait for any in flight IO triggered by prefetches.
+		for (i = 0; i < nr_cache_blocks; i++)
+			_expect(me, E_WAIT);
 	}
 
-	close(fd);
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
 
-	test_exit();
+static void test_dirty_data_gets_written_back(void)
+{
+	const unsigned nr_cache_blocks = 16;
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	{
+		int fd = 17;   // arbitrary key
+		struct block *b;
+
+		// FIXME: be specific about the IO direction
+		// Expect the read
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
+		bcache_put(b);
+
+		// Expect the write
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+	}
+
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
+
+static void test_zeroed_data_counts_as_dirty(void)
+{
+	const unsigned nr_cache_blocks = 16;
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(64, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	{
+		int fd = 17;   // arbitrary key
+		struct block *b;
+
+		// No read
+		T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+		bcache_put(b);
+
+		// Expect the write
+		_expect(me, E_ISSUE);
+		_expect(me, E_WAIT);
+	}
+
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
+
+static void test_flush_waits_for_all_dirty(void)
+{
+	const unsigned nr_cache_blocks = 128, count = 16;
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16);
+
+	// FIXME: use a fixture
+	_expect(me, E_MAX_IO);
+
+	// I'm using a large nr of cache blocks to avoid triggering writeback
+	// early.
+	cache = bcache_create(64, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	{
+		int fd = 17;   // arbitrary key
+		unsigned i;
+		struct block *b;
+
+		for (i = 0; i < count; i++) {
+			if (i % 2) {
+				T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
+			} else {
+				_expect_read(me);
+				_expect(me, E_WAIT);
+				T_ASSERT(bcache_get(cache, fd, i, 0, &b));
+			}
+			bcache_put(b);
+		}
+
+		for (i = 0; i < count; i++) {
+			if (i % 2)
+				_expect_write(me);
+		}
+
+		for (i = 0; i < count; i++) {
+			if (i % 2)
+				_expect(me, E_WAIT);
+		}
+
+		bcache_flush(cache);
+		_no_outstanding_expectations(me);
+	}
+
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
 }
 
+#if 0
 #define NR_FILES 4
 static void test_read_multiple_files(void)
 {
@@ -211,21 +583,58 @@ static void test_read_multiple_files(void)
 
 	test_exit();
 }
-
+#endif
 // Tests to be written
 // Open multiple files and prove the blocks are coming from the correct file
 // show invalidate works
 // show invalidate_fd works
 // show writeback is working
 // check zeroing
-//
-CU_TestInfo bcache_list[] = {
-	{ (char*)"create", test_create },
-	{ (char*)"nr cache block must be positive", test_nr_cache_blocks_must_be_positive },
-	{ (char*)"block size must be positive", test_block_size_must_be_positive },
-	{ (char*)"block size must be multiple of page size", test_block_size_must_be_multiple_of_page_size },
-	{ (char*)"reads work", test_reads_work },
-	{ (char*)"prefetch works", test_prefetch_works },
-	{ (char*)"read multiple files", test_read_multiple_files },
-	CU_TEST_INFO_NULL
+
+struct test_details {
+	const char *name;
+	void (*fn)(void);
 };
+
+int main(int argc, char **argv)
+{
+	static struct test_details _tests[] = {
+		{"simple create/destroy", test_create},
+		{"nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive},
+		{"block size must be positive", test_block_size_must_be_positive},
+		{"block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size},
+		{"bcache_get() triggers read", test_get_triggers_read},
+		{"repeated reads are cached", test_repeated_reads_are_cached},
+		{"block get evicted with many reads", test_block_gets_evicted_with_many_reads},
+		{"prefetch issues a read", test_prefetch_issues_a_read},
+		{"too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait},
+		{"dirty data gets written back", test_dirty_data_gets_written_back},
+		{"zeroed data counts as dirty", test_zeroed_data_counts_as_dirty},
+		{"flush waits for all dirty", test_flush_waits_for_all_dirty},
+	};
+
+	// We have to declare these as volatile because of the setjmp()
+	volatile unsigned i = 0, passed = 0;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
+		struct test_details *t = _tests + i;
+		fprintf(stderr, "[RUN    ] %s\n", t->name);
+
+		if (setjmp(_test_k))
+			fprintf(stderr, "[   FAIL] %s\n", t->name);
+		else {
+			t->fn();
+			passed++;
+			fprintf(stderr, "[     OK] %s\n", t->name);
+		}
+	}
+
+	fprintf(stderr, "\n%u/%lu tests passed\n", passed, DM_ARRAY_SIZE(_tests));
+
+#if 0
+	test_prefetch_works();
+	test_read_multiple_files();
+#endif
+
+	return 0;
+}


