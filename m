From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 25 Nov 2015 10:44:14 +0000 (UTC)
Subject: master - thin: fix previous update of partial tree building
Message-ID: <20151125104414.7E48E602C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0285066e10d0c4a37bc4938eeed2139299600b3e
Commit:        0285066e10d0c4a37bc4938eeed2139299600b3e
Parent:        8d86c5db03acd0b74cd919f1deb6cbfd1ff86e80
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 24 23:24:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 24 23:24:11 2015 +0100

thin: fix previous update of partial tree building

We do want to preserve 'active' thin-pool,
so add this 'fake' layer only when activating.

TODO:  think how to use thin-pool without fake LV layer.
---
 lib/activate/dev_manager.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index da24cdd..eb47ed1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2311,7 +2311,8 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (seg->pool_lv &&
 		    (lv_is_cache_pool(seg->pool_lv) || !dm->skip_external_lv) &&
-		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, origin_only))
+		    /* When activating and not origin_only detect linear 'overlay' over pool */
+		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, dm->activation ? origin_only : 1))
 			return_0;
 
 		for (s = 0; s < seg->area_count; s++) {


