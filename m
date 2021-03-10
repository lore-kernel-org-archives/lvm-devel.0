From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:58:12 +0000 (GMT)
Subject: main - unit-test: modify for systems with PGSIZE of 64K
Message-ID: <20210310235812.1AF83385780E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=262008f1ceb050a9eed64f2fa50b1bc9366b9e75
Commit:        262008f1ceb050a9eed64f2fa50b1bc9366b9e75
Parent:        236a45dfc5e0292c99240aaeef42591c77a28549
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Tue Feb 23 17:39:29 2021 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:56:43 2021 +0100

unit-test: modify for systems with PGSIZE of 64K

This modification supports dynamically obtaining the value of PAGE_SIZE,
which is compatible with systems with PAGE_SIZE of (4K/64K)

Signed-off-by: wuguanghao <wuguanghao3@huawei.com>
---
 test/unit/bcache_t.c       |  7 ++++---
 test/unit/bcache_utils_t.c |  2 +-
 test/unit/io_engine_t.c    | 11 +++++++----
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 9c4d102de..399468ad4 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -360,6 +360,7 @@ static void _large_fixture_exit(void *context)
  *--------------------------------------------------------------*/
 #define MEG 2048
 #define SECTOR_SHIFT 9
+#define PAGE_SIZE_SECTORS (sysconf(_SC_PAGE_SIZE) >> SECTOR_SHIFT)
 
 static void good_create(sector_t block_size, unsigned nr_cache_blocks)
 {
@@ -389,12 +390,12 @@ static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
 
 static void test_create(void *fixture)
 {
-	good_create(8, 16);
+	good_create(PAGE_SIZE_SECTORS, 16);
 }
 
 static void test_nr_cache_blocks_must_be_positive(void *fixture)
 {
-	bad_create(8, 0);
+	bad_create(PAGE_SIZE_SECTORS, 0);
 }
 
 static void test_block_size_must_be_positive(void *fixture)
@@ -412,7 +413,7 @@ static void test_block_size_must_be_multiple_of_page_size(void *fixture)
 		bad_create(_bad_examples[i], 16);
 
 	for (i = 1; i < 100; i++)
-		good_create(i * 8, 16);
+		good_create(i * PAGE_SIZE_SECTORS, 16);
 }
 
 static void test_get_triggers_read(void *context)
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 69c510109..ecc3ebb32 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -26,7 +26,7 @@
 
 //----------------------------------------------------------------
 
-#define T_BLOCK_SIZE 4096
+#define T_BLOCK_SIZE sysconf(_SC_PAGESIZE)
 #define NR_BLOCKS 64
 #define INIT_PATTERN 123
 
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 349df2586..431cca6d3 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -25,8 +25,11 @@
 
 //----------------------------------------------------------------
 
+#define SECTOR_SHIFT 9
 #define SECTOR_SIZE 512
 #define BLOCK_SIZE_SECTORS 8
+#define PAGE_SIZE sysconf(_SC_PAGESIZE)
+#define PAGE_SIZE_SECTORS (PAGE_SIZE >> SECTOR_SHIFT)
 #define NR_BLOCKS 64
 
 struct fixture {
@@ -83,7 +86,7 @@ static void *_fix_init(void)
         T_ASSERT(f);
         f->e = create_async_io_engine();
         T_ASSERT(f->e);
-	if (posix_memalign((void **) &f->data, 4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
+	if (posix_memalign((void **) &f->data, PAGE_SIZE, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
         	test_fail("posix_memalign failed");
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
@@ -138,7 +141,7 @@ static void _test_read(void *fixture)
 {
 	struct fixture *f = fixture;
 	struct io io;
-	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	struct bcache *cache = bcache_create(PAGE_SIZE_SECTORS, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);
 
 	f->di = bcache_set_fd(f->fd);
@@ -156,7 +159,7 @@ static void _test_write(void *fixture)
 {
 	struct fixture *f = fixture;
 	struct io io;
-	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	struct bcache *cache = bcache_create(PAGE_SIZE_SECTORS, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);
 
 	f->di = bcache_set_fd(f->fd);
@@ -175,7 +178,7 @@ static void _test_write_bytes(void *fixture)
 	unsigned offset = 345;
 	char buf_out[32];
 	char buf_in[32];
-	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	struct bcache *cache = bcache_create(PAGE_SIZE_SECTORS, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);
 
 	f->di = bcache_set_fd(f->fd);


