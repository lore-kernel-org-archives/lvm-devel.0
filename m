From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 09:33:51 -0400
Subject: master - bcache: knock out err param.
Message-ID: <201805101333.w4ADXpql015231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67b80e2d9d9b437f18f909c9c09e4b286337b031
Commit:        67b80e2d9d9b437f18f909c9c09e4b286337b031
Parent:        2b96bb403c3aabe7c1593a87c07e774d9256e790
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 10 13:26:08 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 10 13:26:08 2018 +0100

bcache: knock out err param.

Dave used this for debugging.  Not needed in general.
---
 lib/device/bcache-utils.c  |   14 ++++----
 lib/device/bcache.c        |    6 +---
 lib/device/bcache.h        |    9 +-----
 lib/label/label.c          |    2 +-
 test/unit/bcache_t.c       |   68 ++++++++++++++++---------------------------
 test/unit/bcache_utils_t.c |    6 +--
 6 files changed, 37 insertions(+), 68 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index 1487732..a533a66 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -64,7 +64,7 @@ bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
 	byte_range_to_block_range(cache, start, len, &bb, &be);
 
 	for (; bb != be; bb++) {
-        	if (!bcache_get(cache, fd, bb, 0, &b, NULL))
+        	if (!bcache_get(cache, fd, bb, 0, &b))
 			return false;
 
 		size_t blen = _min(block_size - block_offset, len);
@@ -146,7 +146,7 @@ static bool _write_partial(struct updater *u, int fd, block_address bb,
 {
 	struct block *b;
 
-	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b, NULL))
+	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b))
 		return false;
 
 	memcpy(((unsigned char *) b->data) + offset, u->data, len);
@@ -164,7 +164,7 @@ static bool _write_whole(struct updater *u, int fd, block_address bb, block_addr
 	for (; bb != be; bb++) {
         	// We don't need to read the block since we are overwriting
         	// it completely.
-		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b, NULL))
+		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b))
         		return false;
 		memcpy(b->data, u->data, block_size);
 		u->data = ((unsigned char *) u->data) + block_size;
@@ -192,7 +192,7 @@ static bool _zero_partial(struct updater *u, int fd, block_address bb, uint64_t
 {
 	struct block *b;
 
-	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b, NULL))
+	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b))
 		return false;
 
 	memset(((unsigned char *) b->data) + offset, 0, len);
@@ -206,7 +206,7 @@ static bool _zero_whole(struct updater *u, int fd, block_address bb, block_addre
 	struct block *b;
 
 	for (; bb != be; bb++) {
-		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b, NULL))
+		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b))
         		return false;
         	bcache_put(b);
 	}
@@ -233,7 +233,7 @@ static bool _set_partial(struct updater *u, int fd, block_address bb, uint64_t o
 	struct block *b;
 	uint8_t val = *((uint8_t *) u->data);
 
-	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b, NULL))
+	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b))
 		return false;
 
 	memset(((unsigned char *) b->data) + offset, val, len);
@@ -249,7 +249,7 @@ static bool _set_whole(struct updater *u, int fd, block_address bb, block_addres
         uint64_t len = bcache_block_sectors(u->cache) * 512;
 
 	for (; bb != be; bb++) {
-		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b, NULL))
+		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b))
         		return false;
         	memset((unsigned char *) b->data, val, len);
         	bcache_put(b);
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 6ea0349..62e99bd 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -901,14 +901,13 @@ static void _recycle_block(struct bcache *cache, struct block *b)
 }
 
 bool bcache_get(struct bcache *cache, int fd, block_address i,
-	        unsigned flags, struct block **result, int *error)
+	        unsigned flags, struct block **result)
 {
 	struct block *b;
 
 	b = _lookup_or_read_block(cache, fd, i, flags);
 	if (b) {
 		if (b->error) {
-			*error = b->error;
 			if (b->io_dir == DIR_READ) {
 				// Now we know the read failed we can just forget
 				// about this block, since there's no dirty data to
@@ -928,9 +927,6 @@ bool bcache_get(struct bcache *cache, int fd, block_address i,
 
 	*result = NULL;
 
-	if (error)
-		*error = -BCACHE_NO_BLOCK;
-
 	log_error("bcache failed to get block %u fd %d", (uint32_t) i, fd);
 	return false;
 }
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 599b4c6..3084fa7 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -29,13 +29,6 @@
 
 /*----------------------------------------------------------------*/
 
-/*
- * bcache-specific error numbers
- * These supplement standard -EXXX error numbers and
- * should not overlap.
- */
-#define BCACHE_NO_BLOCK 201
-
 enum dir {
 	DIR_READ,
 	DIR_WRITE
@@ -126,7 +119,7 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index);
  * Returns true on success.
  */
 bool bcache_get(struct bcache *cache, int fd, block_address index,
-	        unsigned flags, struct block **result, int *error);
+	        unsigned flags, struct block **result);
 void bcache_put(struct block *b);
 
 /*
diff --git a/lib/label/label.c b/lib/label/label.c
index 8b60780..dcd92ce 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -521,7 +521,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 		scan_failed = 0;
 		is_lvm_device = 0;
 
-		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb, &error)) {
+		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
 			log_debug_devs("Scan failed to read %s error %d.", dev_name(devl->dev), error);
 			scan_failed = 1;
 			scan_read_errors++;
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index b0e2dd2..e1c0e85 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -418,7 +418,6 @@ static void test_block_size_must_be_multiple_of_page_size(void *fixture)
 
 static void test_get_triggers_read(void *context)
 {
-        int err;
 	struct fixture *f = context;
 
 	int fd = 17;   // arbitrary key
@@ -426,12 +425,12 @@ static void test_get_triggers_read(void *context)
 
 	_expect_read(f->me, fd, 0);
 	_expect(f->me, E_WAIT);
-	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
+	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
 	bcache_put(b);
 
 	_expect_read(f->me, fd, 1);
 	_expect(f->me, E_WAIT);
-	T_ASSERT(bcache_get(f->cache, fd, 1, GF_DIRTY, &b, &err));
+	T_ASSERT(bcache_get(f->cache, fd, 1, GF_DIRTY, &b));
 	_expect_write(f->me, fd, 1);
 	_expect(f->me, E_WAIT);
 	bcache_put(b);
@@ -439,7 +438,6 @@ static void test_get_triggers_read(void *context)
 
 static void test_repeated_reads_are_cached(void *context)
 {
-        int err;
 	struct fixture *f = context;
 
 	int fd = 17;   // arbitrary key
@@ -449,7 +447,7 @@ static void test_repeated_reads_are_cached(void *context)
 	_expect_read(f->me, fd, 0);
 	_expect(f->me, E_WAIT);
 	for (i = 0; i < 100; i++) {
-		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
+		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -458,7 +456,6 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 {
 	struct fixture *f = context;
 
-	int err;
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	const unsigned nr_cache_blocks = 16;
@@ -470,14 +467,14 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 	for (i = 0; i < nr_cache_blocks; i++) {
 		_expect_read(me, fd, i);
 		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		bcache_put(b);
 	}
 
 	// Not enough cache blocks to hold this one
 	_expect_read(me, fd, nr_cache_blocks);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
 	bcache_put(b);
 
 	// Now if we run through we should find one block has been
@@ -486,7 +483,7 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 	_expect_read_any(me);
 	_expect(me, E_WAIT);
 	for (i = nr_cache_blocks; i; i--) {
-		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b, &err));
+		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -498,7 +495,6 @@ static void test_prefetch_issues_a_read(void *context)
 	struct bcache *cache = f->cache;
 	const unsigned nr_cache_blocks = 16;
 
-	int err;
 	int fd = 17;   // arbitrary key
 	unsigned i;
 	struct block *b;
@@ -512,7 +508,7 @@ static void test_prefetch_issues_a_read(void *context)
 
 	for (i = 0; i < nr_cache_blocks; i++) {
 		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -545,14 +541,13 @@ static void test_dirty_data_gets_written_back(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 
-	int err;
 	int fd = 17;   // arbitrary key
 	struct block *b;
 
 	// Expect the read
 	_expect_read(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
 	bcache_put(b);
 
 	// Expect the write
@@ -566,12 +561,11 @@ static void test_zeroed_data_counts_as_dirty(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 
-	int err;
 	int fd = 17;   // arbitrary key
 	struct block *b;
 
 	// No read
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
 	bcache_put(b);
 
 	// Expect the write
@@ -586,18 +580,17 @@ static void test_flush_waits_for_all_dirty(void *context)
 	struct bcache *cache = f->cache;
 
 	const unsigned count = 16;
-	int err;
 	int fd = 17;   // arbitrary key
 	unsigned i;
 	struct block *b;
 
 	for (i = 0; i < count; i++) {
 		if (i % 2) {
-			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b, &err));
+			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
 		} else {
 			_expect_read(me, fd, i);
 			_expect(me, E_WAIT);
-			T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
 		}
 		bcache_put(b);
 	}
@@ -620,7 +613,6 @@ static void test_multiple_files(void *context)
 {
 	static int _fds[] = {1, 128, 345, 678, 890};
 
-	int err;
 	struct fixture *f = context;
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
@@ -631,7 +623,7 @@ static void test_multiple_files(void *context)
 		_expect_read(me, _fds[i], 0);
 		_expect(me, E_WAIT);
 
-		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b, &err));
+		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -642,10 +634,9 @@ static void test_read_bad_issue(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int err;
 
 	_expect_read_bad_issue(me, 17, 0);
-	T_ASSERT(!bcache_get(cache, 17, 0, 0, &b, &err));
+	T_ASSERT(!bcache_get(cache, 17, 0, 0, &b));
 }
 
 static void test_read_bad_issue_intermittent(void *context)
@@ -655,14 +646,13 @@ static void test_read_bad_issue_intermittent(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
 	_expect_read_bad_issue(me, fd, 0);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
 
 	_expect_read(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
 	bcache_put(b);
 }
 
@@ -673,11 +663,10 @@ static void test_read_bad_wait(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
 	_expect_read_bad_wait(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
 }
 
 static void test_read_bad_wait_intermittent(void *context)
@@ -687,15 +676,14 @@ static void test_read_bad_wait_intermittent(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
 	_expect_read_bad_wait(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
 
 	_expect_read(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
 	bcache_put(b);
 }
 
@@ -706,9 +694,8 @@ static void test_write_bad_issue_stops_flush(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
 	_expect_write_bad_issue(me, fd, 0);
 	bcache_put(b);
 	T_ASSERT(!bcache_flush(cache));
@@ -726,9 +713,8 @@ static void test_write_bad_io_stops_flush(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
 	_expect_write_bad_wait(me, fd, 0);
 	_expect(me, E_WAIT);
 	bcache_put(b);
@@ -756,11 +742,10 @@ static void test_invalidate_present(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
 	_expect_read(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
 	bcache_put(b);
 
 	T_ASSERT(bcache_invalidate(cache, fd, 0));
@@ -773,10 +758,9 @@ static void test_invalidate_after_read_error(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
 	_expect_read_bad_issue(me, fd, 0);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
 	T_ASSERT(bcache_invalidate(cache, fd, 0));
 }
 
@@ -787,9 +771,8 @@ static void test_invalidate_after_write_error(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
 	bcache_put(b);
 
 	// invalidate should fail if the write fails
@@ -805,7 +788,7 @@ static void test_invalidate_after_write_error(void *context)
 	// a read is not required to get the block
 	_expect_read(me, fd, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
 	bcache_put(b);
 }
 
@@ -817,9 +800,8 @@ static void test_invalidate_held_block(void *context)
 	struct bcache *cache = f->cache;
 	struct block *b;
 	int fd = 17;
-	int err;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
 
 	T_ASSERT(!bcache_invalidate(cache, fd, 0));
 
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 255caff..b784c6f 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -109,7 +109,6 @@ static uint64_t _min(uint64_t lhs, uint64_t rhs)
 
 static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t pat)
 {
-        int err;
 	struct block *b;
 	block_address bb = byte_b / T_BLOCK_SIZE;
 	block_address be = (byte_e + T_BLOCK_SIZE - 1) / T_BLOCK_SIZE;
@@ -128,7 +127,7 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
 
 	// Verify again, driving bcache directly
 	for (; bb != be; bb++) {
-        	T_ASSERT(bcache_get(f->cache, f->fd, bb, 0, &b, &err));
+        	T_ASSERT(bcache_get(f->cache, f->fd, bb, 0, &b));
 
 		blen = _min(T_BLOCK_SIZE - offset, len);
         	_verify_bytes(b, bb * T_BLOCK_SIZE, offset, blen, pat);
@@ -142,7 +141,6 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
 
 static void _verify_set(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t val)
 {
-        int err;
         unsigned i;
 	struct block *b;
 	block_address bb = byte_b / T_BLOCK_SIZE;
@@ -151,7 +149,7 @@ static void _verify_set(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uin
 	uint64_t blen, len = byte_e - byte_b;
 
 	for (; bb != be; bb++) {
-        	T_ASSERT(bcache_get(f->cache, f->fd, bb, 0, &b, &err));
+        	T_ASSERT(bcache_get(f->cache, f->fd, bb, 0, &b));
 
 		blen = _min(T_BLOCK_SIZE - offset, len);
 		for (i = 0; i < blen; i++)


