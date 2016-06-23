From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:47 +0000 (UTC)
Subject: master - lvresize: update lvresize_params struct
Message-ID: <20160623130147.79D0A608F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f45b68940667563e1a8d3bbd5d30864c04381bdf
Commit:        f45b68940667563e1a8d3bbd5d30864c04381bdf
Parent:        698082e67875fe71970fb932ffe2170d777f2807
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 17 13:25:41 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:09 2016 +0200

lvresize: update lvresize_params struct

Reorganise  struct lvresize_params to better fit lvresize needs to be
able to resize more then just a single LV.
---
 lib/locking/lvmlockd.c           |    2 +-
 lib/metadata/lv_manip.c          |   98 ++++++++++++++--------------
 lib/metadata/metadata-exported.h |   52 +++++++---------
 liblvm/lvm_lv.c                  |    2 +-
 tools/lvresize.c                 |  128 +++++++++++++++----------------------
 5 files changed, 126 insertions(+), 156 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 9eb7f92..e2b3e25 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -372,7 +372,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.size = lv->size + ((extend_mb * 1024 * 1024) / SECTOR_SIZE),
 		.percent = PERCENT_NONE,
 		.resize = LV_EXTEND,
-		.ac_force = 1,
+		.force = 1,
 		.sizeargs = 1,
 	};
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9f0d06d..562047c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4314,23 +4314,19 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 static int _validate_stripesize(const struct volume_group *vg,
 				struct lvresize_params *lp)
 {
-
-	if (lp->ac_stripesize_value > (STRIPE_SIZE_LIMIT * 2)) {
+	if (lp->stripe_size > (STRIPE_SIZE_LIMIT * 2)) {
 		log_error("Stripe size cannot be larger than %s.",
 			  display_size(vg->cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
 	}
 
-	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-		log_print_unless_silent("Varied stripesize not supported. Ignoring.");
-	else if (lp->ac_stripesize_value > vg->extent_size) {
+	if (lp->stripe_size > vg->extent_size) {
 		log_print_unless_silent("Reducing stripe size %s to maximum, "
 					"physical extent size %s.",
-					display_size(vg->cmd, lp->ac_stripesize_value),
+					display_size(vg->cmd, lp->stripe_size),
 					display_size(vg->cmd, vg->extent_size));
 		lp->stripe_size = vg->extent_size;
-	} else
-		lp->stripe_size = lp->ac_stripesize_value;
+	}
 
 	if (lp->stripe_size & (lp->stripe_size - 1)) {
 		log_error("Stripe size must be power of 2.");
@@ -4370,7 +4366,7 @@ static int _request_confirmation(const struct volume_group *vg,
 
 	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
 
-	if (!lp->ac_force) {
+	if (!lp->force) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
 				  display_lvname(lv)) == 'n') {
 			log_error("Logical volume %s NOT reduced.",
@@ -4410,7 +4406,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	if (verbose_level() >= _LOG_NOTICE)
 		argv[i++] = "--verbose";
 
-	if (lp->ac_force)
+	if (lp->force)
 		argv[i++] = "--force";
 
 	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
@@ -4491,7 +4487,7 @@ static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_para
 	}
 
 	if (policy_threshold >= 100) {
-		lp->extents = lp->poolmetadatasize = 0;
+		lp->extents = lp->poolmetadata_size = 0;
 		lp->sizeargs = 0;
 		return 1; /* nothing to do */
 	}
@@ -4517,9 +4513,9 @@ static int _adjust_policy_params(struct logical_volume *lv, struct lvresize_para
 					       display_lvname(lv));
 				return 0;
 			}
-			lp->poolmetadatasize = (first_seg(lv)->metadata_lv->size *
-						policy_amount + 99) / 100;
-			lp->poolmetadatasign = SIGN_PLUS;
+			lp->poolmetadata_size = (first_seg(lv)->metadata_lv->size *
+						 policy_amount + 99) / 100;
+			lp->poolmetadata_sign = SIGN_PLUS;
 		}
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
@@ -4579,18 +4575,18 @@ static int _lvresize_poolmetadata_prepare(struct logical_volume *pool_lv,
 		return 0;
 	}
 
-	if (lp->poolmetadatasize % vg->extent_size) {
-		lp->poolmetadatasize += vg->extent_size -
-			(lp->poolmetadatasize % vg->extent_size);
+	if (lp->poolmetadata_size % vg->extent_size) {
+		lp->poolmetadata_size += vg->extent_size -
+			(lp->poolmetadata_size % vg->extent_size);
 		log_print_unless_silent("Rounding pool metadata size to boundary between physical extents: %s",
-					display_size(vg->cmd, lp->poolmetadatasize));
+					display_size(vg->cmd, lp->poolmetadata_size));
 	}
 
-	if (!(extents = extents_from_size(vg->cmd, lp->poolmetadatasize,
+	if (!(extents = extents_from_size(vg->cmd, lp->poolmetadata_size,
 					  vg->extent_size)))
 		return_0;
 
-	if (lp->poolmetadatasign == SIGN_PLUS) {
+	if (lp->poolmetadata_sign == SIGN_PLUS) {
 		if (extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
 			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
 				  lv->name, lv->le_count, MAX_EXTENT_COUNT);
@@ -4624,7 +4620,7 @@ static int _lvresize_poolmetadata(struct logical_volume *pool_lv,
 {
 	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
 	struct volume_group *vg = lv->vg;
-	alloc_policy_t alloc = lp->ac_alloc ? : lv->alloc;
+	alloc_policy_t alloc = lp->alloc ? : lv->alloc;
 	struct lv_segment *mseg = last_seg(lv);
 	uint32_t seg_mirrors = lv_mirror_count(lv);
 
@@ -4676,7 +4672,7 @@ static int _lvresize_check_lv(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lp->ac_policy && !lv_is_cow(lv) && !lv_is_thin_pool(lv)) {
+	if (lp->use_policies && !lv_is_cow(lv) && !lv_is_thin_pool(lv)) {
 		log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
 		return 0;
 	}
@@ -4699,13 +4695,18 @@ static int _lvresize_check_lv(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!lv_is_thin_pool(lv) && lp->poolmetadatasize) {
+	if (!lv_is_thin_pool(lv) && lp->poolmetadata_size) {
 		log_error("--poolmetadatasize can be used only with thin pools.");
 		return 0;
 	}
 
-	if (lp->ac_stripesize && !_validate_stripesize(vg, lp))
-		return_0;
+	if (lp->stripe_size) {
+		if (!(vg->fid->fmt->features & FMT_SEGMENTS)) {
+			log_print_unless_silent("Varied stripesize not supported. Ignoring.");
+			lp->stripe_size = lp->stripes = 0;
+		} else if (!_validate_stripesize(vg, lp))
+			return_0;
+	}
 
 	if (lp->resizefs &&
 	    (lv_is_thin_pool(lv) ||
@@ -4718,18 +4719,16 @@ static int _lvresize_check_lv(struct logical_volume *lv,
 		lp->resizefs = 0;
 	}
 
-	if (lp->ac_stripes) {
-		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-			log_print_unless_silent("Varied striping not supported. Ignoring.");
-		else
-			lp->stripes = lp->ac_stripes_value;
+	if (lp->stripes &&
+	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
+		log_print_unless_silent("Varied striping not supported. Ignoring.");
+		lp->stripes = 0;
 	}
 
-	if (lp->ac_mirrors) {
-		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-			log_print_unless_silent("Mirrors not supported. Ignoring.");
-		else
-			lp->mirrors = lp->ac_mirrors_value;
+	if (lp->mirrors &&
+	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
+		log_print_unless_silent("Mirrors not supported. Ignoring.");
+		lp->mirrors = 0;
 	}
 
 	return 1;
@@ -4885,15 +4884,16 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		lv = seg_lv(first_seg(lv), 0);
 
 	seg_last = last_seg(lv);
-	/* Use segment type of last segment */
-	lp->segtype = seg_last->segtype;
 
 	/* FIXME Support LVs with mixed segment types */
-	if (lp->segtype != get_segtype_from_string(cmd, lp->ac_type ? : lp->segtype->name)) {
+	if (lp->segtype && (lp->segtype != seg_last->segtype)) {
 		log_error("VolumeType does not match (%s).", lp->segtype->name);
 		return 0;
 	}
 
+	/* Use segment type of last segment */
+	lp->segtype = seg_last->segtype;
+
 	/* For virtual devices, just pretend the physical size matches. */
 	existing_physical_extents = saved_existing_physical_extents = _lv_pe_count(lv);
 	if (!existing_physical_extents) {
@@ -4913,10 +4913,10 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	if (!reducing) {
 		seg_mirrors = seg_is_mirrored(seg_last) ? lv_mirror_count(lv) : 0;
 
-		if (!lp->ac_mirrors && seg_mirrors) {
+		if (!lp->mirrors && seg_mirrors) {
 			log_print_unless_silent("Extending %" PRIu32 " mirror images.", seg_mirrors);
 			lp->mirrors = seg_mirrors;
-		} else if ((lp->ac_mirrors || seg_mirrors) && (lp->mirrors != seg_mirrors)) {
+		} else if ((lp->mirrors || seg_mirrors) && (lp->mirrors != seg_mirrors)) {
 			log_error("Cannot vary number of mirrors in LV yet.");
 			return 0;
 		}
@@ -5023,7 +5023,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			}
 		}
 	} else {  /* If reducing, find stripes, stripesize & size of last segment */
-		if (lp->ac_stripes || lp->ac_stripesize || lp->ac_mirrors)
+		if (lp->stripes || lp->stripe_size || lp->mirrors)
 			log_print_unless_silent("Ignoring stripes, stripesize and mirrors "
 						"arguments when reducing.");
 
@@ -5081,7 +5081,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	}
 
 	if (lp->extents == existing_logical_extents) {
-		if (lp->poolmetadatasize || lp->ac_policy) {
+		if (lp->poolmetadata_size || lp->use_policies) {
 			/* Signal that normal resizing is not required */
 			lp->sizeargs = 0;
 			return 1;
@@ -5146,7 +5146,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			return 0;
 		}
 		lp->resize = LV_EXTEND;
-	} else if ((lp->extents == existing_logical_extents) && !lp->ac_policy) {
+	} else if ((lp->extents == existing_logical_extents) && !lp->use_policies) {
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, existing_logical_extents);
@@ -5160,7 +5160,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	 * extents of a mirror not to have an initial sync?
 	 */
 	if ((lp->extents > existing_logical_extents)) {
-		if (seg_is_mirrored(first_seg(lv)) && lp->ac_no_sync)
+		if (seg_is_mirrored(first_seg(lv)) && lp->nosync)
 			lv->status |= LV_NOTSYNCED;
 	}
 
@@ -5226,7 +5226,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 		/* Switch to layered LV resizing */
 		lv = seg_lv(seg, 0);
 	}
-	alloc = lp->ac_alloc ? : lv->alloc;
+	alloc = lp->alloc ? : lv->alloc;
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)
 		log_print_unless_silent("Ignoring PVs on command line when reducing.");
@@ -5308,7 +5308,7 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!_lvresize_check_lv(lv, lp))
 		return_0;
 
-	if (lp->ac_policy && !_adjust_policy_params(lv, lp))
+	if (lp->use_policies && !_adjust_policy_params(lv, lp))
 		return_0;
 
 	if (lp->size && !_lvresize_adjust_size(lv->vg, lp->size, lp->sign,
@@ -5320,16 +5320,16 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->extents && !_lvresize_adjust_extents(cmd, lv, lp, pvh))
 		return_0;
 
-	if ((lp->extents == lv->le_count) && lp->ac_policy) {
+	if ((lp->extents == lv->le_count) && lp->use_policies) {
 		/* Nothing to do. */
 		lp->sizeargs = 0;
-		lp->poolmetadatasize = 0;
+		lp->poolmetadata_size = 0;
 	}
 
 	if (lp->extents && !_lvresize_check_type(lv, lp))
 		return_0;
 
-	if (lp->poolmetadatasize &&
+	if (lp->poolmetadata_size &&
 	    !_lvresize_poolmetadata_prepare(lv, lp))
 		return_0;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5948404..ddf51fc 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -599,26 +599,20 @@ struct pvcreate_params {
 };
 
 struct lvresize_params {
+	int argc;
+	char **argv;
+
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name;
 
-	uint32_t stripes;
-	uint32_t stripe_size;
-	uint32_t mirrors;
-
 	const struct segment_type *segtype;
 
-	/* size */
-	uint32_t extents;
-	uint64_t size;
 	int sizeargs;
-	sign_t sign;
-	uint64_t poolmetadatasize;
-	sign_t poolmetadatasign;
+	uint64_t poolmetadata_size;
+	sign_t poolmetadata_sign;
 	uint32_t poolmetadataextents;
-	int approx_alloc;
-	int extents_are_pes;	/* Is 'extents' counting PEs or LEs? */
-	percent_type_t percent;
+
+	/* Per LV applied parameters */
 
 	enum {
 		LV_ANY = 0,
@@ -626,25 +620,25 @@ struct lvresize_params {
 		LV_EXTEND = 2
 	} resize;
 
-	int resizefs;
+	int use_policies;
+
+	alloc_policy_t alloc;
+	int force;
+	int nosync;
 	int nofsck;
+	int resizefs;
 
-	int argc;
-	char **argv;
+	unsigned mirrors;
+	uint32_t stripes;
+	uint64_t stripe_size;
 
-	/* FIXME Deal with meaningless 'ac' */
-	/* Arg counts & values */
-	alloc_policy_t ac_alloc;
-	unsigned ac_force;
-	unsigned ac_mirrors;
-	uint32_t ac_mirrors_value;
-	unsigned ac_no_sync;
-	unsigned ac_policy;
-	unsigned ac_stripes;
-	uint32_t ac_stripes_value;
-	unsigned ac_stripesize;
-	uint64_t ac_stripesize_value;
-	const char *ac_type;
+	uint32_t extents;
+	uint64_t size;
+	sign_t sign;
+	percent_type_t percent;
+
+	int approx_alloc;
+	int extents_are_pes;	/* Is 'extents' counting PEs or LEs? */
 };
 
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index ee0d48b..467a9d0 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -462,7 +462,7 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 		.percent = PERCENT_NONE,
 		.resize = LV_ANY,
 		.size = new_size >> SECTOR_SHIFT,
-		.ac_force = 1,	/* Assume the user has a good backup? */
+		.force = 1,	/* Assume the user has a good backup? */
 		.sizeargs = 1,
 	};
 	struct saved_env e = store_user_env(lv->vg->cmd);
diff --git a/tools/lvresize.c b/tools/lvresize.c
index f7e17b8..af2b3ac 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -19,7 +19,10 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			    struct lvresize_params *lp)
 {
 	const char *cmd_name = command_name(cmd);
-	char *st;
+	const char *type_str = arg_str_value(cmd, type_ARG, NULL);
+
+	if (type_str && (lp->segtype = get_segtype_from_string(cmd, type_str)))
+		return_0;
 
 	if (!strcmp(cmd_name, "lvreduce"))
 		lp->resize = LV_REDUCE;
@@ -28,9 +31,9 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	else
 		lp->resize = LV_ANY;
 
-	lp->sign = lp->poolmetadatasign = SIGN_NONE;
+	lp->sign = lp->poolmetadata_sign = SIGN_NONE;
 
-	if ((lp->ac_policy = arg_is_set(cmd, usepolicies_ARG))) {
+	if ((lp->use_policies = arg_is_set(cmd, usepolicies_ARG))) {
 		/* do nothing; _lvresize will handle --use-policies itself */
 		lp->extents = 0;
 		lp->sign = SIGN_PLUS;
@@ -53,6 +56,10 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 * then metadata will be extended there.
 		 */
 		lp->sizeargs = arg_is_set(cmd, extents_ARG) + arg_is_set(cmd, size_ARG);
+		if ((lp->extents = arg_uint_value(cmd, extents_ARG, 0))) {
+			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
+			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
+		}
 
 		if (arg_from_list_is_zero(cmd, "may not be zero",
 					  chunksize_ARG, extents_ARG,
@@ -64,39 +71,31 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 					  -1))
 			return_0;
 
-		if (arg_is_set(cmd, poolmetadatasize_ARG)) {
-			lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
-			lp->poolmetadatasign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
-			if (lp->poolmetadatasign == SIGN_MINUS) {
+		if ((lp->poolmetadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, 0))) {
+			lp->poolmetadata_sign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
+			if (lp->poolmetadata_sign == SIGN_MINUS) {
 				log_error("Can't reduce pool metadata size.");
 				return 0;
 			}
 		}
 
-		if ((lp->sizeargs == 0) && (argc >= 2)) {
-			lp->extents = 100;
-			lp->percent = PERCENT_PVS;
-			lp->sign = SIGN_PLUS;
-			lp->sizeargs = !lp->poolmetadatasize ? 1 : 0;
-		} else if ((lp->sizeargs != 1) &&
-			   ((lp->sizeargs == 2) ||
-			    !arg_is_set(cmd, poolmetadatasize_ARG))) {
-			log_error("Please specify either size or extents but not "
-				  "both.");
-			return 0;
+		if ((lp->size = arg_uint64_value(cmd, size_ARG, 0))) {
+			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
+			lp->percent = PERCENT_NONE;
 		}
 
-		if (arg_is_set(cmd, extents_ARG)) {
-			lp->extents = arg_uint_value(cmd, extents_ARG, 0);
-			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
-			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
+		if (lp->size && lp->extents) {
+			log_error("Please specify either size or extents but not both.");
+			return 0;
 		}
 
-		/* Size returned in kilobyte units; held in sectors */
-		if (arg_is_set(cmd, size_ARG)) {
-			lp->size = arg_uint64_value(cmd, size_ARG, 0);
-			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
-			lp->percent = PERCENT_NONE;
+		if (!lp->extents &&
+		    !lp->size &&
+		    !lp->poolmetadata_size &&
+		    (argc >= 2)) {
+			lp->extents = 100;
+			lp->percent = PERCENT_PVS;
+			lp->sign = SIGN_PLUS;
 		}
 	}
 
@@ -106,77 +105,54 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	if (lp->resize == LV_REDUCE &&
-	    ((lp->sign == SIGN_PLUS) || (lp->poolmetadatasign == SIGN_PLUS))) {
+	    ((lp->sign == SIGN_PLUS) ||
+	     (lp->poolmetadata_sign == SIGN_PLUS))) {
 		log_error("Positive sign not permitted - use lvextend.");
 		return 0;
 	}
 
-	lp->resizefs = arg_is_set(cmd, resizefs_ARG);
-	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
-
 	if (!argc) {
 		log_error("Please provide the logical volume name.");
 		return 0;
 	}
 
 	lp->lv_name = argv[0];
-	argv++;
-	argc--;
 
-	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, NULL)) ||
-	    !(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
-		log_error("Please provide a volume group name");
-		return 0;
-	}
+	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
+		return_0;
 
-	if (!validate_name(lp->vg_name)) {
-		log_error("Volume group name %s has invalid characters",
-			  lp->vg_name);
+	/* Check for $LVM_VG_NAME */
+	if (!lp->vg_name && !(lp->vg_name = extract_vgname(cmd, NULL))) {
+		log_error("Please specify a logical volume path.");
 		return 0;
 	}
 
-	if ((st = strrchr(lp->lv_name, '/')))
-		lp->lv_name = st + 1;
-
-	lp->argc = argc;
-	lp->argv = argv;
-
-	lp->ac_policy = arg_is_set(cmd, usepolicies_ARG);
-	lp->ac_stripes = arg_is_set(cmd, stripes_ARG);
-	if (lp->ac_stripes) {
-		lp->ac_stripes_value = arg_uint_value(cmd, stripes_ARG, 1);
-	} else {
-		lp->ac_stripes_value = 0;
+	if ((lp->mirrors = arg_count(cmd, mirrors_ARG)) &&
+	    (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS)) {
+		log_error("Mirrors argument may not be signed.");
+		return 0;
 	}
 
-	lp->ac_mirrors = arg_is_set(cmd, mirrors_ARG);
-
-	if (lp->ac_mirrors) {
-		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Mirrors argument may not be negative");
-			return 0;
-		}
-
-		lp->ac_mirrors_value = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
-	} else {
-		lp->ac_mirrors_value = 0;
+	if ((lp->stripes = arg_uint_value(cmd, stripes_ARG, 0)) &&
+	    (arg_sign_value(cmd, stripes_ARG, SIGN_NONE) == SIGN_MINUS)) {
+		log_error("Stripes argument may not be negative.");
+		return 0;
 	}
 
-	lp->ac_stripesize = arg_is_set(cmd, stripesize_ARG);
-	if (lp->ac_stripesize) {
-		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Stripesize may not be negative.");
-			return 0;
-		}
-
-		lp->ac_stripesize_value = arg_uint64_value(cmd, stripesize_ARG, 0);
+	if ((lp->stripe_size = arg_uint64_value(cmd, stripesize_ARG, 0)) &&
+	    (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS)) {
+		log_error("Stripesize may not be negative.");
+		return 0;
 	}
 
-	lp->ac_no_sync = arg_is_set(cmd, nosync_ARG);
-	lp->ac_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0);
+	lp->argc = --argc;
+	lp->argv = ++argv;
 
-	lp->ac_type = arg_str_value(cmd, type_ARG, NULL);
-	lp->ac_force = arg_count(cmd, force_ARG);
+	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0);
+	lp->force = arg_is_set(cmd, force_ARG);
+	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
+	lp->nosync = arg_is_set(cmd, nosync_ARG);
+	lp->resizefs = arg_is_set(cmd, resizefs_ARG);
 
 	return 1;
 }


