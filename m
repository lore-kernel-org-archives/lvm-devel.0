From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 11:19:27 +0000 (UTC)
Subject: master - activation: fix pvmove partial tree creation
Message-ID: <20130223111927.684B3AC69D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71f49345004d385acc71a8e534c4313069cc59b6
Commit:        71f49345004d385acc71a8e534c4313069cc59b6
Parent:        b73de7315116da41a993d20567f9a1520610f545
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 23 12:09:12 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 12:09:12 2013 +0100

activation: fix pvmove partial tree creation

Do not try to add LV again into the partial tree, if it's been
already added. Otherwise we may end in endless loop.
---
 lib/activate/dev_manager.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e326929..bffa8a5 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1605,7 +1605,8 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
 	if (dm->track_pvmove_deps && lv->status & PVMOVE)
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
+			if (!_cached_info(dm->mem, dtree, sl->seg->lv, 0) &&
+			    !_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
 				return_0;
 
 	/* Adding LV head of replicator adds all other related devs */


