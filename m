From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Tue, 23 Feb 2021 17:39:29 +0800
Subject: [PATCH v2]unit-test: modify the test case to support systems with PAGE_SIZE of 64K
Message-ID: <aed6c27e-48de-c81e-88f2-a97722857b10@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

This modification supports dynamically obtaining the value of PAGE_SIZE,
which is compatible with systems with PAGE_SIZE of (4K/64K)



>From 83523866cd1a0ad2d5d0da610a622da9e28e7657 Mon Sep 17 00:00:00 2001
From: wuguanghao <wuguanghao3@huawei.com>
Date: Sat, 20 Feb 2021 15:03:28 +0800
Subject: [PATCH] test case supports the case where PAGE_SIZE is 64K

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
-- 
2.23.0



Regards

Wu Guanghao


