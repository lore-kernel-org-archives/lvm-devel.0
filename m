From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:24 +0000 (GMT)
Subject: master - thin: validate thin-pool state before sending messages
Message-ID: <20200929084524.137343844008@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18c74666ee668c5d4569c868f38c3d8ae950dda1
Commit:        18c74666ee668c5d4569c868f38c3d8ae950dda1
Parent:        4de6f58085c533c79ce2e0db6cdeb6ed06fe05f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 28 23:12:48 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

thin: validate thin-pool state before sending messages

Alhtough lvm2 does validation on its side, ensure DM code
is not sending messages to failed thin pool.
---
 device_mapper/libdm-deptree.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index a98b1fcdd..d9e1683ca 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1666,6 +1666,15 @@ static int _thin_pool_node_send_messages(struct dm_tree_node *dnode,
 	if (!have_messages || !send)
 		return 1; /* transaction_id is matching */
 
+	if (stp.fail || stp.read_only || stp.needs_check) {
+		log_error("Cannot send messages to thin pool %s%s%s%s.",
+			  _node_name(dnode),
+			  stp.fail ? " in failed state" : "",
+			  stp.read_only ? " with read only metadata" : "",
+			  stp.needs_check ? " which needs check first" : "");
+		return 0;
+	}
+
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		if (!(_thin_pool_node_message(dnode, tmsg)))
 			return_0;


