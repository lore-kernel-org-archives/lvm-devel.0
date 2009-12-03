From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  3 Dec 2009 18:26:56 -0500
Subject: [PATCH] Update a few more uint64_t's related to the 64-bit status change.
Message-ID: <1259882816-25310-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At this point they probably do not matter but going forward they
may - depends on future patches for replicator, etc.  I think
these probably got missed because they were 'flags' so I changed
the name to 'status' to be consistent.  So the on-disk
things 'flags' and the in structure 'status' (bits).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/import_vsn1.c |    4 ++--
 lib/format_text/text_import.h |    2 +-
 lib/metadata/lv_alloc.h       |    2 +-
 lib/metadata/lv_manip.c       |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 5feb60e..fd045cc 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -372,7 +372,7 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 
 int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		      const struct config_node *cn, struct dm_hash_table *pv_hash,
-		      uint32_t flags)
+		      uint64_t status)
 {
 	unsigned int s;
 	struct config_value *cv;
@@ -410,7 +410,7 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		} else if ((lv1 = find_lv(seg->lv->vg, cv->v.str))) {
 			if (!set_lv_segment_area_lv(seg, s, lv1,
 						    (uint32_t) cv->next->v.i,
-						    flags))
+						    status))
 				return_0;
 		} else {
 			log_error("Couldn't find volume '%s' "
diff --git a/lib/format_text/text_import.h b/lib/format_text/text_import.h
index 937d9c5..99d222f 100644
--- a/lib/format_text/text_import.h
+++ b/lib/format_text/text_import.h
@@ -21,6 +21,6 @@ struct config_node;
 
 int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		      const struct config_node *cn, struct dm_hash_table *pv_hash,
-		      uint32_t flags);
+		      uint64_t status);
 
 #endif
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index 104fcf6..f9220f7 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -35,7 +35,7 @@ int set_lv_segment_area_pv(struct lv_segment *seg, uint32_t area_num,
 			   struct physical_volume *pv, uint32_t pe);
 int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			   struct logical_volume *lv, uint32_t le,
-			   uint32_t flags);
+			   uint64_t status);
 int move_lv_segment_area(struct lv_segment *seg_to, uint32_t area_to,
 			 struct lv_segment *seg_from, uint32_t area_from);
 void release_lv_segment_area(struct lv_segment *seg, uint32_t s,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8a8a44e..7e2c781 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -333,7 +333,7 @@ int set_lv_segment_area_pv(struct lv_segment *seg, uint32_t area_num,
  */
 int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			   struct logical_volume *lv, uint32_t le,
-			   uint32_t flags)
+			   uint64_t status)
 {
 	log_very_verbose("Stack %s:%" PRIu32 "[%" PRIu32 "] on LV %s:%" PRIu32,
 			 seg->lv->name, seg->le, area_num, lv->name, le);
@@ -341,7 +341,7 @@ int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 	seg->areas[area_num].type = AREA_LV;
 	seg_lv(seg, area_num) = lv;
 	seg_le(seg, area_num) = le;
-	lv->status |= flags;
+	lv->status |= status;
 
 	if (!add_seg_to_segs_using_this_lv(lv, seg))
 		return_0;
-- 
1.6.0.6


