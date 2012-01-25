From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jan 2012 11:10:07 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20120125111007.16816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-25 11:10:07

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Make commented out code more obvious

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.267&r2=1.268

--- LVM2/lib/activate/dev_manager.c	2012/01/25 09:10:14	1.267
+++ LVM2/lib/activate/dev_manager.c	2012/01/25 11:10:06	1.268
@@ -1201,10 +1201,11 @@
 	uint32_t s;
 	struct seg_list *sl;
 	struct lv_segment *seg = first_seg(lv);
-	/* FIXME: Resolve skip_childrens
+#if 0
+	/* FIXME For dm_tree_node_skip_children optimisation below */
 	struct dm_tree_node *thin_node;
 	const char *uuid;
-	*/
+#endif
 
 	if ((!origin_only || lv_is_thin_volume(lv)) &&
 	    !_add_dev_to_dtree(dm, dtree, lv, NULL))
@@ -1239,14 +1240,15 @@
 		return_0;
 
 	if (lv_is_thin_volume(lv)) {
-		/* FIXME: Resolve skip_childrens
+#if 0
+		/* FIXME Implement dm_tree_node_skip_children optimisation */
 		if (origin_only) {
 			if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
 				return_0;
 			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
-				dm_tree_node_skip_childrens(thin_node, 1);
+				dm_tree_node_skip_children(thin_node, 1);
 		}
-		*/
+#endif
 		/* Add thin pool LV layer */
 		lv = seg->pool_lv;
 		seg = first_seg(lv);


