From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2008 22:00:51 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20080118220051.24058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-18 22:00:51

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 

Log message:
	add lvconvert messages

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.768&r2=1.769
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/WHATS_NEW	2008/01/18 21:56:39	1.768
+++ LVM2/WHATS_NEW	2008/01/18 22:00:46	1.769
@@ -1,5 +1,6 @@
 Version 2.02.31 -
 ===================================
+  Add very_verbose lvconvert messages.
   Avoid error message when using default setting of lvcreate -M1. (2.02.30)
 
 Version 2.02.30 - 17th January 2008
--- LVM2/lib/metadata/lv_manip.c	2008/01/17 17:17:09	1.145
+++ LVM2/lib/metadata/lv_manip.c	2008/01/18 22:00:46	1.146
@@ -43,6 +43,9 @@
 		}
 	}
 
+	log_very_verbose("Adding %s:%" PRIu32 " as an user of %s",
+			 seg->lv->name, seg->le, lv->name);
+
 	if (!(sl = dm_pool_zalloc(lv->vg->cmd->mem, sizeof(*sl)))) {
 		log_error("Failed to allocate segment list");
 		return 0;
@@ -65,8 +68,12 @@
 			continue;
 		if (sl->count > 1)
 			sl->count--;
-		else
+		else {
+			log_very_verbose("%s:%" PRIu32 " is no longer a user "
+					 "of %s", seg->lv->name, seg->le,
+					 lv->name);
 			list_del(&sl->list);
+		}
 		return 1;
 	}
 
@@ -255,6 +262,11 @@
 	}
 
 	if (area_reduction == seg->area_len) {
+		log_very_verbose("Remove %s:%" PRIu32 "[%" PRIu32 "] from "
+				 "the top of LV %s:%" PRIu32,
+				 seg->lv->name, seg->le, s,
+				 seg_lv(seg, s)->name, seg_le(seg, s));
+
 		remove_seg_from_segs_using_this_lv(seg_lv(seg, s), seg);
 		seg_lv(seg, s) = NULL;
 		seg_le(seg, s) = 0;
@@ -332,6 +344,9 @@
 			   struct logical_volume *lv, uint32_t le,
 			   uint32_t flags)
 {
+	log_very_verbose("Stack %s:%" PRIu32 "[%" PRIu32 "] on LV %s:%" PRIu32,
+			 seg->lv->name, seg->le, area_num, lv->name, le);
+
 	seg->areas[area_num].type = AREA_LV;
 	seg_lv(seg, area_num) = lv;
 	seg_le(seg, area_num) = le;
@@ -2177,6 +2192,9 @@
 	int lv_changed = 0;
 	struct lv_list *lvl;
 
+	log_very_verbose("Removing layer %s for segments of %s",
+			 layer_lv->name, lv->name);
+
 	/* Find all segments that point at the temporary mirror */
 	list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
@@ -2313,6 +2331,8 @@
 	struct lv_segment *parent_seg;
 	struct segment_type *segtype;
 
+	log_very_verbose("Removing layer %s for %s", layer_lv->name, lv->name);
+
 	if (!(parent_seg = get_only_segment_using_this_lv(layer_lv))) {
 		log_error("Failed to find layer %s in %s",
 		layer_lv->name, lv->name);
@@ -2569,6 +2589,10 @@
 	int lv_used = 0;
 	uint32_t s;
 
+	log_very_verbose("Inserting layer %s for segments of %s on %s",
+			 layer_lv->name, lv_where->name,
+			 pvl ? pv_dev_name(pvl->pv) : "any");
+
 	if (!_align_segment_boundary_to_pe_range(lv_where, pvl))
 		return_0;
 
--- LVM2/lib/metadata/mirror.c	2008/01/17 17:17:09	1.63
+++ LVM2/lib/metadata/mirror.c	2008/01/18 22:00:46	1.64
@@ -516,6 +516,8 @@
 			return 0;
 		}
 	} else if (new_area_count == 0) {
+		log_very_verbose("All mimages of %s are gone", lv->name);
+
 		/* All mirror images are gone.
 		 * It can happen for vgreduce --removemissing. */
 		_remove_mirror_log(mirrored_seg);
@@ -586,6 +588,9 @@
 	if (removed)
 		*removed = old_area_count - new_area_count;
 
+	log_very_verbose("%" PRIu32 " image(s) removed from %s",
+			 old_area_count - num_removed, lv->name);
+
 	return 1;
 }
 


