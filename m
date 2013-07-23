From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Jul 2013 12:34:59 +0000 (UTC)
Subject: master - deptree: don't remove live node on resume failure
Message-ID: <20130723123459.4D90261200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83fb622598458e6814eb0d5dde23eda18c6ac620
Commit:        83fb622598458e6814eb0d5dde23eda18c6ac620
Parent:        84801d7c34430052e298bc54826e18eb68212ec6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 23 13:33:35 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 23 13:33:35 2013 +0100

deptree: don't remove live node on resume failure

When resuming a node needed by a higher layer of the tree,
if the resume fails, only remove it if the node did not
originally have a live table.

Ref. 97f8454eccefe29464336ba1823448f4d1fa009b
---
 libdm/libdm-deptree.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 34cd960..57f00f6 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2534,12 +2534,15 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
-			if (!_deactivate_node(child->name, child->info.major, child->info.minor,
+			/* If the device was not previously active, we might as well remove this node. */
+			if (!child->info.live_table &&
+			    !_deactivate_node(child->name, child->info.major,child->info.minor,
 					      &child->dtree->cookie, child->udev_flags, 0))
 				log_error("Unable to deactivate %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
 			r = 0;
+			/* Each child is handled independently */
 			continue;
 		}
 


