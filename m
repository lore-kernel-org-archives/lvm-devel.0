From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 17:17:10 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20080117171710.15108.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 17:17:09

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 mirror.c 
	lib/mirror     : mirrored.c 
	tools          : toollib.c 

Log message:
	pre-release review cleanups

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.766&r2=1.767
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/WHATS_NEW	2008/01/17 15:53:01	1.766
+++ LVM2/WHATS_NEW	2008/01/17 17:17:08	1.767
@@ -1,5 +1,6 @@
 Version 2.02.30 - 17th January 2008
 ===================================
+  Set default readahead to twice maximium stripe size.
   Reinstate VG extent size and stripe size defaults (halved). (2.02.29)
   Add lists of stacked LV segments using each LV to the internal metadata.
   Change vgsplit -l (for unimplemented --list) into --maxlogicalvolumes.
--- LVM2/lib/activate/activate.c	2008/01/16 19:18:50	1.130
+++ LVM2/lib/activate/activate.c	2008/01/17 17:17:08	1.131
@@ -706,10 +706,9 @@
 	 */
 	if (lv_is_origin(lv)) {
 		list_iterate_safe(snh, snht, &lv->snapshot_segs)
-			if (!monitor_dev_for_events(
-				cmd, list_struct_base(snh,
-					struct lv_segment, origin_list)->cow, monitor))
-				r=0;
+			if (!monitor_dev_for_events(cmd, list_struct_base(snh,
+				    struct lv_segment, origin_list)->cow, monitor))
+				r = 0;
 		return r;
 	}
 
--- LVM2/lib/metadata/lv_manip.c	2008/01/17 13:54:05	1.144
+++ LVM2/lib/metadata/lv_manip.c	2008/01/17 17:17:09	1.145
@@ -31,7 +31,8 @@
 	const char *new;
 };
 
-int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg)
+int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
+				  struct lv_segment *seg)
 {
 	struct seg_list *sl;
 
@@ -54,7 +55,8 @@
 	return 1;
 }
 
-int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg)
+int remove_seg_from_segs_using_this_lv(struct logical_volume *lv,
+				       struct lv_segment *seg)
 {
 	struct seg_list *sl;
 
@@ -1429,7 +1431,7 @@
 
 		if (!seg_is_mirrored(seg) &&
 		    (!(seg = _convert_seg_to_mirror(seg, region_size, NULL))))
-				return_0;
+			return_0;
 
 		old_area_count = seg->area_count;
 		new_area_count = old_area_count + ah->area_count;
@@ -1530,20 +1532,16 @@
 		return 0;
 	}
 
-	if (!set_lv_segment_area_pv(seg, 0, ah->log_area.pv, ah->log_area.pe)) {
-		stack;
-		return 0;
-	}
+	if (!set_lv_segment_area_pv(seg, 0, ah->log_area.pv, ah->log_area.pe))
+		return_0;
 
 	list_add(&log_lv->segments, &seg->list);
 	log_lv->le_count += ah->log_area.len;
-	log_lv->size += (uint64_t) log_lv->le_count *log_lv->vg->extent_size;
+	log_lv->size += (uint64_t) log_lv->le_count * log_lv->vg->extent_size;
 
 	if (log_lv->vg->fid->fmt->ops->lv_setup &&
-	    !log_lv->vg->fid->fmt->ops->lv_setup(log_lv->vg->fid, log_lv)) {
-		stack;
-		return 0;
-	}
+	    !log_lv->vg->fid->fmt->ops->lv_setup(log_lv->vg->fid, log_lv))
+		return_0;
 
 	return 1;
 }
@@ -1668,7 +1666,7 @@
 	}
 	suffix = lv->name + len;
 
- 	/*
+	/*
 	 * Compose a new name for sub lv:
 	 *   e.g. new name is "lvol1_mlog"
 	 *        if the sub LV is "lvol0_mlog" and
@@ -2025,9 +2023,9 @@
 			 if (yes_no_prompt("Do you really want to remove active "
 					   "logical volume \"%s\"? [y/n]: ",
 					   lv->name) == 'n') {
-				 log_print("Logical volume \"%s\" not removed",
+				log_print("Logical volume \"%s\" not removed",
 					  lv->name);
-				 return 0;
+				return 0;
 			 }
 		}
 	}
@@ -2264,7 +2262,7 @@
 
 		if (!remove_layers_for_segments(cmd, lv1, layer_lv,
 						status_mask, lvs_changed))
-			return 0;
+			return_0;
 	}
 
 	if (!lv_empty(layer_lv))
@@ -2627,7 +2625,7 @@
 	}
 
 	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			 lv->vg->name, lv->name) < 0) {
+			lv->vg->name, lv->name) < 0) {
 		log_error("Name too long - device not cleared (%s)", lv->name);
 		return 0;
 	}
@@ -2640,7 +2638,7 @@
 	}
 
 	if (!dev_open_quiet(dev))
-		return 0;
+		return_0;
 
 	dev_set(dev, UINT64_C(0),
 		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
@@ -2650,5 +2648,3 @@
 
 	return 1;
 }
-
-
--- LVM2/lib/metadata/metadata-exported.h	2008/01/17 13:54:05	1.39
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/17 17:17:09	1.40
@@ -94,7 +94,7 @@
 
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
-#define MIRROR_BY_LV		0x00000002U	/* mirror by mimage LVs */
+#define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
--- LVM2/lib/metadata/metadata.c	2008/01/16 22:52:46	1.151
+++ LVM2/lib/metadata/metadata.c	2008/01/17 17:17:09	1.152
@@ -233,7 +233,7 @@
 	char vg_path[PATH_MAX];
 
 	if (!validate_name(vg_name))
-		return 0;
+		return_0;
 
 	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
 	if (path_exists(vg_path)) {
@@ -244,7 +244,6 @@
 	return 1;
 }
 
-
 int validate_vg_rename_params(struct cmd_context *cmd,
 			      const char *vg_name_old,
 			      const char *vg_name_new)
@@ -1084,7 +1083,6 @@
 	return 1;
 }
 
-
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -1094,11 +1092,12 @@
 {
 	struct lv_list *lvl1, *lvl2;
 	struct pv_list *pvl;
+	char *name1, *name2;
 
 	if (lvs_in_vg_activated(vg_from)) {
 		log_error("Logical volumes in \"%s\" must be inactive",
 			  vg_from->name);
-		goto error;
+		return 0;
 	}
 
 	/* Check compatibility */
@@ -1106,7 +1105,7 @@
 		log_error("Extent sizes differ: %d (%s) and %d (%s)",
 			  vg_to->extent_size, vg_to->name,
 			  vg_from->extent_size, vg_from->name);
-		goto error;
+		return 0;
 	}
 
 	if (vg_to->max_pv &&
@@ -1114,7 +1113,7 @@
 		log_error("Maximum number of physical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_pv, vg_to->name,
 			  vg_from->name);
-		goto error;
+		return 0;
 	}
 
 	if (vg_to->max_lv &&
@@ -1122,22 +1121,22 @@
 		log_error("Maximum number of logical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
 			  vg_from->name);
-		goto error;
+		return 0;
 	}
 
 	/* Check no conflicts with LV names */
 	list_iterate_items(lvl1, &vg_to->lvs) {
-		char *name1 = lvl1->lv->name;
+		name1 = lvl1->lv->name;
 
 		list_iterate_items(lvl2, &vg_from->lvs) {
-			char *name2 = lvl2->lv->name;
+			name2 = lvl2->lv->name;
 
 			if (!strcmp(name1, name2)) {
 				log_error("Duplicate logical volume "
 					  "name \"%s\" "
 					  "in \"%s\" and \"%s\"",
 					  name1, vg_to->name, vg_from->name);
-				goto error;
+				return 0;
 			}
 		}
 	}
@@ -1148,7 +1147,7 @@
 			log_error("Physical volume %s might be constructed "
 				  "from same volume group %s.",
 				  pv_dev_name(pvl->pv), vg_from->name);
-			goto error;
+			return 0;
 		}
 	}
 
@@ -1157,18 +1156,13 @@
 			log_error("Physical volume %s might be constructed "
 				  "from same volume group %s.",
 				  pv_dev_name(pvl->pv), vg_to->name);
-			goto error;
+			return 0;
 		}
 	}
 
 	return 1;
-
-error:
-	return 0;
 }
 
-
-
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
--- LVM2/lib/metadata/mirror.c	2008/01/17 13:54:05	1.62
+++ LVM2/lib/metadata/mirror.c	2008/01/17 17:17:09	1.63
@@ -1485,10 +1485,9 @@
 
 	/* MIRROR_BY_LV */
 	if (seg_type(seg, 0) == AREA_LV &&
-	    seg_lv(seg, 0)->status & MIRROR_IMAGE) {
+	    seg_lv(seg, 0)->status & MIRROR_IMAGE)
 		return remove_mirror_images(lv, new_mirrors + 1,
 					    pvs, log_count ? 1U : 0);
-	}
 
 	/* MIRROR_BY_SEG */
 	if (log_count) {
--- LVM2/lib/mirror/mirrored.c	2008/01/16 19:18:51	1.48
+++ LVM2/lib/mirror/mirrored.c	2008/01/17 17:17:09	1.49
@@ -283,8 +283,10 @@
 
 	mirr_state = *target_state;
 
-	/* Mirror segment could have only 1 area temporarily,
-	 * if the segment is under conversion. */
+	/*
+	 * Mirror segment could have only 1 area temporarily
+	 * if the segment is under conversion.
+	 */
  	if (seg->area_count == 1)
 		mirror_status = MIRR_DISABLED;
 
--- LVM2/tools/toollib.c	2008/01/16 19:54:39	1.127
+++ LVM2/tools/toollib.c	2008/01/17 17:17:09	1.128
@@ -20,10 +20,6 @@
 #include <sys/stat.h>
 #include <sys/wait.h>
 
-/* From linux/drivers/md/dm-log.c */
-#define MIRROR_MAGIC 0x4D695272
-#define MIRROR_DISK_VERSION 2
-
 /* Command line args */
 unsigned arg_count(const struct cmd_context *cmd, int a)
 {


