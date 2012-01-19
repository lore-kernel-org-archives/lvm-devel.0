From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:19:19 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20120119151919.24655.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:19:18

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Thin rename local static
	
	Use '_' for local const char.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.257&r2=1.258

--- LVM2/lib/activate/dev_manager.c	2012/01/12 01:51:56	1.257
+++ LVM2/lib/activate/dev_manager.c	2012/01/19 15:19:18	1.258
@@ -59,7 +59,7 @@
 	const char *old_name;
 };
 
-static const char thin_layer[] = "tpool";
+static const char _thin_layer[] = "tpool";
 
 int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
@@ -879,13 +879,12 @@
 	char *name;
 	const char *dlid;
 
-	/*
-	 * Build a name for the top layer.
-	 */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, thin_layer)))
+	/* Build a name for the top layer */
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name,
+				      _thin_layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, thin_layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
 		return_0;
 
 	log_debug("Getting device status percentage for %s", name);
@@ -1166,7 +1165,7 @@
 		/* FIXME code from _create_partial_dtree() should be moved here */
 		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), origin_only))
 			return_0;
-		if (!_add_dev_to_dtree(dm, dtree, lv, thin_layer))
+		if (!_add_dev_to_dtree(dm, dtree, lv, _thin_layer))
 			return_0;
 	} else if (lv_is_thin_volume(lv) &&
 		   !_add_lv_to_dtree(dm, dtree, seg->pool_lv, origin_only))
@@ -1559,11 +1558,11 @@
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
-	} else if ((layer != thin_layer) && seg_is_thin(seg)) {
+	} else if ((layer != _thin_layer) && seg_is_thin(seg)) {
 		lva = *laopts;
 		lva.real_pool = 1;
 		if (!_add_new_lv_to_dtree(dm, dtree, seg_is_thin_pool(seg) ?
-					  seg->lv : seg->pool_lv, &lva, thin_layer))
+					  seg->lv : seg->pool_lv, &lva, _thin_layer))
 			return_0;
 	} else {
 		if (seg_is_thin_pool(seg) &&


