From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 15 Jan 2010 22:58:25 -0000
Subject: LVM2 lib/activate/dev_manager.c lib/activate/d ...
Message-ID: <20100115225825.24899.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-15 22:58:25

Modified files:
	lib/activate   : dev_manager.c dev_manager.h 
	tools          : lvconvert.c 

Log message:
	Change dev_manager_mirror_percent()'s 'struct logical_volume *' to be
	'const'.  Be consistent with its use (and dev_manager_snapshot_percent()).
	
	Pass 'lv' from dev_manager_snapshot_percent() to _percent() to
	_percent_run().  _percent_run() always dereferenced 'lv' (when
	initializing segh) even though it may have been NULL (as was the case
	until now for dev_manager_snapshot_percent()).
	
	If a "snapshot-origin" LV (snapshot-merge whose merge was deferred
	becuase it was open) was passed to _percent_run() it would always return
	100%.
	
	Update _percent_run() to NOT return PERCENT_100 et. al. if
	->target_percent() wasn't ever called and supplied 'lv' is a merging
	origin.  A default return of 100% does not work for snapshot-merge.
	
	Also tweak a related lvconvert log_error() to include "Aborting merge."

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/lib/activate/dev_manager.c	2010/01/15 16:35:26	1.174
+++ LVM2/lib/activate/dev_manager.c	2010/01/15 22:58:25	1.175
@@ -393,7 +393,7 @@
 static int _percent_run(struct dev_manager *dm, const char *name,
 			const char *dlid,
 			const char *target_type, int wait,
-			struct logical_volume *lv, float *percent,
+			const struct logical_volume *lv, float *percent,
 			percent_range_t *overall_percent_range,
 			uint32_t *event_nr)
 {
@@ -404,7 +404,7 @@
 	uint64_t start, length;
 	char *type = NULL;
 	char *params = NULL;
-	struct dm_list *segh = &lv->segments;
+	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
 	percent_range_t percent_range = 0, combined_percent_range = 0;
@@ -484,9 +484,15 @@
 		*overall_percent_range = combined_percent_range;
 	} else {
 		*percent = 100;
-		if (first_time)
+		if (first_time) {
+			/* above ->target_percent() was not executed! */
+			/* FIXME why return PERCENT_100 et. al. in this case? */
 			*overall_percent_range = PERCENT_100;
-		else
+			if (lv && lv_is_merging_origin(lv)) {
+				/* must fail in snapshot-merge case */
+				goto_out;
+			}
+		} else
 			*overall_percent_range = combined_percent_range;
 	}
 
@@ -500,7 +506,7 @@
 
 static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const char *target_type, int wait,
-		    struct logical_volume *lv, float *percent,
+		    const struct logical_volume *lv, float *percent,
 		    percent_range_t *overall_percent_range, uint32_t *event_nr)
 {
 	if (dlid && *dlid) {
@@ -587,7 +593,7 @@
 	 * Try and get some info on this device.
 	 */
 	log_debug("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+	if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
 		       percent_range, NULL)))
 		return_0;
 
@@ -600,7 +606,7 @@
 /* FIXME Merge with snapshot_percent, auto-detecting target type */
 /* FIXME Cope with more than one target */
 int dev_manager_mirror_percent(struct dev_manager *dm,
-			       struct logical_volume *lv, int wait,
+			       const struct logical_volume *lv, int wait,
 			       float *percent, percent_range_t *percent_range,
 			       uint32_t *event_nr)
 {
--- LVM2/lib/activate/dev_manager.h	2009/10/01 00:35:29	1.30
+++ LVM2/lib/activate/dev_manager.h	2010/01/15 22:58:25	1.31
@@ -49,7 +49,7 @@
 				 float *percent,
 				 percent_range_t *percent_range);
 int dev_manager_mirror_percent(struct dev_manager *dm,
-			       struct logical_volume *lv, int wait,
+			       const struct logical_volume *lv, int wait,
 			       float *percent, percent_range_t *percent_range,
 			       uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
--- LVM2/tools/lvconvert.c	2010/01/13 01:55:44	1.114
+++ LVM2/tools/lvconvert.c	2010/01/15 22:58:25	1.115
@@ -402,7 +402,7 @@
 	percent_range_t percent_range;
 
 	if (!lv_snapshot_percent(lv, &percent, &percent_range)) {
-		log_error("%s: Failed query for merging percentage", lv->name);
+		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
 	} else if (percent_range == PERCENT_INVALID) {
 		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);


