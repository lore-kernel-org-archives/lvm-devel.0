From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:17 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063217.9AC7F60AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=932db3db535734f03cec973182dcc73adef9d3a5
Commit:        932db3db535734f03cec973182dcc73adef9d3a5
Parent:        fe18e5e77a488618510648c7801ea3375ce5aac4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 03:11:41 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- add missing possible reshape conversions and conversion options
  to allow/prohibit changing stripesize or number fo stripes
- enhance setting convenient riad types in reshape conversions
  (e.g. raid1 with 2 legs -> radi5_n)

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |  149 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 117 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cc074f6..81360d2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -26,6 +26,7 @@ typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
 static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 						      struct dm_list *removal_lvs,
 						      int vg_write_requested);
+#define	ARRAY_SIZE(a) (sizeof(a) / sizeof(*a))
 
 static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 {
@@ -4211,37 +4212,68 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	{ .current_types  = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
 	  .possible_types = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_REGION_SIZE },
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
+
+	/* Reshape raid5* <-> raid5* */
+	{ .current_types  = SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
+	  .possible_types = SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
+	  .current_areas = ~0U,
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
 
+	/* Reshape raid6* <-> raid6* */
+	{ .current_types  = SEG_RAID6_ZR|SEG_RAID6_NR|SEG_RAID6_NC|SEG_RAID6_LS_6|\
+			    SEG_RAID6_RS_6|SEG_RAID6_RA_6|SEG_RAID6_LA_6|SEG_RAID6_N_6,
+	  .possible_types = SEG_RAID6_ZR|SEG_RAID6_NR|SEG_RAID6_NC|SEG_RAID6_LS_6|\
+			    SEG_RAID6_RS_6|SEG_RAID6_RA_6|SEG_RAID6_LA_6|SEG_RAID6_N_6,
+	  .current_areas = ~0U,
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
 
 	/* raid5_ls <-> raid6_ls_6 */
 	{ .current_types  = SEG_RAID5_LS|SEG_RAID6_LS_6,
 	  .possible_types = SEG_RAID5_LS|SEG_RAID6_LS_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_REGION_SIZE },
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
 
 	/* raid5_rs -> raid6_rs_6 */
 	{ .current_types  = SEG_RAID5_RS|SEG_RAID6_RS_6,
 	  .possible_types = SEG_RAID5_RS|SEG_RAID6_RS_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_REGION_SIZE },
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
 
 	/* raid5_ls -> raid6_la_6 */
 	{ .current_types  = SEG_RAID5_LA|SEG_RAID6_LA_6,
 	  .possible_types = SEG_RAID5_LA|SEG_RAID6_LA_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_REGION_SIZE },
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
 
 	/* raid5_ls -> raid6_ra_6 */
 	{ .current_types  = SEG_RAID5_RA|SEG_RAID6_RA_6,
 	  .possible_types = SEG_RAID5_RA|SEG_RAID6_RA_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_REGION_SIZE },
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
+
+	/* Reshape raid10 <-> raid10 */
+	{ .current_types  = SEG_RAID10_NEAR,
+	  .possible_types = SEG_RAID10_NEAR,
+	  .current_areas = ~0U,
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
 
 	/* mirror <-> raid1 with arbitrary number of legs */
 	{ .current_types  = SEG_MIRROR|SEG_RAID1,
 	  .possible_types = SEG_MIRROR|SEG_RAID1,
 	  .current_areas = ~0U,
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPES|ALLOW_STRIPE_SIZE },
+
+	/* raid1 -> raid5* with 2 legs */
+	{ .current_types  = SEG_RAID1,
+	  .possible_types = SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
+	  .current_areas = 2U,
+	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPE_SIZE },
+
+	/* raid5* -> raid1 with 2 legs */
+	{ .current_types  = SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
+	  .possible_types = SEG_RAID1,
+	  .current_areas = 2U,
 	  .options = ALLOW_REGION_SIZE },
 
 	/* END */
@@ -5323,7 +5355,7 @@ static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
 
 /*
  * Only if we decide to support raid01 at all.
- 
+
 static int _takeover_from_raid01_to_raid01(TAKEOVER_FN_ARGS)
 {
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
@@ -5437,11 +5469,51 @@ static int _log_prohibited_option(const struct lv_segment *seg_from,
 	return 1;
 }
 
-/* Change segtype for raid4 <-> raid5 <-> raid6 takeover where necessary. */
-static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
-					      const struct segment_type **segtype)
+/*
+ * Find takeover raid flag for segment type flag of @seg
+ */
+/* Segment type flag correspondence for raid5 <-> raid6 conversions */
+static uint64_t _r5_to_r6[][2] = {
+	{ SEG_RAID5_LS, SEG_RAID6_LS_6 },
+	{ SEG_RAID5_LA, SEG_RAID6_LA_6 },
+	{ SEG_RAID5_RS, SEG_RAID6_RS_6 },
+	{ SEG_RAID5_RA, SEG_RAID6_RA_6 },
+	{ SEG_RAID5_N,  SEG_RAID6_N_6 },
+};
+
+
+/* Return segment type flag for raid5 -> raid6 conversions */
+static uint64_t _get_r56_flag(const struct lv_segment *seg, unsigned idx)
+{
+	unsigned elems = ARRAY_SIZE(_r5_to_r6);
+
+	while (elems--)
+		if (seg->segtype->flags & _r5_to_r6[elems][idx])
+			return _r5_to_r6[elems][!idx];
+
+	return 0;
+}
+
+/* Return segment type flag for raid5 -> raid6 conversions */
+static uint64_t _raid_seg_flag_5_to_6(const struct lv_segment *seg)
+{
+	return _get_r56_flag(seg, 0);
+}
+
+/* Return segment type flag for raid6 -> raid5 conversions */
+static uint64_t _raid_seg_flag_6_to_5(const struct lv_segment *seg)
+{
+	return _get_r56_flag(seg, 1);
+}
+
+/* Change segtype for raid4 <-> raid5 <-> raid6 or raid1 <-> raid5 takeover where necessary. */
+static int _set_convenient_raid1456_segtype_to(const struct lv_segment *seg_from,
+					       const struct segment_type **segtype,
+					       int yes)
 {
 	size_t len = min(strlen((*segtype)->name), strlen(lvseg_name(seg_from)));
+	uint64_t seg_flag;
+	struct cmd_context *cmd = seg_from->lv->vg->cmd;
 	const struct segment_type *segtype_sav = *segtype;
 
 	/* Bail out if same RAID level is requested. */
@@ -5451,54 +5523,66 @@ static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
 	/* Striped/raid0 -> raid5/6 */
 	if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
 		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
-		if (segtype_is_any_raid5(*segtype) &&
-		    !segtype_is_raid5_n(*segtype)) {
-			if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID5_N)))
-				return_0;
+		if (segtype_is_any_raid5(*segtype) && !segtype_is_raid5_n(*segtype)) {
+			seg_flag = SEG_RAID5_N;
 			goto replaced;
 
 		/* If this is any raid6 conversion request -> enforce raid6_n_6, because we convert from striped */
-		} else if (segtype_is_any_raid6(*segtype) &&
-			   !segtype_is_raid6_n_6(*segtype)) {
-			if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID6_N_6)))
-				return_0;
+		} else if (segtype_is_any_raid6(*segtype) && !segtype_is_raid6_n_6(*segtype)) {
+			seg_flag = SEG_RAID6_N_6;
 			goto replaced;
 		}
 
+	/* raid1 -> raid5_n with 2 areas */
+	} else if (seg_is_raid1(seg_from) && seg_from->area_count == 2 &&
+                   segtype_is_any_raid5(*segtype) && !segtype_is_raid5_n(*segtype)) {
+		seg_flag = SEG_RAID5_N;
+		goto replaced;
+
 	/* raid4 -> raid5_n */
-	} else if (seg_is_raid4(seg_from) &&
-		   segtype_is_any_raid5(*segtype)) {
-		if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID5_N)))
-			return_0;
+	} else if (seg_is_raid4(seg_from) && segtype_is_any_raid5(*segtype)) {
+		seg_flag = SEG_RAID5_N;
 		goto replaced;
 
 	/* raid4/raid5_n -> striped/raid0/raid6 */
 	} else if ((seg_is_raid4(seg_from) || seg_is_raid5_n(seg_from)) &&
 		   !segtype_is_striped(*segtype) &&
 		   !segtype_is_any_raid0(*segtype) &&
+		   !segtype_is_raid1(*segtype) &&
 		   !segtype_is_raid4(*segtype) &&
 		   !segtype_is_raid5_n(*segtype) &&
 		   !segtype_is_raid6_n_6(*segtype)) {
-		if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID6_N_6)))
-			return_0;
+		seg_flag = SEG_RAID6_N_6;
 		goto replaced;
 
-	/* ... and raid6 -> striped/raid0/raid4/raid5_n */
-	} else if (seg_is_raid6_n_6(seg_from) &&
-		   !segtype_is_striped(*segtype) &&
-		   !segtype_is_any_raid0(*segtype) &&
-		   !segtype_is_raid4(*segtype) &&
-		   !segtype_is_raid5_n(*segtype)) {
-		if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID5_N)))
+	/* Got to do check for raid5 -> raid6 ... */
+	} else if (seg_is_any_raid5(seg_from) && segtype_is_any_raid6(*segtype)) {
+		if (!(seg_flag = _raid_seg_flag_5_to_6(seg_from)))
 			return_0;
 		goto replaced;
+
+	/* ... and raid6 -> raid5 */
+	} else if (seg_is_any_raid6(seg_from) && segtype_is_any_raid5(*segtype)) {
+		/* No result for raid6_{zr,nr,nc} */
+		if (!(seg_flag = _raid_seg_flag_6_to_5(seg_from)))
+			return 0;
+		goto replaced;
 	}
 
 	return 1;
 
 replaced:
+	if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
+		return_0;
 	log_warn("Replaced LV type %s with possible type %s.",
 		 segtype_sav->name, (*segtype)->name);
+	if (!yes && yes_no_prompt("Do you want to convert %s LV %s to %s? [y/n]: ",
+				  segtype_sav->name, display_lvname(seg_from->lv),
+				  (*segtype)->name) == 'n') {
+		log_error("Logical volume %s NOT converted.", display_lvname(seg_from->lv));
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -5584,6 +5668,7 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 /* Check allowed conversion from seg_from to *segtype_to */
 static int _conversion_options_allowed(const struct lv_segment *seg_from,
 				       const struct segment_type **segtype_to,
+				       int yes,
 				       uint32_t new_image_count,
 				       int new_data_copies, int new_region_size,
 				       int stripes, unsigned new_stripe_size_supplied)
@@ -5591,7 +5676,7 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	int r = 1;
 	uint32_t opts;
 
-	if (!new_image_count && !_set_convenient_raid456_segtype_to(seg_from, segtype_to))
+	if (!new_image_count && !_set_convenient_raid1456_segtype_to(seg_from, segtype_to, yes))
 		return_0;
 
 	if (!_get_allowed_conversion_options(seg_from, *segtype_to, new_image_count, &opts)) {
@@ -5682,7 +5767,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	 * Check acceptible options mirrors, region_size,
 	 * stripes and/or stripe_size have been provided.
 	 */
-	if (!_conversion_options_allowed(seg, &new_segtype, 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
+	if (!_conversion_options_allowed(seg, &new_segtype, yes, 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
 					 new_stripes, new_stripe_size_supplied))
 		return _log_possible_conversion_types(lv, new_segtype);
 	


