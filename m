From: David Teigland <teigland@sourceware.org>
Date: Fri, 17 Nov 2017 11:59:34 -0500
Subject: master - lvmlockd: override unknown lock manager error numbers
Message-ID: <201711171659.vAHGxYb3016224@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbaaf4f1d34a1a097c20dca1f36a0f6a50c5d066
Commit:        bbaaf4f1d34a1a097c20dca1f36a0f6a50c5d066
Parent:        e52d2e3bd86a006bcc322649ac9cb7c52117b787
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 15 16:00:41 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 17 10:59:12 2017 -0600

lvmlockd: override unknown lock manager error numbers

When sanlock or dlm lock managers return an error number
that we don't recognize, replace it with a generic -ELMERR
which is defined in the set of special lvmlockd error
numbers.  Otherwise, an unknown lock manager error number
could be misinterpreted for something else if it happened
to overlap another set of error numbers (which they have
not thus far.)
---
 daemons/lvmlockd/lvmlockd-client.h  |    1 +
 daemons/lvmlockd/lvmlockd-dlm.c     |    4 +++-
 daemons/lvmlockd/lvmlockd-sanlock.c |   24 +++++++++++++++++++++++-
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 1d42338..bc90596 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -49,5 +49,6 @@ static inline void lvmlockd_close(daemon_handle h)
 #define ELOCKIO   218 /* sanlock io errors during lock op, may be transient. */
 #define EREMOVED  219
 #define EDEVOPEN  220 /* sanlock failed to open lvmlock LV */
+#define ELMERR    221
 
 #endif	/* _LVM_LVMLOCKD_CLIENT_H */
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 280cf2b..9440821 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -508,7 +508,7 @@ lockrv:
 	}
 	if (rv < 0) {
 		log_error("S %s R %s lock_dlm acquire error %d errno %d", ls->name, r->name, rv, errno);
-		return rv;
+		return -ELMERR;
 	}
 
 	if (rdd->vb) {
@@ -581,6 +581,7 @@ int lm_convert_dlm(struct lockspace *ls, struct resource *r,
 	}
 	if (rv < 0) {
 		log_error("S %s R %s convert_dlm error %d", ls->name, r->name, rv);
+		rv = -ELMERR;
 	}
 	return rv;
 }
@@ -654,6 +655,7 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 			      0, NULL, NULL, NULL);
 	if (rv < 0) {
 		log_error("S %s R %s unlock_dlm error %d", ls->name, r->name, rv);
+		rv = -ELMERR;
 	}
 
 	return rv;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index acec7dc..358c588 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1460,6 +1460,12 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 
 	rv = sanlock_acquire(lms->sock, -1, flags, 1, &rs, &opt);
 
+	/*
+	 * errors: translate the sanlock error number to an lvmlockd error.
+	 * We don't want to return an sanlock-specific error number from
+	 * this function to code that doesn't recognize sanlock error numbers.
+	 */
+
 	if (rv == -EAGAIN) {
 		/*
 		 * It appears that sanlock_acquire returns EAGAIN when we request
@@ -1598,15 +1604,25 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		if (rv == -ENOSPC)
 			rv = -ELOCKIO;
 
-		return rv;
+		/*
+		 * generic error number for sanlock errors that we are not
+		 * catching above.
+		 */
+		return -ELMERR;
 	}
 
+	/*
+	 * sanlock acquire success (rv 0)
+	 */
+
 	if (rds->vb) {
 		rv = sanlock_get_lvb(0, rs, (char *)&vb, sizeof(vb));
 		if (rv < 0) {
 			log_error("S %s R %s lock_san get_lvb error %d", ls->name, r->name, rv);
 			memset(rds->vb, 0, sizeof(struct val_blk));
 			memset(vb_out, 0, sizeof(struct val_blk));
+			/* the lock is still acquired, the vb values considered invalid */
+			rv = 0;
 			goto out;
 		}
 
@@ -1659,6 +1675,7 @@ int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 		if (rv < 0) {
 			log_error("S %s R %s convert_san set_lvb error %d",
 				  ls->name, r->name, rv);
+			rv = -ELMERR;
 		}
 	}
 
@@ -1679,6 +1696,7 @@ int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 	}
 	if (rv < 0) {
 		log_error("S %s R %s convert_san convert error %d", ls->name, r->name, rv);
+		rv = -ELMERR;
 	}
 
 	return rv;
@@ -1715,6 +1733,7 @@ static int release_rename(struct lockspace *ls, struct resource *r)
 	rv = sanlock_release(lms->sock, -1, SANLK_REL_RENAME, 2, res_args);
 	if (rv < 0) {
 		log_error("S %s R %s unlock_san release rename error %d", ls->name, r->name, rv);
+		rv = -ELMERR;
 	}
 
 	free(res_args);
@@ -1771,6 +1790,7 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 		if (rv < 0) {
 			log_error("S %s R %s unlock_san set_lvb error %d",
 				  ls->name, r->name, rv);
+			rv = -ELMERR;
 		}
 	}
 
@@ -1789,6 +1809,8 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 
 	if (rv == -EIO)
 		rv = -ELOCKIO;
+	else if (rv < 0)
+		rv = -ELMERR;
 
 	return rv;
 }


