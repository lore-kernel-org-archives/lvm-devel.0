From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:04 +0000 (UTC)
Subject: master - lvm2app: Rework argument handling for lv resize
Message-ID: <20130702192604.AB13E60D30@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d550cfc36ffb13fa0c70c077add7d8d8957180f
Commit:        9d550cfc36ffb13fa0c70c077add7d8d8957180f
Parent:        60c78e6aef9b744d6313ac0cf3ebb62b74066eb3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jan 8 16:39:00 2013 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:33 2013 -0500

lvm2app: Rework argument handling for lv resize

Extend the lv resize parameter structure to contain everything
the re-size functions need so that the command line does not
need to be present for lower level calls when we call from
library functions.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 tools/lvresize.c |  116 ++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 79 insertions(+), 37 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 47cb6aa..f08fa91 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -47,18 +47,28 @@ struct lvresize_params {
 
 	int argc;
 	char **argv;
+
+	/* Arg counts & values */
+	unsigned ac_policy;
+	unsigned ac_stripes;
+	uint32_t ac_stripes_value;
+	unsigned ac_mirrors;
+	uint32_t ac_mirrors_value;
+	unsigned ac_stripesize;
+	uint64_t ac_stripesize_value;
+	unsigned ac_alloc;
+	unsigned ac_no_sync;
+	unsigned ac_force;
+
+	const char *ac_type;
 };
 
 static int _validate_stripesize(struct cmd_context *cmd,
 				const struct volume_group *vg,
 				struct lvresize_params *lp)
 {
-	if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Stripesize may not be negative.");
-		return 0;
-	}
 
-	if (arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
+	if ( lp->ac_stripesize_value > STRIPE_SIZE_LIMIT * 2) {
 		log_error("Stripe size cannot be larger than %s",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
@@ -66,15 +76,14 @@ static int _validate_stripesize(struct cmd_context *cmd,
 
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 		log_warn("Varied stripesize not supported. Ignoring.");
-	else if (arg_uint_value(cmd, stripesize_ARG, 0) > (uint64_t) vg->extent_size * 2) {
+	else if (lp->ac_stripesize_value > (uint64_t) vg->extent_size * 2) {
 		log_error("Reducing stripe size %s to maximum, "
 			  "physical extent size %s",
-			  display_size(cmd,
-				       (uint64_t) arg_uint_value(cmd, stripesize_ARG, 0)),
+			  display_size(cmd,lp->ac_stripesize_value),
 			  display_size(cmd, (uint64_t) vg->extent_size));
 		lp->stripe_size = vg->extent_size;
 	} else
-		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
+		lp->stripe_size = lp->ac_stripesize_value;
 
 	if (lp->stripe_size & (lp->stripe_size - 1)) {
 		log_error("Stripe size must be power of 2");
@@ -114,7 +123,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 
 	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
 
-	if (!arg_count(cmd, force_ARG)) {
+	if (!lp->ac_force) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
 				  lp->lv_name) == 'n') {
 			log_error("Logical volume %s NOT reduced", lp->lv_name);
@@ -155,7 +164,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	if (verbose_level() >= _LOG_NOTICE)
 		argv[i++] = "--verbose";
 
-	if (arg_count(cmd, force_ARG))
+	if (lp->ac_force)
 		argv[i++] = "--force";
 
 	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
@@ -295,6 +304,43 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->argc = argc;
 	lp->argv = argv;
 
+	lp->ac_policy = arg_count(cmd, use_policies_ARG);
+	lp->ac_stripes = arg_count(cmd, stripes_ARG);
+	if (lp->ac_stripes) {
+		lp->ac_stripes_value = arg_uint_value(cmd, stripes_ARG, 1);
+	} else {
+		lp->ac_stripes_value = 0;
+	}
+
+	lp->ac_mirrors = arg_count(cmd, mirrors_ARG);
+
+	if (lp->ac_mirrors) {
+		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Mirrors argument may not be negative");
+			return 0;
+		}
+
+		lp->ac_mirrors_value = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
+	} else {
+		lp->ac_mirrors_value = 0;
+	}
+
+	lp->ac_stripesize = arg_count(cmd, stripesize_ARG);
+	if (lp->ac_stripesize) {
+		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Stripesize may not be negative.");
+			return 0;
+		}
+
+		lp->ac_stripesize_value = arg_uint64_value(cmd, stripesize_ARG, 0);
+	}
+
+	lp->ac_no_sync = arg_count(cmd, nosync_ARG);
+	lp->ac_alloc = arg_uint_value(cmd, alloc_ARG, 0);
+
+	lp->ac_type = arg_str_value(cmd, type_ARG, NULL);
+	lp->ac_force = arg_count(cmd, force_ARG);
+
 	return 1;
 }
 
@@ -456,7 +502,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 }
 
 static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
-		     struct lvresize_params *lp)
+		     struct lvresize_params *lp, struct dm_list *pvh)
 {
 	struct logical_volume *lv;
 	uint32_t stripesize_extents;
@@ -472,8 +518,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t seg_extents;
 	uint32_t sz, str;
 	int status;
-	struct dm_list *pvh = NULL;
-	int use_policy = arg_count(cmd, use_policies_ARG);
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
@@ -506,29 +550,25 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, stripes_ARG)) {
+	if (lp->ac_stripes) {
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
-			lp->stripes = arg_uint_value(cmd, stripes_ARG, 1);
+			lp->stripes = lp->ac_stripes_value;
 		else
 			log_warn("Varied striping not supported. Ignoring.");
 	}
 
-	if (arg_count(cmd, mirrors_ARG)) {
+	if (lp->ac_mirrors) {
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
-			lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
+			lp->mirrors = lp->ac_mirrors_value;
 		else
 			log_warn("Mirrors not supported. Ignoring.");
-		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Mirrors argument may not be negative");
-			return EINVALID_CMD_LINE;
-		}
 	}
 
-	if (arg_count(cmd, stripesize_ARG) &&
+	if (lp->ac_stripesize &&
 	    !_validate_stripesize(cmd, vg, lp))
 		return EINVALID_CMD_LINE;
 
-	if (use_policy) {
+	if (lp->ac_policy) {
 		if (!lv_is_cow(lv) &&
 		    !lv_is_thin_pool(lv)) {
 			log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
@@ -554,7 +594,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lv->alloc);
+	alloc = (alloc_policy_t)(lp->ac_alloc)?lp->ac_alloc: lv->alloc;
 
 	/*
 	 * First adjust to an exact multiple of extent size.
@@ -577,10 +617,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		lp->extents = lp->size / vg->extent_size;
 	}
 
-	if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc,
-						     lp->argv, 1) : &vg->pvs))
-		return_ECMD_FAILED;
-
 	if (lp->sizeargs) { /* TODO: reindent or move to function */
 
 	switch(lp->percent) {
@@ -655,7 +691,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			lp->sizeargs = 0;
 			goto metadata_resize;
 		}
-		if (use_policy)
+		if (lp->ac_policy)
 			return ECMD_PROCESSED; /* Nothing to do. */
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
@@ -671,8 +707,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	lp->segtype = last_seg(lv)->segtype;
 
 	/* FIXME Support LVs with mixed segment types */
-	if (lp->segtype != get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG,
-								      lp->segtype->name))) {
+	if (lp->segtype != get_segtype_from_string(cmd, (lp->ac_type)?lp->ac_type:lp->segtype->name)) {
 		log_error("VolumeType does not match (%s)", lp->segtype->name);
 		return EINVALID_CMD_LINE;
 	}
@@ -683,7 +718,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		 * Has the user specified that they would like the additional
 		 * extents of a mirror not to have an initial sync?
 		 */
-		if (seg_is_mirrored(first_seg(lv)) && arg_count(cmd, nosync_ARG))
+		if (seg_is_mirrored(first_seg(lv)) && lp->ac_no_sync)
 			lv->status |= LV_NOTSYNCED;
 
 		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
@@ -694,12 +729,12 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			break;
 		}
 
-		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
+		if (!lp->ac_mirrors && seg_mirrors) {
 			log_print_unless_silent("Extending %" PRIu32 " mirror images.",
 						seg_mirrors);
 			lp->mirrors = seg_mirrors;
 		}
-		if ((arg_count(cmd, mirrors_ARG) || seg_mirrors) &&
+		if ((lp->ac_mirrors || seg_mirrors) &&
 		    (lp->mirrors != seg_mirrors)) {
 			log_error("Cannot vary number of mirrors in LV yet.");
 			return EINVALID_CMD_LINE;
@@ -847,7 +882,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		}
 		lp->resize = LV_EXTEND;
 	} else if (lp->extents == lv->le_count) {
-		if (use_policy)
+		if (lp->ac_policy)
 			return ECMD_PROCESSED; /* Nothing to do. */
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
@@ -1011,6 +1046,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct lvresize_params lp = { 0 };
 	struct volume_group *vg;
 	int r;
+	struct dm_list *pvh = NULL;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
@@ -1022,7 +1058,13 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	if (!(r = _lvresize(cmd, vg, &lp)))
+	/* How does this list get cleaned up? */
+	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
+						     lp.argv, 1) : &vg->pvs)) {
+		return_ECMD_FAILED;
+	}
+
+	if (!(r = _lvresize(cmd, vg, &lp, pvh)))
 		stack;
 
 	unlock_and_release_vg(cmd, vg, lp.vg_name);


