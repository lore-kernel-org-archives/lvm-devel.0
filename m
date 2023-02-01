From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  1 Feb 2023 10:53:11 +0000 (GMT)
Subject: main - device_mapper: reduce unnecessary looping passed
Message-ID: <20230201105311.49F573857BB3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85aa236946d3c290c7fab2c6229684ed268b1670
Commit:        85aa236946d3c290c7fab2c6229684ed268b1670
Parent:        f89c369a0119a701a5a550694258a145202ab4a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 30 14:31:04 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 1 11:47:47 2023 +0100

device_mapper: reduce unnecessary looping passed

While looping through the list of nodes, check if there is higher
priority present and another iteration is still needed.
---
 device_mapper/libdm-deptree.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index c6cc8de56..6a7fd08ee 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2040,7 +2040,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	struct dm_tree_node *child = dnode;
 	const char *name;
 	const char *uuid;
-	int priority;
+	int priority, next_priority;
 
 	/* Activate children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
@@ -2058,12 +2058,16 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	}
 
 	handle = NULL;
-
 	for (priority = 0; priority < 3; priority++) {
 		awaiting_peer_rename = 0;
+		next_priority = 0;
 		while ((child = dm_tree_next_child(&handle, dnode, 0))) {
-			if (priority != child->activation_priority)
+			if (priority != child->activation_priority) {
+				if ((next_priority < child->activation_priority) &&
+				    (child->activation_priority > priority))
+					next_priority = child->activation_priority;
 				continue;
+			}
 
 			if (!(uuid = dm_tree_node_get_uuid(child))) {
 				stack;
@@ -2121,6 +2125,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 		}
 		if (awaiting_peer_rename)
 			priority--; /* redo priority level */
+		else if (!next_priority)
+			break;  /* no more work, higher priority was not found in the chain */
 	}
 
 	return r;

