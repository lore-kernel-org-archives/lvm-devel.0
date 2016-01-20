From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:54:00 +0000 (UTC)
Subject: master - cleanup: drop extra cmd passed arg
Message-ID: <20160120125400.F2E0E60D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b5a8f61a79c88e9a99f3cec590163a143e70237
Commit:        7b5a8f61a79c88e9a99f3cec590163a143e70237
Parent:        b64703401da1f4bef60579a0b3766c087fcfe96a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 18 23:24:32 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: drop extra cmd passed arg

Use vg->cmd when needed cmd struct.
---
 lib/metadata/lv_manip.c |   55 ++++++++++++++++++++++------------------------
 1 files changed, 26 insertions(+), 29 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4507f8e..b67a2b7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4273,14 +4273,13 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 #define SIZE_BUF 128
 
 /* TODO: unify stripe size validation across source code */
-static int _validate_stripesize(struct cmd_context *cmd,
-				const struct volume_group *vg,
+static int _validate_stripesize(const struct volume_group *vg,
 				struct lvresize_params *lp)
 {
 
 	if (lp->ac_stripesize_value > (STRIPE_SIZE_LIMIT * 2)) {
 		log_error("Stripe size cannot be larger than %s.",
-			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
+			  display_size(vg->cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
 	}
 
@@ -4289,8 +4288,8 @@ static int _validate_stripesize(struct cmd_context *cmd,
 	else if (lp->ac_stripesize_value > vg->extent_size) {
 		log_print_unless_silent("Reducing stripe size %s to maximum, "
 					"physical extent size %s.",
-					display_size(cmd, lp->ac_stripesize_value),
-					display_size(cmd, vg->extent_size));
+					display_size(vg->cmd, lp->ac_stripesize_value),
+					display_size(vg->cmd, vg->extent_size));
 		lp->stripe_size = vg->extent_size;
 	} else
 		lp->stripe_size = lp->ac_stripesize_value;
@@ -4303,14 +4302,13 @@ static int _validate_stripesize(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _request_confirmation(struct cmd_context *cmd,
-				 const struct volume_group *vg,
+static int _request_confirmation(const struct volume_group *vg,
 				 const struct logical_volume *lv,
 				 const struct lvresize_params *lp)
 {
 	struct lvinfo info = { 0 };
 
-	if (!lv_info(cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
+	if (!lv_info(vg->cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
 		log_error("lv_info failed: aborting");
 		return 0;
 	}
@@ -4329,7 +4327,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 
 	log_warn("WARNING: Reducing active%s logical volume to %s",
 		 info.open_count ? " and open" : "",
-		 display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+		 display_size(vg->cmd, (uint64_t) lp->extents * vg->extent_size));
 
 	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
 
@@ -4424,9 +4422,9 @@ static int _adjust_amount(dm_percent_t percent, int policy_threshold, int *polic
 	return 1;
 }
 
-static int _adjust_policy_params(struct cmd_context *cmd,
-				 struct logical_volume *lv, struct lvresize_params *lp)
+static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_params *lp)
 {
+	struct cmd_context *cmd = lv->vg->cmd;
 	dm_percent_t percent;
 	int policy_threshold, policy_amount;
 
@@ -4529,9 +4527,8 @@ static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 	return 0;
 }
 
-static int _lvresize_poolmetadata_prepare(struct cmd_context *cmd,
-					  struct lvresize_params *lp,
-					  const struct logical_volume *pool_lv)
+static int _lvresize_poolmetadata_prepare(struct logical_volume *pool_lv,
+					  struct lvresize_params *lp)
 {
 	uint32_t extents;
 	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
@@ -4548,7 +4545,7 @@ static int _lvresize_poolmetadata_prepare(struct cmd_context *cmd,
 		lp->poolmetadatasize += vg->extent_size -
 			(lp->poolmetadatasize % vg->extent_size);
 		log_print_unless_silent("Rounding pool metadata size to boundary between physical extents: %s",
-					display_size(cmd, lp->poolmetadatasize));
+					display_size(vg->cmd, lp->poolmetadatasize));
 	}
 
 	if (!(extents = extents_from_size(vg->cmd, lp->poolmetadatasize,
@@ -4574,7 +4571,7 @@ static int _lvresize_poolmetadata_prepare(struct cmd_context *cmd,
 	/* FIXME Split here and move validation code earlier alongside rest of validation code */
 	if (extents == lv->le_count) {
 		log_print_unless_silent("Metadata volume %s has already %s.",
-					lv->name, display_size(cmd, lv->size));
+					display_lvname(lv), display_size(vg->cmd, lv->size));
 		return 2;
 	}
 
@@ -4583,12 +4580,12 @@ static int _lvresize_poolmetadata_prepare(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *vg,
+static int _lvresize_poolmetadata(struct logical_volume *pool_lv,
 				  struct lvresize_params *lp,
-				  const struct logical_volume *pool_lv,
 				  struct dm_list *pvh)
 {
 	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
+	struct volume_group *vg = lv->vg;
 	alloc_policy_t alloc = lp->ac_alloc ? : lv->alloc;
 	struct lv_segment *mseg = last_seg(lv);
 	uint32_t seg_mirrors = lv_mirror_count(lv);
@@ -4597,8 +4594,8 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 		return_0;
 
 	log_print_unless_silent("Extending logical volume %s to %s.",
-				lv->name,
-				display_size(cmd, (uint64_t) lp->poolmetadataextents *
+				display_lvname(lv),
+				display_size(vg->cmd, (uint64_t) lp->poolmetadataextents *
 					     vg->extent_size));
 	if (!lv_extend(lv,
 		       mseg->segtype,
@@ -4613,7 +4610,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 	return 1;
 }
 
-static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv,
+static int _lvresize_check_lv(struct logical_volume *lv,
 			      struct lvresize_params *lp)
 {
 	struct volume_group *vg = lv->vg;
@@ -4669,7 +4666,7 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		return 0;
 	}
 
-	if (lp->ac_stripesize && !_validate_stripesize(cmd, vg, lp))
+	if (lp->ac_stripesize && !_validate_stripesize(vg, lp))
 		return_0;
 
 	if (lp->ac_stripes) {
@@ -5126,7 +5123,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	return 1;
 }
 
-static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_volume *lv,
+static int _lvresize_check_type(const struct logical_volume *lv,
 				struct lvresize_params *lp)
 {
 	if (lv_is_origin(lv)) {
@@ -5194,7 +5191,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 
 	/* Request confirmation before operations that are often mistakes. */
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
-	    !_request_confirmation(cmd, vg, lv, lp))
+	    !_request_confirmation(vg, lv, lp))
 		return_NULL;
 
 	if (lp->resizefs) {
@@ -5264,10 +5261,10 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvresize_params *lp, struct dm_list *pvh)
 {
-	if (!_lvresize_check_lv(cmd, lv, lp))
+	if (!_lvresize_check_lv(lv, lp))
 		return_0;
 
-	if (lp->ac_policy && !_adjust_policy_params(cmd, lv, lp))
+	if (lp->ac_policy && !_adjust_policy_params(lv, lp))
 		return_0;
 
 	if (lp->size && !_lvresize_adjust_size(lv->vg, lp->size, lp->sign,
@@ -5285,11 +5282,11 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 		lp->poolmetadatasize = 0;
 	}
 
-	if (lp->extents && !_lvresize_check_type(cmd, lv, lp))
+	if (lp->extents && !_lvresize_check_type(lv, lp))
 		return_0;
 
 	if (lp->poolmetadatasize &&
-	    !_lvresize_poolmetadata_prepare(cmd, lp, lv))
+	    !_lvresize_poolmetadata_prepare(lv, lp))
 		return_0;
 
 	return 1;
@@ -5320,7 +5317,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (lp->poolmetadataextents) {
-		if (!_lvresize_poolmetadata(cmd, vg, lp, lv, pvh))
+		if (!_lvresize_poolmetadata(lv, lp, pvh))
 			return_0;
 		lock_lv = lv;
 	}


