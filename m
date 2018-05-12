From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:54 -0400
Subject: master - tests: detect running bcache test on tmpfs
Message-ID: <201805121626.w4CGQs99008396@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa8d0b57660b9788d75b554eaeadb9725f522011
Commit:        fa8d0b57660b9788d75b554eaeadb9725f522011
Parent:        79b296139947c43aaf9cc70ae8caf66c1f89f4a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 11 23:02:10 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

tests: detect running bcache test on tmpfs

When test happens to run in tmpfs, it cannot use O_DIRECT (unsupported
with tmpfs).

CHECKME: unsure if detection of tmpfs is 'valid' but kind of works and
is very simple.
---
 test/unit/bcache_utils_t.c |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 4f15591..e5e66d5 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -14,6 +14,10 @@
 
 #define _GNU_SOURCE
 
+#include "bcache.h"
+#include "framework.h"
+#include "units.h"
+
 #include <errno.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -21,10 +25,7 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
-
-#include "bcache.h"
-#include "framework.h"
-#include "units.h"
+#include <sys/statvfs.h>
 
 //----------------------------------------------------------------
 
@@ -53,6 +54,16 @@ static void *_fix_init(struct io_engine *engine)
         uint8_t buffer[T_BLOCK_SIZE];
         struct fixture *f = malloc(sizeof(*f));
         unsigned b, i;
+	struct statvfs fsdata;
+	static int _runs_is_tmpfs = -1;
+
+	if (_runs_is_tmpfs == -1) {
+		// With testing in tmpfs directory O_DIRECT cannot be used
+		// tmpfs has  f_fsid == 0  (unsure if this is best guess)
+		_runs_is_tmpfs = (statvfs(".", &fsdata) == 0 && !fsdata.f_fsid) ? 1 : 0;
+		if (_runs_is_tmpfs)
+			printf("  Running test in tmpfs, *NOT* using O_DIRECT\n");
+	}
 
         T_ASSERT(f);
 
@@ -65,11 +76,13 @@ static void *_fix_init(struct io_engine *engine)
                 	buffer[i] = _pattern_at(INIT_PATTERN, byte(b, i));
 		T_ASSERT(write(f->fd, buffer, T_BLOCK_SIZE) > 0);
 	}
-	close(f->fd);
 
-	// reopen with O_DIRECT
-	f->fd = open(f->fname, O_RDWR | O_DIRECT);
-	T_ASSERT(f->fd >= 0);
+	if (!_runs_is_tmpfs) {
+		close(f->fd);
+		// reopen with O_DIRECT
+		f->fd = open(f->fname, O_RDWR | O_DIRECT);
+		T_ASSERT(f->fd >= 0);
+	}
 
 	f->cache = bcache_create(T_BLOCK_SIZE / 512, NR_BLOCKS, engine);
 	T_ASSERT(f->cache);


