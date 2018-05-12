From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:24 -0400
Subject: master - tests: swith to mkstemp
Message-ID: <201805122139.w4CLdO84005466@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a5edc1f12ddad72e0c34dddfecbb46cbfdb192f
Commit:        0a5edc1f12ddad72e0c34dddfecbb46cbfdb192f
Parent:        9640320aea74e7cef0bde64c9be6e3471a85746e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 23:23:54 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 23:23:54 2018 +0200

tests: swith to mkstemp

As mkostemp is only on newer systems, switch to more old version
which effectively does exactly the same thing for given list of
open flags.
---
 test/unit/bcache_utils_t.c |    2 +-
 test/unit/io_engine_t.c    |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index e5e66d5..9ddc194 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -68,7 +68,7 @@ static void *_fix_init(struct io_engine *engine)
         T_ASSERT(f);
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
-	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
+	f->fd = mkstemp(f->fname);
 	T_ASSERT(f->fd >= 0);
 
 	for (b = 0; b < NR_BLOCKS; b++) {
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 01f659e..5efd4e4 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -89,13 +89,14 @@ static void *_fix_init(void)
         	test_fail("posix_memalign failed");
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
-	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
+	f->fd = mkstemp(f->fname);
 	T_ASSERT(f->fd >= 0);
 
 	_fill_buffer(f->data, 123, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
 
-	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
-	lseek(f->fd, 0, SEEK_SET);
+	T_ASSERT(write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS) > 0);
+	T_ASSERT(lseek(f->fd, 0, SEEK_SET) != -1);
+
         return f;
 }
 


