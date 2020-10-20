From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:14 +0000 (GMT)
Subject: master - libdm: relocate code for sending messages
Message-ID: <20201020203414.CE5953951832@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=756066a2e85062be5e406d9139fc1033746d7ff9
Commit:        756066a2e85062be5e406d9139fc1033746d7ff9
Parent:        3e06061d82dbcc2f464f0fdcd6610f25177bfa1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 16:48:04 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:19 2020 +0200

libdm: relocate code for sending messages

To be able to send messages for recently resumed devices,
move code into inner loop.
Matching commit c1a6b10d09aae6179e4f08c7d8c03d5e3068ad94.
---
 libdm/libdm-deptree.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e784cbc9c..f16db8568 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1966,22 +1966,22 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
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
 


