From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 19 Jan 2010 20:21:56 -0600
Subject: [PATCH 4 of 10] LVM: subdivide mirror creation function
Message-ID: <201001200221.o0K2LuAE024039@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-subdivide-mirror-creation-function.patch

Here we carve out a portion of the 'add_mirror_images'
function that will be useful in more than one place
later.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1547,6 +1547,46 @@ static struct logical_volume *_create_mi
 	return log_lv;
 }
 
+/*
+ * Returns: 1 on success, 0 on error
+ */
+static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
+			struct logical_volume *lv,
+			uint32_t mirrors, uint32_t region_size)
+{
+	struct logical_volume **img_lvs;
+
+	/*
+	 * insert a mirror layer
+	 */
+	if (dm_list_size(&lv->segments) != 1 ||
+	    seg_type(first_seg(lv), 0) != AREA_LV)
+		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
+			return 0;
+
+	/*
+	 * create mirror image LVs
+	 */
+	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
+		log_error("img_lvs allocation failed. "
+			  "Remove new LV and retry.");
+		return 0;
+	}
+
+	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+		return 0;
+
+	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
+			       MIRROR_IMAGE | (lv->status & LOCKED),
+			       region_size)) {
+		log_error("Aborting. Failed to add mirror segment. "
+			  "Remove new LV and retry.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
@@ -1696,7 +1736,6 @@ int add_mirror_images(struct cmd_context
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
-	struct logical_volume **img_lvs;
 	struct logical_volume *log_lv = NULL;
 
 	if (stripes > 1) {
@@ -1736,34 +1775,9 @@ int add_mirror_images(struct cmd_context
 	   So from here on, if failure occurs, the log must be explicitly
 	   removed and the updated vg metadata should be committed. */
 
-	/*
-	 * insert a mirror layer
-	 */
-	if (dm_list_size(&lv->segments) != 1 ||
-	    seg_type(first_seg(lv), 0) != AREA_LV)
-		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
-			goto out_remove_log;
-
-	/*
-	 * create mirror image LVs
-	 */
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
-		log_error("img_lvs allocation failed. "
-			  "Remove new LV and retry.");
-		goto out_remove_log;
-	}
-
-	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+	if (!_form_mirror(cmd, ah, lv, mirrors, region_size))
 		goto out_remove_log;
 
-	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
-			       MIRROR_IMAGE | (lv->status & LOCKED),
-			       region_size)) {
-		log_error("Aborting. Failed to add mirror segment. "
-			  "Remove new LV and retry.");
-		goto out_remove_images;
-	}
-
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))
 		stack;
 


