From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:54:36 -0000
Subject: LVM2 lib/activate/dev_manager.c lib/report/rep ...
Message-ID: <20100113015436.20593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:54:35

Modified files:
	lib/activate   : dev_manager.c 
	lib/report     : report.c 
	tools          : lvconvert.c 

Log message:
	Merge on activate support.
	
	If either the origin or snapshot that is to be merged is open the merge
	will not start; only the merge metadata will be written.  The merge will
	start on the next activation of the origin (or via lvchange --refresh)
	IFF both the origin and snapshot are closed.
	
	Merge on activate is particularly important if we want to merge over a
	mounted filesystem that cannot be unmounted (until next boot) --- for
	example root.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/lib/activate/dev_manager.c	2010/01/13 01:44:37	1.170
+++ LVM2/lib/activate/dev_manager.c	2010/01/13 01:54:34	1.171
@@ -327,6 +327,52 @@
 	return 0;
 }
 
+static int _lv_has_target_type(struct dev_manager *dm,
+			       struct logical_volume *lv,
+			       const char *layer,
+			       const char *target_type)
+{
+	int r = 0;
+	char *dlid;
+	struct dm_task *dmt;
+	struct dm_info info;
+	void *next = NULL;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+
+	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+		return_0;
+
+	if (!(dmt = _setup_task(NULL, dlid, 0,
+				DM_DEVICE_STATUS, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length,
+					  &type, &params);
+		if (type && strncmp(type, target_type,
+				    strlen(target_type)) == 0) {
+			if (info.live_table && !info.inactive_table)
+				r = 1;
+			break;
+		}
+	} while (next);
+
+ out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
 static percent_range_t _combine_percent_ranges(percent_range_t a,
 					       percent_range_t b)
 {
@@ -1062,12 +1108,33 @@
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
+	struct dm_info dinfo;
 	char *name, *dlid, *lv_name;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
+	if (lv_is_origin(lv) && lv->merging_snapshot && !layer) {
+		/*
+		 * Clear merge attributes if merge isn't currently possible:
+		 * either origin or merging snapshot are open
+		 * - must refresh info's open_count, so using the tree's
+		 *   existing nodes' info isn't an option
+		 * - but use "snapshot-merge" if it is already being used
+		 */
+		if ((dev_manager_info(dm->mem, NULL, lv,
+				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
+		    (dev_manager_info(dm->mem, NULL, lv->merging_snapshot->cow,
+				      0, 1, 0, &dinfo, NULL) && dinfo.open_count)) {
+			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge")) {
+				/* clear merge attributes */
+				lv->merging_snapshot->status &= ~SNAPSHOT_MERGE;
+				lv->merging_snapshot = NULL;
+			}
+		}
+	}
+
 	lv_name = lv->name;
 	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE) {
 		if (layer) {
--- LVM2/lib/report/report.c	2010/01/13 01:49:22	1.109
+++ LVM2/lib/report/report.c	2010/01/13 01:54:35	1.110
@@ -1032,8 +1032,16 @@
 
 	if (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
 				 (percent_range == PERCENT_INVALID)) {
-		*sortval = UINT64_C(100);
-		dm_report_field_set_value(field, "100.00", sortval);
+		if (!lv->merging_snapshot) {
+			*sortval = UINT64_C(100);
+			dm_report_field_set_value(field, "100.00", sortval);
+		} else {
+			/* onactivate merge that hasn't started yet would
+			 * otherwise display incorrect snap% in origin
+			 */
+			*sortval = UINT64_C(0);
+			dm_report_field_set_value(field, "", sortval);
+		}
 		return 1;
 	}
 
--- LVM2/tools/lvconvert.c	2010/01/13 01:49:52	1.112
+++ LVM2/tools/lvconvert.c	2010/01/13 01:54:35	1.113
@@ -1117,6 +1117,7 @@
 			   struct lvconvert_params *lp)
 {
 	int r = 0;
+	int merge_on_activate = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *cow_seg = find_cow(lv);
 	struct lvinfo info;
@@ -1134,7 +1135,9 @@
 
 	/*
 	 * Prevent merge with open device(s) as it would likely lead
-	 * to application/filesystem failure.
+	 * to application/filesystem failure.  Merge on origin's next
+	 * activation if either the origin or snapshot LV are currently
+	 * open.
 	 *
 	 * FIXME testing open_count is racey; snapshot-merge target's
 	 * constructor and DM should prevent appropriate devices from
@@ -1143,13 +1146,13 @@
 	if (lv_info(cmd, origin, &info, 1, 0)) {
 		if (info.open_count) {
 			log_error("Can't merge over open origin volume");
-			return 0;
+			merge_on_activate = 1;
 		}
 	}
 	if (lv_info(cmd, lv, &info, 1, 0)) {
 		if (info.open_count) {
-			log_error("Can't merge when snapshot is open");
-			return 0;
+			log_print("Can't merge when snapshot is open");
+			merge_on_activate = 1;
 		}
 	}
 
@@ -1159,6 +1162,16 @@
 	if (!vg_write(lv->vg))
 		return_0;
 
+	if (merge_on_activate) {
+		/* commit vg but skip starting the merge */
+		if (!vg_commit(lv->vg))
+			return_0;
+		r = 1;
+		log_print("Merging of snapshot %s will start "
+			  "next activation.", lv->name);
+		goto out;
+	}
+
 	/* Perform merge */
 	if (!suspend_lv(cmd, origin)) {
 		log_error("Failed to suspend origin %s", origin->name);


