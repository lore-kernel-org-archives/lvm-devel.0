From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:58:17 -0500
Subject: master - cleanup: messsage cleanup
Message-ID: <201712041458.vB4EwHCD007221@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5abf6b7c21c86531eedeebe56de2633d43ef1879
Commit:        5abf6b7c21c86531eedeebe56de2633d43ef1879
Parent:        76954884c741e31eb2ddb4f5f5ffe9d2b8c60572
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 14:37:01 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: messsage cleanup

---
 libdm/libdm-deptree.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index fb33605..48323de 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1287,7 +1287,7 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	struct dm_task *dmt;
 	int r = 0;
 
-	log_verbose("Resuming %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
+	log_verbose("Resuming %s (" FMTu32 ":" FMTu32 ").", name, major, minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RESUME))) {
 		log_debug_activation("Suspend dm_task creation failed for %s.", name);
@@ -1607,8 +1607,8 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 
 			/* When retry is not allowed, error */
 			if (!child->dtree->retry_remove) {
-				log_error("Unable to deactivate open %s (%" PRIu32
-					  ":%" PRIu32 ")", name, info.major, info.minor);
+				log_error("Unable to deactivate open %s (" FMTu32 ":"
+					  FMTu32 ").", name, info.major, info.minor);
 				r = 0;
 				continue;
 			}
@@ -1628,9 +1628,8 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 					       uuid_prefix, uuid_prefix_len))) {
 			/* Only report error from (likely non-internal) dependency at top level */
 			if (!level) {
-				log_error("Unable to deactivate open %s (%" PRIu32
-					  ":%" PRIu32 ")", name, info.major,
-				  	info.minor);
+				log_error("Unable to deactivate open %s (" FMTu32 ":"
+					  FMTu32 ").", name, info.major, info.minor);
 				r = 0;
 			}
 			continue;
@@ -1644,9 +1643,8 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags,
 				      (level == 0) ? child->dtree->retry_remove : 0)) {
-			log_error("Unable to deactivate %s (%" PRIu32
-				  ":%" PRIu32 ")", name, info.major,
-				  info.minor);
+			log_error("Unable to deactivate %s (" FMTu32 ":"
+				  FMTu32 ").", name, info.major, info.minor);
 			r = 0;
 			continue;
 		}
@@ -1738,9 +1736,8 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 		if (!_suspend_node(name, info.major, info.minor,
 				   child->dtree->skip_lockfs,
 				   child->dtree->no_flush, &newinfo)) {
-			log_error("Unable to suspend %s (%" PRIu32
-				  ":%" PRIu32 ")", name, info.major,
-				  info.minor);
+			log_error("Unable to suspend %s (" FMTu32 ":"
+				  FMTu32 ")", name, info.major, info.minor);
 			r = 0;
 			continue;
 		}


