From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 05:50:08 -0400
Subject: master - unit-test/bcache_t: fixup a test.
Message-ID: <201805010950.w419o85P002601@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6459757af0f255fe6cc89a05b614e7512ab1bca
Commit:        f6459757af0f255fe6cc89a05b614e7512ab1bca
Parent:        39f24a169c7cdec5e927a20aacb774e88407d31a
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 09:17:55 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 09:17:55 2018 +0100

unit-test/bcache_t: fixup a test.

Problem found with valgrind.
---
 test/unit/bcache_t.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index d06d5fe..ce159cd 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -100,6 +100,16 @@ static void _expect_read(struct mock_engine *e, int fd, block_address b)
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
+static void _expect_read_any(struct mock_engine *e)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = false;
+	mc->issue_r = true;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
 static void _expect_write(struct mock_engine *e, int fd, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
@@ -466,7 +476,7 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 	// Now if we run through we should find one block has been
 	// evicted.  We go backwards because the oldest is normally
 	// evicted first.
-	_expect(me, E_ISSUE);
+	_expect_read_any(me);
 	_expect(me, E_WAIT);
 	for (i = nr_cache_blocks; i; i--) {
 		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b, &err));


