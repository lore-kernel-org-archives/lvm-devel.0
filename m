From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Nov 2006 17:52:47 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20061130175247.28653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-30 17:52:47

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix mirror segment removal to use temporary error segment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.510&r2=1.511
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2006/11/30 13:19:42	1.510
+++ LVM2/WHATS_NEW	2006/11/30 17:52:47	1.511
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Fix mirror segment removal to use temporary error segment.
   Always compile debug logging into clvmd.
   Add startup timeout to RHEL4 clvmd startup script.
   Add -T (startup timeout) switch to clvmd.
--- LVM2/lib/metadata/mirror.c	2006/11/10 20:15:10	1.36
+++ LVM2/lib/metadata/mirror.c	2006/11/30 17:52:47	1.37
@@ -84,6 +84,7 @@
 			 struct list *removable_pvs, int remove_log)
 {
 	uint32_t m;
+	uint32_t extents;
 	uint32_t s, s1;
 	struct logical_volume *sub_lv;
 	struct logical_volume *log_lv = NULL;
@@ -95,6 +96,7 @@
 	struct pv_list *pvl;
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
+	struct segment_type *segtype;
 
 	log_very_verbose("Reducing mirror set from %" PRIu32 " to %"
 			 PRIu32 " image(s)%s.",
@@ -156,9 +158,14 @@
 	/* If no more mirrors, remove mirror layer */
 	if (num_mirrors == 1) {
 		lv1 = seg_lv(mirrored_seg, 0);
+		extents = lv1->le_count;
 		_move_lv_segments(mirrored_seg->lv, lv1);
 		mirrored_seg->lv->status &= ~MIRRORED;
 		remove_log = 1;
+		/* Replace mirror with error segment */
+		segtype = get_segtype_from_string(mirrored_seg->lv->vg->cmd, "error");
+		if (!lv_add_virtual_segment(lv1, 0, extents, segtype))
+			return_0;
 	}
 
 	if (remove_log && mirrored_seg->log_lv) {
@@ -174,8 +181,6 @@
 	 * then deactivate and remove them fully.
 	 */
 
-	/* FIXME lv1 has no segments here so shouldn't be written to disk! */
-
 	if (!vg_write(mirrored_seg->lv->vg)) {
 		log_error("intermediate VG write failed.");
 		return 0;


