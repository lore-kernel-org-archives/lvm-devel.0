From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Dec 2009 17:48:33 -0000
Subject: LVM2/lib format_text/import_vsn1.c format_text ...
Message-ID: <20091204174833.25123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-12-04 17:48:32

Modified files:
	lib/format_text: import_vsn1.c text_import.h 
	lib/metadata   : lv_alloc.h lv_manip.c 

Log message:
	Update a few more uint64_t's related to the 64-bit status change.
	
	At this point they probably do not matter but going forward they
	may - depends on future patches for replicator, etc.  I think
	these probably got missed because they were 'flags' so I changed
	the name to 'status' to be consistent.  So the on-disk
	things 'flags' and the in structure 'status' (bits).
	NOTE: WHATS_NEW already has entry for this in current release.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_import.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189

--- LVM2/lib/format_text/import_vsn1.c	2009/11/24 22:55:56	1.66
+++ LVM2/lib/format_text/import_vsn1.c	2009/12/04 17:48:32	1.67
@@ -372,7 +372,7 @@
 
 int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		      const struct config_node *cn, struct dm_hash_table *pv_hash,
-		      uint32_t flags)
+		      uint64_t status)
 {
 	unsigned int s;
 	struct config_value *cv;
@@ -410,7 +410,7 @@
 		} else if ((lv1 = find_lv(seg->lv->vg, cv->v.str))) {
 			if (!set_lv_segment_area_lv(seg, s, lv1,
 						    (uint32_t) cv->next->v.i,
-						    flags))
+						    status))
 				return_0;
 		} else {
 			log_error("Couldn't find volume '%s' "
--- LVM2/lib/format_text/text_import.h	2007/08/20 20:55:26	1.4
+++ LVM2/lib/format_text/text_import.h	2009/12/04 17:48:32	1.5
@@ -21,6 +21,6 @@
 
 int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		      const struct config_node *cn, struct dm_hash_table *pv_hash,
-		      uint32_t flags);
+		      uint64_t status);
 
 #endif
--- LVM2/lib/metadata/lv_alloc.h	2009/11/24 22:55:56	1.24
+++ LVM2/lib/metadata/lv_alloc.h	2009/12/04 17:48:32	1.25
@@ -35,7 +35,7 @@
 			   struct physical_volume *pv, uint32_t pe);
 int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			   struct logical_volume *lv, uint32_t le,
-			   uint32_t flags);
+			   uint64_t status);
 int move_lv_segment_area(struct lv_segment *seg_to, uint32_t area_to,
 			 struct lv_segment *seg_from, uint32_t area_from);
 void release_lv_segment_area(struct lv_segment *seg, uint32_t s,
--- LVM2/lib/metadata/lv_manip.c	2009/12/03 19:18:33	1.188
+++ LVM2/lib/metadata/lv_manip.c	2009/12/04 17:48:32	1.189
@@ -333,7 +333,7 @@
  */
 int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			   struct logical_volume *lv, uint32_t le,
-			   uint32_t flags)
+			   uint64_t status)
 {
 	log_very_verbose("Stack %s:%" PRIu32 "[%" PRIu32 "] on LV %s:%" PRIu32,
 			 seg->lv->name, seg->le, area_num, lv->name, le);
@@ -341,7 +341,7 @@
 	seg->areas[area_num].type = AREA_LV;
 	seg_lv(seg, area_num) = lv;
 	seg_le(seg, area_num) = le;
-	lv->status |= flags;
+	lv->status |= status;
 
 	if (!add_seg_to_segs_using_this_lv(lv, seg))
 		return_0;


