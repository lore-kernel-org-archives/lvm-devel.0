From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 18 Mar 2010 15:53:37 -0500
Subject: [PATCH 5 of 12] LVM: add logic to allow mirrored log
Message-ID: <201003182053.o2IKrbIj024676@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-logic-to-allow-mirrored-log.patch

Insert the couple of lines that adds the logic necessary to
create the mirrored log.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1591,7 +1591,7 @@ static struct logical_volume *_set_up_mi
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
 						 uint32_t log_count,
-						 uint32_t region_size __attribute((unused)),
+						 uint32_t region_size,
 						 alloc_policy_t alloc,
 						 int in_sync)
 {
@@ -1635,6 +1635,12 @@ static struct logical_volume *_set_up_mi
 		return NULL;
 	}
 
+	if ((log_count > 1) &&
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size)) {
+		log_error("Failed to form mirrored log.");
+		return NULL;
+	}
+
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to initialise mirror log.");
 		return NULL;
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -647,9 +647,24 @@ static void _lvconvert_mirrors_repair_as
 	}
 }
 
-static int _using_corelog(struct logical_volume *lv)
+/*
+ * _get_log_count
+ * @lv: the mirror LV
+ *
+ * Get the number of on-disk copies of the log.
+ *  0  = 'core'
+ *  1  = 'disk'
+ *  2+ = 'mirrored'
+ */
+static int _get_log_count(struct logical_volume *lv)
 {
-	return !first_seg(_original_lv(lv))->log_lv;
+	struct logical_volume *log_lv;
+
+	log_lv = first_seg(_original_lv(lv))->log_lv;
+	if (!log_lv)
+		return 0;
+
+	return lv_mirror_count(log_lv);
 }
 
 static int _lv_update_log_type(struct cmd_context *cmd,
@@ -657,21 +672,47 @@ static int _lv_update_log_type(struct cm
 			       struct logical_volume *lv,
 			       int log_count)
 {
-	struct logical_volume *original_lv = _original_lv(lv);
-	if (_using_corelog(lv) && log_count) {
+	uint32_t region_size;
+	int old_log_count;
+	struct logical_volume *original_lv;
+	struct logical_volume *log_lv;
+
+	old_log_count = _get_log_count(lv);
+	if (old_log_count == log_count)
+		return 1;
+
+	original_lv = _original_lv(lv);
+	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+						  lv->le_count,
+						  lp->region_size);
+
+	/* Add a log where there is none */
+	if (!old_log_count) {
 		if (!add_mirror_log(cmd, original_lv, log_count,
-				    adjusted_mirror_region_size(
-					lv->vg->extent_size,
-					lv->le_count,
-					lp->region_size),
-				    lp->pvh, lp->alloc))
+				    region_size, lp->pvh, lp->alloc))
 			return_0;
-	} else if (!_using_corelog(lv) && !log_count) {
+		return 1;
+	}
+
+	/* Remove an existing log completely */
+	if (!log_count) {
 		if (!remove_mirror_log(cmd, original_lv,
 				       lp->pv_count ? lp->pvh : NULL))
 			return_0;
+		return 1;
+	}
+
+	log_lv = first_seg(original_lv)->log_lv;
+
+	/* Adding redundancy to the log */
+	if (old_log_count < log_count) {
+		log_error("Adding log redundancy not supported yet.");
+		log_error("Try converting the log to 'core' first.");
+		return_0;
 	}
-	return 1;
+
+	/* Reducing redundancy of the log */
+	return remove_mirror_images(log_lv, log_count, lp->pvh, 1U);
 }
 
 /*
@@ -718,7 +759,7 @@ static int _lvconvert_mirrors(struct cmd
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
 	const char *mirrorlog;
-	unsigned log_count = 1;
+	unsigned log_count = _get_log_count(lv);
 	int r = 0;
 	struct logical_volume *log_lv, *layer_lv;
 	int failed_mirrors = 0, failed_log = 0;
@@ -776,8 +817,7 @@ static int _lvconvert_mirrors(struct cmd
 	if ((existing_mirrors > 1) && (lp->mirrors > 1) &&
 	    (lp->mirrors != existing_mirrors) && !(lv->status & CONVERTING) &&
 	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
-		log_count = (first_seg(lv)->log_lv) ?
-			lv_mirror_count(first_seg(lv)->log_lv) : 0;
+		log_count = _get_log_count(lv);
 	}
 
 	if (repair) {
@@ -798,9 +838,18 @@ static int _lvconvert_mirrors(struct cmd
 			return_0;
 		lp->pvh = lp->failed_pvs = failed_pvs;
 		log_lv = first_seg(lv)->log_lv;
-		if (!log_lv || log_lv->status & PARTIAL_LV) {
+		if (!log_lv) {
 			failed_log = 1;
 			log_count = 0;
+		} else {
+			log_count = lv_mirror_count(log_lv);
+			if (log_lv->status & PARTIAL_LV) {
+				failed_log = 1;
+				if (log_lv->status & MIRRORED)
+					log_count -= _failed_mirrors_count(log_lv);
+				else
+					log_count = 0;
+			}
 		}
 	} else {
 		/*
@@ -992,7 +1041,7 @@ static int _lvconvert_mirrors(struct cmd
 	}
 
 	if (lp->mirrors == existing_mirrors) {
-		if (_using_corelog(lv) != !log_count) {
+		if (_get_log_count(lv) != log_count) {
 			if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
 				stack;
 				return failure_code;


