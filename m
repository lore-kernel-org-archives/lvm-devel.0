From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:11:39 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080116191139.13718.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:11:39

Modified files:
	lib/metadata   : mirror.c 

Log message:
	move removable_pvs checking

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/metadata/mirror.c	2008/01/16 19:09:35	1.54
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:11:39	1.55
@@ -335,6 +335,39 @@
 	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
 }
 
+/* Check if mirror image LV is removable with regard to given removable_pvs */
+static int _is_mirror_image_removable(struct logical_volume *mimage_lv,
+				      struct list *removable_pvs)
+{
+	struct physical_volume *pv;
+	struct lv_segment *seg;
+	int pv_found;
+	struct pv_list *pvl;
+	uint32_t s;
+
+	list_iterate_items(seg, &mimage_lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV)
+				/* FIXME Recurse for AREA_LV */
+				continue;
+
+			pv = seg_pv(seg, s);
+
+			pv_found = 0;
+			list_iterate_items(pvl, removable_pvs) {
+				if (pv->dev->dev == pvl->pv->dev->dev) {
+					pv_found = 1;
+					break;
+				}
+			}
+			if (!pv_found)
+				return 0;
+		}
+	}
+
+	return 1;
+}
+
 /*
  * Remove num_removed images from mirrored_seg
  */
@@ -344,15 +377,12 @@
 				 unsigned remove_log, unsigned collapse)
 {
 	uint32_t m;
-	uint32_t s, s1;
+	uint32_t s;
 	struct logical_volume *sub_lv;
 	struct logical_volume *log_lv = NULL;
 	struct logical_volume *lv1 = NULL;
-	struct physical_volume *pv;
-	struct lv_segment *seg, *mirrored_seg = first_seg(lv);
+	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct lv_segment_area area;
-	int all_pvs_removable, pv_found;
-	struct pv_list *pvl;
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
 	struct lv_list *lvl;
@@ -373,32 +403,8 @@
 	if (removable_pvs) {
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
-			all_pvs_removable = 1;
 			sub_lv = seg_lv(mirrored_seg, s);
-			list_iterate_items(seg, &sub_lv->segments) {
-				for (s1 = 0; s1 < seg->area_count; s1++) {
-					if (seg_type(seg, s1) != AREA_PV)
-						/* FIXME Recurse for AREA_LV */
-						continue;
-
-					pv = seg_pv(seg, s1);
-
-					pv_found = 0;
-					list_iterate_items(pvl, removable_pvs) {
-						if (pv->dev->dev == pvl->pv->dev->dev) {
-							pv_found = 1;
-							break;
-						}
-					}
-					if (!pv_found) {
-						all_pvs_removable = 0;
-						break;
-					}
-				}
-				if (!all_pvs_removable)
-					break;
-			}
-			if (all_pvs_removable) {
+			if (_is_mirror_image_removable(sub_lv, removable_pvs)) {
 				/* Swap segment to end */
 				new_area_count--;
 				area = mirrored_seg->areas[new_area_count];


