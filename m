From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Dec 2017 15:32:38 -0500
Subject: master - lvmlockd: use pool lock for tmeta access
Message-ID: <201712052032.vB5KWc9j009807@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b910c34f09f45987fe56f0e90455a166e047144c
Commit:        b910c34f09f45987fe56f0e90455a166e047144c
Parent:        b9e419850086473d4309c5211852b0237020421d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 5 14:31:03 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 5 14:31:03 2017 -0600

lvmlockd: use pool lock for tmeta access

When a command is run on a named tmeta LV, use
the lock on the pool.
---
 lib/locking/lvmlockd.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d8bb818..eb7076c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2161,6 +2161,10 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 		/* FIXME: there should be a function to get pool lv from data lv. */
 		pool_lv = lv_parent(lv);
 
+	} else if (lv_is_thin_pool_metadata(lv)) {
+		struct lv_segment *pool_seg = get_only_segment_using_this_lv(lv);
+		pool_lv = pool_seg->lv;
+
 	} else {
 		/* This should not happen AFAIK. */
 		log_error("Lock on incorrect thin lv type %s/%s",


