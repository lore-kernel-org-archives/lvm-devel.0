From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:15:24 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-deptree. ...
Message-ID: <20100114101524.30492.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:15:23

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 
	tools          : dmsetup.c 

Log message:
	Cleanup gcc warning: cast discards qualifiers from pointer target type
	
	API of the library should remain the same as the 'const' is not
	mangled into the function name in C.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/libdm/libdevmapper.h	2010/01/14 10:12:44	1.107
+++ LVM2/libdm/libdevmapper.h	2010/01/14 10:15:23	1.108
@@ -307,23 +307,23 @@
  * Set inverted to use inverted tree.
  */
 struct dm_tree_node *dm_tree_next_child(void **handle,
-					   struct dm_tree_node *parent,
-					   uint32_t inverted);
+					const struct dm_tree_node *parent,
+					uint32_t inverted);
 
 /*
  * Get properties of a node.
  */
-const char *dm_tree_node_get_name(struct dm_tree_node *node);
-const char *dm_tree_node_get_uuid(struct dm_tree_node *node);
-const struct dm_info *dm_tree_node_get_info(struct dm_tree_node *node);
-void *dm_tree_node_get_context(struct dm_tree_node *node);
-int dm_tree_node_size_changed(struct dm_tree_node *dnode);
+const char *dm_tree_node_get_name(const struct dm_tree_node *node);
+const char *dm_tree_node_get_uuid(const struct dm_tree_node *node);
+const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node);
+void *dm_tree_node_get_context(const struct dm_tree_node *node);
+int dm_tree_node_size_changed(const struct dm_tree_node *dnode);
 
 /*
  * Returns the number of children of the given node (excluding the root node).
  * Set inverted for the number of parents.
  */
-int dm_tree_node_num_children(struct dm_tree_node *node, uint32_t inverted);
+int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted);
 
 /*
  * Deactivate a device plus all dependencies.
--- LVM2/libdm/libdm-deptree.c	2010/01/13 01:39:45	1.69
+++ LVM2/libdm/libdm-deptree.c	2010/01/14 10:15:23	1.70
@@ -201,8 +201,8 @@
 	dm_free(dtree);
 }
 
-static int _nodes_are_linked(struct dm_tree_node *parent,
-			     struct dm_tree_node *child)
+static int _nodes_are_linked(const struct dm_tree_node *parent,
+			     const struct dm_tree_node *child)
 {
 	struct dm_tree_link *dlink;
 
@@ -665,32 +665,32 @@
 	return _add_dev(dtree, &dtree->root, major, minor, udev_flags) ? 1 : 0;
 }
 
-const char *dm_tree_node_get_name(struct dm_tree_node *node)
+const char *dm_tree_node_get_name(const struct dm_tree_node *node)
 {
 	return node->info.exists ? node->name : "";
 }
 
-const char *dm_tree_node_get_uuid(struct dm_tree_node *node)
+const char *dm_tree_node_get_uuid(const struct dm_tree_node *node)
 {
 	return node->info.exists ? node->uuid : "";
 }
 
-const struct dm_info *dm_tree_node_get_info(struct dm_tree_node *node)
+const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node)
 {
 	return &node->info;
 }
 
-void *dm_tree_node_get_context(struct dm_tree_node *node)
+void *dm_tree_node_get_context(const struct dm_tree_node *node)
 {
 	return node->context;
 }
 
-int dm_tree_node_size_changed(struct dm_tree_node *dnode)
+int dm_tree_node_size_changed(const struct dm_tree_node *dnode)
 {
 	return dnode->props.size_changed;
 }
 
-int dm_tree_node_num_children(struct dm_tree_node *node, uint32_t inverted)
+int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted)
 {
 	if (inverted) {
 		if (_nodes_are_linked(&node->dtree->root, node))
@@ -806,11 +806,11 @@
  * Set inverted to invert the tree.
  */
 struct dm_tree_node *dm_tree_next_child(void **handle,
-					   struct dm_tree_node *parent,
-					   uint32_t inverted)
+					const struct dm_tree_node *parent,
+					uint32_t inverted)
 {
 	struct dm_list **dlink = (struct dm_list **) handle;
-	struct dm_list *use_list;
+	const struct dm_list *use_list;
 
 	if (inverted)
 		use_list = &parent->used_by;
--- LVM2/tools/dmsetup.c	2010/01/11 15:36:25	1.132
+++ LVM2/tools/dmsetup.c	2010/01/14 10:15:23	1.133
@@ -2094,7 +2094,7 @@
 			       void *private)
 {
 	char buf[DM_MAX_TYPE_NAME], *repstr;
-	struct dm_info *info = (struct dm_info *) data;
+	const struct dm_info *info = data;
 
 	if (!dm_pool_begin_object(mem, 8)) {
 		log_error("dm_pool_begin_object failed");
@@ -2125,7 +2125,8 @@
 			  struct dm_report_field *field, const void *data,
 			  void *private, unsigned inverted)
 {
-	struct dm_tree_node *node = (struct dm_tree_node *) data, *parent;
+	const struct dm_tree_node *node = data;
+	struct dm_tree_node *parent;
 	void *t = NULL;
 	const char *name;
 	int first_node = 1;
@@ -2186,7 +2187,8 @@
 				      struct dm_report_field *field,
 				      const void *data, void *private)
 {
-	struct dm_tree_node *node = (struct dm_tree_node *) data, *parent;
+	const struct dm_tree_node *node = data;
+	struct dm_tree_node *parent;
 	void *t = NULL;
 	const struct dm_info *info;
 	int first_node = 1;
@@ -2237,7 +2239,7 @@
 				       struct dm_report_field *field,
 				       const void *data, void *private)
 {
-	struct dm_tree_node *node = (struct dm_tree_node *) data;
+	const struct dm_tree_node *node = data;
 	int num_parent = dm_tree_node_num_children(node, 1);
 
 	return dm_report_field_int(rh, field, &num_parent);


