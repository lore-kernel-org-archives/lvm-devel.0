From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 11:43:28 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20100401114328.13587.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 11:43:27

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Improve vg_validate to detect some loops in lists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1499&r2=1.1500
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.326&r2=1.327

--- LVM2/WHATS_NEW	2010/04/01 10:34:09	1.1499
+++ LVM2/WHATS_NEW	2010/04/01 11:43:24	1.1500
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Improve vg_validate to detect some loops in lists.
   Change most remaining log_error WARNING messages to log_warn.
   Always use blocking lock for VGs and orphan locks.
   Allocate all segments memory from vg private mempool.
--- LVM2/lib/metadata/metadata.c	2010/03/31 17:21:40	1.326
+++ LVM2/lib/metadata/metadata.c	2010/04/01 11:43:26	1.327
@@ -2129,12 +2129,28 @@
 	struct lv_list *lvl, *lvl2;
 	char uuid[64] __attribute((aligned(8)));
 	int r = 1;
-	uint32_t hidden_lv_count = 0;
+	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
+	uint32_t pv_count = 0;
+	uint32_t num_snapshots = 0;
+	uint32_t loop_counter1, loop_counter2;
 
 	/* FIXME Also check there's no data/metadata overlap */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (++pv_count > vg->pv_count) {
+			log_error(INTERNAL_ERROR "PV list corruption detected in VG %s.", vg->name);
+			/* FIXME Dump list structure? */
+			r = 0;
+		}
+	}
 
+	loop_counter1 = loop_counter2 = 0;
+	/* FIXME Use temp hash table instead? */
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (++loop_counter1 > pv_count)
+			break;
 		dm_list_iterate_items(pvl2, &vg->pvs) {
+			if (++loop_counter2 > pv_count)
+				break;
 			if (pvl == pvl2)
 				break;
 			if (id_equal(&pvl->pv->id,
@@ -2167,6 +2183,14 @@
 	 * Count all non-snapshot invisible LVs
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv_count++;
+
+		if (lv_is_cow(lvl->lv))
+			num_snapshots++;
+
+		if (lv_is_visible(lvl->lv))
+			lv_visible_count++;
+
 		if (lvl->lv->status & VISIBLE_LV)
 			continue;
 
@@ -2192,17 +2216,22 @@
 	/*
 	 * all volumes = visible LVs + snapshot_cows + invisible LVs
 	 */
-	if (((uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg_visible_lvs(vg) + snapshot_count(vg) + hidden_lv_count) {
+	if (lv_count != lv_visible_count + num_snapshots + hidden_lv_count) {
 		log_error(INTERNAL_ERROR "#internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs (%u) in VG %s",
-			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
-			  snapshot_count(vg), hidden_lv_count, vg->name);
+			  lv_count, lv_visible_count,
+			  num_snapshots, hidden_lv_count, vg->name);
 		r = 0;
 	}
 
+	loop_counter1 = loop_counter2 = 0;
+	/* FIXME Use temp hash table instead? */
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (++loop_counter1 > lv_count)
+			break;
 		dm_list_iterate_items(lvl2, &vg->lvs) {
+			if (++loop_counter2 > lv_count)
+				break;
 			if (lvl == lvl2)
 				break;
 			if (!strcmp(lvl->lv->name, lvl2->lv->name)) {
@@ -2223,9 +2252,7 @@
 				r = 0;
 			}
 		}
-	}
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
@@ -2889,6 +2916,15 @@
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!check_lv_segments(lvl->lv, 0)) {
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
+				  lvl->lv->name);
+			vg_release(vg);
+			return NULL;
+		}
+		/*
+		 * Checks that cross-reference other LVs.
+		 */
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);


