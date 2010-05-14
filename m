From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:18:59 +0200
Subject: [PATCH 04/23] Replicator: suspend/deactivate replicator
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <0d91c5e08f309fd9f3698bfd975a4851da7db857.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introducing dm_tree_set_suspend_priority() for suspending replicator
control target before deactivation of replicator-dev target.

This patch presents no functional change to current dtree - only
replicator target currently sets higher suspend priority for some of its
nodes.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |    3 +++
 libdm/libdm-deptree.c   |   14 ++++++++++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 090e633..4f8c42b 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -82,6 +82,7 @@ dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
 dm_tree_node_add_replicator_target
 dm_tree_node_add_replicator_dev_target
+dm_tree_node_set_presuspend
 dm_tree_node_set_read_ahead
 dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e0b7739..8d44e7a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -474,6 +474,9 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 					   uint32_t slog_region_size);
 /* End of Replicator API */
 
+void dm_tree_node_set_presuspend(struct dm_tree_node *node,
+				 struct dm_tree_node *presuspend_node);
+
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
 				    const char *dev_name,
 				    const char *dlid,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6cbb806..411c30a 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -168,6 +168,8 @@ struct dm_tree_node {
 	void *context;			/* External supplied context */
 
 	struct load_properties props;	/* For creation/table (re)load */
+
+	struct dm_tree_node *presuspend_children; /* Presuspend first */
 };
 
 struct dm_tree {
@@ -684,6 +686,11 @@ void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 	dnode->props.read_ahead_flags = read_ahead_flags;
 }
 
+void dm_tree_node_set_presuspend(struct dm_tree_node *node, struct dm_tree_node *presuspend_node)
+{
+	node->presuspend_children = presuspend_node;
+}
+
 int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
 {
 	return _add_dev(dtree, &dtree->root, major, minor, 0) ? 1 : 0;
@@ -794,6 +801,9 @@ static int _children_suspended(struct dm_tree_node *node,
 		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
 			continue;
 
+		if (dlink->node->presuspend_children == node)
+			return 1;
+
 		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
 			stack;	/* FIXME Is this normal? */
 			return 0;
@@ -1095,6 +1105,10 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 			continue;
 		}
 
+		if (child->presuspend_children &&
+		    !dm_tree_suspend_children(child, uuid_prefix, uuid_prefix_len))
+			continue;
+
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32
-- 
1.7.0.1


