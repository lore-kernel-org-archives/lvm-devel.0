From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:02:53 +0000 (UTC)
Subject: master - cleanup: update commented-out code part
Message-ID: <20130715140253.1E10160642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55d90b64207739ddee710f40cab8b71fc45d9849
Commit:        55d90b64207739ddee710f40cab8b71fc45d9849
Parent:        9ba77833504fb08456db1fab8a4061b689f7922c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 13:05:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:40:46 2013 +0200

cleanup: update commented-out code part

Just make it in-sync with latest proposal.
---
 lib/activate/dev_manager.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 74afaac..724742d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1685,11 +1685,11 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 #if 0
 		/* ? Use origin_only to avoid 'deep' thin pool suspend ? */
-		/* FIXME Implement dm_tree_node_skip_children optimisation */
-		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_lauer(lv))))
+		/* FIXME Implement dm_tree_node_skip_childrens optimisation */
+		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
 			return_0;
 		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
-			dm_tree_node_skip_children(thin_node, 1);
+			dm_tree_node_skip_childrens(thin_node, 1);
 #endif
 	}
 


