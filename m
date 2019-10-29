From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 Oct 2019 06:42:53 -0400
Subject: master - [bcache] add unit test
Message-ID: <201910291042.x9TAgriG030330@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fdebf9bbf68a53b9d2153dbd8bf27a36e0ef3cd
Commit:        5fdebf9bbf68a53b9d2153dbd8bf27a36e0ef3cd
Parent:        6b0d969b2a85ba69046afa26af4d7bcddddbccd5
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 10:33:31 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue Oct 29 10:33:31 2019 +0000

[bcache] add unit test

abort-forces-read
---
 test/unit/bcache_t.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 668d24d..2a8f931 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -837,6 +837,29 @@ static void test_abort_single_block(void *context)
 	T_ASSERT(bcache_flush(cache));
 }
 
+static void test_abort_forces_reread(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
+	bcache_put(b);
+
+	bcache_abort_fd(cache, fd);
+	T_ASSERT(bcache_flush(cache));
+
+	// Check the block is re-read
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+	bcache_put(b);
+}
+
 static void test_abort_only_specific_fd(void *context)
 {
 	struct fixture *f = context;
@@ -960,6 +983,7 @@ static struct test_suite *_small_tests(void)
 
 	T("abort-with-no-blocks", "you can call abort, even if there are no blocks in the cache", test_abort_no_blocks);
 	T("abort-single-block", "single block get silently discarded", test_abort_single_block);
+	T("abort-forces-read", "if a block has been discarded then another read is necc.", test_abort_forces_reread);
 	T("abort-specific-fd", "abort doesn't effect other fds", test_abort_only_specific_fd);
 
 	T("concurrent-reads-after-invalidate", "prefetch should still issue concurrent reads after invalidate",


