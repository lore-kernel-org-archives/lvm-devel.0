From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 16 Sep 2014 15:35:12 +0000 (UTC)
Subject: dev-mcsontos-clvmd-stack-overflow - mirrors: Fix checks for mirror/raid/pvmove LVs.
Message-ID: <20140916153512.3F3D260735@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=979be63f2537373b49e47aa3e8ce3f9bf2a4279f
Commit:        979be63f2537373b49e47aa3e8ce3f9bf2a4279f
Parent:        829e5a40373a2ef1721dc9210350c86c4b9d70f7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 16 00:13:46 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 16 00:13:46 2014 +0100

mirrors: Fix checks for mirror/raid/pvmove LVs.

Try to enforce consistent macro usage along these lines:

lv_is_mirror - mirror that uses the original dm-raid1 implementation
               (segment type "mirror")
lv_is_mirror_type - also includes internal mirror image and log LVs

lv_is_raid - raid volume that uses the new dm-raid implementation
             (segment type "raid")
lv_is_raid_type - also includes internal raid image / log / metadata LVs

lv_is_mirrored - LV is mirrored using either kernel implementation
                 (excludes non-mirror modes like raid5 etc.)

lv_is_pvmove - internal pvmove volume
---
 WHATS_NEW                        |    3 +++
 lib/activate/dev_manager.c       |    2 +-
 lib/format_text/flags.c          |    1 +
 lib/format_text/import_vsn1.c    |    3 +++
 lib/metadata/lv.c                |    4 ++--
 lib/metadata/lv_manip.c          |   23 +++++++++++++++--------
 lib/metadata/metadata-exported.h |    6 ++++--
 lib/metadata/mirror.c            |   10 +++++++---
 lib/metadata/raid_manip.c        |    1 +
 lib/metadata/segtype.h           |    3 +++
 lib/mirror/mirrored.c            |    2 +-
 lib/report/report.c              |    3 +--
 tools/lvchange.c                 |    2 +-
 tools/pvmove.c                   |    2 +-
 tools/vgreduce.c                 |    2 +-
 15 files changed, 45 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3c02440..70d8a9a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.112 - 
 =====================================
+  Review internal checks for mirror/raid/pvmove volumes.
+  Track mirror segment type with separate MIRROR flag.
+  Fix cmirror endian conversions.
   Introduce lv_is_pvmove/locked/converting/merging macros.
   Avoid leaving linear logical volume when thin pool creation fails.
   Demote an error to a warning when devices known to lvmetad are filtered out.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c5581eb..4ee5a25 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2917,7 +2917,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if (!dm->flush_required && !seg_is_raid(first_seg(lv)) && lv_is_mirrored(lv) && !lv_is_pvmove(lv))
+		if (!dm->flush_required && lv_is_mirror(lv) && !lv_is_pvmove(lv))
 			dm_tree_use_no_flush_suspend(root);
 		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index bc48952..55681d4 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -67,6 +67,7 @@ static const struct flag _lv_flags[] = {
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
+	{MIRROR, NULL, 0},
 	{MIRROR_IMAGE, NULL, 0},
 	{MIRROR_LOG, NULL, 0},
 	{MIRRORED, NULL, 0},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 9ddf99e..174b3bf 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -386,6 +386,9 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 	 */
 	_insert_segment(lv, seg);
 
+	if (seg_is_mirror(seg))
+		lv->status |= MIRROR;
+
 	if (seg_is_mirrored(seg))
 		lv->status |= MIRRORED;
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index a8ad2d2..3ebb14d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -361,7 +361,7 @@ char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		if (seg->status & PVMOVE) {
 			if (seg_type(seg, 0) == AREA_LV) { /* atomic pvmove */
 				mimage0_lv = seg_lv(seg, 0);
-				if (!lv_is_mirrored(mimage0_lv)) {
+				if (!lv_is_mirror_image(mimage0_lv)) {
 					log_error(INTERNAL_ERROR
 						  "Bad pvmove structure");
 					return NULL;
@@ -648,7 +648,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[0] = 'C';
 	else if (lv_is_raid(lv))
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';
-	else if (lv_is_mirrored(lv))
+	else if (lv_is_mirror(lv))
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
 	else if (lv_is_thin_volume(lv))
 		repstr[0] = lv_is_merging_origin(lv) ?
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6d80dfb..58bc79b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -231,6 +231,10 @@ static int _lv_layout_and_role_raid(struct dm_pool *mem,
 		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_RAID]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
+	} else if (lv_is_pvmove(lv)) {
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_PVMOVE]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
+			goto_bad;
 	} else
 		top_level = 1;
 
@@ -464,7 +468,7 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 	}
 
 	/* Mirrors and related */
-	if ((lv_is_mirror_type(lv) || lv_is_pvmove(lv)) && !lv_is_raid(lv) &&
+	if ((lv_is_mirror_type(lv) || lv_is_pvmove(lv)) &&
 	    !_lv_layout_and_role_mirror(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
@@ -985,6 +989,12 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	if (log_lv && !attach_mirror_log(seg, log_lv))
 		return_NULL;
 
+	if (segtype_is_mirror(segtype))
+		lv->status |= MIRROR;
+
+	if (segtype_is_mirrored(segtype))
+		lv->status |= MIRRORED;
+
 	return seg;
 }
 
@@ -1347,9 +1357,10 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 	 * an error segment, we should also clear any flags
 	 * that suggest it is anything other than "error".
 	 */
-	lv->status &= ~(MIRRORED|PVMOVE|LOCKED);
+	/* FIXME Check for other flags that need removing */
+	lv->status &= ~(MIRROR|MIRRORED|PVMOVE|LOCKED);
 
-	/* FIXME: Should we bug if we find a log_lv attached? */
+	/* FIXME Check for any attached LVs that will become orphans e.g. mirror logs */
 
 	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, "error"), NULL))
 		return_0;
@@ -1858,9 +1869,6 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents *lv->vg->extent_size;
 
-	if (segtype_is_mirrored(segtype))
-		lv->status |= MIRRORED;
-
 	return 1;
 }
 
@@ -6723,8 +6731,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 
-			if (lv_is_mirror_type(org) &&
-			    !seg_is_raid(first_seg(org))) {
+			if (lv_is_mirror_type(org)) {
 				log_warn("WARNING: Snapshots of mirrors can deadlock under rare device failures.");
 				log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0026ba9..01b04ff 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -67,6 +67,7 @@
 #define LOCKED			UINT64_C(0x0000000000004000)	/* LV */
 #define MIRRORED		UINT64_C(0x0000000000008000)	/* LV - internal use only */
 //#define VIRTUAL		UINT64_C(0x0000000000010000)	/* LV - internal use only */
+#define MIRROR			UINT64_C(0x0002000000000000)    /* LV - Internal use only */
 #define MIRROR_LOG		UINT64_C(0x0000000000020000)	/* LV - Internal use only */
 #define MIRROR_IMAGE		UINT64_C(0x0000000000040000)	/* LV - Internal use only */
 
@@ -115,7 +116,7 @@
 #define CACHE_POOL_METADATA	UINT64_C(0x0000800000000000)    /* LV - Internal use only */
 #define CACHE			UINT64_C(0x0001000000000000)    /* LV - Internal use only */
 
-/* Next unused flag:		UINT64_C(0x0002000000000000)    */
+/* Next unused flag:		UINT64_C(0x0004000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -181,7 +182,8 @@
 
 #define lv_is_mirror_image(lv)	(((lv)->status & MIRROR_IMAGE) ? 1 : 0)
 #define lv_is_mirror_log(lv)	(((lv)->status & MIRROR_LOG) ? 1 : 0)
-#define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED)) ? 1 : 0)
+#define lv_is_mirror(lv)	(((lv)->status & MIRROR) ? 1 : 0)
+#define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR | MIRROR_LOG | MIRROR_IMAGE)) ? 1 : 0)
 
 #define lv_is_pvmove(lv)	(((lv)->status & PVMOVE) ? 1 : 0)
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4505eb9..0fc9314 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -742,6 +742,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, sub_lv))
 			return_0;
+		lv->status &= ~MIRROR;
 		lv->status &= ~MIRRORED;
 		lv->status &= ~LV_NOTSYNCED;
 	}
@@ -941,6 +942,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
                  * mirror. Fix up the flags if we only have one image left.
                  */
                 if (lv_mirror_count(lv) == 1) {
+                    lv->status &= ~MIRROR;
                     lv->status &= ~MIRRORED;
                     lv->status &= ~LV_NOTSYNCED;
                 }
@@ -957,6 +959,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		/* All mirror images are gone.
 		 * It can happen for vgreduce --removemissing. */
 		detached_log_lv = detach_mirror_log(mirrored_seg);
+		lv->status &= ~MIRROR;
 		lv->status &= ~MIRRORED;
 		lv->status &= ~LV_NOTSYNCED;
 		if (!replace_lv_with_error_segment(lv))
@@ -1502,9 +1505,10 @@ const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr)
 	dm_list_iterate_items(seg, &lv_mirr->segments) {
 		if (!seg_is_mirrored(seg))
 			continue;
-		if (seg_type(seg, 0) != AREA_PV)
-			continue;
-		return dev_name(seg_dev(seg, 0));
+		if (seg_type(seg, 0) == AREA_PV)
+			return dev_name(seg_dev(seg, 0));
+		if (seg_type(seg, 0) == AREA_LV)
+			return dev_name(seg_dev(first_seg(seg_lv(seg, 0)), 0));
 	}
 
 	return NULL;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c9ac405..f494f11 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1403,6 +1403,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 
 	log_debug_metadata("Setting new segtype for %s", lv->name);
 	seg->segtype = new_segtype;
+	lv->status &= ~MIRROR;
 	lv->status &= ~MIRRORED;
 	lv->status |= RAID;
 	seg->status |= RAID;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 080cf4e..e0c46df 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -43,11 +43,13 @@ struct dev_manager;
 #define SEG_THIN_VOLUME		0x00001000U
 #define SEG_CACHE		0x00002000U
 #define SEG_CACHE_POOL		0x00004000U
+#define SEG_MIRROR		0x00008000U
 #define SEG_UNKNOWN		0x80000000U
 
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -59,6 +61,7 @@ struct dev_manager;
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
+#define seg_is_mirror(seg)	segtype_is_mirror((seg)->segtype)
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
 #define seg_is_pool(seg)	segtype_is_pool((seg)->segtype)
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 1ab06ce..74a8e37 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -628,7 +628,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 	segtype->ops = &_mirrored_ops;
 	segtype->name = "mirror";
 	segtype->private = NULL;
-	segtype->flags = SEG_AREAS_MIRRORED;
+	segtype->flags = SEG_MIRROR | SEG_AREAS_MIRRORED;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
diff --git a/lib/report/report.c b/lib/report/report.c
index 24bc437..c34aa5e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1042,8 +1042,7 @@ static int _copypercent_disp(struct dm_report *rh,
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (((lv_is_raid(lv) && lv_raid_percent(lv, &percent)) ||
-	     ((lv_is_pvmove(lv) || lv_is_mirrored(lv)) &&
-	      lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
+	     (lv_is_mirror(lv) && lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
 	    (percent != DM_PERCENT_INVALID)) {
 		percent = copy_percent(lv);
 		return dm_report_field_percent(rh, field, &percent);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3ac5165..e0e3b03 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -287,7 +287,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_init(&device_list);
 
-	if (!lv_is_mirrored(lv) && !seg_is_raid(seg)) {
+	if (!seg_is_mirror(seg) && !seg_is_raid(seg)) {
 		log_error("Unable to resync %s.  It is not RAID or mirrored.",
 			  lv->name);
 		return 0;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 5b458b1..a9d750d 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -325,7 +325,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		 *
 		 * Allow clustered mirror, but not raid mirror.
 		 */
-		if (vg_is_clustered(lv->vg) && (!lv_is_mirror_type(lv) || lv_is_raid(lv)))
+		if (vg_is_clustered(lv->vg) && !lv_is_mirror_type(lv))
 			continue;
 
 		if (!lv_is_on_pvs(lv, source_pvl))
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 62162af..970f61c 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -95,7 +95,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 				goto restart;
 			}
 
-			if (lv_is_mirrored(lv)) {
+			if (lv_is_mirror(lv)) {
 				if (!mirror_remove_missing(cmd, lv, 1))
 					return_0;
 				goto restart;


