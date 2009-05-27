From: agk@sourceware.org <agk@sourceware.org>
Date: 27 May 2009 13:19:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090527131935.31284.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-27 13:19:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Fix counting of virtual origin LVs in vg_validate. (mbroz)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1125&r2=1.1126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.221&r2=1.222

--- LVM2/WHATS_NEW	2009/05/27 13:05:53	1.1125
+++ LVM2/WHATS_NEW	2009/05/27 13:19:34	1.1126
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix counting of virtual origin LVs in vg_validate.
   Attempt to load dm-zero module if zero target needed but not present.
 
 Version 2.02.47 - 22nd May 2009
--- LVM2/lib/metadata/metadata.c	2009/05/21 03:04:53	1.221
+++ LVM2/lib/metadata/metadata.c	2009/05/27 13:19:34	1.222
@@ -1449,7 +1449,7 @@
 	struct lv_list *lvl, *lvl2;
 	char uuid[64] __attribute((aligned(8)));
 	int r = 1;
-	uint32_t lv_count;
+	uint32_t hidden_lv_count = 0;
 
 	/* FIXME Also check there's no data/metadata overlap */
 
@@ -1486,17 +1486,20 @@
 	/*
 	 * Count all non-snapshot invisible LVs
 	 */
-	lv_count = 0;
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & VISIBLE_LV)
 			continue;
 
 		/* snapshots */
-		if (lv_is_cow(lvl->lv) || lv_is_origin(lvl->lv))
+		if (lv_is_cow(lvl->lv))
+			continue;
+
+		/* virtual origins are always hidden */
+		if (lv_is_origin(lvl->lv) && !lv_is_virtual_origin(lvl->lv))
 			continue;
 
 		/* count other non-snapshot invisible volumes */
-		lv_count++;
+		hidden_lv_count++;
 
 		/*
 		 *  FIXME: add check for unreferenced invisible LVs
@@ -1510,11 +1513,11 @@
 	 * all volumes = visible LVs + snapshot_cows + invisible LVs
 	 */
 	if (((uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg_visible_lvs(vg) + snapshot_count(vg) + lv_count) {
+	    vg_visible_lvs(vg) + snapshot_count(vg) + hidden_lv_count) {
 		log_error("Internal error: #internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + #snapshots (%" PRIu32 ") + #invisible LVs %u in VG %s",
+			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs %u in VG %s",
 			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
-			  snapshot_count(vg), lv_count, vg->name);
+			  snapshot_count(vg), hidden_lv_count, vg->name);
 		r = 0;
 	}
 


