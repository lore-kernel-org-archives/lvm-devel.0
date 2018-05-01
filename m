From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 05:50:12 -0400
Subject: master - unit-test/io_engine_t: add a little test for bcache_{read, write}_bytes
Message-ID: <201805010950.w419oCAv002613@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7aba7fe68b6da2ca8ec7b01f5730396d64426fb0
Commit:        7aba7fe68b6da2ca8ec7b01f5730396d64426fb0
Parent:        f6459757af0f255fe6cc89a05b614e7512ab1bca
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 10:47:40 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 10:47:40 2018 +0100

unit-test/io_engine_t: add a little test for bcache_{read,write}_bytes

---
 test/unit/bcache_t.c    |    1 +
 test/unit/io_engine_t.c |   84 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 70 insertions(+), 15 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index ce159cd..ecbe07b 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -821,6 +821,7 @@ static void test_invalidate_held_block(void *context)
 	bcache_put(b);
 }
 
+
 /*----------------------------------------------------------------
  * Top level
  *--------------------------------------------------------------*/
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 3a70265..822789a 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -29,7 +29,8 @@
 //----------------------------------------------------------------
 
 #define SECTOR_SIZE 512
-#define BLOCK_SIZE_SECTORS 64
+#define BLOCK_SIZE_SECTORS 8
+#define NR_BLOCKS 64
 
 struct fixture {
 	struct io_engine *e;
@@ -39,10 +40,46 @@ struct fixture {
 	int fd;
 };
 
-static void *_fix_init(void)
+static void _fill_buffer(uint8_t *buffer, uint8_t seed, size_t count)
 {
-        uint8_t b = 123;
         unsigned i;
+        uint8_t b = seed;
+
+	for (i = 0; i < count; i++) {
+        	buffer[i] = b;
+        	b = ((b << 5) + b) + i;
+	}
+}
+
+static void _check_buffer(uint8_t *buffer, uint8_t seed, size_t count)
+{
+	unsigned i;
+	uint8_t b = seed;
+
+	for (i = 0; i < count; i++) {
+        	T_ASSERT_EQUAL(buffer[i], b);
+        	b = ((b << 5) + b) + i;
+	}
+}
+
+static void _print_buffer(const char *name, uint8_t *buffer, size_t count)
+{
+	unsigned col;
+
+	fprintf(stderr, "%s:\n", name);
+	while (count) {
+		for (col = 0; count && col < 20; col++) {
+        		fprintf(stderr, "%x, ", (unsigned) *buffer);
+        		col++;
+        		buffer++;
+        		count--;
+		}
+		fprintf(stderr, "\n");
+	}
+}
+
+static void *_fix_init(void)
+{
         struct fixture *f = malloc(sizeof(*f));
 
         T_ASSERT(f);
@@ -55,10 +92,7 @@ static void *_fix_init(void)
 	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
 	T_ASSERT(f->fd >= 0);
 
-	for (i = 0; i < SECTOR_SIZE * BLOCK_SIZE_SECTORS; i++) {
-        	f->data[i] = b;
-        	b = ((b << 5) + b) + i;
-	}
+	_fill_buffer(f->data, 123, sizeof(f->data));
 
 	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
 	lseek(f->fd, 0, SEEK_SET);
@@ -72,7 +106,8 @@ static void _fix_exit(void *fixture)
 	close(f->fd);
 	unlink(f->fname);
         free(f->data);
-        f->e->destroy(f->e);
+        if (f->e)
+                f->e->destroy(f->e);
         free(f);
 }
 
@@ -103,8 +138,6 @@ static void _test_read(void *fixture)
 {
 	struct fixture *f = fixture;
 
-	uint8_t b = 123;
-	unsigned i;
 	struct io io;
 
 	_io_init(&io);
@@ -112,11 +145,8 @@ static void _test_read(void *fixture)
 	T_ASSERT(f->e->wait(f->e, _complete_io));
 	T_ASSERT(io.completed);
 	T_ASSERT(!io.error);
-	
-	for (i = 0; i < SECTOR_SIZE * BLOCK_SIZE_SECTORS; i++) {
-        	T_ASSERT_EQUAL(f->data[i], b);
-        	b = ((b << 5) + b) + i;
-	}
+
+	_check_buffer(f->data, 123, sizeof(f->data));
 }
 
 static void _test_write(void *fixture)
@@ -132,6 +162,29 @@ static void _test_write(void *fixture)
 	T_ASSERT(!io.error);
 }
 
+static void _test_write_bytes(void *fixture)
+{
+	struct fixture *f = fixture;
+
+	unsigned offset = 345;
+	char buf_out[32];
+	char buf_in[32];
+	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	T_ASSERT(cache);
+
+	// T_ASSERT(bcache_read_bytes(cache, f->fd, offset, sizeof(buf_in), buf_in));
+	_fill_buffer((uint8_t *) buf_out, 234, sizeof(buf_out));
+	T_ASSERT(bcache_write_bytes(cache, f->fd, offset, sizeof(buf_out), buf_out));
+	T_ASSERT(bcache_read_bytes(cache, f->fd, offset, sizeof(buf_in), buf_in));
+
+	_print_buffer("buf_out", (uint8_t *) buf_out, sizeof(buf_out));
+	_print_buffer("buf_in", (uint8_t *) buf_in, sizeof(buf_in));
+	T_ASSERT(!memcmp(buf_out, buf_in, sizeof(buf_out)));
+
+	bcache_destroy(cache);
+	f->e = NULL;   // already destroyed
+}
+
 //----------------------------------------------------------------
 
 #define T(path, desc, fn) register_test(ts, "/base/device/bcache/io-engine/" path, desc, fn)
@@ -147,6 +200,7 @@ static struct test_suite *_tests(void)
         T("create-destroy", "simple create/destroy", _test_create);
         T("create-read", "read sanity check", _test_read);
         T("create-write", "write sanity check", _test_write);
+        T("bcache-write-bytes", "test the utility fns", _test_write_bytes);
 
         return ts;
 }


