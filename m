From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Nov 2007 13:57:22 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20071122135722.15907.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-22 13:57:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Start refactoring pvmove allocation code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.739&r2=1.740
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2007/11/16 21:16:20	1.739
+++ LVM2/WHATS_NEW	2007/11/22 13:57:20	1.740
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Refactor pvmove allocation code.
   Decode cluster locking state in log message.
   Change file locking state messages from debug to very verbose.
   Fix --addtag to drop @ prefix from name.
--- LVM2/lib/metadata/mirror.c	2007/10/12 14:29:32	1.44
+++ LVM2/lib/metadata/mirror.c	2007/11/22 13:57:21	1.45
@@ -532,6 +532,37 @@
 	return lv_add_more_mirrored_areas(lv, img_lvs, num_mirrors, 0);
 }
 
+static int _alloc_and_insert_pvmove_seg(struct logical_volume *lv_mirr,
+					struct lv_segment *seg, uint32_t s,
+					struct list *allocatable_pvs,
+					alloc_policy_t alloc,
+					const struct segment_type *segtype)
+{
+	struct physical_volume *pv = seg_pv(seg, s);
+	uint32_t start_le = lv_mirr->le_count;
+	uint32_t pe = seg_pe(seg, s);
+
+	log_very_verbose("Moving %s:%u-%u of %s/%s", pv_dev_name(pv),
+			 pe, pe + seg->area_len - 1,
+			 seg->lv->vg->name, seg->lv->name);
+
+	release_lv_segment_area(seg, s, seg->area_len);
+
+	if (!lv_extend(lv_mirr, segtype, 1,
+	       	seg->area_len, 0u, seg->area_len,
+	       	pv, pe,
+	       	PVMOVE, allocatable_pvs,
+	       	alloc)) {
+		log_error("Unable to allocate "
+			  "temporary LV for pvmove.");
+		return 0;
+	}
+
+	set_lv_segment_area_lv(seg, s, lv_mirr, start_le, 0);
+
+	return 1;
+}
+
 /* 
  * Replace any LV segments on given PV with temporary mirror.
  * Returns list of LVs changed.
@@ -547,10 +578,8 @@
 	struct lv_segment *seg;
 	struct lv_list *lvl;
 	struct pv_list *pvl;
-	struct physical_volume *pv;
-	uint32_t pe;
 	int lv_used = 0;
-	uint32_t s, start_le, extent_count = 0u;
+	uint32_t s, extent_count = 0u;
 	const struct segment_type *segtype;
 	struct pe_range *per;
 	uint32_t pe_start, pe_end, per_end, stripe_multiplier;
@@ -648,27 +677,11 @@
 					lv_used = 1;
 				}
 	
-				pv = seg_pv(seg, s);
-				pe = seg_pe(seg, s);
-				log_very_verbose("Moving %s:%u-%u of %s/%s",
-						 pv_dev_name(pvl->pv),
-						 pe, pe + seg->area_len - 1,
-						 lv->vg->name, lv->name);
-
-				start_le = lv_mirr->le_count;
-				/* FIXME Clean this up */
-				release_lv_segment_area(seg, s, seg->area_len);
-				if (!lv_extend(lv_mirr, segtype, 1,
-				       	seg->area_len, 0u, seg->area_len,
-				       	pv, pe,
-				       	PVMOVE, allocatable_pvs,
-				       	alloc)) {
-					log_error("Unable to allocate "
-						  "temporary LV for pvmove.");
-					return 0;
-				}
-				set_lv_segment_area_lv(seg, s, lv_mirr, start_le, 0);
-	
+				if (!_alloc_and_insert_pvmove_seg(lv_mirr, seg, s,
+								  allocatable_pvs,
+								  alloc, segtype))
+					return_0;
+
 				extent_count += seg->area_len;
 	
 				lv->status |= LOCKED;


