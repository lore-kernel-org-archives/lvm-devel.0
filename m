From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:29 +0100
Subject: [PATCH 05/15] Fix multiple operations on the same node
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <3eab1b81dbfb2ad72087eecea69829edc2f7e292.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As we are now able to stack many operations in one udev
transaction - in same cases we are adding and removing device
at the same time.

This leads to a problem of checking stacked operations:
i.e.   remove /dev/node1 followed by create /dev/node1

If the node creation is handled with udev - there is a problem as
stacked operation gives warning about existing node1 and will try to
remove it - while next operation needs to recreate it.

Current code removes all previous stacked operation if the fs op is
FS_DEL - patch adds similar behavior for FS_ADD - it will try to
remove any 'delete' operation if udev is in use.

As a very simple optimisation counters were added for each stacked ops
type to avoid unneeded list scans.

For the complexity probably the best would be to sort list before processing
stacked ops and removing of unwanted ops - but it seem to complex
for the speed gains we could achieve.

CHECKME: handling of rename operation needs to be better checked
for liblvm2api usage.

(Patch currently checks variable 'check_udev' flag -
previous patch is needed for that)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/fs.c    |   49 ++++++++++++++++++++++++++++++++++++++++--
 libdm/libdm-common.c |   57 +++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 91 insertions(+), 15 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index ae94763..8b8b585 100644
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
@@ -309,15 +316,51 @@ static void _store_str(char **pos, char **ptr, const char *str)
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
 
+	if (type == FS_DEL && _other_fs_ops(type))
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if (!strcmp(fsp->lv_name, lv_name) &&
+			    !strcmp(fsp->vg_name, vg_name))
+				_del_fs_op(fsp);
+		}
+	else if (type == FS_ADD && _c_fs_ops[FS_DEL] &&
+		 check_udev && dm_udev_get_sync_support() &&
+		 dm_udev_get_checking())
+		dm_list_iterate_safe(fsph, fspht, &_fs_ops) {
+			fsp = dm_list_item(fsph, struct fs_op_parms);
+			if ((fsp->type == FS_DEL || fsp->type == FS_ADD) &&
+			    !strcmp(fsp->lv_name, lv_name) &&
+			    !strcmp(fsp->vg_name, vg_name))
+				_del_fs_op(fsp);
+		}
+
 	if (!(fsp = dm_malloc(sizeof(*fsp) + len))) {
 		log_error("No space to stack fs operation");
 		return 0;
@@ -333,6 +376,7 @@ static int _stack_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 	_store_str(&pos, &fsp->dev, dev);
 	_store_str(&pos, &fsp->old_lv_name, old_lv_name);
 
+	_c_fs_ops[type]++;
 	dm_list_add(&_fs_ops, &fsp->list);
 
 	return 1;
@@ -347,8 +391,7 @@ static void _pop_fs_ops(void)
 		fsp = dm_list_item(fsph, struct fs_op_parms);
 		_do_fs_op(fsp->type, fsp->dev_dir, fsp->vg_name, fsp->lv_name,
 			  fsp->dev, fsp->old_lv_name, fsp->check_udev);
-		dm_list_del(&fsp->list);
-		dm_free(fsp);
+		_del_fs_op(fsp);
 	}
 }
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index a181c5f..ee75745 100644
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
@@ -783,18 +805,29 @@ static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 	size_t len = strlen(dev_name) + strlen(old_name) + 2;
 	char *pos;
 
-	/*
-	 * Ignore any outstanding operations on the node if deleting it
-	 */
-	if (type == NODE_DEL) {
+	if (type == NODE_DEL && _other_node_ops(type))
+		/*
+		 * Ignore any outstanding operations on the node if deleting it
+		 */
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);
-			if (!strcmp(dev_name, nop->dev_name)) {
-				dm_list_del(&nop->list);
-				dm_free(nop);
-			}
+			if (!strcmp(dev_name, nop->dev_name))
+				_del_node_op(nop);
+		}
+	else if (type == NODE_ADD && _c_node_ops[NODE_DEL] &&
+		 // CHECKME: needs proper flag in add_dev_node
+		 check_udev && dm_udev_get_sync_support() &&
+		 dm_udev_get_checking())
+		/*
+		 * Ignore any other add/del operations when udev is running
+		 */
+		dm_list_iterate_safe(noph, nopht, &_node_ops) {
+			nop = dm_list_item(noph, struct node_op_parms);
+			if ((nop->type == NODE_DEL ||
+			     nop->type == NODE_ADD) &&
+			    !strcmp(dev_name, nop->dev_name))
+				_del_node_op(nop);
 		}
-	}
 
 	if (!(nop = dm_malloc(sizeof(*nop) + len))) {
 		log_error("Insufficient memory to stack mknod operation");
@@ -815,6 +848,7 @@ static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
 
+	_c_node_ops[type]++;
 	dm_list_add(&_node_ops, &nop->list);
 
 	return 1;
@@ -831,8 +865,7 @@ static void _pop_node_ops(void)
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


