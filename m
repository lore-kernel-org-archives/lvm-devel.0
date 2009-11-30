From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:08 +0100
Subject: [PATCH 08/23] Replicator: suspend/deactivate replicator
In-Reply-To: <1259581043-15308-8-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-9-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introducing dm_tree_set_replicator_suspend() to suspend
replicator control device before actual deactivation of replicator-dev
head device.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |    2 +
 libdm/libdm-deptree.c   |   63 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 05d82bf..aa0e04a 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -80,6 +80,7 @@ dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
 dm_tree_node_add_replicator_target
 dm_tree_node_add_replicator_dev_target
+dm_tree_set_replicator_suspend
 dm_tree_node_set_read_ahead
 dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3041fcf..3244b46 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -458,6 +458,8 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 					   uint32_t slog_flags,		/* Mirror log flags */
 					   uint32_t slog_size);
 
+int dm_tree_set_replicator_suspend(struct dm_tree *dtree, const char *uuid);
+
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
 				    const char *dev_name,
 				    const char *dlid,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a7e7dd2..57e89dd 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -157,6 +157,7 @@ struct dm_tree_node {
         struct dm_list used_by;    	/* Nodes that use this node */
 
 	int activation_priority;	/* 0 gets activated first */
+	int replicator_suspend;		/* 1 gets suspend first */
 
 	uint16_t udev_flags;		/* Udev control flags */
 
@@ -678,6 +679,18 @@ void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 	dnode->props.read_ahead_flags = read_ahead_flags;
 }
 
+int dm_tree_set_replicator_suspend(struct dm_tree *dtree, const char *uuid)
+{
+	struct dm_tree_node *dnode;
+
+	if ((dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
+		log_verbose("Setting replicator suspend for %s", dnode->name);
+		dnode->replicator_suspend = 1;
+	}
+
+	return 1;
+}
+
 int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
 {
 	return _add_dev(dtree, &dtree->root, major, minor) ? 1 : 0;
@@ -1030,6 +1043,53 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 	return r;
 }
 
+static int _suspend_replicator_parent(struct dm_tree_node *dnode,
+				      const char *uuid_prefix,
+				      size_t uuid_prefix_len)
+{
+	struct dm_info info;
+	const struct dm_info *dinfo;
+	const char *name;
+	const char *uuid;
+	struct dm_tree_link *dlink;
+
+	dm_list_iterate_items(dlink, &dnode->uses) {
+		if (!dlink->node->replicator_suspend)
+			continue;
+
+		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
+			stack;
+			continue;
+		}
+		/* Ignore if it doesn't belong to this VG */
+		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
+			continue;
+
+		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
+			stack;
+			continue;
+		}
+
+		if (dinfo->suspended)
+			continue;
+
+		if (!(name = dm_tree_node_get_name(dlink->node))) {
+			stack;
+			continue;
+		}
+
+		if (!_suspend_node(name, dinfo->major, dinfo->minor,
+				   1, 1, &info)) {
+			log_error("Unable to suspend %s (%" PRIu32
+				  ":%" PRIu32 ")", name, dinfo->major,
+				  dinfo->minor);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 				   const char *uuid_prefix,
 				   size_t uuid_prefix_len)
@@ -1066,6 +1126,9 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		    !info.exists || info.open_count)
 			continue;
 
+		if (!_suspend_replicator_parent(child, uuid_prefix, uuid_prefix_len))
+			continue;
+
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32
-- 
1.6.5.3


