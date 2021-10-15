From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 08:12:12 +0000 (GMT)
Subject: main - unit-test: better check for O_DIRECT
Message-ID: <20211015081212.D005B3857C75@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=037165300ea1f6d9c9f8587360792505b2f3988d
Commit:        037165300ea1f6d9c9f8587360792505b2f3988d
Parent:        52a52d556773cf57007932ed483d20d21bd53823
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 09:44:15 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 09:55:54 2021 +0200

unit-test: better check for O_DIRECT

Instead of guessing tmpfs usage, just directly try if we could
reopen file with O_DIRECT on the used filesystem.
---
 test/unit/bcache_utils_t.c | 36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 73b8902fb..daed0ce39 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -49,31 +49,39 @@ static uint64_t byte(block_address b, uint64_t offset)
 
 static void *_fix_init(struct io_engine *engine)
 {
-        uint8_t buffer[T_BLOCK_SIZE];
-        struct fixture *f = malloc(sizeof(*f));
-        unsigned b, i;
-	struct statvfs fsdata = { 0 };
+	uint8_t buffer[T_BLOCK_SIZE];
+	struct fixture *f = malloc(sizeof(*f));
+	unsigned b, i;
 	static int _runs_is_tmpfs = -1;
 
 	memset(buffer, 0, sizeof(buffer));
+	T_ASSERT(f);
+
 	if (_runs_is_tmpfs == -1) {
-		// With testing in tmpfs directory O_DIRECT cannot be used
-		// tmpfs has  f_fsid == 0  (unsure if this is best guess)
-		_runs_is_tmpfs = (statvfs(".", &fsdata) == 0 && !fsdata.f_fsid) ? 1 : 0;
-		if (_runs_is_tmpfs)
+		snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
+		/* coverity[secure_temp] don't care */
+		f->fd = mkstemp(f->fname);
+		T_ASSERT(f->fd >= 0);
+		(void) close(f->fd);
+		// test if we can reopen with O_DIRECT
+		if ((f->fd = open(f->fname, O_RDWR | O_DIRECT)) >= 0) {
+			_runs_is_tmpfs = 0;
+			(void) close(f->fd);
+		} else {
+			_runs_is_tmpfs = 1; // likely running on tmpfs
 			printf("  Running test in tmpfs, *NOT* using O_DIRECT\n");
+		}
+		(void) unlink(f->fname);
 	}
 
-        T_ASSERT(f);
-
-        snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
+	snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
 	/* coverity[secure_temp] don't care */
 	f->fd = mkstemp(f->fname);
 	T_ASSERT(f->fd >= 0);
 
 	for (b = 0; b < NR_BLOCKS; b++) {
-        	for (i = 0; i < sizeof(buffer); i++)
-                	buffer[i] = _pattern_at(INIT_PATTERN, byte(b, i));
+		for (i = 0; i < sizeof(buffer); i++)
+			buffer[i] = _pattern_at(INIT_PATTERN, byte(b, i));
 		T_ASSERT(write(f->fd, buffer, T_BLOCK_SIZE) > 0);
 	}
 
@@ -89,7 +97,7 @@ static void *_fix_init(struct io_engine *engine)
 
 	f->di = bcache_set_fd(f->fd);
 
-        return f;
+	return f;
 }
 
 static void *_async_init(void)


