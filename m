From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 May 2016 15:49:02 +0000 (UTC)
Subject: master - raid0: Add raid0 segment type.
Message-ID: <20160523154902.44CAC60CE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf8d00985ada723778701530c7ea863c617dda8a
Commit:        bf8d00985ada723778701530c7ea863c617dda8a
Parent:        ad4ca55543428f909fde8ba03e88d355560fe320
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon May 23 16:46:38 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon May 23 16:46:38 2016 +0100

raid0: Add raid0 segment type.

This remains experimental and quite restrictive so should only be used
for testing at this stage.  (E.g. lvreduce is not supported.)
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   14 +++--
 lib/format_text/export.c   |   13 +++--
 lib/metadata/lv_manip.c    |   31 +++++++----
 lib/metadata/segtype.h     |    5 ++
 lib/raid/raid.c            |  128 +++++++++++++++++++++++++++++++-------------
 lib/report/report.c        |    2 +-
 libdm/libdm-deptree.c      |    5 ++
 man/lvcreate.8.in          |   12 ++++-
 tools/lvcreate.c           |   27 +++++++---
 10 files changed, 168 insertions(+), 70 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 645e87e..eac3477 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Add basic support for --type raid0 using md.
   Add support for lvchange --cachemode for cached LV.
   Fix liblvm2app error handling when setting up context.
   Delay liblvm2app init in python code until it is needed.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f6cc0be..711074d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2207,7 +2207,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    (!dm->track_pending_delete || !lv_is_cache(lv)) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
 				return_0;
-			if (seg_is_raid(seg) &&
+			if (seg_is_raid(seg) && seg->meta_areas && seg_metalv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
 				return_0;
 		}
@@ -2379,9 +2379,13 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 					return_0;
 				continue;
 			}
-			if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s), NULL)))
-				return_0;
-			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_metale(seg, s)))
+
+			if (seg->meta_areas && seg_metalv(seg, s)) {
+				if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s), NULL)))
+					return_0;
+				if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_metale(seg, s)))
+					return_0;
+			} else if (!dm_tree_node_add_null_area(node, 0))
 				return_0;
 
 			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s), NULL)))
@@ -2709,7 +2713,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		    !_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
 					  laopts, NULL))
 			return_0;
-		if (seg_is_raid(seg) &&
+		if (seg_is_raid(seg) && seg->meta_areas && seg_metalv(seg, s) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
 					  laopts, NULL))
 			return_0;
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index c0af3fa..a762c74 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -621,6 +621,7 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 			     (s == seg->area_count - 1) ? "" : ",");
 			break;
 		case AREA_LV:
+			/* FIXME This helper code should be target-independent! Check for metadata LV property. */
 			if (!(seg->status & RAID)) {
 				outf(f, "\"%s\", %u%s",
 				     seg_lv(seg, s)->name,
@@ -630,15 +631,19 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 			}
 
 			/* RAID devices are laid-out in metadata/data pairs */
+			/* FIXME Validation should be elsewhere, not here! */
 			if (!lv_is_raid_image(seg_lv(seg, s)) ||
-			    !lv_is_raid_metadata(seg_metalv(seg, s))) {
+			    (seg->meta_areas && seg_metalv(seg, s) && !lv_is_raid_metadata(seg_metalv(seg, s)))) {
 				log_error("RAID segment has non-RAID areas");
 				return 0;
 			}
 
-			outf(f, "\"%s\", \"%s\"%s",
-			     seg_metalv(seg, s)->name, seg_lv(seg, s)->name,
-			     (s == seg->area_count - 1) ? "" : ",");
+			if (seg->meta_areas && seg_metalv(seg,s))
+				outf(f, "\"%s\", \"%s\"%s",
+				     (seg->meta_areas && seg_metalv(seg, s)) ? seg_metalv(seg, s)->name : "",
+				     seg_lv(seg, s)->name, (s == seg->area_count - 1) ? "" : ",");
+			else
+				outf(f, "\"%s\"%s", seg_lv(seg, s)->name, (s == seg->area_count - 1) ? "" : ",");
 
 			break;
 		case AREA_UNASSIGNED:
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9bfef45..82faf42 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -114,6 +114,7 @@ enum {
 	LV_TYPE_DATA,
 	LV_TYPE_SPARE,
 	LV_TYPE_VIRTUAL,
+	LV_TYPE_RAID0,
 	LV_TYPE_RAID1,
 	LV_TYPE_RAID10,
 	LV_TYPE_RAID4,
@@ -162,6 +163,7 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_DATA] =				"data",
 	[LV_TYPE_SPARE] =				"spare",
 	[LV_TYPE_VIRTUAL] =				"virtual",
+	[LV_TYPE_RAID0] =				SEG_TYPE_NAME_RAID0,
 	[LV_TYPE_RAID1] =				SEG_TYPE_NAME_RAID1,
 	[LV_TYPE_RAID10] =				SEG_TYPE_NAME_RAID10,
 	[LV_TYPE_RAID4] =				SEG_TYPE_NAME_RAID4,
@@ -256,7 +258,10 @@ static int _lv_layout_and_role_raid(struct dm_pool *mem,
 
 	segtype = first_seg(lv)->segtype;
 
-	if (segtype_is_raid1(segtype)) {
+	if (segtype_is_raid0(segtype)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID0]))
+			goto_bad;
+	} else if (segtype_is_raid1(segtype)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID1]))
 			goto_bad;
 	} else if (segtype_is_raid10(segtype)) {
@@ -860,7 +865,7 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 		denominator += seg->area_len;
 
 		/* FIXME Generalise name of 'extents_copied' field */
-		if ((seg_is_raid(seg) || seg_is_mirrored(seg)) &&
+		if (((seg_is_raid(seg) && !seg_is_any_raid0(seg)) || seg_is_mirrored(seg)) &&
 		    (seg->area_count > 1))
 			numerator += seg->extents_copied;
 		else
@@ -3751,7 +3756,7 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 			return_0;
 
 		/* Metadata LVs for raid */
-		if (segtype_is_raid(segtype)) {
+		if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype)) {
 			if (dm_snprintf(img_name, sizeof(img_name), "%s_rmeta_%u",
 					lv->name, i) < 0)
 				goto_bad;
@@ -3787,6 +3792,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t fa, s;
 	int clear_metadata = 0;
+	uint32_t area_multiple = 1;
 
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
@@ -3797,13 +3803,14 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	 * 'stripes' and 'stripe_size' parameters meaningless.
 	 */
 	if (seg_is_raid(seg)) {
+		area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, 0);
 		stripes = 1;
 		stripe_size = 0;
 	}
 
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
-			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents,
+			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents / area_multiple,
 						   fa, stripes, stripe_size))
 				return_0;
 			fa += lv_mirror_count(seg_lv(seg, s));
@@ -3819,7 +3826,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		}
 
 		/* Extend metadata LVs only on initial creation */
-		if (seg_is_raid(seg) && !lv->le_count) {
+		if (seg_is_raid(seg) && !seg_is_raid0(seg) && !lv->le_count) {
 			if (!seg->meta_areas) {
 				log_error("No meta_areas for RAID type");
 				return 0;
@@ -3854,6 +3861,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		/*
 		 * We must clear the metadata areas upon creation.
 		 */
+		/* FIXME VG is not in a fully-consistent state here and should not be committed! */
 		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 			return_0;
 
@@ -3898,7 +3906,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		}
 	}
 
-	seg->area_len += extents;
+	seg->area_len += extents / area_multiple;
 	seg->len += extents;
 
 	if (!_setup_lv_size(lv, lv->le_count + extents))
@@ -3953,7 +3961,7 @@ int lv_extend(struct logical_volume *lv,
 		 */
 		/* FIXME Support striped metadata pool */
 		log_count = 1;
-	} else if (segtype_is_raid(segtype) && !lv->le_count)
+	} else if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype) && !lv->le_count)
 		log_count = mirrors * stripes;
 	/* FIXME log_count should be 1 for mirrors */
 
@@ -3963,7 +3971,7 @@ int lv_extend(struct logical_volume *lv,
 		return_0;
 
 	new_extents = ah->new_extents;
-	if (segtype_is_raid(segtype))
+	if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
 		new_extents -= ah->log_len * ah->area_multiple;
 
 	if (segtype_is_pool(segtype)) {
@@ -7078,7 +7086,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!activation()) {
 		if (seg_is_cache(lp) ||
 		    seg_is_mirror(lp) ||
-		    seg_is_raid(lp) ||
+		    (seg_is_raid(lp) && !seg_is_raid0(lp)) ||
 		    seg_is_thin(lp) ||
 		    lp->snapshot) {
 			/*
@@ -7256,7 +7264,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		/* FIXME Eventually support raid/mirrors with -m */
 		if (!(create_segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
 			return_0;
-	} else if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
+	} else if (seg_is_mirrored(lp) || (seg_is_raid(lp) && !seg_is_any_raid0(lp))) {
 		if (is_change_activating(lp->activate) && (lp->activate != CHANGE_AEY) &&
 		    vg_is_clustered(vg) && seg_is_mirrored(lp) && !seg_is_raid(lp) &&
 		    !cluster_mirror_is_available(vg->cmd)) {
@@ -7389,7 +7397,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!archive(vg))
 		return_NULL;
 
-
 	if (pool_lv && segtype_is_thin_volume(create_segtype)) {
 		/* Ensure all stacked messages are submitted */
 		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
@@ -7444,7 +7451,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			stack;
 			goto revert_new_lv;
 		}
-	} else if (lv_is_raid(lv)) {
+	} else if (lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv))) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
 	} else if (lv_is_thin_pool(lv)) {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 67fb11c..3fc4266 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -47,6 +47,7 @@ struct dev_manager;
 #define SEG_ONLY_EXCLUSIVE	0x0000000000010000ULL /* In cluster only exlusive activation */
 #define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000ULL
 
+#define SEG_RAID0		0x0000000000040000ULL
 #define SEG_RAID1		0x0000000000100000ULL
 #define SEG_RAID10		0x0000000000200000ULL
 #define SEG_RAID4		0x0000000000400000ULL
@@ -100,6 +101,8 @@ struct dev_manager;
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
+#define segtype_is_raid0(segtype)	((segtype)->flags & SEG_RAID0 ? 1 : 0)
+#define segtype_is_any_raid0(segtype)	((segtype)->flags & SEG_RAID0 ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_raid1(segtype)	((segtype)->flags & SEG_RAID1 ? 1 : 0)
 #define segtype_is_raid4(segtype)	((segtype)->flags & SEG_RAID4 ? 1 : 0)
@@ -130,6 +133,8 @@ struct dev_manager;
 #define seg_is_mirror(seg)	segtype_is_mirror((seg)->segtype)
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
 #define seg_is_pool(seg)	segtype_is_pool((seg)->segtype)
+#define seg_is_raid0(seg)	segtype_is_raid0((seg)->segtype)
+#define seg_is_any_raid0(seg)	segtype_is_any_raid0((seg)->segtype)
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
 #define seg_is_raid1(seg)	segtype_is_raid1((seg)->segtype)
 #define seg_is_raid4(seg)	segtype_is_raid4((seg)->segtype)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 28fd45b..4987f91 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -33,8 +33,10 @@ static void _raid_display(const struct lv_segment *seg)
 		display_stripe(seg, s, "    ");
 	}
 
-	for (s = 0; s < seg->area_count; ++s)
-		log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
+	if (seg->meta_areas) {
+		for (s = 0; s < seg->area_count; ++s)
+			log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
+	}
 
 	log_print(" ");
 }
@@ -42,11 +44,26 @@ static void _raid_display(const struct lv_segment *seg)
 static int _raid_text_import_area_count(const struct dm_config_node *sn,
 					uint32_t *area_count)
 {
-	if (!dm_config_get_uint32(sn, "device_count", area_count)) {
-		log_error("Couldn't read 'device_count' for "
+	uint32_t stripe_count = 0, device_count = 0;
+	int stripe_count_found, device_count_found;
+
+	device_count_found = dm_config_get_uint32(sn, "device_count", &device_count);
+	stripe_count_found = dm_config_get_uint32(sn, "stripe_count", &stripe_count);
+
+	if (!device_count_found && !stripe_count_found) {
+		log_error("Couldn't read 'device_count' or 'stripe_count' for "
+			  "segment '%s'.", dm_config_parent_name(sn));
+		return 0;
+	}
+
+	if (device_count_found && stripe_count_found) {
+		log_error("Only one of 'device_count' and 'stripe_count' allowed for "
 			  "segment '%s'.", dm_config_parent_name(sn));
 		return 0;
 	}
+
+	*area_count = stripe_count + device_count;
+
 	return 1;
 }
 
@@ -69,22 +86,25 @@ static int _raid_text_import_areas(struct lv_segment *seg,
 			return 0;
 		}
 
-		if (!cv->next) {
-			log_error("Missing data device in areas array for segment %s.", seg_name);
-			return 0;
+		/* Metadata device comes first. */
+		if (!seg_is_raid0(seg)) {
+			if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
+				log_error("Couldn't find volume '%s' for segment '%s'.",
+					  cv->v.str ? : "NULL", seg_name);
+				return 0;
+			}
+
+			if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_META))
+				return_0;
+			cv = cv->next;
 		}
 
-		/* Metadata device comes first */
-		if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
-			log_error("Couldn't find volume '%s' for segment '%s'.",
-				  cv->v.str ? : "NULL", seg_name);
+		if (!cv) {
+			log_error("Missing data device in areas array for segment %s.", seg_name);
 			return 0;
 		}
-		if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_META))
-			return_0;
 
 		/* Data device comes second */
-		cv = cv->next;
 		if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
 			log_error("Couldn't find volume '%s' for segment '%s'.",
 				  cv->v.str ? : "NULL", seg_name);
@@ -133,7 +153,7 @@ static int _raid_text_import(struct lv_segment *seg,
 		}
 	}
 
-	if (!dm_config_get_list(sn, "raids", &cv)) {
+	if (!dm_config_get_list(sn, seg_is_any_raid0(seg) ? "raid0_lvs" : "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
 			  dm_config_parent_name(sn), seg->lv->name);
@@ -145,18 +165,31 @@ static int _raid_text_import(struct lv_segment *seg,
 		return 0;
 	}
 
+	if (seg_is_any_raid0(seg))
+		seg->area_len /= seg->area_count;
 	seg->status |= RAID;
 
 	return 1;
 }
 
-static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
+static int _raid_text_export_raid0(const struct lv_segment *seg, struct formatter *f)
+{
+	outf(f, "stripe_count = %u", seg->area_count);
+
+	if (seg->stripe_size)
+		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
+
+	return out_areas(f, seg, "raid0_lv");
+}
+
+static int _raid_text_export_raid(const struct lv_segment *seg, struct formatter *f)
 {
 	outf(f, "device_count = %u", seg->area_count);
-	if (seg->region_size)
-		outf(f, "region_size = %" PRIu32, seg->region_size);
+
 	if (seg->stripe_size)
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
+	if (seg->region_size)
+		outf(f, "region_size = %" PRIu32, seg->region_size);
 	if (seg->writebehind)
 		outf(f, "writebehind = %" PRIu32, seg->writebehind);
 	if (seg->min_recovery_rate)
@@ -167,6 +200,14 @@ static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
 	return out_areas(f, seg, "raid");
 }
 
+static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	if (seg_is_any_raid0(seg))
+		return _raid_text_export_raid0(seg, f);
+
+	return _raid_text_export_raid(seg, f);
+}
+
 static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 				 struct dm_pool *mem __attribute__((unused)),
 				 struct cmd_context *cmd __attribute__((unused)),
@@ -181,6 +222,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	uint64_t rebuilds = 0;
 	uint64_t writemostly = 0;
 	struct dm_tree_node_raid_params params;
+	int raid0 = seg_is_any_raid0(seg);
 
 	memset(&params, 0, sizeof(params));
 
@@ -200,24 +242,32 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		return 0;
 	}
 
-	if (!seg->region_size) {
-		log_error("Missing region size for mirror segment.");
-		return 0;
-	}
+	if (!raid0) {
+		if (!seg->region_size) {
+			log_error("Missing region size for mirror segment.");
+			return 0;
+		}
 
-	for (s = 0; s < seg->area_count; s++)
-		if (seg_lv(seg, s)->status & LV_REBUILD)
-			rebuilds |= 1ULL << s;
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_lv(seg, s)->status & LV_REBUILD)
+				rebuilds |= 1ULL << s;
 
-	for (s = 0; s < seg->area_count; s++)
-		if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
-			writemostly |= 1ULL << s;
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
+				writemostly |= 1ULL << s;
 
-	if (mirror_in_sync())
-		flags = DM_NOSYNC;
+		if (mirror_in_sync())
+			flags = DM_NOSYNC;
+	}
 
 	params.raid_type = lvseg_name(seg);
-	if (seg->segtype->parity_devs) {
+	params.stripe_size = seg->stripe_size;
+	params.flags = flags;
+
+	if (raid0) {
+		params.mirrors = 1;
+		params.stripes = seg->area_count;
+	} else if (seg->segtype->parity_devs) {
 		/* RAID 4/5/6 */
 		params.mirrors = 1;
 		params.stripes = seg->area_count - seg->segtype->parity_devs;
@@ -231,13 +281,14 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		params.stripes = 1;
 		params.writebehind = seg->writebehind;
 	}
-	params.region_size = seg->region_size;
-	params.stripe_size = seg->stripe_size;
-	params.rebuilds = rebuilds;
-	params.writemostly = writemostly;
-	params.min_recovery_rate = seg->min_recovery_rate;
-	params.max_recovery_rate = seg->max_recovery_rate;
-	params.flags = flags;
+
+	if (!raid0) {
+		params.region_size = seg->region_size;
+		params.rebuilds = rebuilds;
+		params.writemostly = writemostly;
+		params.min_recovery_rate = seg->min_recovery_rate;
+		params.max_recovery_rate = seg->max_recovery_rate;
+	}
 
 	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
 		return_0;
@@ -418,6 +469,7 @@ static const struct raid_type {
 	unsigned parity;
 	uint64_t extra_flags;
 } _raid_types[] = {
+	{ SEG_TYPE_NAME_RAID0,    0, SEG_RAID0 | SEG_AREAS_STRIPED },
 	{ SEG_TYPE_NAME_RAID1,    0, SEG_RAID1 | SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID10,   0, SEG_RAID10 | SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID4,    1, SEG_RAID4 },
diff --git a/lib/report/report.c b/lib/report/report.c
index 92eb64c..8fa9daf 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2845,7 +2845,7 @@ static int _copypercent_disp(struct dm_report *rh,
 	struct lv_status_cache *status;
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
-	if (((lv_is_raid(lv) && lv_raid_percent(lv, &percent)) ||
+	if (((lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv)) && lv_raid_percent(lv, &percent)) ||
 	     (lv_is_mirror(lv) && lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
 	    (percent != DM_PERCENT_INVALID)) {
 		percent = copy_percent(lv);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6f18ae2..dd5ee9e 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -42,6 +42,7 @@ enum {
 	SEG_ZERO,
 	SEG_THIN_POOL,
 	SEG_THIN,
+	SEG_RAID0,
 	SEG_RAID1,
 	SEG_RAID10,
 	SEG_RAID4,
@@ -74,6 +75,7 @@ static const struct {
 	{ SEG_ZERO, "zero"},
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
+	{ SEG_RAID0, "raid0"},
 	{ SEG_RAID1, "raid1"},
 	{ SEG_RAID10, "raid10"},
 	{ SEG_RAID4, "raid4"},
@@ -2131,6 +2133,7 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 					EMIT_PARAMS(*pos, "%s", synctype);
 			}
 			break;
+		case SEG_RAID0:
 		case SEG_RAID1:
 		case SEG_RAID10:
 		case SEG_RAID4:
@@ -2572,6 +2575,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?
 			    seg->iv_offset : *seg_start);
 		break;
+	case SEG_RAID0:
 	case SEG_RAID1:
 	case SEG_RAID10:
 	case SEG_RAID4:
@@ -3848,6 +3852,7 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 
 	switch (seg->type) {
+	case SEG_RAID0:
 	case SEG_RAID1:
 	case SEG_RAID4:
 	case SEG_RAID5_LA:
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index e008b58..8614cb1 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -606,7 +606,14 @@ would use 3 devices for striped logical volumes,
 RAID 4/5/6 will stripe across all PVs in the volume group or
 all of the PVs specified if the \fB\-i\fP
 argument is omitted.
-.
+Two implementations of basic striping are available in the kernel.
+The original device-mapper implementation is the default and should
+normally be used.  The alternative implementation using MD, available
+since version 1.7 of the RAID device-mapper kernel target (kernel
+version 4.2) is provided to facilitate the development of new RAID
+features.  It may be accessed with \fB--type raid0\fP, but is best
+avoided at present because of assorted restrictions on resizing and converting
+such devices.
 .HP
 .BR \-I | \-\-stripesize
 .IR StripeSize
@@ -649,6 +656,7 @@ Supported types are:
 .BR error ,
 .BR linear ,
 .BR mirror,
+.BR raid0 ,
 .BR raid1 ,
 .BR raid4 ,
 .BR raid5_la ,
@@ -683,7 +691,7 @@ is selected from combination of options:
 (snapshot or thin),
 .BR \-i | \-\-stripes
 (striped).
-Default segment type is \fBlinear\fP.
+The default segment type is \fBlinear\fP.
 .
 .HP
 .BR \-V | \-\-virtualsize
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 9714789..8ddecae 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -987,6 +987,12 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			return 0;
 		}
 
+		if (segtype_is_any_raid0(lp->segtype) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
+			log_error("RAID module does not support RAID0.");
+			return 0;
+		}
+
 		if (segtype_is_raid10(lp->segtype) && !(lp->target_attr & RAID_FEATURE_RAID10)) {
 			log_error("RAID module does not support RAID10.");
 			return 0;
@@ -1209,18 +1215,23 @@ static int _check_raid_parameters(struct volume_group *vg,
 	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
 	struct cmd_context *cmd = vg->cmd;
 
-	/*
-	 * If number of devices was not supplied, we can infer from
-	 * the PVs given.
-	 */
-	if (!seg_is_mirrored(lp)) {
+	if (!seg_is_mirrored(lp) && !lp->stripe_size)
+		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+
+	if (seg_is_any_raid0(lp)) {
+		if (lp->stripes < 2) {
+			log_error("Segment type 'raid0' requires 2 or more stripes.");
+			return 0;
+		}
+	} else if (!seg_is_mirrored(lp)) {
+		/*
+		 * If number of devices was not supplied, we can infer from
+		 * the PVs given.
+		 */
 		if (!arg_count(cmd, stripes_ARG) &&
 		    (devs > 2 * lp->segtype->parity_devs))
 			lp->stripes = devs - lp->segtype->parity_devs;
 
-		if (!lp->stripe_size)
-			lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
-
 		if (lp->stripes <= lp->segtype->parity_devs) {
 			log_error("Number of stripes must be at least %d for %s",
 				  lp->segtype->parity_devs + 1,


