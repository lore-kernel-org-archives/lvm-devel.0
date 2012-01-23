From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2012 17:46:34 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-deptree. ...
Message-ID: <20120123174634.17457.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-23 17:46:32

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 
	lib/metadata   : thin_manip.c 
	lib/config     : config.c 
	lib/commands   : toolcontext.c 

Log message:
	Reorder fns in libdm-deptree.
	Tweak dm_config interface and remove FIXMEs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/libdm/libdevmapper.h	2012/01/19 15:21:23	1.176
+++ LVM2/libdm/libdevmapper.h	2012/01/23 17:46:31	1.177
@@ -1337,26 +1337,26 @@
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
-
 /*************************
  * config file parse/print
  *************************/
-// FIXME AGK Review this interface before inclusion in a release.
-enum {
-	DM_CFG_STRING,
-	DM_CFG_FLOAT,
+typedef enum {
 	DM_CFG_INT,
+	DM_CFG_FLOAT,
+	DM_CFG_STRING,
 	DM_CFG_EMPTY_ARRAY
-};
+} dm_config_value_type_t;
 
 struct dm_config_value {
-	int type;
+	dm_config_value_type_t type;
+
 	union {
 		int64_t i;
 		float f;
-		double d;	/* For completeness.  (Unused.) */
+		double d;       	/* Unused. */
 		const char *str;
 	} v;
+
 	struct dm_config_value *next;	/* For arrays */
 };
 
@@ -1366,7 +1366,6 @@
 	struct dm_config_value *v;
 };
 
-/* FIXME Move cascade to dm_config_node and remove this struct */
 struct dm_config_tree {
 	struct dm_config_node *root;
 	struct dm_config_tree *cascade;
@@ -1382,22 +1381,22 @@
 void dm_config_set_custom(struct dm_config_tree *cft, void *custom);
 
 /*
- * If there's a cascaded dm_config_tree, remove the top layer
- * and return the layer below.  Otherwise return NULL.
+ * When searching, first_cft is checked before second_cft.
  */
-struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft);
+struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *first_cft, struct dm_config_tree *second_cft);
 
 /*
- * When searching, first_cft is checked before second_cft.
+ * If there's a cascaded dm_config_tree, remove the top layer
+ * and return the layer below.  Otherwise return NULL.
  */
-struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *first_cft, struct dm_config_tree *second_cft);
+struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft);
 
 void dm_config_destroy(struct dm_config_tree *cft);
 
 typedef int (*dm_putline_fn)(const char *line, void *baton);
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
 
-struct dm_config_node *dm_config_find_node(struct dm_config_node *cn, const char *path);
+struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
 int dm_config_has_node(const struct dm_config_node *cn, const char *path);
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
 const char *dm_config_find_str_allow_empty(const struct dm_config_node *cn, const char *path, const char *fail);
@@ -1405,18 +1404,12 @@
 float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
 
 const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tree *cft, const char *path);
-const char *dm_config_tree_find_str(const struct dm_config_tree *cft,
-				    const char *path, const char *fail);
-const char *dm_config_tree_find_str_allow_empty(const struct dm_config_tree *cft,
-						const char *path, const char *fail);
-int dm_config_tree_find_int(const struct dm_config_tree *cft,
-			    const char *path, int fail);
-int64_t dm_config_tree_find_int64(const struct dm_config_tree *cft,
-				  const char *path, int64_t fail);
-float dm_config_tree_find_float(const struct dm_config_tree *cft,
-				const char *path, float fail);
-int dm_config_tree_find_bool(const struct dm_config_tree *cft,
-			     const char *path, int fail);
+const char *dm_config_tree_find_str(const struct dm_config_tree *cft, const char *path, const char *fail);
+const char *dm_config_tree_find_str_allow_empty(const struct dm_config_tree *cft, const char *path, const char *fail);
+int dm_config_tree_find_int(const struct dm_config_tree *cft, const char *path, int fail);
+int64_t dm_config_tree_find_int64(const struct dm_config_tree *cft, const char *path, int64_t fail);
+float dm_config_tree_find_float(const struct dm_config_tree *cft, const char *path, float fail);
+int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path, int fail);
 
 /*
  * Understands (0, ~0), (y, n), (yes, no), (on,
@@ -1424,36 +1417,25 @@
  */
 int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int fail);
 
-int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
-			 uint32_t *result);
-
-int dm_config_get_uint64(const struct dm_config_node *cn, const char *path,
-			 uint64_t *result);
-
-int dm_config_get_str(const struct dm_config_node *cn, const char *path,
-		      const char **result);
-int dm_config_get_list(const struct dm_config_node *cn, const char *path,
-		       const struct dm_config_value **result);
-int dm_config_get_section(const struct dm_config_node *cn, const char *path,
-			  const struct dm_config_node **result);
+int dm_config_get_uint32(const struct dm_config_node *cn, const char *path, uint32_t *result);
+int dm_config_get_uint64(const struct dm_config_node *cn, const char *path, uint64_t *result);
+int dm_config_get_str(const struct dm_config_node *cn, const char *path, const char **result);
+int dm_config_get_list(const struct dm_config_node *cn, const char *path, const struct dm_config_value **result);
+int dm_config_get_section(const struct dm_config_node *cn, const char *path, const struct dm_config_node **result);
 
 unsigned dm_config_maybe_section(const char *str, unsigned len);
 
 const char *dm_config_parent_name(const struct dm_config_node *n);
 
-struct dm_config_node *dm_config_clone_node_with_mem(struct dm_pool *mem,
-						     const struct dm_config_node *node,
-						     int siblings);
+struct dm_config_node *dm_config_clone_node_with_mem(struct dm_pool *mem, const struct dm_config_node *node, int siblings);
 struct dm_config_node *dm_config_create_node(struct dm_config_tree *cft, const char *key);
 struct dm_config_value *dm_config_create_value(struct dm_config_tree *cft);
-struct dm_config_node *dm_config_clone_node(struct dm_config_tree *cft,
-					    const struct dm_config_node *cn,
-					    int siblings);
+struct dm_config_node *dm_config_clone_node(struct dm_config_tree *cft, const struct dm_config_node *cn, int siblings);
 
 struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
 
-
 /* Cookie prefixes.
+ *
  * The cookie value consists of a prefix (16 bits) and a base (16 bits).
  * We can use the prefix to store the flags. These flags are sent to
  * kernel within given dm task. When returned back to userspace in
@@ -1461,6 +1443,7 @@
  * of udev rules we use by decoding the cookie prefix. When doing the
  * notification, we replace the cookie prefix with DM_COOKIE_MAGIC,
  * so we notify the right semaphore.
+ *
  * It is still possible to use cookies for passing the flags to udev
  * rules even when udev_sync is disabled. The base part of the cookie
  * will be zero (there's no notification semaphore) and prefix will be
--- LVM2/libdm/libdm-deptree.c	2012/01/19 15:22:32	1.150
+++ LVM2/libdm/libdm-deptree.c	2012/01/23 17:46:31	1.151
@@ -276,6 +276,9 @@
 	uint32_t cookie;
 };
 
+/*
+ * Tree functions.
+ */
 struct dm_tree *dm_tree_create(void)
 {
 	struct dm_pool *dmem;
@@ -322,6 +325,34 @@
 	dm_pool_destroy(dtree->mem);
 }
 
+void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie)
+{
+	node->dtree->cookie = cookie;
+}
+
+uint32_t dm_tree_get_cookie(struct dm_tree_node *node)
+{
+	return node->dtree->cookie;
+}
+
+void dm_tree_skip_lockfs(struct dm_tree_node *dnode)
+{
+	dnode->dtree->skip_lockfs = 1;
+}
+
+void dm_tree_use_no_flush_suspend(struct dm_tree_node *dnode)
+{
+	dnode->dtree->no_flush = 1;
+}
+
+void dm_tree_retry_remove(struct dm_tree_node *dnode)
+{
+	dnode->dtree->retry_remove = 1;
+}
+
+/*
+ * Node functions.
+ */
 static int _nodes_are_linked(const struct dm_tree_node *parent,
 			     const struct dm_tree_node *child)
 {
@@ -500,6 +531,200 @@
 	return dm_hash_lookup(dtree->uuids, uuid + default_uuid_prefix_len);
 }
 
+void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)
+
+{
+	struct dm_info *dinfo = &dnode->info;
+
+	if (udev_flags != dnode->udev_flags)
+		log_debug("Resetting %s (%" PRIu32 ":%" PRIu32
+			  ") udev_flags from 0x%x to 0x%x",
+			  dnode->name, dinfo->major, dinfo->minor,
+			  dnode->udev_flags, udev_flags);
+	dnode->udev_flags = udev_flags;
+}
+
+void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
+				 uint32_t read_ahead,
+				 uint32_t read_ahead_flags)
+{
+	dnode->props.read_ahead = read_ahead;
+	dnode->props.read_ahead_flags = read_ahead_flags;
+}
+
+void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
+				      struct dm_tree_node *presuspend_node)
+{
+	node->presuspend_node = presuspend_node;
+}
+
+const char *dm_tree_node_get_name(const struct dm_tree_node *node)
+{
+	return node->info.exists ? node->name : "";
+}
+
+const char *dm_tree_node_get_uuid(const struct dm_tree_node *node)
+{
+	return node->info.exists ? node->uuid : "";
+}
+
+const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node)
+{
+	return &node->info;
+}
+
+void *dm_tree_node_get_context(const struct dm_tree_node *node)
+{
+	return node->context;
+}
+
+int dm_tree_node_size_changed(const struct dm_tree_node *dnode)
+{
+	return dnode->props.size_changed;
+}
+
+int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted)
+{
+	if (inverted) {
+		if (_nodes_are_linked(&node->dtree->root, node))
+			return 0;
+		return dm_list_size(&node->used_by);
+	}
+
+	if (_nodes_are_linked(node, &node->dtree->root))
+		return 0;
+
+	return dm_list_size(&node->uses);
+}
+
+/*
+ * Returns 1 if no prefix supplied
+ */
+static int _uuid_prefix_matches(const char *uuid, const char *uuid_prefix, size_t uuid_prefix_len)
+{
+	const char *default_uuid_prefix = dm_uuid_prefix();
+	size_t default_uuid_prefix_len = strlen(default_uuid_prefix);
+
+	if (!uuid_prefix)
+		return 1;
+
+	if (!strncmp(uuid, uuid_prefix, uuid_prefix_len))
+		return 1;
+
+	/* Handle transition: active device uuids might be missing the prefix */
+	if (uuid_prefix_len <= 4)
+		return 0;
+
+	if (!strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
+		return 0;
+
+	if (strncmp(uuid_prefix, default_uuid_prefix, default_uuid_prefix_len))
+		return 0;
+
+	if (!strncmp(uuid, uuid_prefix + default_uuid_prefix_len, uuid_prefix_len - default_uuid_prefix_len))
+		return 1;
+
+	return 0;
+}
+
+/*
+ * Returns 1 if no children.
+ */
+static int _children_suspended(struct dm_tree_node *node,
+			       uint32_t inverted,
+			       const char *uuid_prefix,
+			       size_t uuid_prefix_len)
+{
+	struct dm_list *list;
+	struct dm_tree_link *dlink;
+	const struct dm_info *dinfo;
+	const char *uuid;
+
+	if (inverted) {
+		if (_nodes_are_linked(&node->dtree->root, node))
+			return 1;
+		list = &node->used_by;
+	} else {
+		if (_nodes_are_linked(node, &node->dtree->root))
+			return 1;
+		list = &node->uses;
+	}
+
+	dm_list_iterate_items(dlink, list) {
+		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
+			stack;
+			continue;
+		}
+
+		/* Ignore if it doesn't belong to this VG */
+		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
+			continue;
+
+		/* Ignore if parent node wants to presuspend this node */
+		if (dlink->node->presuspend_node == node)
+			continue;
+
+		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
+			stack;	/* FIXME Is this normal? */
+			return 0;
+		}
+
+		if (!dinfo->suspended)
+			return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Set major and minor to zero for root of tree.
+ */
+struct dm_tree_node *dm_tree_find_node(struct dm_tree *dtree,
+					  uint32_t major,
+					  uint32_t minor)
+{
+	if (!major && !minor)
+		return &dtree->root;
+
+	return _find_dm_tree_node(dtree, major, minor);
+}
+
+/*
+ * Set uuid to NULL for root of tree.
+ */
+struct dm_tree_node *dm_tree_find_node_by_uuid(struct dm_tree *dtree,
+						  const char *uuid)
+{
+	if (!uuid || !*uuid)
+		return &dtree->root;
+
+	return _find_dm_tree_node_by_uuid(dtree, uuid);
+}
+
+/*
+ * First time set *handle to NULL.
+ * Set inverted to invert the tree.
+ */
+struct dm_tree_node *dm_tree_next_child(void **handle,
+					const struct dm_tree_node *parent,
+					uint32_t inverted)
+{
+	struct dm_list **dlink = (struct dm_list **) handle;
+	const struct dm_list *use_list;
+
+	if (inverted)
+		use_list = &parent->used_by;
+	else
+		use_list = &parent->uses;
+
+	if (!*dlink)
+		*dlink = dm_list_first(use_list);
+	else
+		*dlink = dm_list_next(use_list, *dlink);
+
+	return (*dlink) ? dm_list_item(*dlink, struct dm_tree_link)->node : NULL;
+}
+
 static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint32_t minor,
 		 const char **name, const char **uuid, unsigned inactive_table,
 		 struct dm_info *info, struct dm_deps **deps)
@@ -591,70 +816,168 @@
 	return 0;
 }
 
-static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
-				     struct dm_tree_node *parent,
-				     uint32_t major, uint32_t minor,
-				     uint16_t udev_flags)
+/*
+ * Deactivate a device with its dependencies if the uuid prefix matches.
+ */
+static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
+			struct dm_info *info, struct dm_pool *mem,
+			const char **name, const char **uuid)
 {
-	struct dm_task *dmt = NULL;
-	struct dm_info info;
-	struct dm_deps *deps = NULL;
-	const char *name = NULL;
-	const char *uuid = NULL;
-	struct dm_tree_node *node = NULL;
-	uint32_t i;
-	int new = 0;
-
-	/* Already in tree? */
-	if (!(node = _find_dm_tree_node(dtree, major, minor))) {
-		if (!_deps(&dmt, dtree->mem, major, minor, &name, &uuid, 0, &info, &deps))
-			return_NULL;
+	struct dm_task *dmt;
+	int r;
 
-		if (!(node = _create_dm_tree_node(dtree, name, uuid, &info,
-						  NULL, udev_flags)))
-			goto_out;
-		new = 1;
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
+		log_error("_info_by_dev: dm_task creation failed");
+		return 0;
 	}
 
-	if (!_link_tree_nodes(parent, node)) {
-		node = NULL;
+	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
+		log_error("_info_by_dev: Failed to set device number");
+		dm_task_destroy(dmt);
+		return 0;
+	}
+
+	if (!with_open_count && !dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if (!(r = dm_task_run(dmt)))
+		goto_out;
+
+	if (!(r = dm_task_get_info(dmt, info)))
+		goto_out;
+
+	if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(dmt)))) {
+		log_error("name pool_strdup failed");
+		r = 0;
 		goto_out;
 	}
 
-	/* If node was already in tree, no need to recurse. */
-	if (!new)
-		goto out;
+	if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(dmt)))) {
+		log_error("uuid pool_strdup failed");
+		r = 0;
+		goto_out;
+	}
 
-	/* Can't recurse if not a mapped device or there are no dependencies */
-	if (!node->info.exists || !deps->count) {
-		if (!_add_to_bottomlevel(node)) {
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+static int _check_device_not_in_use(const char *name, struct dm_info *info)
+{
+	if (!info->exists)
+		return 1;
+
+	/* If sysfs is not used, use open_count information only. */
+	if (!*dm_sysfs_dir()) {
+		if (info->open_count) {
+			log_error("Device %s (%" PRIu32 ":%" PRIu32 ") in use",
+				  name, info->major, info->minor);
+			return 0;
+		}
+
+		return 1;
+	}
+
+	if (dm_device_has_holders(info->major, info->minor)) {
+		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") is used "
+			  "by another device.", name, info->major, info->minor);
+		return 0;
+	}
+
+	if (dm_device_has_mounted_fs(info->major, info->minor)) {
+		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") contains "
+			  "a filesystem in use.", name, info->major, info->minor);
+		return 0;
+	}
+
+	return 1;
+}
+
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
 			stack;
-			node = NULL;
+			continue;
 		}
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
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
+		    !info.exists)
+			continue;
+
+		if (info.open_count) {
+			log_debug("Node %s %d:%d has open_count %d", uuid_prefix,
+				  dinfo->major, dinfo->minor, info.open_count);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
+			    uint32_t *cookie, uint16_t udev_flags, int retry)
+{
+	struct dm_task *dmt;
+	int r = 0;
+
+	log_verbose("Removing %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
+
+	if (!(dmt = dm_task_create(DM_DEVICE_REMOVE))) {
+		log_error("Deactivation dm_task creation failed for %s", name);
+		return 0;
+	}
+
+	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
+		log_error("Failed to set device number for %s deactivation", name);
 		goto out;
 	}
 
-	/* Add dependencies to tree */
-	for (i = 0; i < deps->count; i++)
-		if (!_add_dev(dtree, node, MAJOR(deps->device[i]),
-			      MINOR(deps->device[i]), udev_flags)) {
-			node = NULL;
-			goto_out;
-		}
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if (cookie)
+		if (!dm_task_set_cookie(dmt, cookie, udev_flags))
+			goto out;
+
+	if (retry)
+		dm_task_retry_remove(dmt);
+
+	r = dm_task_run(dmt);
+
+	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
+	rm_dev_node(name, dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG),
+		    dmt->cookie_set && (udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
+
+	/* FIXME Remove node from tree or mark invalid? */
 
 out:
-	if (dmt)
-		dm_task_destroy(dmt);
+	dm_task_destroy(dmt);
 
-	return node;
+	return r;
 }
 
-// FIXME Move fn group down.
-static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
-			struct dm_info *info, struct dm_pool *mem,
-			const char **name, const char **uuid);
-static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
-			    uint32_t *cookie, uint16_t udev_flags, int retry);
 static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 {
 	struct dm_task *dmt = NULL, *deps_dmt = NULL;
@@ -721,476 +1044,178 @@
 	for (i = 0; i < deps->count; i++) {
 		/* If already in tree, assume it's under control */
 		if (_find_dm_tree_node(dnode->dtree, MAJOR(deps->device[i]), MINOR(deps->device[i])))
-			continue;
-
-		if (!_info_by_dev(MAJOR(deps->device[i]), MINOR(deps->device[i]), 1,
-				  &deps_info, dnode->dtree->mem, &name, &uuid))
-			continue;
-
-		/* Proceed if device is an 'orphan' - unreferenced and without a live table. */
-		if (!deps_info.exists || deps_info.live_table || deps_info.open_count)
-			continue;
-
-		if (strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
-			continue;
-
-		/* Remove device. */
-		if (!_deactivate_node(name, deps_info.major, deps_info.minor, &dnode->dtree->cookie, udev_flags, 0)) {
-			log_error("Failed to deactivate no-longer-used device %s (%"
-				  PRIu32 ":%" PRIu32 ")", name, deps_info.major, deps_info.minor);
-		} else if (deps_info.suspended)
-			dec_suspended();
-	}
-
-out:
-	if (dmt)
-		dm_task_destroy(dmt);
-
-	if (deps_dmt)
-		dm_task_destroy(deps_dmt);
-
-	return r;
-}
-
-struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
-							 const char *name,
-							 const char *uuid,
-							 uint32_t major,
-							 uint32_t minor,
-							 int read_only,
-							 int clear_inactive,
-							 void *context,
-							 uint16_t udev_flags)
-{
-	struct dm_tree_node *dnode;
-	struct dm_info info;
-	const char *name2;
-	const char *uuid2;
-
-	/* Do we need to add node to tree? */
-	if (!(dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
-		if (!(name2 = dm_pool_strdup(dtree->mem, name))) {
-			log_error("name pool_strdup failed");
-			return NULL;
-		}
-		if (!(uuid2 = dm_pool_strdup(dtree->mem, uuid))) {
-			log_error("uuid pool_strdup failed");
-			return NULL;
-		}
-
-		info.major = 0;
-		info.minor = 0;
-		info.exists = 0;
-		info.live_table = 0;
-		info.inactive_table = 0;
-		info.read_only = 0;
-
-		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
-						   context, 0)))
-			return_NULL;
-
-		/* Attach to root node until a table is supplied */
-		if (!_add_to_toplevel(dnode) || !_add_to_bottomlevel(dnode))
-			return_NULL;
-
-		dnode->props.major = major;
-		dnode->props.minor = minor;
-		dnode->props.new_name = NULL;
-		dnode->props.size_changed = 0;
-	} else if (strcmp(name, dnode->name)) {
-		/* Do we need to rename node? */
-		if (!(dnode->props.new_name = dm_pool_strdup(dtree->mem, name))) {
-			log_error("name pool_strdup failed");
-			return NULL;
-		}
-	}
-
-	dnode->props.read_only = read_only ? 1 : 0;
-	dnode->props.read_ahead = DM_READ_AHEAD_AUTO;
-	dnode->props.read_ahead_flags = 0;
-
-	if (clear_inactive && !_node_clear_table(dnode, udev_flags))
-		return_NULL;
-
-	dnode->context = context;
-	dnode->udev_flags = udev_flags;
-
-	return dnode;
-}
-
-struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree, const char *name,
-					 const char *uuid, uint32_t major, uint32_t minor,
-					 int read_only, int clear_inactive, void *context)
-{
-	return dm_tree_add_new_dev_with_udev_flags(dtree, name, uuid, major, minor,
-						   read_only, clear_inactive, context, 0);
-}
-
-void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)
-
-{
-	struct dm_info *dinfo = &dnode->info;
-
-	if (udev_flags != dnode->udev_flags)
-		log_debug("Resetting %s (%" PRIu32 ":%" PRIu32
-			  ") udev_flags from 0x%x to 0x%x",
-			  dnode->name, dinfo->major, dinfo->minor,
-			  dnode->udev_flags, udev_flags);
-	dnode->udev_flags = udev_flags;
-}
-
-void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
-				 uint32_t read_ahead,
-				 uint32_t read_ahead_flags)
-{
-	dnode->props.read_ahead = read_ahead;
-	dnode->props.read_ahead_flags = read_ahead_flags;
-}
-
-void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
-				      struct dm_tree_node *presuspend_node)
-{
-	node->presuspend_node = presuspend_node;
-}
-
-int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
-{
-	return _add_dev(dtree, &dtree->root, major, minor, 0) ? 1 : 0;
-}
-
-int dm_tree_add_dev_with_udev_flags(struct dm_tree *dtree, uint32_t major,
-				    uint32_t minor, uint16_t udev_flags)
-{
-	return _add_dev(dtree, &dtree->root, major, minor, udev_flags) ? 1 : 0;
-}
-
-const char *dm_tree_node_get_name(const struct dm_tree_node *node)
-{
-	return node->info.exists ? node->name : "";
-}
-
-const char *dm_tree_node_get_uuid(const struct dm_tree_node *node)
-{
-	return node->info.exists ? node->uuid : "";
-}
-
-const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node)
-{
-	return &node->info;
-}
-
-void *dm_tree_node_get_context(const struct dm_tree_node *node)
-{
-	return node->context;
-}
-
-int dm_tree_node_size_changed(const struct dm_tree_node *dnode)
-{
-	return dnode->props.size_changed;
-}
-
-int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted)
-{
-	if (inverted) {
-		if (_nodes_are_linked(&node->dtree->root, node))
-			return 0;
-		return dm_list_size(&node->used_by);
-	}
-
-	if (_nodes_are_linked(node, &node->dtree->root))
-		return 0;
-
-	return dm_list_size(&node->uses);
-}
-
-/*
- * Returns 1 if no prefix supplied
- */
-static int _uuid_prefix_matches(const char *uuid, const char *uuid_prefix, size_t uuid_prefix_len)
-{
-	const char *default_uuid_prefix = dm_uuid_prefix();
-	size_t default_uuid_prefix_len = strlen(default_uuid_prefix);
-
-	if (!uuid_prefix)
-		return 1;
-
-	if (!strncmp(uuid, uuid_prefix, uuid_prefix_len))
-		return 1;
-
-	/* Handle transition: active device uuids might be missing the prefix */
-	if (uuid_prefix_len <= 4)
-		return 0;
-
-	if (!strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
-		return 0;
-
-	if (strncmp(uuid_prefix, default_uuid_prefix, default_uuid_prefix_len))
-		return 0;
-
-	if (!strncmp(uuid, uuid_prefix + default_uuid_prefix_len, uuid_prefix_len - default_uuid_prefix_len))
-		return 1;
-
-	return 0;
-}
-
-/*
- * Returns 1 if no children.
- */
-static int _children_suspended(struct dm_tree_node *node,
-			       uint32_t inverted,
-			       const char *uuid_prefix,
-			       size_t uuid_prefix_len)
-{
-	struct dm_list *list;
-	struct dm_tree_link *dlink;
-	const struct dm_info *dinfo;
-	const char *uuid;
-
-	if (inverted) {
-		if (_nodes_are_linked(&node->dtree->root, node))
-			return 1;
-		list = &node->used_by;
-	} else {
-		if (_nodes_are_linked(node, &node->dtree->root))
-			return 1;
-		list = &node->uses;
-	}
-
-	dm_list_iterate_items(dlink, list) {
-		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
-			stack;
-			continue;
-		}
-
-		/* Ignore if it doesn't belong to this VG */
-		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
-			continue;
-
-		/* Ignore if parent node wants to presuspend this node */
-		if (dlink->node->presuspend_node == node)
-			continue;
-
-		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
-			stack;	/* FIXME Is this normal? */
-			return 0;
-		}
-
-		if (!dinfo->suspended)
-			return 0;
-	}
-
-	return 1;
-}
-
-/*
- * Set major and minor to zero for root of tree.
- */
-struct dm_tree_node *dm_tree_find_node(struct dm_tree *dtree,
-					  uint32_t major,
-					  uint32_t minor)
-{
-	if (!major && !minor)
-		return &dtree->root;
-
-	return _find_dm_tree_node(dtree, major, minor);
-}
-
-/*
- * Set uuid to NULL for root of tree.
- */
-struct dm_tree_node *dm_tree_find_node_by_uuid(struct dm_tree *dtree,
-						  const char *uuid)
-{
-	if (!uuid || !*uuid)
-		return &dtree->root;
-
-	return _find_dm_tree_node_by_uuid(dtree, uuid);
-}
-
-/*
- * First time set *handle to NULL.
- * Set inverted to invert the tree.
- */
-struct dm_tree_node *dm_tree_next_child(void **handle,
-					const struct dm_tree_node *parent,
-					uint32_t inverted)
-{
-	struct dm_list **dlink = (struct dm_list **) handle;
-	const struct dm_list *use_list;
-
-	if (inverted)
-		use_list = &parent->used_by;
-	else
-		use_list = &parent->uses;
-
-	if (!*dlink)
-		*dlink = dm_list_first(use_list);
-	else
-		*dlink = dm_list_next(use_list, *dlink);
-
-	return (*dlink) ? dm_list_item(*dlink, struct dm_tree_link)->node : NULL;
-}
-
-/*
- * Deactivate a device with its dependencies if the uuid prefix matches.
- */
-static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
-			struct dm_info *info, struct dm_pool *mem,
-			const char **name, const char **uuid)
-{
-	struct dm_task *dmt;
-	int r;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
-		log_error("_info_by_dev: dm_task creation failed");
-		return 0;
-	}
-
-	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("_info_by_dev: Failed to set device number");
-		dm_task_destroy(dmt);
-		return 0;
-	}
-
-	if (!with_open_count && !dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+			continue;
 
-	if (!(r = dm_task_run(dmt)))
-		goto_out;
+		if (!_info_by_dev(MAJOR(deps->device[i]), MINOR(deps->device[i]), 1,
+				  &deps_info, dnode->dtree->mem, &name, &uuid))
+			continue;
 
-	if (!(r = dm_task_get_info(dmt, info)))
-		goto_out;
+		/* Proceed if device is an 'orphan' - unreferenced and without a live table. */
+		if (!deps_info.exists || deps_info.live_table || deps_info.open_count)
+			continue;
 
-	if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(dmt)))) {
-		log_error("name pool_strdup failed");
-		r = 0;
-		goto_out;
-	}
+		if (strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
+			continue;
 
-	if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(dmt)))) {
-		log_error("uuid pool_strdup failed");
-		r = 0;
-		goto_out;
+		/* Remove device. */
+		if (!_deactivate_node(name, deps_info.major, deps_info.minor, &dnode->dtree->cookie, udev_flags, 0)) {
+			log_error("Failed to deactivate no-longer-used device %s (%"
+				  PRIu32 ":%" PRIu32 ")", name, deps_info.major, deps_info.minor);
+		} else if (deps_info.suspended)
+			dec_suspended();
 	}
 
 out:
-	dm_task_destroy(dmt);
+	if (dmt)
+		dm_task_destroy(dmt);
+
+	if (deps_dmt)
+		dm_task_destroy(deps_dmt);
 
 	return r;
 }
 
-static int _check_device_not_in_use(const char *name, struct dm_info *info)
+struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
+							 const char *name,
+							 const char *uuid,
+							 uint32_t major,
+							 uint32_t minor,
+							 int read_only,
+							 int clear_inactive,
+							 void *context,
+							 uint16_t udev_flags)
 {
-	if (!info->exists)
-		return 1;
+	struct dm_tree_node *dnode;
+	struct dm_info info;
+	const char *name2;
+	const char *uuid2;
 
-	/* If sysfs is not used, use open_count information only. */
-	if (!*dm_sysfs_dir()) {
-		if (info->open_count) {
-			log_error("Device %s (%" PRIu32 ":%" PRIu32 ") in use",
-				  name, info->major, info->minor);
-			return 0;
+	/* Do we need to add node to tree? */
+	if (!(dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
+		if (!(name2 = dm_pool_strdup(dtree->mem, name))) {
+			log_error("name pool_strdup failed");
+			return NULL;
+		}
+		if (!(uuid2 = dm_pool_strdup(dtree->mem, uuid))) {
+			log_error("uuid pool_strdup failed");
+			return NULL;
 		}
 
-		return 1;
-	}
-
-	if (dm_device_has_holders(info->major, info->minor)) {
-		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") is used "
-			  "by another device.", name, info->major, info->minor);
-		return 0;
-	}
-
-	if (dm_device_has_mounted_fs(info->major, info->minor)) {
-		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") contains "
-			  "a filesystem in use.", name, info->major, info->minor);
-		return 0;
-	}
+		info.major = 0;
+		info.minor = 0;
+		info.exists = 0;
+		info.live_table = 0;
+		info.inactive_table = 0;
+		info.read_only = 0;
 
-	return 1;
-}
+		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
+						   context, 0)))
+			return_NULL;
 
-/* Check if all parent nodes of given node have open_count == 0 */
-static int _node_has_closed_parents(struct dm_tree_node *node,
-				    const char *uuid_prefix,
-				    size_t uuid_prefix_len)
-{
-	struct dm_tree_link *dlink;
-	const struct dm_info *dinfo;
-	struct dm_info info;
-	const char *uuid;
+		/* Attach to root node until a table is supplied */
+		if (!_add_to_toplevel(dnode) || !_add_to_bottomlevel(dnode))
+			return_NULL;
 
-	/* Iterate through parents of this node */
-	dm_list_iterate_items(dlink, &node->used_by) {
-		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
-			stack;
-			continue;
+		dnode->props.major = major;
+		dnode->props.minor = minor;
+		dnode->props.new_name = NULL;
+		dnode->props.size_changed = 0;
+	} else if (strcmp(name, dnode->name)) {
+		/* Do we need to rename node? */
+		if (!(dnode->props.new_name = dm_pool_strdup(dtree->mem, name))) {
+			log_error("name pool_strdup failed");
+			return NULL;
 		}
+	}
 
-		/* Ignore if it doesn't belong to this VG */
-		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
-			continue;
+	dnode->props.read_only = read_only ? 1 : 0;
+	dnode->props.read_ahead = DM_READ_AHEAD_AUTO;
+	dnode->props.read_ahead_flags = 0;
 
-		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
-			stack;	/* FIXME Is this normal? */
-			return 0;
-		}
+	if (clear_inactive && !_node_clear_table(dnode, udev_flags))
+		return_NULL;
 
-		/* Refresh open_count */
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
-		    !info.exists)
-			continue;
+	dnode->context = context;
+	dnode->udev_flags = udev_flags;
 
-		if (info.open_count) {
-			log_debug("Node %s %d:%d has open_count %d", uuid_prefix,
-				  dinfo->major, dinfo->minor, info.open_count);
-			return 0;
-		}
-	}
+	return dnode;
+}
 
-	return 1;
+struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree, const char *name,
+					 const char *uuid, uint32_t major, uint32_t minor,
+					 int read_only, int clear_inactive, void *context)
+{
+	return dm_tree_add_new_dev_with_udev_flags(dtree, name, uuid, major, minor,
+						   read_only, clear_inactive, context, 0);
 }
 
-static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
-			    uint32_t *cookie, uint16_t udev_flags, int retry)
+static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
+				     struct dm_tree_node *parent,
+				     uint32_t major, uint32_t minor,
+				     uint16_t udev_flags)
 {
-	struct dm_task *dmt;
-	int r = 0;
+	struct dm_task *dmt = NULL;
+	struct dm_info info;
+	struct dm_deps *deps = NULL;
+	const char *name = NULL;
+	const char *uuid = NULL;
+	struct dm_tree_node *node = NULL;
+	uint32_t i;
+	int new = 0;
 
-	log_verbose("Removing %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
+	/* Already in tree? */
+	if (!(node = _find_dm_tree_node(dtree, major, minor))) {
+		if (!_deps(&dmt, dtree->mem, major, minor, &name, &uuid, 0, &info, &deps))
+			return_NULL;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_REMOVE))) {
-		log_error("Deactivation dm_task creation failed for %s", name);
-		return 0;
+		if (!(node = _create_dm_tree_node(dtree, name, uuid, &info,
+						  NULL, udev_flags)))
+			goto_out;
+		new = 1;
 	}
 
-	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("Failed to set device number for %s deactivation", name);
-		goto out;
+	if (!_link_tree_nodes(parent, node)) {
+		node = NULL;
+		goto_out;
 	}
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
-
-	if (cookie)
-		if (!dm_task_set_cookie(dmt, cookie, udev_flags))
-			goto out;
+	/* If node was already in tree, no need to recurse. */
+	if (!new)
+		goto out;
 
-	if (retry)
-		dm_task_retry_remove(dmt);
+	/* Can't recurse if not a mapped device or there are no dependencies */
+	if (!node->info.exists || !deps->count) {
+		if (!_add_to_bottomlevel(node)) {
+			stack;
+			node = NULL;
+		}
+		goto out;
+	}
 
-	r = dm_task_run(dmt);
+	/* Add dependencies to tree */
+	for (i = 0; i < deps->count; i++)
+		if (!_add_dev(dtree, node, MAJOR(deps->device[i]),
+			      MINOR(deps->device[i]), udev_flags)) {
+			node = NULL;
+			goto_out;
+		}
 
-	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
-	rm_dev_node(name, dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG),
-		    dmt->cookie_set && (udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
+out:
+	if (dmt)
+		dm_task_destroy(dmt);
 
-	/* FIXME Remove node from tree or mark invalid? */
+	return node;
+}
 
-out:
-	dm_task_destroy(dmt);
+int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
+{
+	return _add_dev(dtree, &dtree->root, major, minor, 0) ? 1 : 0;
+}
 
-	return r;
+int dm_tree_add_dev_with_udev_flags(struct dm_tree *dtree, uint32_t major,
+				    uint32_t minor, uint16_t udev_flags)
+{
+	return _add_dev(dtree, &dtree->root, major, minor, udev_flags) ? 1 : 0;
 }
 
 static int _rename_node(const char *old_name, const char *new_name, uint32_t major,
@@ -1588,21 +1613,6 @@
 	return _dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len, 0);
 }
 
-void dm_tree_skip_lockfs(struct dm_tree_node *dnode)
-{
-	dnode->dtree->skip_lockfs = 1;
-}
-
-void dm_tree_use_no_flush_suspend(struct dm_tree_node *dnode)
-{
-	dnode->dtree->no_flush = 1;
-}
-
-void dm_tree_retry_remove(struct dm_tree_node *dnode)
-{
-	dnode->dtree->retry_remove = 1;
-}
-
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
@@ -3254,13 +3264,3 @@
 
 	return 1;
 }
-
-void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie)
-{
-	node->dtree->cookie = cookie;
-}
-
-uint32_t dm_tree_get_cookie(struct dm_tree_node *node)
-{
-	return node->dtree->cookie;
-}
--- LVM2/lib/metadata/thin_manip.c	2012/01/19 15:23:51	1.28
+++ LVM2/lib/metadata/thin_manip.c	2012/01/23 17:46:31	1.29
@@ -234,7 +234,7 @@
 			max_id = sl->seg->device_id;
 
 	if (++max_id > DM_THIN_MAX_DEVICE_ID) {
-		// FIXME: try to find empty holes....
+		/* FIXME Find empty holes instead of aborting! */
 		log_error("Cannot find free device_id.");
 		return 0;
 	}
--- LVM2/lib/config/config.c	2011/12/18 21:56:03	1.111
+++ LVM2/lib/config/config.c	2012/01/23 17:46:31	1.112
@@ -160,7 +160,6 @@
  */
 struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd)
 {
-// FIXME Replace cmd->cft with clean copy of merged lvm*.conf tree
 	struct dm_config_tree *old_cft = cmd->cft;
 	struct dm_config_tree *cft = dm_config_remove_cascaded_tree(cmd->cft);
 
@@ -172,8 +171,6 @@
 	return old_cft;
 }
 
-// FIXME Retain a copy of the string (or tree?) in cmd->cft_cmdline
-// FIXME and merge into cmd->cft
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {
--- LVM2/lib/commands/toolcontext.c	2012/01/11 20:38:42	1.146
+++ LVM2/lib/commands/toolcontext.c	2012/01/23 17:46:32	1.147
@@ -620,7 +620,6 @@
 	struct config_tree_list *cfl;
 	struct dm_config_tree *cft_cmdline = NULL, *cft;
 
-// FIXME No need for this - only one config tree now
 	cft = dm_config_remove_cascaded_tree(cmd->cft);
 	if (cft) {
 		cft_cmdline = cmd->cft;
@@ -1452,7 +1451,7 @@
 	}
 	dev_cache_exit();
 	_destroy_tags(cmd);
-// FIXME Use cmd->cft_cmdline instead here.
+
 	cft_cmdline = _destroy_tag_configs(cmd);
 
 	cmd->config_valid = 0;
@@ -1465,7 +1464,6 @@
 	/* Temporary duplicate cft pointer holding lvm.conf - replaced later */
 	cft_tmp = cmd->cft;
 	if (cft_cmdline)
-// FIXME Use cmd->cft_cmdline (convert string to cft again?) and merge instead
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cft_tmp);
 
 	/* Uses cmd->cft i.e. cft_cmdline + lvm.conf */
@@ -1479,15 +1477,11 @@
 	if (!_init_tag_configs(cmd))
 		return 0;
 
-// FIXME Will need to use a fresh copy of the lvm.conf cft as the original
-// FIXME got destroyed when cft_cmdline was merged into it
 	/* Merge all the tag config files with lvm.conf, returning a
 	 * fresh cft pointer in place of cft_tmp. */
 	if (!(cmd->cft = _merge_config_files(cmd, cft_tmp)))
 		return 0;
 
-// FIXME Merge instead - but keep a clean copy of cmd->cft at this point
-// FIXME so we can easily 'remove' the effect of cft_cmdline after each cmd
 	/* Finally we can make the proper, fully-merged, cmd->cft */
 	if (cft_cmdline)
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cmd->cft);
@@ -1539,7 +1533,6 @@
 	dev_cache_exit();
 	_destroy_tags(cmd);
 
-// FIXME destroy_tag_configs handles this itself again
 	if ((cft_cmdline = _destroy_tag_configs(cmd)))
 		dm_config_destroy(cft_cmdline);
 	if (cmd->libmem)


