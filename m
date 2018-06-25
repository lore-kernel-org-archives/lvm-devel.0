From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:09:59 -0400
Subject: master - lv_manip: add new internal api function
Message-ID: <201806251309.w5PD9xmt031403@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c0d92d9575da63b38685c385917644d9ac9445d
Commit:        9c0d92d9575da63b38685c385917644d9ac9445d
Parent:        8949903fbb0be370ae7c5d71617d5084e8dddad9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 11:35:22 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

lv_manip: add new internal api function

---
 lib/metadata/lv_manip.c |   21 ++++++++++-----------
 lib/metadata/metadata.h |    2 ++
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4efe04a..11a6927 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1219,17 +1219,19 @@ int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 /*
  * Prepare for adding parallel areas to an existing segment.
  */
-static int _lv_segment_add_areas(struct logical_volume *lv,
-				 struct lv_segment *seg,
-				 uint32_t new_area_count)
+int add_lv_segment_areas(struct lv_segment *seg, uint32_t new_area_count)
 {
 	struct lv_segment_area *newareas;
 	uint32_t areas_sz = new_area_count * sizeof(*newareas);
 
-	if (!(newareas = dm_pool_zalloc(lv->vg->cmd->mem, areas_sz)))
+	if (!(newareas = dm_pool_zalloc(seg->lv->vg->vgmem, areas_sz))) {
+		log_error("Failed to allocate widened LV segment for %s.",
+			  display_lvname(seg->lv));
 		return_0;
+	}
 
-	memcpy(newareas, seg->areas, seg->area_count * sizeof(*seg->areas));
+	if (seg->area_count)
+		memcpy(newareas, seg->areas, seg->area_count * sizeof(*seg->areas));
 
 	seg->areas = newareas;
 	seg->area_count = new_area_count;
@@ -3766,7 +3768,7 @@ int lv_add_mirror_areas(struct alloc_handle *ah,
 		old_area_count = seg->area_count;
 		new_area_count = old_area_count + ah->area_count;
 
-		if (!_lv_segment_add_areas(lv, seg, new_area_count))
+		if (!add_lv_segment_areas(seg, new_area_count))
 			return_0;
 
 		for (s = 0; s < ah->area_count; s++) {
@@ -3818,11 +3820,8 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 	old_area_count = seg->area_count;
 	new_area_count = old_area_count + num_extra_areas;
 
-	if (!_lv_segment_add_areas(lv, seg, new_area_count)) {
-		log_error("Failed to allocate widened LV segment for %s.",
-			  display_lvname(lv));
-		return 0;
-	}
+	if (!add_lv_segment_areas(seg, new_area_count))
+		return_0;
 
 	for (m = 0; m < old_area_count; m++)
 		seg_lv(seg, m)->status |= status;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 129267c..1c4be48 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -445,6 +445,8 @@ int for_each_sub_lv(struct logical_volume *lv,
 int move_lv_segments(struct logical_volume *lv_to,
 		     struct logical_volume *lv_from,
 		     uint64_t set_status, uint64_t reset_status);
+/* Widen existing segment areas */
+int add_lv_segment_areas(struct lv_segment *seg, uint32_t new_area_count);
 
 /*
  * Calculate readahead from underlying PV devices


