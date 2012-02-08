From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 13:05:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20120208130540.1581.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 13:05:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata.h thin_manip.c 

Log message:
	Thin add pool_below_threshold
	
	Test both data and metadata percent usage.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2272&r2=1.2273
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.357&r2=1.358
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.265&r2=1.266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2012/02/08 13:02:07	1.2272
+++ LVM2/WHATS_NEW	2012/02/08 13:05:38	1.2273
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Add pool_below_threshold() function to check thin pool percent status.
   Fix test for snap percent for failing merge when removing LV.
   Switch int to void return for str_list_del().
   Fix error path handling in _build_desc().
--- LVM2/lib/metadata/lv_manip.c	2012/02/08 13:02:07	1.357
+++ LVM2/lib/metadata/lv_manip.c	2012/02/08 13:05:39	1.358
@@ -4054,7 +4054,6 @@
 	struct logical_volume *lv, *org = NULL;
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
-	percent_t percent;
 	int origin_active = 0;
 	struct lvinfo info;
 
@@ -4375,26 +4374,20 @@
 	if (seg_is_thin(lp)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org)) {
-			/* Check if the pool is bellow threshold (Works only for active thin) */
-			if (!lv_thin_pool_percent(first_seg(org)->pool_lv, 0, &percent)) {
-				stack;
-				goto revert_new_lv;
-			}
-			percent /= PERCENT_1;
-			if (percent >= (find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
-							     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD))) {
-				log_error("Failed to create snapshot, pool is filled over "
-					  "the autoextend threshold (%d%%).", percent);
+			if (!pool_below_threshold(first_seg(first_seg(org)->pool_lv))) {
+				log_error("Cannot create thin snapshot. Pool %s/%s is filled "
+					  "over the autoextend threshold.",
+					  org->vg->name, first_seg(org)->pool_lv->name);
 				goto revert_new_lv;
 			}
 			if (!suspend_lv_origin(cmd, org)) {
-				log_error("Failed to suspend thin snapshot origin %s.",
-					  org->name);
+				log_error("Failed to suspend thin snapshot origin %s/%s.",
+					  org->vg->name, org->name);
 				goto revert_new_lv;
 			}
 			if (!resume_lv_origin(cmd, org)) { /* deptree updates thin-pool */
-				log_error("Failed to resume thin snapshot origin %s.",
-					  org->name);
+				log_error("Failed to resume thin snapshot origin %s/%s.",
+					  org->vg->name, org->name);
 				goto revert_new_lv;
 			}
 			/* At this point remove pool messages, snapshot is active */
--- LVM2/lib/metadata/metadata.h	2012/01/25 08:55:19	1.265
+++ LVM2/lib/metadata/metadata.h	2012/02/08 13:05:39	1.266
@@ -464,6 +464,7 @@
 			int auto_increment);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
+int pool_below_threshold(const struct lv_segment *pool_seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
--- LVM2/lib/metadata/thin_manip.c	2012/01/25 09:17:15	1.32
+++ LVM2/lib/metadata/thin_manip.c	2012/02/08 13:05:39	1.33
@@ -19,6 +19,7 @@
 #include "segtype.h"
 #include "lv_alloc.h"
 #include "archiver.h"
+#include "defaults.h"
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume *metadata_lv)
 {
@@ -215,6 +216,35 @@
 	return 0;
 }
 
+int pool_below_threshold(const struct lv_segment *pool_seg)
+{
+	percent_t percent;
+	int threshold = PERCENT_1 *
+		find_config_tree_int(pool_seg->lv->vg->cmd,
+				     "activation/thin_pool_autoextend_threshold",
+				     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD);
+
+	/* Data */
+	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent)) {
+		stack;
+		return 0;
+	}
+
+	if (percent >= threshold)
+		return 0;
+
+	/* Metadata */
+	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent)) {
+		stack;
+		return 0;
+	}
+
+	if (percent >= threshold)
+		return 0;
+
+	return 1;
+}
+
 struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
 	struct lv_segment *pool_seg;


