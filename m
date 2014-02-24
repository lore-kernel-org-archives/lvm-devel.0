From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:02 +0000 (UTC)
Subject: master - libdm: enhance thin transaction_id validation
Message-ID: <20140224201702.00E7960D5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=203affffc70622e1b0db4734bc631cd7caf22442
Commit:        203affffc70622e1b0db4734bc631cd7caf22442
Parent:        c7b7cb60e4de1aff7f9ea9e3a8116f851ef3089c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 09:43:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:06:31 2014 +0100

libdm: enhance thin transaction_id validation

Reuse _node_send_messages for just checking
for valid transaction_id with preload.

This allows earlier detection of incosistent thin pool.

Code does the same thing, except for sending messages.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   21 +++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c29cb39..32c2265 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Reuse _node_send_messages() for validation of transaction_id in preload.
   Transaction_id could be lower by one only when messages are prepared.
   Do not call callback when preload fails.
   Wrap is_selinux_enabled() to be called just once.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 56ddd1a..fad14d6 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1478,9 +1478,11 @@ out:
 	return r;
 }
 
+/* For preload pass only validate pool's transaction_id */
 static int _node_send_messages(struct dm_tree_node *dnode,
 			       const char *uuid_prefix,
-			       size_t uuid_prefix_len)
+			       size_t uuid_prefix_len,
+			       int send)
 {
 	struct load_segment *seg;
 	struct thin_message *tmsg;
@@ -1522,6 +1524,9 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 		return 0;
 	}
 
+	if (!send)
+		return 1; /* transaction_id is matching */
+
 	dm_list_iterate_items(tmsg, &seg->thin_messages)
 		if (!(_thin_pool_node_message(dnode, tmsg)))
 			return_0;
@@ -1865,7 +1870,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	 * has to report failure.
 	 */
 	if (r && dnode->props.send_messages &&
-	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
+	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len, 1)))
 		stack;
 
 	return r;
@@ -2713,6 +2718,18 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!child->info.live_table) {
 			/* Collect newly introduced devices for revert */
 			dm_list_add_h(&dnode->activated, &child->activated_list);
+
+			/* When creating new node also check transaction_id. */
+			if (child->props.send_messages &&
+			    !_node_send_messages(child, uuid_prefix, uuid_prefix_len, 0)) {
+				stack;
+				if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+					stack;
+				dm_tree_set_cookie(dnode, 0);
+				(void) _dm_tree_revert_activated(dnode);
+				r = 0;
+				continue;
+			}
 		}
 
 		/* Update cached info */


