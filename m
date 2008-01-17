From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 13:54:06 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20080117135406.3934.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 13:54:05

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	tools          : vgreduce.c 

Log message:
	rename lv_remap_error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/lib/metadata/lv_manip.c	2008/01/17 13:13:54	1.143
+++ LVM2/lib/metadata/lv_manip.c	2008/01/17 13:54:05	1.144
@@ -461,7 +461,7 @@
 /*
  * Empty an LV and add error segment.
  */
-int lv_remap_error(struct logical_volume *lv)
+int replace_lv_with_error_segment(struct logical_volume *lv)
 {
 	uint32_t len = lv->le_count;
 
--- LVM2/lib/metadata/metadata-exported.h	2008/01/17 13:13:54	1.38
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/17 13:54:05	1.39
@@ -379,7 +379,7 @@
 int lv_empty(struct logical_volume *lv);
 
 /* Empty an LV and add error segment */
-int lv_remap_error(struct logical_volume *lv);
+int replace_lv_with_error_segment(struct logical_volume *lv);
 
 /* Entry point for all LV extent allocations */
 int lv_extend(struct logical_volume *lv,
--- LVM2/lib/metadata/mirror.c	2008/01/17 13:37:51	1.61
+++ LVM2/lib/metadata/mirror.c	2008/01/17 13:54:05	1.62
@@ -521,7 +521,7 @@
 		_remove_mirror_log(mirrored_seg);
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
-		if (!lv_remap_error(lv))
+		if (!replace_lv_with_error_segment(lv))
 			return_0;
 		remove_log = 1;
 	} else if (remove_log)
@@ -616,7 +616,7 @@
 			/* Some mirrors are removed from the temporary mirror,
 			 * but the temporary layer still exists.
 			 * Down the stack and retry for remainder. */
-			next_lv = find_tmp_mirror(next_lv);
+			next_lv = find_temporary_mirror(next_lv);
 		}
 
 		num_removed -= r;
--- LVM2/tools/vgreduce.c	2008/01/17 13:13:54	1.74
+++ LVM2/tools/vgreduce.c	2008/01/17 13:54:05	1.75
@@ -54,7 +54,6 @@
 	struct list *snh, *snht;
 	struct logical_volume *cow;
 	struct lv_list *lvl;
-	uint32_t extents;
 	struct lvinfo info;
 	int first = 1;
 
@@ -116,19 +115,10 @@
 	 * the mirrored LV also should be cleaned up.
 	 * Clean-up is currently done by caller (_make_vg_consistent()).
 	 */
-	if ((lv_info(cmd, lv, &info, 0, 0) && info.exists)
-	    || find_mirror_seg(first_seg(lv))) {
-		extents = lv->le_count;
-		if (!lv_empty(lv)) {
-			stack;
-			return 0;
-		}
-		if (!lv_add_virtual_segment(lv, 0, extents,
-					    get_segtype_from_string(cmd,
-								    "error"))) {
-			stack;
-			return 0;
-		}
+	if ((lv_info(cmd, lv, &info, 0, 0) && info.exists) ||
+	    find_mirror_seg(first_seg(lv))) {
+		if (!replace_lv_with_error_segment(lv))
+			return_0;
 
 		if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
 			log_error("lv_list alloc failed");


