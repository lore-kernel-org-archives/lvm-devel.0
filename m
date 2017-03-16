From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:02:49 -0400
Subject: master - raid: use 64bit arithmetic
Message-ID: <201703160002.v2G02nBE017678@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a727a3ccd178d4762f0b7a8a48a24f7667e8c51
Commit:        4a727a3ccd178d4762f0b7a8a48a24f7667e8c51
Parent:        e3a51537c57f8ebe2ecb49f3d221710cd59163ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 00:51:52 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:02:10 2017 +0100

raid: use 64bit arithmetic

Coverity - keep  multiplication for size cals in 64bit
(otherwise it's just 32b x 32b)
---
 lib/metadata/raid_manip.c |    4 ++--
 lib/report/report.c       |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9f0de4c..720337b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1690,7 +1690,7 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 
 	/* Externally visible LV size w/o reshape space */
 	lv->le_count = seg->len = new_le_count;
-	lv->size = (lv->le_count - new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
+	lv->size = (uint64_t) (lv->le_count - new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
 	/* seg->area_len does not change */
 
 	if (old_image_count < new_image_count) {
@@ -1861,7 +1861,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 
 		reduced_le_count -= seg->reshape_len * _data_rimages_count(seg, new_image_count);
 		current_le_count = lv->le_count - seg->reshape_len * _data_rimages_count(seg, old_image_count);
-		extend_le_count = current_le_count * current_le_count / reduced_le_count;
+		extend_le_count = (uint32_t)((uint64_t) current_le_count * current_le_count / reduced_le_count);
 		log_warn("WARNING: Removing stripes from active%s logical "
 			 "volume %s will shrink it from %s to %s!",
 			 info.open_count ? " and open" : "", display_lvname(lv),
diff --git a/lib/report/report.c b/lib/report/report.c
index fcb9e33..1421b31 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2582,7 +2582,7 @@ static int _segdata_offset(struct dm_report *rh, struct dm_pool *mem,
 
 		if (lv_raid_data_offset(lv, &data_offset)) {
 			if (new_data_offset && !lv_raid_image_in_sync(seg->lv))
-				data_offset = data_offset ? 0 : seg->reshape_len * lv->vg->extent_size;
+				data_offset = data_offset ? 0 : (uint64_t) seg->reshape_len * lv->vg->extent_size;
 
 			return dm_report_field_uint64(rh, field, &data_offset);
 		}


