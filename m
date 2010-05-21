From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:27:04 -0000
Subject: LVM2 ./WHATS_NEW libdm/.exported_symbols libdm ...
Message-ID: <20100521122704.7926.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:27:03

Modified files:
	.              : WHATS_NEW 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 

Log message:
	Replicator: support deactivate of replicator-dev nodes
	
	Introducing dm_tree_node_set_presuspend_node() for presuspending child
	node (i.e. replicator control target) before deactivation of parent node
	(i.e. replicator-dev target).
	
	This patch presents no functional change to current dtree - only
	replicator target currently sets presuspend node for dev nodes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1577&r2=1.1578
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/WHATS_NEW	2010/05/21 12:24:15	1.1577
+++ LVM2/WHATS_NEW	2010/05/21 12:27:02	1.1578
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Added dm_tree_node_set_presuspend_node() to presuspend child in deactivate.
   Initial libdm support for Replicator target (API is not stable yet).
   Extend process_each_lv_in_vg() with support for list of failed lvnames.
   Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv().
--- LVM2/libdm/.exported_symbols	2010/05/21 12:24:15	1.53
+++ LVM2/libdm/.exported_symbols	2010/05/21 12:27:03	1.54
@@ -82,6 +82,7 @@
 dm_tree_node_add_target_area
 dm_tree_node_add_replicator_target
 dm_tree_node_add_replicator_dev_target
+dm_tree_node_set_presuspend_node
 dm_tree_node_set_read_ahead
 dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
--- LVM2/libdm/libdevmapper.h	2010/05/21 12:24:15	1.114
+++ LVM2/libdm/libdevmapper.h	2010/05/21 12:27:03	1.115
@@ -474,6 +474,9 @@
 					   uint32_t slog_region_size);
 /* End of Replicator API */
 
+void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
+				      struct dm_tree_node *presuspend_node);
+
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
 				    const char *dev_name,
 				    const char *dlid,
--- LVM2/libdm/libdm-deptree.c	2010/05/21 12:24:15	1.76
+++ LVM2/libdm/libdm-deptree.c	2010/05/21 12:27:03	1.77
@@ -168,6 +168,12 @@
 	void *context;			/* External supplied context */
 
 	struct load_properties props;	/* For creation/table (re)load */
+
+	/*
+	 * If presuspend of child node is needed
+	 * Note: only direct child is allowed
+	 */
+	struct dm_tree_node *presuspend_node;
 };
 
 struct dm_tree {
@@ -684,6 +690,12 @@
 	dnode->props.read_ahead_flags = read_ahead_flags;
 }
 
+void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
+				      struct dm_tree_node *presuspend_node)
+{
+	node->presuspend_node = presuspend_node;
+}
+
 int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
 {
 	return _add_dev(dtree, &dtree->root, major, minor, 0) ? 1 : 0;
@@ -794,6 +806,10 @@
 		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
 			continue;
 
+		/* Ignore if parent node wants to presuspend this node */
+		if (dlink->node->presuspend_node == node)
+			continue;
+
 		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
 			stack;	/* FIXME Is this normal? */
 			return 0;
@@ -1095,6 +1111,11 @@
 			continue;
 		}
 
+		/* Suspend child node first if requested */
+		if (child->presuspend_node &&
+		    !dm_tree_suspend_children(child, uuid_prefix, uuid_prefix_len))
+			continue;
+
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32


