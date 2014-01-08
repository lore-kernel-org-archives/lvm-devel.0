From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jan 2014 11:05:40 +0000 (UTC)
Subject: master - libdm: pass dnode to callback
Message-ID: <20140108110540.5FB286119F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af7297c73eb824f30898ba7dbb4a4b23406625ca
Commit:        af7297c73eb824f30898ba7dbb4a4b23406625ca
Parent:        95b1af72803336f8a2e559bae4eadefff9a48a7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 8 10:30:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 8 11:57:43 2014 +0100

libdm: pass dnode to callback

Pass dnode  pointer instead of rather unknown child pointer.
The pointer is currently unused and passing child pointer
is quite undefined, while dnode has at least some usability.
---
 libdm/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 752a44b..7bc1f33 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2619,7 +2619,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		dm_tree_set_cookie(dnode, 0);
 
 		if (!dnode->info.exists && dnode->callback &&
-		    !dnode->callback(child, DM_NODE_CALLBACK_PRELOADED,
+		    !dnode->callback(dnode, DM_NODE_CALLBACK_PRELOADED,
 				     dnode->callback_data))
 			return_0;
 	}


