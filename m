From: David Teigland <teigland@sourceware.org>
Date: Fri, 2 Nov 2018 13:14:17 -0400
Subject: master - lvmlockd: fix handling of sanlock release error
Message-ID: <201811021714.wA2HEHWF025746@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7a56d5cd32654e4921e4c03bc434efd0e24b1c0
Commit:        e7a56d5cd32654e4921e4c03bc434efd0e24b1c0
Parent:        f6a54a50a0f5e1a06e1a4da6ca17f9e84773eb88
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 2 12:11:09 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 2 12:11:09 2018 -0500

lvmlockd: fix handling of sanlock release error

When sanlock_release returns an error because of an i/o
timeout releasing the lease on disk, lvmlockd should just
consider the lock released.  sanlock will continue trying
to release the lease on disk after the original request
times out.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 892b446..9c950f3 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -2111,12 +2111,20 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 	if (rv < 0)
 		log_error("S %s R %s unlock_san release error %d", ls->name, r->name, rv);
 
-	if (rv == -EIO)
-		rv = -ELOCKIO;
-	else if (rv < 0)
-		rv = -ELMERR;
+	/*
+	 * sanlock may return an error here if it fails to release the lease on
+	 * disk because of an io timeout.  But, sanlock will continue trying to
+	 * release the lease after this call returns.  We shouldn't return an
+	 * error here which would result in lvmlockd-core keeping the lock
+	 * around.  By releasing the lock in lvmlockd-core@this point,
+	 * lvmlockd may send another acquire request to lvmlockd.  If sanlock
+	 * has not been able to release the previous instance of the lock yet,
+	 * then it will return an error for the new request.  But, acquiring a
+	 * new lock is able o fail gracefully, until sanlock is finally able to
+	 * release the old lock.
+	 */
 
-	return rv;
+	return 0;
 }
 
 int lm_hosts_sanlock(struct lockspace *ls, int notify)


