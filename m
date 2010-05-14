From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:19:00 +0200
Subject: [PATCH 05/23] Replicator: use open_count for all related heads
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <83b98f572efba4d6aab23a907b1316429f7c3628.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For deactivation of Replicator it is better to check in advance
that all heads have open_count == 0. For this presuspend_children
node is used as all heads are using this node.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-deptree.c |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 411c30a..1c164aa 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -896,6 +896,42 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	return r;
 }
 
+static int _is_parent_unused(struct dm_tree_node *node,
+			      const char *uuid_prefix,
+			      size_t uuid_prefix_len)
+{
+	struct dm_tree_link *dlink;
+	const struct dm_info *dinfo;
+	struct dm_info info;
+	const char *uuid;
+
+	dm_list_iterate_items(dlink, &node->used_by) {
+		if (!(uuid = dm_tree_node_get_uuid(dlink->node))) {
+			stack;
+			continue;
+		}
+
+		/* Ignore if it doesn't belong to this VG */
+		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
+			continue;
+
+		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
+			stack;	/* FIXME Is this normal? */
+			return 0;
+		}
+
+		/* Refresh open_count */
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
+		    !info.exists)
+			continue;
+
+		if (info.open_count)
+			return 0;
+	}
+
+	return 1;
+}
+
 static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
 			    uint32_t *cookie, uint16_t udev_flags)
 {
@@ -1094,7 +1130,10 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		    !info.exists)
 			continue;
 
-		if (info.open_count) {
+		if (info.open_count ||
+		    (child->presuspend_children &&
+		     !_is_parent_unused(child->presuspend_children,
+					uuid_prefix, uuid_prefix_len))) {
 			/* Only report error from (likely non-internal) dependency at top level */
 			if (!level) {
 				log_error("Unable to deactivate open %s (%" PRIu32
-- 
1.7.0.1


