From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:07 +0000 (UTC)
Subject: master - thin: add sub volumes as whole volumes
Message-ID: <20130715140307.C1BF2602E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0443c42e3bff5b3e0bca6cfdc489d59cd45ada8a
Commit:        0443c42e3bff5b3e0bca6cfdc489d59cd45ada8a
Parent:        e1e986f16d27e468a70dcbc2d2c2a249111d7725
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 13:39:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:58:07 2013 +0200

thin: add sub volumes as whole volumes

Do not use origin_only when add log_lv and metadata as a subvolume.
The stacked volume needs to access whole volume in this case.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    7 ++-----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 008fdf7..7aa3df9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add whole log_lv and metadata_lv sub volumes when creating partial tree.
   Properly use snapshot layer for origin which is also thin volume.
   Avoid generating metadata backup when calling update_pool_lv().
   Send thin messages also for active thin pool and inactive thin volume.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 986e696..260cb3e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1728,22 +1728,19 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		    !_add_lv_to_dtree(dm, dtree, seg->external_lv, 1)) /* stack */
 			return_0;
 		if (seg->log_lv &&
-		    !_add_lv_to_dtree(dm, dtree, seg->log_lv, origin_only))
+		    !_add_lv_to_dtree(dm, dtree, seg->log_lv, 0))
 			return_0;
 		if (seg->metadata_lv &&
-		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, origin_only))
+		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
 		if (seg->pool_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 1)) /* stack */
 			return_0;
 
 		for (s = 0; s < seg->area_count; s++) {
-			/* FIXME: raid requires to use  '0' instead of preserving
-			 * origin_only value for stacking */
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
 				return_0;
-			/* FIXME: raid tests fails with origin_only */
 			if (seg_is_raid(seg) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
 				return_0;


