From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 May 2009 09:52:38 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20090520095238.12545.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-20 09:52:37

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c dev_manager.h 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 
	tools          : lvresize.c 

Log message:
	Use suspend with flush when device size was changed during table preload.
	
	This allows online mirror resize, also removes condition to preventing
	code to do this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1116&r2=1.1117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2009/05/19 10:38:58	1.1116
+++ LVM2/WHATS_NEW	2009/05/20 09:52:37	1.1117
@@ -1,5 +1,7 @@
 Version 2.02.46 - 
 ================================
+  Enable online resizing of mirrors.
+  Use suspend with flush when device size was changed during table preload.
   Introduce CLVMD_CMD_LOCK_QUERY command for clvmd.
   Use lvconvert --repair in dmeventd mirror DSO.
   Fix pvmove to revert operation if temporary mirror creation fails.
--- LVM2/lib/activate/activate.c	2009/05/19 10:39:00	1.148
+++ LVM2/lib/activate/activate.c	2009/05/20 09:52:37	1.149
@@ -589,7 +589,7 @@
 	return r;
 }
 
-static int _lv_preload(struct logical_volume *lv)
+static int _lv_preload(struct logical_volume *lv, int *flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -597,7 +597,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_preload(dm, lv)))
+	if (!(r = dev_manager_preload(dm, lv, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -619,7 +619,7 @@
 	return r;
 }
 
-static int _lv_suspend_lv(struct logical_volume *lv, int lockfs)
+static int _lv_suspend_lv(struct logical_volume *lv, int lockfs, int flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -627,7 +627,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_suspend(dm, lv, lockfs)))
+	if (!(r = dev_manager_suspend(dm, lv, lockfs, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -831,7 +831,7 @@
 {
 	struct logical_volume *lv = NULL, *lv_pre = NULL;
 	struct lvinfo info;
-	int r = 0, lockfs = 0;
+	int r = 0, lockfs = 0, flush_required = 0;
 
 	if (!activation())
 		return 1;
@@ -859,7 +859,7 @@
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
-		if (!_lv_preload(lv_pre)) {
+		if (!_lv_preload(lv_pre, &flush_required)) {
 			/* FIXME Revert preloading */
 			goto_out;
 		}
@@ -874,7 +874,7 @@
 	if (lv_is_origin(lv_pre) || lv_is_cow(lv_pre))
 		lockfs = 1;
 
-	if (!_lv_suspend_lv(lv, lockfs)) {
+	if (!_lv_suspend_lv(lv, lockfs, flush_required)) {
 		memlock_dec();
 		fs_unlock();
 		goto out;
--- LVM2/lib/activate/dev_manager.c	2009/05/13 14:13:55	1.148
+++ LVM2/lib/activate/dev_manager.c	2009/05/20 09:52:37	1.149
@@ -49,6 +49,7 @@
 
 	void *target_state;
 	uint32_t pvmove_mirror_count;
+	int flush_required;
 
 	char *vg_name;
 };
@@ -1164,7 +1165,7 @@
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if ((lv->status & MIRRORED) && !(lv->status & PVMOVE))
+		if (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE))
 			dm_tree_use_no_flush_suspend(root);
 	case SUSPEND_WITH_LOCKFS:
 		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
@@ -1180,6 +1181,9 @@
 		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
 
+		if (dm_tree_node_size_changed(root))
+			dm->flush_required = 1;
+
 		if ((action == ACTIVATE) &&
 		    !dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
@@ -1210,13 +1214,19 @@
 	return _tree_action(dm, lv, CLEAN);
 }
 
-int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv)
+int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
+			int *flush_required)
 {
 	/* FIXME Update the pvmove implementation! */
 	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
 		return 1;
 
-	return _tree_action(dm, lv, PRELOAD);
+	if (!_tree_action(dm, lv, PRELOAD))
+		return 0;
+
+	*flush_required = dm->flush_required;
+
+	return 1;
 }
 
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
@@ -1231,8 +1241,10 @@
 }
 
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			int lockfs)
+			int lockfs, int flush_required)
 {
+	dm->flush_required = flush_required;
+
 	return _tree_action(dm, lv, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
 }
 
--- LVM2/lib/activate/dev_manager.h	2007/11/12 20:51:53	1.28
+++ LVM2/lib/activate/dev_manager.h	2009/05/20 09:52:37	1.29
@@ -49,9 +49,10 @@
 			       struct logical_volume *lv, int wait,
 			       float *percent, uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			int lockfs);
+			int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv);
-int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv);
+int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
+			int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 
 int dev_manager_lv_mknodes(const struct logical_volume *lv);
--- LVM2/libdm/.exported_symbols	2008/11/03 20:03:00	1.34
+++ LVM2/libdm/.exported_symbols	2009/05/20 09:52:37	1.35
@@ -49,6 +49,7 @@
 dm_tree_node_get_uuid
 dm_tree_node_get_info
 dm_tree_node_get_context
+dm_tree_node_size_changed
 dm_tree_node_num_children
 dm_tree_node_num_parents
 dm_tree_find_node
--- LVM2/libdm/libdevmapper.h	2008/11/04 15:07:45	1.86
+++ LVM2/libdm/libdevmapper.h	2009/05/20 09:52:37	1.87
@@ -288,6 +288,7 @@
 const char *dm_tree_node_get_uuid(struct dm_tree_node *node);
 const struct dm_info *dm_tree_node_get_info(struct dm_tree_node *node);
 void *dm_tree_node_get_context(struct dm_tree_node *node);
+int dm_tree_node_size_changed(struct dm_tree_node *dnode);
 
 /*
  * Returns the number of children of the given node (excluding the root node).
--- LVM2/libdm/libdm-deptree.c	2008/12/12 18:45:58	1.49
+++ LVM2/libdm/libdm-deptree.c	2009/05/20 09:52:37	1.50
@@ -640,6 +640,11 @@
 	return node->context;
 }
 
+int dm_tree_node_size_changed(struct dm_tree_node *dnode)
+{
+	return dnode->props.size_changed;
+}
+
 int dm_tree_node_num_children(struct dm_tree_node *node, uint32_t inverted)
 {
 	if (inverted) {
@@ -1481,6 +1486,10 @@
 			}
 		}
 
+		/* Propagate device size change change */
+		if (child->props.size_changed)
+			dnode->props.size_changed = 1;
+
 		/* Resume device immediately if it has parents and its size changed */
 		if (!dm_tree_node_num_children(child, 1) || !child->props.size_changed)
 			continue;
--- LVM2/tools/lvresize.c	2009/04/21 14:31:58	1.107
+++ LVM2/tools/lvresize.c	2009/05/20 09:52:37	1.108
@@ -550,12 +550,6 @@
 		lp->resize = LV_EXTEND;
 	}
 
-	if (lp->mirrors && activation() &&
-	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-		log_error("Mirrors cannot be resized while active yet.");
-		return ECMD_FAILED;
-	}
-
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("Snapshot origin volumes cannot be reduced "


