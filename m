From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 8 Oct 2009 16:19:27 -0500
Subject: [PATCH 7 of 10] LVM: add needed params
Message-ID: <200910082119.n98LJRvb014652@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-needed-params.patch

Here we add a couple necessary parameters to functions so
that we can distinguish between when we are allocating
from log_areas or alloced_areas

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -909,7 +909,8 @@ int reconfigure_mirror_images(struct lv_
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,
 			      struct logical_volume *lv,
-			      struct logical_volume **img_lvs)
+			      struct logical_volume **img_lvs,
+			      int for_log)
 {
 	uint32_t m;
 	char *img_name;
@@ -940,7 +941,7 @@ static int _create_mimage_lvs(struct all
 		if (!lv_add_segment(ah, m, 1, img_lvs[m],
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    0, 0, 0, NULL)) {
+				    0, 0, 0, for_log ? lv : NULL)) {
 			log_error("Aborting. Failed to add mirror image segment "
 				  "to %s. Remove new LV and retry.",
 				  img_lvs[m]->name);
@@ -1290,7 +1291,7 @@ static struct logical_volume *_create_mi
  */
 static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 			struct logical_volume *lv,
-			uint32_t mirrors, uint32_t region_size)
+			uint32_t mirrors, uint32_t region_size, int for_log)
 {
 	struct logical_volume **img_lvs;
 
@@ -1311,7 +1312,7 @@ static int _form_mirror(struct cmd_conte
 		return 0;
 	}
 
-	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs, for_log))
 		return 0;
 
 	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
@@ -1513,7 +1514,7 @@ int add_mirror_images(struct cmd_context
 	   So from here on, if failure occurs, the log must be explicitly
 	   removed and the updated vg metadata should be committed. */
 
-	if (!_form_mirror(cmd, ah, lv, mirrors, region_size))
+	if (!_form_mirror(cmd, ah, lv, mirrors, region_size, 0))
 		goto out_remove_log;
 
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))


