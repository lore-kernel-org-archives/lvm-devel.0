From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 9 May 2018 06:08:14 -0400
Subject: master - bcache-utils: bcache_set_bytes()
Message-ID: <201805091008.w49A8EIU021545@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c5c99afceb28f6ee464a705f1337866d29a9819
Commit:        1c5c99afceb28f6ee464a705f1337866d29a9819
Parent:        2e1869b9231181cbd5c3cfa7dbbb3ef237ffa4a9
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 9 11:05:29 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 9 11:05:29 2018 +0100

bcache-utils: bcache_set_bytes()

---
 lib/device/bcache-utils.c  |   43 ++++++++++++++++++++++++++++
 lib/device/bcache.h        |    1 +
 test/unit/bcache_utils_t.c |   66 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 108 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index 92e25c8..1487732 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -227,3 +227,46 @@ bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
 }
 
 //----------------------------------------------------------------
+
+static bool _set_partial(struct updater *u, int fd, block_address bb, uint64_t offset, size_t len)
+{
+	struct block *b;
+	uint8_t val = *((uint8_t *) u->data);
+
+	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b, NULL))
+		return false;
+
+	memset(((unsigned char *) b->data) + offset, val, len);
+	bcache_put(b);
+
+	return true;
+}
+
+static bool _set_whole(struct updater *u, int fd, block_address bb, block_address be)
+{
+	struct block *b;
+	uint8_t val = *((uint8_t *) u->data);
+        uint64_t len = bcache_block_sectors(u->cache) * 512;
+
+	for (; bb != be; bb++) {
+		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b, NULL))
+        		return false;
+        	memset((unsigned char *) b->data, val, len);
+        	bcache_put(b);
+	}
+
+	return true;
+}
+
+bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, uint8_t val)
+{
+        struct updater u;
+
+        u.cache = cache;
+        u.partial_fn = _set_partial;
+        u.whole_fn = _set_whole;
+        u.data = &val;
+
+	return _update_bytes(&u, fd, start, len);
+}
+
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index c07f012..599b4c6 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -162,6 +162,7 @@ void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t
 bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
 bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
 bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
+bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, uint8_t val);
 
 //----------------------------------------------------------------
 
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index d3ddb9a..255caff 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -140,7 +140,7 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
 	}
 }
 
-static void _verify_zeroes(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
+static void _verify_set(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t val)
 {
         int err;
         unsigned i;
@@ -155,7 +155,7 @@ static void _verify_zeroes(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
 
 		blen = _min(T_BLOCK_SIZE - offset, len);
 		for (i = 0; i < blen; i++)
-        		T_ASSERT(((uint8_t *) b->data)[offset + i] == 0);
+        		T_ASSERT(((uint8_t *) b->data)[offset + i] == val);
 
         	offset = 0;
         	len -= blen;
@@ -164,6 +164,11 @@ static void _verify_zeroes(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
 	}
 }
 
+static void _verify_zeroes(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
+{
+        _verify_set(f, byte_b, byte_e, 0);
+}
+
 static void _do_write(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t pat)
 {
         unsigned i;
@@ -183,6 +188,11 @@ static void _do_zero(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
 	T_ASSERT(bcache_zero_bytes(f->cache, f->fd, byte_b, byte_e - byte_b));
 }
 
+static void _do_set(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t val)
+{
+	T_ASSERT(bcache_set_bytes(f->cache, f->fd, byte_b, byte_e - byte_b, val));
+}
+
 static void _reopen(struct fixture *f)
 {
         struct io_engine *engine;
@@ -296,6 +306,51 @@ static void _test_zero_many_boundaries(void *fixture)
 
 //----------------------------------------------------------------
 
+static void _set_cycle(struct fixture *f, uint64_t b, uint64_t e)
+{
+	uint8_t val = random();
+
+	_verify(f, b, e, INIT_PATTERN);
+	_do_set(f, b, e, val); 
+	_reopen(f);
+	_verify(f, b < 128 ? 0 : b - 128, b, INIT_PATTERN);
+	_verify_set(f, b, e, val);
+	_verify(f, e, _min(e + 128, _max_byte()), INIT_PATTERN);
+}
+
+static void _test_set_first_block(void *fixture)
+{
+	_set_cycle(fixture, byte(0, 0), byte(0, T_BLOCK_SIZE));
+}
+
+static void _test_set_last_block(void *fixture)
+{
+        uint64_t last_block = NR_BLOCKS - 1;
+	_set_cycle(fixture, byte(last_block, 0), byte(last_block, T_BLOCK_SIZE)); 
+}
+
+static void _test_set_several_whole_blocks(void *fixture)
+{
+        _set_cycle(fixture, byte(5, 0), byte(10, 0));
+}
+
+static void _test_set_within_single_block(void *fixture)
+{
+        _set_cycle(fixture, byte(7, 3), byte(7, T_BLOCK_SIZE / 2));
+}
+
+static void _test_set_cross_one_boundary(void *fixture)
+{
+        _set_cycle(fixture, byte(13, 43), byte(14, 43));
+}
+
+static void _test_set_many_boundaries(void *fixture)
+{
+        _set_cycle(fixture, byte(13, 13), byte(23, 13));
+}
+
+//----------------------------------------------------------------
+
 #define T(path, desc, fn) register_test(ts, "/base/device/bcache/utils/" path, desc, fn)
 
 static struct test_suite *_tests(void)
@@ -320,6 +375,13 @@ static struct test_suite *_tests(void)
         T("zero-cross-one-boundary", "zero across one boundary", _test_zero_cross_one_boundary);
         T("zero-many-boundaries", "zero many boundaries", _test_zero_many_boundaries);
 
+        T("set-first-block", "set the first block", _test_set_first_block);
+        T("set-last-block", "set the last block", _test_set_last_block);
+        T("set-several-blocks", "set several whole blocks", _test_set_several_whole_blocks);
+        T("set-within-single-block", "set within single block", _test_set_within_single_block);
+        T("set-cross-one-boundary", "set across one boundary", _test_set_cross_one_boundary);
+        T("set-many-boundaries", "set many boundaries", _test_set_many_boundaries);
+
         return ts;
 }
 


