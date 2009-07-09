From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jul 2009 11:28:10 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20090709112810.24684.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-07-09 11:28:10

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Fix segment import functions to print segment name and logical volume name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1170&r2=1.1171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/WHATS_NEW	2009/07/09 10:19:07	1.1170
+++ LVM2/WHATS_NEW	2009/07/09 11:28:09	1.1171
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Fix segment import functions to print segment name and logical volume name.
   Update vgsplit and vgcreate to call the new vg_create, then call 'set' fns.
   Change vg_create to take minimal parameters, obtain a lock, and return vg_t.
   Refactor vgchange extent_size, max_lv, max_pv, and alloc_policy for liblvm.
--- LVM2/lib/format_text/import_vsn1.c	2009/05/13 21:25:02	1.61
+++ LVM2/lib/format_text/import_vsn1.c	2009/07/09 11:28:10	1.62
@@ -293,32 +293,32 @@
 {
 	uint32_t area_count = 0u;
 	struct lv_segment *seg;
-	struct config_node *cn;
+	struct config_node *cn, *sn_child = sn->child;
 	struct config_value *cv;
 	uint32_t start_extent, extent_count;
 	struct segment_type *segtype;
 	const char *segtype_str;
 
-	if (!(sn = sn->child)) {
+	if (!sn_child) {
 		log_error("Empty segment section.");
 		return 0;
 	}
 
-	if (!_read_int32(sn, "start_extent", &start_extent)) {
-		log_error("Couldn't read 'start_extent' for segment '%s'.",
-			  sn->key);
+	if (!_read_int32(sn_child, "start_extent", &start_extent)) {
+		log_error("Couldn't read 'start_extent' for segment '%s' "
+			  "of logical volume %s.", sn->key, lv->name);
 		return 0;
 	}
 
-	if (!_read_int32(sn, "extent_count", &extent_count)) {
-		log_error("Couldn't read 'extent_count' for segment '%s'.",
-			  sn->key);
+	if (!_read_int32(sn_child, "extent_count", &extent_count)) {
+		log_error("Couldn't read 'extent_count' for segment '%s' "
+			  "of logical volume %s.", sn->key, lv->name);
 		return 0;
 	}
 
 	segtype_str = "striped";
 
-	if ((cn = find_config_node(sn, "type"))) {
+	if ((cn = find_config_node(sn_child, "type"))) {
 		cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("Segment type must be a string.");
@@ -331,7 +331,7 @@
 		return_0;
 
 	if (segtype->ops->text_import_area_count &&
-	    !segtype->ops->text_import_area_count(sn, &area_count))
+	    !segtype->ops->text_import_area_count(sn_child, &area_count))
 		return_0;
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
@@ -342,11 +342,11 @@
 	}
 
 	if (seg->segtype->ops->text_import &&
-	    !seg->segtype->ops->text_import(seg, sn, pv_hash))
+	    !seg->segtype->ops->text_import(seg, sn_child, pv_hash))
 		return_0;
 
 	/* Optional tags */
-	if ((cn = find_config_node(sn, "tags")) &&
+	if ((cn = find_config_node(sn_child, "tags")) &&
 	    !(read_tags(mem, &seg->tags, cn->v))) {
 		log_error("Couldn't read tags for a segment of %s/%s.",
 			  vg->name, lv->name);
@@ -463,13 +463,14 @@
 	}
 
 	if (!_read_int32(lvn, "segment_count", &seg_count)) {
-		log_error("Couldn't read segment count for logical volume.");
+		log_error("Couldn't read segment count for logical volume %s.",
+			  lv->name);
 		return 0;
 	}
 
 	if (seg_count != count) {
 		log_error("segment_count and actual number of segments "
-			  "disagree.");
+			  "disagree for logical volume %s.", lv->name);
 		return 0;
 	}
 


