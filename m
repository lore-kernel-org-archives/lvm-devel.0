From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 5 Mar 2010 17:58:39 -0600
Subject: [PATCH 4 of 10] LVM: hack to make things work
Message-ID: <201003052358.o25NwdmQ012282@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-hack-to-make-things-work.patch

This patch is somewhat of a hack to put the various pieces
together.

Although the changes to lv_add_log_segment are clever, they
don't create the mirror in the right way (more like what
pvmove needs, and not like what a LV mirror needs).

Other changes to get functions to pull areas from the end
of the list when creating the log.

RFC:
Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -1363,8 +1363,11 @@ int lv_add_segment(struct alloc_handle *
 		   const struct segment_type *segtype,
 		   uint32_t stripe_size,
 		   uint64_t status,
-		   uint32_t region_size)
+		   uint32_t region_size,
+		   int reverse)
 {
+	uint32_t fa = first_area;
+
 	if (!segtype) {
 		log_error("Missing segtype in lv_add_segment().");
 		return 0;
@@ -1380,7 +1383,14 @@ int lv_add_segment(struct alloc_handle *
 		return 0;
 	}
 
-	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
+	if (reverse)
+		fa = (ah->area_count + ah->log_area_count - 1) - first_area;
+
+	/* 'fa' is unsigned, so check if too large (invalid). */
+	if (fa >= (ah->area_count + ah->log_area_count))
+		return 0;
+
+	if (!_setup_alloced_segments(lv, &ah->alloced_areas[fa],
 				     num_areas, status,
 				     stripe_size, segtype,
 				     region_size))
@@ -1559,11 +1569,14 @@ int lv_add_mirror_lvs(struct logical_vol
  */
 int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
 {
-	const char *segtype_name = ah->log_area_count > 1 ? "mirror" : "striped";
-
-	return lv_add_segment(ah, ah->area_count, ah->log_area_count, log_lv,
-			      get_segtype_from_string(log_lv->vg->cmd, segtype_name),
-			      0, MIRROR_LOG, 0);
+	/*
+	 * We specify the first area as starting after the areas
+	 * allocated for the mirror.
+	 */
+	return lv_add_segment(ah, ah->area_count, 1, log_lv,
+			      get_segtype_from_string(log_lv->vg->cmd,
+						      "striped"),
+			      0, MIRROR_LOG, 0, 0);
 }
 
 static int _lv_extend_mirror(struct alloc_handle *ah,
@@ -1585,7 +1598,7 @@ static int _lv_extend_mirror(struct allo
 		if (!lv_add_segment(ah, m++, 1, seg_lv(seg, s),
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    0, 0, 0)) {
+				    0, 0, 0, 0)) {
 			log_error("Aborting. Failed to extend %s.",
 				  seg_lv(seg, s)->name);
 			return 0;
@@ -1623,7 +1636,7 @@ int lv_extend(struct logical_volume *lv,
 
 	if (mirrors < 2)
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
-				   stripe_size, status, 0);
+				   stripe_size, status, 0, 0);
 	else
 		r = _lv_extend_mirror(ah, lv, extents, 0);
 
Index: LVM2/lib/metadata/lv_alloc.h
===================================================================
--- LVM2.orig/lib/metadata/lv_alloc.h
+++ LVM2/lib/metadata/lv_alloc.h
@@ -58,7 +58,8 @@ int lv_add_segment(struct alloc_handle *
                    const struct segment_type *segtype,
                    uint32_t stripe_size,
                    uint64_t status,
-		   uint32_t region_size);
+		   uint32_t region_size,
+		   int reverse);
 
 int lv_add_mirror_areas(struct alloc_handle *ah,
 			struct logical_volume *lv, uint32_t le,
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1171,7 +1171,8 @@ int reconfigure_mirror_images(struct lv_
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,
 			      struct logical_volume *lv,
-			      struct logical_volume **img_lvs)
+			      struct logical_volume **img_lvs,
+			      int log)
 {
 	uint32_t m;
 	char *img_name;
@@ -1202,7 +1203,7 @@ static int _create_mimage_lvs(struct all
 		if (!lv_add_segment(ah, m, 1, img_lvs[m],
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    0, 0, 0)) {
+				    0, 0, 0, log)) {
 			log_error("Aborting. Failed to add mirror image segment "
 				  "to %s. Remove new LV and retry.",
 				  img_lvs[m]->name);
@@ -1552,7 +1553,7 @@ static struct logical_volume *_create_mi
  */
 static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 			struct logical_volume *lv,
-			uint32_t mirrors, uint32_t region_size)
+			uint32_t mirrors, uint32_t region_size, int log)
 {
 	struct logical_volume **img_lvs;
 
@@ -1573,7 +1574,7 @@ static int _form_mirror(struct cmd_conte
 		return 0;
 	}
 
-	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs, log))
 		return 0;
 
 	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
@@ -1636,7 +1637,7 @@ static struct logical_volume *_set_up_mi
 	}
 
 	if ((log_count > 1) &&
-	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size)) {
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size, 1)) {
 		log_error("Failed to form mirrored log.");
 		return NULL;
 	}
@@ -1781,7 +1782,7 @@ int add_mirror_images(struct cmd_context
 	   So from here on, if failure occurs, the log must be explicitly
 	   removed and the updated vg metadata should be committed. */
 
-	if (!_form_mirror(cmd, ah, lv, mirrors, region_size))
+	if (!_form_mirror(cmd, ah, lv, mirrors, region_size, 0))
 		goto out_remove_log;
 
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))


