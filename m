From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2008 18:35:52 -0000
Subject: LVM2 lib/format_text/flags.c lib/format_text/i ...
Message-ID: <20080110183552.28693.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-10 18:35:51

Modified files:
	lib/format_text: flags.c import_vsn1.c 
	lib/metadata   : metadata-exported.h mirror.c 
	lib/report     : columns.h report.c 
	man            : lvs.8 pvs.8 vgs.8 
	tools          : lvchange.c lvconvert.c tools.h 

Log message:
	Various lvconvert/polldaemon-related fixes from NEC.  See lvm-devel
	for original patches & explanations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/lib/format_text/flags.c	2007/08/20 20:55:26	1.30
+++ LVM2/lib/format_text/flags.c	2008/01/10 18:35:50	1.31
@@ -60,6 +60,7 @@
 	{VIRTUAL, NULL},
 	{SNAPSHOT, NULL},
 	{ACTIVATE_EXCL, NULL},
+	{CONVERTING, NULL},
 	{0, NULL}
 };
 
--- LVM2/lib/format_text/import_vsn1.c	2007/11/09 16:51:53	1.45
+++ LVM2/lib/format_text/import_vsn1.c	2008/01/10 18:35:50	1.46
@@ -86,6 +86,22 @@
 	return 1;
 }
 
+static int _is_converting(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	if (lv->status & MIRRORED) {
+		seg = first_seg(lv);
+		/* Can't use is_temporary_mirror() because the metadata for
+		 * seg_lv may not be read in and flags may not be set yet. */
+		if (seg_type(seg, 0) == AREA_LV &&
+		    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER))
+			return 1;
+	}
+
+	return 0;
+}
+
 static int _read_id(struct id *id, struct config_node *cn, const char *path)
 {
 	struct config_value *cv;
@@ -343,6 +359,9 @@
 	if (seg_is_virtual(seg))
 		lv->status |= VIRTUAL;
 
+	if (_is_converting(lv))
+		lv->status |= CONVERTING;
+
 	return 1;
 }
 
--- LVM2/lib/metadata/metadata-exported.h	2008/01/07 20:42:57	1.30
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/10 18:35:50	1.31
@@ -69,6 +69,7 @@
 #define MIRROR_NOTSYNCED	0x00080000U	/* LV */
 //#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
+#define CONVERTING		0x00400000U	/* LV */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
--- LVM2/lib/metadata/mirror.c	2007/12/22 12:13:29	1.51
+++ LVM2/lib/metadata/mirror.c	2008/01/10 18:35:50	1.52
@@ -134,13 +134,34 @@
 	return 1;
 }
 
+static int _merge_mirror_images(struct logical_volume *lv,
+				const struct list *mimages)
+{
+	uint32_t addition = list_size(mimages);
+	struct logical_volume **img_lvs;
+	struct lv_list *lvl;
+	int i = 0;
+
+	if (!addition)
+		return 1;
+
+	if (!(img_lvs = alloca(sizeof(*img_lvs) * addition)))
+		return_0;
+
+	list_iterate_items(lvl, mimages)
+		img_lvs[i++] = lvl->lv;
+
+	return lv_add_mirror_lvs(lv, img_lvs, addition,
+				 MIRROR_IMAGE, first_seg(lv)->region_size);
+}
+
 /*
  * Remove num_removed images from mirrored_seg
  */
 static int _remove_mirror_images(struct logical_volume *lv,
 				 uint32_t num_removed,
 				 struct list *removable_pvs,
-				 unsigned remove_log, struct list *orphan_lvs)
+				 unsigned remove_log, unsigned collapse)
 {
 	uint32_t m;
 	uint32_t s, s1;
@@ -162,9 +183,16 @@
 			 old_area_count, old_area_count - num_removed,
 			 remove_log ? " and no log volume" : "");
 
+	if (collapse &&
+	    (removable_pvs || (old_area_count - num_removed != 1))) {
+		log_error("Incompatible parameters to _remove_mirror_images");
+		return 0;
+	}
+
 	/* Move removable_pvs to end of array */
 	if (removable_pvs) {
-		for (s = 0; s < mirrored_seg->area_count; s++) {
+		for (s = 0; s < mirrored_seg->area_count &&
+			    old_area_count - new_area_count < num_removed; s++) {
 			all_pvs_removable = 1;
 			sub_lv = seg_lv(mirrored_seg, s);
 			list_iterate_items(seg, &sub_lv->segments) {
@@ -197,11 +225,8 @@
 				mirrored_seg->areas[new_area_count] = mirrored_seg->areas[s];
 				mirrored_seg->areas[s] = area;
 			}
-			/* Found enough matches? */
-			if (old_area_count - new_area_count == num_removed)
-				break;
 		}
-		if (old_area_count == new_area_count) {
+		if (num_removed && old_area_count == new_area_count) {
 			log_error("No mirror images found using specified PVs.");
 			return 0;
 		}
@@ -235,7 +260,12 @@
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
 		remove_log = 1;
-	}
+		if (collapse && !_merge_mirror_images(lv, &tmp_orphan_lvs)) {
+			log_error("Failed to add mirror images");
+			return 0;
+		}
+	} else if (remove_log)
+		mirrored_seg->log_lv = NULL;
 
 	if (remove_log && log_lv) {
 		log_lv->status &= ~MIRROR_LOG;
@@ -272,11 +302,7 @@
 	}
 
 	/* Save or delete the 'orphan' LVs */
-	if (orphan_lvs) {
-		*orphan_lvs = tmp_orphan_lvs;
-		orphan_lvs->n->p = orphan_lvs;
-		orphan_lvs->p->n = orphan_lvs;
-	} else {
+	if (!collapse) {
 		list_iterate_items(lvl, &tmp_orphan_lvs)
 			if (!_delete_lv(lv, lvl->lv))
 				return 0;
@@ -302,18 +328,19 @@
 
 	num_removed = existing_mirrors - num_mirrors;
 
-	while (num_removed) {
+	/* num_removed can be 0 if the function is called just to remove log */
+	do {
 		if (num_removed < first_seg(lv)->area_count)
 			removed_once = num_removed;
 		else
 			removed_once = first_seg(lv)->area_count - 1;
 
 		if (!_remove_mirror_images(lv, removed_once,
-				           removable_pvs, remove_log, NULL))
+				           removable_pvs, remove_log, 0))
 			return_0;
 
 		num_removed -= removed_once;
-	}
+	} while (num_removed);
 
 	return 1;
 }
@@ -334,27 +361,6 @@
 	return 0;
 }
 
-static int _merge_mirror_images(struct logical_volume *lv,
-				const struct list *mimages)
-{
-	uint32_t addition = list_size(mimages);
-	struct logical_volume **img_lvs;
-	struct lv_list *lvl;
-	int i = 0;
-
-	if (!addition)
-		return 1;
-
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * addition)))
-		return_0;
-
-	list_iterate_items(lvl, mimages)
-		img_lvs[i++] = lvl->lv;
-
-	return lv_add_mirror_lvs(lv, img_lvs, addition,
-				 MIRROR_IMAGE, first_seg(lv)->region_size);
-}
-
 /*
  * Return a temporary LV for resyncing added mirror image.
  * Add other mirror legs to lvs list.
@@ -390,7 +396,6 @@
 int collapse_mirrored_lv(struct logical_volume *lv)
 {
 	struct logical_volume *tmp_lv, *parent_lv;
-	struct list lvlist;
 
 	while ((tmp_lv = _find_tmp_mirror(lv))) {
 		parent_lv = find_parent_for_layer(lv, tmp_lv);
@@ -400,18 +405,12 @@
 			return 1;
 		}
 
-		list_init(&lvlist);
 		if (!_remove_mirror_images(parent_lv,
 					   first_seg(parent_lv)->area_count - 1,
-					   NULL, 1, &lvlist)) {
+					   NULL, 1, 1)) {
 			log_error("Failed to release mirror images");
 			return 0;
 		}
-
-		if (!_merge_mirror_images(parent_lv, &lvlist)) {
-			log_error("Failed to add mirror images");
-			return 0;
-		}
 	}
 
 	return 1;
@@ -1277,6 +1276,13 @@
 		return 0;
 	}
 
+	/* For corelog mirror, activation code depends on
+	 * the global mirror_in_sync status. As we are adding
+	 * a new mirror, it should be set as 'out-of-sync'
+	 * so that the sync starts. */
+	if (!log_count)
+		init_mirror_in_sync(0);
+
 	if (flags & MIRROR_BY_SEG) {
 		if (log_count) {
 			log_error("Persistent log is not supported on "
--- LVM2/lib/report/columns.h	2007/12/14 21:53:02	1.26
+++ LVM2/lib/report/columns.h	2008/01/10 18:35:51	1.27
@@ -33,6 +33,7 @@
 FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, "snap_percent", "For snapshots, the percentage full if LV is active.")
 FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, "copy_percent", "For mirrors and pvmove, current percentage in-sync.")
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, "move_pv", "For pvmove, Source PV of temporary LV created by pvmove")
+FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, "convert_lv", "For lvconvert, Name of temporary LV created by lvconvert")
 FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, "lv_tags", "Tags, if any.")
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log", "For mirrors, the LV holding the synchronisation log.")
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mapper modules required for this LV.")
--- LVM2/lib/report/report.c	2007/12/22 02:12:59	1.70
+++ LVM2/lib/report/report.c	2008/01/10 18:35:51	1.71
@@ -272,7 +272,7 @@
 	return dm_report_field_uint64(rh, field, &_minusone);
 }
 
-static int _lv_mimage_in_sync(struct logical_volume *lv)
+static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
 	float percent;
 	struct lv_segment *seg = first_seg(lv);
@@ -306,6 +306,8 @@
 
 	if (lv->status & PVMOVE)
 		repstr[0] = 'p';
+	else if (lv->status & CONVERTING)
+		repstr[0] = 'c';
 	else if (lv->status & MIRRORED) {
 		if (lv->status & MIRROR_NOTSYNCED)
 			repstr[0] = 'M';
@@ -548,6 +550,32 @@
 	return 1;
 }
 
+static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+			   struct dm_report_field *field,
+			   const void *data, void *private __attribute((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const char *name = NULL;
+	struct lv_segment *seg;
+
+	if (lv->status & CONVERTING) {
+		if (lv->status & MIRRORED) {
+			seg = first_seg(lv);
+
+			/* Temporary mirror is always area_num == 0 */
+			if (seg_type(seg, 0) == AREA_LV &&
+			    is_temporary_mirror_layer(seg_lv(seg, 0)))
+				name = seg_lv(seg, 0)->name;
+		}
+	}
+
+	if (name)
+		return dm_report_field_string(rh, field, &name);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
 static int _size32_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
--- LVM2/man/lvs.8	2007/12/22 02:12:59	1.7
+++ LVM2/man/lvs.8	2008/01/10 18:35:51	1.8
@@ -47,7 +47,8 @@
 .RS
 .IP 1 3
 Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin, (p)vmove, (s)napshot, 
-invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage out-of-sync
+invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage out-of-sync,
+under (c)onversion
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3
@@ -82,6 +83,7 @@
 of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
 \-\-units 3M
 .SH SEE ALSO
+.BR lvm (8),
 .BR lvdisplay (8),
 .BR pvs (8),
 .BR vgs (8)
--- LVM2/man/pvs.8	2007/01/18 22:33:24	1.3
+++ LVM2/man/pvs.8	2008/01/10 18:35:51	1.4
@@ -58,6 +58,7 @@
 of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
 \-\-units 3M
 .SH SEE ALSO
+.BR lvm (8),
 .BR pvdisplay (8),
 .BR lvs (8),
 .BR vgs (8)
--- LVM2/man/vgs.8	2007/03/27 13:35:33	1.5
+++ LVM2/man/vgs.8	2008/01/10 18:35:51	1.6
@@ -71,6 +71,7 @@
 of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
 \-\-units 3M
 .SH SEE ALSO
+.BR lvm (8),
 .BR vgdisplay (8),
 .BR pvs (8),
 .BR lvs (8)
--- LVM2/tools/lvchange.c	2007/12/05 19:24:32	1.84
+++ LVM2/tools/lvchange.c	2008/01/10 18:35:51	1.85
@@ -106,6 +106,8 @@
 {
 	int activate;
 	const char *pvname;
+	char *lv_full_name;
+	uint32_t len;
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
@@ -158,6 +160,18 @@
 				    pvname);
 			pvmove_poll(cmd, pvname, 1);
 		}
+
+		if (lv->status & CONVERTING) {
+			len = strlen(lv->vg->name) + strlen(lv->name) + 2;
+			if (!(lv_full_name = alloca(len)))
+				return_0;
+			if (!dm_snprintf(lv_full_name, len, "%s/%s",
+					 lv->vg->name, lv->name))
+				return_0;
+			log_verbose("Spawning background lvconvert process for %s",
+				    lv->name);
+			lvconvert_poll(cmd, lv_full_name, 1);
+		}
 	}
 
 	return 1;
--- LVM2/tools/lvconvert.c	2007/12/22 12:13:29	1.52
+++ LVM2/tools/lvconvert.c	2008/01/10 18:35:51	1.53
@@ -270,6 +270,8 @@
 		return 0;
 	}
 
+	lv->status &= ~CONVERTING;
+
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
 	if (!vg_write(vg))
@@ -307,8 +309,8 @@
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
-static int _lvconvert_poll(struct cmd_context *cmd, const char *lv_name,
-			   unsigned background)
+int lvconvert_poll(struct cmd_context *cmd, const char *lv_name,
+		   unsigned background)
 {
 	return poll_daemon(cmd, lv_name, background, 0, &_lvconvert_mirror_fns,
 			   "Converted");
@@ -370,7 +372,8 @@
 	existing_mirrors = lv_mirror_count(lv);
 
 	/* If called with no argument, try collapsing the resync layers */
-	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG)) {
+	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
+	    !arg_count(cmd, corelog_ARG)) {
 		lp->wait_daemon = 1;
 		return 1;
 	}
@@ -496,7 +499,8 @@
 					    lp->pvh, lp->alloc))
 				return_0;
 		} else if (seg->log_lv && corelog) {
-			if (!remove_mirror_log(cmd, lv, lp->pvh))
+			if (!remove_mirror_log(cmd, lv,
+					       lp->pv_count ? lp->pvh : NULL))
 				return_0;
 		} else {
 			/* No change */
@@ -511,25 +515,46 @@
 				  "without initial resync");
 			return 0;
 		}
-		/* FIXME: can't have multiple mlogs. force corelog. */
-		corelog = 1;
-		if (!_insert_lvconvert_layer(cmd, lv)) {
+		/*
+		 * Log addition/removal should be done before the layer
+		 * insertion to make the end result consistent with
+		 * linear-to-mirror conversion.
+		 */
+		if (!seg->log_lv && !corelog) {
+			if (!add_mirror_log(cmd, lv, 1,
+					    adjusted_mirror_region_size(
+							lv->vg->extent_size,
+							lv->le_count,
+							lp->region_size),
+					    lp->pvh, lp->alloc))
+				return_0;
+		} else if (seg->log_lv && corelog) {
+			if (!remove_mirror_log(cmd, lv,
+					       lp->pv_count ? lp->pvh : NULL))
+				return_0;
+		}
+		/* Insert a temporary layer for syncing,
+		 * only if the original lv is using disk log. */
+		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
 			log_error("Failed to insert resync layer");
 			return 0;
 		}
+		/* FIXME: can't have multiple mlogs. force corelog. */
 		if (!lv_add_mirrors(cmd, lv, lp->mirrors - existing_mirrors, 1,
 				    adjusted_mirror_region_size(
 						lv->vg->extent_size,
 						lv->le_count,
 						lp->region_size),
-				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    0U, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV))
 			return_0;
+		lv->status |= CONVERTING;
 		lp->wait_daemon = 1;
 	} else {
 		/* Reduce number of mirrors */
 		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-				       0, lp->pv_count ? lp->pvh : NULL, 0))
+				       corelog ? 1U : 0U,
+				       lp->pv_count ? lp->pvh : NULL, 0))
 			return_0;
 	}
 
@@ -681,6 +706,7 @@
 	struct lv_list *lvl;
 	struct lvconvert_params lp;
 	int ret = ECMD_FAILED;
+	struct lvinfo info;
 
 	if (!_read_params(&lp, cmd, argc, argv)) {
 		stack;
@@ -714,8 +740,14 @@
 error:
 	unlock_vg(cmd, lp.vg_name);
 
-	if (lp.wait_daemon)
-		ret = _lvconvert_poll(cmd, lp.lv_name_full,
-				      arg_count(cmd, background_ARG) ? 1U : 0);
+	if (ret == ECMD_PROCESSED && lp.wait_daemon) {
+		if (!lv_info(cmd, lvl->lv, &info, 1, 0) || !info.exists) {
+			log_print("Conversion starts after activation");
+			return ret;
+		}
+		ret = lvconvert_poll(cmd, lp.lv_name_full,
+				     arg_count(cmd, background_ARG) ? 1U : 0);
+	}
+
 	return ret;
 }
--- LVM2/tools/tools.h	2007/11/09 16:51:54	1.59
+++ LVM2/tools/tools.h	2008/01/10 18:35:51	1.60
@@ -165,5 +165,6 @@
 const char *command_name(struct cmd_context *cmd);
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
+int lvconvert_poll(struct cmd_context *cmd, const char *lv_name, unsigned background);
 
 #endif


