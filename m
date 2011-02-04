From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2011 19:14:44 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110204191444.20244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-04 19:14:41

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c fs.c 
	libdm          : libdm-common.c 

Log message:
	Fix operation node stacking for consecutive dm ops
	
	With the ability to stack many operations in one udev transaction -
	in same cases we are adding and removing same device at the same time
	(i.e. deactivate followed by activate).
	
	This leads to a problem of checking stacked operations:
	i.e. remove /dev/node1 followed by create /dev/node1
	
	If the node creation is handled with udev - there is a problem as
	stacked operation gives warning about existing node1 and will try to
	remove it - while next operation needs to recreate it.
	
	Current code removes all previous stacked operation if the fs op is
	FS_DEL - patch adds similar behavior for FS_ADD - it will try to
	remove any 'delete' operation if udev is in use.
	
	For FS_RENAME operation it seems to be more complex. But as we
	are always stacking FS_READ_AHEAD after FS_ADD operation -
	should be safe to remove all previous operation on the node
	when udev is running.
	
	Code does same checking for stacking libdm and liblvm operations.
	
	As a very simple optimization counters were added for each stacked ops
	type to avoid unneeded list scans if some operation does not exists in
	the list.
	
	Enable skipping of fs_unlock() (udev sync) if only DEL operations are staked.
	as we do not use lv_info for already deleted nodes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1902&r2=1.1903
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2011/02/03 16:03:13	1.1902
+++ LVM2/WHATS_NEW	2011/02/04 19:14:39	1.1903
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Fix operation node stacking for consecutive dm ops.
   Increase hash table size to 1024 lv names and 64 pv uuids.
   Remove fs_unlock() from lv_resume path.
   Fix wipe size when setting up mda.
--- LVM2/lib/activate/activate.c	2011/02/03 01:58:21	1.189
+++ LVM2/lib/activate/activate.c	2011/02/04 19:14:40	1.190
@@ -469,7 +469,7 @@
 	if (with_open_count) {
 		if (locking_is_clustered())
 			sync_local_dev_names(cmd); /* Wait to have udev in sync */
-		else //if (fs_has_non_delete_ops())
+		else if (fs_has_non_delete_ops())
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
--- LVM2/lib/activate/fs.c	2011/02/03 01:24:46	1.58
+++ LVM2/lib/activate/fs.c	2011/02/04 19:14:40	1.59
@@ -257,7 +257,8 @@
 typedef enum {
 	FS_ADD,
 	FS_DEL,
-	FS_RENAME
+	FS_RENAME,
+	NUM_FS_OPS
 } fs_op_t;
 
 static int _do_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
@@ -283,12 +284,18 @@
 
 		if (!_mk_link(dev_dir, vg_name, lv_name, dev, check_udev))
 			stack;
+	default:;
 	}
 
 	return 1;
 }
 
 static DM_LIST_INIT(_fs_ops);
+/*
+ * Count number of stacked fs_op_t operations to allow to skip dm_list search.
+ * FIXME: handling of FS_RENAME
+ */
+static int _count_fs_ops[NUM_FS_OPS];
 
 struct fs_op_parms {
 	struct dm_list list;
@@ -309,15 +316,84 @@
 	*pos += strlen(*ptr) + 1;
 }
 
+static void _del_fs_op(struct fs_op_parms *fsp)
+{
+	_count_fs_ops[fsp->type]--;
+	dm_list_del(&fsp->list);
+	dm_free(fsp);
+}
+
+/* Check if there is other the type of fs operation stacked */
+static int _other_fs_ops(fs_op_t type)
+{
+	int i;
+
+	for (i = 0; i < NUM_FS_OPS; i++)
+		if (type != i && _count_fs_ops[i])
+			return 1;
+	return 0;
+}
+
+/* Check if udev is supposed to create nodes */
+static int _check_udev(int check_udev)
+{
+    return check_udev && dm_udev_get_sync_support() && dm_udev_get_checking();
+}
+
+/* FIXME: duplication of the  code from libdm-common.c */
 static int _stack_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 			const char *lv_name, const char *dev,
 			const char *old_lv_name, int check_udev)
 {
+	struct dm_list *fsph, *fspht;
 	struct fs_op_parms *fsp;
 	size_t len = strlen(dev_dir) + strlen(vg_name) + strlen(lv_name) +
 	    strlen(dev) + strlen(old_lv_name) + 5;
 	char *pos;
 
+	if ((type == FS_DEL) && _other_fs_ops(type))
+		/*
+		 * Ignore any outstanding operations on the fs_op if deleting it.
+		 */
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if (!strcmp(lv_name, fsp->lv_name) &&
+			    !strcmp(vg_name, fsp->vg_name)) {
+				_del_fs_op(fsp);
+				if (!_other_fs_ops(type))
+					break; /* no other non DEL ops */
+			}
+		}
+	else if ((type == FS_ADD) && _count_fs_ops[FS_DEL] && _check_udev(check_udev))
+		/*
+		 * If udev is running ignore previous DEL operation on added fs_op.
+		 * (No other operations for this device then DEL could be staked here).
+		 */
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if ((fsp->type == FS_DEL) &&
+			    !strcmp(lv_name, fsp->lv_name) &&
+			    !strcmp(vg_name, fsp->vg_name)) {
+				_del_fs_op(fsp);
+				break; /* no other DEL ops */
+			}
+		}
+	else if ((type == FS_RENAME) && _check_udev(check_udev))
+		/*
+		 * If udev is running ignore any outstanding operations if renaming it.
+		 *
+		 * Currently RENAME operation happens through 'suspend -> resume'.
+		 * On 'resume' device is added with read_ahead settings, so it
+		 * safe to remove any stacked ADD, RENAME, READ_AHEAD operation
+		 * There cannot be any DEL operation on the renamed device.
+		 */
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if (!strcmp(old_lv_name, fsp->lv_name) &&
+			    !strcmp(vg_name, fsp->vg_name))
+				_del_fs_op(fsp);
+		}
+
 	if (!(fsp = dm_malloc(sizeof(*fsp) + len))) {
 		log_error("No space to stack fs operation");
 		return 0;
@@ -333,6 +409,7 @@
 	_store_str(&pos, &fsp->dev, dev);
 	_store_str(&pos, &fsp->old_lv_name, old_lv_name);
 
+	_count_fs_ops[type]++;
 	dm_list_add(&_fs_ops, &fsp->list);
 
 	return 1;
@@ -347,8 +424,7 @@
 		fsp = dm_list_item(fsph, struct fs_op_parms);
 		_do_fs_op(fsp->type, fsp->dev_dir, fsp->vg_name, fsp->lv_name,
 			  fsp->dev, fsp->old_lv_name, fsp->check_udev);
-		dm_list_del(&fsp->list);
-		dm_free(fsp);
+		_del_fs_op(fsp);
 	}
 }
 
@@ -423,9 +499,7 @@
 	_fs_cookie = cookie;
 }
 
-#if 0
 int fs_has_non_delete_ops(void)
 {
 	return _other_fs_ops(FS_DEL);
 }
-#endif
--- LVM2/libdm/libdm-common.c	2011/02/04 16:08:12	1.108
+++ LVM2/libdm/libdm-common.c	2011/02/04 19:14:40	1.109
@@ -725,7 +725,8 @@
 	NODE_ADD,
 	NODE_DEL,
 	NODE_RENAME,
-	NODE_READ_AHEAD
+	NODE_READ_AHEAD,
+	NUM_NODES
 } node_op_t;
 
 static int _do_node_op(node_op_t type, const char *dev_name, uint32_t major,
@@ -744,12 +745,14 @@
 	case NODE_READ_AHEAD:
 		return _set_dev_node_read_ahead(dev_name, read_ahead,
 						read_ahead_flags);
+	default:;
 	}
 
 	return 1;
 }
 
 static DM_LIST_INIT(_node_ops);
+static int _count_node_ops[NUM_NODES];
 
 struct node_op_parms {
 	struct dm_list list;
@@ -774,6 +777,31 @@
 	*pos += strlen(*ptr) + 1;
 }
 
+static void _del_node_op(struct node_op_parms *nop)
+{
+	_count_node_ops[nop->type]--;
+	dm_list_del(&nop->list);
+	dm_free(nop);
+
+}
+
+/* Check if there is other the type of node operation stacked */
+static int _other_node_ops(node_op_t type)
+{
+	int i;
+
+	for (i = 0; i < NUM_NODES; i++)
+		if (type != i && _count_node_ops[i])
+			return 1;
+	return 0;
+}
+
+/* Check if udev is supposed to create nodes */
+static int _check_udev(int check_udev)
+{
+    return check_udev && dm_udev_get_sync_support() && dm_udev_get_checking();
+}
+
 static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 			  uint32_t minor, uid_t uid, gid_t gid, mode_t mode,
 			  const char *old_name, uint32_t read_ahead,
@@ -785,17 +813,47 @@
 	char *pos;
 
 	/*
-	 * Ignore any outstanding operations on the node if deleting it
+	 * Note: check_udev must have valid content
 	 */
-	if (type == NODE_DEL) {
+	if ((type == NODE_DEL) && _other_node_ops(type))
+		/*
+		 * Ignore any outstanding operations on the node if deleting it.
+		 */
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);
 			if (!strcmp(dev_name, nop->dev_name)) {
-				dm_list_del(&nop->list);
-				dm_free(nop);
+				_del_node_op(nop);
+				if (!_other_node_ops(type))
+					break; /* no other non DEL ops */
 			}
 		}
-	}
+	else if ((type == NODE_ADD) && _count_node_ops[NODE_DEL] && _check_udev(check_udev))
+		/*
+		 * If udev is running ignore previous DEL operation on added node.
+		 * (No other operations for this device then DEL could be staked here).
+		 */
+		dm_list_iterate_safe(noph, nopht, &_node_ops) {
+			nop = dm_list_item(noph, struct node_op_parms);
+			if ((nop->type == NODE_DEL) &&
+			    !strcmp(dev_name, nop->dev_name)) {
+				_del_node_op(nop);
+				break; /* no other DEL ops */
+			}
+		}
+	else if ((type == NODE_RENAME) && _check_udev(check_udev))
+		/*
+		 * If udev is running ignore any outstanding operations if renaming it.
+		 *
+		 * Currently  RENAME operation happens through 'suspend -> resume'.
+		 * On 'resume' device is added with read_ahead settings, so it is
+		 * safe to remove any stacked ADD, RENAME, READ_AHEAD operation
+		 * There cannot be any DEL operation on the renamed device.
+		 */
+		dm_list_iterate_safe(noph, nopht, &_node_ops) {
+			nop = dm_list_item(noph, struct node_op_parms);
+			if (!strcmp(old_name, nop->dev_name))
+				_del_node_op(nop);
+		}
 
 	if (!(nop = dm_malloc(sizeof(*nop) + len))) {
 		log_error("Insufficient memory to stack mknod operation");
@@ -816,6 +874,7 @@
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
 
+	_count_node_ops[type]++;
 	dm_list_add(&_node_ops, &nop->list);
 
 	return 1;
@@ -832,8 +891,7 @@
 			    nop->uid, nop->gid, nop->mode, nop->old_name,
 			    nop->read_ahead, nop->read_ahead_flags,
 			    nop->check_udev);
-		dm_list_del(&nop->list);
-		dm_free(nop);
+		_del_node_op(nop);
 	}
 }
 


