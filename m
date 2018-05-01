From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 09:18:02 -0400
Subject: master - unit-test/bcache_t: test was using too large a block size
Message-ID: <201805011318.w41DI2WN001250@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ea862bdfc036f6e5ce08ba01eb706d1d10638cd
Commit:        3ea862bdfc036f6e5ce08ba01eb706d1d10638cd
Parent:        bfc61a9543f3fc669d265d9b6e384cef0ab78ef2
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 14:17:12 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 14:17:12 2018 +0100

unit-test/bcache_t: test was using too large a block size

---
 test/unit/bcache_t.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index bb1db29..b0e2dd2 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -412,7 +412,7 @@ static void test_block_size_must_be_multiple_of_page_size(void *fixture)
 	for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++)
 		bad_create(_bad_examples[i], 16);
 
-	for (i = 1; i < 1000; i++)
+	for (i = 1; i < 100; i++)
 		good_create(i * 8, 16);
 }
 


