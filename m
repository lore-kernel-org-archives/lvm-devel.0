From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 27 Apr 2018 04:16:16 -0400
Subject: master - [bcache] Add some unit tests for invalidate block.
Message-ID: <201804270816.w3R8GGLm030807@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a14b8a733b95ccb92fc8b907dc330bac474b712
Commit:        8a14b8a733b95ccb92fc8b907dc330bac474b712
Parent:        5b6e62dc1f3b27089179308fa2f7d004850d5a2c
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 27 09:12:57 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Apr 27 09:12:57 2018 +0100

[bcache] Add some unit tests for invalidate block.

Trying to identify dct's lockup.
---
 unit-test/bcache_t.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/unit-test/bcache_t.c b/unit-test/bcache_t.c
index 4fe913b..23498a8 100644
--- a/unit-test/bcache_t.c
+++ b/unit-test/bcache_t.c
@@ -723,6 +723,46 @@ static void test_write_bad_io_stops_flush(void *context)
 	T_ASSERT(bcache_flush(cache));
 }
 
+static void test_invalidate_not_present(void *context)
+{
+	struct fixture *f = context;
+	struct bcache *cache = f->cache;
+	int fd = 17;
+
+	bcache_invalidate(cache, fd, 0);
+}
+
+static void test_invalidate_present(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+
+	bcache_invalidate(cache, fd, 0);
+}
+
+static void test_invalidate_after_error(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_issue(me, fd, 0);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_invalidate(cache, fd, 0);
+}
+
 // Tests to be written
 // show invalidate works
 // show invalidate_fd works
@@ -759,6 +799,9 @@ static struct test_suite *_small_tests(void)
 	T("read-bad-io-intermittent", "failed io, followed by success", test_read_bad_wait_intermittent);
 	T("write-bad-issue-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_issue_stops_flush);
 	T("write-bad-io-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_io_stops_flush);
+	T("invalidate-not-present", "invalidate a block that isn't in the cache", test_invalidate_not_present);
+	T("invalidate-present", "invalidate a block that is in the cache", test_invalidate_present);
+	T("invalidate-error", "invalidate a block that errored", test_invalidate_after_error);
 
 	return ts;
 }


