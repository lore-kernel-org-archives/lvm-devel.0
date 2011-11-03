From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:43:23 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111103144323.19808.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:43:22

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Thin api change for dm_tree_node_add_thin_target
	
	A little code shuffling and adding support for
	DM_THIN_ERROR_DEVICE_ID which might be eventually be used
	for activation of thin which is going to be deleted.
	For now we do not need it lvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/libdm/libdevmapper.h	2011/10/28 20:06:50	1.166
+++ LVM2/libdm/libdevmapper.h	2011/11/03 14:43:21	1.167
@@ -540,11 +540,9 @@
  * FIXME: Defines bellow are based on kernel's dm-thin.c defines
  * DATA_DEV_BLOCK_SIZE_MIN_SECTORS (64 * 1024 >> SECTOR_SHIFT)
  * DATA_DEV_BLOCK_SIZE_MAX_SECTORS (1024 * 1024 * 1024 >> SECTOR_SHIFT)
- * MAX_DEV_ID ((1 << 24) - 1)
  */
 #define DM_THIN_MIN_DATA_BLOCK_SIZE (UINT32_C(128))
 #define DM_THIN_MAX_DATA_BLOCK_SIZE (UINT32_C(2097152))
-#define DM_THIN_MAX_DEVICE_ID (UINT32_C((1 << 24) - 1))
 
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
@@ -591,9 +589,18 @@
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
                                        const struct dm_thin_message *message);
 
+/*
+ * FIXME: Defines bellow are based on kernel's dm-thin.c defines
+ * MAX_DEV_ID ((1 << 24) - 1)
+ */
+#define DM_THIN_MAX_DEVICE_ID (UINT32_C((1 << 24) - 1))
+/* Reserved device_id for error (deleted) thin device */
+// FIXME - only needed for in-delete thin is not activated
+#define DM_THIN_ERROR_DEVICE_ID (UINT32_MAX)
+
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
-				 const char *thin_pool_uuid,
+				 const char *pool_uuid,
 				 uint32_t device_id);
 
 void dm_tree_node_set_udev_flags(struct dm_tree_node *node, uint16_t udev_flags);
--- LVM2/libdm/libdm-deptree.c	2011/10/30 22:52:08	1.142
+++ LVM2/libdm/libdm-deptree.c	2011/11/03 14:43:21	1.143
@@ -2973,26 +2973,33 @@
 
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
-				 const char *thin_pool_uuid,
+				 const char *pool_uuid,
 				 uint32_t device_id)
 {
+	struct dm_tree_node *pool;
 	struct load_segment *seg;
 
-	if (!_thin_validate_device_id(device_id))
-		return_0;
-
-	if (!(seg = _add_segment(node, SEG_THIN, size)))
-		return_0;
-
-	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree, thin_pool_uuid))) {
-		log_error("Missing thin pool uuid %s.", thin_pool_uuid);
+	if (!(pool = dm_tree_find_node_by_uuid(node->dtree, pool_uuid))) {
+		log_error("Missing thin pool uuid %s.", pool_uuid);
 		return 0;
 	}
 
-	if (!_link_tree_nodes(node, seg->pool))
+	if (!_link_tree_nodes(node, pool))
 		return_0;
 
-	seg->device_id = device_id;
+	if (device_id == DM_THIN_ERROR_DEVICE_ID) {
+		if (!dm_tree_node_add_error_target(node, size))
+			return_0;
+	} else {
+		if (!_thin_validate_device_id(device_id))
+			return_0;
+
+		if (!(seg = _add_segment(node, SEG_THIN, size)))
+			return_0;
+
+		seg->pool = pool;
+		seg->device_id = device_id;
+	}
 
 	return 1;
 }


