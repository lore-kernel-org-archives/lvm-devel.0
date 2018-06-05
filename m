From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 5 Jun 2018 10:25:06 -0400
Subject: master - lvconvert: support linear <-> striped convenience conversions
Message-ID: <201806051425.w55EP6GC028156@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd7cdd0b09ba123b064937fddde08daacbed7dab
Commit:        bd7cdd0b09ba123b064937fddde08daacbed7dab
Parent:        de66704253653305e4513637735a078af00912b7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed May 30 12:49:15 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 5 16:23:18 2018 +0200

lvconvert: support linear <-> striped convenience conversions

"lvconvert --type {linear|striped|raid*} ..." on a striped/linear
LV provides convenience interim type to convert to the requested
final layout similar to the given raid* <-> raid* conveninece types.

Whilst on it, add missing raid5_n convenince type from raid5* to raid10.

Resolves: rhbz1439925
Resolves: rhbz1447809
Resolves: rhbz1573255
---
 lib/metadata/raid_manip.c |  172 ++++++++++++++++++++++++++++++---------------
 tools/lvconvert.c         |  110 ++++++++++-------------------
 2 files changed, 154 insertions(+), 128 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9b4cb83..4d58d74 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4526,17 +4526,18 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	  .current_areas = 1,
 	  .options = ALLOW_REGION_SIZE },
 
-	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
-	  .possible_types = SEG_RAID0|SEG_RAID0_META,
-	  .current_areas = 1,
-	  .options = ALLOW_STRIPE_SIZE },
-
 	/* raid0* -> raid1 */
 	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count = 1 */
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 1,
 	  .options = ALLOW_REGION_SIZE },
 
+	/* raid5_n -> linear through interim raid1 */
+	{ .current_types  = SEG_RAID5_N,
+	  .possible_types = SEG_STRIPED_TARGET,
+	  .current_areas = 2,
+	  .options = ALLOW_NONE },
+
 	/* striped,raid0* <-> striped,raid0* */
 	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
@@ -4547,13 +4548,13 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .possible_types = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6|SEG_RAID10_NEAR,
 	  .current_areas = ~0U,
-	  .options = ALLOW_REGION_SIZE },
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES },
 
 	/* raid4,raid5_n,raid6_n_6,raid10_near -> striped/raid0* */
 	{ .current_types  = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6|SEG_RAID10_NEAR,
 	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE },
+	  .options = ALLOW_STRIPES },
 
 	/* raid4,raid5_n,raid6_n_6 <-> raid4,raid5_n,raid6_n_6 */
 	{ .current_types  = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
@@ -4640,7 +4641,8 @@ static struct possible_takeover_reshape_type *_get_possible_takeover_reshape_typ
 	for ( ; pt->current_types; pt++)
 		if ((seg_from->segtype->flags & pt->current_types) &&
 		    (segtype_to ? (segtype_to->flags & pt->possible_types) : 1))
-			if (seg_from->area_count <= pt->current_areas)
+			if ((seg_from->area_count == pt->current_areas) ||
+			    (seg_from->area_count > 1 && seg_from->area_count <= pt->current_areas))
 				return pt;
 
 	return NULL;
@@ -4816,7 +4818,7 @@ typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGS);
 /*
  * Unsupported takeover functions.
  */
-static int _takeover_noop(TAKEOVER_FN_ARGS)
+static int _takeover_same_layout(const struct logical_volume *lv)
 {
 	log_error("Logical volume %s is already of requested type %s.",
 		  display_lvname(lv), lvseg_name(first_seg(lv)));
@@ -4824,6 +4826,11 @@ static int _takeover_noop(TAKEOVER_FN_ARGS)
 	return 0;
 }
 
+static int _takeover_noop(TAKEOVER_FN_ARGS)
+{
+	return _takeover_same_layout(lv);
+}
+
 static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 {
 	struct lv_segment *seg = first_seg(lv);
@@ -5618,7 +5625,9 @@ static int _takeover_from_linear_to_raid0(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_linear_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	first_seg(lv)->region_size = new_region_size;
+
+	return _lv_raid_change_image_count(lv, 1, 2, allocate_pvs, NULL, 1, 0);
 }
 
 static int _takeover_from_linear_to_raid10(TAKEOVER_FN_ARGS)
@@ -6102,23 +6111,34 @@ static uint64_t _raid_segtype_flag_5_to_6(const struct segment_type *segtype)
 /* FIXME: do this like _conversion_options_allowed()? */
 static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_from,
 						 const struct segment_type **segtype,
+						 uint32_t *new_image_count,
+						 uint32_t *stripes,
 						 int yes)
 {
 	uint64_t seg_flag = 0;
 	struct cmd_context *cmd = seg_from->lv->vg->cmd;
 	const struct segment_type *segtype_sav = *segtype;
 
+	/* Linear -> striped request */
+	if (seg_is_striped(seg_from) &&
+	    seg_from->area_count == 1 &&
+	    segtype_is_striped(*segtype))
+		;
 	/* Bail out if same RAID level is requested. */
-	if (_is_same_level(seg_from->segtype, *segtype))
+	else if (_is_same_level(seg_from->segtype, *segtype))
 		return 1;
 
 	log_debug("Checking LV %s requested %s segment type for convenience",
 		  display_lvname(seg_from->lv), (*segtype)->name);
-
 	/* striped/raid0 -> raid5/6 */
 	if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
+		/* linear -> raid*, interim/first conversion is to raid1 */
+		if (seg_from->area_count == 1)
+			seg_flag = SEG_RAID1;
+
 		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
-		if (segtype_is_any_raid5(*segtype) && !segtype_is_raid5_n(*segtype))
+		else if (((segtype_is_striped(*segtype) && !segtype_is_any_raid0(*segtype)) || segtype_is_any_raid5(*segtype)) &&
+			 !segtype_is_raid5_n(*segtype))
 			seg_flag = SEG_RAID5_N;
 
 		/* If this is any raid6 conversion request -> enforce raid6_n_6, because we convert from striped */
@@ -6143,40 +6163,71 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 
 	/* raid4/raid5 -> striped/raid0/raid1/raid6/raid10 */
 	} else if (seg_is_raid4(seg_from) || seg_is_any_raid5(seg_from)) {
-		if (segtype_is_raid1(*segtype) &&
-		    seg_from->area_count != 2) {
+		if ((segtype_is_raid1(*segtype) || segtype_is_linear(*segtype)) && seg_is_raid5_n(seg_from)) {
+			if (seg_from->area_count != 2) {
+				log_error("Converting %s LV %s to 2 stripes first.",
+					  lvseg_name(seg_from), display_lvname(seg_from->lv));
+				*new_image_count = 2;
+				seg_flag = SEG_RAID5_N;
+			} else
+				seg_flag = SEG_RAID1;
+
+		} else if (segtype_is_raid1(*segtype) && seg_from->area_count != 2) {
 			log_error("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
 				  lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
-		}
-
-		if (seg_is_raid4(seg_from) &&
-			   segtype_is_any_raid5(*segtype) &&
-			   !segtype_is_raid5_n(*segtype))
-			seg_flag = SEG_RAID5_N;
 
-		else if (seg_is_any_raid5(seg_from) &&
-			 segtype_is_raid4(*segtype) &&
+		} else if (seg_is_raid4(seg_from) &&
+		         (segtype_is_linear(*segtype) || segtype_is_any_raid5(*segtype)) &&
 			 !segtype_is_raid5_n(*segtype))
 			seg_flag = SEG_RAID5_N;
 
-		else if (segtype_is_raid10(*segtype)) {
-			if (seg_from->area_count < 3) {
+		else if (seg_is_raid5_n(seg_from) && seg_from->area_count == 2) {
+			if (*stripes >= 2) {
+				log_error("Converting %s LV %s to %u stripes first.",
+					  lvseg_name(seg_from), display_lvname(seg_from->lv), *stripes);
+				*new_image_count = *stripes + seg_from->segtype->parity_devs;
+				seg_flag = SEG_RAID5_N;
+			} else {
 				log_error("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
 					  lvseg_name(seg_from), display_lvname(seg_from->lv));
 				return 0;
 			}
+		} else if (seg_is_any_raid5(seg_from) &&
+		         (segtype_is_linear(*segtype) || segtype_is_raid4(*segtype)) &&
+			 !segtype_is_raid5_n(*segtype))
+			seg_flag = SEG_RAID5_N;
 
-			seg_flag = seg_is_raid5_n(seg_from) ? SEG_RAID0_META : SEG_RAID5_N;
+		else if (segtype_is_raid10(*segtype)) {
+			if (seg_from->area_count < 3) {
+				if (*stripes >= 2) {
+					log_error("Converting %s LV %s to %u stripes first.",
+						  lvseg_name(seg_from), display_lvname(seg_from->lv), *stripes);
+					*new_image_count = *stripes + seg_from->segtype->parity_devs;
+					seg_flag = SEG_RAID5_N;
+				} else {
+					log_error("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
+						  lvseg_name(seg_from), display_lvname(seg_from->lv));
+					return 0;
+				}
+			} else
+				seg_flag = seg_is_raid5_n(seg_from) ? SEG_RAID0_META : SEG_RAID5_N;
 
 		} else if (segtype_is_any_raid6(*segtype)) {
-			if (seg_from->area_count < 4) {
-				log_error("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
-					  lvseg_name(seg_from), display_lvname(seg_from->lv));
-				return 0;
-			}
+			if (seg_from->area_count < 4 &&
+			    seg_is_any_raid5(seg_from)) {
+				if (*stripes >= 3) {
+					log_error("Converting %s LV %s to %u stripes first.",
+						  lvseg_name(seg_from), display_lvname(seg_from->lv), *stripes);
+					*new_image_count = *stripes + seg_from->segtype->parity_devs;
+					seg_flag = SEG_RAID5_LS;
+				} else {
+					log_error("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
+						  lvseg_name(seg_from), display_lvname(seg_from->lv));
+					return 0;
+				}
 
-			if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
+			} else if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
 				seg_flag = SEG_RAID6_N_6;
 			else
 				seg_flag = _raid_seg_flag_5_to_6(seg_from);
@@ -6193,9 +6244,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 		} else if (segtype_is_any_raid10(*segtype)) {
 			seg_flag = seg_is_raid6_n_6(seg_from) ? SEG_RAID0_META : SEG_RAID6_N_6;
 
-		} else if ((segtype_is_striped(*segtype) || segtype_is_any_raid0(*segtype)) &&
-			   !seg_is_raid6_n_6(seg_from)) {
-			seg_flag = SEG_RAID6_N_6;
+		} else if (segtype_is_striped(*segtype) || segtype_is_any_raid0(*segtype)) {
+			if (!seg_is_raid6_n_6(seg_from))
+				seg_flag = SEG_RAID6_N_6;
 
 		} else if (segtype_is_raid4(*segtype) && !seg_is_raid6_n_6(seg_from)) {
 			seg_flag = SEG_RAID6_N_6;
@@ -6331,41 +6382,48 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 				       int yes,
 				       uint32_t new_image_count,
 				       int new_data_copies, int new_region_size,
-				       int stripes, unsigned new_stripe_size_supplied)
+				       uint32_t *stripes, unsigned new_stripe_size_supplied)
 {
 	int r = 1;
-	uint32_t opts;
+	uint32_t count = new_image_count, opts;
+
+	/* Linear -> linear rejection */
+	if ((seg_is_linear(seg_from) || seg_is_striped(seg_from)) &&
+	    seg_from->area_count == 1 &&
+	    segtype_is_striped(*segtype_to) &&
+	    *stripes < 2)
+		return _takeover_same_layout(seg_from->lv);
 
-	if (!new_image_count && !_set_convenient_raid145610_segtype_to(seg_from, segtype_to, yes))
+	if (!new_image_count && !_set_convenient_raid145610_segtype_to(seg_from, segtype_to, &count, stripes, yes))
 		return_0;
 
+	if (new_image_count != count)
+		*stripes = count - seg_from->segtype->parity_devs;
+
 	if (!_get_allowed_conversion_options(seg_from, *segtype_to, new_image_count, &opts)) {
-		log_error("Unable to convert LV %s from %s to %s.",
-			  display_lvname(seg_from->lv), lvseg_name(seg_from), (*segtype_to)->name);
+		if (strcmp(lvseg_name(seg_from), (*segtype_to)->name))
+			log_error("Unable to convert LV %s from %s to %s.",
+				  display_lvname(seg_from->lv), lvseg_name(seg_from), (*segtype_to)->name);
+		else
+			_takeover_same_layout(seg_from->lv);
+
 		return 0;
 	}
 
-	if (stripes > 1 && !(opts & ALLOW_STRIPES)) {
-		if (!_log_prohibited_option(seg_from, *segtype_to, "--stripes"))
-			stack;
-		r = 0;
+	if (*stripes > 1 && !(opts & ALLOW_STRIPES)) {
+		_log_prohibited_option(seg_from, *segtype_to, "--stripes");
+		*stripes = seg_from->area_count;
 	}
 
-	if (new_stripe_size_supplied && !(opts & ALLOW_STRIPE_SIZE)) {
-		if (!_log_prohibited_option(seg_from, *segtype_to, "-I/--stripesize"))
-			stack;
-		r = 0;
-	}
+	if (new_stripe_size_supplied && !(opts & ALLOW_STRIPE_SIZE))
+		_log_prohibited_option(seg_from, *segtype_to, "-I/--stripesize");
 
-	if (new_region_size && !(opts & ALLOW_REGION_SIZE)) {
-		if (!_log_prohibited_option(seg_from, *segtype_to, "-R/--regionsize"))
-			stack;
-		r = 0;
-	}
+	if (new_region_size && new_region_size != seg_from->region_size && !(opts & ALLOW_REGION_SIZE))
+		_log_prohibited_option(seg_from, *segtype_to, "-R/--regionsize");
 
 	/* Can't reshape stripes or stripe size when performing a takeover! */
 	if (!_is_same_level(seg_from->segtype, *segtype_to)) {
-		if (stripes && stripes != _data_rimages_count(seg_from, seg_from->area_count))
+		if (*stripes && *stripes != _data_rimages_count(seg_from, seg_from->area_count))
 			log_warn("WARNING: ignoring --stripes option on takeover of %s (reshape afterwards).",
 				 display_lvname(seg_from->lv));
 
@@ -6501,7 +6559,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	 */
 	if (!_conversion_options_allowed(seg, &new_segtype, yes,
 					 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
-					 new_stripes, new_stripe_size_supplied))
+					 &stripes, new_stripe_size_supplied))
 		return _log_possible_conversion_types(lv, new_segtype);
 
 	/* https://bugzilla.redhat.com/1439399 */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index be4b1d0..536b925 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -238,6 +238,14 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
                 break;
 
 	case CONV_OTHER:
+		if (arg_is_set(cmd, regionsize_ARG)) {
+			lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
+			lp->region_size_supplied = 1;
+		} else {
+			lp->region_size = get_default_region_size(cmd);
+			lp->region_size_supplied = 0;
+		}
+
 		if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
 			   lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
 			if (arg_is_set(cmd, chunksize_ARG)) {
@@ -250,14 +258,6 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 				return 0;
 			}
 
-			if (arg_is_set(cmd, regionsize_ARG)) {
-				lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
-				lp->region_size_supplied = 1;
-			} else {
-				lp->region_size = get_default_region_size(cmd);
-				lp->region_size_supplied = 0;
-			}
-
 			/* FIXME man page says in one place that --type and --mirrors can't be mixed */
 			if (lp->mirrors_supplied && !lp->mirrors)
 				/* down-converting to linear/stripe? */
@@ -265,7 +265,7 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 
 		} else if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str)) { /* striped or linear or raid0 */
 			if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped or --type linear",
-						 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
+						 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, zero_ARG,
 						 -1))
 				return_0;
 		} /* else segtype will default to current type */
@@ -1258,11 +1258,11 @@ static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
 	if (!from_segtype)
 		return 1;
 
-	if (from_segtype == to_segtype)
-		return 1;
-
-	/* Support raid0 <-> striped conversions */
+	/* linear/striped/raid0 <-> striped/raid0/linear (restriping via raid) */
 	if (segtype_is_striped(from_segtype) && segtype_is_striped(to_segtype))
+		return 0;
+
+	if (from_segtype == to_segtype)
 		return 1;
 
 	if (!segtype_is_raid(from_segtype) && !segtype_is_raid(to_segtype))
@@ -1305,45 +1305,18 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		lp->mirrors = 0;
 	}
 
-	/* Can only change image count for raid1 and linear */
-	if (lp->mirrors_supplied) {
-		if (_raid0_type_requested(lp->type_str)) {
-			log_error("--mirrors/-m is not compatible with conversion to %s.",
-				  lp->type_str);
-			return 0;
-		}
-		if (!seg_is_mirrored(seg) && !seg_is_linear(seg)) {
-			log_error("--mirrors/-m is not compatible with %s.",
-				  lvseg_name(seg));
-			return 0;
-		}
-		if (seg_is_raid10(seg)) {
-			log_error("--mirrors/-m cannot be changed with %s.",
-				  lvseg_name(seg));
-			return 0;
-		}
-	}
-
 	if (!_lvconvert_validate_thin(lv, lp))
 		return_0;
 
-	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype))
+	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype) &&
+	    !lp->mirrors_supplied)
 		goto try_new_takeover_or_reshape;
 
-	if (seg_is_linear(seg) && !lp->mirrors_supplied) {
-		if (_raid0_type_requested(lp->type_str)) {
-			log_error("Linear LV %s cannot be converted to %s.",
-				  display_lvname(lv), lp->type_str);
-			return 0;
-		}
+	if (seg_is_striped(seg) && !lp->mirrors_supplied)
+		goto try_new_takeover_or_reshape;
 
-		if (!strcmp(lp->type_str, SEG_TYPE_NAME_RAID1)) {
-			log_error("Raid conversions of LV %s require -m/--mirrors.",
-				  display_lvname(lv));
-			return 0;
-		}
+	if (seg_is_linear(seg) && !lp->mirrors_supplied)
 		goto try_new_takeover_or_reshape;
-	}
 
 	/* Change number of RAID1 images */
 	if (lp->mirrors_supplied || lp->keep_mimages) {
@@ -1381,6 +1354,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_split(lv, lp->yes, lp->lv_split_name, image_count, lp->pvh);
 
 	if (lp->mirrors_supplied) {
+		if ((seg_is_striped(seg) && seg->area_count == 1) || seg_is_raid1(seg)) { /* ??? */
 		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR) ||
 		    (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED) && image_count == 1)) {
 			if (image_count > DEFAULT_RAID1_MAX_IMAGES) {
@@ -1398,6 +1372,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 			return 1;
 		}
+		}
 		goto try_new_takeover_or_reshape;
 	}
 
@@ -1440,7 +1415,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 try_new_takeover_or_reshape:
-
 	if (!_raid4_conversion_supported(lv, lp))
 		return 0;
 
@@ -1450,24 +1424,15 @@ try_new_takeover_or_reshape:
 	if (!arg_is_set(cmd, type_ARG))
 	       lp->segtype = NULL;
 
-	/* Only let raid4 through for now. */
-	if (!lp->segtype ||
-	    (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
-	     ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
-	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp))))) {
-		if (!lv_raid_convert(lv, lp->segtype,
-				     lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     (lp->region_size_supplied || !seg->region_size) ?
-				     lp->region_size : seg->region_size , lp->pvh))
-			return_0;
-
-		log_print_unless_silent("Logical volume %s successfully converted.",
-					display_lvname(lv));
-		return 1;
-	}
+	if (!lv_raid_convert(lv, lp->segtype,
+			     lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
+			     (lp->region_size_supplied || !seg->region_size) ?
+			     lp->region_size : seg->region_size , lp->pvh))
+		return_0;
 
-	log_error("Conversion operation not yet supported.");
-	return 0;
+	log_print_unless_silent("Logical volume %s successfully converted.",
+				display_lvname(lv));
+	return 1;
 }
 
 /*
@@ -1692,21 +1657,24 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 			    struct lvconvert_params *lp)
 {
 	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
+	int raid_type = *lp->type_str && !strncmp(lp->type_str, "raid", 4);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
-		return _convert_striped_mirror(cmd, lv, lp);
+	if (!raid_type) {
+		if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))
+			return _convert_striped_mirror(cmd, lv, lp);
 
-	if (segtype_is_raid(lp->segtype))
-		return _convert_striped_raid(cmd, lv, lp);
-
-	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
+		/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
 
-	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_MIRROR))
-		return _convert_striped_mirror(cmd, lv, lp);
+		if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_MIRROR))
+			return _convert_striped_mirror(cmd, lv, lp);
+	}
 
 	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, SEG_TYPE_NAME_RAID1))
 		return _convert_striped_raid(cmd, lv, lp);
 
+	if (segtype_is_striped(lp->segtype) || segtype_is_raid(lp->segtype))
+		return _convert_striped_raid(cmd, lv, lp);
+
 	log_error("Unknown operation on striped or linear LV %s.", display_lvname(lv));
 	return 0;
 }


