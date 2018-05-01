From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 07:55:47 -0400
Subject: master - unit-test/bcache_t: Use a stripped down fixture for some tests
Message-ID: <201805011155.w41BtlGt019946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de042fa13ddaecc9b4512ceb4196b2a2345f1f90
Commit:        de042fa13ddaecc9b4512ceb4196b2a2345f1f90
Parent:        61153d90e55309cd6bca9c8d1a1e7a7421464663
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 12:54:57 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 12:54:57 2018 +0100

unit-test/bcache_t: Use a stripped down fixture for some tests

---
 test/unit/bcache_t.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 85bb321..bb1db29 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -834,9 +834,9 @@ static void test_invalidate_held_block(void *context)
  *--------------------------------------------------------------*/
 #define T(path, desc, fn) register_test(ts, "/base/device/bcache/" path, desc, fn)
 
-static struct test_suite *_small_tests(void)
+static struct test_suite *_tiny_tests(void)
 {
-	struct test_suite *ts = test_suite_create(_small_fixture_init, _small_fixture_exit);
+	struct test_suite *ts = test_suite_create(NULL, NULL);
 	if (!ts) {
 		fprintf(stderr, "out of memory\n");
 		exit(1);
@@ -846,6 +846,18 @@ static struct test_suite *_small_tests(void)
 	T("cache-blocks-positive", "nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive);
 	T("block-size-positive", "block size must be positive", test_block_size_must_be_positive);
 	T("block-size-multiple-page", "block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size);
+
+	return ts;
+}
+
+static struct test_suite *_small_tests(void)
+{
+	struct test_suite *ts = test_suite_create(_small_fixture_init, _small_fixture_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
 	T("get-reads", "bcache_get() triggers read", test_get_triggers_read);
 	T("reads-cached", "repeated reads are cached", test_repeated_reads_are_cached);
 	T("blocks-get-evicted", "block get evicted with many reads", test_block_gets_evicted_with_many_reads);
@@ -884,6 +896,7 @@ static struct test_suite *_large_tests(void)
 
 void bcache_tests(struct dm_list *all_tests)
 {
+        dm_list_add(all_tests, &_tiny_tests()->list);
 	dm_list_add(all_tests, &_small_tests()->list);
 	dm_list_add(all_tests, &_large_tests()->list);
 }


