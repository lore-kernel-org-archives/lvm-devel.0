From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Aug 2009 21:56:30 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20090802215630.11769.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-02 21:56:29

Modified files:
	tools          : lvconvert.c 

Log message:
	Slightly refactor mirror log conversions in lvconvert.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/tools/lvconvert.c	2009/07/15 05:47:55	1.89
+++ LVM2/tools/lvconvert.c	2009/08/02 21:56:29	1.90
@@ -496,6 +496,33 @@
 	}
 }
 
+static int _using_corelog(struct logical_volume *lv)
+{
+	return !first_seg(_original_lv(lv))->log_lv;
+}
+
+static int _lv_update_log_type(struct cmd_context *cmd,
+			       struct lvconvert_params *lp,
+			       struct logical_volume *lv,
+			       int corelog)
+{
+	struct logical_volume *original_lv = _original_lv(lv);
+	if (_using_corelog(lv) && !corelog) {
+		if (!add_mirror_log(cmd, original_lv, 1,
+				    adjusted_mirror_region_size(
+					lv->vg->extent_size,
+					lv->le_count,
+					lp->region_size),
+				    lp->pvh, lp->alloc))
+			return_0;
+	} else if (!_using_corelog(lv) && corelog) {
+		if (!remove_mirror_log(cmd, original_lv,
+				       lp->pv_count ? lp->pvh : NULL))
+			return_0;
+	}
+	return 1;
+}
+
 static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
@@ -503,7 +530,6 @@
 	uint32_t existing_mirrors;
 	const char *mirrorlog;
 	unsigned corelog = 0;
-	struct logical_volume *original_lv;
 	int r = 0;
 	struct logical_volume *log_lv;
 	int failed_mirrors = 0, failed_log = 0;
@@ -688,20 +714,8 @@
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
-		original_lv = _original_lv(lv);
-		if (!first_seg(original_lv)->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, original_lv, 1,
-					    adjusted_mirror_region_size(
-							lv->vg->extent_size,
-							lv->le_count,
-							lp->region_size),
-					    lp->pvh, lp->alloc))
-				return_0;
-		} else if (first_seg(original_lv)->log_lv && corelog) {
-			if (!remove_mirror_log(cmd, original_lv,
-					       lp->pv_count ? lp->pvh : NULL))
-				return_0;
-		}
+		if (!_lv_update_log_type(cmd, lp, lv, corelog))
+			return_0;
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
 		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
@@ -722,24 +736,10 @@
 	}
 
 	if (lp->mirrors == existing_mirrors) {
-		/*
-		 * Convert Mirror log type
-		 */
-		original_lv = _original_lv(lv);
-		if (!first_seg(original_lv)->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, original_lv, 1,
-					    adjusted_mirror_region_size(
-							lv->vg->extent_size,
-							lv->le_count,
-							lp->region_size),
-					    lp->pvh, lp->alloc))
-				return_0;
-		} else if (first_seg(original_lv)->log_lv && corelog) {
-			if (!remove_mirror_log(cmd, original_lv,
-					       lp->pv_count ? lp->pvh : NULL))
+		if (_using_corelog(lv) != corelog) {
+			if (!_lv_update_log_type(cmd, lp, lv, corelog))
 				return_0;
 		} else {
-			/* No change */
 			log_error("Logical volume %s already has %"
 				  PRIu32 " mirror(s).", lv->name,
 				  lp->mirrors - 1);


