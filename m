From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Mon, 22 Feb 2021 16:01:43 +0800
Subject: [PATCH]unit-test: modify the test case to support systems with PAGE_SIZE of 64K
Message-ID: <be093e24-7d0b-a929-d092-4854878196ec@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Now we want to compile lvm2 on a machine whose PAGE_SIZE is 64K and
enable unit test at the same time. However, we found that some test cases
cannot be executed normally, so we made some modifications.


>From 00acbafcdf006d9da748e404c0eed58d6675791b Mon Sep 17 00:00:00 2001
From: root <root@localhost.localdomain>
Date: Mon, 22 Feb 2021 15:38:49 +0800
Subject: [PATCH] Modify the test case to support systems with PAGE_SIZE of 64K

---
 test/unit/bcache_t.c       |  6 +++---
 test/unit/bcache_utils_t.c |  2 +-
 test/unit/io_engine_t.c    | 10 +++++-----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 9c4d102..5d7077c 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -389,12 +389,12 @@ static void bad_create(sector_t block_size, unsigned nr_cache_blocks)

 static void test_create(void *fixture)
 {
-	good_create(8, 16);
+	good_create(128, 16);
 }

 static void test_nr_cache_blocks_must_be_positive(void *fixture)
 {
-	bad_create(8, 0);
+	bad_create(128, 0);
 }

 static void test_block_size_must_be_positive(void *fixture)
@@ -412,7 +412,7 @@ static void test_block_size_must_be_multiple_of_page_size(void *fixture)
 		bad_create(_bad_examples[i], 16);

 	for (i = 1; i < 100; i++)
-		good_create(i * 8, 16);
+		good_create(i * 128, 16);
 }

 static void test_get_triggers_read(void *context)
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 69c5101..f81c083 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -26,7 +26,7 @@

 //----------------------------------------------------------------

-#define T_BLOCK_SIZE 4096
+#define T_BLOCK_SIZE 65536
 #define NR_BLOCKS 64
 #define INIT_PATTERN 123

diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 349df25..4d3164c 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -26,7 +26,7 @@
 //----------------------------------------------------------------

 #define SECTOR_SIZE 512
-#define BLOCK_SIZE_SECTORS 8
+#define BLOCK_SIZE_SECTORS 128
 #define NR_BLOCKS 64

 struct fixture {
@@ -83,7 +83,7 @@ static void *_fix_init(void)
         T_ASSERT(f);
         f->e = create_async_io_engine();
         T_ASSERT(f->e);
-	if (posix_memalign((void **) &f->data, 4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
+	if (posix_memalign((void **) &f->data, 65536, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
         	test_fail("posix_memalign failed");

         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
@@ -138,7 +138,7 @@ static void _test_read(void *fixture)
 {
 	struct fixture *f = fixture;
 	struct io io;
-	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	struct bcache *cache = bcache_create(128, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);

 	f->di = bcache_set_fd(f->fd);
@@ -156,7 +156,7 @@ static void _test_write(void *fixture)
 {
 	struct fixture *f = fixture;
 	struct io io;
-	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	struct bcache *cache = bcache_create(128, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);

 	f->di = bcache_set_fd(f->fd);
@@ -175,7 +175,7 @@ static void _test_write_bytes(void *fixture)
 	unsigned offset = 345;
 	char buf_out[32];
 	char buf_in[32];
-	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	struct bcache *cache = bcache_create(128, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);

 	f->di = bcache_set_fd(f->fd);
-- 
2.27.0



Regards

Wu Guanghao


