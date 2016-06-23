From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:55 +0000 (UTC)
Subject: master - lvresize: support more resized LVs
Message-ID: <20160623130155.C1A096090A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7092c6ba1084dcc029ffef918c0419ebdd41b5f4
Commit:        7092c6ba1084dcc029ffef918c0419ebdd41b5f4
Parent:        d44e653fe184a6c179a13998b41e13f737d4926c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 22 23:32:35 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:59:27 2016 +0200

lvresize: support more resized LVs

Add code to support more LVs to be resized through a same code path
using a single lvresize_params struct.
(Now it's used for thin-pool metadata resize,
next user will be snapshot virtual resize).

Update code to adjust percent amount resize for use_policies.

Properly activate inactive thin-pool in case of any pool resize
as the command should not 'deffer' this operation to next activation.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |  221 +++++++++++++++++++++++++----------------------
 2 files changed, 120 insertions(+), 102 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5e2cb5a..a24325f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Pool metadata lvresize uses now same code as resize of normal volume.
   Log system error when locking dir cannot be accessed.
   Preserve monitoring status when updating thin-pool metadata.
   Rerurn 0 (inactive) when status cannot be queried in _lv_active().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e42a73c..17e44cc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4439,7 +4439,7 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 	return exec_cmd(cmd, argv, status, 1);
 }
 
-static int _adjust_amount(dm_percent_t percent, int policy_threshold, int *policy_amount)
+static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int policy_amount)
 {
 	if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
 	    percent <= (policy_threshold * DM_PERCENT_1))
@@ -4452,18 +4452,18 @@ static int _adjust_amount(dm_percent_t percent, int policy_threshold, int *polic
 	percent = (percent / policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
 
 	/* Use it if current policy amount is smaller */
-	if (*policy_amount < percent)
-		*policy_amount = percent;
-
-	return 1;
+	return (policy_amount < percent) ? (uint32_t) policy_amount : (uint32_t) percent;
 }
 
-static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_params *lp)
+static int _lvresize_adjust_policy(const struct logical_volume *lv,
+				   uint32_t *amount, uint32_t *meta_amount)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	dm_percent_t percent;
 	int policy_threshold, policy_amount;
 
+	*amount = *meta_amount = 0;
+
 	if (lv_is_thin_pool(lv)) {
 		policy_threshold =
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
@@ -4488,11 +4488,8 @@ static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_para
 		}
 	}
 
-	if (policy_threshold >= 100) {
-		lp->extents = lp->poolmetadata_size = 0;
-		lp->sizeargs = 0;
+	if (policy_threshold >= 100)
 		return 1; /* nothing to do */
-	}
 
 	if (!policy_amount) {
 		log_error("Can't extend %s with %s autoextend percent set to 0%%.",
@@ -4509,16 +4506,9 @@ static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_para
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;
-		if (_adjust_amount(percent, policy_threshold, &policy_amount)) {
-			if (!thin_pool_feature_supported(lv, THIN_FEATURE_METADATA_RESIZE)) {
-				log_error_once("Online metadata resize for %s is not supported.",
-					       display_lvname(lv));
-				return 0;
-			}
-			lp->poolmetadata_size = (first_seg(lv)->metadata_lv->size *
-						 policy_amount + 99) / 100;
-			lp->poolmetadata_sign = SIGN_PLUS;
-		}
+
+		*meta_amount = _adjust_amount(percent, policy_threshold, policy_amount);
+
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
 	} else {
@@ -4526,11 +4516,7 @@ static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_para
 			return_0;
 	}
 
-	if (!_adjust_amount(percent, policy_threshold, &policy_amount))
-		return 1; /* nothing to do */
-
-	lp->extents = policy_amount;
-	lp->sizeargs = (lp->extents) ? 1 : 0;
+	*amount = _adjust_amount(percent, policy_threshold, policy_amount);
 
 	return 1;
 }
@@ -4646,8 +4632,8 @@ static int _lvresize_poolmetadata(struct logical_volume *pool_lv,
 	return 1;
 }
 
-static int _lvresize_check_lv(struct logical_volume *lv,
-			      struct lvresize_params *lp)
+static int _lvresize_check(struct logical_volume *lv,
+			   struct lvresize_params *lp)
 {
 	struct volume_group *vg = lv->vg;
 
@@ -4884,10 +4870,6 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	uint32_t new_extents;
 	int reducing = 0;
 
-	if (lv_is_thin_pool(lv))
-		/* Manipulate the thin data layer underneath */
-		lv = seg_lv(first_seg(lv), 0);
-
 	seg_last = last_seg(lv);
 
 	/* FIXME Support LVs with mixed segment types */
@@ -5086,12 +5068,6 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	}
 
 	if (lp->extents == existing_logical_extents) {
-		if (lp->poolmetadata_size || lp->use_policies) {
-			/* Signal that normal resizing is not required */
-			lp->sizeargs = 0;
-			return 1;
-		}
-
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, existing_logical_extents);
@@ -5192,8 +5168,9 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 	}
 
 	if (lp->resize == LV_REDUCE) {
-		if (lv_is_thin_pool(lv)) {
-			log_error("Thin pool volumes cannot be reduced in size yet.");
+		if (lv_is_thin_pool_data(lv)) {
+			log_error("Thin pool volumes %s cannot be reduced in size yet.",
+				  display_lvname(lv));
 			return 0;
 		}
 		if (lv_is_thin_pool_metadata(lv)) {
@@ -5201,6 +5178,13 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 			return 0;
 		}
 	} else if (lp->resize == LV_EXTEND)  {
+		if (lv_is_thin_pool_metadata(lv) &&
+		    !thin_pool_feature_supported(find_pool_seg(first_seg(lv))->lv, THIN_FEATURE_METADATA_RESIZE)) {
+			log_error("Support for online metadata resize of %s not detected.",
+				  display_lvname(lv));
+			return 0;
+		}
+
 		/* Validate thin target supports bigger size of thin volume then external origin */
 		if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
 		    (lv->size > first_seg(lv)->external_lv->size) &&
@@ -5220,18 +5204,9 @@ static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 	struct cmd_context *cmd = vg->cmd;
 	struct logical_volume *lock_lv = NULL;
-	struct lv_segment *seg = NULL;
 	uint32_t old_extents;
 	int status;
-	alloc_policy_t alloc;
-
-	if (lv_is_thin_pool(lv)) {
-		lock_lv = lv;
-		seg = first_seg(lv);
-		/* Switch to layered LV resizing */
-		lv = seg_lv(seg, 0);
-	}
-	alloc = lp->alloc ? : lv->alloc;
+	alloc_policy_t alloc = lp->alloc ? : lv->alloc;
 
 	if ((lp->resize == LV_REDUCE) && (pvh != &vg->pvs))
 		log_print_unless_silent("Ignoring PVs on command line when reducing.");
@@ -5307,81 +5282,106 @@ static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 	return lock_lv;
 }
 
-static int _lvresize_prepare(struct logical_volume *lv,
+static int _lvresize_prepare(struct logical_volume **lv,
 			     struct lvresize_params *lp,
 			     struct dm_list *pvh)
 {
-	if (!_lvresize_check_lv(lv, lp))
-		return_0;
+	struct volume_group *vg = (*lv)->vg;
 
-	if (lp->use_policies && !_adjust_policy_params(lv, lp))
-		return_0;
+	if (lv_is_thin_pool(*lv))
+		*lv = seg_lv(first_seg(*lv), 0); /* switch to data LV */
 
-	if (lp->size && !_lvresize_adjust_size(lv->vg, lp->size, lp->sign,
-					       &lp->extents))
-		return_0;
-	else if (lp->extents && !_lvresize_extents_from_percent(lv, lp, pvh))
+	/* Resolve extents from size */
+	if (lp->size && !_lvresize_adjust_size(vg, lp->size, lp->sign, &lp->extents))
 		return_0;
-
-	if (lp->extents && !_lvresize_adjust_extents(lv, lp, pvh))
+	else if (lp->extents && !_lvresize_extents_from_percent(*lv, lp, pvh))
 		return_0;
 
-	if ((lp->extents == lv->le_count) && lp->use_policies) {
-		/* Nothing to do. */
-		lp->sizeargs = 0;
-		lp->poolmetadata_size = 0;
-	}
-
-	if (lp->extents && !_lvresize_check_type(lv, lp))
+	if (lp->extents && !_lvresize_adjust_extents(*lv, lp, pvh))
 		return_0;
 
-	if (lp->poolmetadata_size &&
-	    !_lvresize_poolmetadata_prepare(lv, lp))
+	if (lp->extents && !_lvresize_check_type(*lv, lp))
 		return_0;
 
 	return 1;
 }
 
+/* Set aux LV properties, we can't use those from command line */
+static struct logical_volume *_lvresize_setup_aux(struct logical_volume *lv,
+						  struct lvresize_params *lp)
+{
+	struct lv_segment *mseg = last_seg(lv);
+
+	lp->alloc = lv->alloc;
+	lp->mirrors = seg_is_mirrored(mseg) ? lv_mirror_count(lv) : 0;
+	lp->resizefs = 0;
+	lp->stripes = lp->mirrors ? mseg->area_count / lp->mirrors : 0;
+	lp->stripe_size = mseg->stripe_size;
+
+	return lv;
+}
+
 int lv_resize(struct logical_volume *lv,
 	      struct lvresize_params *lp,
 	      struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
 	struct cmd_context *cmd = vg->cmd;
-	struct logical_volume *lock_lv = NULL;
-	int inactive = 0;
+	struct logical_volume *lock_lv = (struct logical_volume*) lv_lock_holder(lv);
+	struct logical_volume *aux_lv = NULL; /* Note: aux_lv never resizes fs */
+	struct lvresize_params aux_lp;
+	int activated = 0;
+	int ret = 0;
 
-	if (!_lvresize_prepare(lv, lp, pvh))
+	if (!_lvresize_check(lv, lp))
 		return_0;
 
-	if (lv_is_cache_type(lv)) {
-		log_error("Unable to resize logical volumes of cache type.");
-		return 0;
+	if (lp->use_policies) {
+		lp->percent = SIGN_PLUS;
+		aux_lp = *lp;
+		if (!_lvresize_adjust_policy(lv, &lp->extents, &aux_lp.extents))
+			return_0;
+
+		if (!lp->extents) {
+			if (!aux_lp.extents)
+				return 1;  /* Nothing to do */
+			/* Resize thin-pool metadata as mainlv */
+			lv = first_seg(lv)->metadata_lv; /* metadata LV */
+			lp->extents = aux_lp.extents;
+		} else if (aux_lp.extents) {
+			/* Also resize thin-pool metadata */
+			aux_lv = _lvresize_setup_aux(first_seg(lv)->metadata_lv, &aux_lp);
+		}
+	} else if (lp->poolmetadata_size) {
+		if (!lp->extents && !lp->size) {
+			/* When only --poolmetadatasize give and not --size
+			 * swith directly to resize metadata LV */
+			lv = first_seg(lv)->metadata_lv;
+			lp->size = lp->poolmetadata_size;
+			lp->sign = lp->poolmetadata_sign;
+		} else {
+			aux_lp = *lp;
+			aux_lv = _lvresize_setup_aux(first_seg(lv)->metadata_lv, &aux_lp);
+			aux_lp.size = lp->poolmetadata_size;
+			aux_lp.sign = lp->poolmetadata_sign;
+		}
 	}
 
-	/*
-	 * If the LV is locked from activation, this lock call is a no-op.
-	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT).
-	 */
-	if (!lockd_lv(cmd, lv, "ex", 0))
+	if (aux_lv && !_lvresize_prepare(&aux_lv, &aux_lp, pvh))
 		return_0;
 
-	if (lp->extents &&
-	    !(lock_lv = _lvresize_volume(lv, lp, pvh)))
+	if (!_lvresize_prepare(&lv, lp, pvh))
 		return_0;
 
-	if (lp->poolmetadataextents) {
-		if (!_lvresize_poolmetadata(lv, lp, pvh))
-			return_0;
-		lock_lv = lv;
-	}
-
-	if (!lock_lv)
-		return 1; /* Nothing to do */
-
-	if (lv_is_thin_pool(lock_lv) &&
-	    pool_is_active(lock_lv) &&
+	if (lv_is_thin_pool(lock_lv) &&  /* Lock holder is thin-pool */
 	    !lv_is_active(lock_lv)) {
+
+		if (!activation()) {
+			log_error("Cannot resize %s without using "
+				  "device-mapper kernel driver.",
+				  display_lvname(lock_lv));
+			return 0;
+		}
 		/*
 		 * Active 'hidden' -tpool can be waiting for resize, but the
 		 * pool LV itself might be inactive.
@@ -5390,13 +5390,33 @@ int lv_resize(struct logical_volume *lv,
 		 * then use suspend and resume and deactivate pool LV,
 		 * instead of searching for an active thin volume.
 		 */
-		inactive = 1;
 		if (!activate_lv_excl(cmd, lock_lv)) {
 			log_error("Failed to activate %s.", display_lvname(lock_lv));
 			return 0;
 		}
+
+		activated = 1;
 	}
 
+	/*
+	 * If the LV is locked from activation, this lock call is a no-op.
+	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT).
+	 */
+	if (!lockd_lv(cmd, lock_lv, "ex", 0))
+		return_0;
+
+	if (aux_lv) {
+		if (!_lvresize_volume(aux_lv, &aux_lp, pvh))
+			goto_bad;
+
+		/* store vg on disk(s) */
+		if (!lv_update_and_reload(lock_lv))
+			goto_bad;
+	}
+
+	if (!_lvresize_volume(lv, lp, pvh))
+		goto_bad;
+
 	/* store vg on disk(s) */
 	if (!lv_update_and_reload(lock_lv))
 		goto_bad;
@@ -5411,11 +5431,6 @@ int lv_resize(struct logical_volume *lv,
 			goto_bad;
 
 		backup(vg);
-
-		if (inactive && !deactivate_lv(cmd, lock_lv)) {
-			log_error("Problem deactivating %s.", display_lvname(lock_lv));
-			return 0;
-		}
 	}
 
 	log_print_unless_silent("Logical volume %s successfully resized.",
@@ -5425,12 +5440,14 @@ int lv_resize(struct logical_volume *lv,
 	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL))
 		return_0;
 
-	return 1;
+	ret = 1;
 bad:
-	if (inactive && !deactivate_lv(cmd, lock_lv))
+	if (activated && !deactivate_lv(cmd, lock_lv)) {
 		log_error("Problem deactivating %s.", display_lvname(lock_lv));
+		ret = 0;
+	}
 
-	return 0;
+	return ret;
 }
 
 char *generate_lv_name(struct volume_group *vg, const char *format,


