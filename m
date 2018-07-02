From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:27:11 -0400
Subject: master - device_mapper: relocate code for sending messages
Message-ID: <201807020827.w628RBM2026012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1a6b10d09aae6179e4f08c7d8c03d5e3068ad94
Commit:        c1a6b10d09aae6179e4f08c7d8c03d5e3068ad94
Parent:        d56e400d448c79a269591ac065e087bc2cc69609
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 23:03:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:25:35 2018 +0200

device_mapper: relocate code for sending messages

To be able to send messages for recently resumed devices,
move code into inner loop.
---
 device_mapper/libdm-deptree.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 4609796..2dc33ae 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1953,22 +1953,22 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 				r = 0;
 				continue;
 			}
+
+			/*
+			 * FIXME: Implement delayed error reporting
+			 * activation should be stopped only in the case,
+			 * the submission of transation_id message fails,
+			 * resume should continue further, just whole command
+			 * has to report failure.
+			 */
+			if (r && (child->props.send_messages > 1) &&
+			    !(r = _node_send_messages(child, uuid_prefix, uuid_prefix_len, 1)))
+				stack;
 		}
 		if (awaiting_peer_rename)
 			priority--; /* redo priority level */
 	}
 
-	/*
-	 * FIXME: Implement delayed error reporting
-	 * activation should be stopped only in the case,
-	 * the submission of transation_id message fails,
-	 * resume should continue further, just whole command
-	 * has to report failure.
-	 */
-	if (r && (dnode->props.send_messages > 1) &&
-	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len, 1)))
-		stack;
-
 	return r;
 }
 


