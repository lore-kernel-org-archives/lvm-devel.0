From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 04:18:18 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20110811041818.6854.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 04:18:17

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Add RAID metadata devices to considered devices in _add_lv_to_dtree.
	
	_add_lv_to_dtree must also add RAID metadata devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2059&r2=1.2060
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.227&r2=1.228

--- LVM2/WHATS_NEW	2011/08/11 03:29:51	1.2059
+++ LVM2/WHATS_NEW	2011/08/11 04:18:17	1.2060
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add RAID metadata devices to considered devices in _add_lv_to_dtree.
   Fix renaming of RAID logical volumes.
   Replace free_vg with release_vg and move it to vg.c.
   Remove INCONSISTENT_VG flag from the code.
--- LVM2/lib/activate/dev_manager.c	2011/08/02 22:07:21	1.227
+++ LVM2/lib/activate/dev_manager.c	2011/08/11 04:18:17	1.228
@@ -1060,9 +1060,12 @@
 /*
  * Add LV and any known dependencies
  */
-static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, int origin_only)
+static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
+			    struct logical_volume *lv, int origin_only)
 {
+	uint32_t s;
 	struct seg_list *sl;
+	struct lv_segment *seg = first_seg(lv);
 
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
@@ -1074,10 +1077,16 @@
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
-	if ((lv->status & MIRRORED) && first_seg(lv)->log_lv &&
-	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
+	if ((lv->status & MIRRORED) && seg->log_lv &&
+	    !_add_dev_to_dtree(dm, dtree, seg->log_lv, NULL))
 		return_0;
 
+	if (lv->status & RAID)
+		for (s = 0; s < seg->area_count; s++)
+			if (!_add_lv_to_dtree(dm, dtree,
+					      seg_metalv(seg, s), origin_only))
+				return_0;
+
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
 	if (dm->track_pvmove_deps && lv->status & PVMOVE)
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)


