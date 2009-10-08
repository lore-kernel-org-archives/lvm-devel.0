From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 8 Oct 2009 16:19:17 -0500
Subject: [PATCH 6 of 10] LVM: allow lv_add_segment to use log_areas
Message-ID: <200910082119.n98LJHcx014579@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-allow-lv_add_segment-to-use-log_areas.patch

Use the (so far unused) parameter 'log_lv' to determine
whether or not to allocate from 'alloced_areas' or
'log_areas'.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -1386,6 +1386,18 @@ int lv_add_segment(struct alloc_handle *
 		   uint32_t region_size,
 		   struct logical_volume *log_lv)
 {
+	int i;
+	struct dm_list *aa_list;
+
+	/*
+	 * We don't actually use the 'log_lv' parameter for anything more
+	 * than just figuring out that this allocation is for a log device
+	 * It'd be nice to change the arguments type, but the function is
+	 * exported.
+	 */
+	aa_list = (log_lv) ? &ah->log_areas :
+		&ah->alloced_areas[first_area];
+
 	if (!segtype) {
 		log_error("Missing segtype in lv_add_segment().");
 		return 0;
@@ -1396,10 +1408,8 @@ int lv_add_segment(struct alloc_handle *
 		return 0;
 	}
 
-	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
-				     num_areas, status,
-				     stripe_size, segtype,
-				     region_size))
+	if (!_setup_alloced_segments(lv, aa_list, num_areas, status,
+				     stripe_size, segtype, region_size))
 		return_0;
 
 	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {


