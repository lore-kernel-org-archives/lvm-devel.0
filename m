From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 16 Jan 2020 10:34:56 -0500
Subject: stable-2.02 - [bcache] pass up the error from io_submit rather than using generic -EIO
Message-ID: <28176.120011610345301743@us-mta-145.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6370c20d392fb6228273695cd9f1a2ae43ff1e77
Commit:        6370c20d392fb6228273695cd9f1a2ae43ff1e77
Parent:        056eb0a8809aee3ca888aff4fe8e22bf8884a0cc
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 10:39:20 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jan 16 14:58:28 2020 +0000

[bcache] pass up the error from io_submit rather than using generic -EIO

Author: Heming Zhao
---
 lib/device/bcache.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 72cc59929..56e3db33f 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -246,6 +246,10 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	if (r < 0) {
 		_cb_free(e->cbs, cb);
+	       ((struct block *) context)->error = r;
+	       log_warn("io_submit <%c> off %llu bytes %llu return %d:%s",
+	                (d == DIR_READ) ? 'R' : 'W', (long long unsigned)offset,
+                        (long long unsigned) nbytes, r, strerror(-r));
 		return false;
 	}
 
@@ -784,8 +788,7 @@ static void _issue_low_level(struct block *b, enum dir d)
 	dm_list_move(&cache->io_pending, &b->list);
 
 	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
-		/* FIXME: if io_submit() set an errno, return that instead of EIO? */
-		_complete_io(b, -EIO);
+		_complete_io(b, b->error);
 		return;
 	}
 }



