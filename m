From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:30:36 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdm-deptree.c
Message-ID: <20100521123036.8843.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:30:35

Modified files:
	.              : WHATS_NEW 
	libdm          : libdm-deptree.c 

Log message:
	Replicator: check open_count for parents of presuspend_node
	
	For deactivation of Replicator check in advance that all heads
	have open_count == 0. For this presuspend_node is used as all
	head nodes are linking this control node.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1578&r2=1.1579
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/WHATS_NEW	2010/05/21 12:27:02	1.1578
+++ LVM2/WHATS_NEW	2010/05/21 12:30:35	1.1579
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Checking open_count in all parents of presuspend_node.
   Added dm_tree_node_set_presuspend_node() to presuspend child in deactivate.
   Initial libdm support for Replicator target (API is not stable yet).
   Extend process_each_lv_in_vg() with support for list of failed lvnames.
--- LVM2/libdm/libdm-deptree.c	2010/05/21 12:27:03	1.77
+++ LVM2/libdm/libdm-deptree.c	2010/05/21 12:30:35	1.78
@@ -902,6 +902,44 @@
 	return r;
 }
 
+/* Check if all parent nodes of given node have open_count == 0 */
+static int _node_has_closed_parents(struct dm_tree_node *node,
+				    const char *uuid_prefix,
+				    size_t uuid_prefix_len)
+{
+	struct dm_tree_link *dlink;
+	const struct dm_info *dinfo;
+	struct dm_info info;
+	const char *uuid;
+
+	/* Iterate through parents of this node */
+	dm_list_iterate_items(dlink, &node->used_by) {
+		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
+			stack;
+			continue;
+		}
+
+		/* Ignore if it doesn't belong to this VG */
+		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
+			continue;
+
+		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
+			stack;	/* FIXME Is this normal? */
+			return 0;
+		}
+
+		/* Refresh open_count */
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
+		    !info.exists)
+			continue;
+
+		if (info.open_count)
+			return 0;
+	}
+
+	return 1;
+}
+
 static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
 			    uint32_t *cookie, uint16_t udev_flags)
 {
@@ -1100,7 +1138,11 @@
 		    !info.exists)
 			continue;
 
-		if (info.open_count) {
+		/* Also checking open_count in parent nodes of presuspend_node */
+		if (info.open_count ||
+		    (child->presuspend_node &&
+		     !_node_has_closed_parents(child->presuspend_node,
+					       uuid_prefix, uuid_prefix_len))) {
 			/* Only report error from (likely non-internal) dependency at top level */
 			if (!level) {
 				log_error("Unable to deactivate open %s (%" PRIu32


