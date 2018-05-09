From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 9 May 2018 06:08:03 -0400
Subject: master - unit-test/bcache-utils: Tweak zero tests
Message-ID: <201805091008.w49A83RY021530@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e1869b9231181cbd5c3cfa7dbbb3ef237ffa4a9
Commit:        2e1869b9231181cbd5c3cfa7dbbb3ef237ffa4a9
Parent:        bc50dc6e70453c98e45aaa845db2828e586f9370
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 9 10:50:31 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 9 10:50:31 2018 +0100

unit-test/bcache-utils: Tweak zero tests

---
 test/unit/bcache_utils_t.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 9c82068..d3ddb9a 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -102,11 +102,6 @@ static void _verify_bytes(struct block *b, uint64_t base,
 		T_ASSERT_EQUAL(((uint8_t *) b->data)[offset + i], _pattern_at(pat, base + offset + i));
 }
 
-static void _zero_bytes(struct block *b, uint64_t offset, uint64_t len)
-{
-	memset(((uint8_t *) b->data) + offset, 0, len);
-}
-
 static uint64_t _min(uint64_t lhs, uint64_t rhs)
 {
 	return rhs < lhs ? rhs : lhs;
@@ -179,30 +174,13 @@ static void _do_write(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8
         for (i = 0; i < len; i++)
 		buffer[i] = _pattern_at(pat, byte_b + i);
 
-        T_ASSERT(bcache_write_bytes(f->cache, f->fd, byte_b, i, buffer));
+        T_ASSERT(bcache_write_bytes(f->cache, f->fd, byte_b, byte_e - byte_b, buffer));
 	free(buffer);
 }
 
 static void _do_zero(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
 {
-        int err;
-	struct block *b;
-	block_address bb = byte_b / T_BLOCK_SIZE;
-	block_address be = (byte_e + T_BLOCK_SIZE - 1) / T_BLOCK_SIZE;
-	uint64_t offset = byte_b % T_BLOCK_SIZE;
-	uint64_t blen, len = byte_e - byte_b;
-
-	for (; bb != be; bb++) {
-        	T_ASSERT(bcache_get(f->cache, f->fd, bb, GF_DIRTY, &b, &err));
-
-		blen = _min(T_BLOCK_SIZE - offset, len);
-		_zero_bytes(b, offset, blen);
-
-        	offset = 0;
-        	len -= blen;
-
-        	bcache_put(b);
-	}
+	T_ASSERT(bcache_zero_bytes(f->cache, f->fd, byte_b, byte_e - byte_b));
 }
 
 static void _reopen(struct fixture *f)


