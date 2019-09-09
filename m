From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 9 Sep 2019 13:20:24 -0400
Subject: 2019-09-05-add-io-manager - [io-manager] Reopen without O_DIRECT if we need to write a partial block.
Message-ID: <201909091720.x89HKOXL030000@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4693f7f8db38230362255ebc30d6b8a5bd40918
Commit:        e4693f7f8db38230362255ebc30d6b8a5bd40918
Parent:        4b25dd7bc229645535698109fb411a9c0752c446
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Sep 9 18:18:46 2019 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Sep 9 18:18:46 2019 +0100

[io-manager] Reopen without O_DIRECT if we need to write a partial block.

Still need to do a bit more testing.

Also need to think more about how we guarantee that we've reopened
the same device.  Pass in a device_id_extractor object to push the
issue up a layer?
---
 lib/device/io-manager.c        |   87 +++++++++++++++++++++++++-------
 lib/device/io-manager.h        |   14 +++--
 test/unit/io-manager-utils_t.c |   10 ++--
 test/unit/io-manager_t.c       |  107 ++++++++++++++++++++++++++++++----------
 4 files changed, 161 insertions(+), 57 deletions(-)

diff --git a/lib/device/io-manager.c b/lib/device/io-manager.c
index 9b44ff3..9800eee 100644
--- a/lib/device/io-manager.c
+++ b/lib/device/io-manager.c
@@ -137,7 +137,6 @@ struct async_engine {
 	struct cb_set *cbs;
 	unsigned page_mask;
 	unsigned page_sector_mask;
-	bool use_o_direct;
 	struct dm_list completed_fallbacks;
 };
 
@@ -186,12 +185,11 @@ static int _open_common(const char *path, int os_flags)
 	return fd;
 }
 
-static int _async_open(struct io_engine *ioe, const char *path, unsigned flags)
+static int _async_open(struct io_engine *ioe, const char *path, unsigned flags, bool o_direct)
 {
-	struct async_engine *e = _to_async(ioe);
 	int os_flags = 0;
 
-	if (e->use_o_direct)
+	if (o_direct)
 		os_flags |= O_DIRECT;
 
 	if (flags & EF_READ_ONLY)
@@ -474,7 +472,7 @@ static bool _common_get_block_sizes(struct io_engine *e, const char *path, int f
 	return true;
 }
 
-struct io_engine *create_async_io_engine(bool use_o_direct)
+struct io_engine *create_async_io_engine(void)
 {
 	int r;
 	struct async_engine *e = malloc(sizeof(*e));
@@ -508,15 +506,14 @@ struct io_engine *create_async_io_engine(bool use_o_direct)
 
 	e->page_mask = sysconf(_SC_PAGESIZE) - 1;
 	e->page_sector_mask = (sysconf(_SC_PAGESIZE) / 512) - 1;
-	e->use_o_direct = use_o_direct;
 	dm_list_init(&e->completed_fallbacks);
 
 	return &e->e;
 }
 
-struct io_engine *create_test_io_engine(bool use_o_direct)
+struct io_engine *create_test_io_engine(void)
 {
-	struct io_engine *ioe = create_async_io_engine(use_o_direct);
+	struct io_engine *ioe = create_async_io_engine();
 
 	if (ioe) {
 		struct async_engine *e = _to_async(ioe);
@@ -536,7 +533,6 @@ struct sync_io {
 struct sync_engine {
 	struct io_engine e;
 	struct dm_list complete;
-	bool use_o_direct;
 };
 
 static struct sync_engine *_to_sync(struct io_engine *e)
@@ -550,12 +546,11 @@ static void _sync_destroy(struct io_engine *ioe)
 	free(e);
 }
 
-static int _sync_open(struct io_engine *ioe, const char *path, unsigned flags)
+static int _sync_open(struct io_engine *ioe, const char *path, unsigned flags, bool o_direct)
 {
-	struct sync_engine *e = _to_sync(ioe);
 	int os_flags = 0;
 
-	if (e->use_o_direct)
+	if (o_direct)
 		os_flags |= O_DIRECT;
 
 	if (flags & EF_READ_ONLY)
@@ -637,7 +632,7 @@ static unsigned _sync_max_io(struct io_engine *e)
 	return 1;
 }
 
-struct io_engine *create_sync_io_engine(bool use_o_direct)
+struct io_engine *create_sync_io_engine(void)
 {
 	struct sync_engine *e = malloc(sizeof(*e));
 
@@ -652,7 +647,6 @@ struct io_engine *create_sync_io_engine(bool use_o_direct)
 	e->e.max_io = _sync_max_io;
 	e->e.get_size = _common_get_size;
 	e->e.get_block_sizes = _common_get_block_sizes;
-	e->use_o_direct = use_o_direct;
 
 	dm_list_init(&e->complete);
 	return &e->e;
@@ -719,6 +713,7 @@ struct io_dev_internal {
 
 	// These are the flags that actually used to open the dev.
 	unsigned flags;
+	bool opened_o_direct;
 
 	// Reopen uses this to check it's reopened the same device.
 	bool is_device;
@@ -740,6 +735,7 @@ struct io_dev_internal {
 struct io_manager {
 	sector_t block_sectors;
 	uint64_t block_mask;
+	uint64_t page_sector_mask;
 
 	// 1 bit set for every sector in a block.
 	uint64_t sectors_mask;
@@ -748,6 +744,7 @@ struct io_manager {
 	uint64_t nr_cache_blocks;
 	unsigned max_io;
 	unsigned max_cache_devs;
+	bool use_o_direct;
 
 	struct io_engine *engine;
 
@@ -916,7 +913,7 @@ static struct io_dev_internal *_new_dev(struct io_manager *iom,
 		}
 	}
 
-	dev->fd = iom->engine->open(iom->engine, path, flags);
+	dev->fd = iom->engine->open(iom->engine, path, flags, iom->use_o_direct);
 	if (dev->fd < 0) {
 		log_error("couldn't open io_dev(%s)", path);
 		free(dev);
@@ -937,6 +934,7 @@ static struct io_dev_internal *_new_dev(struct io_manager *iom,
 	dev->iom = iom;
 	dev->holders = 1;
 	dev->blocks = 0;
+	dev->opened_o_direct = iom->use_o_direct;
 
 	v.ptr = dev;
 	if (!radix_tree_insert(iom->dev_tree, (uint8_t *) path, (uint8_t *) (path + strlen(path)), v)) {
@@ -1012,7 +1010,7 @@ static struct io_dev_internal *_upgrade_dev(struct io_manager *iom, const char *
 		// Fast path
 		int fd;
 
-		fd = iom->engine->open(iom->engine, path, flags);
+		fd = iom->engine->open(iom->engine, path, flags, iom->use_o_direct);
 		if ((fd < 0) || !_check_same_device(dev, fd, path)) {
 			log_error("couldn't reopen io_dev(%s)", path);
 			_dec_holders(dev);
@@ -1023,6 +1021,7 @@ static struct io_dev_internal *_upgrade_dev(struct io_manager *iom, const char *
 
 		dev->fd = fd;
 		dev->flags = flags;
+		dev->opened_o_direct = iom->use_o_direct;
 	}
 
 	return dev;
@@ -1243,6 +1242,29 @@ static void _complete_io(void *context, int err)
 	}
 }
 
+static void _wait_all(struct io_manager *iom);
+static bool _reopen_without_o_direct(struct io_manager *iom, struct io_dev_internal *dev)
+{
+	int fd;
+
+	_wait_all(iom);
+
+	fd = iom->engine->open(iom->engine, dev->path, dev->flags, false);
+	if (fd < 0)
+		return false;
+
+	if (!_check_same_device(dev, fd, dev->path)) {
+		iom->engine->close(iom->engine, fd);
+		return false;
+	}
+
+	iom->engine->close(iom->engine, dev->fd);
+	dev->fd = fd;
+	dev->opened_o_direct = false;
+
+	return true;
+}
+
 static void _issue_sectors(struct block *b, sector_t sb, sector_t se)
 {
 	struct io_manager *iom = b->iom;
@@ -1287,10 +1309,16 @@ static void _issue_whole_block(struct block *b, enum dir d)
 	_issue_sectors(b, 0, b->iom->block_sectors);
 }
 
+static bool _is_partial_write(struct io_manager *iom, struct block *b)
+{
+	return (b->io_dir == DIR_WRITE) && (b->dirty_bits != iom->block_mask);
+}
+
 // |b->list| should be valid (either pointing to itself, on one of the other
 // lists.
 static void _issue(struct block *b, enum dir d)
 {
+	bool fail = false;
 	struct io_manager *iom = b->iom;
 
 	if (_test_flags(b, BF_IO_PENDING))
@@ -1300,12 +1328,21 @@ static void _issue(struct block *b, enum dir d)
 	assert(!b->io_count);
 
 	b->io_dir = d;
+	if (_is_partial_write(iom, b) && b->dev->opened_o_direct) {
+		if (!_reopen_without_o_direct(iom, b->dev))
+			fail = true;
+	}
+
 	_set_flags(b, BF_IO_PENDING);
 	iom->nr_io_pending++;
 	dm_list_move(&iom->io_pending, &b->list);
 
-	if ((d == DIR_WRITE) && (b->dirty_bits != iom->block_mask))
+	if (fail)
+		_complete_io(b, -EIO);
+
+	else if (_is_partial_write(iom, b))
 		_issue_partial_write(b);
+
 	else
 		_issue_whole_block(b, d);
 }
@@ -1584,7 +1621,8 @@ static uint64_t _calc_block_mask(sector_t nr_sectors)
 }
 
 struct io_manager *io_manager_create(sector_t block_sectors, unsigned nr_cache_blocks,
-                                     unsigned max_cache_devs, struct io_engine *engine)
+                                     unsigned max_cache_devs, struct io_engine *engine,
+                                     bool use_o_direct)
 {
 	struct io_manager *iom;
 	unsigned max_io = engine->max_io(engine);
@@ -1607,6 +1645,7 @@ struct io_manager *io_manager_create(sector_t block_sectors, unsigned nr_cache_b
 	iom->nr_cache_blocks = nr_cache_blocks;
 	iom->max_io = nr_cache_blocks < max_io ? nr_cache_blocks : max_io;
 	iom->max_cache_devs = max_cache_devs;
+	iom->use_o_direct = use_o_direct;
 	iom->engine = engine;
 	iom->dev_index = 0;
 	iom->nr_open = 0;
@@ -1651,6 +1690,8 @@ struct io_manager *io_manager_create(sector_t block_sectors, unsigned nr_cache_b
 	}
 	dm_list_init(&iom->dev_lru);
 
+	iom->page_sector_mask = (sysconf(_SC_PAGESIZE) / 512) - 1;
+
 	return iom;
 }
 
@@ -1989,9 +2030,15 @@ bool io_invalidate_all(struct io_manager *iom)
 	return it.success;
 }
 
-int io_get_fd(struct io_dev *dev)
+void *io_get_dev_context(struct io_dev *dev)
+{
+	return dev->idev;
+}
+
+int io_get_fd(void *dev_context)
 {
-	return dev->idev->fd;
+	struct io_dev_internal *idev = dev_context;
+	return idev->fd;
 }
 
 bool io_is_well_formed(struct io_manager *iom)
diff --git a/lib/device/io-manager.h b/lib/device/io-manager.h
index 87429b6..253b3ad 100644
--- a/lib/device/io-manager.h
+++ b/lib/device/io-manager.h
@@ -50,7 +50,7 @@ enum {
 struct io_engine {
 	void (*destroy)(struct io_engine *e);
 
-	int (*open)(struct io_engine *e, const char *path, unsigned flags);
+	int (*open)(struct io_engine *e, const char *path, unsigned flags, bool o_direct);
 	void (*close)(struct io_engine *e, int fd);
 
 	unsigned (*max_io)(struct io_engine *e);
@@ -64,12 +64,12 @@ struct io_engine {
                                 unsigned *physical, unsigned *logical);
 };
 
-struct io_engine *create_async_io_engine(bool use_o_direct);
-struct io_engine *create_sync_io_engine(bool use_o_direct);
+struct io_engine *create_async_io_engine(void);
+struct io_engine *create_sync_io_engine(void);
 
 // Same as create_async_io_engine(), except writes are not acted upon.
 // Used when running with --test.
-struct io_engine *create_test_io_engine(bool use_o_direct);
+struct io_engine *create_test_io_engine(void);
 
 /*----------------------------------------------------------------*/
 
@@ -104,7 +104,8 @@ struct block {
  * dev will be closed, and all its data invalidated.
  */
 struct io_manager *io_manager_create(sector_t block_size, unsigned nr_cache_blocks,
-			     	     unsigned max_cache_devs, struct io_engine *engine);
+			     	     unsigned max_cache_devs, struct io_engine *engine,
+                                     bool use_o_direct);
 void io_manager_destroy(struct io_manager *iom);
 
 // IMPORTANT: It is up to the caller to normalise the device path.  io does
@@ -200,7 +201,8 @@ bool io_dev_size(struct io_dev *dev, uint64_t *sectors);
 bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical, unsigned *block_size);
 
 // For testing and debug only
-int io_get_fd(struct io_dev *dev);
+void *io_get_dev_context(struct io_dev *dev);
+int io_get_fd(void *dev_context);
 bool io_is_well_formed(struct io_manager *iom);
 
 //----------------------------------------------------------------
diff --git a/test/unit/io-manager-utils_t.c b/test/unit/io-manager-utils_t.c
index a23c2a5..8384c4e 100644
--- a/test/unit/io-manager-utils_t.c
+++ b/test/unit/io-manager-utils_t.c
@@ -95,7 +95,7 @@ static void *_fix_init(struct io_engine *engine)
 	}
 	close(fd);
 
-	f->iom = io_manager_create(T_BLOCK_SIZE / 512, NR_BLOCKS, 256, engine);
+	f->iom = io_manager_create(T_BLOCK_SIZE / 512, NR_BLOCKS, 256, engine, true);
 	T_ASSERT(f->iom);
 
 	f->dev = io_get_dev(f->iom, f->fname, 0);
@@ -106,14 +106,14 @@ static void *_fix_init(struct io_engine *engine)
 
 static void *_async_init(void)
 {
-	struct io_engine *e = create_async_io_engine(_use_o_direct());
+	struct io_engine *e = create_async_io_engine();
 	T_ASSERT(e);
 	return _fix_init(e);
 }
 
 static void *_sync_init(void)
 {
-	struct io_engine *e = create_sync_io_engine(_use_o_direct());
+	struct io_engine *e = create_sync_io_engine();
 	T_ASSERT(e);
 	return _fix_init(e);
 }
@@ -236,10 +236,10 @@ static void _reopen(struct fixture *f)
 	io_put_dev(f->dev);
 	io_manager_destroy(f->iom);
 
-	engine = create_async_io_engine(_use_o_direct());
+	engine = create_async_io_engine();
 	T_ASSERT(engine);
 
-	f->iom = io_manager_create(T_BLOCK_SIZE / 512, NR_BLOCKS, 256, engine);
+	f->iom = io_manager_create(T_BLOCK_SIZE / 512, NR_BLOCKS, 256, engine, _use_o_direct());
 	T_ASSERT(f->iom);
 
 	f->dev = io_get_dev(f->iom, f->fname, 0);
diff --git a/test/unit/io-manager_t.c b/test/unit/io-manager_t.c
index d228257..f4187c1 100644
--- a/test/unit/io-manager_t.c
+++ b/test/unit/io-manager_t.c
@@ -57,7 +57,7 @@ struct mock_call {
 	enum dir d;
 	// We can't store the dev here because we want to track writebacks
 	// and the dev may have been put by then.
-	int fd;
+	void *fd_context;
 	sector_t sb;
 	sector_t se;
 	bool issue_r;
@@ -119,7 +119,7 @@ static void _expect_read(struct mock_engine *e, struct io_dev *dev, block_addres
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	_set_block(e, mc, b);
 	mc->issue_r = true;
 	mc->wait_r = true;
@@ -142,7 +142,7 @@ static void _expect_write(struct mock_engine *e, struct io_dev *dev, block_addre
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	mc->sb = b * e->block_size;
 	mc->se = mc->sb + e->block_size;
 	mc->issue_r = true;
@@ -158,7 +158,11 @@ static void _expect_partial_write(struct mock_engine *e,
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = io_get_fd(dev);
+
+ 	// FIXME: this can be reopened to remove a partial write, so we
+ 	// shouldn't call the io_get_fd(dev) until the validation step, but
+ 	// the dev object will not be held/exist at that point ...
+ 	mc->fd_context = io_get_dev_context(dev);
 	mc->sb = sb;
 	mc->se = se;
 	mc->issue_r = true;
@@ -174,7 +178,7 @@ static void _expect_partial_write_bad_issue(struct mock_engine *e,
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	mc->sb = sb;
 	mc->se = se;
 	mc->issue_r = false;
@@ -190,7 +194,7 @@ static void _expect_partial_write_bad_wait(struct mock_engine *e,
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	mc->sb = sb;
 	mc->se = se;
 	mc->issue_r = true;
@@ -204,7 +208,7 @@ static void _expect_read_bad_issue(struct mock_engine *e, struct io_dev *dev, bl
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	_set_block(e, mc, b);
 	mc->issue_r = false;
 	mc->wait_r = true;
@@ -217,7 +221,7 @@ static void _expect_write_bad_issue(struct mock_engine *e, struct io_dev *dev, b
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	_set_block(e, mc, b);
 	mc->issue_r = false;
 	mc->wait_r = true;
@@ -230,7 +234,7 @@ static void _expect_read_bad_wait(struct mock_engine *e, struct io_dev *dev, blo
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	_set_block(e, mc, b);
 	mc->issue_r = true;
 	mc->wait_r = false;
@@ -243,7 +247,7 @@ static void _expect_write_bad_wait(struct mock_engine *e, struct io_dev *dev, bl
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	_set_block(e, mc, b);
 	mc->issue_r = true;
 	mc->wait_r = false;
@@ -265,7 +269,7 @@ static void _expect_get_size(struct mock_engine *e, struct io_dev *dev, uint64_t
 	mc->m = E_GET_SIZE;
 	mc->match_args = true;
 	mc->fail = true;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	mc->size = s;
 	dm_list_add(&e->expected_calls, &mc->list);
 }
@@ -276,7 +280,7 @@ static void _expect_get_size_fail(struct mock_engine *e, struct io_dev *dev)
 	mc->m = E_GET_SIZE;
 	mc->match_args = true;
 	mc->fail = false;
-	mc->fd = io_get_fd(dev);
+	mc->fd_context = io_get_dev_context(dev);
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
@@ -333,7 +337,7 @@ static void _mock_destroy(struct io_engine *e)
 	free(_to_mock(e));
 }
 
-static int _mock_open(struct io_engine *e, const char *path, unsigned flags)
+static int _mock_open(struct io_engine *e, const char *path, unsigned flags, bool o_direct)
 {
 	struct mock_engine *me = _to_mock(e);
 	struct mock_call *mc;
@@ -365,7 +369,7 @@ static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
 	mc = _match_pop(me, E_ISSUE);
 	if (mc->match_args) {
 		T_ASSERT(d == mc->d);
-		T_ASSERT_EQUAL(fd, mc->fd);
+		T_ASSERT_EQUAL(fd, io_get_fd(mc->fd_context));
 		T_ASSERT(sb == mc->sb);
 		T_ASSERT(se == mc->se);
 	}
@@ -421,7 +425,7 @@ static bool _mock_get_size(struct io_engine *e, const char *path, int fd, uint64
 	struct mock_engine *me = _to_mock(e);
 	struct mock_call *mc = _match_pop(me, E_GET_SIZE);
 	if (mc->match_args && !mc->fail)
-		T_ASSERT_EQUAL(fd, mc->fd);
+		T_ASSERT_EQUAL(fd, io_get_fd(mc->fd_context));
 
 	*s = mc->size;
 	r = mc->fail;
@@ -459,7 +463,8 @@ struct fixture {
 };
 
 static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_blocks,
-                                     unsigned max_cache_devs)
+                                     unsigned max_cache_devs,
+                                     bool use_o_direct)
 {
 	struct fixture *f = malloc(sizeof(*f));
 
@@ -467,7 +472,8 @@ static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_bloc
 	T_ASSERT(f->me);
 
 	_expect(f->me, E_MAX_IO);
-	f->iom = io_manager_create(block_size, nr_cache_blocks, max_cache_devs, &f->me->e);
+	f->iom = io_manager_create(block_size, nr_cache_blocks, max_cache_devs,
+                                   &f->me->e, use_o_direct);
 	T_ASSERT(f->iom);
 
 	return f;
@@ -483,7 +489,7 @@ static void _fixture_exit(struct fixture *f)
 
 static void *_small_fixture_init(void)
 {
-	return _fixture_init(T_BLOCK_SIZE >> SECTOR_SHIFT, 16, SMALL_MAX_CACHE_DEVS);
+	return _fixture_init(T_BLOCK_SIZE >> SECTOR_SHIFT, 16, SMALL_MAX_CACHE_DEVS, true);
 }
 
 static void _small_fixture_exit(void *context)
@@ -491,9 +497,19 @@ static void _small_fixture_exit(void *context)
 	_fixture_exit(context);
 }
 
+static void *_no_o_direct_fixture_init(void)
+{
+	return _fixture_init(T_BLOCK_SIZE >> SECTOR_SHIFT, 16, SMALL_MAX_CACHE_DEVS, false);
+}
+
+static void _no_o_direct_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
 static void *_large_fixture_init(void)
 {
-	return _fixture_init(T_BLOCK_SIZE >> SECTOR_SHIFT, 1024, 256);
+	return _fixture_init(T_BLOCK_SIZE >> SECTOR_SHIFT, 1024, 256, true);
 }
 
 static void _large_fixture_exit(void *context)
@@ -510,7 +526,7 @@ static void good_create(sector_t block_size, unsigned nr_cache_blocks)
 	struct mock_engine *me = _mock_create(16, 128);
 
 	_expect(me, E_MAX_IO);
-	iom = io_manager_create(block_size, nr_cache_blocks, 256, &me->e);
+	iom = io_manager_create(block_size, nr_cache_blocks, 256, &me->e, true);
 	T_ASSERT(iom);
 
 	_expect(me, E_DESTROY);
@@ -523,7 +539,7 @@ static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
 	struct mock_engine *me = _mock_create(16, 128);
 
 	_expect(me, E_MAX_IO);
-	iom = io_manager_create(block_size, nr_cache_blocks, 256, &me->e);
+	iom = io_manager_create(block_size, nr_cache_blocks, 256, &me->e, true);
 	T_ASSERT(!iom);
 
 	_expect(me, E_DESTROY);
@@ -1391,11 +1407,32 @@ static void test_concurrent_reads_after_invalidate(void *context)
  * Partial block tests
  *--------------------------------------------------------------*/
 
-// rather than having a single dirty flag we should rely on the dirty_bits field.
-// after a write we should clear the dirty_bits
- 
-// different partial writes should aggregate in dirty_bits
-// nothing outside dirty_bits should be written
+static void test_reopen_without_direct(void *context)
+{
+	struct fixture *f = context;
+	const char *path = "/foo/bar/dev";
+	struct io_dev *dev;
+	struct mock_engine *me = f->me;
+	struct io_manager *iom = f->iom;
+
+	struct block *b;
+
+	_expect(f->me, E_OPEN);
+	dev = io_get_dev(f->iom, path, 0);
+
+	T_ASSERT(io_get_block_mask(iom, dev, 0, GF_ZERO, 0x1, &b));
+	io_put_block(b);
+
+	_expect(f->me, E_OPEN);   // FIXME: check use_o_direct isn't set
+	_expect(f->me, E_CLOSE);
+
+	// Expect the write
+	_expect_partial_write(me, dev, 0, 1);
+	_expect(me, E_WAIT);
+
+	_expect(f->me, E_CLOSE);
+	io_put_dev(dev);
+}
 
 static void _single_partial_write(struct fixture *f, uint64_t mask, sector_t sb, sector_t se)
 {
@@ -2014,6 +2051,23 @@ static struct test_suite *_small_tests(void)
 #undef T
 
 #define T(path, desc, fn) register_test(ts, "/base/device/io-manager/core/partial-write/" path, desc, fn)
+	T("reopen-without-o-direct", "Partial writes prevent O_DIRECT being used", test_reopen_without_direct);
+#undef T
+
+	return ts;
+}
+
+
+static struct test_suite *_partial_tests(void)
+{
+	struct test_suite *ts = test_suite_create(_no_o_direct_fixture_init,
+                                                  _no_o_direct_fixture_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+#define T(path, desc, fn) register_test(ts, "/base/device/io-manager/core/partial-write/" path, desc, fn)
 	T("single-start", "Writes a single sector at the start of a block", test_partial_write_at_start);
 	T("single-end", "Writes a single sector at the end of a block", test_partial_write_at_end);
 	T("multi-start", "Writes multiple sectors at the start of a block", test_partial_write_multiple_sectors_start);
@@ -2069,5 +2123,6 @@ void io_manager_tests(struct dm_list *all_tests)
 {
         dm_list_add(all_tests, &_tiny_tests()->list);
 	dm_list_add(all_tests, &_small_tests()->list);
+	dm_list_add(all_tests, &_partial_tests()->list);
 	dm_list_add(all_tests, &_large_tests()->list);
 }


