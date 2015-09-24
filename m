From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 14:09:03 +0000 (UTC)
Subject: master - segtypes: Add and use new segtype macros.
Message-ID: <20150924140903.525026020C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39a97d86f09df0d89664c7ddae28ca1d1bb3a741
Commit:        39a97d86f09df0d89664c7ddae28ca1d1bb3a741
Parent:        41fe225b0deecea871354b321d23fad548857518
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Sep 24 14:59:07 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 14:59:07 2015 +0100

segtypes: Add and use new segtype macros.

Includes fixing an inverted raid10 segtype check in _raid_add_target_line.
---
 lib/activate/dev_manager.c |   10 +++++-----
 lib/metadata/lv_manip.c    |   31 +++++++++++++++----------------
 lib/metadata/mirror.c      |    2 +-
 lib/metadata/raid_manip.c  |   16 +++++++---------
 lib/metadata/segtype.h     |   27 +++++++++++++++++++++++++++
 lib/raid/raid.c            |    2 +-
 tools/lvchange.c           |    2 +-
 tools/lvcreate.c           |   14 ++++++--------
 8 files changed, 63 insertions(+), 41 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5a1e18b..a5ee824 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -143,23 +143,23 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		return 0;
 	}
 
-	if (!strcmp(segtype->name, SEG_TYPE_NAME_CACHE)) {
+	if (segtype_is_cache(segtype)) {
 		if (!dm_get_status_cache(seg_status->mem, params, &(seg_status->cache)))
 			return_0;
 		seg_status->type = SEG_STATUS_CACHE;
-	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID)) {
+	} else if (segtype_is_raid(segtype)) {
 		if (!dm_get_status_raid(seg_status->mem, params, &seg_status->raid))
 			return_0;
 		seg_status->type = SEG_STATUS_RAID;
-	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_THIN)) {
+	} else if (segtype_is_thin_volume(segtype)) {
 		if (!dm_get_status_thin(seg_status->mem, params, &seg_status->thin))
 			return_0;
 		seg_status->type = SEG_STATUS_THIN;
-	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_THIN_POOL)) {
+	} else if (segtype_is_thin_pool(segtype)) {
 		if (!dm_get_status_thin_pool(seg_status->mem, params, &seg_status->thin_pool))
 			return_0;
 		seg_status->type = SEG_STATUS_THIN_POOL;
-	} else if (!strcmp(segtype->name, SEG_TYPE_NAME_SNAPSHOT)) {
+	} else if (segtype_is_snapshot(segtype)) {
 		if (!dm_get_status_snapshot(seg_status->mem, params, &seg_status->snapshot))
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 69a6b6e..ac3d25f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -224,7 +224,7 @@ static int _lv_layout_and_role_raid(struct dm_pool *mem,
 				    int *public_lv)
 {
 	int top_level = 0;
-	const char *seg_name;
+	const struct segment_type *segtype;
 
 	/* non-top-level LVs */
 	if (lv_is_raid_image(lv)) {
@@ -251,45 +251,45 @@ static int _lv_layout_and_role_raid(struct dm_pool *mem,
 	if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
 		goto_bad;
 
-	seg_name = first_seg(lv)->segtype->name;
+	segtype = first_seg(lv)->segtype;
 
-	if (!strcmp(seg_name, SEG_TYPE_NAME_RAID1)) {
+	if (segtype_is_raid1(segtype)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID1]))
 			goto_bad;
-	} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID10)) {
+	} else if (segtype_is_raid10(segtype)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID10]))
 			goto_bad;
-	} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID4)) {
+	} else if (segtype_is_raid4(segtype)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID4]))
 			goto_bad;
-	} else if (!strncmp(seg_name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5))) {
+	} else if (segtype_is_any_raid5(segtype)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5]))
 			goto_bad;
 
-		if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_LA)) {
+		if (segtype_is_raid5_la(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_LA]))
 				goto_bad;
-		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_RA)) {
+		} else if (segtype_is_raid5_ra(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_RA]))
 				goto_bad;
-		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_LS)) {
+		} else if (segtype_is_raid5_ls(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_LS]))
 				goto_bad;
-		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_RS)) {
+		} else if (segtype_is_raid5_rs(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_RS]))
 				goto_bad;
 		}
-	} else if (!strncmp(seg_name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6))) {
+	} else if (segtype_is_any_raid6(segtype)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6]))
 			goto_bad;
 
-		if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_ZR)) {
+		if (segtype_is_raid6_zr(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6_ZR]))
 				goto_bad;
-		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_NR)) {
+		} else if (segtype_is_raid6_nr(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6_NR]))
 				goto_bad;
-		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_NC)) {
+		} else if (segtype_is_raid6_nc(segtype)) {
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6_NC]))
 				goto_bad;
 		}
@@ -3669,8 +3669,7 @@ int lv_add_log_segment(struct alloc_handle *ah, uint32_t first_area,
 {
 
 	return lv_add_segment(ah, ah->area_count + first_area, 1, log_lv,
-			      get_segtype_from_string(log_lv->vg->cmd,
-						      SEG_TYPE_NAME_STRIPED),
+			      get_segtype_from_string(log_lv->vg->cmd, SEG_TYPE_NAME_STRIPED),
 			      0, status, 0);
 }
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index d4d2104..8166e89 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -112,7 +112,7 @@ uint32_t lv_mirror_count(const struct logical_volume *lv)
 	seg = first_seg(lv);
 
 	/* FIXME: RAID10 only supports 2 copies right now */
-	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_RAID10))
+	if (seg_is_raid10(seg))
 		return 2;
 
 	if (lv_is_pvmove(lv))
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 87e6c8c..5919e3b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1102,7 +1102,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	}
 
 	if (!seg_is_mirrored(first_seg(lv)) ||
-	    !strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	    seg_is_raid10(first_seg(lv))) {
 		log_error("Unable to split logical volume of segment type, %s",
 			  lvseg_name(first_seg(lv)));
 		return 0;
@@ -1475,13 +1475,11 @@ int lv_raid_reshape(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_MIRROR) &&
-	    (!strcmp(new_segtype->name, SEG_TYPE_NAME_RAID1)))
-	    return _convert_mirror_to_raid1(lv, new_segtype);
+	if (seg_is_mirror(seg) && segtype_is_raid1(new_segtype))
+		return _convert_mirror_to_raid1(lv, new_segtype);
 
-	log_error("Converting the segment type for %s/%s from %s to %s"
-		  " is not yet supported.", lv->vg->name, lv->name,
-		  lvseg_name(seg), new_segtype->name);
+	log_error("Converting the segment type for %s/%s from %s to %s is not yet supported.",
+		  lv->vg->name, lv->name, lvseg_name(seg), new_segtype->name);
 	return 0;
 }
 
@@ -1663,7 +1661,7 @@ int lv_raid_replace(struct logical_volume *lv,
 			  lvseg_name(raid_seg),
 			  lv->vg->name, lv->name);
 		return 0;
-	} else if (!strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	} else if (seg_is_raid10(raid_seg)) {
 		uint32_t i, rebuilds_per_group = 0;
 		/* FIXME: We only support 2-way mirrors in RAID10 currently */
 		uint32_t copies = 2;
@@ -1895,7 +1893,7 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 	uint32_t i, s, rebuilds_per_group = 0;
 	uint32_t failed_components = 0;
 
-	if (!strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	if (seg_is_raid10(raid_seg)) {
 		/* FIXME: We only support 2-way mirrors in RAID10 currently */
 		copies = 2;
 		for (i = 0; i < raid_seg->area_count * copies; i++) {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index aa18224..a14f9d0 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -80,6 +80,20 @@ struct dev_manager;
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
+#define segtype_is_raid1(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID1))
+#define segtype_is_raid4(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID4))
+#define segtype_is_raid5(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5))
+#define segtype_is_any_raid5(segtype)	(!strncmp((segtype)->name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5)))
+#define segtype_is_raid5_la(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_LA))
+#define segtype_is_raid5_ra(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_RA))
+#define segtype_is_raid5_ls(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_LS))
+#define segtype_is_raid5_rs(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID5_RS))
+#define segtype_is_any_raid6(segtype)	(!strncmp((segtype)->name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6)))
+#define segtype_is_raid6_zr(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID6_ZR))
+#define segtype_is_raid6_nr(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID6_NR))
+#define segtype_is_raid6_nc(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID6_NC))
+#define segtype_is_raid10(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_RAID10))
+#define segtype_is_snapshot(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_SNAPSHOT))
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
 #define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
@@ -94,6 +108,19 @@ struct dev_manager;
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
 #define seg_is_pool(seg)	segtype_is_pool((seg)->segtype)
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
+#define seg_is_raid1(seg)	segtype_is_raid1((seg)->segtype)
+#define seg_is_raid4(seg)	segtype_is_raid4((seg)->segtype)
+#define seg_is_raid5(seg)	segtype_is_raid5((seg)->segtype)
+#define seg_is_any_raid5(seg)	segtype_is_any_raid5((seg)->segtype)
+#define seg_is_raid5_la(seg)	segtype_is_raid5_la((seg)->segtype)
+#define seg_is_raid5_ra(seg)	segtype_is_raid5_ra((seg)->segtype)
+#define seg_is_raid5_ls(seg)	segtype_is_raid5_ls((seg)->segtype)
+#define seg_is_raid5_rs(seg)	segtype_is_raid5_rs((seg)->segtype)
+#define seg_is_any_raid6(seg)	segtype_is_any_raid6((seg)->segtype)
+#define seg_is_raid6_zr(seg)	segtype_is_raid6_zr((seg)->segtype)
+#define seg_is_raid6_nr(seg)	segtype_is_raid6_nr((seg)->segtype)
+#define seg_is_raid6_nc(seg)	segtype_is_raid6_nc((seg)->segtype)
+#define seg_is_raid10(seg)	segtype_is_raid10((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 290a590..13b9b6e 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -242,7 +242,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		/* RAID 4/5/6 */
 		params.mirrors = 1;
 		params.stripes = seg->area_count - seg->segtype->parity_devs;
-	} else if (strcmp(seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	} else if (seg_is_raid10(seg)) {
 		/* RAID 10 only supports 2 mirrors now */
 		params.mirrors = 2;
 		params.stripes = seg->area_count / 2;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e24c07a..bd34d11 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -731,7 +731,7 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
-	if (strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID1)) {
+	if (!seg_is_raid1(raid_seg)) {
 		log_error("--write%s can only be used with 'raid1' segment type",
 			  arg_count(cmd, writemostly_ARG) ? "mostly" : "behind");
 		return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e19ae01..80c336a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -453,7 +453,7 @@ static int _read_mirror_params(struct cmd_context *cmd,
 static int _read_raid_params(struct cmd_context *cmd,
 			     struct lvcreate_params *lp)
 {
-	if ((lp->stripes < 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	if ((lp->stripes < 2) && segtype_is_raid10(lp->segtype)) {
 		if (arg_count(cmd, stripes_ARG)) {
 			/* User supplied the bad argument */
 			log_error("Segment type 'raid10' requires 2 or more stripes.");
@@ -468,15 +468,14 @@ static int _read_raid_params(struct cmd_context *cmd,
 	 * RAID1 does not take a stripe arg
 	 */
 	if ((lp->stripes > 1) && seg_is_mirrored(lp) &&
-	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	    !segtype_is_raid10(lp->segtype)) {
 		log_error("Stripe argument cannot be used with segment type, %s",
 			  lp->segtype->name);
 		return 0;
 	}
 
 	if (arg_count(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
-	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID1) &&
-	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	    !segtype_is_raid1(lp->segtype) && !segtype_is_raid10(lp->segtype)) {
 		log_error("Mirror argument cannot be used with segment type, %s",
 			  lp->segtype->name);
 		return 0;
@@ -512,7 +511,7 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+		if ((lp->mirrors > 2) && segtype_is_raid10(lp->segtype)) {
 			/*
 			 * FIXME: When RAID10 is no longer limited to
 			 *        2-way mirror, 'lv_mirror_count()'
@@ -974,8 +973,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10) &&
-		    !(lp->target_attr & RAID_FEATURE_RAID10)) {
+		if (segtype_is_raid10(lp->segtype) && !(lp->target_attr & RAID_FEATURE_RAID10)) {
 			log_error("RAID module does not support RAID10.");
 			return 0;
 		}
@@ -1215,7 +1213,7 @@ static int _check_raid_parameters(struct volume_group *vg,
 				  lp->segtype->name);
 			return 0;
 		}
-	} else if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	} else if (segtype_is_raid10(lp->segtype)) {
 		if (!arg_count(cmd, stripes_ARG))
 			lp->stripes = devs / lp->mirrors;
 		if (lp->stripes < 2) {


