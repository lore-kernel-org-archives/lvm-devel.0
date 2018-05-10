From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 09:33:50 -0400
Subject: master - bcache: Add sync io engine
Message-ID: <201805101333.w4ADXob8015223@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae5037481172da84d414ca047408d9fb13955886
Commit:        ae5037481172da84d414ca047408d9fb13955886
Parent:        67b80e2d9d9b437f18f909c9c09e4b286337b031
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 10 14:29:26 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 10 14:29:26 2018 +0100

bcache: Add sync io engine

Something to fall back to when testing.
---
 lib/device/bcache.c        |   92 +++++++++++++++++++++++++++++++++++++++++++-
 lib/device/bcache.h        |    1 +
 test/unit/bcache_utils_t.c |   67 +++++++++++++++++++++++++++----
 3 files changed, 150 insertions(+), 10 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 62e99bd..7a221c5 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -129,7 +129,6 @@ static struct control_block *_iocb_to_cb(struct iocb *icb)
 
 //----------------------------------------------------------------
 
-// FIXME: write a sync engine too
 struct async_engine {
 	struct io_engine e;
 	io_context_t aio_context;
@@ -281,6 +280,97 @@ struct io_engine *create_async_io_engine(void)
 
 //----------------------------------------------------------------
 
+struct sync_io {
+        struct dm_list list;
+	void *context;
+	int err;
+};
+
+struct sync_engine {
+	struct io_engine e;
+	struct dm_list complete;
+};
+
+static struct sync_engine *_to_sync(struct io_engine *e)
+{
+        return container_of(e, struct sync_engine, e);
+}
+
+static void _sync_destroy(struct io_engine *ioe)
+{
+        struct sync_engine *e = _to_sync(ioe);
+        dm_free(e);
+}
+
+static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
+                        sector_t sb, sector_t se, void *data, void *context)
+{
+        int r;
+        uint64_t len = (se - sb) * 512;
+	struct sync_engine *e = _to_sync(ioe);
+	struct sync_io *io = malloc(sizeof(*io));
+	if (!io)
+        	return false;
+
+	r = lseek(fd, sb * 512, SEEK_SET);
+	if (r < 0)
+        	return false;
+
+	do {
+        	if (d == DIR_READ)
+                        r = read(fd, data, len);
+                else
+                        r = write(fd, data, len);
+
+	} while (r == EINTR || r == EAGAIN);
+
+	if (r != len)
+        	r = -EIO;
+
+	dm_list_add(&e->complete, &io->list);
+	io->context = context;
+	io->err = r < 0 ? r : 0;
+
+	return true;
+}
+
+static bool _sync_wait(struct io_engine *ioe, io_complete_fn fn)
+{
+        struct sync_io *io, *tmp;
+	struct sync_engine *e = _to_sync(ioe);
+
+	dm_list_iterate_items_safe(io, tmp, &e->complete) {
+		fn(io->context, io->err);
+		dm_list_del(&io->list);
+		dm_free(io);
+	}
+
+	return true;
+}
+
+static unsigned _sync_max_io(struct io_engine *e)
+{
+        return 1;
+}
+
+struct io_engine *create_sync_io_engine(void)
+{
+	struct sync_engine *e = dm_malloc(sizeof(*e));
+
+	if (!e)
+        	return NULL;
+
+        e->e.destroy = _sync_destroy;
+        e->e.issue = _sync_issue;
+        e->e.wait = _sync_wait;
+        e->e.max_io = _sync_max_io;
+
+        dm_list_init(&e->complete);
+        return &e->e;
+}
+
+//----------------------------------------------------------------
+
 #define MIN_BLOCKS 16
 #define WRITEBACK_LOW_THRESHOLD_PERCENT 33
 #define WRITEBACK_HIGH_THRESHOLD_PERCENT 66
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 3084fa7..b0aebb4 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -48,6 +48,7 @@ struct io_engine {
 };
 
 struct io_engine *create_async_io_engine(void);
+struct io_engine *create_sync_io_engine(void);
 
 /*----------------------------------------------------------------*/
 
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index b784c6f..4f15591 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -48,10 +48,9 @@ static uint64_t byte(block_address b, uint64_t offset)
 	return b * T_BLOCK_SIZE + offset;
 }
 
-static void *_fix_init(void)
+static void *_fix_init(struct io_engine *engine)
 {
         uint8_t buffer[T_BLOCK_SIZE];
-        struct io_engine *engine;
         struct fixture *f = malloc(sizeof(*f));
         unsigned b, i;
 
@@ -72,15 +71,26 @@ static void *_fix_init(void)
 	f->fd = open(f->fname, O_RDWR | O_DIRECT);
 	T_ASSERT(f->fd >= 0);
 
-	engine = create_async_io_engine();
-	T_ASSERT(engine);
-
 	f->cache = bcache_create(T_BLOCK_SIZE / 512, NR_BLOCKS, engine);
 	T_ASSERT(f->cache);
 
         return f;
 }
 
+static void *_async_init(void)
+{
+	struct io_engine *e = create_async_io_engine();
+	T_ASSERT(e);
+	return _fix_init(e);
+}
+
+static void *_sync_init(void)
+{
+	struct io_engine *e = create_sync_io_engine();
+	T_ASSERT(e);
+	return _fix_init(e);
+}
+
 static void _fix_exit(void *fixture)
 {
         struct fixture *f = fixture;
@@ -123,6 +133,7 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
 		T_ASSERT(bcache_read_bytes(f->cache, f->fd, byte_b, len2, buffer));
 		for (i = 0; i < len; i++)
         		T_ASSERT_EQUAL(buffer[i], _pattern_at(pat, byte_b + i));
+        	free(buffer);
 	}
 
 	// Verify again, driving bcache directly
@@ -349,16 +360,52 @@ static void _test_set_many_boundaries(void *fixture)
 
 //----------------------------------------------------------------
 
-#define T(path, desc, fn) register_test(ts, "/base/device/bcache/utils/" path, desc, fn)
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/utils/async/" path, desc, fn)
+
+static struct test_suite *_async_tests(void)
+{
+        struct test_suite *ts = test_suite_create(_async_init, _fix_exit);
+        if (!ts) {
+                fprintf(stderr, "out of memory\n");
+                exit(1);
+        }
+
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/utils/async/" path, desc, fn)
+        T("rw-first-block", "read/write/verify the first block", _test_rw_first_block);
+        T("rw-last-block", "read/write/verify the last block", _test_rw_last_block);
+        T("rw-several-blocks", "read/write/verify several whole blocks", _test_rw_several_whole_blocks);
+        T("rw-within-single-block", "read/write/verify within single block", _test_rw_within_single_block);
+        T("rw-cross-one-boundary", "read/write/verify across one boundary", _test_rw_cross_one_boundary);
+        T("rw-many-boundaries", "read/write/verify many boundaries", _test_rw_many_boundaries);
+
+        T("zero-first-block", "zero the first block", _test_zero_first_block);
+        T("zero-last-block", "zero the last block", _test_zero_last_block);
+        T("zero-several-blocks", "zero several whole blocks", _test_zero_several_whole_blocks);
+        T("zero-within-single-block", "zero within single block", _test_zero_within_single_block);
+        T("zero-cross-one-boundary", "zero across one boundary", _test_zero_cross_one_boundary);
+        T("zero-many-boundaries", "zero many boundaries", _test_zero_many_boundaries);
+
+        T("set-first-block", "set the first block", _test_set_first_block);
+        T("set-last-block", "set the last block", _test_set_last_block);
+        T("set-several-blocks", "set several whole blocks", _test_set_several_whole_blocks);
+        T("set-within-single-block", "set within single block", _test_set_within_single_block);
+        T("set-cross-one-boundary", "set across one boundary", _test_set_cross_one_boundary);
+        T("set-many-boundaries", "set many boundaries", _test_set_many_boundaries);
+#undef T
+
+        return ts;
+}
+
 
-static struct test_suite *_tests(void)
+static struct test_suite *_sync_tests(void)
 {
-        struct test_suite *ts = test_suite_create(_fix_init, _fix_exit);
+        struct test_suite *ts = test_suite_create(_sync_init, _fix_exit);
         if (!ts) {
                 fprintf(stderr, "out of memory\n");
                 exit(1);
         }
 
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/utils/sync/" path, desc, fn)
         T("rw-first-block", "read/write/verify the first block", _test_rw_first_block);
         T("rw-last-block", "read/write/verify the last block", _test_rw_last_block);
         T("rw-several-blocks", "read/write/verify several whole blocks", _test_rw_several_whole_blocks);
@@ -379,12 +426,14 @@ static struct test_suite *_tests(void)
         T("set-within-single-block", "set within single block", _test_set_within_single_block);
         T("set-cross-one-boundary", "set across one boundary", _test_set_cross_one_boundary);
         T("set-many-boundaries", "set many boundaries", _test_set_many_boundaries);
+#undef T
 
         return ts;
 }
 
 void bcache_utils_tests(struct dm_list *all_tests)
 {
-	dm_list_add(all_tests, &_tests()->list);
+	dm_list_add(all_tests, &_async_tests()->list);
+	dm_list_add(all_tests, &_sync_tests()->list);
 }
 


