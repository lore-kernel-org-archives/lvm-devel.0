From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:36:52 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110922173652.3351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:36:51

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add dm_tree_retry_remove to use retry logic for device removal in a dm_tree.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.503&r2=1.504
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/WHATS_NEW_DM	2011/09/22 17:23:35	1.503
+++ LVM2/WHATS_NEW_DM	2011/09/22 17:36:50	1.504
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add dm_tree_retry_remove to use retry logic for device removal in a dm_tree.
   Add dm_device_has_mounted_fs fn to check mounted filesystem on a device.
   Add dm_device_has_holders fn to to check use of the device by another device.
   Add dm_sysfs_dir to libdevmapper to retrieve sysfs location thas is set.
--- LVM2/libdm/libdevmapper.h	2011/09/22 17:23:36	1.152
+++ LVM2/libdm/libdevmapper.h	2011/09/22 17:36:50	1.153
@@ -422,6 +422,11 @@
 void dm_tree_use_no_flush_suspend(struct dm_tree_node *dnode);
 
 /*
+ * Retry removal of each device if not successful.
+ */
+void dm_tree_retry_remove(struct dm_tree_node *dnode);
+
+/*
  * Is the uuid prefix present in the tree?
  * Only returns 0 if every node was checked successfully.
  * Returns 1 if the tree walk has to be aborted.
--- LVM2/libdm/libdm-deptree.c	2011/09/22 17:33:51	1.110
+++ LVM2/libdm/libdm-deptree.c	2011/09/22 17:36:50	1.111
@@ -222,7 +222,8 @@
 	struct dm_hash_table *uuids;
 	struct dm_tree_node root;
 	int skip_lockfs;		/* 1 skips lockfs (for non-snapshots) */
-	int no_flush;		/* 1 sets noflush (mirrors/multipath) */
+	int no_flush;			/* 1 sets noflush (mirrors/multipath) */
+	int retry_remove;		/* 1 retries remove if not successful */
 	uint32_t cookie;
 };
 
@@ -1006,7 +1007,7 @@
 }
 
 static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
-			    uint32_t *cookie, uint16_t udev_flags)
+			    uint32_t *cookie, uint16_t udev_flags, int retry)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -1029,6 +1030,10 @@
 	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
+
+	if (retry)
+		dm_task_retry_remove(dmt);
+
 	r = dm_task_run(dmt);
 
 	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
@@ -1231,7 +1236,8 @@
 			continue;
 
 		if (!_deactivate_node(name, info.major, info.minor,
-				      &child->dtree->cookie, child->udev_flags)) {
+				      &child->dtree->cookie, child->udev_flags,
+				      child->dtree->retry_remove)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
@@ -1266,6 +1272,11 @@
 	dnode->dtree->no_flush = 1;
 }
 
+void dm_tree_retry_remove(struct dm_tree_node *dnode)
+{
+	dnode->dtree->retry_remove = 1;
+}
+
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)


