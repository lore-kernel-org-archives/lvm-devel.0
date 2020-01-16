From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 16 Jan 2020 10:34:57 -0500
Subject: stable-2.02 - [bcache] add unit test
Message-ID: <69466.120011610345300669@us-mta-93.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=056eb0a8809aee3ca888aff4fe8e22bf8884a0cc
Commit:        056eb0a8809aee3ca888aff4fe8e22bf8884a0cc
Parent:        babde3da5530e4bbda5fb474fb5ea32a55adf16f
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 10:33:31 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jan 16 14:58:12 2020 +0000

[bcache] add unit test

abort-forces-read
---
 test/unit/bcache_t.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 668d24d77..2a8f931e4 100644
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



