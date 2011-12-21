From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:55:23 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111221125523.14780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:55:22

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Thin move layer suffix into local static const

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.253&r2=1.254

--- LVM2/lib/activate/dev_manager.c	2011/11/28 20:37:51	1.253
+++ LVM2/lib/activate/dev_manager.c	2011/12/21 12:55:22	1.254
@@ -59,6 +59,8 @@
 	const char *old_name;
 };
 
+static const char thin_layer[] = "tpool";
+
 static int _read_only_lv(struct logical_volume *lv)
 {
 	return (!(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
@@ -1140,7 +1142,7 @@
 		/* FIXME code from _create_partial_dtree() should be moved here */
 		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), origin_only))
 			return_0;
-		if (!_add_dev_to_dtree(dm, dtree, lv, "tpool"))
+		if (!_add_dev_to_dtree(dm, dtree, lv, thin_layer))
 			return_0;
 	} else if (lv_is_thin_volume(lv) &&
 		   !_add_lv_to_dtree(dm, dtree, seg->pool_lv, origin_only))
@@ -1489,7 +1491,6 @@
 	struct lv_segment *seg_present;
 	const char *target_name;
 	struct lv_activate_opts lva;
-	static const char tpool_layer[] = "tpool";
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
@@ -1534,11 +1535,11 @@
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
-	} else if ((layer != tpool_layer) && seg_is_thin(seg)) {
+	} else if ((layer != thin_layer) && seg_is_thin(seg)) {
 		lva = *laopts;
 		lva.real_pool = 1;
 		if (!_add_new_lv_to_dtree(dm, dtree, seg_is_thin_pool(seg) ?
-					  seg->lv : seg->pool_lv, &lva, tpool_layer))
+					  seg->lv : seg->pool_lv, &lva, thin_layer))
 			return_0;
 	} else {
 		if (seg_is_thin_pool(seg) &&


