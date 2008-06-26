From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jun 2008 23:05:12 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c tools/l ...
Message-ID: <20080626230512.18479.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-26 23:05:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	tools          : lvconvert.c 

Log message:
	Update validation of safe mirror log type conversions in lvconvert. (brassow)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.918&r2=1.919
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/WHATS_NEW	2008/06/26 21:38:57	1.918
+++ LVM2/WHATS_NEW	2008/06/26 23:05:10	1.919
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Update validation of safe mirror log type conversions in lvconvert.
   Fix lvconvert to disallow snapshot and mirror combinations.
   Fix reporting of LV fields alongside unallocated PV segments.
   Add --unquoted and --rows to reporting tools.
--- LVM2/lib/metadata/mirror.c	2008/06/13 12:15:55	1.72
+++ LVM2/lib/metadata/mirror.c	2008/06/26 23:05:11	1.73
@@ -1140,6 +1140,8 @@
 		      struct list *removable_pvs)
 {
 	float sync_percent;
+	struct lvinfo info;
+	struct volume_group *vg = lv->vg;
 
 	/* Unimplemented features */
 	if (list_size(&lv->segments) != 1) {
@@ -1148,10 +1150,21 @@
 	}
 
 	/* Had disk log, switch to core. */
-	if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-		log_error("Unable to determine mirror sync status.");
+	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+			log_error("Unable to determine mirror sync status.");
+			return 0;
+		}
+	} else if (vg_is_clustered(vg)) {
+		log_error("Unable to convert the log of inactive "
+			  "cluster mirror %s", lv->name);
+		return 0;
+	} else if (yes_no_prompt("Full resync required to convert "
+				 "inactive mirror %s to core log. "
+				 "Proceed? [y/n]: "))
+		sync_percent = 0;
+	else
 		return 0;
-	}
 
 	if (sync_percent >= 100.0)
 		init_mirror_in_sync(1);
@@ -1269,12 +1282,9 @@
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
-int add_mirror_log(struct cmd_context *cmd,
-		   struct logical_volume *lv,
-		   uint32_t log_count,
-		   uint32_t region_size,
-		   struct list *allocatable_pvs,
-		   alloc_policy_t alloc)
+int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+		   uint32_t log_count, uint32_t region_size,
+		   struct list *allocatable_pvs, alloc_policy_t alloc)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
@@ -1282,17 +1292,31 @@
 	float sync_percent;
 	int in_sync;
 	struct logical_volume *log_lv;
+	struct lvinfo info;
 
 	/* Unimplemented features */
 	if (log_count > 1) {
 		log_error("log_count > 1 is not supported");
 		return 0;
 	}
+
 	if (list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;
 	}
 
+	/*
+	 * We are unable to convert the log of inactive cluster mirrors
+	 * due to the inability to detect whether the mirror is active
+	 * on remote nodes (even though it is inactive on this node)
+	 */
+	if (vg_is_clustered(lv->vg) &&
+	    !(lv_info(cmd, lv, &info, 0, 0) && info.exists)) {
+		log_error("Unable to convert the log of inactive "
+			  "cluster mirror %s", lv->name);
+		return 0;
+	}
+
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 		return_0;
 
--- LVM2/tools/lvconvert.c	2008/06/26 21:38:58	1.65
+++ LVM2/tools/lvconvert.c	2008/06/26 23:05:11	1.66
@@ -508,6 +508,9 @@
 	}
 
 	if (lp->mirrors == existing_mirrors) {
+		/*
+		 * Convert Mirror log type
+		 */
 		original_lv = _original_lv(lv);
 		if (!first_seg(original_lv)->log_lv && !corelog) {
 			if (!add_mirror_log(cmd, original_lv, 1,


