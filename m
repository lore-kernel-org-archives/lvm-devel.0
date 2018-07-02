From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:27:09 -0400
Subject: master - device_mapper: deactive new nodes when load fails
Message-ID: <201807020827.w628R96V026003@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d56e400d448c79a269591ac065e087bc2cc69609
Commit:        d56e400d448c79a269591ac065e087bc2cc69609
Parent:        f2b856c9940cf3b4cf4bb35bf1a145a8f5f76e13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 17:25:38 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:25:35 2018 +0200

device_mapper: deactive new nodes when load fails

When node loading fails, there is not much the caller can do,
since there is 'unknown' set of devices preloaded.

Only suspend during preload knows future precommitted 'metadata',
so it's non-trivial to drop 'preloaded' entries with any later call.

However dm tree tracks newly loaded entries - so in this case it
may simplify the recovery path by dropping preloaded entries so
they are not leaked in the DM table.
---
 device_mapper/libdm-deptree.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index bb552b6..4609796 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2877,8 +2877,14 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			 * insufficient to remove those - only the node
 			 * encountering the table load failure is removed.
 			 */
-			if (node_created && !_remove_node(child))
-				return_0;
+			if (node_created) {
+				if (!_remove_node(child))
+					return_0;
+				if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+					stack;
+				dm_tree_set_cookie(dnode, 0);
+				(void) _dm_tree_revert_activated(child);
+			}
 			return_0;
 		}
 


