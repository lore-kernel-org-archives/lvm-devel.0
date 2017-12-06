From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Dec 2017 11:49:47 -0500
Subject: master - lvmlockd: clear coverity complaint
Message-ID: <201712061649.vB6GnlNS027225@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54154dc6f11ae869228cf9f36dc5ae919e861caa
Commit:        54154dc6f11ae869228cf9f36dc5ae919e861caa
Parent:        0f0f6978e76f2ee55da51b378d951f6e81d7e32d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 6 10:48:32 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 6 10:49:31 2017 -0600

lvmlockd: clear coverity complaint

---
 lib/locking/lvmlockd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index eb7076c..0365797 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2163,7 +2163,8 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 
 	} else if (lv_is_thin_pool_metadata(lv)) {
 		struct lv_segment *pool_seg = get_only_segment_using_this_lv(lv);
-		pool_lv = pool_seg->lv;
+		if (pool_seg)
+			pool_lv = pool_seg->lv;
 
 	} else {
 		/* This should not happen AFAIK. */


