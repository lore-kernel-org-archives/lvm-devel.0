From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Dec 2017 12:56:15 -0500
Subject: master - lvmlockd: recognize normal errors from sanlock_convert
Message-ID: <201712051756.vB5HuFNe020539@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46d6f7a6393d1d99411d7896285f6f1556de8547
Commit:        46d6f7a6393d1d99411d7896285f6f1556de8547
Parent:        bd893348b415d4e604a7f9a503f17623d485e76e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 29 15:17:25 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 5 11:53:03 2017 -0600

lvmlockd: recognize normal errors from sanlock_convert

Don't log an error message for error values returned
by sanlock_convert for expected conditions like lock
contention or io timeouts.
---
 daemons/lvmlockd/lvmlockd-core.c    |    9 ++++-----
 daemons/lvmlockd/lvmlockd-sanlock.c |   20 +++++++++++++++-----
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index a921140..df6e214 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1389,12 +1389,11 @@ static int res_convert(struct lockspace *ls, struct resource *r,
 	}
 
 	rv = lm_convert(ls, r, act->mode, act, r_version);
-	if (rv < 0) {
-		log_error("S %s R %s res_convert lm error %d", ls->name, r->name, rv);
-		return rv;
-	}
 
-	log_debug("S %s R %s res_convert lm done", ls->name, r->name);
+	log_debug("S %s R %s res_convert rv %d", ls->name, r->name, rv);
+
+	if (rv < 0)
+		return rv;
 
 	if (lk->mode == LD_LK_EX && act->mode == LD_LK_SH) {
 		r->sh_count = 1;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 079e952..2171c7a 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1699,12 +1699,22 @@ int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 	flags |= SANLK_ACQUIRE_OWNER_NOWAIT;
 
 	rv = sanlock_convert(lms->sock, -1, flags, rs);
-	if (rv == -EAGAIN) {
-		/* FIXME: When could this happen?  Should something different be done? */
-		log_error("S %s R %s convert_san EAGAIN", ls->name, r->name);
+	if (!rv)
+		return 0;
+
+	switch (rv) {
+	case -EAGAIN:
+	case SANLK_ACQUIRE_IDLIVE:
+	case SANLK_ACQUIRE_OWNED:
+	case SANLK_ACQUIRE_OWNED_RETRY:
+	case SANLK_ACQUIRE_OTHER:
+	case SANLK_AIO_TIMEOUT:
+	case SANLK_DBLOCK_LVER:
+	case SANLK_DBLOCK_MBAL:
+		/* expected errors from known/normal cases like lock contention or io timeouts */
+		log_debug("S %s R %s convert_san error %d", ls->name, r->name, rv);
 		return -EAGAIN;
-	}
-	if (rv < 0) {
+	default:
 		log_error("S %s R %s convert_san convert error %d", ls->name, r->name, rv);
 		rv = -ELMERR;
 	}


