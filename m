From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:53:58 +0000 (UTC)
Subject: master - cleanup: relocate size assign
Message-ID: <20160120125358.DB1D560D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b64703401da1f4bef60579a0b3766c087fcfe96a
Commit:        b64703401da1f4bef60579a0b3766c087fcfe96a
Parent:        ca878a3426197b629c76e98cfc049948da470cd7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 18 23:22:48 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: relocate size assign

Directly set thin-pool size when thin data LV size changes.
---
 lib/metadata/lv_manip.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b283756..4507f8e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1730,7 +1730,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 				  uint32_t region_size)
 {
 	uint32_t s, extents, area_multiple;
-	struct lv_segment *seg;
+	struct lv_segment *seg, *thin_pool_seg;
 
 	area_multiple = _calc_area_multiple(segtype, area_count, 0);
 	extents = aa[0].len * area_multiple;
@@ -1753,6 +1753,15 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents * lv->vg->extent_size;
 
+	if (lv_is_thin_pool_data(lv)) {
+		/* Update thin pool segment from the layered LV */
+		thin_pool_seg = get_only_segment_using_this_lv(lv);
+		thin_pool_seg->lv->le_count =
+			thin_pool_seg->len =
+			thin_pool_seg->area_len = lv->le_count;
+		thin_pool_seg->lv->size = lv->size;
+	}
+
 	return 1;
 }
 
@@ -5239,11 +5248,6 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size), lv->le_count);
 
 	if (lock_lv) {
-		/* Update thin pool segment from the layered LV */
-		seg->area_len = lv->le_count;
-		seg->len = lv->le_count;
-		lock_lv->le_count = lv->le_count;
-		lock_lv->size = lv->size;
 	/* If thin metadata, must suspend thin pool */
 	} else if (lv_is_thin_pool_metadata(lv)) {
 		if (!(lock_lv = find_pool_lv(lv)))


