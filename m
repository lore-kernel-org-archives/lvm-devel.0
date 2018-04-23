From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:46:46 -0400
Subject: master - [device/bcache] some more work on bcache
Message-ID: <201804231346.w3NDkk4C031107@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f0eb04edb00cb5e95c47cb9ca2e70574e6e49ce
Commit:        0f0eb04edb00cb5e95c47cb9ca2e70574e6e49ce
Parent:        46867a45d28ecb667d08df8d8cb497fffc10814d
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Feb 1 14:52:43 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] some more work on bcache

---
 lib/device/bcache.c   |   99 ++++++++++++++++++++++-----------
 lib/device/bcache.h   |    2 +-
 test/unit/Makefile.in |    2 +-
 test/unit/bcache_t.c  |  147 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 216 insertions(+), 34 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 3b8cf78..5a7b2f9 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -167,12 +167,19 @@ static struct io_engine *_engine_create(unsigned max_io)
 
 static void _engine_destroy(struct io_engine *e)
 {
+	int r;
+
 	_cb_set_destroy(e->cbs);
-	io_destroy(e->aio_context);
+
+	// io_destroy is really slow
+	r = io_destroy(e->aio_context);
+	if (r)
+		log_sys_warn("io_destroy");
+
 	dm_free(e);
 }
 
-static bool _engine_issue(struct io_engine *e, int fd, enum dir d,
+static bool _engine_issue(struct io_engine *e, enum dir d, int fd,
 			  sector_t sb, sector_t se, void *data, void *context)
 {
 	int r;
@@ -290,7 +297,6 @@ enum block_flags {
 };
 
 struct bcache {
-	int fd;
 	sector_t block_sectors;
 	uint64_t nr_data_blocks;
 	uint64_t nr_cache_blocks;
@@ -488,6 +494,30 @@ static void _relink(struct block *b)
  *
  *--------------------------------------------------------------*/
 
+static void _complete_io(void *context, int err)
+{
+	struct block *b = context;
+	struct bcache *cache = b->cache;
+
+	b->error = err;
+	_clear_flags(b, BF_IO_PENDING);
+	cache->nr_io_pending--;
+
+	/*
+	 * b is on the io_pending list, so we don't want to use unlink_block.
+	 * Which would incorrectly adjust nr_dirty.
+	 */
+	dm_list_del(&b->list);
+
+	if (b->error)
+		dm_list_add(&cache->errored, &b->list);
+
+	else {
+		_clear_flags(b, BF_DIRTY);
+		_link_block(b);
+	}
+}
+
 /*
  * |b->list| should be valid (either pointing to itself, on one of the other
  * lists.
@@ -502,7 +532,13 @@ static bool _issue_low_level(struct block *b, enum dir d)
 		return false;
 
 	_set_flags(b, BF_IO_PENDING);
-	return _engine_issue(cache->engine, cache->fd, d, sb, se, b->data, b);
+	if (!_engine_issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
+		_complete_io(b, -EIO);
+		return false;
+	}
+
+	return true;
+
 }
 
 static inline bool _issue_read(struct block *b)
@@ -515,30 +551,6 @@ static inline bool _issue_write(struct block *b)
 	return _issue_low_level(b, DIR_WRITE);
 }
 
-static void _complete_io(void *context, int err)
-{
-	struct block *b = context;
-	struct bcache *cache = b->cache;
-
-	b->error = err;
-	_clear_flags(b, BF_IO_PENDING);
-	cache->nr_io_pending--;
-
-	/*
-	 * b is on the io_pending list, so we don't want to use unlink_block.
-	 * Which would incorrectly adjust nr_dirty.
-	 */
-	dm_list_del(&b->list);
-
-	if (b->error)
-		dm_list_add(&cache->errored, &b->list);
-
-	else {
-		_clear_flags(b, BF_DIRTY);
-		_link_block(b);
-	}
-}
-
 static bool _wait_io(struct bcache *cache)
 {
 	return _engine_wait(cache->engine, _complete_io);
@@ -598,7 +610,7 @@ static struct block *_find_unused_clean_block(struct bcache *cache)
 	return NULL;
 }
 
-static struct block *_new_block(struct bcache *cache, block_address index)
+static struct block *_new_block(struct bcache *cache, int fd, block_address index)
 {
 	struct block *b;
 
@@ -616,6 +628,7 @@ static struct block *_new_block(struct bcache *cache, block_address index)
 		dm_list_init(&b->list);
 		dm_list_init(&b->hash);
 		b->flags = 0;
+		b->fd = fd;
 		b->index = index;
 		b->ref_count = 0;
 		b->error = 0;
@@ -685,7 +698,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 	} else {
 		_miss(cache, flags);
 
-		b = _new_block(cache, index);
+		b = _new_block(cache, fd, index);
 		if (b) {
 			if (flags & GF_ZERO)
 				_zero_block(b);
@@ -728,6 +741,21 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks)
 {
 	struct bcache *cache;
 
+	if (!nr_cache_blocks) {
+		log_warn("bcache must have at least one cache block");
+		return NULL;
+	}
+
+	if (!block_sectors) {
+		log_warn("bcache must have a non zero block size");
+		return NULL;
+	}
+
+	if (block_sectors & ((PAGE_SIZE >> SECTOR_SHIFT) - 1)) {
+		log_warn("bcache block size must be a multiple of page size");
+		return NULL;
+	}
+
 	cache = dm_malloc(sizeof(*cache));
 	if (!cache)
 		return NULL;
@@ -787,6 +815,11 @@ void bcache_destroy(struct bcache *cache)
 	dm_free(cache);
 }
 
+unsigned bcache_nr_cache_blocks(struct bcache *cache)
+{
+	return cache->nr_cache_blocks;
+}
+
 void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 {
 	struct block *b = _hash_lookup(cache, fd, index);
@@ -794,7 +827,7 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 	if (!b) {
 		cache->prefetches++;
 
-		b = _new_block(cache, index);
+		b = _new_block(cache, fd, index);
 		if (b)
 			_issue_read(b);
 	}
@@ -803,7 +836,9 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 bool bcache_get(struct bcache *cache, int fd, block_address index,
 	        unsigned flags, struct block **result)
 {
-	struct block *b = _lookup_or_read_block(cache, fd, index, flags);
+	struct block *b;
+
+	b = _lookup_or_read_block(cache, fd, index, flags);
 	if (b) {
 		if (!b->ref_count)
 			cache->nr_locked++;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 0747b5a..2730347 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -61,7 +61,7 @@ enum bcache_get_flags {
 
 typedef uint64_t block_address;
 
-unsigned bcache_get_max_prefetches(struct bcache *cache);
+unsigned bcache_nr_cache_blocks(struct bcache *cache);
 
 /*
  * Use the prefetch method to take advantage of asynchronous IO.  For example,
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 8127ec0..5cf92ba 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -47,7 +47,7 @@ $(TARGETS): $(OBJECTS) $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
 	      -o $@ $(OBJECTS) $(LDLIBS)
 
-unit: $(TARGETS)
+unit: $(TARGETS) $(top_builddir)/lib/liblvm-internal.a
 	@echo Running unit tests
 	LD_LIBRARY_PATH=$(top_builddir)/libdm ./$(TARGETS)
 endif
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index da274a9..ef92721 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -12,9 +12,21 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#define _GNU_SOURCE
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+
 #include "units.h"
 #include "bcache.h"
 
+#define MEG 2048
+#define SECTOR_SHIFT 9
+
+static const char *_test_path = "test.bin";
+
 int bcache_init(void)
 {
 	return 0;
@@ -25,6 +37,42 @@ int bcache_fini(void)
 	return 0;
 }
 
+static int open_file(const char *path)
+{
+	return open(path, O_EXCL | O_RDWR | O_DIRECT, 0666);
+}
+
+static int _prep_file(const char *path)
+{
+	int fd, r;
+
+	fd = open(path, O_CREAT | O_TRUNC | O_EXCL | O_RDWR | O_DIRECT, 0666);
+	if (fd < 0)
+		return -1;
+
+	r = fallocate(fd, FALLOC_FL_ZERO_RANGE, 0, (16 * MEG) << SECTOR_SHIFT);
+	if (r) {
+		close(fd);
+		return -1;
+	}
+
+	close(fd);
+	return 0;
+}
+
+
+static int test_init(void)
+{
+	unlink(_test_path);
+	return _prep_file(_test_path);
+}
+
+static int test_exit(void)
+{
+	unlink(_test_path);
+	return 0;
+}
+
 static void test_create(void)
 {
 	struct bcache *cache = bcache_create(8, 16);
@@ -32,7 +80,106 @@ static void test_create(void)
 	bcache_destroy(cache);
 }
 
+static void test_nr_cache_blocks_must_be_positive(void)
+{
+	struct bcache *cache = bcache_create(8, 0);
+	CU_ASSERT_PTR_NULL(cache);
+}
+
+static void test_block_size_must_be_positive(void)
+{
+	struct bcache *cache = bcache_create(0, 16);
+	CU_ASSERT_PTR_NULL(cache);
+}
+
+static void test_block_size_must_be_multiple_of_page_size(void)
+{
+	unsigned i;
+	struct bcache *cache;
+
+	{
+		static unsigned _bad_examples[] = {3, 9, 13, 1025};
+
+		for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++) {
+			cache = bcache_create(_bad_examples[i], 16);
+			CU_ASSERT_PTR_NULL(cache);
+		}
+	}
+
+	{
+		// Only testing a few sizes because io_destroy is seriously
+		// slow.
+		for (i = 1; i < 25; i++) {
+			cache = bcache_create(8 * i, 16);
+			CU_ASSERT_PTR_NOT_NULL(cache);
+			bcache_destroy(cache);
+		}
+	}
+}
+
+static void test_reads_work(void)
+{
+	int fd;
+
+	// FIXME: add fixtures.
+	test_init();
+	fd = open_file("./test.bin");
+	CU_ASSERT(fd >= 0);
+
+	{
+		int i;
+		struct block *b;
+		struct bcache *cache = bcache_create(8, 16);
+
+		CU_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+		for (i = 0; i < 8 << SECTOR_SHIFT; i++)
+			CU_ASSERT(((unsigned char *) b->data)[i] == 0);
+		bcache_put(b);
+
+		bcache_destroy(cache);
+	}
+
+	close(fd);
+
+	test_exit();
+}
+
+static void test_prefetch_works(void)
+{
+	int fd;
+
+	// FIXME: add fixtures.
+	test_init();
+	fd = open_file("./test.bin");
+	CU_ASSERT(fd >= 0);
+
+	{
+		int i;
+		struct block *b;
+		struct bcache *cache = bcache_create(8, 16);
+
+		for (i = 0; i < 16; i++)
+			bcache_prefetch(cache, fd, i);
+
+		for (i = 0; i < 16; i++) {
+			CU_ASSERT(bcache_get(cache, fd, i, 0, &b));
+			bcache_put(b);
+		}
+
+		bcache_destroy(cache);
+	}
+
+	close(fd);
+
+	test_exit();
+}
+
 CU_TestInfo bcache_list[] = {
 	{ (char*)"create", test_create },
+	{ (char*)"nr cache block must be positive", test_nr_cache_blocks_must_be_positive },
+	{ (char*)"block size must be positive", test_block_size_must_be_positive },
+	{ (char*)"block size must be multiple of page size", test_block_size_must_be_multiple_of_page_size },
+	{ (char*)"reads work", test_reads_work },
+	{ (char*)"prefetch works", test_prefetch_works },
 	CU_TEST_INFO_NULL
 };


