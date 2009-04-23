From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 23 Apr 2009 15:07:28 +0200
Subject: [PATCH 4/5] Udev integration: add cookie support for dm trees
Message-ID: <49F06810.2010505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

...resending updated and cleaned up patches for udev integration.


diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1083fcd..f697e6a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1123,7 +1123,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root)
 		if (!*layer)
 			continue;
 
-		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
+		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid), 0))
 			return_0;
 	}
 
@@ -1157,7 +1157,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		break;
 	case DEACTIVATE:
  		/* Deactivate LV and all devices it references that nothing else has open. */
-		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1, 0))
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
 			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
@@ -1177,11 +1177,11 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1, 0))
 			goto_out;
 
 		if ((action == ACTIVATE) &&
-		    !dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		    !dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1, 0))
 			goto_out;
 
 		if (!_create_lv_symlinks(dm, root)) {
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ea75a64..de61de9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -308,23 +308,23 @@ int dm_tree_node_num_children(struct dm_tree_node *node, uint32_t inverted);
  * Ignores devices that don't have a uuid starting with uuid_prefix.
  */
 int dm_tree_deactivate_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len);
+				   const char *uuid_prefix, size_t uuid_prefix_len,
+					 uint32_t cookie);
 /*
  * Preload/create a device plus all dependencies.
  * Ignores devices that don't have a uuid starting with uuid_prefix.
  */
 int dm_tree_preload_children(struct dm_tree_node *dnode,
-			     const char *uuid_prefix,
-			     size_t uuid_prefix_len);
+			     const char *uuid_prefix, size_t uuid_prefix_len,
+					 uint32_t cookie);
 
 /*
  * Resume a device plus all dependencies.
  * Ignores devices that don't have a uuid starting with uuid_prefix.
  */
 int dm_tree_activate_children(struct dm_tree_node *dnode,
-			      const char *uuid_prefix,
-			      size_t uuid_prefix_len);
+			      const char *uuid_prefix, size_t uuid_prefix_len,
+						uint32_t cookie);
 
 /*
  * Suspend a device plus all dependencies.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 11428ca..bd344ec 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -806,10 +806,10 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	return r;
 }
 
-static int _deactivate_node(const char *name, uint32_t major, uint32_t minor)
+static int _deactivate_node(const char *name, uint32_t major, uint32_t minor, uint32_t cookie)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	log_verbose("Removing %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
@@ -820,26 +820,34 @@ static int _deactivate_node(const char *name, uint32_t major, uint32_t minor)
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("Failed to set device number for %s deactivation", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
+	if (!dm_task_set_cookie(dmt, cookie) ||
+			!dm_notification_sem_inc(cookie))
+		goto out;
+
 	r = dm_task_run(dmt);
 
+	if (!r)
+		dm_notification_sem_dec(cookie);
+
 	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
 	rm_dev_node(name);
 
 	/* FIXME Remove node from tree or mark invalid? */
 
+out:
 	dm_task_destroy(dmt);
 
 	return r;
 }
 
-static int _rename_node(const char *old_name, const char *new_name, uint32_t major, uint32_t minor)
+static int _rename_node(const char *old_name, const char *new_name, uint32_t major,
+							uint32_t minor, uint32_t cookie)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -857,13 +865,20 @@ static int _rename_node(const char *old_name, const char *new_name, uint32_t maj
 	}
 
 	if (!dm_task_set_newname(dmt, new_name))
-                goto_out;
+		goto_out;
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
+	if (!dm_task_set_cookie(dmt, cookie) ||
+		 (!dm_notification_sem_inc(cookie)))
+		goto out;
+
 	r = dm_task_run(dmt);
 
+	if (!r)
+		dm_notification_sem_dec(cookie);
+
 out:
 	dm_task_destroy(dmt);
 
@@ -873,10 +888,10 @@ out:
 /* FIXME Merge with _suspend_node? */
 static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 			uint32_t read_ahead, uint32_t read_ahead_flags,
-			struct dm_info *newinfo)
+			struct dm_info *newinfo, uint32_t cookie)
 {
 	struct dm_task *dmt;
-	int r;
+	int r = 0;
 
 	log_verbose("Resuming %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
@@ -888,14 +903,12 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	/* FIXME Kernel should fill in name on return instead */
 	if (!dm_task_set_name(dmt, name)) {
 		log_error("Failed to set readahead device name for %s", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("Failed to set device number for %s resumption.", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
@@ -904,9 +917,16 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
 		log_error("Failed to set read ahead");
 
+	if (!dm_task_set_cookie(dmt, cookie) ||
+			!dm_notification_sem_inc(cookie))
+		goto out;
+
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, newinfo);
+	else
+		dm_notification_sem_dec(cookie);
 
+out:
 	dm_task_destroy(dmt);
 
 	return r;
@@ -952,8 +972,8 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 }
 
 int dm_tree_deactivate_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len)
+			     const char *uuid_prefix, size_t uuid_prefix_len,
+			     uint32_t cookie)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
@@ -961,6 +981,16 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 	const struct dm_info *dinfo;
 	const char *name;
 	const char *uuid;
+	uint32_t local_cookie;
+
+	/* Set notification semaphore at the root level only and
+	 * use its value for every child to group them together.
+	 * We are at the root level if cookie == 0. */
+	if (!cookie) {
+		if (!dm_notification_sem_open(&local_cookie))
+			return 0;
+	}	else
+		local_cookie = cookie;
 
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
 		if (!(dinfo = dm_tree_node_get_info(child))) {
@@ -987,7 +1017,7 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		    !info.exists || info.open_count)
 			continue;
 
-		if (!_deactivate_node(name, info.major, info.minor)) {
+		if (!_deactivate_node(name, info.major, info.minor, local_cookie)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
@@ -995,7 +1025,12 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		}
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len);
+			dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, local_cookie);
+	}
+
+	if (!cookie) {
+		dm_notification_sem_wait_zero(local_cookie);
+		dm_notification_sem_close(local_cookie);
 	}
 
 	return 1;
@@ -1085,8 +1120,8 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 }
 
 int dm_tree_activate_children(struct dm_tree_node *dnode,
-				 const char *uuid_prefix,
-				 size_t uuid_prefix_len)
+			     const char *uuid_prefix, size_t uuid_prefix_len,
+			     uint32_t cookie)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
@@ -1094,6 +1129,17 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	const char *name;
 	const char *uuid;
 	int priority;
+	uint32_t local_cookie;
+
+	/* Set notification semaphore at the root level only and
+	 * use its value for every child to group them together.
+	 * We are at the root level if cookie == 0. */
+	if (!cookie) {
+		if (!dm_notification_sem_open(&local_cookie))
+			return 0;
+	}
+	else
+		local_cookie = cookie;
 
 	/* Activate children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
@@ -1106,7 +1152,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len);
+			dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len, local_cookie);
 	}
 
 	handle = NULL;
@@ -1131,10 +1177,13 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 
 			/* Rename? */
 			if (child->props.new_name) {
-				if (!_rename_node(name, child->props.new_name, child->info.major, child->info.minor)) {
+				if (!_rename_node(name, child->props.new_name, child->info.major,
+							child->info.minor, local_cookie)) {
 					log_error("Failed to rename %s (%" PRIu32
 						  ":%" PRIu32 ") to %s", name, child->info.major,
 						  child->info.minor, child->props.new_name);
+					if (!cookie)
+						dm_notification_sem_close(local_cookie);
 					return 0;
 				}
 				child->name = child->props.new_name;
@@ -1145,8 +1194,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 				continue;
 
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
-					  child->props.read_ahead,
-					  child->props.read_ahead_flags, &newinfo)) {
+					  child->props.read_ahead, child->props.read_ahead_flags,
+						&newinfo, local_cookie)) {
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
@@ -1160,6 +1209,11 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 
 	handle = NULL;
 
+	if (!cookie) {
+		dm_notification_sem_wait_zero(local_cookie);
+		dm_notification_sem_close(local_cookie);
+	}
+
 	return 1;
 }
 
@@ -1445,12 +1499,22 @@ out:
 }
 
 int dm_tree_preload_children(struct dm_tree_node *dnode,
-			     const char *uuid_prefix,
-			     size_t uuid_prefix_len)
+			     const char *uuid_prefix, size_t uuid_prefix_len,
+			     uint32_t cookie)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
+	uint32_t local_cookie;
+
+	/* Set notification semaphore at the root level only and
+	 * use its value for every child to group them together.
+	 * We are at the root level if cookie == 0. */
+	if (!cookie) {
+		if (!dm_notification_sem_open(&local_cookie))
+			return 0;
+	} else
+		local_cookie = cookie;
 
 	/* Preload children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
@@ -1464,20 +1528,20 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len);
+			dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len, local_cookie);
 
 		/* FIXME Cope if name exists with no uuid? */
 		if (!child->info.exists) {
 			if (!_create_node(child)) {
 				stack;
-				return 0;
+				goto out;
 			}
 		}
 
 		if (!child->info.inactive_table && child->props.segment_count) {
 			if (!_load_node(child)) {
 				stack;
-				return 0;
+				goto out;
 			}
 		}
 
@@ -1489,8 +1553,8 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
-				  child->props.read_ahead,
-				  child->props.read_ahead_flags, &newinfo)) {
+				  child->props.read_ahead, child->props.read_ahead_flags,
+					&newinfo, local_cookie)) {
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
@@ -1503,7 +1567,17 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 
 	handle = NULL;
 
+	if (!cookie) {
+		dm_notification_sem_wait_zero(local_cookie);
+		dm_notification_sem_close(local_cookie);
+	}
+
 	return 1;
+
+out:
+	if (!cookie)
+		dm_notification_sem_close(local_cookie);
+	return 0;
 }
 
 /*


