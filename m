From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 31 Mar 2010 17:23:20 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import.c lib/ ...
Message-ID: <20100331172320.852.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-31 17:23:19

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import.c 
	lib/metadata   : lv_manip.c merge.c pv_alloc.h pv_manip.c 

Log message:
	Fix all segments memory is allocated from vg private mempool.
	
	Physical segments were still allocated from global
	command context mempool.
	
	This leads to very high memory usage when
	activating large VG (vgchange).
	(Memory usage was about 2G when >3000LVs).
	
	Fix it by properly using vg->vgmem private pool,
	so all the memory is released early.
	
	New memory pool parameter is needed here for pv_split_segment
	function.
	
	Also fix the same problem in some minor allocations
	(vg description, lv segment split).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1496&r2=1.1497
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_alloc.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2010/03/31 17:22:26	1.1496
+++ LVM2/WHATS_NEW	2010/03/31 17:23:18	1.1497
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Allocate all segments memory from vg private mempool.
   Return newly allocated PV segment after segment split.
   Optimise PV segments search for the most last segment search case.
   Remove vg_validate call when parsing cached metadata.
--- LVM2/lib/format_text/import.c	2010/03/17 02:11:19	1.49
+++ LVM2/lib/format_text/import.c	2010/03/31 17:23:19	1.50
@@ -114,7 +114,7 @@
 		if (!(vg = (*vsn)->read_vg(fid, cft, 0)))
 			goto_out;
 
-		(*vsn)->read_desc(fid->fmt->cmd->mem, cft, when, desc);
+		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
 		break;
 	}
 
--- LVM2/lib/metadata/lv_manip.c	2010/03/29 17:59:46	1.218
+++ LVM2/lib/metadata/lv_manip.c	2010/03/31 17:23:19	1.219
@@ -47,7 +47,7 @@
 	log_very_verbose("Adding %s:%" PRIu32 " as an user of %s",
 			 seg->lv->name, seg->le, lv->name);
 
-	if (!(sl = dm_pool_zalloc(lv->vg->cmd->mem, sizeof(*sl)))) {
+	if (!(sl = dm_pool_zalloc(lv->vg->vgmem, sizeof(*sl)))) {
 		log_error("Failed to allocate segment list");
 		return 0;
 	}
--- LVM2/lib/metadata/merge.c	2010/03/31 12:06:30	1.37
+++ LVM2/lib/metadata/merge.c	2010/03/31 17:23:19	1.38
@@ -268,7 +268,7 @@
 	}
 
 	/* Clone the existing segment */
-	if (!(split_seg = alloc_lv_segment(lv->vg->cmd->mem, seg->segtype,
+	if (!(split_seg = alloc_lv_segment(lv->vg->vgmem, seg->segtype,
 					   seg->lv, seg->le, seg->len,
 					   seg->status, seg->stripe_size,
 					   seg->log_lv,
@@ -279,7 +279,7 @@
 		return 0;
 	}
 
-	if (!str_list_dup(lv->vg->cmd->mem, &split_seg->tags, &seg->tags)) {
+	if (!str_list_dup(lv->vg->vgmem, &split_seg->tags, &seg->tags)) {
 		log_error("LV segment tags duplication failed");
 		return 0;
 	}
--- LVM2/lib/metadata/pv_alloc.h	2010/03/31 17:22:26	1.8
+++ LVM2/lib/metadata/pv_alloc.h	2010/03/31 17:23:19	1.9
@@ -20,7 +20,8 @@
 				       uint32_t area_len,
 				       struct lv_segment *seg,
 				       uint32_t area_num);
-int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+int pv_split_segment(struct dm_pool *mem,
+		     struct physical_volume *pv, uint32_t pe,
 		     struct pv_segment **pvseg_allocated);
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction);
 int check_pv_segments(struct volume_group *vg);
--- LVM2/lib/metadata/pv_manip.c	2010/03/31 17:22:26	1.24
+++ LVM2/lib/metadata/pv_manip.c	2010/03/31 17:23:19	1.25
@@ -96,13 +96,14 @@
  * Split peg at given extent.
  * Second part is always not allocated to a LV and returned.
  */
-static struct pv_segment *_pv_split_segment(struct physical_volume *pv,
+static struct pv_segment *_pv_split_segment(struct dm_pool *mem,
+					    struct physical_volume *pv,
 					    struct pv_segment *peg,
 					    uint32_t pe)
 {
 	struct pv_segment *peg_new;
 
-	if (!(peg_new = _alloc_pv_segment(pv->fmt->cmd->mem, peg->pv, pe,
+	if (!(peg_new = _alloc_pv_segment(mem, peg->pv, pe,
 					  peg->len + peg->pe - pe,
 					  NULL, 0)))
 		return_NULL;
@@ -122,7 +123,8 @@
 /*
  * Ensure there is a PV segment boundary at the given extent.
  */
-int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+int pv_split_segment(struct dm_pool *mem,
+		     struct physical_volume *pv, uint32_t pe,
 		     struct pv_segment **pvseg_allocated)
 {
 	struct pv_segment *pvseg, *pvseg_new = NULL;
@@ -142,7 +144,7 @@
 		goto out;
 	}
 
-	if (!(pvseg_new = _pv_split_segment(pv, pvseg, pe)))
+	if (!(pvseg_new = _pv_split_segment(mem, pv, pvseg, pe)))
 		return_0;
 out:
 	if (pvseg_allocated)
@@ -167,8 +169,8 @@
 	if (!pv)
 		return &null_pv_segment;
 
-	if (!pv_split_segment(pv, pe, &peg) ||
-	    !pv_split_segment(pv, pe + area_len, NULL))
+	if (!pv_split_segment(seg->lv->vg->vgmem, pv, pe, &peg) ||
+	    !pv_split_segment(seg->lv->vg->vgmem, pv, pe + area_len, NULL))
 		return_NULL;
 
 	if (!peg) {
@@ -206,8 +208,9 @@
 		return 1;
 	}
 
-	if (!pv_split_segment(peg->pv, peg->pe + peg->lvseg->area_len -
-				       area_reduction, NULL))
+	if (!pv_split_segment(peg->lvseg->lv->vg->vgmem,
+			      peg->pv, peg->pe + peg->lvseg->area_len -
+			      area_reduction, NULL))
 		return_0;
 
 	return 1;
@@ -380,7 +383,7 @@
 		}
 	}
 
-	if (!pv_split_segment(pv, new_pe_count, NULL))
+	if (!pv_split_segment(vg->vgmem, pv, new_pe_count, NULL))
 		return_0;
 
 	dm_list_iterate_items_safe(peg, pegt, &pv->segments) {


