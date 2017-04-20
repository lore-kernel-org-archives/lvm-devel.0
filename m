From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 14:42:49 -0400
Subject: master - mirror/raid: display adjusted region size with units
Message-ID: <201704201842.v3KIgndt005924@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83cdba75bde734027984af9642f161c5693a5458
Commit:        83cdba75bde734027984af9642f161c5693a5458
Parent:        b9d10857b26533dcd52c4d482af0a9291670858e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 20 20:42:21 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 20 20:42:21 2017 +0200

mirror/raid: display adjusted region size with units

Display adjusted region size in units (e.g. "4.00 MiB") rather than sectors.
---
 lib/metadata/lv_manip.c          |    3 ++-
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/mirror.c            |   26 ++++++++++++++------------
 lib/mirror/mirrored.c            |    3 ++-
 tools/lvconvert.c                |    4 ++--
 5 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 50f5167..8f38839 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7514,7 +7514,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			status |= LV_NOTSYNCED;
 		}
 
-		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
+		lp->region_size = adjusted_mirror_region_size(vg->cmd,
+							      vg->extent_size,
 							      lp->extents,
 							      lp->region_size, 0,
 							      vg_is_clustered(vg));
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3e6da63..8e03e20 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1158,7 +1158,8 @@ uint32_t lv_mirror_count(const struct logical_volume *lv);
 
 /* Remove CMIRROR_REGION_COUNT_LIMIT when http://bugzilla.redhat.com/682771 is fixed */
 #define CMIRROR_REGION_COUNT_LIMIT (256*1024 * 8)
-uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
+uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
+				     uint32_t extent_size, uint32_t extents,
 				     uint32_t region_size, int internal, int clustered);
 
 int remove_mirrors_from_segments(struct logical_volume *lv,
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c668ea0..9dee0ab 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -157,7 +157,8 @@ struct lv_segment *find_mirror_seg(struct lv_segment *seg)
  *
  * For internal use only log only in verbose mode
  */
-uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
+uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
+				     uint32_t extent_size, uint32_t extents,
 				     uint32_t region_size, int internal, int clustered)
 {
 	uint64_t region_max;
@@ -168,11 +169,11 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;
 		if (!internal)
-			log_print_unless_silent("Using reduced mirror region size of %"
-						PRIu32 " sectors.", region_size);
+			log_print_unless_silent("Using reduced mirror region size of %s",
+						display_size(cmd, region_size));
                 else
-			log_verbose("Using reduced mirror region size of %"
-				    PRIu32 " sectors.", region_size);
+			log_verbose("Using reduced mirror region size of %s",
+				    display_size(cmd, region_size));
 	}
 
 #ifdef CMIRROR_REGION_COUNT_LIMIT
@@ -199,13 +200,13 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 
 		if (region_size < region_min_pow2) {
 			if (internal)
-				log_print_unless_silent("Increasing mirror region size from %"
-							PRIu32 " to %" PRIu64 " sectors.",
-							region_size, region_min_pow2);
+				log_print_unless_silent("Increasing mirror region size from %s to %s",
+							display_size(cmd, region_size),
+							display_size(cmd, region_min_pow2));
 			else
-				log_verbose("Increasing mirror region size from %"
-					    PRIu32 " to %" PRIu64 " sectors.",
-					    region_size, region_min_pow2);
+				log_verbose("Increasing mirror region size from %s to %s",
+					    display_size(cmd, region_size),
+					    display_size(cmd, region_min_pow2));
 			region_size = region_min_pow2;
 		}
 	}
@@ -1665,7 +1666,8 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
-	adjusted_region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+	adjusted_region_size = adjusted_mirror_region_size(cmd,
+							   lv->vg->extent_size,
 							   lv->le_count,
 							   region_size, 1,
 							   vg_is_clustered(lv->vg));
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index c4ba70a..f4c1567 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -370,7 +370,8 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 		region_size = seg->region_size;
 
 	} else
-		region_size = adjusted_mirror_region_size(seg->lv->vg->extent_size,
+		region_size = adjusted_mirror_region_size(cmd,
+							  seg->lv->vg->extent_size,
 							  seg->area_len,
 							  mirr_state->default_region_size, 1,
 							  vg_is_clustered(seg->lv->vg));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f4ee660..5b9510b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -622,7 +622,7 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
-		region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+		region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
 							  lv->le_count,
 							  region_size, 0,
 							  vg_is_clustered(lv->vg));
@@ -827,7 +827,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		return 1;
 	}
 
-	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+	region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
 						  lv->le_count,
 						  lp->region_size ? : seg->region_size, 0,
 						  vg_is_clustered(lv->vg));


