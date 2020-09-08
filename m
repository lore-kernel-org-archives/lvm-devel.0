From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:41 +0000 (GMT)
Subject: master - raid: add _rimage and _rmeta as origin_only
Message-ID: <20200908220341.953F4385702B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3388e194892e9ab7a36b72e512796c2d218dae6e
Commit:        3388e194892e9ab7a36b72e512796c2d218dae6e
Parent:        3e6bb772287a6d7f753b08780c7e913c98f5e307
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 21:06:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

raid: add _rimage and _rmeta as origin_only

Since we do not support rimage & rmeta for snapshots - we can
avoid quering for -cow devices and add them as origin_only -
since their snapshots (-cow) could have never existed.
This redumes several ioctl operation during table preloading.
---
 WHATS_NEW                  | 1 +
 lib/activate/dev_manager.c | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1fffbb5d7..aa3960b31 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Use _rmeta and _rimage as origin only devices for table loading.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a626b000a..e98cf578b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2642,10 +2642,11 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    /* origin only for cache without pending delete */
 			    (!dm->track_pending_delete || !lv_is_cache(lv)) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-					      lv_is_vdo_pool(seg_lv(seg, s)) ? 1 : 0))
+					      (lv_is_vdo_pool(seg_lv(seg, s)) ||
+					       lv_is_raid_image(seg_lv(seg, s))) ? 1 : 0))
 				return_0;
 			if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
-			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
+			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 1))
 				return_0;
 		}
 


