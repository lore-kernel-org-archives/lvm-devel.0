From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 03 Oct 2011 16:25:02 -0500
Subject: [PATCH 2 of 3] Fix udev flags on sub-lvs
In-Reply-To: <1317417040.4475.8.camel@f14.redhat.com>
References: <1317416791.4475.3.camel@f14.redhat.com>
	<1317417040.4475.8.camel@f14.redhat.com>
Message-ID: <1317677102.7301.3.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Refresh patch to update the logging and ignore non-LVM devices when
resetting udev flags.

 brassow

This patch attempts to fix issues with improper udev flags on sub-LVs.

The current code does not always assign proper udev flags to sub-LVs (e.g.
mirror images and log LVs).  This shows up especially during a splitmirror
operation in which an image is split off from a mirror to form a new LV.

A mirror with a disk log is actually composed of 4 different LVs: the 2
mirror images, the log, and the top-level LV that "glues" them all together.
When a 2-way mirror is split into two linear LVs, two of those LVs must be
removed.  The segments of the image which is not split off to form the new
LV are transferred to the top-level LV.  This is done so that the original
LV can maintain its major/minor, UUID, and name.  The sub-lv from which the
segments were transferred gets an error segment as a transitory process
before it is eventually removed.  (Note that if the error target was not put
in place, a resume_lv would result in two LVs pointing to the same segment!
If the machine crashes before the eventual removal of the sub-LV, the result
would be a residual LV with the same mapping as the original (now linear) LV.)
So, the two LVs that need to be removed are now the log device and the sub-LV
with the error segment.  If udev_flags are not properly set, a resume will
cause the error LV to come up and be scanned by udev.  This causes I/O errors.
Additionally, when udev scans sub-LVs (or former sub-LVs), it can cause races
when we are trying to remove those LVs.  This is especially bad during failure
conditions.

When the mirror is suspended, the top-level along with it's sub-LVs are
suspended.  The changes (now 2 linear devices and the yet-to-be-removed log
and error LV) are committed.  When the resume takes place on the original
LV, there are no longer links to the other sub-lvs through the LVM metadata.
The links are implicitly handled by querying the kernel for a list of
dependencies.  This is done in the '_add_dev' function (which is recursively
called for each dependency found) - called through the following chain:
	_add_dev
	dm_tree_add_dev_with_udev_flags
	<*** DM / LVM divide ***>
	_add_dev_to_dtree
	_add_lv_to_dtree
	_create_partial_dtree
	_tree_action
	dev_manager_activate
	_lv_activate_lv
	_lv_resume
	lv_resume_if_active
When udev flags are calculated by '_get_udev_flags', it is done by referencing
the 'logical_volume' structure.  Those flags are then passed down into
'dm_tree_add_dev_with_udev_flags', which in turn passes them to '_add_dev'.
Unfortunately, when '_add_dev' is finding the dependencies, it has no way to
calculate their proper udev_flags.  This is because it is below the DM/LVM
divide - it doesn't have access to the logical_volume structure.  In fact,
'_add_dev' simply reuses the udev_flags given for the initial device!  This
virtually guarentees the udev_flags are wrong for all the dependencies unless
they are reset by some other mechanism.  The current code provides no such
mechanism.  Even if '_add_new_lv_to_dtree' were called on the sub-devices -
which it isn't - entries already in the tree are simply passed over, failing
to reset any udev_flags.  The solution must retain its implicit nature of
discovering dependencies and be able to go back over the dependencies found
to properly set the udev_flags.

There are probably multiple levels at which a solution could be done (either
up or down a function in the call chain from where I've placed it).  That
position may significantly alter the way in which the solution is coded, but
I don't think it will change the general idea.  I'm hoping that others have
some insight on where the best place to make the necessary changes is.

My solution simply calls a new function before leaving '_add_new_lv_to_dtree'
that iterates over the dtree nodes to properly reset the udev_flags of any
children.  It is important that this function occur after the '_add_dev' has
done its job of querying the kernel for a list of dependencies.  It is this
list of children that we use to look up their respective LVs and properly
calculate the udev_flags.

This solution has worked for single machine, cluster, and cluster w/ exclusive
activation.




Index: LVM2/libdm/libdm-deptree.c
===================================================================
--- LVM2.orig/libdm/libdm-deptree.c
+++ LVM2/libdm/libdm-deptree.c
@@ -720,6 +720,18 @@ struct dm_tree_node *dm_tree_add_new_dev
 	return node;
 }
 
+void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)
+
+{
+	struct dm_info *dinfo = &dnode->info;
+
+	if (udev_flags != dnode->udev_flags)
+		log_debug("Resetting %s (%" PRIu32 ":%" PRIu32
+			  ") udev_flags (s/0x%X/0x%X)",
+			  dnode->name, dinfo->major, dinfo->minor,
+			  dnode->udev_flags, udev_flags);
+	dnode->udev_flags = udev_flags;
+}
 
 void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 				 uint32_t read_ahead,
Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -1524,6 +1524,60 @@ static int _add_segment_to_dtree(struct 
 	return 1;
 }
 
+static int set_udev_flags_for_children(struct dev_manager *dm,
+				       struct volume_group *vg,
+				       struct dm_tree_node *dnode)
+{
+	void *handle = NULL;
+	struct dm_tree_node *child;
+	const char *uuid;
+	const struct dm_info *info;
+	char *vgname, *lvname, *layer;
+	struct lv_list *lvl;
+
+	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+		/* Ignore root node */
+		if (!(info  = dm_tree_node_get_info(child)) || !info->exists)
+			continue;
+
+		if (!(uuid = dm_tree_node_get_uuid(child))) {
+			log_error(INTERNAL_ERROR
+				  "Failed to get uuid for %" PRIu32 ":%" PRIu32,
+				  info->major, info->minor);
+			continue;
+		}
+
+		/* Ignore non-LVM devices */
+		if (strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+			log_debug("Not resetting udev flags for non-LVM "
+				  "device %" PRIu32 ":%" PRIu32,
+				  info->major, info->minor);
+			continue;
+		}
+
+		if (!dm_split_lvm_name(dm->mem, dm_tree_node_get_name(child),
+				       &vgname, &lvname, &layer)) {
+			log_error("Failed to split DM name, %s",
+				  dm_tree_node_get_name(child));
+			return 0;
+		}
+
+		if (!(lvl = find_lv_in_vg(vg, lvname)))
+			/*
+			 * Rename of an LV will cause it not to be found, but
+			 * in these cases we should allow udev to rename the
+			 * device - not skip over it because it is a mirror
+			 * sub-lv or something similar
+			 */
+			continue;
+
+		dm_tree_node_set_udev_flags(child,
+					    _get_udev_flags(dm, lvl->lv, layer));
+	}
+
+	return 1;
+}
+
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				struct logical_volume *lv, struct lv_activate_opts *laopts,
 				const char *layer)
@@ -1628,6 +1682,9 @@ static int _add_new_lv_to_dtree(struct d
 			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, laopts, NULL))
 				return_0;
 
+	if (!set_udev_flags_for_children(dm, lv->vg, dnode))
+		return_0;
+
 	return 1;
 }
 
Index: LVM2/libdm/libdevmapper.h
===================================================================
--- LVM2.orig/libdm/libdevmapper.h
+++ LVM2/libdm/libdevmapper.h
@@ -535,6 +535,8 @@ int dm_tree_node_add_replicator_dev_targ
 					   uint32_t slog_region_size);
 /* End of Replicator API */
 
+void dm_tree_node_set_udev_flags(struct dm_tree_node *node, uint16_t udev_flags);
+
 void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
 				      struct dm_tree_node *presuspend_node);
 




