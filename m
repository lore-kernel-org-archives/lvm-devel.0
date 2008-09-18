From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Sep 2008 19:56:51 -0000
Subject: LVM2 tools/vgreduce.c ./WHATS_NEW lib/metadata ...
Message-ID: <20080918195651.3888.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-18 19:56:50

Modified files:
	tools          : vgreduce.c 
	.              : WHATS_NEW 
	lib/metadata   : mirror.c metadata-exported.h 

Log message:
	Avoid shuffling remaining mirror images when removing one, retaining primary.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.954&r2=1.955
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/tools/vgreduce.c	2008/04/08 12:49:21	1.80
+++ LVM2/tools/vgreduce.c	2008/09/18 19:56:50	1.81
@@ -250,9 +250,8 @@
 					    lvl2->lv != seg_lv(mirrored_seg, s))
 						continue;
 					list_del(&lvl2->list);
-					area = mirrored_seg->areas[mimages - 1];
-					mirrored_seg->areas[mimages - 1] = mirrored_seg->areas[s];
-					mirrored_seg->areas[s] = area;
+					if (!shift_mirror_images(mirrored_seg, s))
+						return_0;
 					mimages--;	/* FIXME Assumes uniqueness */
 				}
 			}
--- LVM2/WHATS_NEW	2008/09/18 19:09:47	1.954
+++ LVM2/WHATS_NEW	2008/09/18 19:56:50	1.955
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Avoid shuffling remaining mirror images when removing one, retaining primary.
   Add missing LV error target activation in _remove_mirror_images.
   Prevent resizing an LV while lvconvert is using it.
   Avoid repeatedly wiping cache while VG_GLOBAL is held in vgscan & pvscan.
--- LVM2/lib/metadata/mirror.c	2008/09/18 19:09:47	1.74
+++ LVM2/lib/metadata/mirror.c	2008/09/18 19:56:50	1.75
@@ -136,6 +136,53 @@
 }
 
 /*
+ * shift_mirror_images
+ * @mirrored_seg
+ * @mimage:  The position (index) of the image to move to the end
+ *
+ * When dealing with removal of legs, we often move a 'removable leg'
+ * to the back of the 'areas' array.  It is critically important not
+ * to simply swap it for the last area in the array.  This would have
+ * the affect of reordering the remaining legs - altering position of
+ * the primary.  So, we must shuffle all of the areas in the array
+ * to maintain their relative position before moving the 'removable
+ * leg' to the end.
+ *
+ * Short illustration of the problem:
+ *   - Mirror consists of legs A, B, C and we want to remove A
+ *   - We swap A and C and then remove A, leaving C, B
+ * This scenario is problematic in failure cases where A dies, because
+ * B becomes the primary.  If the above happens, we effectively throw
+ * away any changes made between the time of failure and the time of
+ * restructuring the mirror.
+ *
+ * So, any time we want to move areas to the end to be removed, use
+ * this function.
+ */
+int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage)
+{
+	int i;
+	struct lv_segment_area area;
+
+	if (mimage >= mirrored_seg->area_count) {
+		log_error("Invalid index (%u) of mirror image supplied "
+			  "to shift_mirror_images()", mimage);
+		return 0;
+	}
+
+	area = mirrored_seg->areas[mimage];
+
+	/* Shift remaining images down to fill the hole */
+	for (i = mimage + 1; i < mirrored_seg->area_count; i++)
+		mirrored_seg->areas[i-1] = mirrored_seg->areas[i];
+
+	/* Place this one at the end */
+	mirrored_seg->areas[i-1] = area;
+
+	return 0;
+}
+
+/*
  * This function writes a new header to the mirror log header to the lv
  *
  * Returns: 1 on success, 0 on failure
@@ -469,13 +516,12 @@
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
 			sub_lv = seg_lv(mirrored_seg, s);
+
 			if (!is_temporary_mirror_layer(sub_lv) &&
 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
-				/* Swap segment to end */
+				if (!shift_mirror_images(mirrored_seg, s))
+					return_0;
 				new_area_count--;
-				area = mirrored_seg->areas[new_area_count];
-				mirrored_seg->areas[new_area_count] = mirrored_seg->areas[s];
-				mirrored_seg->areas[s] = area;
 			}
 		}
 		if (num_removed && old_area_count == new_area_count)
--- LVM2/lib/metadata/metadata-exported.h	2008/08/05 12:05:25	1.50
+++ LVM2/lib/metadata/metadata-exported.h	2008/09/18 19:56:50	1.51
@@ -532,6 +532,7 @@
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
 			      struct list *removable_pvs, unsigned remove_log);
 int collapse_mirrored_lv(struct logical_volume *lv);
+int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);


