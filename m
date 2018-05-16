From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 16 May 2018 05:26:20 -0400
Subject: master - unit-tests: remove a couple of debug printfs
Message-ID: <201805160926.w4G9QKRi028956@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c852c75c3b3e719d57d3410bf0c2a5e61d67f4e
Commit:        7c852c75c3b3e719d57d3410bf0c2a5e61d67f4e
Parent:        e296f784c974eaa76deb3af58baf79a70095b308
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 16 10:25:30 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 16 10:25:30 2018 +0100

unit-tests: remove a couple of debug printfs

---
 test/unit/bcache_t.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 803a088..925b95d 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -845,11 +845,9 @@ static void test_concurrent_reads_after_invalidate(void *context)
 	unsigned i, nr_cache_blocks = 16;
 
 	_cycle(f, nr_cache_blocks);
-	fprintf(stderr, "cycle 1 complete\n");
 	for (i = 0; i < nr_cache_blocks; i++)
         	bcache_invalidate_fd(f->cache, i);
         _cycle(f, nr_cache_blocks);
-	fprintf(stderr, "cycle 2 complete\n");
 }
 
 /*----------------------------------------------------------------


