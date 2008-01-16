From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:16:48 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20080116191648.15666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:16:48

Modified files:
	tools          : lvconvert.c 

Log message:
	fix mirror log manipulation during lv convert

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/tools/lvconvert.c	2008/01/14 21:11:47	1.54
+++ LVM2/tools/lvconvert.c	2008/01/16 19:16:48	1.55
@@ -364,6 +364,17 @@
 	return 1;
 }
 
+/* walk down the stacked mirror LV to the original mirror LV */
+static struct logical_volume *_original_lv(struct logical_volume *lv)
+{
+	struct logical_volume *next_lv = lv, *tmp_lv;
+
+	while ((tmp_lv = find_temporary_mirror(next_lv)))
+		next_lv = tmp_lv;
+
+	return next_lv;
+}
+
 static int lvconvert_mirrors(struct cmd_context * cmd, struct logical_volume * lv,
 			     struct lvconvert_params *lp)
 {
@@ -371,6 +382,7 @@
 	uint32_t existing_mirrors;
 	const char *mirrorlog;
 	unsigned corelog = 0;
+	struct logical_volume *original_lv;
 
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);
@@ -496,8 +508,9 @@
 	}
 
 	if (lp->mirrors == existing_mirrors) {
+		original_lv = _original_lv(lv);
 		if (!seg->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, lv, 1,
+			if (!add_mirror_log(cmd, original_lv, 1,
 					    adjusted_mirror_region_size(
 							lv->vg->extent_size,
 							lv->le_count,
@@ -505,7 +518,7 @@
 					    lp->pvh, lp->alloc))
 				return_0;
 		} else if (seg->log_lv && corelog) {
-			if (!remove_mirror_log(cmd, lv,
+			if (!remove_mirror_log(cmd, original_lv,
 					       lp->pv_count ? lp->pvh : NULL))
 				return_0;
 		} else {
@@ -526,8 +539,9 @@
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
+		original_lv = _original_lv(lv);
 		if (!seg->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, lv, 1,
+			if (!add_mirror_log(cmd, original_lv, 1,
 					    adjusted_mirror_region_size(
 							lv->vg->extent_size,
 							lv->le_count,
@@ -535,7 +549,7 @@
 					    lp->pvh, lp->alloc))
 				return_0;
 		} else if (seg->log_lv && corelog) {
-			if (!remove_mirror_log(cmd, lv,
+			if (!remove_mirror_log(cmd, original_lv,
 					       lp->pv_count ? lp->pvh : NULL))
 				return_0;
 		}


