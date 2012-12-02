From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:36 +0000 (UTC)
Subject: master - libdm: deactivate failed node in preload
Message-ID: <20121202170236.392ACA0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97f8454eccefe29464336ba1823448f4d1fa009b
Commit:        97f8454eccefe29464336ba1823448f4d1fa009b
Parent:        ade2f47829f66d061d69844b9911e266751435b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 16:32:42 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:59:40 2012 +0100

libdm: deactivate failed node in preload

If the resume of preloaded node fails, do not leave such
node in the table - since it may not be easy to detach such
node later when the node is i.e. internal.

i.e. failing activation of the thin pool with mismatching
chunk size may leave -tpool device in the table, which
could have been then removed only by dmsetup command.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3ea0502..75bd1b3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Automatically deactivate failed preloaded dm tree node.
   Add DM_DISABLE_UDEV environment variable to manage dev nodes by libdm only.
   Fix dm_task_set_cookie to properly process udev flags if udev_sync disabled.
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 096eba2..e4a574d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2496,6 +2496,11 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
+			if (!_deactivate_node(child->name, child->info.major, child->info.minor,
+					      &child->dtree->cookie, child->udev_flags, 0))
+				log_error("Unable to deactivate %s (%" PRIu32
+					  ":%" PRIu32 ")", child->name, child->info.major,
+					  child->info.minor);
 			r = 0;
 			continue;
 		}


