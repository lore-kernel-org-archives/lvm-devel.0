From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Oct 2011 14:45:44 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20111006144544.10591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-06 14:45:42

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	This patch fixes issues with improper udev flags on sub-LVs.
	
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
	
	When the mirror is suspended, the top-level along with its sub-LVs are
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
	
	My solution simply calls a new function before leaving '_add_new_lv_to_dtree'
	that iterates over the dtree nodes to properly reset the udev_flags of any
	children.  It is important that this function occur after the '_add_dev' has
	done its job of querying the kernel for a list of dependencies.  It is this
	list of children that we use to look up their respective LVs and properly
	calculate the udev_flags.
	
	This solution has worked for single machine, cluster, and cluster w/ exclusive
	activation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2146&r2=1.2147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/WHATS_NEW	2011/10/06 14:17:45	1.2146
+++ LVM2/WHATS_NEW	2011/10/06 14:45:40	1.2147
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix improper udev settings during suspend/resume for mirror sub-LVs.
   Fix vgsplit when there are mirrors that have mirrored logs.
   Clarify multi-name device filter pattern matching explanation in lvm.conf.5.
   Introduce lv_send_message and dev_manager_send_message.
--- LVM2/lib/activate/dev_manager.c	2011/10/03 18:37:47	1.236
+++ LVM2/lib/activate/dev_manager.c	2011/10/06 14:45:41	1.237
@@ -1568,6 +1568,57 @@
 	return 1;
 }
 
+static int _set_udev_flags_for_children(struct dev_manager *dm,
+					struct volume_group *vg,
+					struct dm_tree_node *dnode)
+{
+	char *p;
+	const char *uuid;
+	void *handle = NULL;
+	struct dm_tree_node *child;
+	const struct dm_info *info;
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
+		if (!(p = strstr(uuid, UUID_PREFIX)))
+			continue;
+		p += strlen(UUID_PREFIX);
+
+		/* Ignore LVs that belong to different VGs (due to stacking) */
+		if (strncmp(p, (char *)vg->id.uuid, ID_LEN))
+			continue;
+
+		/* Ignore LVM devices with 'layer' suffixes */
+		if (strrchr(p, '-'))
+			continue;
+
+		if (!(lvl = find_lv_in_vg_by_lvid(vg, (const union lvid *)p))) {
+			log_error(INTERNAL_ERROR
+				  "%s (%" PRIu32 ":%" PRIu32 ") not found in VG",
+				  dm_tree_node_get_name(child),
+				  info->major, info->minor);
+			return 0;
+		}
+
+		dm_tree_node_set_udev_flags(child,
+					    _get_udev_flags(dm, lvl->lv, NULL));
+	}
+
+	return 1;
+}
+
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				struct logical_volume *lv, struct lv_activate_opts *laopts,
 				const char *layer)
@@ -1672,6 +1723,9 @@
 			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, laopts, NULL))
 				return_0;
 
+	if (!_set_udev_flags_for_children(dm, lv->vg, dnode))
+		return_0;
+
 	return 1;
 }
 
--- LVM2/libdm/libdevmapper.h	2011/10/06 11:05:56	1.158
+++ LVM2/libdm/libdevmapper.h	2011/10/06 14:45:42	1.159
@@ -560,6 +560,8 @@
 				 const char *thin_pool_uuid,
 				 uint32_t device_id);
 
+void dm_tree_node_set_udev_flags(struct dm_tree_node *node, uint16_t udev_flags);
+
 void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
 				      struct dm_tree_node *presuspend_node);
 
--- LVM2/libdm/libdm-deptree.c	2011/10/06 11:05:56	1.121
+++ LVM2/libdm/libdm-deptree.c	2011/10/06 14:45:42	1.122
@@ -741,6 +741,18 @@
 	return node;
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
 
 void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 				 uint32_t read_ahead,


