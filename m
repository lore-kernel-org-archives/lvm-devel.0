From: agk@sourceware.org <agk@sourceware.org>
Date: 30 May 2009 00:09:28 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20090530000928.27226.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-30 00:09:27

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Handle multi-extent mirror log allocation when smallest PV has only 1 extent.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1133&r2=1.1134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178

--- LVM2/WHATS_NEW	2009/05/29 18:34:10	1.1133
+++ LVM2/WHATS_NEW	2009/05/30 00:09:27	1.1134
@@ -1,6 +1,7 @@
 Version 2.02.48 - 
 ===============================
-  Fix rpmlint in clvmd initscript
+  Handle multi-extent mirror log allocation when smallest PV has only 1 extent.
+  Add LSB standard headers and functions (incl. reload) to clvmd initscript.
   When creating new LV, double-check that name is not already in use.
   Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.
   Rename internal vorigin LV to match visible LV.
--- LVM2/lib/metadata/lv_manip.c	2009/05/28 01:59:37	1.177
+++ LVM2/lib/metadata/lv_manip.c	2009/05/30 00:09:27	1.178
@@ -728,7 +728,8 @@
  */
 static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t needed,
 				struct pv_area **areas,
-				uint32_t *ix, struct pv_area *log_area)
+				uint32_t *ix, struct pv_area *log_area,
+				uint32_t log_len)
 {
 	uint32_t area_len, remaining;
 	uint32_t s;
@@ -763,9 +764,7 @@
 	if (log_area) {
 		ah->log_area.pv = log_area->map->pv;
 		ah->log_area.pe = log_area->start;
-		ah->log_area.len = mirror_log_extents(ah->log_region_size,
-						      pv_pe_size(log_area->map->pv),
-						      area_len);
+		ah->log_area.len = log_len;
 		consume_pv_area(log_area, ah->log_area.len);
 	}
 
@@ -990,11 +989,15 @@
 	unsigned contiguous = 0, cling = 0, preferred_count = 0;
 	unsigned ix;
 	unsigned ix_offset = 0;	/* Offset for non-preferred allocations */
+	unsigned too_small_for_log_count; /* How many too small for log? */
 	uint32_t max_parallel;	/* Maximum extents to allocate */
 	uint32_t next_le;
 	struct seg_pvs *spvs;
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
+	uint32_t log_len;
+	struct pv_area *log_area;
+	unsigned log_needs_allocating;
 
 	/* Is there enough total space? */
 	free_pes = pv_maps_size(pvms);
@@ -1121,25 +1124,49 @@
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
-		/* Only allocate log_area the first time around */
-		if (ix + ix_offset < ah->area_count +
-			    ((ah->log_count && !ah->log_area.len) ?
-				ah->log_count : 0))
-			/* FIXME With ALLOC_ANYWHERE, need to split areas */
-			break;
-
 		/* sort the areas so we allocate from the biggest */
 		if (ix > 1)
 			qsort(areas + ix_offset, ix, sizeof(*areas),
 			      _comp_area);
 
-		/* First time around, use smallest area as log_area */
-		/* FIXME decide which PV to use at top of function instead */
-		if (!_alloc_parallel_area(ah, max_parallel, areas,
-					  allocated,
-					  (ah->log_count && !ah->log_area.len) ?
-						*(areas + ix_offset + ix - 1) :
-						NULL))
+		/*
+		 * First time around, if there's a log, allocate it on the
+		 * smallest device that has space for it.
+		 *
+		 * FIXME decide which PV to use at top of function instead
+		 */
+
+		log_needs_allocating = (ah->log_count && !ah->log_area.len) ?
+				       1 : 0;
+
+		too_small_for_log_count = 0;
+
+		if (!log_needs_allocating) {
+			log_len = 0;
+			log_area = NULL;
+		} else {
+			log_len = mirror_log_extents(ah->log_region_size,
+			    pv_pe_size((*areas)->map->pv),
+			    (max_parallel - *allocated) / ah->area_multiple);
+
+			/* How many areas are too small for the log? */
+			while (too_small_for_log_count < ix_offset + ix &&
+			       (*(areas + ix_offset + ix - 1 -
+				  too_small_for_log_count))->count < log_len)
+				too_small_for_log_count++;
+
+			log_area = *(areas + ix_offset + ix - 1 -
+				     too_small_for_log_count);
+		}
+
+		if (ix + ix_offset < ah->area_count +
+		    (log_needs_allocating ? ah->log_count +
+					    too_small_for_log_count : 0))
+			/* FIXME With ALLOC_ANYWHERE, need to split areas */
+			break;
+
+		if (!_alloc_parallel_area(ah, max_parallel, areas, allocated,
+					  log_area, log_len))
 			return_0;
 
 	} while (!contiguous && *allocated != needed && can_split);


