From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 Oct 2019 06:42:55 -0400
Subject: master - [bcache] pass up the error from io_submit rather than using generic -EIO
Message-ID: <201910291042.x9TAgtZw030340@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b3c39e402b966043a65ae649797defb6db597fc
Commit:        2b3c39e402b966043a65ae649797defb6db597fc
Parent:        5fdebf9bbf68a53b9d2153dbd8bf27a36e0ef3cd
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 10:39:20 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue Oct 29 10:39:20 2019 +0000

[bcache] pass up the error from io_submit rather than using generic -EIO

Author: Heming Zhao
---
 lib/device/bcache.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index b0edf28..1249d6e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -293,6 +293,10 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	if (r < 0) {
 		_cb_free(e->cbs, cb);
+	       ((struct block *) context)->error = r;
+	       log_warn("io_submit <%c> off %llu bytes %llu return %d:%s",
+	                (d == DIR_READ) ? 'R' : 'W', (long long unsigned)offset,
+                        (long long unsigned) nbytes, r, strerror(-r));
 		return false;
 	}
 
@@ -869,8 +873,7 @@ static void _issue_low_level(struct block *b, enum dir d)
 	dm_list_move(&cache->io_pending, &b->list);
 
 	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
-		/* FIXME: if io_submit() set an errno, return that instead of EIO? */
-		_complete_io(b, -EIO);
+		_complete_io(b, b->error);
 		return;
 	}
 }


