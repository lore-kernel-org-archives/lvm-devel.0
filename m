From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:26 -0500
Subject: master - libdm: watch for failing _info_by_dev
Message-ID: <201712041457.vB4EvQFp007077@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63368a5064dd20a1fb5a2f4110704059c79b3ced
Commit:        63368a5064dd20a1fb5a2f4110704059c79b3ced
Parent:        b74e7f6a781bf7dc4914d8294fcbc6881a539f2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 15:05:44 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

libdm: watch for failing _info_by_dev

Separate handling of error code from _info_by_dev.
This error can only happeng when we are running out of memory.
In such case there is urgent need to stop any futher proceeding
of command and run to error ASAP.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9cec953..56b8153 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.146 -
 ====================================
+  Do not ignore failure of _info_by_dev().
   Propagate delayed resume for pvmove subvolumes.
   Suppress integrity encryption keys in 'table' output unless --showkeys supplied.
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8c623bf..ff7e9b4 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1011,8 +1011,10 @@ static int _node_has_closed_parents(struct dm_tree_node *node,
 			return_0;	/* FIXME Is this normal? */
 
 		/* Refresh open_count */
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
-		    !info.exists)
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL))
+			return_0;
+
+		if (!info.exists)
 			continue;
 
 		if (info.open_count) {
@@ -1137,7 +1139,7 @@ static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 
 		if (!_info_by_dev(MAJOR(deps->device[i]), MINOR(deps->device[i]), 1,
 				  &deps_info, dnode->dtree->mem, &name, &uuid))
-			continue;
+			goto_out;
 
 		/* Proceed if device is an 'orphan' - unreferenced and without a live table. */
 		if (!deps_info.exists || deps_info.live_table || deps_info.open_count)
@@ -1653,8 +1655,10 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 			continue;
 
 		/* Refresh open_count */
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
-		    !info.exists)
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL))
+			return_0;
+
+		if (!info.exists)
 			continue;
 
 		if (info.open_count) {
@@ -1773,8 +1777,10 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 		if (!_children_suspended(child, 1, uuid_prefix, uuid_prefix_len))
 			continue;
 
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 0, &info, NULL, NULL, NULL) ||
-		    !info.exists || info.suspended)
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 0, &info, NULL, NULL, NULL))
+			return_0;
+
+		if (!info.exists || info.suspended)
 			continue;
 
 		/* If child has some real messages send them */


