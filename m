From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Sep 2017 13:29:08 -0400
Subject: master - revert tidy: prefer not using else after return
Message-ID: <201709141729.v8EHT8dc011383@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d93a2bb74177397430ec21d6062987cb7da91217
Commit:        d93a2bb74177397430ec21d6062987cb7da91217
Parent:        29834b6e918e4b3774fd82aec0cfd2cbb5d162bb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 14 12:15:59 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 14 12:28:48 2017 -0500

revert tidy: prefer not using else after return

Revert the lvmlockd.c changes from:
  commit 0bf836aa14f98eb83969a6e81695a024f56a5eb5
  "tidy: prefer not using else after return"

The commit introduced at least one regression, which broke
lvcreate of a thin pool in a shared VG.
---
 lib/locking/lvmlockd.c |   43 ++++++++++++++++++++-----------------------
 1 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a0e3f03..f4047d9 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1646,15 +1646,15 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 			 */
 			log_error("Global lock failed: held by other host.");
 			return 0;
+		} else {
+			/*
+			 * We don't intend to reach this.  We should check
+			 * any known/possible error specifically and print
+			 * a more helpful message.  This is for completeness.
+			 */
+			log_error("Global lock failed: error %d.", result);
+			return 0;
 		}
-
-		/*
-		 * We don't intend to reach this.  We should check
-		 * any known/possible error specifically and print
-		 * a more helpful message.  This is for completeness.
-		 */
-		log_error("Global lock failed: error %d.", result);
-		return 0;
 	}
 
  allow:
@@ -2380,16 +2380,15 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 	if (!_lvmlockd_connected)
 		return 0;
 
-	if (!lp->needs_lockd_init)
+	if (!lp->needs_lockd_init) {
 		/* needs_lock_init is set for LVs that need a lockd lock. */
 		return 1;
 
-	if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
+	} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
 		log_error("Use lvconvert for cache with lock type %s", vg->lock_type);
 		return 0;
-	}
 
-	if (!seg_is_thin_volume(lp) && lp->snapshot) {
+	} else if (!seg_is_thin_volume(lp) && lp->snapshot) {
 		struct logical_volume *origin_lv;
 
 		/*
@@ -2414,9 +2413,8 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 		}
 		lv->lock_args = NULL;
 		return 1;
-	}
 
-	if (seg_is_thin(lp)) {
+	} else if (seg_is_thin(lp)) {
 		if ((seg_is_thin_volume(lp) && !lp->create_pool) ||
 		    (!seg_is_thin_volume(lp) && lp->snapshot)) {
 			struct lv_list *lvl;
@@ -2437,9 +2435,8 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			}
 			lv->lock_args = NULL;
 			return 1;
-		}
 
-		if (seg_is_thin_volume(lp) && lp->create_pool) {
+		} else if (seg_is_thin_volume(lp) && lp->create_pool) {
 			/*
 			 * Creating a thin pool and a thin lv in it.  We could
 			 * probably make this work.
@@ -2447,21 +2444,21 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			log_error("Create thin pool and thin LV separately with lock type %s",
 				  vg->lock_type);
 			return 0;
-		}
 
-		if (!seg_is_thin_volume(lp) && lp->create_pool) {
+		} else if (!seg_is_thin_volume(lp) && lp->create_pool) {
 			/* Creating a thin pool only. */
 			/* lv_name_lock = lp->pool_name; */
 
+		} else {
+			log_error("Unknown thin options for lock init.");
+			return 0;
 		}
 
-		log_error("Unknown thin options for lock init.");
-		return 0;
+	} else {
+		/* Creating a normal lv. */
+		/* lv_name_lock = lv_name; */
 	}
 
-	/* Creating a normal lv. */
-	/* lv_name_lock = lv_name; */
-
 	/*
 	 * The LV gets its own lock, so set lock_args to non-NULL.
 	 *


