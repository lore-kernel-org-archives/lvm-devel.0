From: heinzm@redhat.com <heinzm@redhat.com>
Date: Wed, 24 Sep 2014 14:33:21 +0200
Subject: [PATCH] Use segtype.h definitions of segment type names wherever possible
Message-ID: <1411562001-11962-1-git-send-email-heinzm@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Heinz Mauelshagen <heinzm@redhat.com>


We are not using already defined segement type names where we could.

There is a lot of other places in device-mapper and LVM2 we have those hardcoded
so we should better finally have a common interface in libdevmapper to avoid this.



---
 lib/metadata/lv_manip.c   | 30 +++++++++++++++---------------
 lib/metadata/raid_manip.c | 12 ++++++------
 lib/raid/raid.c           |  4 ++--
 tools/lvchange.c          |  2 +-
 tools/lvconvert.c         |  9 +++++----
 tools/lvcreate.c          | 10 +++++-----
 6 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 968b8d0..5589cc7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -158,18 +158,18 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_DATA] =				"data",
 	[LV_TYPE_SPARE] =				"spare",
 	[LV_TYPE_VIRTUAL] =				"virtual",
-	[LV_TYPE_RAID1] =				"raid1",
-	[LV_TYPE_RAID10] =				"raid10",
-	[LV_TYPE_RAID4] =				"raid4",
-	[LV_TYPE_RAID5] =				"raid5",
-	[LV_TYPE_RAID5_LA] =				"raid5_la",
-	[LV_TYPE_RAID5_RA] =				"raid5_ra",
-	[LV_TYPE_RAID5_LS] =				"raid5_ls",
-	[LV_TYPE_RAID5_RS] =				"raid5_rs",
-	[LV_TYPE_RAID6] =				"raid6",
-	[LV_TYPE_RAID6_ZR] =				"raid6_zr",
-	[LV_TYPE_RAID6_NR] =				"raid6_nr",
-	[LV_TYPE_RAID6_NC] =				"raid6_nc",
+	[LV_TYPE_RAID1] =				SEG_TYPE_NAME_RAID1,
+	[LV_TYPE_RAID10] =				SEG_TYPE_NAME_RAID10,
+	[LV_TYPE_RAID4] =				SEG_TYPE_NAME_RAID4,
+	[LV_TYPE_RAID5] =				SEG_TYPE_NAME_RAID5,
+	[LV_TYPE_RAID5_LA] =				SEG_TYPE_NAME_RAID5_LA,
+	[LV_TYPE_RAID5_RA] =				SEG_TYPE_NAME_RAID5_RA,
+	[LV_TYPE_RAID5_LS] =				SEG_TYPE_NAME_RAID5_LS,
+	[LV_TYPE_RAID5_RS] =				SEG_TYPE_NAME_RAID5_RS,
+	[LV_TYPE_RAID6] =				SEG_TYPE_NAME_RAID6,
+	[LV_TYPE_RAID6_ZR] =				SEG_TYPE_NAME_RAID6_ZR,
+	[LV_TYPE_RAID6_NR] =				SEG_TYPE_NAME_RAID6_NR,
+	[LV_TYPE_RAID6_NC] =				SEG_TYPE_NAME_RAID6_NC,
 };
 
 static int _lv_layout_and_role_mirror(struct dm_pool *mem,
@@ -1476,7 +1476,7 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 	 *          the 'stripes' argument will always need to
 	 *          be given.
 	 */
-	if (!strcmp(segtype->name, "raid10")) {
+	if (!strcmp(segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
 		if (!stripes)
 			return area_count / 2;
 		return stripes;
@@ -4575,7 +4575,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			return 0;
 		}
 
-		if (!strcmp(mirr_seg->segtype->name, "raid10")) {
+		if (!strcmp(mirr_seg->segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
 			/* FIXME Warn if command line values are being overridden? */
 			lp->stripes = mirr_seg->area_count / seg_mirrors;
 			lp->stripe_size = mirr_seg->stripe_size;
@@ -4588,7 +4588,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 				/* Allow through "striped" and RAID 4/5/6/10 */
 				if (!seg_is_striped(seg) &&
 				    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
-				    strcmp(seg->segtype->name, "raid10"))
+				    strcmp(seg->segtype->name, _lv_type_names[LV_TYPE_RAID10]))
 					continue;
 	
 				sz = seg->stripe_size;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f494f11..603ad1f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -431,7 +431,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 
 	if (seg_is_raid(seg))
 		segtype = seg->segtype;
-	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
+	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
 		return_0;
 
 	/*
@@ -631,7 +631,7 @@ static int _raid_add_images(struct logical_volume *lv,
 			log_very_verbose("Setting RAID1 region_size to %uS",
 					 seg->region_size);
 		}
-		if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
+		if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
 			return_0;
 	}
 /*
@@ -1073,7 +1073,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	}
 
 	if (!seg_is_mirrored(first_seg(lv)) ||
-	    !strcmp(first_seg(lv)->segtype->name, "raid10")) {
+	    !strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		log_error("Unable to split logical volume of segment type, %s",
 			  first_seg(lv)->segtype->ops->name(first_seg(lv)));
 		return 0;
@@ -1440,7 +1440,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 	}
 
 	if (!strcmp(seg->segtype->name, "mirror") &&
-	    (!strcmp(new_segtype->name, "raid1")))
+	    (!strcmp(new_segtype->name, SEG_TYPE_NAME_RAID1)))
 	    return _convert_mirror_to_raid1(lv, new_segtype);
 
 	log_error("Converting the segment type for %s/%s from %s to %s"
@@ -1604,7 +1604,7 @@ int lv_raid_replace(struct logical_volume *lv,
 			  raid_seg->segtype->ops->name(raid_seg),
 			  lv->vg->name, lv->name);
 		return 0;
-	} else if (!strcmp(raid_seg->segtype->name, "raid10")) {
+	} else if (!strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		uint32_t i, rebuilds_per_group = 0;
 		/* FIXME: We only support 2-way mirrors in RAID10 currently */
 		uint32_t copies = 2;
@@ -1829,7 +1829,7 @@ static int _partial_raid_lv_is_redundant(struct logical_volume *lv)
 	uint32_t i, s, rebuilds_per_group = 0;
 	uint32_t failed_components = 0;
 
-	if (!strcmp(raid_seg->segtype->name, "raid10")) {
+	if (!strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		/* FIXME: We only support 2-way mirrors in RAID10 currently */
 		copies = 2;
 		for (i = 0; i < raid_seg->area_count * copies; i++) {
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 831c912..6628dc8 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -248,7 +248,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		/* RAID 4/5/6 */
 		params.mirrors = 1;
 		params.stripes = seg->area_count - seg->segtype->parity_devs;
-	} else if (strcmp(seg->segtype->name, "raid10")) {
+	} else if (strcmp(seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		/* RAID 10 only supports 2 mirrors now */
 		params.mirrors = 2;
 		params.stripes = seg->area_count / 2;
@@ -336,7 +336,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 		unsigned raid_feature;
 		const char *feature;
 	} _features[] = {
-		{ 1, 3, RAID_FEATURE_RAID10, "raid10" },
+		{ 1, 3, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
 	};
 
 	static int _raid_checked = 0;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e520157..eb13225 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -640,7 +640,7 @@ static int lvchange_writemostly(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
-	if (strcmp(raid_seg->segtype->name, "raid1")) {
+	if (strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID1)) {
 		log_error("--write%s can only be used with 'raid1' segment type",
 			  arg_count(cmd, writemostly_ARG) ? "mostly" : "behind");
 		return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6a2676b..74b6e17 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1720,8 +1720,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 
 	if (lv_is_thin_type(lv)) {
 		log_error("Mirror segment type cannot be used for thinpool%s.\n"
-			  "Try \"raid1\" segment type instead.",
-			  lv_is_thin_pool_data(lv) ? "s" : " metadata");
+			  "Try \"%s\" segment type instead.",
+			  lv_is_thin_pool_data(lv) ? "s" : " metadata",
+			  SEG_TYPE_NAME_RAID1);
 		return 0;
 	}
 
@@ -2703,7 +2704,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (lv_is_mirror(metadata_lv)) {
 			log_error("Mirror logical volumes cannot be used "
 				  "for pool metadata.");
-			log_error("Try \"raid1\" segment type instead.");
+			log_error("Try \"%s\" segment type instead.", SEG_TYPE_NAME_RAID1);
 			return 0;
 		}
 
@@ -2755,7 +2756,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 
 	if (lv_is_mirror(pool_lv)) {
 		log_error("Mirror logical volumes cannot be used as pools.\n"
-			  "Try \"raid1\" segment type instead.");
+			  "Try \"%s\" segment type instead.", SEG_TYPE_NAME_RAID1);
 		return 0;
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 499d686..7c811ba 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -625,7 +625,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if (!strcmp(lp->segtype->name, "raid10") && (lp->stripes < 2)) {
+	if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10) && (lp->stripes < 2)) {
 		if (arg_count(cmd, stripes_ARG)) {
 			/* User supplied the bad argument */
 			log_error("Segment type 'raid10' requires 2 or more stripes.");
@@ -651,7 +651,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	 */
 	if ((lp->stripes > 1) &&
 	    segtype_is_mirrored(lp->segtype) &&
-	    strcmp(lp->segtype->name, "raid10")) {
+	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		log_error("Stripe argument cannot be used with segment type, %s",
 			  lp->segtype->name);
 		return 0;
@@ -895,7 +895,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			log_print_unless_silent("Redundant mirrors argument: default is 0");
 		}
 
-		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, "raid10")) {
+		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
 			/*
 			 * FIXME: When RAID10 is no longer limited to
 			 *        2-way mirror, 'lv_mirror_count()'
@@ -942,7 +942,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			return 0;
 		}
 
-		if ((strcmp(lp->segtype->name, "raid10") == 0) &&
+		if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID10)) {
 			log_error("RAID module does not support RAID10.");
 			return 0;
@@ -1154,7 +1154,7 @@ static int _check_raid_parameters(struct volume_group *vg,
 				  lp->segtype->name);
 			return 0;
 		}
-	} else if (!strcmp(lp->segtype->name, "raid10")) {
+	} else if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		if (!arg_count(cmd, stripes_ARG))
 			lp->stripes = devs / lp->mirrors;
 		if (lp->stripes < 2) {
-- 
1.9.3


