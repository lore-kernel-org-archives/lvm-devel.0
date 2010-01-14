From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Jan 2010 14:39:58 -0000
Subject: LVM2/lib activate/dev_manager.c metadata/lv_ma ...
Message-ID: <20100114143958.7601.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-14 14:39:58

Modified files:
	lib/activate   : dev_manager.c 
	lib/metadata   : lv_manip.c 
	lib/snapshot   : snapshot.c 

Log message:
	Note some problems still to be addressed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.205&r2=1.206
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/lib/activate/dev_manager.c	2010/01/13 01:55:44	1.172
+++ LVM2/lib/activate/dev_manager.c	2010/01/14 14:39:57	1.173
@@ -327,6 +327,7 @@
 	return 0;
 }
 
+/* FIXME Is there anything simpler to check for instead? */
 static int _lv_has_target_type(struct dev_manager *dm,
 			       struct logical_volume *lv,
 			       const char *layer,
@@ -362,6 +363,7 @@
 					  &type, &params);
 		if (type && strncmp(type, target_type,
 				    strlen(target_type)) == 0) {
+			/* FIXME Why the inactive test? */
 			if (info.live_table && !info.inactive_table)
 				r = 1;
 			break;
@@ -447,6 +449,7 @@
                  * - allows the situation when 'type' is "snapshot-merge" and
                  *   'target_type' is "snapshot"
                  */
+		/* FIXME Do this properly - relying on target prefixes is incorrect. (E.g. snapshot-origin)*/
 		if (!type || !params || strncmp(type, target_type, strlen(target_type)))
 			continue;
 
@@ -1051,7 +1054,7 @@
 		return_0;
 
 	/* If this is a snapshot origin, add real LV */
-	/* If this is a snapshot origin w/ merging snapshot, add cow and real LV */
+	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
@@ -1117,6 +1120,8 @@
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
+	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */
+
 	if (lv_is_origin(lv) && lv_is_merging_origin(lv) && !layer) {
 		/*
 		 * Clear merge attributes if merge isn't currently possible:
@@ -1125,6 +1130,7 @@
 		 *   existing nodes' info isn't an option
 		 * - but use "snapshot-merge" if it is already being used
 		 */
+		/* FIXME Avoid this - open_count is always returned by kernel now. */
 		if ((dev_manager_info(dm->mem, NULL, lv,
 				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
 		    (dev_manager_info(dm->mem, NULL, find_merging_cow(lv)->cow,
--- LVM2/lib/metadata/lv_manip.c	2010/01/14 10:17:12	1.205
+++ LVM2/lib/metadata/lv_manip.c	2010/01/14 14:39:57	1.206
@@ -2142,6 +2142,7 @@
 	if (!vg_write(vg))
 		return_0;
 
+	/* FIXME Seek a simpler way of dealing with this within the tree. */
 	/* If no snapshots left or if we stopped merging, reload */
 	if (origin && (!lv_is_origin(origin) || was_merging)) {
 		if (!suspend_lv(cmd, origin)) {
--- LVM2/lib/snapshot/snapshot.c	2010/01/13 01:56:18	1.42
+++ LVM2/lib/snapshot/snapshot.c	2010/01/14 14:39:58	1.43
@@ -46,10 +46,10 @@
 
 	old_suppress = log_suppress(1);
 
-	cow_name = find_config_str(sn, "merging_store", NULL);
-	if (cow_name) {
+	/* FIXME Detect case of both merging_store and cow_store supplied */
+	if ((cow_name = find_config_str(sn, "merging_store", NULL)))
 		merge = 1;
-	} else if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
+	else if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
 		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");
 		return 0;


