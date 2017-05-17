From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 17 May 2017 18:19:11 -0400
Subject: master - lvconvert: enhance automatic settings of possible (raid) LV types
Message-ID: <201705172219.v4HMJBJm006648@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fe07d3574ddce3d194f0fa57af9028348a91008
Commit:        5fe07d3574ddce3d194f0fa57af9028348a91008
Parent:        16c6d9f11ab581a79fb57fd36142af1dc57a3c61
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu May 18 00:18:15 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu May 18 00:18:15 2017 +0200

lvconvert: enhance automatic settings of possible (raid) LV types

Offer possible interim LV types and display their aliases
(e.g. raid5 and raid5_ls) for all conversions between
striped and any raid LVs in case user requests a type
not suitable to direct conversion.

E.g. running "lvconvert --type raid5 LV" on a striped
LV will replace raid5 aka raid5_ls (rotating parity)
with raid5_n (dedicated parity on last image).
User is asked to repeat the lvconvert command to get to the
requested LV type (raid5 aka raid5_ls in this example)
when such replacement occurs.

Resolves: rhbz1439403
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |  312 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 222 insertions(+), 91 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5097c1b..07c2602 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Enhance lvconvert automatic settings of possible (raid) LV types.
   Allow lvchange to change properties on a thin pool data sub LV.
   Fix lvcreate extent percentage calculation for mirrors.
   Don't reinstate still-missing devices when correcting inconsistent metadata.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b708442..99fe275 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -427,8 +427,10 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl))))
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl)))) {
+		log_error("Memory allocation failed.");
 		return_0;
+	}
 
 	/* Add last metadata area to removal_lvs */
 	lvl_array[0].lv = seg_metalv(seg, 0);
@@ -786,8 +788,10 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
 	/* FIXME: once more data copies supported with raid10 */
 	stripes /= data_copies;
 
-	if (!(idx = dm_pool_zalloc(seg_lv(seg, 0)->vg->vgmem, seg->area_count * sizeof(*idx))))
-		return 0;
+	if (!(idx = dm_pool_zalloc(seg_lv(seg, 0)->vg->vgmem, seg->area_count * sizeof(*idx)))) {
+		log_error("Memory allocation failed.");
+		return_0;
+	}
 
 	/* Set up positional index array */
 	switch (conv) {
@@ -1013,8 +1017,8 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
-			(alt_base_name) ? : lv->name, type_suffix) < 0) {
+	if (!dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
+			(alt_base_name) ? : lv->name, type_suffix)) {
 		log_error("Component name for raid %s is too long.", display_lvname(lv));
 		return 0;
 	}
@@ -1056,8 +1060,10 @@ static int _alloc_image_components(struct logical_volume *lv,
 	const char *raid_segtype;
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
-					sizeof(*lvl_array) * count * 2)))
+					sizeof(*lvl_array) * count * 2))) {
+		log_error("Memory allocation failed.");
 		return_0;
+	}
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
 		return_0;
@@ -1250,6 +1256,10 @@ static int _cmp_level(const struct segment_type *t1, const struct segment_type *
 	    (!segtype_is_any_raid10(t1) && segtype_is_any_raid10(t2)))
 		return 0;
 
+	if ((segtype_is_raid4(t1) && segtype_is_raid5_n(t2)) ||
+	    (segtype_is_raid5_n(t1) && segtype_is_raid4(t2)))
+		return 1;
+
 	return !strncmp(t1->name, t2->name, 5);
 }
 
@@ -1986,10 +1996,11 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 /*
  * HM Helper:
  *
- * Reshape: keep images in RAID @lv but change stripe size or data copies
+ * Reshape: keep images in RAID @lv but change layout, stripe size or data copies
  *
  */
 static const char *_get_segtype_alias(const struct segment_type *segtype);
+static const char *_get_segtype_alias_str(const struct logical_volume *lv, const struct segment_type *segtype);
 static int _raid_reshape_keep_images(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     int yes, int force, int *force_repair,
@@ -2001,10 +2012,13 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 	struct lv_segment *seg = first_seg(lv);
 
 	if (seg->segtype != new_segtype)
-		log_print_unless_silent("Converting %s LV %s to %s.",
-					lvseg_name(seg), display_lvname(lv), new_segtype->name);
-	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s? [y/n]: ",
-				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
+		log_print_unless_silent("Converting %s%s LV %s to %s%s.",
+					lvseg_name(seg), _get_segtype_alias_str(lv, seg->segtype),
+					display_lvname(lv), new_segtype->name,
+					_get_segtype_alias_str(lv, new_segtype));
+
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv)) == 'n') {
 			log_error("Logical volume %s NOT converted.", display_lvname(lv));
 			return 0;
 	}
@@ -2022,12 +2036,9 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 	 * The dm-raid target is able to use the space whereever it
 	 * is found by appropriately selecting forward or backward reshape.
 	 */
-	if (seg->segtype != new_segtype) {
-		const char *alias = _get_segtype_alias(seg->segtype);
-
-		if (!strcmp(alias, new_segtype->name))
-			alloc_reshape_space = 0;
-	}
+	if (seg->segtype != new_segtype &&
+	    !strcmp(_get_segtype_alias(seg->segtype), new_segtype->name))
+		alloc_reshape_space = 0;
 
 	if (seg->stripe_size != new_stripe_size)
 		alloc_reshape_space = 1;
@@ -4437,6 +4448,7 @@ static int _log_possible_conversion(uint64_t *processed_segtypes, void *data)
 	return 1;
 }
 
+/* Return any segment type alias name for @segtype or empty string */
 static const char *_get_segtype_alias(const struct segment_type *segtype)
 {
 	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID5))
@@ -4460,12 +4472,28 @@ static const char *_get_segtype_alias(const struct segment_type *segtype)
 	return "";
 }
 
+/* Return any segment type alias string (format " (same as raid*)") for @segtype or empty string */
+static const char *_get_segtype_alias_str(const struct logical_volume *lv, const struct segment_type *segtype)
+{
+	const char *alias = _get_segtype_alias(segtype);
+
+	if (*alias) {
+		const char *msg = " (same as ";
+		size_t sz = strlen(msg) + strlen(alias) + 2;
+		char *buf = dm_pool_alloc(lv->vg->cmd->mem, sz);
+
+		if (buf)
+			alias = dm_snprintf(buf, sz, "%s%s)", msg, alias) ? buf : "";
+	}
+
+	return alias;
+}
+
 static int _log_possible_conversion_types(const struct logical_volume *lv, const struct segment_type *new_segtype)
 {
 	unsigned possible_conversions = 0;
 	const struct lv_segment *seg = first_seg(lv);
 	struct possible_type *pt = NULL;
-	const char *alias;
 	uint64_t processed_segtypes = UINT64_C(0);
 
 	/* Count any possible segment types @seg an be directly converted to */
@@ -4476,12 +4504,10 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 	if (!possible_conversions)
 		log_error("Direct conversion of %s LV %s is not possible.", lvseg_name(seg), display_lvname(lv));
 	else {
-			alias = _get_segtype_alias(seg->segtype);
-
-			log_error("Converting %s from %s%s%s%s is "
+			log_error("Converting %s from %s%s is "
 				  "directly possible to the following layout%s:",
 				  display_lvname(lv), lvseg_name(seg),
-				  *alias ? " (same as " : "", alias, *alias ? ")" : "",
+				  _get_segtype_alias_str(lv, seg->segtype),
 				  possible_conversions > 1 ? "s" : "");
 
 			pt = NULL;
@@ -4526,10 +4552,16 @@ static int _takeover_noop(TAKEOVER_FN_ARGS)
 
 static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 {
-	log_error("Converting the segment type for %s from %s to %s is not supported.",
-		  display_lvname(lv), lvseg_name(first_seg(lv)),
-		  (segtype_is_striped_target(new_segtype) &&
-		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg->segtype == new_segtype)
+		log_error("Logical volume %s already is type %s.",
+			  display_lvname(lv), lvseg_name(seg));
+	else
+		log_error("Converting the segment type for %s from %s to %s is not supported.",
+			  display_lvname(lv), lvseg_name(seg),
+			  (segtype_is_striped_target(new_segtype) &&
+			  (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	if (!_log_possible_conversion_types(lv, new_segtype))
 		stack;
@@ -4737,7 +4769,7 @@ static int _rename_area_lvs(struct logical_volume *lv, const char *suffix)
 	/* Create _generate_raid_name() suffixes w/ or w/o passed in @suffix */
 	for (s = 0; s < SLV_COUNT; s++)
 		if (!(sfx[s] = dm_pool_alloc(lv->vg->cmd->mem, sz)) ||
-		    dm_snprintf(sfx[s], sz, suffix ? "%s%s" : "%s", s ? "rmeta" : "rimage", suffix) < 0)
+		    !dm_snprintf(sfx[s], sz, suffix ? "%s%s" : "%s", s ? "rmeta" : "rimage", suffix))
 			return_0;
 
 	/* Change names (temporarily) to be able to shift numerical name suffixes */
@@ -4844,6 +4876,15 @@ static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s%s LV %s to %s%s type? [y/n]: ",
+				  lvseg_name(seg), _get_segtype_alias_str(lv, seg->segtype),
+				  display_lvname(lv), new_segtype->name,
+				  _get_segtype_alias_str(lv, new_segtype)) == 'n') {
+		log_error("Logical volume %s NOT converted to \"%s\".",
+			  display_lvname(lv), new_segtype->name);
+		return 0;
+	}
+
 	log_debug_metadata("Converting LV %s from %s to %s.", display_lvname(lv),
 			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID4 : SEG_TYPE_NAME_RAID5_N),
 			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID5_N : SEG_TYPE_NAME_RAID4));
@@ -4926,8 +4967,8 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 	if (seg->area_count > 2) {
-		if (dm_snprintf(res_str, sizeof(res_str), " losing %s resilience",
-				segtype_is_striped(new_segtype) ? "all" : "some") < 0)
+		if (!dm_snprintf(res_str, sizeof(res_str), " losing %s resilience",
+				segtype_is_striped(new_segtype) ? "all" : "some"))
 			return_0;
 	} else
 		*res_str = '\0';
@@ -5018,7 +5059,7 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 	if (segtype_is_raid4(new_segtype))
-		return _raid45_to_raid54_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count,
+		return _raid45_to_raid54_wrapper(lv, new_segtype, 1 /* yes */, force, first_seg(lv)->area_count,
 						 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 
 	return 1;
@@ -5200,7 +5241,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		if (!(raid5_n_segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID5_N)))
 			return_0;
 
-		/* raid6 upconvert: vonvert to raid5_n preserving already allocated new image component pair */
+		/* raid6 upconvert: convert to raid5_n preserving already allocated new image component pair */
 		if (segtype_is_any_raid6(new_segtype)) {
 			struct logical_volume *meta_lv, *data_lv;
 
@@ -5217,7 +5258,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 						      extents_copied, seg_len);
 			seg->area_count--;
 
-			if (!_raid45_to_raid54_wrapper(lv, raid5_n_segtype, yes, force, seg->area_count,
+			if (!_raid45_to_raid54_wrapper(lv, raid5_n_segtype, 1 /* yes */, force, seg->area_count,
 						       1 /* data_copies */, 0, 0, 0, allocate_pvs))
 				return 0;
 
@@ -5774,71 +5815,144 @@ static uint64_t _raid_seg_flag_6_to_5(const struct lv_segment *seg)
 	return _get_r56_flag(seg, 1);
 }
 
-/* Change segtype for raid4 <-> raid5 <-> raid6 where necessary. */
-static int _set_convenient_raid1456_segtype_to(const struct lv_segment *seg_from,
-					       const struct segment_type **segtype,
-					       int yes)
+/* Change segtype for raid* for convenience where necessary. */
+/* FIXME: do this like _conversion_options_allowed()? */
+static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_from,
+						 const struct segment_type **segtype,
+						 int yes)
 {
-	size_t len = min(strlen((*segtype)->name), strlen(lvseg_name(seg_from)));
-	uint64_t seg_flag;
+	uint64_t seg_flag = 0;
 	struct cmd_context *cmd = seg_from->lv->vg->cmd;
 	const struct segment_type *segtype_sav = *segtype;
 
 	/* Bail out if same RAID level is requested. */
-	if (!strncmp((*segtype)->name, lvseg_name(seg_from), len))
+	if (is_same_level(seg_from->segtype, *segtype))
 		return 1;
 
-	/* Striped/raid0 -> raid5/6 */
+	log_debug("Checking LV %s requested %s segment type for convenience",
+		  display_lvname(seg_from->lv), (*segtype)->name);
+
+	/* striped/raid0 -> raid5/6 */
 	if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
 		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
-		if (segtype_is_any_raid5(*segtype) && !segtype_is_raid5_n(*segtype)) {
+		if (segtype_is_any_raid5(*segtype) && !segtype_is_raid5_n(*segtype))
 			seg_flag = SEG_RAID5_N;
-			goto replaced;
 
 		/* If this is any raid6 conversion request -> enforce raid6_n_6, because we convert from striped */
-		} else if (segtype_is_any_raid6(*segtype) && !segtype_is_raid6_n_6(*segtype)) {
+		else if (segtype_is_any_raid6(*segtype) && !segtype_is_raid6_n_6(*segtype))
 			seg_flag = SEG_RAID6_N_6;
-			goto replaced;
+
+	/* raid1 -> */
+	} else if (seg_is_raid1(seg_from) && !segtype_is_mirror(*segtype)) {
+		if (seg_from->area_count != 2) {
+			log_warn("Convert %s LV %s to 2 images first.",
+				 lvseg_name(seg_from), display_lvname(seg_from->lv));
+			return 0;
+
+		} else if (segtype_is_striped(*segtype) ||
+			   segtype_is_any_raid0(*segtype) ||
+			   segtype_is_raid10(*segtype))
+			seg_flag = SEG_RAID5_N;
+
+		else if (!segtype_is_raid4(*segtype) && !segtype_is_any_raid5(*segtype))
+			seg_flag = SEG_RAID5_LS;
+
+	/* raid4/raid5 -> striped/raid0/raid1/raid6/raid10 */
+	} else if (seg_is_raid4(seg_from) || seg_is_any_raid5(seg_from)) {
+		if (segtype_is_raid1(*segtype) &&
+		    seg_from->area_count != 2) {
+			log_warn("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
+				 lvseg_name(seg_from), display_lvname(seg_from->lv));
+			return 0;
+
+		} else if (seg_is_raid4(seg_from) &&
+			   segtype_is_any_raid5(*segtype) &&
+			   !segtype_is_raid5_n(*segtype))
+			seg_flag = SEG_RAID5_N;
+
+		else if (seg_is_any_raid5(seg_from) &&
+		    segtype_is_raid4(*segtype) &&
+		    !segtype_is_raid5_n(*segtype))
+			seg_flag = SEG_RAID5_N;
+
+		else if (segtype_is_raid10(*segtype)) {
+			if (seg_from->area_count < 3) {
+				log_warn("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
+					 lvseg_name(seg_from), display_lvname(seg_from->lv));
+				return 0;
+			}
+
+			seg_flag = seg_is_raid5_n(seg_from) ? SEG_RAID0_META : SEG_RAID5_N;
+
+		} else if (segtype_is_any_raid6(*segtype)) {
+			if (seg_from->area_count < 4) {
+				log_warn("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
+					 lvseg_name(seg_from), display_lvname(seg_from->lv));
+				return 0;
+
+			} else if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
+				seg_flag = SEG_RAID6_N_6;
+
+			else if (!(seg_flag = _raid_seg_flag_5_to_6(seg_from)))
+				seg_flag = SEG_RAID5_N;
 		}
 
-	/* raid4 -> raid5_n */
-	} else if (seg_is_raid4(seg_from) && segtype_is_any_raid5(*segtype)) {
-		seg_flag = SEG_RAID5_N;
-		goto replaced;
+	/* raid6 -> striped/raid0/raid5/raid10 */
+	} else if (seg_is_any_raid6(seg_from)) {
+		if (segtype_is_raid1(*segtype)) {
+			/* No result for raid6_{zr,nr,nc} */
+			if (!((seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
+			      !(seg_flag & (*segtype)->flags)))
+				seg_flag = SEG_RAID6_LS_6;
 
-	/* raid4/raid5_n -> striped/raid0/raid6 */
-	} else if ((seg_is_raid4(seg_from) || seg_is_raid5_n(seg_from)) &&
-		   !segtype_is_striped(*segtype) &&
-		   !segtype_is_any_raid0(*segtype) &&
-		   !segtype_is_raid1(*segtype) &&
-		   !segtype_is_raid4(*segtype) &&
-		   !segtype_is_raid5_n(*segtype) &&
-		   !segtype_is_raid6_n_6(*segtype)) {
-		seg_flag = SEG_RAID6_N_6;
-		goto replaced;
-
-	/* Got to do check for raid5 -> raid6 ... */
-	} else if (seg_is_any_raid5(seg_from) && segtype_is_any_raid6(*segtype)) {
-		if (!(seg_flag = _raid_seg_flag_5_to_6(seg_from)))
-			return_0;
-		goto replaced;
+		} else if (segtype_is_any_raid10(*segtype)) {
+			seg_flag = seg_is_raid6_n_6(seg_from) ? SEG_RAID0_META : SEG_RAID6_N_6;
 
-	/* ... and raid6 -> raid5 */
-	} else if (seg_is_any_raid6(seg_from) && segtype_is_any_raid5(*segtype)) {
-		/* No result for raid6_{zr,nr,nc} */
-		if (!(seg_flag = _raid_seg_flag_6_to_5(seg_from)))
+		} else if ((segtype_is_striped(*segtype) || segtype_is_any_raid0(*segtype)) &&
+			   !seg_is_raid6_n_6(seg_from)) {
+			seg_flag = SEG_RAID6_N_6;
+
+		} else if (segtype_is_raid4(*segtype) && !seg_is_raid6_n_6(seg_from)) {
+			seg_flag = SEG_RAID6_N_6;
+
+		} else if (segtype_is_any_raid5(*segtype))
+			/* No result for raid6_{zr,nr,nc} */
+			if (!((seg_flag = _raid_seg_flag_6_to_5(seg_from)) ||
+			      !(seg_flag & (*segtype)->flags)))
+				seg_flag = SEG_RAID6_N_6;
+
+	/* -> raid1 */
+	} else if (!seg_is_mirror(seg_from) && segtype_is_raid1(*segtype)) {
+		if (!seg_is_raid4(seg_from) && !seg_is_any_raid5(seg_from)) {
+			log_warn("Convert %s LV %s to raid4/raid5 first.",
+				 lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
-		goto replaced;
-	}
 
-	return 1;
+		} else if (seg_from->area_count != 2) {
+			log_warn("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
+				 lvseg_name(seg_from), display_lvname(seg_from->lv));
+			return 0;
+
+		}
+
+	/* raid10 -> ... */
+	} else if (seg_is_raid10(seg_from) &&
+		   !segtype_is_striped(*segtype) &&
+		   !segtype_is_any_raid0(*segtype))
+		seg_flag = SEG_RAID0_META;
+
+	if (seg_flag) {
+		if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
+			return_0;
+		if (segtype_sav != *segtype) {
+			log_warn("Replaced LV type %s%s with possible type %s.",
+				 segtype_sav->name, _get_segtype_alias_str(seg_from->lv, segtype_sav),
+				 (*segtype)->name);
+			log_warn("Repeat this command to convert to %s after an interim conversion has finished.",
+				 segtype_sav->name);
+		}
+	}
 
-replaced:
-	if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
-		return_0;
-	if (segtype_sav != *segtype)
-		log_warn("Replaced LV type %s with possible type %s.",
-			 segtype_sav->name, (*segtype)->name);
 	return 1;
 }
 
@@ -5924,7 +6038,7 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	int r = 1;
 	uint32_t opts;
 
-	if (!new_image_count && !_set_convenient_raid1456_segtype_to(seg_from, segtype_to, yes))
+	if (!new_image_count && !_set_convenient_raid145610_segtype_to(seg_from, segtype_to, yes))
 		return_0;
 
 	if (!_get_allowed_conversion_options(seg_from, *segtype_to, new_image_count, &opts)) {
@@ -5952,12 +6066,28 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	}
 
 	if (r &&
+	    !yes &&
 	    strcmp((*segtype_to)->name, SEG_TYPE_NAME_MIRROR) && /* "mirror" is prompted for later */
-	    !yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s type? [y/n]: ",
-				  lvseg_name(seg_from), display_lvname(seg_from->lv),
+	    !is_same_level(seg_from->segtype, *segtype_to)) { /* Prompt here for takeover */
+		const char *basic_fmt = "Are you sure you want to convert %s LV %s";
+		const char *type_fmt = " to %s type";
+		const char *question_fmt = " to %s type";
+		char *fmt;
+		size_t sz = strlen(basic_fmt) + ((seg_from->segtype == *segtype_to) ? 0 : strlen(type_fmt)) + strlen(question_fmt) + 1;
+
+		if (!(fmt = dm_pool_alloc(seg_from->lv->vg->cmd->mem, sz)))
+			return_0;
+
+		if (!dm_snprintf(fmt, sz, "%s%s%s", basic_fmt, (seg_from->segtype == *segtype_to) ? "" : type_fmt, question_fmt)) {
+			log_error(INTERNAL_ERROR "dm_snprintf failed.");
+			return_0;
+		}
+
+		if (yes_no_prompt(fmt, lvseg_name(seg_from), display_lvname(seg_from->lv),
 				  (*segtype_to)->name) == 'n') {
-		log_error("Logical volume %s NOT converted.", display_lvname(seg_from->lv));
-		r = 0;
+			log_error("Logical volume %s NOT converted.", display_lvname(seg_from->lv));
+			r = 0;
+		}
 	}
 
 	return r;
@@ -6040,6 +6170,15 @@ int lv_raid_convert(struct logical_volume *lv,
 	region_size = region_size ? : get_default_region_size(lv->vg->cmd);
 
 	/*
+	 * Check acceptible options mirrors, region_size,
+	 * stripes and/or stripe_size have been provided.
+	 */
+	if (!_conversion_options_allowed(seg, &new_segtype, yes,
+					 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
+					 new_stripes, new_stripe_size_supplied))
+		return _log_possible_conversion_types(lv, new_segtype);
+
+	/*
 	 * reshape of capable raid type requested
 	 */
 	switch (_reshape_requested(lv, new_segtype, data_copies, region_size, stripes, stripe_size)) {
@@ -6074,15 +6213,6 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	/*
-	 * Check acceptible options mirrors, region_size,
-	 * stripes and/or stripe_size have been provided.
-	 */
-	if (!_conversion_options_allowed(seg, &new_segtype, yes,
-					 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
-					 new_stripes, new_stripe_size_supplied))
-		return _log_possible_conversion_types(lv, new_segtype);
-	
 	takeover_fn = _get_takeover_fn(first_seg(lv), new_segtype, new_image_count);
 
 	/* Exit without doing activation checks if the combination isn't possible */


