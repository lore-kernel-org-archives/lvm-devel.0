From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:10:14 -0400
Subject: master - device_mapper: split _node_send_message
Message-ID: <201806251310.w5PDAEfZ031462@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1c81c009a59c2476ffca8a8cf2cd06f0674e46d
Commit:        a1c81c009a59c2476ffca8a8cf2cd06f0674e46d
Parent:        19b92ae3f3185919a0a1cef849a9a003101d4429
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 20:50:36 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

device_mapper: split _node_send_message

For better code reuse split _node_send_messages into commont
messaging part and separate _thin_pool_node_send_messages.

Patch makes it possible to better reuse common code for messaging
other targets.
---
 device_mapper/libdm-deptree.c |   56 ++++++++++++++++++++++++-----------------
 1 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index d177374..4875858 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1510,34 +1510,14 @@ static struct load_segment *_get_last_load_segment(struct dm_tree_node *node)
 }
 
 /* For preload pass only validate pool's transaction_id */
-static int _node_send_messages(struct dm_tree_node *dnode,
-			       const char *uuid_prefix,
-			       size_t uuid_prefix_len,
-			       int send)
+static int _thin_pool_node_send_messages(struct dm_tree_node *dnode,
+					 struct load_segment *seg,
+					 int send)
 {
-	struct load_segment *seg;
 	struct thin_message *tmsg;
 	struct dm_status_thin_pool stp;
-	const char *uuid;
 	int have_messages;
 
-	if (!dnode->info.exists)
-		return 1;
-
-	if (!(seg = _get_last_load_segment(dnode)))
-		return_0;
-
-	if (seg->type != SEG_THIN_POOL)
-		return 1;
-
-	if (!(uuid = dm_tree_node_get_uuid(dnode)))
-		return_0;
-
-	if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len)) {
-		log_debug_activation("UUID \"%s\" does not match.", uuid);
-		return 1;
-	}
-
 	if (!_thin_pool_get_status(dnode, &stp))
 		return_0;
 
@@ -1582,6 +1562,36 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	return 1;
 }
 
+static int _node_send_messages(struct dm_tree_node *dnode,
+			       const char *uuid_prefix,
+			       size_t uuid_prefix_len,
+			       int send)
+{
+	struct load_segment *seg;
+	const char *uuid;
+
+	if (!dnode->info.exists || !dnode->info.live_table)
+		return 1;
+
+	if (!(uuid = dm_tree_node_get_uuid(dnode)))
+		return_0;
+
+	if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len)) {
+		log_debug_activation("UUID \"%s\" does not match.", uuid);
+		return 1;
+	}
+
+	if (!(seg = _get_last_load_segment(dnode)))
+		return_0;
+
+	switch (seg->type) {
+	case SEG_THIN_POOL: return _thin_pool_node_send_messages(dnode, seg, send);
+	}
+
+	return 1;
+}
+
+
 /*
  * FIXME Don't attempt to deactivate known internal dependencies.
  */


