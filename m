From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 Oct 2015 19:40:21 +0000 (UTC)
Subject: master - lvmlockd: use flag to avoid blocking in sanlock_acquire
Message-ID: <20151014194021.7936861025@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df34fcdafd20ac195e588a06c8fc5a904fa71669
Commit:        df34fcdafd20ac195e588a06c8fc5a904fa71669
Parent:        a6d1c8ac651ecdc6fbdfa20f892ba318c2dddeda
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 14 14:36:46 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 14 14:39:29 2015 -0500

lvmlockd: use flag to avoid blocking in sanlock_acquire

If a host failed while holding a sanlock lease,
sanlock_acquire will by default block and wait
for the lease to expire before returning.  We
want it to return with an error so we can retry
instead of blocking, which allows us to process
other lock operations.

(Enclose this in an ifdef until the new flag
appears in a sanlock release.)
---
 daemons/lvmlockd/lvmlockd-sanlock.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 1e691eb..e1a85b4 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1392,6 +1392,15 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 	if (adopt)
 		flags |= SANLK_ACQUIRE_ORPHAN_ONLY;
 
+#ifdef SANLOCK_HAS_ACQUIRE_OWNER_NOWAIT
+	/*
+	 * Don't block waiting for a failed lease to expire since it causes
+	 * sanlock_acquire to block for a long time, which would prevent this
+	 * thread from processing other lock requests.
+	 */
+	flags |= SANLK_ACQUIRE_OWNER_NOWAIT;
+#endif
+
 	rv = sanlock_acquire(lms->sock, -1, flags, 1, &rs, NULL);
 
 	if (rv == -EAGAIN) {
@@ -1462,6 +1471,26 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		return -EAGAIN;
 	}
 
+#ifdef SANLOCK_HAS_ACQUIRE_OWNER_NOWAIT
+	if (rv == SANLK_ACQUIRE_OWNED_RETRY) {
+		/*
+		 * The lock is held by a failed host, and will eventually
+		 * expire.  If we retry we'll eventually acquire the lock
+		 * (or find someone else has acquired it).  The EAGAIN retry
+		 * attempts for SH locks above would not be sufficient for
+		 * the length of expiration time.  We could add a longer
+		 * retry time here to cover the full expiration time and block
+		 * the activation command for that long.  For now just return
+		 * the standard error indicating that another host still owns
+		 * the lease.  FIXME: return a different error number so the
+		 * command can print an different error indicating that the
+		 * owner of the lease is in the process of expiring?
+		 */
+		log_debug("S %s R %s lock_san acquire mode %d rv %d", ls->name, r->name, ld_mode, rv);
+		*retry = 0;
+		return -EAGAIN;
+	}
+#endif
 	if (rv < 0) {
 		log_error("S %s R %s lock_san acquire error %d",
 			  ls->name, r->name, rv);


