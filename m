From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 Oct 2019 11:22:13 -0400
Subject: master - [bcache] reverse earlier patch.
Message-ID: <201910291522.x9TFMDb6018722@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e8296f4788d6a83863a268582280587ade2e26c
Commit:        7e8296f4788d6a83863a268582280587ade2e26c
Parent:        2b3c39e402b966043a65ae649797defb6db597fc
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 15:14:07 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue Oct 29 15:14:07 2019 +0000

[bcache] reverse earlier patch.

It broke some unit tests, for v. little benefit
---
 lib/device/bcache.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 1249d6e..b0edf28 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -293,10 +293,6 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	if (r < 0) {
 		_cb_free(e->cbs, cb);
-	       ((struct block *) context)->error = r;
-	       log_warn("io_submit <%c> off %llu bytes %llu return %d:%s",
-	                (d == DIR_READ) ? 'R' : 'W', (long long unsigned)offset,
-                        (long long unsigned) nbytes, r, strerror(-r));
 		return false;
 	}
 
@@ -873,7 +869,8 @@ static void _issue_low_level(struct block *b, enum dir d)
 	dm_list_move(&cache->io_pending, &b->list);
 
 	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
-		_complete_io(b, b->error);
+		/* FIXME: if io_submit() set an errno, return that instead of EIO? */
+		_complete_io(b, -EIO);
 		return;
 	}
 }


