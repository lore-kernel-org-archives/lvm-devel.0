From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:20 -0400
Subject: master - [device/bcache] another unit test
Message-ID: <201804231352.w3NDqKkq000707@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d0fab3d2ddb0c0f16c01e569e3f1f218701592e
Commit:        0d0fab3d2ddb0c0f16c01e569e3f1f218701592e
Parent:        19647d1cd44d029a8aa2f7e74dbdbd1f114a8c08
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Feb 2 14:35:11 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] another unit test

---
 test/unit/bcache_t.c |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index ef92721..5532c92 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -50,7 +50,7 @@ static int _prep_file(const char *path)
 	if (fd < 0)
 		return -1;
 
-	r = fallocate(fd, FALLOC_FL_ZERO_RANGE, 0, (16 * MEG) << SECTOR_SHIFT);
+	r = fallocate(fd, FALLOC_FL_ZERO_RANGE, 0, (1 * MEG) << SECTOR_SHIFT);
 	if (r) {
 		close(fd);
 		return -1;
@@ -174,6 +174,51 @@ static void test_prefetch_works(void)
 	test_exit();
 }
 
+#define NR_FILES 4
+static void test_multiple_files(void)
+{
+	unsigned i;
+	int fd[NR_FILES];
+	char buffer[128];
+
+
+	// FIXME: add fixtures.
+	test_init();
+	for (i = 0; i < NR_FILES; i++) {
+		snprintf(buffer, sizeof(buffer), "./test%u.bin", i);
+		unlink(buffer);
+		_prep_file(buffer);
+		fd[i] = open_file(buffer);
+		CU_ASSERT(fd[i] >= 0);
+	}
+
+	{
+		struct block *b;
+		struct bcache *cache = bcache_create(8, 16);
+
+		for (i = 0; i < 64; i++) {
+			if (!bcache_get(cache, fd[i % NR_FILES], i, 0, &b)) {
+				CU_ASSERT(false);
+			} else
+				bcache_put(b);
+		}
+
+		bcache_destroy(cache);
+	}
+
+	for (i = 0; i < NR_FILES; i++)
+		close(fd[i]);
+
+	test_exit();
+}
+
+// Tests to be written
+// Open multiple files and prove the blocks are coming from the correct file
+// show invalidate works
+// show invalidate_fd works
+// show writeback is working
+// check zeroing
+//
 CU_TestInfo bcache_list[] = {
 	{ (char*)"create", test_create },
 	{ (char*)"nr cache block must be positive", test_nr_cache_blocks_must_be_positive },
@@ -181,5 +226,6 @@ CU_TestInfo bcache_list[] = {
 	{ (char*)"block size must be multiple of page size", test_block_size_must_be_multiple_of_page_size },
 	{ (char*)"reads work", test_reads_work },
 	{ (char*)"prefetch works", test_prefetch_works },
+	{ (char*)"multiple files", test_multiple_files },
 	CU_TEST_INFO_NULL
 };


