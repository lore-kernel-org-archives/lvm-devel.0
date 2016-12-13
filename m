From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:47 +0000 (UTC)
Subject: master - raid: avoid manipulation of segment status
Message-ID: <20161213210947.B0AD960AA5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0fe3ec0c58ccd5dfcc4f5fd40ddabab0c9defe5
Commit:        d0fe3ec0c58ccd5dfcc4f5fd40ddabab0c9defe5
Parent:        d1e398c474032716679f704008026b5d17e9469a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 14:52:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

raid: avoid manipulation of segment status

RAID is LV property

TODO: only 2 flags are seg->status: PVMOVE & MERGING
At least the second one should be soon elimanted as again
we merge LV not a segment.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    6 ++----
 lib/raid/raid.c           |    1 -
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0561074..60e8fa5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Do not use LV RAID status bit for segment status.
   Check segtype directly instead of checking RAID in segment status. 
   Reusing exiting code for raid image removal.
   Fix pvmove leaving -pvmove0 error device in clustered VG.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f2c0b26..c70ce3e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1701,7 +1701,7 @@ static int _alloc_and_add_new_striped_segment(struct logical_volume *lv,
 
 	/* Allocate a segment with seg->area_count areas */
 	if (!(new_seg = alloc_lv_segment(striped_segtype, lv, le, area_len * seg->area_count,
-					 seg->status & ~RAID,
+					 0,
 					 seg->stripe_size, NULL, seg->area_count,
 					 area_len, seg->chunk_size, 0, 0, NULL)))
 		return_0;
@@ -2150,7 +2150,6 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	lv->status &= ~MIRROR;
 	lv->status &= ~MIRRORED;
 	lv->status |= RAID;
-	seg->status |= RAID;
 
 	if (!lv_update_and_reload(lv))
 		return_0;
@@ -2220,7 +2219,6 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	seg->segtype = new_segtype;
 	seg->region_size = new_region_size;
 	lv->status &= ~RAID;
-	seg->status &= ~RAID;
 	lv->status |= (MIRROR | MIRRORED);
 
 	if (!attach_mirror_log(first_seg(lv), log_lv))
@@ -2473,7 +2471,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	seg = first_seg(dm_list_item(dm_list_first(&data_lvs), struct lv_list)->lv);
 	if (!(raid0_seg = alloc_lv_segment(segtype, lv,
 					   0 /* le */, lv->le_count /* len */,
-					   seg->status | SEG_RAID,
+					   0,
 					   stripe_size, NULL /* log_lv */,
 					   area_count, area_len,
 					   0 /* chunk_size */,
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 21fad92..1e562ff 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -167,7 +167,6 @@ static int _raid_text_import(struct lv_segment *seg,
 
 	if (seg_is_any_raid0(seg))
 		seg->area_len /= seg->area_count;
-	seg->status |= RAID;
 
 	return 1;
 }


