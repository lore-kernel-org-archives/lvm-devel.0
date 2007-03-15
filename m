From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Mar 2007 13:38:29 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-extents.c
Message-ID: <20070315133829.5607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-15 13:38:28

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-extents.c 

Log message:
	Try to fix reading in of lvm1 striped LVs.
	There are two fixes other than improving variable names and updating code
	layout etc.
	The loop counter is incremented by area_len instead of area_len * stripes;
	the 3rd _check_stripe parameter is no longer multiplied by number of stripes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.585&r2=1.586
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2007/03/13 14:59:21	1.585
+++ LVM2/WHATS_NEW	2007/03/15 13:38:27	1.586
@@ -1,9 +1,9 @@
 Version 2.02.24 -
 ====================================
+  Fix reading of striped LVs in LVM1 format.
+  Flag nolocking as clustered so clvmd startup sees clustered LVs. (2.02.10)
   Add a few missing pieces of vgname command line validation.
   Support the /dev/mapper prefix on most command lines.
-  Flag nolocking as a clustered locking module as we need to be able
-    to look at clustered LVs at clvmd startup (2.02.10)
 
 Version 2.02.23 - 8th March 2007
 ================================
--- LVM2/lib/format1/import-extents.c	2006/05/09 21:23:50	1.31
+++ LVM2/lib/format1/import-extents.c	2007/03/15 13:38:28	1.32
@@ -203,6 +203,19 @@
 	return 1;
 }
 
+static uint32_t _area_length(struct lv_map *lvm, uint32_t le)
+{
+	uint32_t len = 0;
+
+	do
+		len++;
+	while ((lvm->map[le + len].pv == lvm->map[le].pv) &&
+		 (lvm->map[le].pv &&
+		  lvm->map[le + len].pe == lvm->map[le].pe + len));
+
+	return len;
+}
+
 static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
 {
 	uint32_t le = 0, len;
@@ -215,13 +228,7 @@
 	}
 
 	while (le < lvm->lv->le_count) {
-		len = 0;
-
-		do
-			len++;
-		while ((lvm->map[le + len].pv == lvm->map[le].pv) &&
-			 (lvm->map[le].pv &&
-			  lvm->map[le + len].pe == lvm->map[le].pe + len));
+		len = _area_length(lvm, le);
 
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv, le,
 					     len, 0, 0, NULL, 1, len, 0, 0, 0))) {
@@ -230,10 +237,8 @@
 		}
 
 		if (!set_lv_segment_area_pv(seg, 0, lvm->map[le].pv,
-					    lvm->map[le].pe)) {
-			stack;
-			return 0;
-		}
+					    lvm->map[le].pe))
+			return_0;
 
 		list_add(&lvm->lv->segments, &seg->list);
 
@@ -244,7 +249,8 @@
 }
 
 static int _check_stripe(struct lv_map *lvm, uint32_t area_count,
-			 uint32_t seg_len, uint32_t base_le, uint32_t len)
+			 uint32_t area_len, uint32_t base_le,
+			 uint32_t total_area_len)
 {
 	uint32_t st;
 
@@ -252,11 +258,11 @@
 	 * Is the next physical extent in every stripe adjacent to the last?
 	 */
 	for (st = 0; st < area_count; st++)
-		if ((lvm->map[base_le + st * len + seg_len].pv !=
-		     lvm->map[base_le + st * len].pv) ||
-		    (lvm->map[base_le + st * len].pv &&
-		     lvm->map[base_le + st * len + seg_len].pe !=
-		     lvm->map[base_le + st * len].pe + seg_len))
+		if ((lvm->map[base_le + st * total_area_len + area_len].pv !=
+		     lvm->map[base_le + st * total_area_len].pv) ||
+		    (lvm->map[base_le + st * total_area_len].pv &&
+		     lvm->map[base_le + st * total_area_len + area_len].pe !=
+		     lvm->map[base_le + st * total_area_len].pe + area_len))
 			return 0;
 
 	return 1;
@@ -264,7 +270,7 @@
 
 static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 {
-	uint32_t st, le = 0, len;
+	uint32_t st, first_area_le = 0, total_area_len;
 	uint32_t area_len;
 	struct lv_segment *seg;
 	struct segment_type *segtype;
@@ -277,26 +283,25 @@
 			  "with logical extent count (%u) for %s",
 			  lvm->stripes, lvm->lv->le_count, lvm->lv->name);
 	}
-	len = lvm->lv->le_count / lvm->stripes;
 
-	if (!(segtype = get_segtype_from_string(cmd, "striped"))) {
-		stack;
-		return 0;
-	}
+	total_area_len = lvm->lv->le_count / lvm->stripes;
+
+	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+		return_0;
 
-	while (le < len) {
+	while (first_area_le < total_area_len) {
 		area_len = 1;
 
 		/* 
-		 * Find how many blocks are contiguous in all stripes
+		 * Find how many extents are contiguous in all stripes
 		 * and so can form part of this segment
 		 */
 		while (_check_stripe(lvm, lvm->stripes,
-				     area_len * lvm->stripes, le, len))
+				     area_len, first_area_le, total_area_len))
 			area_len++;
 
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv,
-					     lvm->stripes * le,
+					     lvm->stripes * first_area_le,
 					     lvm->stripes * area_len,
 					     0, lvm->stripe_size, NULL,
 					     lvm->stripes,
@@ -310,15 +315,13 @@
 		 */
 		for (st = 0; st < seg->area_count; st++)
 			if (!set_lv_segment_area_pv(seg, st,
-						    lvm->map[le + st * len].pv,
-						    lvm->map[le + st * len].pe)) {
-				stack;
-				return 0;
-			}
+			      lvm->map[first_area_le + st * total_area_len].pv,
+			      lvm->map[first_area_le + st * total_area_len].pe))
+				return_0;
 
 		list_add(&lvm->lv->segments, &seg->list);
 
-		le += seg->len;
+		first_area_le += area_len;
 	}
 
 	return 1;


