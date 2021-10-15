From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:22 +0000 (GMT)
Subject: main - cov: ignore close result
Message-ID: <20211015214222.CE0C53858416@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7b5f490c53368b9591fe8c5561de4371207f882
Commit:        e7b5f490c53368b9591fe8c5561de4371207f882
Parent:        6668d6409aa841839b8eefc2a49d004b0c29397a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 14:42:34 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:40:29 2021 +0200

cov: ignore close result

---
 test/unit/bcache_utils_t.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index daed0ce39..f05292474 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -86,7 +86,7 @@ static void *_fix_init(struct io_engine *engine)
 	}
 
 	if (!_runs_is_tmpfs) {
-		close(f->fd);
+		(void) close(f->fd);
 		// reopen with O_DIRECT
 		f->fd = open(f->fname, O_RDWR | O_DIRECT);
 		T_ASSERT(f->fd >= 0);


