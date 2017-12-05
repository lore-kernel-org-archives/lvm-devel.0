From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Dec 2017 12:56:11 -0500
Subject: master - lvmlockd: avoid blocking in sanlock_convert
Message-ID: <201712051756.vB5HuBD5020231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd893348b415d4e604a7f9a503f17623d485e76e
Commit:        bd893348b415d4e604a7f9a503f17623d485e76e
Parent:        94632eb155a0a1814e69b1baa0516323cbbae648
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 29 14:59:11 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 5 11:53:03 2017 -0600

lvmlockd: avoid blocking in sanlock_convert

Use the same flag as sanlock_acquire() for the
same purpose.  sanlock_convert can block like
acquire when doing a sh to ex conversion.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 358c588..079e952 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1688,6 +1688,16 @@ int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 	if (daemon_test)
 		return 0;
 
+	/*
+	 * Don't block waiting for a failed lease to expire since it causes
+	 * sanlock_convert to block for a long time, which would prevent this
+	 * thread from processing other lock requests.
+	 *
+	 * FIXME: SANLK_CONVERT_OWNER_NOWAIT is the same as SANLK_ACQUIRE_OWNER_NOWAIT.
+	 * Change to use the CONVERT define when the latest sanlock version has it.
+	 */
+	flags |= SANLK_ACQUIRE_OWNER_NOWAIT;
+
 	rv = sanlock_convert(lms->sock, -1, flags, rs);
 	if (rv == -EAGAIN) {
 		/* FIXME: When could this happen?  Should something different be done? */


