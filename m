From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:47 +0000 (UTC)
Subject: master - cleanup: remove thin low_water_mark from metadata
Message-ID: <20151029113947.DF04760E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=175119fdcd1a8eb23011e4c25d0df5899dfc42ea
Commit:        175119fdcd1a8eb23011e4c25d0df5899dfc42ea
Parent:        33a8a2febf483df088ec8e1928d25a6705a18991
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 12:07:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:14:20 2015 +0100

cleanup: remove thin low_water_mark from metadata

This option could never have been printed in lvm2 metadata, so it could
be safely removed as it could have been set only as 0.

These configurable setting is supported via metadata profile.
---
 lib/metadata/lv_manip.c          |    2 --
 lib/metadata/metadata-exported.h |    1 -
 lib/thin/thin.c                  |    7 -------
 tools/lvconvert.c                |    1 -
 4 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8e20dfa..2310bfa 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7388,8 +7388,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
 		first_seg(lv)->discards = lp->discards;
-		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
-		first_seg(lv)->low_water_mark = 0;
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
 								lp->thin_chunk_size_calc_policy)) {
 			stack;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 41838a8..2d118f4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -454,7 +454,6 @@ struct lv_segment {
 	struct lv_segment_area *meta_areas;	/* For RAID */
 	struct logical_volume *metadata_lv;	/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool, thin */
-	uint64_t low_water_mark;		/* For thin_pool */
 	unsigned zero_new_blocks;		/* For thin_pool */
 	thin_discards_t discards;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index ad400ef..be7a6b4 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -118,10 +118,6 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	else if (!set_pool_discards(&seg->discards, discards_str))
 		return SEG_LOG_ERROR("Discards option unsupported for");
 
-	if (dm_config_has_node(sn, "low_water_mark") &&
-	    !dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
-		return SEG_LOG_ERROR("Could not read low_water_mark");
-
 	if ((seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE))
 		return SEG_LOG_ERROR("Unsupported value %u for chunk_size",
@@ -169,9 +165,6 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 		return 0;
 	}
 
-	if (seg->low_water_mark)
-		outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
-
 	if (seg->zero_new_blocks)
 		outf(f, "zero_new_blocks = 1");
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0e06160..a7df26d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3064,7 +3064,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	/* FIXME: revert renamed LVs in fail path? */
 	/* FIXME: any common code with metadata/thin_manip.c  extend_pool() ? */
 
-	seg->low_water_mark = 0;
 	seg->transaction_id = 0;
 
 mda_write:


