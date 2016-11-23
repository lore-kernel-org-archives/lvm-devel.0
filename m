From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:56:07 +0000 (UTC)
Subject: master - cleanup: indent changes
Message-ID: <20161123165607.67F1D60F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f39255dcae168621de9eea264dddfe831286a0d
Commit:        4f39255dcae168621de9eea264dddfe831286a0d
Parent:        ae95937af46989dbce992eace2914ace3b001a4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 10:48:33 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: indent changes

---
 lib/metadata/lv_manip.c |    6 ++----
 lib/metadata/mirror.c   |   26 +++++++++++---------------
 2 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2a02ad2..07ba8ef 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3668,12 +3668,10 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 		      uint32_t num_extra_areas,
 		      uint64_t status, uint32_t region_size)
 {
-	struct lv_segment *seg;
-	uint32_t old_area_count, new_area_count;
 	uint32_t m;
+	uint32_t old_area_count, new_area_count;
 	struct segment_type *mirror_segtype;
-
-	seg = first_seg(lv);
+	struct lv_segment *seg = first_seg(lv);
 
 	if (dm_list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
 		log_error(INTERNAL_ERROR "Mirror layer must be inserted before adding mirrors.");
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index cb1f8c8..df99174 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -866,7 +866,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *temp_layer_lv = NULL;
-	struct lv_segment *pvmove_seg, *mirrored_seg = first_seg(lv);
+	struct lv_segment *seg, *pvmove_seg, *mirrored_seg = first_seg(lv);
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
 	struct lv_list *lvl;
@@ -1004,7 +1004,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 */
 	if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
 	    lv_is_partial(detached_log_lv)) {
-		struct lv_segment *seg = first_seg(detached_log_lv);
+		seg = first_seg(detached_log_lv);
 
 		log_very_verbose("%s being removed due to failures.",
 				 display_lvname(detached_log_lv));
@@ -1959,16 +1959,15 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	if (activation() && segtype->ops->target_present &&
 	    !segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel", segtype->name);
+			  "detected in your kernel.", segtype->name);
 		return 0;
 	}
 
 	/* allocate destination extents */
-	ah = allocate_extents(lv->vg, NULL, segtype,
-			      0, 0, log_count - old_log_count, region_size,
-			      lv->le_count, allocatable_pvs,
-			      alloc, 0, parallel_areas);
-	if (!ah) {
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype,
+				    0, 0, log_count - old_log_count, region_size,
+				    lv->le_count, allocatable_pvs,
+				    alloc, 0, parallel_areas))) {
 		log_error("Unable to allocate extents for mirror log.");
 		return 0;
 	}
@@ -2029,10 +2028,9 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
-	ah = allocate_extents(lv->vg, NULL, segtype,
-			      stripes, mirrors, log_count, region_size, lv->le_count,
-			      allocatable_pvs, alloc, 0, parallel_areas);
-	if (!ah) {
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype,
+				    stripes, mirrors, log_count, region_size, lv->le_count,
+				    allocatable_pvs, alloc, 0, parallel_areas))) {
 		log_error("Unable to allocate extents for mirror(s).");
 		return 0;
 	}
@@ -2165,7 +2163,6 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 int lv_split_mirror_images(struct logical_volume *lv, const char *split_name,
 			   uint32_t split_count, struct dm_list *removable_pvs)
 {
-	int r;
 	int historical;
 
 	if (lv_name_is_used_in_vg(lv->vg, split_name, &historical)) {
@@ -2192,8 +2189,7 @@ int lv_split_mirror_images(struct logical_volume *lv, const char *split_name,
 	 * is being implemented.  For now, we force the user to
 	 * come up with a name for their LV.
 	 */
-	r = _split_mirror_images(lv, split_name, split_count, removable_pvs);
-	if (!r)
+	if (!_split_mirror_images(lv, split_name, split_count, removable_pvs))
 		return_0;
 
 	return 1;


