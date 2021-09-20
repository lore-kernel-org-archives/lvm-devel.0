From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:03 +0000 (GMT)
Subject: main - cov: handle teoretical sysconf failure
Message-ID: <20210920133003.192F93858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce907bcd26f4814966a814771f9c1d01c80c9b01
Commit:        ce907bcd26f4814966a814771f9c1d01c80c9b01
Parent:        f410035181d8c524ffc5d0f3edf512e8506b47d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:23:24 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: handle teoretical sysconf failure

sysconf() may also return -1 although rather theoretically.
Default to 4K when such case would happen.
Also in function call it just once and keep as static variable.
---
 lib/device/bcache.c        | 20 +++++++++++++-------
 test/unit/bcache_t.c       |  2 +-
 test/unit/bcache_utils_t.c |  2 +-
 test/unit/framework.h      |  2 ++
 test/unit/io_engine_t.c    |  3 +--
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 285d92bc7..be25cc7e2 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -358,10 +358,16 @@ static unsigned _async_max_io(struct io_engine *e)
 
 struct io_engine *create_async_io_engine(void)
 {
+	static int _pagesize = 0;
 	int r;
-	struct async_engine *e = malloc(sizeof(*e));
+	struct async_engine *e;
 
-	if (!e)
+	if ((_pagesize <= 0) && (_pagesize = sysconf(_SC_PAGESIZE)) < 0) {
+		log_warn("_SC_PAGESIZE returns negative value.");
+		return NULL;
+	}
+
+	if (!(e = malloc(sizeof(*e))))
 		return NULL;
 
 	e->e.destroy = _async_destroy;
@@ -384,7 +390,7 @@ struct io_engine *create_async_io_engine(void)
 		return NULL;
 	}
 
-	e->page_mask = sysconf(_SC_PAGESIZE) - 1;
+	e->page_mask = (unsigned) _pagesize - 1;
 
 	return &e->e;
 }
@@ -1087,12 +1093,12 @@ static void _preemptive_writeback(struct bcache *cache)
 struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 			     struct io_engine *engine)
 {
+	static long _pagesize = 0;
 	struct bcache *cache;
 	unsigned max_io = engine->max_io(engine);
-	long pgsize = sysconf(_SC_PAGESIZE);
 	int i;
 
-	if (pgsize < 0) {
+	if ((_pagesize <= 0) && ((_pagesize = sysconf(_SC_PAGESIZE)) < 0)) {
 		log_warn("WARNING: _SC_PAGESIZE returns negative value.");
 		return NULL;
 	}
@@ -1107,7 +1113,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 		return NULL;
 	}
 
-	if (block_sectors & ((pgsize >> SECTOR_SHIFT) - 1)) {
+	if (block_sectors & ((_pagesize >> SECTOR_SHIFT) - 1)) {
 		log_warn("bcache block size must be a multiple of page size");
 		return NULL;
 	}
@@ -1144,7 +1150,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	cache->write_misses = 0;
 	cache->prefetches = 0;
 
-	if (!_init_free_list(cache, nr_cache_blocks, pgsize)) {
+	if (!_init_free_list(cache, nr_cache_blocks, _pagesize)) {
 		cache->engine->destroy(cache->engine);
 		radix_tree_destroy(cache->rtree);
 		free(cache);
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 878ed5996..3231b76e0 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -380,7 +380,7 @@ static void _large_fixture_exit(void *context)
  *--------------------------------------------------------------*/
 #define MEG 2048
 #define SECTOR_SHIFT 9
-#define PAGE_SIZE_SECTORS (sysconf(_SC_PAGE_SIZE) >> SECTOR_SHIFT)
+#define PAGE_SIZE_SECTORS ((PAGE_SIZE) >> SECTOR_SHIFT)
 
 static void good_create(sector_t block_size, unsigned nr_cache_blocks)
 {
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 517a46e1d..573fc1533 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -26,7 +26,7 @@
 
 //----------------------------------------------------------------
 
-#define T_BLOCK_SIZE sysconf(_SC_PAGESIZE)
+#define T_BLOCK_SIZE (PAGE_SIZE)
 #define NR_BLOCKS 64
 #define INIT_PATTERN 123
 
diff --git a/test/unit/framework.h b/test/unit/framework.h
index 0c455969c..f7f5b5bb9 100644
--- a/test/unit/framework.h
+++ b/test/unit/framework.h
@@ -44,6 +44,8 @@ void test_fail(const char *fmt, ...)
 extern jmp_buf test_k;
 #define TEST_FAILED 1
 
+#define PAGE_SIZE ({ int ps = sysconf(_SC_PAGESIZE); (ps > 0) ? ps : 4096 ; })
+
 //-----------------------------------------------------------------
 
 #endif
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index c864fa338..89fa4b787 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -28,8 +28,7 @@
 #define SECTOR_SHIFT 9
 #define SECTOR_SIZE 512
 #define BLOCK_SIZE_SECTORS 8
-#define PAGE_SIZE sysconf(_SC_PAGESIZE)
-#define PAGE_SIZE_SECTORS (PAGE_SIZE >> SECTOR_SHIFT)
+#define PAGE_SIZE_SECTORS ((PAGE_SIZE) >> SECTOR_SHIFT)
 #define NR_BLOCKS 64
 
 struct fixture {


