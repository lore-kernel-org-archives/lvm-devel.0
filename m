From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:28 +0100
Subject: [PATCH 05/24] Perf: Fix multiple operations on the same node
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <26382d082d66727c13809cb4216caec33468ad20.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With ability to stack many operations in one udev transaction -
in same cases we are adding and removing same device at the same time.

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
type to avoid unneeded list scans if some operation couldn't exist in
the list.

WARNING:
Patch checks variable 'check_udev' flag so the previous patch is mandatory

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/fs.c    |   61 ++++++++++++++++++++++++++++++++++++++++--
 libdm/libdm-common.c |   71 ++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 121 insertions(+), 11 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index ae94763..a3db5a7 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -257,7 +257,8 @@ static int _rm_link(const char *dev_dir, const char *vg_name,
 typedef enum {
 	FS_ADD,
 	FS_DEL,
-	FS_RENAME
+	FS_RENAME,
+	NUM_FS_OPS
 } fs_op_t;
 
 static int _do_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
@@ -283,12 +284,18 @@ static int _do_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 
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
+static int _c_fs_ops[NUM_FS_OPS];
 
 struct fs_op_parms {
 	struct dm_list list;
@@ -309,15 +316,63 @@ static void _store_str(char **pos, char **ptr, const char *str)
 	*pos += strlen(*ptr) + 1;
 }
 
+static int _other_fs_ops(fs_op_t type)
+{
+	int i;
+
+	for (i = 0; i < NUM_FS_OPS; i++)
+		if (type != i && _c_fs_ops[i])
+			return 1;
+	return 0;
+}
+
+static void _del_fs_op(struct fs_op_parms *fsp)
+{
+	_c_fs_ops[fsp->type]--;
+	dm_list_del(&fsp->list);
+	dm_free(fsp);
+}
+
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
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if (!strcmp(lv_name, fsp->lv_name) &&
+			    !strcmp(vg_name, fsp->vg_name)) {
+				_del_fs_op(fsp);
+				if (!_other_fs_ops(type))
+					break;
+			}
+		}
+	else if ((type == FS_ADD) && _c_fs_ops[FS_DEL] && check_udev &&
+		 dm_udev_get_sync_support() && dm_udev_get_checking())
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if ((fsp->type == FS_DEL) &&
+			    !strcmp(lv_name, fsp->lv_name) &&
+			    !strcmp(vg_name, fsp->vg_name)) {
+				_del_fs_op(fsp);
+				break;
+			}
+		}
+	else if ((type == FS_RENAME) && check_udev &&
+		 dm_udev_get_sync_support() && dm_udev_get_checking())
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
@@ -333,6 +388,7 @@ static int _stack_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 	_store_str(&pos, &fsp->dev, dev);
 	_store_str(&pos, &fsp->old_lv_name, old_lv_name);
 
+	_c_fs_ops[type]++;
 	dm_list_add(&_fs_ops, &fsp->list);
 
 	return 1;
@@ -347,8 +403,7 @@ static void _pop_fs_ops(void)
 		fsp = dm_list_item(fsph, struct fs_op_parms);
 		_do_fs_op(fsp->type, fsp->dev_dir, fsp->vg_name, fsp->lv_name,
 			  fsp->dev, fsp->old_lv_name, fsp->check_udev);
-		dm_list_del(&fsp->list);
-		dm_free(fsp);
+		_del_fs_op(fsp);
 	}
 }
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index a181c5f..9593e75 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -724,7 +724,8 @@ typedef enum {
 	NODE_ADD,
 	NODE_DEL,
 	NODE_RENAME,
-	NODE_READ_AHEAD
+	NODE_READ_AHEAD,
+	NUM_NODES
 } node_op_t;
 
 static int _do_node_op(node_op_t type, const char *dev_name, uint32_t major,
@@ -743,12 +744,14 @@ static int _do_node_op(node_op_t type, const char *dev_name, uint32_t major,
 	case NODE_READ_AHEAD:
 		return _set_dev_node_read_ahead(dev_name, read_ahead,
 						read_ahead_flags);
+	default:;
 	}
 
 	return 1;
 }
 
 static DM_LIST_INIT(_node_ops);
+static int _c_node_ops[NUM_NODES];
 
 struct node_op_parms {
 	struct dm_list list;
@@ -773,6 +776,25 @@ static void _store_str(char **pos, char **ptr, const char *str)
 	*pos += strlen(*ptr) + 1;
 }
 
+static int _other_node_ops(node_op_t type)
+{
+	int i;
+
+	for (i = 0; i < NUM_NODES; i++)
+		if (type != i && _c_node_ops[i])
+			return 1;
+
+	return 0;
+}
+
+static void _del_node_op(struct node_op_parms *nop)
+{
+	_c_node_ops[nop->type]--;
+	dm_list_del(&nop->list);
+	dm_free(nop);
+
+}
+
 static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 			  uint32_t minor, uid_t uid, gid_t gid, mode_t mode,
 			  const char *old_name, uint32_t read_ahead,
@@ -784,17 +806,50 @@ static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 	char *pos;
 
 	/*
-	 * Ignore any outstanding operations on the node if deleting it
+	 * Note: check_udev must have valid content
 	 */
-	if (type == NODE_DEL) {
+	if ((type == NODE_DEL) && _other_node_ops(type))
+		/*
+		 * Ignore any outstanding operations on the node if deleting it
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
+	else if ((type == NODE_ADD) &&
+		 _c_node_ops[NODE_DEL] && check_udev &&
+		 dm_udev_get_sync_support() && dm_udev_get_checking())
+		/*
+		 * Ignore previous del operation when udev is running
+		 * Any other stacked operation for dev_node is error
+		 */
+		dm_list_iterate_safe(noph, nopht, &_node_ops) {
+			nop = dm_list_item(noph, struct node_op_parms);
+			if ((nop->type == NODE_DEL) &&
+			    !strcmp(dev_name, nop->dev_name)) {
+				_del_node_op(nop);
+				break;
+			}
+		}
+	else if ((type == NODE_RENAME) && check_udev &&
+		 dm_udev_get_sync_support() && dm_udev_get_checking())
+		/*
+		 * Ignore any outstanding operations on the node if renaming it
+		 *
+		 * Currently  RENAME operation goes through suspend - resume
+		 * on resume devnode is added with read_ahead settings, so it
+		 * it's safe to remove any stacked ADD, RENAME, READ_AHEAD operation
+		 * There cannot be any DEL operation on the renamed node.
+		 */
+		dm_list_iterate_safe(noph, nopht, &_node_ops) {
+			nop = dm_list_item(noph, struct node_op_parms);
+			if (!strcmp(old_name, nop->dev_name))
+				_del_node_op(nop);
+		}
 
 	if (!(nop = dm_malloc(sizeof(*nop) + len))) {
 		log_error("Insufficient memory to stack mknod operation");
@@ -815,6 +870,7 @@ static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
 
+	_c_node_ops[type]++;
 	dm_list_add(&_node_ops, &nop->list);
 
 	return 1;
@@ -831,8 +887,7 @@ static void _pop_node_ops(void)
 			    nop->uid, nop->gid, nop->mode, nop->old_name,
 			    nop->read_ahead, nop->read_ahead_flags,
 			    nop->check_udev);
-		dm_list_del(&nop->list);
-		dm_free(nop);
+		_del_node_op(nop);
 	}
 }
 
-- 
1.7.3.5


