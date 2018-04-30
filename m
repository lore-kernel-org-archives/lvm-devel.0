From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 12:10:18 -0400
Subject: master - unit-test/io_engine_t: Improve the read test.
Message-ID: <201804301610.w3UGAIM9005079@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39f24a169c7cdec5e927a20aacb774e88407d31a
Commit:        39f24a169c7cdec5e927a20aacb774e88407d31a
Parent:        ef79d639fe245f93202df00381b2c87a05917374
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 17:09:24 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 17:09:24 2018 +0100

unit-test/io_engine_t: Improve the read test.

Now verifies what it reads.
---
 test/unit/io_engine_t.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 57fdbda..3a70265 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -33,7 +33,7 @@
 
 struct fixture {
 	struct io_engine *e;
-	void *data;
+	uint8_t *data;
 
 	char fname[64];
 	int fd;
@@ -41,19 +41,25 @@ struct fixture {
 
 static void *_fix_init(void)
 {
+        uint8_t b = 123;
+        unsigned i;
         struct fixture *f = malloc(sizeof(*f));
 
         T_ASSERT(f);
         f->e = create_async_io_engine();
         T_ASSERT(f->e);
-	if (posix_memalign(&f->data, 4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
+	if (posix_memalign((void **) &f->data, 4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
         	test_fail("posix_memalign failed");
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
 	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
 	T_ASSERT(f->fd >= 0);
 
-	memset(f->data, 0, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+	for (i = 0; i < SECTOR_SIZE * BLOCK_SIZE_SECTORS; i++) {
+        	f->data[i] = b;
+        	b = ((b << 5) + b) + i;
+	}
+
 	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
 	lseek(f->fd, 0, SEEK_SET);
         return f;
@@ -97,6 +103,8 @@ static void _test_read(void *fixture)
 {
 	struct fixture *f = fixture;
 
+	uint8_t b = 123;
+	unsigned i;
 	struct io io;
 
 	_io_init(&io);
@@ -104,6 +112,11 @@ static void _test_read(void *fixture)
 	T_ASSERT(f->e->wait(f->e, _complete_io));
 	T_ASSERT(io.completed);
 	T_ASSERT(!io.error);
+	
+	for (i = 0; i < SECTOR_SIZE * BLOCK_SIZE_SECTORS; i++) {
+        	T_ASSERT_EQUAL(f->data[i], b);
+        	b = ((b << 5) + b) + i;
+	}
 }
 
 static void _test_write(void *fixture)


