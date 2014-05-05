From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 05 May 2014 16:38:04 -0500
Subject: [PATCH] Better clean-up of pvmove failures in a cluster
Message-ID: <1399325884.1503.5.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I don't see any reason why the following patch would be bad, but I'd
like to hear from others first.  In essence, I'm just trying to improve
the error code path.  This seems to improve things for pvmove when a
node in the cluster is not running 'cmirrord' as it should.  However, it
doesn't clean everything up when attempting to create a full cluster
mirror LV.  So there might still be some work left after this.

 brassow

activation:  Remove empty DM devices when table fails to load.

As part of better error handling, remove DM devices that have been
successfully created but failed to load a table.  This can happen
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
@@ -1929,6 +1929,26 @@ out:
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
+	return _deactivate_node(dnode->name, dnode->info.major,
+				dnode->info.minor, NULL, 0, 0);
+}
 
 static int _build_dev_string(char *devbuf, size_t bufsize, struct dm_tree_node *node)
 {
@@ -2662,7 +2682,7 @@ int dm_tree_preload_children(struct dm_t
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
 {
-	int r = 1;
+	int r = 1, node_created = 0;
 	void *handle = NULL;
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
@@ -2684,13 +2704,16 @@ int dm_tree_preload_children(struct dm_t
 				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
-		if (!child->info.exists && !_create_node(child))
+		if (!child->info.exists && !(node_created = _create_node(child)))
 			return_0;
 
 		if (!child->info.inactive_table &&
 		    child->props.segment_count &&
-		    !_load_node(child))
+		    !_load_node(child)) {
+			if (node_created && !_remove_node(child))
+				return_0;
 			return_0;
+		}
 
 		/* Propagate device size change change */
 		if (child->props.size_changed)



