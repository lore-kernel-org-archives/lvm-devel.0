From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Nov 2014 08:40:58 +0000 (UTC)
Subject: master - cache: fix clean_tree
Message-ID: <20141112084058.CE4E660C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57c618b0edbea321626766d9de2a0640efdc2bc2
Commit:        57c618b0edbea321626766d9de2a0640efdc2bc2
Parent:        112302d41a2cbf0c28c5cb65774121302ba374be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 12 09:34:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 12 09:40:27 2014 +0100

cache: fix clean_tree

Fix 8121074fda126cc6c0df05fba066cc9365e00255 - the patch
incorrectly removed also other top-level nodes.

It needs to deactivate purely subnodes of _corig.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0c8fcc7..9859939 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Fix clean_tree after activation/resume for cache target (2.02.112).
 
 Version 2.02.112 - 11th November 2014
 =====================================
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index efaaa65..18ecb3a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3001,11 +3001,12 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		if ((name = strstr(lvname, "_corig")) && !name[6]) {
-			/* FIXME: for now just for _corig deactivate LVM subtree, should be generic */
-			if (!dm_tree_deactivate_children(root, "LVM-", 4))
-				return_0;
-		} else if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
+		if ((name = strstr(lvname, "_corig")) && !name[6] &&
+		    /* FIXME: for now just for _corig deactivate LVM subtree, should be generic */
+		    !dm_tree_deactivate_children(child, "LVM-", 4))
+			return_0;
+
+		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
 			return_0;
 	}
 


