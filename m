From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 11:56:03 -0400
Subject: master - unit-test/io_engine_t: use posix_memalign() rather than aligned_alloc()
Message-ID: <201804301556.w3UFu3sO030112@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef79d639fe245f93202df00381b2c87a05917374
Commit:        ef79d639fe245f93202df00381b2c87a05917374
Parent:        cca815d240bb850c25603a12aedd65f377a17776
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 16:55:19 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 16:55:19 2018 +0100

unit-test/io_engine_t: use posix_memalign() rather than aligned_alloc()

Not present on older systems.
---
 test/unit/io_engine_t.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 6219d79..57fdbda 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -46,8 +46,8 @@ static void *_fix_init(void)
         T_ASSERT(f);
         f->e = create_async_io_engine();
         T_ASSERT(f->e);
-        f->data = aligned_alloc(4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
-        T_ASSERT(f->data);
+	if (posix_memalign(&f->data, 4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS))
+        	test_fail("posix_memalign failed");
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
 	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);


