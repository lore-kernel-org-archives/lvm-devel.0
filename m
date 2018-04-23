From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:03 -0400
Subject: master - [device/bcache] rename a unit test
Message-ID: <201804231347.w3NDl3UO031164@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b03e55a5130ffdf6be9188b227c59e6793dc0dfc
Commit:        b03e55a5130ffdf6be9188b227c59e6793dc0dfc
Parent:        0d0fab3d2ddb0c0f16c01e569e3f1f218701592e
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Feb 2 15:38:46 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] rename a unit test

---
 test/unit/bcache_t.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 5532c92..3db9cc7 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -175,7 +175,7 @@ static void test_prefetch_works(void)
 }
 
 #define NR_FILES 4
-static void test_multiple_files(void)
+static void test_read_multiple_files(void)
 {
 	unsigned i;
 	int fd[NR_FILES];
@@ -226,6 +226,6 @@ CU_TestInfo bcache_list[] = {
 	{ (char*)"block size must be multiple of page size", test_block_size_must_be_multiple_of_page_size },
 	{ (char*)"reads work", test_reads_work },
 	{ (char*)"prefetch works", test_prefetch_works },
-	{ (char*)"multiple files", test_multiple_files },
+	{ (char*)"read multiple files", test_read_multiple_files },
 	CU_TEST_INFO_NULL
 };


