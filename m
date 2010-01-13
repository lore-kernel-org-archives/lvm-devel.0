From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:55:45 -0000
Subject: LVM2 lib/activate/activate.c lib/activate/dev_ ...
Message-ID: <20100113015545.30631.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:55:44

Modified files:
	lib/activate   : activate.c dev_manager.c 
	lib/metadata   : lv_manip.c metadata-exported.h snapshot_manip.c 
	lib/report     : report.c 
	tools          : lvconvert.c toollib.c vgchange.c 

Log message:
	Add snapshot merge wrappers to abstract the associations and flags used
	to represent merging origin and snapshot volumes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/lib/activate/activate.c	2010/01/13 01:43:32	1.162
+++ LVM2/lib/activate/activate.c	2010/01/13 01:55:43	1.163
@@ -754,7 +754,7 @@
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv) && !(find_cow(lv)->status & SNAPSHOT_MERGE))
+	if (lv_is_cow(lv) && !lv_is_merging_cow(lv))
 		return monitor_dev_for_events(cmd, lv->snapshot->lv, monitor);
 
 	/*
--- LVM2/lib/activate/dev_manager.c	2010/01/13 01:54:34	1.171
+++ LVM2/lib/activate/dev_manager.c	2010/01/13 01:55:44	1.172
@@ -947,19 +947,20 @@
 					       struct logical_volume *lv)
 {
 	const char *origin_dlid, *cow_dlid, *merge_dlid;
+	struct lv_segment *merging_cow_seg = find_merging_cow(lv);
 
 	if (!(origin_dlid = build_dlid(dm, lv->lvid.s, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dlid(dm, lv->merging_snapshot->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dlid(dm, merging_cow_seg->cow->lvid.s, "cow")))
 		return_0;
 
-	if (!(merge_dlid = build_dlid(dm, lv->merging_snapshot->cow->lvid.s, NULL)))
+	if (!(merge_dlid = build_dlid(dm, merging_cow_seg->cow->lvid.s, NULL)))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_merge_target(dnode, lv->size, origin_dlid,
 						    cow_dlid, merge_dlid,
-						    lv->merging_snapshot->chunk_size))
+						    merging_cow_seg->chunk_size))
 		return_0;
 
 	return 1;
@@ -979,7 +980,8 @@
 		return 0;
 	}
 
-	if (snap_seg->status & SNAPSHOT_MERGE)
+	/* cow is to be merged so skip adding it */
+	if (lv_is_merging_cow(lv))
 		return 1;
 
 	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
@@ -1055,9 +1057,9 @@
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
 		}
-		if (seg->lv->merging_snapshot) {
+		if (lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
-			     seg->lv->merging_snapshot->cow, "cow"))
+			     find_merging_cow(seg->lv)->cow, "cow"))
 				return_0;
 			/*
 			 * Must also add "real" LV for use when
@@ -1080,7 +1082,7 @@
 
 	/* Now we've added its dependencies, we can add the target itself */
 	if (lv_is_origin(seg->lv) && !layer) {
-		if (!seg->lv->merging_snapshot) {
+		if (!lv_is_merging_origin(seg->lv)) {
 			if (!_add_origin_target_to_dtree(dm, dnode, seg->lv))
 				return_0;
 		} else {
@@ -1115,7 +1117,7 @@
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
-	if (lv_is_origin(lv) && lv->merging_snapshot && !layer) {
+	if (lv_is_origin(lv) && lv_is_merging_origin(lv) && !layer) {
 		/*
 		 * Clear merge attributes if merge isn't currently possible:
 		 * either origin or merging snapshot are open
@@ -1125,18 +1127,15 @@
 		 */
 		if ((dev_manager_info(dm->mem, NULL, lv,
 				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
-		    (dev_manager_info(dm->mem, NULL, lv->merging_snapshot->cow,
+		    (dev_manager_info(dm->mem, NULL, find_merging_cow(lv)->cow,
 				      0, 1, 0, &dinfo, NULL) && dinfo.open_count)) {
-			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge")) {
-				/* clear merge attributes */
-				lv->merging_snapshot->status &= ~SNAPSHOT_MERGE;
-				lv->merging_snapshot = NULL;
-			}
+			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge"))
+				clear_snapshot_merge(lv);
 		}
 	}
 
 	lv_name = lv->name;
-	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE) {
+	if (lv_is_cow(lv) && lv_is_merging_cow(lv)) {
 		if (layer) {
 			/*
 			 * use origin's name as basis for snapshot-merge device names;
--- LVM2/lib/metadata/lv_manip.c	2010/01/13 01:52:58	1.200
+++ LVM2/lib/metadata/lv_manip.c	2010/01/13 01:55:44	1.201
@@ -2127,7 +2127,7 @@
 
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
-		was_merging = !!origin->merging_snapshot;
+		was_merging = lv_is_merging_origin(origin);
 		log_verbose("Removing snapshot %s", lv->name);
 		if (!vg_remove_snapshot(lv))
 			return_0;
@@ -2953,7 +2953,7 @@
 					  "supported yet");
 				return 0;
 			}
-			if (org->merging_snapshot) {
+			if (lv_is_merging_origin(org)) {
 				log_error("Snapshots of an origin that has a "
 					  "merging snapshot is not supported");
 				return 0;
--- LVM2/lib/metadata/metadata-exported.h	2010/01/13 01:35:49	1.126
+++ LVM2/lib/metadata/metadata-exported.h	2010/01/13 01:55:44	1.127
@@ -616,12 +616,16 @@
 int lv_is_origin(const struct logical_volume *lv);
 int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
+int lv_is_merging_origin(const struct logical_volume *origin);
+int lv_is_merging_cow(const struct logical_volume *snapshot);
 
 /* Test if given LV is visible from user's perspective */
 int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
+struct lv_segment *find_merging_cow(const struct logical_volume *origin);
+
 /* Given a cow LV, return return the snapshot lv_segment that uses it */
 struct lv_segment *find_cow(const struct logical_volume *lv);
 
@@ -633,6 +637,8 @@
 
 void init_snapshot_merge(struct lv_segment *cow_seg, struct logical_volume *origin);
 
+void clear_snapshot_merge(struct logical_volume *origin);
+
 int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
 		    uint32_t chunk_size);
--- LVM2/lib/metadata/snapshot_manip.c	2010/01/13 01:35:49	1.45
+++ LVM2/lib/metadata/snapshot_manip.c	2010/01/13 01:55:44	1.46
@@ -37,7 +37,7 @@
 		if (lv_is_virtual_origin(origin_from_cow(lv)))
 			return 1;
 
-		if (find_cow(lv)->status & SNAPSHOT_MERGE)
+		if (lv_is_merging_cow(lv))
 			return 0;
 
 		return lv_is_visible(origin_from_cow(lv));
@@ -51,6 +51,21 @@
 	return (lv->status & VIRTUAL_ORIGIN) ? 1 : 0;
 }
 
+int lv_is_merging_origin(const struct logical_volume *origin)
+{
+	return origin->merging_snapshot ? 1 : 0;
+}
+
+struct lv_segment *find_merging_cow(const struct logical_volume *origin)
+{
+	return origin->merging_snapshot;
+}
+
+int lv_is_merging_cow(const struct logical_volume *snapshot)
+{
+	/* NOTE: use of find_cow() rather than find_merging_cow() */
+	return (find_cow(snapshot)->status & SNAPSHOT_MERGE) ? 1 : 0;
+}
 
 /* Given a cow LV, return the snapshot lv_segment that uses it */
 struct lv_segment *find_cow(const struct logical_volume *lv)
@@ -106,6 +121,13 @@
 	origin->merging_snapshot = cow_seg;
 }
 
+void clear_snapshot_merge(struct logical_volume *origin)
+{
+	/* clear merge attributes */
+	origin->merging_snapshot->status &= ~SNAPSHOT_MERGE;
+	origin->merging_snapshot = NULL;
+}
+
 int vg_add_snapshot(struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
@@ -143,10 +165,12 @@
 
 int vg_remove_snapshot(struct logical_volume *cow)
 {
+	struct logical_volume *origin = origin_from_cow(cow);
+
 	dm_list_del(&cow->snapshot->origin_list);
-	cow->snapshot->origin->origin_count--;
-	if (cow->snapshot->origin->merging_snapshot == cow->snapshot)
-		cow->snapshot->origin->merging_snapshot = NULL;
+	origin->origin_count--;
+	if (find_merging_cow(origin) == find_cow(cow))
+		clear_snapshot_merge(origin_from_cow(cow));
 
 	if (!lv_remove(cow->snapshot->lv)) {
 		log_error("Failed to remove internal snapshot LV %s",
--- LVM2/lib/report/report.c	2010/01/13 01:54:35	1.110
+++ LVM2/lib/report/report.c	2010/01/13 01:55:44	1.111
@@ -306,7 +306,7 @@
 		repstr[0] = 'v';
 	/* Origin takes precedence over Mirror */
 	else if (lv_is_origin(lv)) {
-		if (lv->merging_snapshot)
+		if (lv_is_merging_origin(lv))
 			repstr[0] = 'O';
 		else
 			repstr[0] = 'o';
@@ -324,7 +324,7 @@
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv)) {
-		if (find_cow(lv)->status & SNAPSHOT_MERGE)
+		if (lv_is_merging_cow(lv))
 			repstr[0] = 'S';
 		else
 			repstr[0] = 's';
@@ -1023,7 +1023,7 @@
 		return 0;
 	}
 
-	if ((!lv_is_cow(lv) && !lv->merging_snapshot) ||
+	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
 	    (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
@@ -1032,7 +1032,7 @@
 
 	if (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
 				 (percent_range == PERCENT_INVALID)) {
-		if (!lv->merging_snapshot) {
+		if (!lv_is_merging_origin(lv)) {
 			*sortval = UINT64_C(100);
 			dm_report_field_set_value(field, "100.00", sortval);
 		} else {
--- LVM2/tools/lvconvert.c	2010/01/13 01:54:35	1.113
+++ LVM2/tools/lvconvert.c	2010/01/13 01:55:44	1.114
@@ -377,7 +377,7 @@
 				   struct logical_volume *lv,
 				   struct dm_list *lvs_changed __attribute((unused)))
 {
-	struct lv_segment *snap_seg = lv->merging_snapshot;
+	struct lv_segment *snap_seg = find_merging_cow(lv);
 	if (!snap_seg) {
 		log_error("Logical volume %s has no merging snapshot.", lv->name);
 		return 0;
@@ -450,7 +450,7 @@
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
 
-	if (!lv->merging_snapshot)
+	if (!lv_is_merging_origin(lv))
 		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
 				   &_lvconvert_mirror_fns, "Converted");
 	else
@@ -1123,13 +1123,13 @@
 	struct lvinfo info;
 
 	/* Check if merge is possible */
-	if (cow_seg->status & SNAPSHOT_MERGE) {
+	if (lv_is_merging_cow(lv)) {
 		log_error("Snapshot %s is already merging", lv->name);
 		return 0;
 	}
-	if (origin->merging_snapshot) {
+	if (lv_is_merging_origin(origin)) {
 		log_error("Snapshot %s is already merging into the origin",
-			  origin->merging_snapshot->cow->name);
+			  find_merging_cow(origin)->cow->name);
 		return 0;
 	}
 
--- LVM2/tools/toollib.c	2010/01/13 01:50:34	1.182
+++ LVM2/tools/toollib.c	2010/01/13 01:55:44	1.183
@@ -1270,7 +1270,7 @@
 	 * - fortunately: polldaemon will immediately shutdown if the
 	 *   origin doesn't have a status with a snapshot percentage
 	 */
-	if (background_polling() && lv_is_origin(lv) && lv->merging_snapshot)
+	if (background_polling() && lv_is_origin(lv) && lv_is_merging_origin(lv))
 		lv_spawn_background_polling(cmd, lv);
 
 out:
@@ -1307,7 +1307,7 @@
 		pvmove_poll(cmd, pvname, 1);
 	}
 
-	if (lv->status & CONVERTING || lv->merging_snapshot) {
+	if (lv->status & CONVERTING || lv_is_merging_origin(lv)) {
 		log_verbose("Spawning background lvconvert process for %s",
 			lv->name);
 		lvconvert_poll(cmd, lv, 1);
--- LVM2/tools/vgchange.c	2010/01/13 01:50:34	1.96
+++ LVM2/tools/vgchange.c	2010/01/13 01:55:44	1.97
@@ -70,7 +70,7 @@
 
 		if (lv_active &&
 		    (lv->status & (PVMOVE|CONVERTING) ||
-		     lv->merging_snapshot)) {
+		     lv_is_merging_origin(lv))) {
 			lv_spawn_background_polling(cmd, lv);
 			count++;
 		}
@@ -141,7 +141,7 @@
 		if (background_polling() &&
 		    activate != CHANGE_AN && activate != CHANGE_ALN &&
 		    (lv->status & (PVMOVE|CONVERTING) ||
-		     lv->merging_snapshot))
+		     lv_is_merging_origin(lv)))
 			lv_spawn_background_polling(cmd, lv);
 
 		count++;


