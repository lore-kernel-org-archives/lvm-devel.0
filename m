From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:14 +0000 (UTC)
Subject: master - libdm: drop callback on revert path
Message-ID: <20161218185214.ED15A60E2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=954c59779d35436a6d2f28482ec1ed6dc128844c
Commit:        954c59779d35436a6d2f28482ec1ed6dc128844c
Parent:        29b0e42be3026a11c86fc05f82f6a14e71d26cc8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 22:40:59 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:29:08 2016 +0100

libdm: drop callback on revert path

The system is likely in some very inconsisten state.
Do not try to make it even more problematic with trying
to invoke tools like thin_check via callback.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ab32bdb..d57ddd7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Do not try call callback when reverting activation on error path.
   Fix file mapping for extents with physically adjacent extents.
   Validation vsnprintf result in runtime translate of dm_log (1.02.136).
   Separate filemap extent allocation from region table.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index cf6a06e..c5226a7 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2778,6 +2778,10 @@ static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 
 	dm_list_iterate_items_gen(child, &parent->activated, activated_list) {
 		log_debug_activation("Reverting %s.", child->name);
+		if (child->callback) {
+			log_debug_activation("Dropping callback for %s.", child->name);
+			child->callback = NULL;
+		}
 		if (!_deactivate_node(child->name, child->info.major, child->info.minor,
 				      &child->dtree->cookie, child->udev_flags, 0)) {
 			log_error("Unable to deactivate %s (%" PRIu32


