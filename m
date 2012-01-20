From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jan 2012 22:02:06 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20120120220206.26961.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2012-01-20 22:02:05

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/misc       : lvm-percent.h 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	liblvm         : lvm2app.h 
	tools          : lvconvert.c 

Log message:
	Differentiate between snapshot status of "Invalid" and "Merge failed".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2229&r2=1.2230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.262&r2=1.263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-percent.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178

--- LVM2/WHATS_NEW	2012/01/20 21:56:01	1.2229
+++ LVM2/WHATS_NEW	2012/01/20 22:02:04	1.2230
@@ -1,6 +1,7 @@
 Version 2.02.89 - 
 ==================================
-  Lookup snapshot usage percent of origin when a snapshot is merging.
+  Differentiate between snapshot status of "Invalid" and "Merge failed".
+  Lookup snapshot usage percent of origin volume when a snapshot is merging.
   Update lvdisplay with backward compat. config opt. lvm1_compatible_display.
   Do not report linear segtype for non-striped targets.
   Keep info about creation host and time for each logical volume.
--- LVM2/lib/activate/dev_manager.c	2012/01/20 21:56:01	1.262
+++ LVM2/lib/activate/dev_manager.c	2012/01/20 22:02:04	1.263
@@ -482,6 +482,9 @@
 static percent_range_t _combine_percent(percent_t a, percent_t b,
                                         uint32_t numerator, uint32_t denominator)
 {
+	if (a == PERCENT_MERGE_FAILED || b == PERCENT_MERGE_FAILED)
+		return PERCENT_MERGE_FAILED;
+
 	if (a == PERCENT_INVALID || b == PERCENT_INVALID)
 		return PERCENT_INVALID;
 
--- LVM2/lib/misc/lvm-percent.h	2010/11/30 11:53:32	1.1
+++ LVM2/lib/misc/lvm-percent.h	2012/01/20 22:02:04	1.2
@@ -34,7 +34,8 @@
 	PERCENT_0 = 0,
 	PERCENT_1 = 1000000,
 	PERCENT_100 = 100 * PERCENT_1,
-	PERCENT_INVALID = -1
+	PERCENT_INVALID = -1,
+	PERCENT_MERGE_FAILED = -2
 } percent_range_t;
 
 float percent_to_float(percent_t v);
--- LVM2/lib/report/report.c	2012/01/19 15:34:33	1.148
+++ LVM2/lib/report/report.c	2012/01/20 22:02:04	1.149
@@ -836,7 +836,7 @@
 	}
 
 	if (!lv_snapshot_percent(lv, &snap_percent) ||
-				 (snap_percent == PERCENT_INVALID)) {
+	    (snap_percent == PERCENT_INVALID) || (snap_percent == PERCENT_MERGE_FAILED)) {
 		if (!lv_is_merging_origin(lv)) {
 			*sortval = UINT64_C(100);
 			dm_report_field_set_value(field, "100.00", sortval);
--- LVM2/lib/snapshot/snapshot.c	2011/08/30 14:55:18	1.58
+++ LVM2/lib/snapshot/snapshot.c	2012/01/20 22:02:04	1.59
@@ -136,9 +136,11 @@
 			*percent = PERCENT_100;
 		else
 			*percent = make_percent(*total_numerator, *total_denominator);
-	} else if (!strcmp(params, "Invalid") ||
-		   !strcmp(params, "Merge failed"))
+	}
+	else if (!strcmp(params, "Invalid"))
 		*percent = PERCENT_INVALID;
+	else if (!strcmp(params, "Merge failed"))
+		*percent = PERCENT_MERGE_FAILED;
 	else
 		return 0;
 
--- LVM2/liblvm/lvm2app.h	2010/12/14 23:20:58	1.31
+++ LVM2/liblvm/lvm2app.h	2012/01/20 22:02:04	1.32
@@ -1591,7 +1591,8 @@
 	PERCENT_0 = 0,
 	PERCENT_1 = 1000000,
 	PERCENT_100 = 100 * PERCENT_1,
-	PERCENT_INVALID = -1
+	PERCENT_INVALID = -1,
+	PERCENT_MERGE_FAILED = -2
 } percent_range_t;
 
 typedef int32_t percent_t;
--- LVM2/tools/lvconvert.c	2011/12/08 18:00:03	1.177
+++ LVM2/tools/lvconvert.c	2012/01/20 22:02:05	1.178
@@ -461,6 +461,9 @@
 	} else if (percent == PERCENT_INVALID) {
 		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
+	} else if (percent == PERCENT_MERGE_FAILED) {
+		log_error("%s: Merge failed. Retry merge or inspect manually.", lv->name);
+		return PROGRESS_CHECK_FAILED;
 	}
 
 	if (parms->progress_display)


