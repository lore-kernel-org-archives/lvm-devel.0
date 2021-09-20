From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:14 +0000 (GMT)
Subject: main - cov: test for fixture being NULL pointer
Message-ID: <20210920133014.601D43858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9721f3e0ff6fd841b62b6bcccceee2ebb914e96b
Commit:        9721f3e0ff6fd841b62b6bcccceee2ebb914e96b
Parent:        3f946bfce72952bc9e775ec41278dd33afbc9eb1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:28:07 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: test for fixture being NULL pointer

Explicit check for teoretical NULL pointer passed as fixture.
---
 test/unit/bcache_t.c       |  8 +++++---
 test/unit/bcache_utils_t.c | 12 +++++++-----
 test/unit/bitset_t.c       |  3 ++-
 test/unit/io_engine_t.c    | 16 +++++++++-------
 test/unit/radix_tree_t.c   |  3 ++-
 5 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 3231b76e0..2668d3ff6 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -349,10 +349,12 @@ static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_bloc
 
 static void _fixture_exit(struct fixture *f)
 {
-	_expect(f->me, E_DESTROY);
-	bcache_destroy(f->cache);
+	if (f) {
+		_expect(f->me, E_DESTROY);
+		bcache_destroy(f->cache);
 
-	free(f);
+		free(f);
+	}
 }
 
 static void *_small_fixture_init(void)
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index df2826977..48dab142e 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -109,11 +109,13 @@ static void _fix_exit(void *fixture)
 {
         struct fixture *f = fixture;
 
-	bcache_destroy(f->cache);
-	close(f->fd);
-	bcache_clear_fd(f->di);
-	unlink(f->fname);
-        free(f);
+	if (f) {
+		bcache_destroy(f->cache);
+		(void) close(f->fd);
+		bcache_clear_fd(f->di);
+		(void) unlink(f->fname);
+		free(f);
+	}
 }
 
 //----------------------------------------------------------------
diff --git a/test/unit/bitset_t.c b/test/unit/bitset_t.c
index 4ee4f1c22..1e74e12d2 100644
--- a/test/unit/bitset_t.c
+++ b/test/unit/bitset_t.c
@@ -31,7 +31,8 @@ static void *_mem_init(void) {
 
 static void _mem_exit(void *mem)
 {
-	dm_pool_destroy(mem);
+	if (mem)
+		dm_pool_destroy(mem);
 }
 
 static void test_get_next(void *fixture)
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 89fa4b787..d45d8ffa7 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -104,13 +104,15 @@ static void _fix_exit(void *fixture)
 {
         struct fixture *f = fixture;
 
-	close(f->fd);
-	bcache_clear_fd(f->di);
-	unlink(f->fname);
-        free(f->data);
-        if (f->e)
-                f->e->destroy(f->e);
-        free(f);
+	if (f) {
+		(void) close(f->fd);
+		bcache_clear_fd(f->di);
+		(void) unlink(f->fname);
+		free(f->data);
+		if (f->e)
+			f->e->destroy(f->e);
+		free(f);
+	}
 }
 
 static void _test_create(void *fixture)
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 54bc40670..88c8bd5a7 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -28,7 +28,8 @@ static void *rt_init(void)
 
 static void rt_exit(void *fixture)
 {
-	radix_tree_destroy(fixture);
+	if (fixture)
+		radix_tree_destroy(fixture);
 }
 
 static void test_create_destroy(void *fixture)


