From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:15:44 +0000 (UTC)
Subject: master - cleanup: move comment
Message-ID: <20130313141544.DAD31A0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9fe52e811eba446813292e230502ac41040cdae
Commit:        b9fe52e811eba446813292e230502ac41040cdae
Parent:        293a06c39a45bcdcaabb2fa95e46f39466ef627f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 24 19:42:40 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:50 2013 +0100

cleanup: move comment

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b8ee2f3..906f53a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -492,7 +492,6 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
 		return NULL;
 	}
 
-	/* An activating merging origin won't have a node in the tree yet */
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
 		return NULL;
 
@@ -2196,6 +2195,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		 * - open_count is always retrieved (as of dm-ioctl 4.7.0)
 		 *   so just use the tree's existing nodes' info
 		 */
+		/* An activating merging origin won't have a node in the tree yet */
 		if (((dinfo = _cached_info(dm->mem, dtree, lv, NULL)) &&
 		     dinfo->open_count) ||
 		    ((dinfo = _cached_info(dm->mem, dtree,


