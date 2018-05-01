From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 07:14:05 -0400
Subject: master - bcache: rewrite bcache_{write,zero}_bytes
Message-ID: <201805011114.w41BE5rV014258@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f564e78d98747266c7add85906309f773de42061
Commit:        f564e78d98747266c7add85906309f773de42061
Parent:        c863c9581dead8f41e30c66df38017bef2229a90
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 12:07:33 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 12:07:33 2018 +0100

bcache: rewrite bcache_{write,zero}_bytes

These are utility functions so should only use the public interface.

Also write_bytes was flushing, which will kill performance.
---
 lib/device/bcache.c     |   68 +++++++++++++++++++++++-----------------------
 test/unit/bcache_t.c    |    7 +++++
 test/unit/io_engine_t.c |    6 ++--
 3 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 0995ba9..2464e59 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1056,6 +1056,9 @@ static off_t _min(off_t lhs, off_t rhs)
 	return lhs;
 }
 
+// These functions are all utilities, they should only use the public
+// interface to bcache.
+// FIXME: there's common code that can be factored out of these 3
 bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
 {
 	struct block *b;
@@ -1070,7 +1073,7 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 
 	for (i = bb; i < be; i++) {
 		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
-			log_error("bcache_read failed to get block %u fd %d bb %u be %u",
+			log_error("bcache_read_bytes failed to get block %u fd %d bb %u be %u",
 				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
 			errors++;
 			continue;
@@ -1108,11 +1111,11 @@ bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, v
 		bcache_prefetch(cache, fd, i);
 
 	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
-			log_error("bcache_write failed to get block %u fd %d bb %u be %u",
+		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
+			log_error("bcache_write_bytes failed to get block %u fd %d bb %u be %u",
 				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
 			errors++;
-			break;
+			continue;
 		}
 
 		if (i == bb) {
@@ -1128,49 +1131,46 @@ bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, v
 			udata += blen;
 		}
 
-		_set_flags(b, BF_DIRTY);
-		_unlink_block(b);
-		_link_block(b);
-		_put_ref(b);
+		bcache_put(b);
 	}
 
-	if (!bcache_flush(cache))
-		errors++;
-
 	return errors ? false : true;
 }
 
-#define ZERO_BUF_LEN 4096
-
 bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len)
 {
-	char zerobuf[ZERO_BUF_LEN];
-	size_t plen;
-	size_t poff;
-
-	memset(zerobuf, 0, sizeof(zerobuf));
-
-	if (len <= ZERO_BUF_LEN)
-		return bcache_write_bytes(cache, fd, start, len, &zerobuf);
-
-	poff = 0;
-	plen = ZERO_BUF_LEN;
+	struct block *b;
+	block_address bb, be, i;
+	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
+	int errors = 0;
 
-	while (1) {
-		if (!bcache_write_bytes(cache, fd, start + poff, plen, &zerobuf))
-			return false;
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	for (i = bb; i < be; i++)
+		bcache_prefetch(cache, fd, i);
 
-		poff += plen;
-		len -= plen;
+	for (i = bb; i < be; i++) {
+		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
+			log_error("bcache_write_bytes failed to get block %u fd %d bb %u be %u",
+				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
+			errors++;
+			continue;
+		}
 
-		if (!len)
-			break;
+		if (i == bb) {
+			off_t block_offset = start % block_size;
+			size_t blen = _min(block_size - block_offset, len);
+			memset(((unsigned char *) b->data) + block_offset, 0, blen);
+			len -= blen;
+		} else {
+			size_t blen = _min(block_size, len);
+			memset(b->data, 0, blen);
+			len -= blen;
+		}
 
-		if (len < ZERO_BUF_LEN)
-			plen = len;
+		bcache_put(b);
 	}
 
-	return true;
+	return errors ? false : true;
 }
 
 
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index ecbe07b..85bb321 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -428,6 +428,13 @@ static void test_get_triggers_read(void *context)
 	_expect(f->me, E_WAIT);
 	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
 	bcache_put(b);
+
+	_expect_read(f->me, fd, 1);
+	_expect(f->me, E_WAIT);
+	T_ASSERT(bcache_get(f->cache, fd, 1, GF_DIRTY, &b, &err));
+	_expect_write(f->me, fd, 1);
+	_expect(f->me, E_WAIT);
+	bcache_put(b);
 }
 
 static void test_repeated_reads_are_cached(void *context)
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 822789a..01f659e 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -92,7 +92,7 @@ static void *_fix_init(void)
 	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
 	T_ASSERT(f->fd >= 0);
 
-	_fill_buffer(f->data, 123, sizeof(f->data));
+	_fill_buffer(f->data, 123, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
 
 	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
 	lseek(f->fd, 0, SEEK_SET);
@@ -198,8 +198,8 @@ static struct test_suite *_tests(void)
         }
 
         T("create-destroy", "simple create/destroy", _test_create);
-        T("create-read", "read sanity check", _test_read);
-        T("create-write", "write sanity check", _test_write);
+        T("read", "read sanity check", _test_read);
+        T("write", "write sanity check", _test_write);
         T("bcache-write-bytes", "test the utility fns", _test_write_bytes);
 
         return ts;


