From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:59:31 +0000 (GMT)
Subject: master - Revert "raid: add _rimage and _rmeta as origin_only"
Message-ID: <20200908225931.40DA93953C08@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af33a008472c5d7066a52f5c2031ce5b0d508a26
Commit:        af33a008472c5d7066a52f5c2031ce5b0d508a26
Parent:        a8ea1817abccbd6acba83fb1ceb075830e747279
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 00:58:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 9 00:58:52 2020 +0200

Revert "raid: add _rimage and _rmeta as origin_only"

This reverts commit 3388e194892e9ab7a36b72e512796c2d218dae6e.
More thinking needed.
---
 WHATS_NEW                  | 1 -
 lib/activate/dev_manager.c | 5 ++---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa3960b31..1fffbb5d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.03.11 - 
 ==================================
-  Use _rmeta and _rimage as origin only devices for table loading.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e98cf578b..a626b000a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2642,11 +2642,10 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    /* origin only for cache without pending delete */
 			    (!dm->track_pending_delete || !lv_is_cache(lv)) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-					      (lv_is_vdo_pool(seg_lv(seg, s)) ||
-					       lv_is_raid_image(seg_lv(seg, s))) ? 1 : 0))
+					      lv_is_vdo_pool(seg_lv(seg, s)) ? 1 : 0))
 				return_0;
 			if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
-			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 1))
+			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
 				return_0;
 		}
 


