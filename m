From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:10:14 -0000
Subject: LVM2/lib/activate activate.c dev_manager.c
Message-ID: <20120125091014.30183.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:10:14

Modified files:
	lib/activate   : activate.c dev_manager.c 

Log message:
	Thin add support for origin_only suspend of thin volumes
	
	Pass in the origin_only flag also for thin volumes - but curently the flag
	is not used to its best.
	
	FIXME: achieve the state where only  thin volume snapshot origin is
	suspended without its childrens -  let's explore whether this may
	happen automatically inside libdm (might be generic for other targets).
	So the code would not need to annotate the node for this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.266&r2=1.267

--- LVM2/lib/activate/activate.c	2012/01/25 09:00:18	1.236
+++ LVM2/lib/activate/activate.c	2012/01/25 09:10:13	1.237
@@ -1344,7 +1344,7 @@
 		goto_out;
 
 	/* Ignore origin_only unless LV is origin in both old and new metadata */
-	if (!lv_is_origin(lv) || !lv_is_origin(lv_pre))
+	if (!lv_is_thin_volume(lv) && !(lv_is_origin(lv) && lv_is_origin(lv_pre)))
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
--- LVM2/lib/activate/dev_manager.c	2012/01/25 09:06:43	1.266
+++ LVM2/lib/activate/dev_manager.c	2012/01/25 09:10:14	1.267
@@ -1201,8 +1201,13 @@
 	uint32_t s;
 	struct seg_list *sl;
 	struct lv_segment *seg = first_seg(lv);
+	/* FIXME: Resolve skip_childrens
+	struct dm_tree_node *thin_node;
+	const char *uuid;
+	*/
 
-	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
+	if ((!origin_only || lv_is_thin_volume(lv)) &&
+	    !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
 	/* FIXME Can we avoid doing this every time? */
@@ -1233,17 +1238,29 @@
 	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
 		return_0;
 
+	if (lv_is_thin_volume(lv)) {
+		/* FIXME: Resolve skip_childrens
+		if (origin_only) {
+			if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+				return_0;
+			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
+				dm_tree_node_skip_childrens(thin_node, 1);
+		}
+		*/
+		/* Add thin pool LV layer */
+		lv = seg->pool_lv;
+		seg = first_seg(lv);
+	}
+
 	if (lv_is_thin_pool(lv)) {
-		if (!_add_lv_to_dtree(dm, dtree, seg->metadata_lv, origin_only))
+		if (!_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
 		/* FIXME code from _create_partial_dtree() should be moved here */
-		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), origin_only))
+		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), 0))
 			return_0;
 		if (!_add_dev_to_dtree(dm, dtree, lv, _thin_layer))
 			return_0;
-	} else if (lv_is_thin_volume(lv) &&
-		   !_add_lv_to_dtree(dm, dtree, seg->pool_lv, origin_only))
-		return_0;
+	}
 
 	return 1;
 }
@@ -1260,7 +1277,7 @@
 		return NULL;
 	}
 
-	if (!_add_lv_to_dtree(dm, dtree, lv, lv_is_origin(lv) ? origin_only : 0))
+	if (!_add_lv_to_dtree(dm, dtree, lv, (lv_is_origin(lv) || lv_is_thin_volume(lv)) ? origin_only : 0))
 		goto_bad;
 
 	/* Add any snapshots of this LV */


