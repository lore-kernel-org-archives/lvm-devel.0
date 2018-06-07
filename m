From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:21:32 -0400
Subject: master - Remove unused clvm variations for active LVs
Message-ID: <201806071521.w57FLWSb013120@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18259d5559307f2708e12b9923988319e46572df
Commit:        18259d5559307f2708e12b9923988319e46572df
Parent:        e4d9099e19591a7f3ad546c180b59a601e0d03da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 5 13:21:28 2018 -0500
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 7 16:17:04 2018 +0100

Remove unused clvm variations for active LVs

Different flavors of activate_lv() and lv_is_active()
which are meaningful in a clustered VG can be eliminated
and replaced with whatever that flavor already falls back
to in a local VG.

e.g. lv_is_active_exclusive_locally() is distinct from
lv_is_active() in a clustered VG, but in a local VG they
are equivalent.  So, all instances of the variant are
replaced with the basic local equivalent.

For local VGs, the same behavior remains as before.
For shared VGs, lvmlockd was written with the explicit
requirement of local behavior from these functions
(lvmlockd requires locking_type 1), so the behavior
in shared VGs also remains the same.
---
 lib/activate/activate.c       |  131 ++--------------------------------------
 lib/activate/activate.h       |    6 --
 lib/locking/locking.c         |   18 +-----
 lib/locking/locking.h         |   10 +---
 lib/metadata/cache_manip.c    |    6 +-
 lib/metadata/lv.c             |   64 ++------------------
 lib/metadata/lv.h             |    2 +-
 lib/metadata/lv_manip.c       |   36 +++++-------
 lib/metadata/mirror.c         |   65 ++------------------
 lib/metadata/pool_manip.c     |    2 +-
 lib/metadata/raid_manip.c     |   46 ++++----------
 lib/metadata/snapshot_manip.c |    6 --
 lib/metadata/thin_manip.c     |    4 +-
 lib/report/report.c           |   40 +------------
 tools/lvchange.c              |   11 +--
 tools/lvconvert.c             |   27 ++++-----
 tools/lvcreate.c              |    4 +-
 tools/polldaemon.c            |    4 +-
 tools/pvmove.c                |    8 +--
 tools/toollib.c               |    4 +-
 tools/vgchange.c              |   16 +-----
 21 files changed, 88 insertions(+), 422 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4c70443..c9ead42 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -374,31 +374,6 @@ int lv_is_active(const struct logical_volume *lv)
 {
 	return 0;
 }
-int lv_is_active_locally(const struct logical_volume *lv)
-{
-	return 0;
-}
-int lv_is_active_remotely(const struct logical_volume *lv)
-{
-	return 0;
-}
-int lv_is_active_but_not_locally(const struct logical_volume *lv)
-{
-	return 0;
-}
-int lv_is_active_exclusive(const struct logical_volume *lv)
-{
-	return 0;
-}
-int lv_is_active_exclusive_locally(const struct logical_volume *lv)
-{
-	return 0;
-}
-int lv_is_active_exclusive_remotely(const struct logical_volume *lv)
-{
-	return 0;
-}
-
 int lv_check_transient(struct logical_volume *lv)
 {
 	return 1;
@@ -1471,61 +1446,6 @@ int lvs_in_vg_opened(const struct volume_group *vg)
 }
 
 /*
- * _lv_is_active
- * @lv:        logical volume being queried
- * @locally:   set if active locally (when provided)
- * @remotely:  set if active remotely (when provided)
- * @exclusive: set if active exclusively (when provided)
- *
- * Determine whether an LV is active locally or in a cluster.
- * In addition to the return code which indicates whether or
- * not the LV is active somewhere, two other values are set
- * to yield more information about the status of the activation:
- *
- *	return	locally	exclusively	status
- *	======	=======	===========	======
- *	   0	   0	    0		not active
- *	   1	   0	    0		active remotely
- *	   1	   0	    1		exclusive remotely
- *	   1	   1	    0		active locally and possibly remotely
- *	   1	   1	    1		exclusive locally (or local && !cluster)
- * The VG lock must be held to call this function.
- *
- * Returns: 0 or 1
- */
-static int _lv_is_active(const struct logical_volume *lv,
-			 int *locally, int *remotely, int *exclusive)
-{
-	int r, l, e; /* remote, local, and exclusive */
-	int skip_cluster_query = 0;
-
-	r = l = e = 0;
-
-	if (_lv_active(lv->vg->cmd, lv))
-		l = 1;
-
-	if (l)
-		e = 1;  /* exclusive by definition */
-
-	if (locally)
-		*locally = l;
-	if (exclusive)
-		*exclusive = e;
-	if (remotely)
-		*remotely = r;
-
-	log_very_verbose("%s is %sactive%s%s%s%s",
-			 display_lvname(lv),
-			 (r || l) ? "" : "not ",
-			 (exclusive && e) ? " exclusive" : "",
-			 l ? " locally" : "",
-			 (!skip_cluster_query && l && r) ? " and" : "",
-			 (!skip_cluster_query && r) ? " remotely" : "");
-
-	return r || l;
-}
-
-/*
  * Check if "raid4" @segtype is supported by kernel.
  *
  * if segment type is not raid4, return 1.
@@ -1545,51 +1465,14 @@ int raid4_is_supported(struct cmd_context *cmd, const struct segment_type *segty
 	return 1;
 }
 
+/*
+ * The VG lock must be held to call this function.
+ *
+ * Returns: 0 or 1
+ */
 int lv_is_active(const struct logical_volume *lv)
 {
-	return _lv_is_active(lv, NULL, NULL, NULL);
-}
-
-int lv_is_active_locally(const struct logical_volume *lv)
-{
-	int l;
-
-	return _lv_is_active(lv, &l, NULL, NULL) && l;
-}
-
-int lv_is_active_remotely(const struct logical_volume *lv)
-{
-	int r;
-
-	return _lv_is_active(lv, NULL, &r, NULL) && r;
-}
-
-int lv_is_active_but_not_locally(const struct logical_volume *lv)
-{
-	int l;
-
-	return _lv_is_active(lv, &l, NULL, NULL) && !l;
-}
-
-int lv_is_active_exclusive(const struct logical_volume *lv)
-{
-	int e;
-
-	return _lv_is_active(lv, NULL, NULL, &e) && e;
-}
-
-int lv_is_active_exclusive_locally(const struct logical_volume *lv)
-{
-	int l, e;
-
-	return _lv_is_active(lv, &l, NULL, &e) && l && e;
-}
-
-int lv_is_active_exclusive_remotely(const struct logical_volume *lv)
-{
-	int l, e;
-
-	return _lv_is_active(lv, &l, NULL, &e) && !l && e;
+	return _lv_active(lv->vg->cmd, lv);
 }
 
 #ifdef DMEVENTD
@@ -1991,7 +1874,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			continue;
 
 		if (!vg_write_lock_held() && lv_is_mirror(lv)) {
-			mirr_laopts.exclusive = lv_is_active_exclusive_locally(lv) ? 1 : 0;
+			mirr_laopts.exclusive = lv_is_active(lv) ? 1 : 0;
 			/*
 			 * Commands vgchange and lvchange do use read-only lock when changing
 			 * monitoring (--monitor y|n). All other use cases hold 'write-lock'
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 8175f68..8b6c4ad 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -191,12 +191,6 @@ int lvs_in_vg_activated(const struct volume_group *vg);
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(const struct logical_volume *lv);
-int lv_is_active_locally(const struct logical_volume *lv);
-int lv_is_active_remotely(const struct logical_volume *lv);
-int lv_is_active_but_not_locally(const struct logical_volume *lv);
-int lv_is_active_exclusive(const struct logical_volume *lv);
-int lv_is_active_exclusive_locally(const struct logical_volume *lv);
-int lv_is_active_exclusive_remotely(const struct logical_volume *lv);
 
 /* Check is any component LV is active */
 const struct logical_volume *lv_component_is_active(const struct logical_volume *lv);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 0e5658f..a4fcaf7 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -273,16 +273,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	return 1;
 }
 
-/*
- * First try to activate exclusively locally.
- * Then if the VG is clustered and the LV is not yet active (e.g. due to 
- * an activation filter) try activating on remote nodes.
- */
-int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv)
-{
-	return activate_lv_excl_local(cmd, lv);
-}
-
 /* Lock a list of LVs */
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive)
 {
@@ -290,13 +280,9 @@ int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusiv
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs) {
-		if (!exclusive && !lv_is_active_exclusive(lvl->lv)) {
-			if (!activate_lv(cmd, lvl->lv)) {
-				log_error("Failed to activate %s", display_lvname(lvl->lv));
-				return 0;
-			}
-		} else if (!activate_lv_excl(cmd, lvl->lv)) {
+		if (!activate_lv(cmd, lvl->lv)) {
 			log_error("Failed to activate %s", display_lvname(lvl->lv));
+
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
 				if (!deactivate_lv(cmd, lvl->lv))
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 8b2bced..f3956c2 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -231,20 +231,14 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 })
 #define suspend_lv(cmd, lv)	\
 	(lock_activation((cmd), (lv)) ? lock_lv_vol((cmd), (lv), LCK_LV_SUSPEND | LCK_HOLD) : 0)
+
 #define suspend_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD | LCK_ORIGIN_ONLY)
+
 #define deactivate_lv(cmd, lv)	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE)
 
 #define activate_lv(cmd, lv)	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
-#define activate_lv_excl_local(cmd, lv)	\
-				lock_lv_vol_serially(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_LOCAL)
-#define activate_lv_excl_remote(cmd, lv)	\
-				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_REMOTE)
 
 struct logical_volume;
-int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv);
-
-#define activate_lv_local(cmd, lv)	\
-	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
 
 #define deactivate_lv_local(cmd, lv)	\
 	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 0768e6f..fe91fee 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -566,8 +566,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		default:
 			/* Otherwise localy activate volume to sync dirty blocks */
 			cache_lv->status |= LV_TEMPORARY;
-			if (!activate_lv_excl_local(cache_lv->vg->cmd, cache_lv) ||
-			    !lv_is_active_locally(cache_lv)) {
+			if (!activate_lv(cache_lv->vg->cmd, cache_lv) ||
+			    !lv_is_active(cache_lv)) {
 				log_error("Failed to active cache locally %s.",
 					  display_lvname(cache_lv));
 				return 0;
@@ -969,7 +969,7 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv)
 	}
 
 	cache_pool_lv->status |= LV_TEMPORARY;
-	if (!activate_lv_excl_local(cache_pool_lv->vg->cmd, cache_pool_lv)) {
+	if (!activate_lv(cache_pool_lv->vg->cmd, cache_pool_lv)) {
 		log_error("Aborting. Failed to activate cache pool %s.",
 			  display_lvname(cache_pool_lv));
 		return 0;
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f930633..14d7312 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1023,7 +1023,7 @@ int lv_raid_image_in_sync(const struct logical_volume *lv)
 	 * If the LV is not active locally,
 	 * it doesn't make sense to check status
 	 */
-	if (!lv_is_active_locally(lv))
+	if (!lv_is_active(lv))
 		return 0;  /* Assume not in-sync */
 
 	if (!lv_is_raid_image(lv)) {
@@ -1081,7 +1081,7 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	 * If the LV is not active locally,
 	 * it doesn't make sense to check status
 	 */
-	if (!lv_is_active_locally(lv))
+	if (!lv_is_active(lv))
 		return 1;  /* assume healthy */
 
 	if (!lv_is_raid_type(lv)) {
@@ -1446,22 +1446,8 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return dm_pool_strdup(mem, lv->hostname ? : "");
 }
 
-static int _lv_is_exclusive(struct logical_volume *lv)
-{
-	struct lv_segment *seg;
-
-	/* Some seg types require exclusive activation */
-	/* FIXME Scan recursively */
-	dm_list_iterate_items(seg, &lv->segments)
-		if (seg_only_exclusive(seg))
-			return 1;
-
-	/* Origin has no seg type require exlusiveness */
-	return lv_is_origin(lv);
-}
-
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     enum activation_change activate, int needs_exclusive)
+		     enum activation_change activate)
 {
 	const char *ay_with_mode = NULL;
 
@@ -1478,45 +1464,22 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 
 	switch (activate) {
 	case CHANGE_AN:
+	case CHANGE_ALN:
 		log_verbose("Deactivating logical volume %s.", display_lvname(lv));
 		if (!deactivate_lv(cmd, lv))
 			return_0;
 		break;
-	case CHANGE_ALN:
-		log_verbose("Deactivating logical volume %s locally.",
-			    display_lvname(lv));
-		if (!deactivate_lv_local(cmd, lv))
-			return_0;
-		break;
+
 	case CHANGE_ALY:
 	case CHANGE_AAY:
-		if (needs_exclusive || _lv_is_exclusive(lv)) {
-			log_verbose("Activating logical volume %s exclusively locally.",
-				    display_lvname(lv));
-			if (!activate_lv_excl_local(cmd, lv))
-				return_0;
-		} else {
-			log_verbose("Activating logical volume %s locally.",
-				    display_lvname(lv));
-			if (!activate_lv_local(cmd, lv))
-				return_0;
-		}
-		break;
 	case CHANGE_AEY:
-exclusive:
-		log_verbose("Activating logical volume %s exclusively.",
-			    display_lvname(lv));
-		if (!activate_lv_excl(cmd, lv))
-			return_0;
-		break;
 	case CHANGE_ASY:
 	case CHANGE_AY:
 	default:
-		if (needs_exclusive || _lv_is_exclusive(lv))
-			goto exclusive;
 		log_verbose("Activating logical volume %s.", display_lvname(lv));
 		if (!activate_lv(cmd, lv))
 			return_0;
+		break;
 	}
 
 	if (!is_change_activating(activate) &&
@@ -1535,23 +1498,10 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		goto out;
 	}
 
-	if (vg_is_clustered(lv->vg)) {
-		//const struct logical_volume *lvo = lv;
-		lv = lv_lock_holder(lv);
-		//log_debug("Holder for %s => %s.", lvo->name, lv->name);
-	}
-
 	if (!lv_is_active(lv))
 		s = ""; /* not active */
-	else if (!vg_is_clustered(lv->vg))
+	else
 		s = "active";
-	else if (lv_is_active_exclusive(lv))
-		/* exclusive cluster activation */
-		s = lv_is_active_exclusive_locally(lv) ?
-			"local exclusive" : "remote exclusive";
-	else /* locally active */
-		s = lv_is_active_but_not_locally(lv) ?
-			"remotely" : "locally";
 out:
 	return dm_pool_strdup(mem, s);
 }
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 920bcb5..e2e640f 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -153,7 +153,7 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     enum activation_change activate, int needs_exclusive);
+		     enum activation_change activate);
 
 /* LV dup functions */
 char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e023132..dad5953 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4058,7 +4058,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			for (s = 0; !fail && s < seg->area_count; s++) {
 				meta_lv = seg_metalv(seg, s);
 
-				if (!activate_lv_local(meta_lv->vg->cmd, meta_lv)) {
+				if (!activate_lv(meta_lv->vg->cmd, meta_lv)) {
 					log_error("Failed to activate %s for clearing.",
 						  display_lvname(meta_lv));
 					fail = 1;
@@ -4228,7 +4228,7 @@ int lv_extend(struct logical_volume *lv,
 		    (lv_is_not_synced(lv))) {
 			dm_percent_t sync_percent = DM_PERCENT_INVALID;
 
-			if (!lv_is_active_locally(lv)) {
+			if (!lv_is_active(lv)) {
 				log_error("Unable to read sync percent while LV %s "
 					  "is not locally active.", display_lvname(lv));
 				/* FIXME Support --force */
@@ -4711,7 +4711,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!lv_is_active_locally(lv)) {
+	if (!lv_is_active(lv)) {
 		log_error("Can't read state of locally inactive LV %s.",
 			  display_lvname(lv));
 		return 0;
@@ -5571,7 +5571,7 @@ int lv_resize(struct logical_volume *lv,
 		 * then use suspend and resume and deactivate pool LV,
 		 * instead of searching for an active thin volume.
 		 */
-		if (!activate_lv_excl(cmd, lock_lv)) {
+		if (!activate_lv(cmd, lock_lv)) {
 			log_error("Failed to activate %s.", display_lvname(lock_lv));
 			return 0;
 		}
@@ -6788,7 +6788,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
 	struct lv_names lv_names;
-	unsigned exclusive = 0, i;
+	unsigned i;
 
 	/* create an empty layer LV */
 	if (dm_snprintf(name, sizeof(name), "%s%s", lv_where->name, layer_suffix) < 0) {
@@ -6804,9 +6804,6 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (lv_is_active_exclusive_locally(lv_where))
-		exclusive = 1;
-
 	if (lv_is_active(lv_where) && strstr(name, MIRROR_SYNC_LAYER)) {
 		log_very_verbose("Creating transient LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 
@@ -6835,10 +6832,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 			return NULL;
 		}
 
-		if (exclusive)
-			r = activate_lv_excl(cmd, layer_lv);
-		else
-			r = activate_lv(cmd, layer_lv);
+		r = activate_lv(cmd, layer_lv);
 
 		if (!r) {
 			log_error("Failed to resume transient LV"
@@ -7125,7 +7119,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		/* nothing to do */
 		return 1;
 
-	if (!lv_is_active_locally(lv)) {
+	if (!lv_is_active(lv)) {
 		log_error("Volume \"%s/%s\" is not active locally (volume_list activation filter?).",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -7491,7 +7485,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					return_NULL;
 				/* New pool is now inactive */
 			} else {
-				if (!activate_lv_excl_local(cmd, pool_lv)) {
+				if (!activate_lv(cmd, pool_lv)) {
 					log_error("Aborting. Failed to locally activate thin pool %s.",
 						  display_lvname(pool_lv));
 					return NULL;
@@ -7783,7 +7777,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (seg_is_cache(lp)) {
 		if (vg_is_shared(vg)) {
 			if (is_change_activating(lp->activate)) {
-				if (!lv_active_change(cmd, lv, CHANGE_AEY, 0)) {
+				if (!lv_active_change(cmd, lv, CHANGE_AEY)) {
 					log_error("Aborting. Failed to activate LV %s.",
 						  display_lvname(lv));
 					goto revert_new_lv;
@@ -7794,7 +7788,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		/* FIXME Support remote exclusive activation? */
 		/* Not yet 'cache' LV, it is stripe volume for wiping */
 
-		else if (is_change_activating(lp->activate) && !activate_lv_excl_local(cmd, lv)) {
+		else if (is_change_activating(lp->activate) && !activate_lv(cmd, lv)) {
 			log_error("Aborting. Failed to activate LV %s locally exclusively.",
 				  display_lvname(lv));
 			goto revert_new_lv;
@@ -7827,7 +7821,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				/* Avoid multiple thin-pool activations in this case */
 				if (thin_pool_was_active < 0)
 					thin_pool_was_active = 0;
-				if (!activate_lv_excl(cmd, pool_lv)) {
+				if (!activate_lv(cmd, pool_lv)) {
 					log_error("Failed to activate thin pool %s.",
 						  display_lvname(pool_lv));
 					goto revert_new_lv;
@@ -7846,7 +7840,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		backup(vg);
 
-		if (!lv_active_change(cmd, lv, lp->activate, 0)) {
+		if (!lv_active_change(cmd, lv, lp->activate)) {
 			log_error("Failed to activate thin %s.", lv->name);
 			goto deactivate_and_revert_new_lv;
 		}
@@ -7860,13 +7854,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	} else if (lp->snapshot) {
 		lv->status |= LV_TEMPORARY;
-		if (!activate_lv_local(cmd, lv)) {
+		if (!activate_lv(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
 				  "exception store.");
 			goto revert_new_lv;
 		}
 		lv->status &= ~LV_TEMPORARY;
-	} else if (!lv_active_change(cmd, lv, lp->activate, 0)) {
+	} else if (!lv_active_change(cmd, lv, lp->activate)) {
 		log_error("Failed to activate new LV.");
 		goto deactivate_and_revert_new_lv;
 	}
@@ -7968,7 +7962,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			 */
 
 			/* Activate spare snapshot once it is a complete LV */
-			if (!lv_active_change(cmd, origin_lv, lp->activate, 1)) {
+			if (!lv_active_change(cmd, origin_lv, lp->activate)) {
 				log_error("Failed to activate sparce volume %s.",
 					  display_lvname(origin_lv));
 				return NULL;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 9c775c4..8de1440 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -354,7 +354,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	} else if (!lv_update_and_reload((struct logical_volume*) lock_holder))
 		return_0;
 
-	if (!activate_lv_excl_local(cmd, log_lv)) {
+	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
 	}
@@ -427,15 +427,10 @@ static int _activate_lv_like_model(struct logical_volume *model,
 	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
 
 	if (vg_is_shared(lv->vg))
-		return lv_active_change(lv->vg->cmd, lv, CHANGE_AEY, 0);
+		return lv_active_change(lv->vg->cmd, lv, CHANGE_AEY);
 
-	if (lv_is_active_exclusive(model)) {
-		if (!activate_lv_excl(lv->vg->cmd, lv))
-			return_0;
-	} else {
-		if (!activate_lv(lv->vg->cmd, lv))
-			return_0;
-	}
+	if (!activate_lv(lv->vg->cmd, lv))
+		return_0;
 	return 1;
 }
 
@@ -610,14 +605,7 @@ static int _mirrored_lv_in_sync(struct logical_volume *lv)
 
 	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
 			       NULL)) {
-		if (lv_is_active_but_not_locally(lv))
-			log_error("Unable to determine mirror sync status of"
-				  " remotely active LV, %s",
-				  display_lvname(lv));
-		else
-			log_error("Unable to determine mirror "
-				  "sync status of %s.",
-				  display_lvname(lv));
+		log_error("Unable to determine mirror sync status of %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -1668,7 +1656,6 @@ int remove_mirror_log(struct cmd_context *cmd,
 		      int force)
 {
 	dm_percent_t sync_percent;
-	struct volume_group *vg = lv->vg;
 
 	/* Unimplemented features */
 	if (dm_list_size(&lv->segments) != 1) {
@@ -1677,20 +1664,12 @@ int remove_mirror_log(struct cmd_context *cmd,
 	}
 
 	/* Had disk log, switch to core. */
-	if (lv_is_active_locally(lv)) {
+	if (lv_is_active(lv)) {
 		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent,
 				       NULL)) {
 			log_error("Unable to determine mirror sync status.");
 			return 0;
 		}
-	} else if (lv_is_active(lv)) {
-		log_error("Unable to determine sync status of "
-			  "remotely active mirror volume %s.", display_lvname(lv));
-		return 0;
-	} else if (vg_is_clustered(vg)) {
-		log_error("Unable to convert the log of an inactive "
-			  "cluster mirror volume %s.", display_lvname(lv));
-		return 0;
 	} else if (force || yes_no_prompt("Full resync required to convert inactive "
 					  "mirror volume %s to core log. "
 					  "Proceed? [y/n]: ", display_lvname(lv)) == 'y')
@@ -1910,22 +1889,11 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	unsigned old_log_count;
 	int r = 0;
 
-	if (vg_is_clustered(lv->vg) && (log_count > 1)) {
-		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
-		return 0;
-	}
-
 	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported.");
 		return 0;
 	}
 
-	if (lv_is_active_but_not_locally(lv)) {
-		log_error("Unable to convert the log of a mirror, %s, that is "
-			  "active remotely but not locally.", display_lvname(lv));
-		return 0;
-	}
-
 	log_lv = first_seg(lv)->log_lv;
 	old_log_count = (log_lv) ? lv_mirror_count(log_lv) : 0;
 	if (old_log_count == log_count) {
@@ -2079,27 +2047,6 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (vg_is_clustered(lv->vg)) {
-		/* FIXME: move this test out of this function */
-		/* Skip test for pvmove mirrors, it can use local mirror */
-		if (!lv_is_pvmove(lv) && !lv_is_locked(lv) &&
-		    lv_is_active(lv) &&
-		    !lv_is_active_exclusive_locally(lv) && /* lv_is_active_remotely */
-		    !cluster_mirror_is_available(lv->vg->cmd)) {
-			log_error("Shared cluster mirrors are not available.");
-			return 0;
-		}
-
-		/*
-		 * No mirrored logs for cluster mirrors until
-		 * log daemon is multi-threaded.
-		 */
-		if (log_count > 1) {
-			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors.");
-			return 0;
-		}
-	}
-
 	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm") && cmd->lockd_lv_sh) {
 		if (!cluster_mirror_is_available(cmd)) {
 			log_error("Shared cluster mirrors are not available.");
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 20224d1..80d2e07 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -526,7 +526,7 @@ int create_pool(struct logical_volume *pool_lv,
 		 * or directly converted to invisible device via suspend/resume
 		 */
 		pool_lv->status |= LV_TEMPORARY;
-		if (!activate_lv_excl_local(pool_lv->vg->cmd, pool_lv)) {
+		if (!activate_lv(pool_lv->vg->cmd, pool_lv)) {
 			log_error("Aborting. Failed to activate pool metadata %s.",
 				  display_lvname(pool_lv));
 			goto bad;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 53aa4f1..92e01a2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -319,7 +319,7 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 			return 0;
 		}
 		/* Must get a cluster lock on SubLVs that will be removed. */
-		if (!activate_lv_excl_local(vg->cmd, lvl->lv))
+		if (!activate_lv(vg->cmd, lvl->lv))
 			return_0;
 	}
 
@@ -669,7 +669,7 @@ static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only
 		dm_list_iterate_items(lvl, lv_list) {
 			log_very_verbose("Activating logical volume %s before %s in kernel.",
 					 display_lvname(lvl->lv), display_lvname(lock_lv));
-			if (!activate_lv_excl_local(vg->cmd, lvl->lv)) {
+			if (!activate_lv(vg->cmd, lvl->lv)) {
 				log_error("Failed to activate %s before resuming %s.",
 					  display_lvname(lvl->lv), display_lvname(lock_lv));
 				r = 0; /* But lets try with the rest */
@@ -732,9 +732,9 @@ static int _clear_lvs(struct dm_list *lv_list)
 	was_active = alloca(sz);
 
 	dm_list_iterate_items(lvl, lv_list)
-		if (!(was_active[i++] = lv_is_active_locally(lvl->lv))) {
+		if (!(was_active[i++] = lv_is_active(lvl->lv))) {
 			lvl->lv->status |= LV_TEMPORARY;
-			if (!activate_lv_excl_local(vg->cmd, lvl->lv)) {
+			if (!activate_lv(vg->cmd, lvl->lv)) {
 				log_error("Failed to activate localy %s for clearing.",
 					  display_lvname(lvl->lv));
 				r = 0;
@@ -2276,7 +2276,7 @@ static int _vg_write_lv_suspend_vg_commit(struct logical_volume *lv, int origin_
 /* Helper: function to activate @lv exclusively local */
 static int _activate_sub_lv_excl_local(struct logical_volume *lv)
 {
-	if (lv && !activate_lv_excl_local(lv->vg->cmd, lv)) {
+	if (lv && !activate_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to activate %s.", display_lvname(lv));
 		return 0;
 	}
@@ -3258,16 +3258,6 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, int yes, uint3
 		return r;
 	}
 
-	/*
-	 * LV must be either in-active or exclusively active
-	 */
-	if (lv_is_active(lv_lock_holder(lv)) && vg_is_clustered(lv->vg) &&
-	    !lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-		log_error("%s must be active exclusive locally to "
-			  "perform this operation.", display_lvname(lv));
-		return 0;
-	}
-
 	if (old_count > new_count)
 		return _raid_remove_images(lv, yes, new_count, allocate_pvs, removal_lvs, commit);
 
@@ -3427,13 +3417,13 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
 
 	if (vg_is_shared(lvl->lv->vg)) {
-		if (!lv_active_change(lv->vg->cmd, lvl->lv, CHANGE_AEY, 0))
+		if (!lv_active_change(lv->vg->cmd, lvl->lv, CHANGE_AEY))
 			return_0;
-	} else if (!activate_lv_excl_local(cmd, lvl->lv))
+	} else if (!activate_lv(cmd, lvl->lv))
 		return_0;
 
 	dm_list_iterate_items(lvl, &removal_lvs)
-		if (!activate_lv_excl_local(cmd, lvl->lv))
+		if (!activate_lv(cmd, lvl->lv))
 			return_0;
 
 	if (!resume_lv(cmd, lv_lock_holder(lv))) {
@@ -3539,7 +3529,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 
 	/* Activate the split (and tracking) LV */
 	/* Preserving exclusive local activation also for tracked LV */
-	if (!activate_lv_excl_local(lv->vg->cmd, seg_lv(seg, s)))
+	if (!activate_lv(lv->vg->cmd, seg_lv(seg, s)))
 		return_0;
 
 	if (seg->area_count == 2)
@@ -5001,7 +4991,7 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	/* Grab locks first in case of clustered VG */
 	if (vg_is_clustered(lv->vg))
 		dm_list_iterate_items(lvl, &meta_lvs)
-			if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv))
+			if (!activate_lv(lv->vg->cmd, lvl->lv))
 				return_0;
 	/*
 	 * Now deactivate the MetaLVs before clearing, so
@@ -6520,14 +6510,6 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (vg_is_clustered(lv->vg) &&
-		   !lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-		/* In clustered VGs, the LV must be active on this node exclusively. */
-		log_error("%s must be active exclusive locally to "
-			  "perform this operation.", display_lvname(lv));
-		return 0;
-	}
-
 	new_segtype = new_segtype ? : seg->segtype;
 	if (!new_segtype) {
 		log_error(INTERNAL_ERROR "New segtype not specified.");
@@ -6810,10 +6792,8 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	if (lv_is_partial(lv))
 		lv->vg->cmd->partial_activation = 1;
 
-	if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-		log_error("%s must be active %sto perform this operation.",
-			  display_lvname(lv),
-			  vg_is_clustered(lv->vg) ? "exclusive locally " : "");
+	if (!lv_is_active(lv_lock_holder(lv))) {
+		log_error("%s must be active to perform this operation.", display_lvname(lv));
 		return 0;
 	}
 
@@ -7013,7 +6993,7 @@ try_again:
 	 * of their new names.
 	 */
 	dm_list_iterate_items(lvl, &old_lvs)
-		if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv))
+		if (!activate_lv(lv->vg->cmd, lvl->lv))
 			return_0;
 
 	/*
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e3669ef..5ccf251 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -411,11 +411,5 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 		return 0;
 	}
 
-	if (vg_is_clustered(origin_lv->vg) && lv_is_active(origin_lv) &&
-	    !lv_is_active_exclusive_locally(origin_lv)) {
-		log_error("Snapshot origin must be active exclusively.");
-		return 0;
-	}
-
 	return 1;
 }
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index e1522d3..6b2b1e7 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -504,7 +504,7 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 			 *   as this version has major problem when it does not know
 			 *   which Node has pool active.
 			 */
-			if (!activate_lv_excl(lv->vg->cmd, lv)) {
+			if (!activate_lv(lv->vg->cmd, lv)) {
 				init_dmeventd_monitor(monitored);
 				return_0;
 			}
@@ -857,7 +857,7 @@ int check_new_thin_pool(const struct logical_volume *pool_lv)
 	uint64_t transaction_id;
 
 	/* For transaction_id check LOCAL activation is required */
-	if (!activate_lv_excl_local(cmd, pool_lv)) {
+	if (!activate_lv(cmd, pool_lv)) {
 		log_error("Aborting. Failed to locally activate thin pool %s.",
 			  display_lvname(pool_lv));
 		return 0;
diff --git a/lib/report/report.c b/lib/report/report.c
index 4a957a7..8039820 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3559,11 +3559,7 @@ static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!activation())
 		return _binary_undef_disp(rh, mem, field, private);
 
-	if (vg_is_clustered(lv->vg)) {
-		lv = lv_lock_holder(lv);
-		active_locally = lv_is_active_locally(lv);
-	} else
-		active_locally = lv_is_active(lv);
+	active_locally = lv_is_active(lv);
 
 	return _binary_disp(rh, mem, field, active_locally, GET_FIRST_RESERVED_NAME(lv_active_locally_y), private);
 }
@@ -3572,38 +3568,12 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
 				  struct dm_report_field *field,
 				  const void *data, void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
 	int active_remotely;
 
 	if (!activation())
 		return _binary_undef_disp(rh, mem, field, private);
 
-	if (vg_is_clustered(lv->vg)) {
-		lv = lv_lock_holder(lv);
-		/* FIXME: It seems we have no way to get this info correctly
-		 * 	  with current interface - we'd need to check number
-		 * 	  of responses from the cluster:
-		 * 	    - if number of nodes that responded == 1
-		 * 	    - and LV is active on local node
-		 * 	  ..then we may say that LV is *not* active remotely.
-		 *
-		 * 	  Otherwise ((responses > 1 && LV active locally) ||
-		 * 	  (responses == 1 && LV not active locally)), it's
-		 * 	  active remotely.
-		 *
-		 * 	  We have this info, but hidden underneath the
-		 * 	  locking interface (locking_type.query_resource fn).
-		 *
-		 * 	  For now, let's use 'unknown' for remote status if
-		 * 	  the LV is found active locally until we find a way to
-		 * 	  smuggle the proper information out of the interface.
-		 */
-		if (lv_is_active_locally(lv))
-			return _binary_undef_disp(rh, mem, field, private);
-
-		active_remotely = lv_is_active_but_not_locally(lv);
-	} else
-		active_remotely = 0;
+	active_remotely = 0;
 
 	return _binary_disp(rh, mem, field, active_remotely, GET_FIRST_RESERVED_NAME(lv_active_remotely_y), private);
 }
@@ -3618,11 +3588,7 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!activation())
 		return _binary_undef_disp(rh, mem, field, private);
 
-	if (vg_is_clustered(lv->vg)) {
-		lv = lv_lock_holder(lv);
-		active_exclusively = lv_is_active_exclusive(lv);
-	} else
-		active_exclusively = lv_is_active(lv);
+	active_exclusively = lv_is_active(lv);
 
 	return _binary_disp(rh, mem, field, active_exclusively, GET_FIRST_RESERVED_NAME(lv_active_exclusively_y), private);
 }
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 481cb4c..a90174e 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -294,9 +294,6 @@ static int _reactivate_lv(struct logical_volume *lv,
 	if (!active)
 		return 1;
 
-	if (exclusive)
-		return activate_lv_excl_local(cmd, lv);
-
 	return activate_lv(cmd, lv);
 }
 
@@ -318,7 +315,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_init(&device_list);
 
-	if (lv_is_active_locally(lv)) {
+	if (lv_is_active(lv)) {
 		if (!lv_check_not_in_use(lv, 1)) {
 			log_error("Can't resync open logical volume %s.",
 				  display_lvname(lv));
@@ -335,7 +332,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		}
 
 		active = 1;
-		if (lv_is_active_exclusive_locally(lv))
+		if (lv_is_active(lv))
 			exclusive = 1;
 	}
 
@@ -411,7 +408,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	memlock_unlock(lv->vg->cmd);
 
 	dm_list_iterate_items(lvl, &device_list) {
-		if (!activate_lv_excl_local(cmd, lvl->lv)) {
+		if (!activate_lv(cmd, lvl->lv)) {
 			log_error("Unable to activate %s for %s clearing.",
 				  display_lvname(lvl->lv), (seg_is_raid(seg)) ?
 				  "metadata area" : "mirror log");
@@ -621,7 +618,7 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 
 	if (activate != CHANGE_AN) {
 		log_verbose("Re-activating logical volume %s.", display_lvname(lv));
-		if (!lv_active_change(cmd, lv, activate, 0)) {
+		if (!lv_active_change(cmd, lv, activate)) {
 			log_error("%s: reactivation failed.", display_lvname(lv));
 			backup(lv->vg);
 			return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index aebf3e9..11f7cee 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1767,7 +1767,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
-	if (lv_is_active_locally(cow)) {
+	if (lv_is_active(cow)) {
 		if (!lv_check_not_in_use(cow, 1))
 			return_0;
 
@@ -1950,7 +1950,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		log_warn("WARNING: %s not zeroed.", snap_name);
 	else {
 		lv->status |= LV_TEMPORARY;
-		if (!activate_lv_excl_local(cmd, lv) ||
+		if (!activate_lv(cmd, lv) ||
 		    !wipe_lv(lv, (struct wipe_params) { .do_zero = 1 })) {
 			log_error("Aborting. Failed to wipe snapshot exception store.");
 			return 0;
@@ -2037,7 +2037,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	 * constructor and DM should prevent appropriate devices from
 	 * being open.
 	 */
-	if (lv_is_active_locally(origin)) {
+	if (lv_is_active(origin)) {
 		if (!lv_check_not_in_use(origin, 0)) {
 			log_print_unless_silent("Delaying merge since origin is open.");
 			merge_on_activate = 1;
@@ -2146,7 +2146,7 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 		log_print_unless_silent("Volume %s replaced origin %s.",
 					display_lvname(origin), display_lvname(lv));
 
-		if (origin_is_active && !activate_lv_excl_local(cmd, lv)) {
+		if (origin_is_active && !activate_lv(cmd, lv)) {
 			log_error("Failed to reactivate origin %s.",
 				  display_lvname(lv));
 			return 0;
@@ -2254,13 +2254,13 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!activate_lv_excl_local(cmd, pmslv)) {
+	if (!activate_lv(cmd, pmslv)) {
 		log_error("Cannot activate pool metadata spare volume %s.",
 			  pmslv->name);
 		return 0;
 	}
 
-	if (!activate_lv_excl_local(cmd, mlv)) {
+	if (!activate_lv(cmd, mlv)) {
 		log_error("Cannot activate thin pool metadata volume %s.",
 			  mlv->name);
 		goto deactivate_pmslv;
@@ -2452,13 +2452,13 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!activate_lv_excl_local(cmd, pmslv)) {
+	if (!activate_lv(cmd, pmslv)) {
 		log_error("Cannot activate pool metadata spare volume %s.",
 			  pmslv->name);
 		return 0;
 	}
 
-	if (!activate_lv_excl_local(cmd, mlv)) {
+	if (!activate_lv(cmd, mlv)) {
 		log_error("Cannot activate cache pool metadata volume %s.",
 			  mlv->name);
 		goto deactivate_pmslv;
@@ -3106,7 +3106,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 		if (zero_metadata) {
 			metadata_lv->status |= LV_TEMPORARY;
-			if (!activate_lv_excl_local(cmd, metadata_lv)) {
+			if (!activate_lv(cmd, metadata_lv)) {
 				log_error("Aborting. Failed to activate metadata lv.");
 				goto bad;
 			}
@@ -3248,7 +3248,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	}
 
 	if (activate_pool &&
-	    !activate_lv_excl(cmd, pool_lv)) {
+	    !activate_lv(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s.",
 			  display_lvname(pool_lv));
 		/* Deactivate subvolumes */
@@ -3461,11 +3461,8 @@ static int _lvconvert_repair_pvs_raid(struct cmd_context *cmd, struct logical_vo
 	struct dm_list *failed_pvs;
 	int do_it;
 
-	if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
-		log_error("%s must be active %sto perform this operation.",
-			  display_lvname(lv),
-			  vg_is_clustered(lv->vg) ?
-			  "exclusive locally " : "");
+	if (!lv_is_active(lv_lock_holder(lv))) {
+		log_error("%s must be active to perform this operation.", display_lvname(lv));
 		return 0;
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 5c9d448..4009ea5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1232,13 +1232,13 @@ static int _determine_cache_argument(struct volume_group *vg,
 				return 1;
 
 			} else if (vg_is_shared(vg)) {
-				if (!lv_active_change(cmd, lv, CHANGE_AEY, 0)) {
+				if (!lv_active_change(cmd, lv, CHANGE_AEY)) {
 					log_error("Cannot activate cache origin %s.",
 						   display_lvname(lv));
 					return 0;
 				}
 
-			} else if (!activate_lv_excl_local(cmd, lv)) {
+			} else if (!activate_lv(cmd, lv)) {
 				log_error("Cannot activate cache origin %s.",
 					  display_lvname(lv));
 				return 0;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index bd99c7b..7ad45ca 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -200,7 +200,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		 * If the LV is not active locally, the kernel cannot be
 		 * queried for its status.  We must exit in this case.
 		 */
-		if (!lv_is_active_locally(lv)) {
+		if (!lv_is_active(lv)) {
 			log_print_unless_silent("%s: Interrupted: No longer active.", id->display_name);
 			ret = 1;
 			goto out;
@@ -440,7 +440,7 @@ static int _report_progress(struct cmd_context *cmd, struct poll_operation_id *i
 		goto out;
 	}
 
-	if (!lv_is_active_locally(lv)) {
+	if (!lv_is_active(lv)) {
 		log_verbose("%s: Interrupted: No longer active.", id->display_name);
 		ret = 1;
 		goto out;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 0fcabb3..c5e3929 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -466,8 +466,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			 * in the case it's NOT active anywhere else, since LOCKED LVs cannot be
 			 * later activated by user.
 			 */
-			if (lv_is_active_remotely(holder) ||
-			    (!lv_is_active_locally(holder) && !activate_lv_excl_local(cmd, holder))) {
+			if ((!lv_is_active(holder) && !activate_lv(cmd, holder))) {
 				lv_skipped = 1;
 				log_print_unless_silent("Skipping LV %s which is not locally exclusive%s.",
 							display_lvname(lv),
@@ -532,10 +531,7 @@ static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 {
 	int r = 0;
 
-	if (exclusive || lv_is_active_exclusive(lv_mirr))
-		r = activate_lv_excl(cmd, lv_mirr);
-	else
-		r = activate_lv(cmd, lv_mirr);
+	r = activate_lv(cmd, lv_mirr);
 
 	if (!r)
 		stack;
diff --git a/tools/toollib.c b/tools/toollib.c
index baf84ad..236e2b1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1034,7 +1034,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!lv_active_change(cmd, lv, activate, 0))
+	if (!lv_active_change(cmd, lv, activate))
 		return_0;
 
 	set_lv_notify(lv->vg->cmd);
@@ -1066,7 +1066,7 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	 * - fortunately: polldaemon will immediately shutdown if the
 	 *   origin doesn't have a status with a snapshot percentage
 	 */
-	if (background_polling() && lv_is_merging_origin(lv) && lv_is_active_locally(lv))
+	if (background_polling() && lv_is_merging_origin(lv) && lv_is_active(lv))
 		lv_spawn_background_polling(cmd, lv);
 
 	return 1;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e87277f..a67c3be 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -63,7 +63,7 @@ static int _poll_lvs_in_vg(struct cmd_context *cmd,
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (lv_is_active_locally(lv) &&
+		if (lv_is_active(lv) &&
 		    (lv_is_pvmove(lv) || lv_is_converting(lv) || lv_is_merging(lv))) {
 			lv_spawn_background_polling(cmd, lv);
 			count++;
@@ -116,20 +116,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		expected_count++;
 
-		if (!lv_change_activate(cmd, lv, activate)) {
-			if (!lv_is_active_exclusive_remotely(lv))
-				stack;
-			else {
-				/*
-				 * If the LV is active exclusive remotely,
-				 * then ignore it here
-				 */
-				log_verbose("%s is exclusively active on a remote node.",
-					    display_lvname(lv));
-				expected_count--; /* not accounted */
-			}
+		if (!lv_change_activate(cmd, lv, activate))
 			continue;
-		}
 
 		count++;
 	}


