From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 14:40:39 -0000
Subject: LVM2 lib/metadata/metadata.c ./WHATS_NEW
Message-ID: <20110310144039.9093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 14:40:33

Modified files:
	lib/metadata   : metadata.c 
	.              : WHATS_NEW 

Log message:
	Refactor code for _lv_postoder
	
	Add _lv_postorder_vg() - for calling _lv_postorder() for every LV from VG.
	We use this in 2 places -  vg_mark_partial_lvs() and vg_validate()
	so make it as a one function.
	
	Benefit here is - to use only one cleanup code and avoid
	potentially duplicate scans of same LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.439&r2=1.440
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1942&r2=1.1943

--- LVM2/lib/metadata/metadata.c	2011/03/10 13:12:00	1.439
+++ LVM2/lib/metadata/metadata.c	2011/03/10 14:40:32	1.440
@@ -2039,6 +2039,29 @@
 	return r;
 }
 
+/*
+ * Calls _lv_postorder() on each LV from VG. Avoids duplicate transitivity visits.
+ * Clears with _lv_postorder_cleanup() when all LVs were visited by postorder.
+ */
+static int _lv_postorder_vg(struct volume_group *vg,
+			    int (*fn)(struct logical_volume *lv, void *data),
+			    void *data)
+{
+	struct lv_list *lvl;
+	int r = 1;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
+			stack;
+			r = 0;
+		}
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		_lv_postorder_cleanup(lvl->lv, 0);
+
+	return r;
+}
+
 struct _lv_mark_if_partial_baton {
 	int partial;
 };
@@ -2076,11 +2099,6 @@
 	return 1;
 }
 
-static int _lv_mark_if_partial(struct logical_volume *lv)
-{
-	return _lv_postorder(lv, _lv_mark_if_partial_single, NULL);
-}
-
 /*
  * Mark LVs with missing PVs using PARTIAL_LV status flag. The flag is
  * propagated transitively, so LVs referencing other LVs are marked
@@ -2088,14 +2106,9 @@
  */
 int vg_mark_partial_lvs(struct volume_group *vg)
 {
-	struct logical_volume *lv;
-	struct lv_list *lvl;
+	if (!_lv_postorder_vg(vg, _lv_mark_if_partial_single, NULL))
+		return_0;
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		lv = lvl->lv;
-		if (!_lv_mark_if_partial(lv))
-			return_0;
-	}
 	return 1;
 }
 
@@ -2378,9 +2391,9 @@
 	dm_hash_destroy(lvname_hash);
 	dm_hash_destroy(lvid_hash);
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!_lv_postorder(lvl->lv, _lv_validate_references_single, NULL))
-			r = 0;
+	if (!_lv_postorder_vg(vg, _lv_validate_references_single, NULL)) {
+		stack;
+		r = 0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
--- LVM2/WHATS_NEW	2011/03/10 13:11:59	1.1942
+++ LVM2/WHATS_NEW	2011/03/10 14:40:33	1.1943
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add _lv_postorder_vg() to improve efficiency for all LVs in VG.
   Use hash tables to speedup string search in validate_vg().
   Refactor allocation of VG structure, add alloc_vg().
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.


