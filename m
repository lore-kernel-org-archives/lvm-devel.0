From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Sep 2009 18:50:29 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20090929185029.28852.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-29 18:50:29

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Don't attempt to deactivate an LV if any of its snapshots are in use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1278&r2=1.1279
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/WHATS_NEW	2009/09/29 15:17:54	1.1278
+++ LVM2/WHATS_NEW	2009/09/29 18:50:28	1.1279
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Don't attempt to deactivate an LV if any of its snapshots are in use.
   Return fail if lv_deactivate fails to remove device from kernel.
   Provide alternative implementation of obsolete siginterrupt().
   Consolidate LV allocation into alloc_lv().
--- LVM2/lib/activate/activate.c	2009/09/29 15:17:54	1.154
+++ LVM2/lib/activate/activate.c	2009/09/29 18:50:28	1.155
@@ -975,6 +975,29 @@
 	return _lv_resume(cmd, lvid_s, 1);
 }
 
+static int _lv_has_open_snapshots(struct logical_volume *lv)
+{
+	struct lv_segment *snap_seg;
+	struct lvinfo info;
+	int r = 0;
+
+	dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
+		if (!lv_info(lv->vg->cmd, snap_seg->cow, &info, 1, 0)) {
+			r = 1;
+			continue;
+		}
+
+		if (info.exists && info.open_count) {
+			log_error("LV %s/%s has open snapshot %s: "
+				  "not deactivating", lv->vg->name, lv->name,
+				  snap_seg->cow->name);
+			r = 1;
+		}
+	}
+
+	return r;
+}
+
 int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 {
 	struct logical_volume *lv;
@@ -1001,10 +1024,14 @@
 		goto out;
 	}
 
-	if (info.open_count && lv_is_visible(lv)) {
-		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
-			  lv->name);
-		goto out;
+	if (lv_is_visible(lv)) {
+		if (info.open_count) {
+			log_error("LV %s/%s in use: not deactivating",
+				  lv->vg->name, lv->name);
+			goto out;
+		}
+		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
+			goto_out;
 	}
 
 	lv_calculate_readahead(lv, NULL);


