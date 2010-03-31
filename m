From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 31 Mar 2010 17:22:26 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/pv_alloc.h lib/m ...
Message-ID: <20100331172226.501.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-31 17:22:26

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : pv_alloc.h pv_manip.c 

Log message:
	Do not traverse PV segment list twice.
	
	In addition to previous patch, we really do not need
	to search for segment which was just allocated in
	split request.
	
	Make pv_split_segment function return newly allocated
	(split) segment also.
	
	(So after this patch, there is only one user
	of slow find_peg_by_pe).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1495&r2=1.1496
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_alloc.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2010/03/31 17:21:40	1.1495
+++ LVM2/WHATS_NEW	2010/03/31 17:22:26	1.1496
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Return newly allocated PV segment after segment split.
   Optimise PV segments search for the most last segment search case.
   Remove vg_validate call when parsing cached metadata.
   Use hash table of LVs to speed up parsing of text metadata with many LVs.
--- LVM2/lib/metadata/pv_alloc.h	2008/11/03 22:14:29	1.7
+++ LVM2/lib/metadata/pv_alloc.h	2010/03/31 17:22:26	1.8
@@ -20,7 +20,8 @@
 				       uint32_t area_len,
 				       struct lv_segment *seg,
 				       uint32_t area_num);
-int pv_split_segment(struct physical_volume *pv, uint32_t pe);
+int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+		     struct pv_segment **pvseg_allocated);
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction);
 int check_pv_segments(struct volume_group *vg);
 void merge_pv_segments(struct pv_segment *peg1, struct pv_segment *peg2);
--- LVM2/lib/metadata/pv_manip.c	2010/03/31 17:21:40	1.23
+++ LVM2/lib/metadata/pv_manip.c	2010/03/31 17:22:26	1.24
@@ -94,17 +94,18 @@
 
 /*
  * Split peg at given extent.
- * Second part is always deallocated.
+ * Second part is always not allocated to a LV and returned.
  */
-static int _pv_split_segment(struct physical_volume *pv, struct pv_segment *peg,
-			     uint32_t pe)
+static struct pv_segment *_pv_split_segment(struct physical_volume *pv,
+					    struct pv_segment *peg,
+					    uint32_t pe)
 {
 	struct pv_segment *peg_new;
 
 	if (!(peg_new = _alloc_pv_segment(pv->fmt->cmd->mem, peg->pv, pe,
 					  peg->len + peg->pe - pe,
 					  NULL, 0)))
-		return_0;
+		return_NULL;
 
 	peg->len = peg->len - peg_new->len;
 
@@ -115,31 +116,37 @@
 		peg->lvseg->lv->vg->free_count += peg_new->len;
 	}
 
-	return 1;
+	return peg_new;
 }
 
 /*
  * Ensure there is a PV segment boundary at the given extent.
  */
-int pv_split_segment(struct physical_volume *pv, uint32_t pe)
+int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+		     struct pv_segment **pvseg_allocated)
 {
-	struct pv_segment *peg;
+	struct pv_segment *pvseg, *pvseg_new = NULL;
 
 	if (pe == pv->pe_count)
-		return 1;
+		goto out;
 
-	if (!(peg = find_peg_by_pe(pv, pe))) {
+	if (!(pvseg = find_peg_by_pe(pv, pe))) {
 		log_error("Segment with extent %" PRIu32 " in PV %s not found",
 			  pe, pv_dev_name(pv));
 		return 0;
 	}
 
 	/* This is a peg start already */
-	if (pe == peg->pe)
-		return 1;
+	if (pe == pvseg->pe) {
+		pvseg_new = pvseg;
+		goto out;
+	}
 
-	if (!_pv_split_segment(pv, peg, pe))
+	if (!(pvseg_new = _pv_split_segment(pv, pvseg, pe)))
 		return_0;
+out:
+	if (pvseg_allocated)
+		*pvseg_allocated = pvseg_new;
 
 	return 1;
 }
@@ -154,17 +161,17 @@
 				       struct lv_segment *seg,
 				       uint32_t area_num)
 {
-	struct pv_segment *peg;
+	struct pv_segment *peg = NULL;
 
 	/* Missing format1 PV */
 	if (!pv)
 		return &null_pv_segment;
 
-	if (!pv_split_segment(pv, pe) ||
-	    !pv_split_segment(pv, pe + area_len))
+	if (!pv_split_segment(pv, pe, &peg) ||
+	    !pv_split_segment(pv, pe + area_len, NULL))
 		return_NULL;
 
-	if (!(peg = find_peg_by_pe(pv, pe))) {
+	if (!peg) {
 		log_error("Missing PV segment on %s at %u.",
 			  pv_dev_name(pv), pe);
 		return NULL;
@@ -200,7 +207,7 @@
 	}
 
 	if (!pv_split_segment(peg->pv, peg->pe + peg->lvseg->area_len -
-				       area_reduction))
+				       area_reduction, NULL))
 		return_0;
 
 	return 1;
@@ -373,7 +380,7 @@
 		}
 	}
 
-	if (!pv_split_segment(pv, new_pe_count))
+	if (!pv_split_segment(pv, new_pe_count, NULL))
 		return_0;
 
 	dm_list_iterate_items_safe(peg, pegt, &pv->segments) {


