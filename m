From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Aug 2011 04:28:35 -0000
Subject: LVM2/lib metadata/raid_manip.c raid/raid.c
Message-ID: <20110813042835.21947.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-13 04:28:34

Modified files:
	lib/metadata   : raid_manip.c 
	lib/raid       : raid.c 

Log message:
	Compiler warning fixes, better error messaging, and cosmetic changes.
	
	1) add new function 'raid_remove_top_layer' which will be useful
	to other conversion functions later (also cleans up code)
	2) Add error messages if raid_[extract|add]_images fails
	3) Add function prototypes to prevent compiler warnings when
	compiling with '--with-raid=shared'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/metadata/raid_manip.c	2011/08/11 21:32:18	1.3
+++ LVM2/lib/metadata/raid_manip.c	2011/08/13 04:28:34	1.4
@@ -123,6 +123,63 @@
 }
 
 /*
+ * raid_remove_top_layer
+ * @lv
+ * @removal_list
+ *
+ * Remove top layer of RAID LV in order to convert to linear.
+ * This function makes no on-disk changes.  The residual LVs
+ * returned in 'removal_list' must be freed by the caller.
+ *
+ * Returns: 1 on succes, 0 on failure
+ */
+static int raid_remove_top_layer(struct logical_volume *lv,
+				 struct dm_list *removal_list)
+{
+	struct lv_list *lvl_array, *lvl;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!seg_is_mirrored(seg)) {
+		log_error(INTERNAL_ERROR
+			  "Unable to remove RAID layer from segment type %s",
+			  seg->segtype->name);
+		return 0;
+	}
+
+	if (seg->area_count != 1) {
+		log_error(INTERNAL_ERROR
+			  "Unable to remove RAID layer when there"
+			  " is more than one sub-lv");
+		return 0;
+	}
+
+	lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl));
+	if (!lvl_array) {
+		log_error("Memory allocation failed.");
+		return 0;
+	}
+
+	/* Add last metadata area to removal_list */
+	lvl_array[0].lv = seg_metalv(seg, 0);
+	lv_set_visible(seg_metalv(seg, 0));
+	remove_seg_from_segs_using_this_lv(seg_metalv(seg, 0), seg);
+	seg_metatype(seg, 0) = AREA_UNASSIGNED;
+	dm_list_add(removal_list, &(lvl_array[0].list));
+
+	/* Remove RAID layer and add residual LV to removal_list*/
+	seg_lv(seg, 0)->status &= ~RAID_IMAGE;
+	lv_set_visible(seg_lv(seg, 0));
+	lvl_array[1].lv = seg_lv(seg, 0);
+	dm_list_add(removal_list, &(lvl_array[1].list));
+
+	if (!remove_layer_from_lv(lv, seg_lv(seg, 0)))
+		return_0;
+
+	lv->status &= ~(MIRRORED | RAID);
+	return 1;
+}
+
+/*
  * _shift_and_rename_image_components
  * @seg: Top-level RAID segment
  *
@@ -373,11 +430,10 @@
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs)
 {
-	int r;
 	uint32_t old_count = lv_raid_image_count(lv);
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_list;
-	struct lv_list *lvl_array, *lvl;
+	struct lv_list *lvl;
 
 	dm_list_init(&removal_list);
 
@@ -392,34 +448,25 @@
 		return 1;
 	}
 
-	if (old_count > new_count)
-		r = raid_extract_images(lv, new_count, pvs, 1,
-					&removal_list, &removal_list);
-	else
-		r = raid_add_images(lv, new_count, pvs);
-	if (!r)
-		return 0;
+	if (old_count > new_count) {
+		if (!raid_extract_images(lv, new_count, pvs, 1,
+					 &removal_list, &removal_list)) {
+			log_error("Failed to extract images from %s/%s",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
+	} else {
+		if (!raid_add_images(lv, new_count, pvs)) {
+			log_error("Failed to add images to %s/%s",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
+	}
 
 	/* Convert to linear? */
-	if (new_count == 1) {
-		/* Add last metadata area to removal_list */
-		lvl_array = dm_pool_alloc(lv->vg->cmd->mem, 2 * sizeof(*lvl));
-		if (!lvl_array)
-			return_0;
-		lvl_array[0].lv = seg_metalv(seg, 0);
-		remove_seg_from_segs_using_this_lv(seg_metalv(seg, 0), seg);
-		seg_metatype(seg, 0) = AREA_UNASSIGNED;
-		dm_list_add(&removal_list, &(lvl_array[0].list));
-
-		/* Remove RAID layer */
-		seg_lv(seg, 0)->status &= ~RAID_IMAGE;
-		lv_set_visible(seg_lv(seg, 0));
-		lvl_array[1].lv = seg_lv(seg, 0);
-		dm_list_add(&removal_list, &(lvl_array[1].list));
-
-		if (!remove_layer_from_lv(lv, seg_lv(seg, 0)))
-			return_0;
-		lv->status &= ~(MIRRORED | RAID);
+	if ((new_count == 1) && !raid_remove_top_layer(lv, &removal_list)) {
+		log_error("Failed to remove RAID layer after linear conversion");
+		return 0;
 	}
 
 	if (!vg_write(lv->vg)) {
--- LVM2/lib/raid/raid.c	2011/08/11 21:32:19	1.5
+++ LVM2/lib/raid/raid.c	2011/08/13 04:28:34	1.6
@@ -349,6 +349,20 @@
 	return segtype;
 }
 
+#ifndef RAID_INTERNAL /* Shared */
+struct segment_type *init_raid1_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid4_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd);
+#endif
+
 struct segment_type *init_raid1_segtype(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;


