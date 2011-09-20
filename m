From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 14:58:01 +0200
Subject: [PATCH 6/7][retry remove] Add "retry remove" support for dm trees
Message-ID: <4E788DD9.9030907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 libdm/libdevmapper.h  |    5 +++++
 libdm/libdm-deptree.c |   17 ++++++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 9df34bb..f6614a5 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -415,6 +415,11 @@ void dm_tree_skip_lockfs(struct dm_tree_node *dnode);
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
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 864723d..d0b2743 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -222,7 +222,8 @@ struct dm_tree {
 	struct dm_hash_table *uuids;
 	struct dm_tree_node root;
 	int skip_lockfs;		/* 1 skips lockfs (for non-snapshots) */
-	int no_flush;		/* 1 sets noflush (mirrors/multipath) */
+	int no_flush;			/* 1 sets noflush (mirrors/multipath) */
+	int retry_remove;		/* 1 retries remove if not successful */
 	uint32_t cookie;
 };
 
@@ -982,7 +983,7 @@ static int _node_has_closed_parents(struct dm_tree_node *node,
 }
 
 static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
-			    uint32_t *cookie, uint16_t udev_flags)
+			    uint32_t *cookie, uint16_t udev_flags, int retry)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -1005,6 +1006,10 @@ static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
 	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
+
+	if (retry)
+		dm_task_retry_remove(dmt);
+
 	r = dm_task_run(dmt);
 
 	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
@@ -1205,7 +1210,8 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (!_deactivate_node(name, info.major, info.minor,
-				      &child->dtree->cookie, child->udev_flags)) {
+				      &child->dtree->cookie, child->udev_flags,
+				      child->dtree->retry_remove)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
@@ -1240,6 +1246,11 @@ void dm_tree_use_no_flush_suspend(struct dm_tree_node *dnode)
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


