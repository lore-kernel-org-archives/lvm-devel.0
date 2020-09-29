From: David Teigland <teigland@sourceware.org>
Date: Tue, 29 Sep 2020 19:43:35 +0000 (GMT)
Subject: master - lvmlockd vdo: add support
Message-ID: <20200929194335.D5262386EC0E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2272a32e6f9b99f98514e58de82f8a3baa8b46da
Commit:        2272a32e6f9b99f98514e58de82f8a3baa8b46da
Parent:        82e270c18a76d68e2efc28a194bca2e428c18fae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 29 14:33:44 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 29 14:43:27 2020 -0500

lvmlockd vdo: add support

lvmlockd handling for vdo lv and vdo pool is like
thin lv and thin pool.
---
 lib/locking/lvmlockd.c  | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv_manip.c | 21 ++++++++++++--
 2 files changed, 92 insertions(+), 2 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 9d11077e3..24b7ff6f7 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2311,6 +2311,49 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 			     pool_lv->lock_args, def_mode, flags);
 }
 
+static int _lockd_lv_vdo(struct cmd_context *cmd, struct logical_volume *lv,
+			 const char *def_mode, uint32_t flags)
+{
+	struct logical_volume *pool_lv = NULL;
+
+	if (lv_is_vdo(lv)) {
+		if (first_seg(lv))
+			pool_lv = seg_lv(first_seg(lv), 0);
+
+	} else if (lv_is_vdo_pool(lv)) {
+		pool_lv = lv;
+
+	} else if (lv_is_vdo_pool_data(lv)) {
+		return 1;
+
+	} else {
+		/* This should not happen AFAIK. */
+		log_error("Lock on incorrect vdo lv type %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!pool_lv) {
+		/* This happens in lvremove where it's harmless. */
+		log_debug("No vdo pool for %s/%s", lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/*
+	 * Locking a locked lv (pool in this case) is a no-op.
+	 * Unlock when the pool is no longer active.
+	 */
+
+	if (def_mode && !strcmp(def_mode, "un") &&
+	    lv_is_vdo_pool(pool_lv) && lv_is_active(lv_lock_holder(pool_lv)))
+		return 1;
+
+	flags |= LDLV_MODE_NO_SH;
+
+	return lockd_lv_name(cmd, pool_lv->vg, pool_lv->name, &pool_lv->lvid.id[1],
+			     pool_lv->lock_args, def_mode, flags);
+}
+
 /*
  * If the VG has no lock_type, then this function can return immediately.
  * The LV itself may have no lock (NULL lv->lock_args), but the lock request
@@ -2352,6 +2395,9 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_thin_type(lv))
 		return _lockd_lv_thin(cmd, lv, def_mode, flags);
 
+	if (lv_is_vdo_type(lv))
+		return _lockd_lv_vdo(cmd, lv, def_mode, flags);
+
 	/*
 	 * An LV with NULL lock_args does not have a lock of its own.
 	 */
@@ -2724,6 +2770,27 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			return 0;
 		}
 
+	} else if (seg_is_vdo(lp)) {
+		struct lv_list *lvl;
+
+		/*
+		 * A vdo lv is being created in a vdo pool.  The vdo lv does
+		 * not have its own lock, the lock of the vdo pool is used, and
+		 * the vdo pool needs to be locked to create a vdo lv in it.
+		 */
+
+		if (!(lvl = find_lv_in_vg(vg, lp->pool_name))) {
+			log_error("Failed to find vdo pool %s/%s", vg->name, lp->pool_name);
+			return 0;
+		}
+
+		if (!lockd_lv(cmd, lvl->lv, "ex", LDLV_PERSISTENT)) {
+			log_error("Failed to lock vdo pool %s/%s", vg->name, lp->pool_name);
+			return 0;
+		}
+		lv->lock_args = NULL;
+		return 1;
+
 	} else {
 		/* Creating a normal lv. */
 		/* lv_name_lock = lv_name; */
@@ -2963,6 +3030,12 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 	if (lv_is_pool_metadata_spare(lv))
 		return 0;
 
+	if (lv_is_vdo(lv))
+		return 0;
+
+	if (lv_is_vdo_pool_data(lv))
+		return 0;
+
 	if (lv_is_cache_vol(lv))
 		return 0;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9dbb6e1b5..a907130ff 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1222,8 +1222,19 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	}
 
 	/* When removed last VDO user automatically removes VDO pool */
-	if (lv_is_vdo_pool(lv) && dm_list_empty(&(lv->segs_using_this_lv)))
-		return lv_remove(lv); /* FIXME: any upper level reporting */
+	if (lv_is_vdo_pool(lv) && dm_list_empty(&(lv->segs_using_this_lv))) {
+		struct volume_group *vg = lv->vg;
+
+		if (!lv_remove(lv)) /* FIXME: any upper level reporting */
+			return_0;
+
+		if (vg_is_shared(vg)) {
+			if (!lockd_lv_name(vg->cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args, "un", LDLV_PERSISTENT))
+				log_error("Failed to unlock vdo pool in lvmlockd.");
+			lockd_free_lv(vg->cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
+		}
+		return 1;
+	}
 
 	return 1;
 }
@@ -8730,9 +8741,15 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			/* The VDO segment needs VDO pool which is layer above created striped data LV */
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_VDO_POOL)))
 				return_NULL;
+
+			/* We want a lockd lock for the new vdo pool, but not the vdo lv. */
+			lp->needs_lockd_init = 1;
+
 			/* Use vpool names for vdo-pool */
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name ? : "vpool%d")))
 				return_NULL;
+
+			lp->needs_lockd_init = 0;
 		} else {
 			log_error(INTERNAL_ERROR "Creation of pool for unsupported segment type %s.",
 				  lp->segtype->name);


