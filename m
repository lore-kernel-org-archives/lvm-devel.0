From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 24 Feb 2016 16:12:07 +0000 (UTC)
Subject: master - lvmlockd: use new sanlock flag to avoid blocking
Message-ID: <20160224161207.796B16103F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=664fa6d1be10a807f8edc13801b1cd62248ae76f
Commit:        664fa6d1be10a807f8edc13801b1cd62248ae76f
Parent:        77f034bfa3d85600ec9b9581c17352202ce09ae8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 24 10:10:59 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 24 10:10:59 2016 -0600

lvmlockd: use new sanlock flag to avoid blocking

This flag allows sanlock requests to avoid all blocking.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 6694652..c6534d8 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1416,14 +1416,12 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 	if (adopt)
 		flags |= SANLK_ACQUIRE_ORPHAN_ONLY;
 
-#ifdef SANLOCK_HAS_ACQUIRE_OWNER_NOWAIT
 	/*
 	 * Don't block waiting for a failed lease to expire since it causes
 	 * sanlock_acquire to block for a long time, which would prevent this
 	 * thread from processing other lock requests.
 	 */
 	flags |= SANLK_ACQUIRE_OWNER_NOWAIT;
-#endif
 
 	memset(&opt, 0, sizeof(opt));
 	sprintf(opt.owner_name, "%s", "lvmlockd");
@@ -1498,7 +1496,6 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		return -EAGAIN;
 	}
 
-#ifdef SANLOCK_HAS_ACQUIRE_OWNER_NOWAIT
 	if (rv == SANLK_ACQUIRE_OWNED_RETRY) {
 		/*
 		 * The lock is held by a failed host, and will eventually
@@ -1517,7 +1514,7 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		*retry = 0;
 		return -EAGAIN;
 	}
-#endif
+
 	if (rv < 0) {
 		log_error("S %s R %s lock_san acquire error %d",
 			  ls->name, r->name, rv);


