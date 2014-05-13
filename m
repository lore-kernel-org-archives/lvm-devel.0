From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 12 May 2014 21:31:43 -0500
Subject: [PATCH v2] Better clean-up of pvmove failures in a cluster
Message-ID: <1399948303.5822.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I think this patch is just about ready, but I'd like to make sure that
I'm not making any mistakes in calling _deactivate_node().
Specifically, I'd like to know whether I need to pass a cookie pointer
and udev_flags.  If I need udev_flags, do I need anything special.

 brassow

activation:  Remove empty DM device when table fails to load.

As part of better error handling, remove DM devices that have been
sucessfully created but failed to load a table.  This can happen
when pvmove'ing in a cluster and the cluster mirror daemon is not
running on a remote node - the mapping table failing to load as a
result.  In this case, any revert would work on other nodes running
cmirrord because the DM devices on those nodes did succeed in loading.
However, because no table was able to load on the non-cmirrord nodes,
there is no table present that points to what needs to be reverted.
This causes the empty DM device to remain on the system without being
present in any LVM representation.

Index: lvm2/libdm/libdm-deptree.c
===================================================================
--- lvm2.orig/libdm/libdm-deptree.c
+++ lvm2/libdm/libdm-deptree.c
@@ -1920,15 +1920,49 @@ static int _create_node(struct dm_tree_n
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if ((r = dm_task_run(dmt)))
-		r = dm_task_get_info(dmt, &dnode->info);
-
+	if ((r = dm_task_run(dmt))) {
+		if (!(r = dm_task_get_info(dmt, &dnode->info)))
+			/*
+			 * This should not be possible to occur.  However,
+			 * we print an error message anyway for the more
+			 * absurd cases (e.g. memory corruption) so there
+			 * is never any question as to what happened.
+			 */
+			log_error(INTERNAL_ERROR
+				  "Unable to get DM task info");
+	}
 out:
 	dm_task_destroy(dmt);
 
 	return r;
 }
 
+/*
+ * _remove_node
+ *
+ * This function is only used to remove a DM device that has failed
+ * to load any table.
+ */
+static int _remove_node(struct dm_tree_node *dnode)
+{
+	if (!dnode->info.exists)
+		return 1;
+
+	if (dnode->info.live_table || dnode->info.inactive_table) {
+		log_error(INTERNAL_ERROR
+			  "_remove_node called on device with loaded table(s).");
+		return 0;
+	}
+
+	if (!_deactivate_node(dnode->name, dnode->info.major,
+			      dnode->info.minor, NULL, 0, 0)) {
+		log_error("Failed to clean-up device with no table: %s %u:%u",
+			  dnode->name ? dnode->name : "",
+			  dnode->info.major, dnode->info.minor);
+		return 0;
+	}
+	return 1;
+}
 
 static int _build_dev_string(char *devbuf, size_t bufsize, struct dm_tree_node *node)
 {
@@ -2662,7 +2696,7 @@ int dm_tree_preload_children(struct dm_t
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
 {
-	int r = 1;
+	int r = 1, node_created = 0;
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
@@ -2684,13 +2718,25 @@ int dm_tree_preload_children(struct dm_t
 				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
-		if (!child->info.exists && !_create_node(child))
+		if (!child->info.exists && !(node_created = _create_node(child)))
 			return_0;
 
 		if (!child->info.inactive_table &&
 		    child->props.segment_count &&
-		    !_load_node(child))
+		    !_load_node(child)) {
+			/*
+			 * If the table load does not succeed, we remove the
+			 * device in the kernel that would otherwise have an
+			 * empty table.  This makes the create + load of the
+			 * device atomic.  However, if other dependencies have
+			 * already been created and loaded; this code is
+			 * insufficient to remove those - only the node
+			 * encountering the table load failure is removed.
+			 */
+			if (node_created && !_remove_node(child))
+				return_0;
 			return_0;
+		}
 
 		/* Propagate device size change change */
 		if (child->props.size_changed)



