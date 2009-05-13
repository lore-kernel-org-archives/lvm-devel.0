From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:24:42 +0200
Subject: [PATCH 7/9] Merge lv_is_displayable and lv_is_visible.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <18669858e9abb950dc6438a08bc6eda8ae9d2215.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Displayable and visible is the same thing.

volumes_count(vg) now always returns number of LVs from
user perspective.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c          |    2 +-
 lib/display/display.c            |    4 +-
 lib/format_text/export.c         |    4 +-
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    7 +---
 lib/metadata/metadata.c          |   59 ++++++++++++++++++++++---------------
 lib/metadata/metadata.h          |    5 ---
 lib/metadata/snapshot_manip.c    |    8 -----
 lib/report/report.c              |    4 +-
 tools/lvchange.c                 |    2 +-
 tools/lvdisplay.c                |    2 +-
 tools/lvscan.c                   |    2 +-
 tools/reporter.c                 |    4 +-
 13 files changed, 50 insertions(+), 55 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index e38c4d8..34f979a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -673,7 +673,7 @@ int lvs_in_vg_opened(const struct volume_group *vg)
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_displayable(lvl->lv))
+		if (lv_is_visible(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 	}
 
diff --git a/lib/display/display.c b/lib/display/display.c
index c1ae8db..e0e1369 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -606,7 +606,7 @@ void vgdisplay_full(const struct volume_group *vg)
 	}
 
 	log_print("MAX LV                %u", vg->max_lv);
-	log_print("Cur LV                %u", displayable_lvs_in_vg(vg));
+	log_print("Cur LV                %u", volumes_count(vg));
 	log_print("Open LV               %u", lvs_in_vg_opened(vg));
 /****** FIXME Max LV Size
       log_print ( "MAX LV Size           %s",
@@ -681,7 +681,7 @@ void vgdisplay_colons(const struct volume_group *vg)
 		vg->status,
 		/* internal volume group number; obsolete */
 		vg->max_lv,
-		displayable_lvs_in_vg(vg),
+		volumes_count(vg),
 		lvs_in_vg_opened(vg),
 		/* FIXME: maximum logical volume size */
 		vg->max_pv,
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 604138c..ce6676e 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -592,14 +592,14 @@ static int _print_lvs(struct formatter *f, struct volume_group *vg)
 	 * Write visible LVs first
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!(lv_is_displayable(lvl->lv)))
+		if (!(lv_is_visible(lvl->lv)))
 			continue;
 		if (!_print_lv(f, lvl->lv))
 			return_0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if ((lv_is_displayable(lvl->lv)))
+		if ((lv_is_visible(lvl->lv)))
 			continue;
 		if (!_print_lv(f, lvl->lv))
 			return_0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 068d745..80c1197 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1733,7 +1733,7 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
-	if (!lv_is_displayable(lv)) {
+	if (!lv_is_visible(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 64b30f7..680be10 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -238,18 +238,16 @@ struct volume_group {
 	/*
 	 * logical volumes
 	 * The following relationship should always hold:
-	 * dm_list_size(lvs) = lv_count + 2 * snapshot_count
+	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other unvisible LVs
 	 *
 	 * Snapshots consist of 2 instances of "struct logical_volume":
 	 * - cow (lv_name is visible to the user)
 	 * - snapshot (lv_name is 'snapshotN')
-	 * Neither of these instances is reflected in lv_count.
 	 *
 	 * Mirrors consist of multiple instances of "struct logical_volume":
 	 * - one for the mirror log
 	 * - one for each mirror leg
 	 * - one for the user-visible mirror LV
-	 * all of the instances are reflected in lv_count.
 	 */
 	struct dm_list lvs;
 
@@ -536,10 +534,9 @@ struct lv_segment *first_seg(const struct logical_volume *lv);
 int lv_is_origin(const struct logical_volume *lv);
 int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
-int lv_is_visible(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
-int lv_is_displayable(const struct logical_volume *lv);
+int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 97b9ebb..82ee6cb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -376,7 +376,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return 0;
 
-	lv_count = displayable_lvs_in_vg(vg);
+	lv_count = volumes_count(vg);
 
 	if (lv_count) {
 		if ((force == PROMPT) &&
@@ -391,8 +391,8 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 			return 0;
 	}
 
-	lv_count = displayable_lvs_in_vg(vg);
-	
+	lv_count = volumes_count(vg);
+
 	if (lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
 			  "logical volume(s)", vg_name, lv_count);
@@ -1140,18 +1140,6 @@ int vg_remove(struct volume_group *vg)
 	return 1;
 }
 
-unsigned displayable_lvs_in_vg(const struct volume_group *vg)
-{
-	struct lv_list *lvl;
-	unsigned lv_count = 0;
-
-	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_displayable(lvl->lv))
-			lv_count++;
-
-	return lv_count;
-}
-
 unsigned snapshot_count(const struct volume_group *vg)
 {
 	struct lv_list *lvl;
@@ -1170,11 +1158,8 @@ unsigned volumes_count(const struct volume_group *vg)
 	unsigned lv_count = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_cow(lvl->lv))
-			continue;
-		if (lvl->lv->status & SNAPSHOT)
-			continue;
-		lv_count++;
+		if (lv_is_visible(lvl->lv))
+			lv_count++;
 	}
 
 	return lv_count;
@@ -1469,12 +1454,38 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
-	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    volumes_count(vg) + 2 * snapshot_count(vg)) {
+	/*
+	 * Count all non-snapshot unvisible LVs
+	 */
+	lv_count = 0;
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->status & VISIBLE_LV)
+			continue;
+
+		/* snapshots */
+		if (lv_is_cow(lvl->lv) || lv_is_origin(lvl->lv))
+			continue;
+
+		/* count other non-snapshot invisible volumes */
+		lv_count++;
+
+		/*
+		 *  FIXME: add check for unreferenced unvisible LVs
+		 *   - snapshot cow & origin
+		 *   - mirror log & images
+		 *   - mirror conversion volumes (_mimagetmp*)
+		 */
+	}
+
+	/*
+	 * all volumes = visible LVs + snapshot_cows + unvisible LVs
+	 */
+	if (((uint32_t) dm_list_size(&vg->lvs)) !=
+	    volumes_count(vg) + snapshot_count(vg) + lv_count) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
+			  PRIu32 ") + #snapshots (%" PRIu32 ") + #invisible LVs %u in VG %s",
 			  dm_list_size(&vg->lvs), volumes_count(vg),
-			  snapshot_count(vg), vg->name);
+			  snapshot_count(vg), lv_count, vg->name);
 		r = 0;
 	}
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index aca57f4..b2294bb 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -340,11 +340,6 @@ int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segm
 struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
 /*
- * Count LVs that are visible from user's perspective.
- */
-unsigned displayable_lvs_in_vg(const struct volume_group *vg);
-
-/*
  * Count snapshot LVs.
  */
 unsigned snapshot_count(const struct volume_group *vg);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index ff608c3..bf694f7 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -43,14 +43,6 @@ int lv_is_visible(const struct logical_volume *lv)
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }
 
-int lv_is_displayable(const struct logical_volume *lv)
-{
-	if (lv->status & SNAPSHOT)
-		return 0;
-
-	return (lv->status & VISIBLE_LV) || lv_is_cow(lv) ? 1 : 0;
-}
-
 int lv_is_virtual_origin(const struct logical_volume *lv)
 {
 	return (lv->status & VIRTUAL_ORIGIN) ? 1 : 0;
diff --git a/lib/report/report.c b/lib/report/report.c
index d8f7961..86c6743 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -497,7 +497,7 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_displayable(lv)) {
+	if (lv_is_visible(lv)) {
 		repstr = lv->name;
 		return dm_report_field_string(rh, field, (const char **) &repstr);
 	}
@@ -974,7 +974,7 @@ static int _lvcount_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count;
 
-	count = displayable_lvs_in_vg(vg);	
+	count = volumes_count(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 2696a95..466fe29 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -584,7 +584,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (!(lv_is_displayable(lv))) {
+	if (!(lv_is_visible(lv))) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 5263e0d..16e7052 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -18,7 +18,7 @@
 static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	if (arg_count(cmd, colon_ARG))
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 1186b3b..a286fe1 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -27,7 +27,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	const char *active_str, *snapshot_str;
 
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
diff --git a/tools/reporter.c b/tools/reporter.c
index 0a9de09..28393f8 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -36,7 +36,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
@@ -113,7 +113,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
-- 
1.6.2.4


