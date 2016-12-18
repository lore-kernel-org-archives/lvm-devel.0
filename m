From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:00 +0000 (UTC)
Subject: master - raid: fix activation of tracked image
Message-ID: <20161218185200.43F7E6055F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdfc96cb089031c6d95dccb0ff66616efdb16783
Commit:        bdfc96cb089031c6d95dccb0ff66616efdb16783
Parent:        a15f0d181ca2fb44c9c854dfba425d372a8756c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 14 21:47:38 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:10:38 2016 +0100

raid: fix activation of tracked image

Activation of raid has brough up also splitted image with tracing
(without taking lock for this).

So when raid is now activate - such image is not put into
table (with _rmeta).  When user needs such device, just active it.
---
 WHATS_NEW                        |    3 ++-
 lib/activate/dev_manager.c       |    3 +++
 lib/metadata/metadata-exported.h |    1 +
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4ac3377..eee6e98 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,9 @@
 Version 2.02.169 - 
 =====================================
+  Fix table load for splitted RAID LV and require explicit activation.
   Always active splitted RAID LV exclusively locally.
   Do not use LV RAID status bit for segment status.
-  Check segtype directly instead of checking RAID in segment status. 
+  Check segtype directly instead of checking RAID in segment status.
   Reusing exiting code for raid image removal.
   Fix pvmove leaving -pvmove0 error device in clustered VG.
   Avoid adding extra '_' at end of raid extracted images or metadata.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 581e900..8245454 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2681,12 +2681,15 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	/* Add any LVs used by this segment */
 	for (s = 0; s < seg->area_count; ++s) {
 		if ((seg_type(seg, s) == AREA_LV) &&
+		    /* do not bring up tracked image */
+		    !lv_is_raid_image_with_tracking(seg_lv(seg, s)) &&
 		    /* origin only for cache without pending delete */
 		    (!dm->track_pending_delete || !seg_is_cache(seg)) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
 					  laopts, NULL))
 			return_0;
 		if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
+		    !lv_is_raid_image_with_tracking(seg_lv(seg, s)) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
 					  laopts, NULL))
 			return_0;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4bf466b..aa40c6c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -226,6 +226,7 @@
 
 #define lv_is_raid(lv)		(((lv)->status & RAID) ? 1 : 0)
 #define lv_is_raid_image(lv)	(((lv)->status & RAID_IMAGE) ? 1 : 0)
+#define lv_is_raid_image_with_tracking(lv)	((lv_is_raid_image(lv) && !((lv)->status & LVM_WRITE)) ? 1 : 0)
 #define lv_is_raid_metadata(lv)	(((lv)->status & RAID_META) ? 1 : 0)
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 


