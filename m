From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 May 2009 16:43:03 +0200
Subject: [PATCH 6/7] Merge lv_is_displayable and lv_is_visible.
In-Reply-To: <cover.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
Message-ID: <121713e1267ebb0dd4123c8fa4774b611eea576a.1241620083.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Displayable and visible is the same thing, stored
in lv_count volume group attribute.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c          |    2 +-
 lib/display/display.c            |    4 ++--
 lib/format_text/export.c         |    4 ++--
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    3 +--
 lib/metadata/metadata.c          |   25 ++++---------------------
 lib/metadata/metadata.h          |    5 -----
 lib/metadata/snapshot_manip.c    |    8 --------
 lib/report/columns.h             |    2 +-
 lib/report/report.c              |   14 +-------------
 tools/lvchange.c                 |    2 +-
 tools/lvdisplay.c                |    2 +-
 tools/lvscan.c                   |    2 +-
 tools/reporter.c                 |    4 ++--
 14 files changed, 18 insertions(+), 61 deletions(-)

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
index c1ae8db..042d760 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -606,7 +606,7 @@ void vgdisplay_full(const struct volume_group *vg)
 	}
 
 	log_print("MAX LV                %u", vg->max_lv);
-	log_print("Cur LV                %u", displayable_lvs_in_vg(vg));
+	log_print("Cur LV                %u", vg->lv_count);
 	log_print("Open LV               %u", lvs_in_vg_opened(vg));
 /****** FIXME Max LV Size
       log_print ( "MAX LV Size           %s",
@@ -681,7 +681,7 @@ void vgdisplay_colons(const struct volume_group *vg)
 		vg->status,
 		/* internal volume group number; obsolete */
 		vg->max_lv,
-		displayable_lvs_in_vg(vg),
+		vg->lv_count,
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
index 705fa2b..fa83614 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1732,7 +1732,7 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
-	if (!lv_is_displayable(lv)) {
+	if (!lv_is_visible(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ac5de87..ffb1510 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -535,10 +535,9 @@ struct lv_segment *first_seg(const struct logical_volume *lv);
 int lv_is_origin(const struct logical_volume *lv);
 int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
-int lv_is_visible(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
-int lv_is_displayable(const struct logical_volume *lv);
+int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 745083b..ceea447 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -362,7 +362,6 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	unsigned lv_count;
 	int ret = 1;
 
 	if (!vg || !consistent || vg_missing_pv_count(vg)) {
@@ -376,14 +375,12 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return 0;
 
-	lv_count = displayable_lvs_in_vg(vg);
-
-	if (lv_count) {
+	if (vg->lv_count) {
 		if ((force == PROMPT) &&
 		    (yes_no_prompt("Do you really want to remove volume "
 				   "group \"%s\" containing %u "
 				   "logical volumes? [y/n]: ",
-				   vg_name, lv_count) == 'n')) {
+				   vg_name, vg->lv_count) == 'n')) {
 			log_print("Volume group \"%s\" not removed", vg_name);
 			return 0;
 		}
@@ -391,11 +388,9 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 			return 0;
 	}
 
-	lv_count = displayable_lvs_in_vg(vg);
-	
-	if (lv_count) {
+	if (vg->lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
-			  "logical volume(s)", vg_name, lv_count);
+			  "logical volume(s)", vg_name, vg->lv_count);
 		return 0;
 	}
 
@@ -1141,18 +1136,6 @@ int vg_remove(struct volume_group *vg)
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
 unsigned snapshot_lvs_in_vg(const struct volume_group *vg)
 {
 	struct lv_list *lvl;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 410a9f9..b1ea5cb 100644
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
 unsigned snapshot_lvs_in_vg(const struct volume_group *vg);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 852ad76..154c404 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -39,14 +39,6 @@ int lv_is_visible(const struct logical_volume *lv)
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
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6ca24e5..8366a40 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -104,7 +104,7 @@ FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, "vg_free_count", "Total numbe
 FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, "max_lv", "Maximum number of LVs allowed in VG or 0 if unlimited.")
 FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv", "Maximum number of PVs allowed in VG or 0 if unlimited.")
 FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count", "Number of PVs.")
-FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, "lv_count", "Number of LVs.")
+FIELD(VGS, vg, NUM, "#LV", lv_count, 3, uint32, "lv_count", "Number of LVs.")
 FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots.")
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
diff --git a/lib/report/report.c b/lib/report/report.c
index b02fdd8..0a1eeb1 100644
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
@@ -967,18 +967,6 @@ static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static int _lvcount_disp(struct dm_report *rh, struct dm_pool *mem,
-			 struct dm_report_field *field,
-			 const void *data, void *private)
-{
-	const struct volume_group *vg = (const struct volume_group *) data;
-	uint32_t count;
-
-	count = displayable_lvs_in_vg(vg);	
-
-	return _uint32_disp(rh, mem, field, &count, private);
-}
-
 static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)
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


