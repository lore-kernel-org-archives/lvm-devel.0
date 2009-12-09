From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 19:43:39 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20091209194339.28299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 19:43:39

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Use more descriptive variable name for temporary layer lv.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/lib/metadata/mirror.c	2009/12/09 18:09:52	1.97
+++ LVM2/lib/metadata/mirror.c	2009/12/09 19:43:39	1.98
@@ -502,7 +502,7 @@
 	uint32_t s;
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
-	struct logical_volume *lv1 = NULL;
+	struct logical_volume *temp_layer_lv = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
@@ -561,11 +561,11 @@
 	 * leave the LV as mirrored and let the lvconvert completion
 	 * to remove the layer. */
 	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
-		lv1 = seg_lv(mirrored_seg, 0);
-		lv1->status &= ~MIRROR_IMAGE;
-		lv_set_visible(lv1);
+		temp_layer_lv = seg_lv(mirrored_seg, 0);
+		temp_layer_lv->status &= ~MIRROR_IMAGE;
+		lv_set_visible(temp_layer_lv);
 		detached_log_lv = detach_mirror_log(mirrored_seg);
-		if (!remove_layer_from_lv(lv, lv1))
+		if (!remove_layer_from_lv(lv, temp_layer_lv))
 			return_0;
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
@@ -616,9 +616,9 @@
 	 * As it's now detached from mirrored_seg->lv we must resume it
 	 * explicitly.
 	 */
-	if (lv1) {
-		if (!resume_lv(lv1->vg->cmd, lv1)) {
-			log_error("Problem resuming temporary LV, %s", lv1->name);
+	if (temp_layer_lv) {
+		if (!resume_lv(temp_layer_lv->vg->cmd, temp_layer_lv)) {
+			log_error("Problem resuming temporary LV, %s", temp_layer_lv->name);
 			return 0;
 		}
 
@@ -647,7 +647,7 @@
 				return_0;
 	}
 
-	if (lv1 && !_delete_lv(lv, lv1))
+	if (temp_layer_lv && !_delete_lv(lv, temp_layer_lv))
 		return_0;
 
 	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))


