From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:15:04 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111115171504.20211.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:15:04

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Thin fix tpool layer
	
	Since we support snapshots of thin volumes, we could have more layers,
	so we have to check whether tpool layer is going to be inserted.
	
	As the _add_segment_to_dtree() is the only place that adds tpool
	segment, we may just check pointer (no strcmp for layer).
	
	Switch to use  seg_is_  function instead of lv_is_.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.248&r2=1.249

--- LVM2/lib/activate/dev_manager.c	2011/11/03 14:52:09	1.248
+++ LVM2/lib/activate/dev_manager.c	2011/11/15 17:15:03	1.249
@@ -1455,6 +1455,7 @@
 	struct lv_segment *seg_present;
 	const char *target_name;
 	struct lv_activate_opts lva;
+	static const char tpool_layer[] = "tpool";
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
@@ -1499,15 +1500,14 @@
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
-	} else if (!layer && (lv_is_thin_pool(seg->lv) ||
-			      lv_is_thin_volume(seg->lv))) {
+	} else if ((layer != tpool_layer) && seg_is_thin(seg)) {
 		lva = *laopts;
 		lva.real_pool = 1;
-		if (!_add_new_lv_to_dtree(dm, dtree, lv_is_thin_pool(seg->lv) ?
-					  seg->lv : seg->pool_lv, &lva, "tpool"))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg_is_thin_pool(seg) ?
+					  seg->lv : seg->pool_lv, &lva, tpool_layer))
 			return_0;
 	} else {
-		if (lv_is_thin_pool(seg->lv) &&
+		if (seg_is_thin_pool(seg) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg->pool_metadata_lv, laopts, NULL))
 			return_0;
 


