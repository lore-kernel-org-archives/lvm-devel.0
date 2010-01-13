From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:56 +0100
Subject: [PATCH 5/6] Cleanup const compiler warning in devmapper
In-Reply-To: <cover.1263389392.git.zkabelac@redhat.com>
References: <cover.1263389392.git.zkabelac@redhat.com>
Message-ID: <df493494a26c9064bd9d49149d73f118283b66c5.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Cleanup gcc warnings:

warning: cast discards qualifiers from pointer target type

API of the library should remain the same as the 'const' is not
mangled into function header for C.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h  |   16 ++++++++--------
 libdm/libdm-deptree.c |   22 +++++++++++-----------
 tools/dmsetup.c       |   10 ++++++----
 3 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 579cc14..eb5f156 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -307,23 +307,23 @@ struct dm_tree_node *dm_tree_find_node_by_uuid(struct dm_tree *tree,
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
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 7ec5fd2..e4bf9b3 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -201,8 +201,8 @@ void dm_tree_free(struct dm_tree *dtree)
 	dm_free(dtree);
 }
 
-static int _nodes_are_linked(struct dm_tree_node *parent,
-			     struct dm_tree_node *child)
+static int _nodes_are_linked(const struct dm_tree_node *parent,
+			     const struct dm_tree_node *child)
 {
 	struct dm_tree_link *dlink;
 
@@ -665,32 +665,32 @@ int dm_tree_add_dev_with_udev_flags(struct dm_tree *dtree, uint32_t major,
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
@@ -806,11 +806,11 @@ struct dm_tree_node *dm_tree_find_node_by_uuid(struct dm_tree *dtree,
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
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d62e147..78c719e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2094,7 +2094,7 @@ static int _dm_info_devno_disp(struct dm_report *rh, struct dm_pool *mem,
 			       void *private)
 {
 	char buf[DM_MAX_TYPE_NAME], *repstr;
-	struct dm_info *info = (struct dm_info *) data;
+	const struct dm_info *info = data;
 
 	if (!dm_pool_begin_object(mem, 8)) {
 		log_error("dm_pool_begin_object failed");
@@ -2125,7 +2125,8 @@ static int _dm_tree_names(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field, const void *data,
 			  void *private, unsigned inverted)
 {
-	struct dm_tree_node *node = (struct dm_tree_node *) data, *parent;
+	const struct dm_tree_node *node = data;
+	struct dm_tree_node *parent;
 	void *t = NULL;
 	const char *name;
 	int first_node = 1;
@@ -2186,7 +2187,8 @@ static int _dm_tree_parents_devs_disp(struct dm_report *rh, struct dm_pool *mem,
 				      struct dm_report_field *field,
 				      const void *data, void *private)
 {
-	struct dm_tree_node *node = (struct dm_tree_node *) data, *parent;
+	const struct dm_tree_node *node = data;
+	struct dm_tree_node *parent;
 	void *t = NULL;
 	const struct dm_info *info;
 	int first_node = 1;
@@ -2237,7 +2239,7 @@ static int _dm_tree_parents_count_disp(struct dm_report *rh,
 				       struct dm_report_field *field,
 				       const void *data, void *private)
 {
-	struct dm_tree_node *node = (struct dm_tree_node *) data;
+	const struct dm_tree_node *node = data;
 	int num_parent = dm_tree_node_num_children(node, 1);
 
 	return dm_report_field_int(rh, field, &num_parent);
-- 
1.6.6


