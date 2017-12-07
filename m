From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:04:00 -0500
Subject: master - debug: update debug msg
Message-ID: <201712072004.vB7K40Et005678@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c88c4626d9870d4fa146f7596a37853cf965a39
Commit:        4c88c4626d9870d4fa146f7596a37853cf965a39
Parent:        717714b24ffbf648a1b22e9306484944a514c565
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 7 17:54:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 21:00:39 2017 +0100

debug: update debug msg

Use _node_name.
---
 libdm/libdm-deptree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6ba20a4..98dda44 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2786,9 +2786,9 @@ static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 	struct dm_tree_node *child;
 
 	dm_list_iterate_items_gen(child, &parent->activated, activated_list) {
-		log_debug_activation("Reverting %s.", child->name);
+		log_debug_activation("Reverting %s.", _node_name(child));
 		if (child->callback) {
-			log_debug_activation("Dropping callback for %s.", child->name);
+			log_debug_activation("Dropping callback for %s.", _node_name(child));
 			child->callback = NULL;
 		}
 		if (!_deactivate_node(child->name, child->info.major, child->info.minor,


