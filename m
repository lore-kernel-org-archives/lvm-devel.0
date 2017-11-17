From: David Teigland <teigland@sourceware.org>
Date: Fri, 17 Nov 2017 11:59:32 -0500
Subject: master - lvmlockd: retry on other sanlock errors
Message-ID: <201711171659.vAHGxW36016213@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e52d2e3bd86a006bcc322649ac9cb7c52117b787
Commit:        e52d2e3bd86a006bcc322649ac9cb7c52117b787
Parent:        115e66e9bedaa5d6edfd436fb78aba2c753deeb7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 15 15:34:42 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 17 10:59:12 2017 -0600

lvmlockd: retry on other sanlock errors

These less common errors returned from sanlock should
also cause sanlock to retry the lock acquire:

- i/o timeout occurs during sanlock_acquire().
  other i/o on the same disk as the leases can cause
  sanlock i/o timeouts.

- low level disk paxos contention between hosts naturally
  causes one host to not acquire the lease.  There are a
  couple special error numbers associated with these cases
  that should just be recognized as a normal failure to
  acquire the lease.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 0e81915..acec7dc 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1528,6 +1528,26 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		return -EAGAIN;
 	}
 
+	if (rv == SANLK_AIO_TIMEOUT) {
+		/*
+		 * sanlock got an i/o timeout when trying to acquire the
+		 * lease on disk.
+		 */
+		log_debug("S %s R %s lock_san acquire mode %d rv %d", ls->name, r->name, ld_mode, rv);
+		*retry = 0;
+		return -EAGAIN;
+	}
+
+	if (rv == SANLK_DBLOCK_LVER || rv == SANLK_DBLOCK_MBAL) {
+		/*
+		 * There was contention with another host for the lease,
+		 * and we lost.
+		 */
+		log_debug("S %s R %s lock_san acquire mode %d rv %d", ls->name, r->name, ld_mode, rv);
+		*retry = 0;
+		return -EAGAIN;
+	}
+
 	if (rv == SANLK_ACQUIRE_OWNED_RETRY) {
 		/*
 		 * The lock is held by a failed host, and will eventually


