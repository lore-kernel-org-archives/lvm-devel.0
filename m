From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Jul 2015 14:19:09 +0000 (UTC)
Subject: master - libdm: support for posting messages in suspend
Message-ID: <20150703141909.4BB156115B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bef18f2eb1071a29b682f6f456a13a73493868e
Commit:        5bef18f2eb1071a29b682f6f456a13a73493868e
Parent:        622064f00fe41a02ab857ce02920a9e8818e610b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 1 13:30:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 3 16:13:14 2015 +0200

libdm: support for posting messages in suspend

Add support for sending message in suspend tree for thin-pools.
When this operation is requested whole subtree suspend is then skipped.

This is experimantal support for new lvm2 code for sending message
in suspend phase where 'thin-pool origin-only suspend' will send
messages instead of really suspending thin-pool tree.

When suspening thin volume origin-only - only thin volume is suspended,
then messages are posted and thin-pool suspend is skipped.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5e1f25f..f4537d9 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.101 -
 =================================
+  Add experimental support to passing messages in suspend tree.
   Add dm_report_value_cache_{set,get} to support caching during report/select.
   Add dm_report_reserved_handler to handle report reserved value actions.
   Support dynamic value in select: DM_REPORT_FIELD_RESERVED_VALUE_DYNAMIC_VALUE.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e344d1a..b9a8582 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -243,6 +243,8 @@ struct load_properties {
 
 	/* Send messages for this node in preload */
 	unsigned send_messages;
+	/* Skip suspending node's children, used when sending messages to thin-pool */
+	int skip_suspend;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -1768,6 +1770,19 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 		    !info.exists || info.suspended)
 			continue;
 
+		/* If child has some real messages send them */
+		if ((child->props.send_messages > 1) && r) {
+			if (!(r = _node_send_messages(child, uuid_prefix, uuid_prefix_len, 1)))
+				stack;
+			else {
+				log_debug_activation("Sent messages to thin-pool %s."
+						     "skipping suspend of its children.",
+						     _node_name(child));
+				child->props.skip_suspend++;
+			}
+			continue;
+		}
+
 		if (!_suspend_node(name, info.major, info.minor,
 				   child->dtree->skip_lockfs,
 				   child->dtree->no_flush, &newinfo)) {
@@ -1786,6 +1801,9 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 	handle = NULL;
 
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+		if (child->props.skip_suspend)
+			continue;
+
 		if (!(uuid = dm_tree_node_get_uuid(child))) {
 			stack;
 			continue;


