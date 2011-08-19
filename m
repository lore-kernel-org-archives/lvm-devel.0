From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 17:02:49 -0000
Subject: LVM2/libdm libdm-deptree.c ioctl/libdm-iface.c
Message-ID: <20110819170249.27187.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 17:02:48

Modified files:
	libdm          : libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	spaces->tabs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/libdm/libdm-deptree.c	2011/08/19 16:26:03	1.107
+++ LVM2/libdm/libdm-deptree.c	2011/08/19 17:02:48	1.108
@@ -150,7 +150,7 @@
 	struct dm_tree_node *replicator;/* Replicator-dev */
 	uint64_t rdevice_index;		/* Replicator-dev */
 
-	uint64_t rebuilds;              /* raid */
+	uint64_t rebuilds;	      /* raid */
 };
 
 /* Per-device properties */
@@ -194,12 +194,12 @@
 struct dm_tree_node {
 	struct dm_tree *dtree;
 
-        const char *name;
-        const char *uuid;
-        struct dm_info info;
+	const char *name;
+	const char *uuid;
+	struct dm_info info;
 
-        struct dm_list uses;       	/* Nodes this node uses */
-        struct dm_list used_by;    	/* Nodes that use this node */
+	struct dm_list uses;       	/* Nodes this node uses */
+	struct dm_list used_by;    	/* Nodes that use this node */
 
 	int activation_priority;	/* 0 gets activated first */
 
@@ -1038,7 +1038,7 @@
 	}
 
 	if (!dm_task_set_newname(dmt, new_name))
-                goto_out;
+		goto_out;
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
@@ -1450,10 +1450,10 @@
 static int _build_dev_string(char *devbuf, size_t bufsize, struct dm_tree_node *node)
 {
 	if (!dm_format_dev(devbuf, bufsize, node->info.major, node->info.minor)) {
-                log_error("Failed to format %s device number for %s as dm "
-                          "target (%u,%u)",
-                          node->name, node->uuid, node->info.major, node->info.minor);
-                return 0;
+		log_error("Failed to format %s device number for %s as dm "
+			  "target (%u,%u)",
+			  node->name, node->uuid, node->info.major, node->info.minor);
+		return 0;
 	}
 
 	return 1;
@@ -2132,8 +2132,8 @@
 }
 
 int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
-                                               uint64_t size,
-                                               const char *origin_uuid)
+					       uint64_t size,
+					       const char *origin_uuid)
 {
 	struct load_segment *seg;
 	struct dm_tree_node *origin_node;
@@ -2238,7 +2238,7 @@
 }
 
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
-                                     uint64_t size)
+				     uint64_t size)
 {
 	if (!_add_segment(node, SEG_ERROR, size))
 		return_0;
@@ -2247,7 +2247,7 @@
 }
 
 int dm_tree_node_add_zero_target(struct dm_tree_node *node,
-                                    uint64_t size)
+				    uint64_t size)
 {
 	if (!_add_segment(node, SEG_ZERO, size))
 		return_0;
@@ -2256,7 +2256,7 @@
 }
 
 int dm_tree_node_add_linear_target(struct dm_tree_node *node,
-                                      uint64_t size)
+				      uint64_t size)
 {
 	if (!_add_segment(node, SEG_LINEAR, size))
 		return_0;
@@ -2265,8 +2265,8 @@
 }
 
 int dm_tree_node_add_striped_target(struct dm_tree_node *node,
-                                       uint64_t size,
-                                       uint32_t stripe_size)
+				       uint64_t size,
+				       uint32_t stripe_size)
 {
 	struct load_segment *seg;
 
@@ -2353,7 +2353,7 @@
 }
 
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
-                                      uint64_t size)
+				      uint64_t size)
 {
 	if (!_add_segment(node, SEG_MIRRORED, size))
 		return_0;
@@ -2573,9 +2573,9 @@
 }
 
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
-                                    const char *dev_name,
-                                    const char *uuid,
-                                    uint64_t offset)
+				    const char *dev_name,
+				    const char *uuid,
+				    uint64_t offset)
 {
 	struct load_segment *seg;
 	struct stat info;
@@ -2599,7 +2599,7 @@
 			return 0;
 		}
 
-        	if (!S_ISBLK(info.st_mode)) {
+		if (!S_ISBLK(info.st_mode)) {
 			log_error("Device %s is not a block device.", dev_name);
 			return 0;
 		}
--- LVM2/libdm/ioctl/libdm-iface.c	2011/08/19 16:49:00	1.118
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/08/19 17:02:48	1.119
@@ -542,8 +542,8 @@
 int dm_cookie_supported(void)
 {
 	return (dm_check_version() &&
-	        _dm_version >= 4 &&
-	        _dm_version_minor >= 15);
+		_dm_version >= 4 &&
+		_dm_version_minor >= 15);
 }
 
 static int dm_inactive_supported(void)
@@ -647,12 +647,12 @@
 }
 
 uint32_t dm_task_get_read_ahead(const struct dm_task *dmt, uint32_t *read_ahead)
-{              
+{
 	const char *dev_name;
 
 	*read_ahead = 0;
 
-        if (!dmt->dmi.v4 || !(dmt->dmi.v4->flags & DM_EXISTS_FLAG))
+	if (!dmt->dmi.v4 || !(dmt->dmi.v4->flags & DM_EXISTS_FLAG))
 		return 0;
 
 	if (*dmt->dmi.v4->name)
@@ -1336,7 +1336,7 @@
 		if (!dm_task_set_cookie(dmt, &cookie,
 					(dmt->event_nr & DM_UDEV_FLAGS_MASK) >>
 					DM_UDEV_FLAGS_SHIFT))
-                        stack; /* keep going */
+			stack; /* keep going */
 	}
 
 	if (!dm_task_run(dmt))
@@ -1492,8 +1492,8 @@
 		goto out;
 	}
 
-        if (!(deps = dm_task_get_deps(task)))
-                goto out;
+	if (!(deps = dm_task_get_deps(task)))
+		goto out;
 
 	for (i = 0; i < deps->count; i++) {
 		/* Only recurse with dm devices */
@@ -1707,15 +1707,15 @@
 			  "are known to be suspended: "
 			  "%s%s%s %s%.0d%s%.0d%s%s",
 			  suspended_counter,
-	                  dmt->dev_name ? : "",
-	                  dmt->uuid ? " UUID " : "",
+			  dmt->dev_name ? : "",
+			  dmt->uuid ? " UUID " : "",
 			  dmt->uuid ? : "",
-	                  dmt->major > 0 ? "(" : "",
-	                  dmt->major > 0 ? dmt->major : 0,
-	                  dmt->major > 0 ? ":" : "",
-	                  dmt->minor > 0 ? dmt->minor : 0,
-	                  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
-	                  dmt->major > 0 ? ") " : "");
+			  dmt->major > 0 ? "(" : "",
+			  dmt->major > 0 ? dmt->major : 0,
+			  dmt->major > 0 ? ":" : "",
+			  dmt->minor > 0 ? dmt->minor : 0,
+			  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
+			  dmt->major > 0 ? ") " : "");
 
 	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:


