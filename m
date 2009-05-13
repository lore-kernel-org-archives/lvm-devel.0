From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:27:47 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/d ...
Message-ID: <20090513212747.29680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:27:45

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/display    : display.c 
	lib/format1    : import-export.c 
	lib/format_text: export.c 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 metadata.h snapshot_manip.c 
	lib/report     : report.c 
	tools          : lvchange.c lvdisplay.c lvscan.c reporter.c 
	                 vgchange.c 

Log message:
	Merge lv_is_displayable and lv_is_visible.
	
	Displayable and visible is the same thing.
	
	volumes_count(vg) is now vg_visible_lvs() and always
	returns number of LVs from user perspective.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1108&r2=1.1109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.217&r2=1.218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.193&r2=1.194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvdisplay.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/WHATS_NEW	2009/05/13 21:26:45	1.1108
+++ LVM2/WHATS_NEW	2009/05/13 21:27:43	1.1109
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Merge lv_is_displayable and lv_is_visible functions.
   Introduce lv_set_visible & lv_set_invisible functions.
   Fix lv_is_visible to handle virtual origin.
   Introduce link_lv_to_vg and unlink_lv_from_vg functions.
--- LVM2/lib/activate/activate.c	2009/05/13 21:26:45	1.146
+++ LVM2/lib/activate/activate.c	2009/05/13 21:27:43	1.147
@@ -673,7 +673,7 @@
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_displayable(lvl->lv))
+		if (lv_is_visible(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 	}
 
--- LVM2/lib/display/display.c	2008/12/04 15:54:27	1.96
+++ LVM2/lib/display/display.c	2009/05/13 21:27:43	1.97
@@ -606,7 +606,7 @@
 	}
 
 	log_print("MAX LV                %u", vg->max_lv);
-	log_print("Cur LV                %u", displayable_lvs_in_vg(vg));
+	log_print("Cur LV                %u", vg_visible_lvs(vg));
 	log_print("Open LV               %u", lvs_in_vg_opened(vg));
 /****** FIXME Max LV Size
       log_print ( "MAX LV Size           %s",
@@ -681,7 +681,7 @@
 		vg->status,
 		/* internal volume group number; obsolete */
 		vg->max_lv,
-		displayable_lvs_in_vg(vg),
+		vg_visible_lvs(vg),
 		lvs_in_vg_opened(vg),
 		/* FIXME: maximum logical volume size */
 		vg->max_pv,
--- LVM2/lib/format1/import-export.c	2009/05/13 21:25:01	1.105
+++ LVM2/lib/format1/import-export.c	2009/05/13 21:27:43	1.106
@@ -282,7 +282,7 @@
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = volumes_count(vg) + snapshot_count(vg);
+	vgd->lv_cur = vg_visible_lvs(vg) + snapshot_count(vg);
 
 	vgd->pv_max = vg->max_pv;
 	vgd->pv_cur = vg->pv_count;
--- LVM2/lib/format_text/export.c	2009/02/22 22:11:58	1.67
+++ LVM2/lib/format_text/export.c	2009/05/13 21:27:43	1.68
@@ -592,14 +592,14 @@
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
--- LVM2/lib/metadata/lv_manip.c	2009/05/13 21:26:45	1.169
+++ LVM2/lib/metadata/lv_manip.c	2009/05/13 21:27:43	1.170
@@ -1732,7 +1732,7 @@
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
-	if (!lv_is_displayable(lv)) {
+	if (!lv_is_visible(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
@@ -1818,7 +1818,7 @@
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == volumes_count(vg))) {
+	if (vg->max_lv && (vg->max_lv == vg_visible_lvs(vg))) {
 		log_error("Maximum number of logical volumes (%u) reached "
 			  "in volume group %s", vg->max_lv, vg->name);
 		return NULL;
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:26:45	1.70
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:27:43	1.71
@@ -238,18 +238,16 @@
 	/*
 	 * logical volumes
 	 * The following relationship should always hold:
-	 * dm_list_size(lvs) = lv_count + 2 * snapshot_count
+	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs
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
 
@@ -539,10 +537,9 @@
 int lv_is_origin(const struct logical_volume *lv);
 int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
-int lv_is_visible(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
-int lv_is_displayable(const struct logical_volume *lv);
+int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
@@ -563,7 +560,10 @@
 
 int vg_check_status(const struct volume_group *vg, uint32_t status);
 
-unsigned volumes_count(const struct volume_group *vg);
+/*
+ * Returns visible LV count - number of LVs from user perspective
+ */
+unsigned vg_visible_lvs(const struct volume_group *vg);
 
 /*
 * Mirroring functions
--- LVM2/lib/metadata/metadata.c	2009/05/13 21:22:57	1.217
+++ LVM2/lib/metadata/metadata.c	2009/05/13 21:27:43	1.218
@@ -376,7 +376,7 @@
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return 0;
 
-	lv_count = displayable_lvs_in_vg(vg);
+	lv_count = vg_visible_lvs(vg);
 
 	if (lv_count) {
 		if ((force == PROMPT) &&
@@ -391,8 +391,8 @@
 			return 0;
 	}
 
-	lv_count = displayable_lvs_in_vg(vg);
-	
+	lv_count = vg_visible_lvs(vg);
+
 	if (lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
 			  "logical volume(s)", vg_name, lv_count);
@@ -1140,18 +1140,6 @@
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
@@ -1164,17 +1152,14 @@
 	return num_snapshots;
 }
 
-unsigned volumes_count(const struct volume_group *vg)
+unsigned vg_visible_lvs(const struct volume_group *vg)
 {
 	struct lv_list *lvl;
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
@@ -1214,7 +1199,7 @@
 	}
 
 	if (vg_to->max_lv &&
-	    (vg_to->max_lv < volumes_count(vg_to) + volumes_count(vg_from))) {
+	    (vg_to->max_lv < vg_visible_lvs(vg_to) + vg_visible_lvs(vg_from))) {
 		log_error("Maximum number of logical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
 			  vg_from->name);
@@ -1469,12 +1454,38 @@
 		r = 0;
 	}
 
-	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    volumes_count(vg) + 2 * snapshot_count(vg)) {
+	/*
+	 * Count all non-snapshot invisible LVs
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
+		 *  FIXME: add check for unreferenced invisible LVs
+		 *   - snapshot cow & origin
+		 *   - mirror log & images
+		 *   - mirror conversion volumes (_mimagetmp*)
+		 */
+	}
+
+	/*
+	 * all volumes = visible LVs + snapshot_cows + invisible LVs
+	 */
+	if (((uint32_t) dm_list_size(&vg->lvs)) !=
+	    vg_visible_lvs(vg) + snapshot_count(vg) + lv_count) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
-			  dm_list_size(&vg->lvs), volumes_count(vg),
-			  snapshot_count(vg), vg->name);
+			  PRIu32 ") + #snapshots (%" PRIu32 ") + #invisible LVs %u in VG %s",
+			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
+			  snapshot_count(vg), lv_count, vg->name);
 		r = 0;
 	}
 
@@ -1517,10 +1528,10 @@
 		r = 0;
 	}
 
-	if (vg->max_lv && (vg->max_lv < volumes_count(vg))) {
+	if (vg->max_lv && (vg->max_lv < vg_visible_lvs(vg))) {
 		log_error("Internal error: Volume group %s contains %u volumes"
 			  " but the limit is set to %u.",
-			  vg->name, volumes_count(vg), vg->max_lv);
+			  vg->name, vg_visible_lvs(vg), vg->max_lv);
 		r = 0;
 	}
 
--- LVM2/lib/metadata/metadata.h	2009/05/12 19:12:10	1.193
+++ LVM2/lib/metadata/metadata.h	2009/05/13 21:27:43	1.194
@@ -340,11 +340,6 @@
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
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:26:45	1.40
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:27:43	1.41
@@ -43,14 +43,6 @@
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
--- LVM2/lib/report/report.c	2009/05/12 19:12:10	1.98
+++ LVM2/lib/report/report.c	2009/05/13 21:27:44	1.99
@@ -497,7 +497,7 @@
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_displayable(lv)) {
+	if (lv_is_visible(lv)) {
 		repstr = lv->name;
 		return dm_report_field_string(rh, field, (const char **) &repstr);
 	}
@@ -974,7 +974,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count;
 
-	count = displayable_lvs_in_vg(vg);	
+	count = vg_visible_lvs(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
--- LVM2/tools/lvchange.c	2009/04/25 01:18:00	1.99
+++ LVM2/tools/lvchange.c	2009/05/13 21:27:44	1.100
@@ -584,7 +584,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!(lv_is_displayable(lv))) {
+	if (!(lv_is_visible(lv))) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
--- LVM2/tools/lvdisplay.c	2008/12/04 15:54:27	1.21
+++ LVM2/tools/lvdisplay.c	2009/05/13 21:27:44	1.22
@@ -18,7 +18,7 @@
 static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	if (arg_count(cmd, colon_ARG))
--- LVM2/tools/lvscan.c	2008/12/04 15:54:27	1.37
+++ LVM2/tools/lvscan.c	2009/05/13 21:27:44	1.38
@@ -27,7 +27,7 @@
 
 	const char *active_str, *snapshot_str;
 
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
--- LVM2/tools/reporter.c	2009/04/21 12:59:19	1.47
+++ LVM2/tools/reporter.c	2009/05/13 21:27:44	1.48
@@ -36,7 +36,7 @@
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
@@ -113,7 +113,7 @@
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
--- LVM2/tools/vgchange.c	2009/05/13 21:22:57	1.70
+++ LVM2/tools/vgchange.c	2009/05/13 21:27:44	1.71
@@ -308,9 +308,9 @@
 		}
 	}
 
-	if (max_lv && max_lv < volumes_count(vg)) {
+	if (max_lv && max_lv < vg_visible_lvs(vg)) {
 		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for %s", volumes_count(vg),
+			  "%d of LVs for %s", vg_visible_lvs(vg),
 			  vg->name);
 		return ECMD_FAILED;
 	}


