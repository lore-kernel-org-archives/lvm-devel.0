From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:39:50 +0000 (UTC)
Subject: master - segments: introduce lvseg_name
Message-ID: <20141024143950.EB7F060E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9411c19b31b391e7be262d95fb2fa5a5162012b2
Commit:        9411c19b31b391e7be262d95fb2fa5a5162012b2
Parent:        ab940456931ea5a5a6f29f63d1b27057df3fdf75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 18:40:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:30 2014 +0200

segments: introduce lvseg_name

Instead of segtype->ops->name()  introduce lvseg_name().

This also allows us to leave name() function 'empty' for default
return of segtype->name.

TODO: add functions for rest of ops->
---
 WHATS_NEW                 |    1 +
 lib/display/display.c     |    2 +-
 lib/metadata/lv.c         |   12 +++++++++++-
 lib/metadata/lv.h         |    1 +
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/merge.c      |    3 +--
 lib/metadata/pool_manip.c |    6 +++---
 lib/metadata/raid_manip.c |   14 +++++++-------
 lib/report/report.c       |    2 +-
 tools/lvchange.c          |    2 +-
 tools/lvconvert.c         |    9 ++++-----
 11 files changed, 32 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4d2a6d2..f5b7931 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add internal lvseg_name() function.
   Skip trying to file lock virtual internal vg name.
   Fix selection on {vg,lv}_permissions fields to properly match selection criteria.
   Fix lv_permissions reporting to display read-only{-override} instead of blank.
diff --git a/lib/display/display.c b/lib/display/display.c
index d12c393..f86b67f 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -667,7 +667,7 @@ int lvdisplay_segments(const struct logical_volume *lv)
 			  lv_is_virtual(lv) ? "Virtual" : "Logical",
 			  seg->le, seg->le + seg->len - 1);
 
-		log_print("  Type\t\t%s", seg->segtype->ops->name(seg));
+		log_print("  Type\t\t%s", lvseg_name(seg));
 
 		if (seg->segtype->ops->target_monitored)
 			log_print("  Monitoring\t\t%s",
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 23f0991..92b38f4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -120,7 +120,7 @@ char *lvseg_tags_dup(const struct lv_segment *seg)
 
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return dm_pool_strdup(mem, seg->segtype->ops->name(seg));
+	return dm_pool_strdup(mem, lvseg_name(seg));
 }
 
 char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
@@ -183,6 +183,16 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 	return size;
 }
 
+const char *lvseg_name(const struct lv_segment *seg)
+{
+	/* Support even segtypes without 'ops' */
+	if (seg->segtype->ops &&
+	    seg->segtype->ops->name)
+		return seg->segtype->ops->name(seg);
+
+	return seg->segtype->name;
+}
+
 uint64_t lvseg_start(const struct lv_segment *seg)
 {
 	return (uint64_t) seg->le * seg->lv->vg->extent_size;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bcd7028..2261913 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -77,6 +77,7 @@ struct logical_volume *lv_parent(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
+const char *lvseg_name(const struct lv_segment *seg);
 uint64_t lvseg_start(const struct lv_segment *seg);
 uint64_t lvseg_size(const struct lv_segment *seg);
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f14cec0..f60b964 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4617,7 +4617,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			else if (seg_is_raid(first_seg(lv)) &&
 				 (lp->stripes != seg_stripes)) {
 				log_error("Unable to extend \"%s\" segment type with different number of stripes.",
-					  first_seg(lv)->segtype->ops->name(first_seg(lv)));
+					  lvseg_name(first_seg(lv)));
 				return 0;
 			}
 	
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index ad918f1..c8c9543 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -481,8 +481,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 	if (!seg_can_split(seg)) {
 		log_error("Unable to split the %s segment at LE %" PRIu32
-			  " in LV %s", seg->segtype->ops->name(seg),
-			  le, lv->name);
+			  " in LV %s", lvseg_name(seg), le, lv->name);
 		return 0;
 	}
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 439b8ed..4c0ab72 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -33,7 +33,7 @@ int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 	if (!seg_is_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to attach pool metadata LV to %s segtype.",
-			  pool_seg->segtype->ops->name(pool_seg));
+			  lvseg_name(pool_seg));
 		return 0;
 	}
 	pool_seg->metadata_lv = metadata_lv;
@@ -70,7 +70,7 @@ int attach_pool_data_lv(struct lv_segment *pool_seg,
 	if (!seg_is_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to attach pool data LV to %s segtype.",
-			  pool_seg->segtype->ops->name(pool_seg));
+			  lvseg_name(pool_seg));
 		return 0;
 	}
 
@@ -129,7 +129,7 @@ int detach_pool_lv(struct lv_segment *seg)
 	if (!seg->pool_lv) {
 		log_error(INTERNAL_ERROR
 			  "No pool associated with %s LV, %s.",
-			  seg->segtype->ops->name(seg), seg->lv->name);
+			  lvseg_name(seg), seg->lv->name);
 		return 0;
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 44272e8..8219984 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -117,7 +117,7 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	if (!seg_is_mirrored(seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to remove RAID layer from segment type %s",
-			  seg->segtype->ops->name(seg));
+			  lvseg_name(seg));
 		return 0;
 	}
 
@@ -579,7 +579,7 @@ static int _raid_add_images(struct logical_volume *lv,
 		dm_list_add(&meta_lvs, &lvl->list);
 	} else if (!seg_is_raid(seg)) {
 		log_error("Unable to add RAID images to %s of segment type %s",
-			  lv->name, seg->segtype->ops->name(seg));
+			  lv->name, lvseg_name(seg));
 		return 0;
 	}
 
@@ -1075,7 +1075,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (!seg_is_mirrored(first_seg(lv)) ||
 	    !strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID10)) {
 		log_error("Unable to split logical volume of segment type, %s",
-			  first_seg(lv)->segtype->ops->name(first_seg(lv)));
+			  lvseg_name(first_seg(lv)));
 		return 0;
 	}
 
@@ -1445,7 +1445,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 
 	log_error("Converting the segment type for %s/%s from %s to %s"
 		  " is not yet supported.", lv->vg->name, lv->name,
-		  seg->segtype->ops->name(seg), new_segtype->name);
+		  lvseg_name(seg), new_segtype->name);
 	return 0;
 }
 
@@ -1601,7 +1601,7 @@ int lv_raid_replace(struct logical_volume *lv,
 		   (match_count > raid_seg->segtype->parity_devs)) {
 		log_error("Unable to replace more than %u PVs from (%s) %s/%s",
 			  raid_seg->segtype->parity_devs,
-			  raid_seg->segtype->ops->name(raid_seg),
+			  lvseg_name(raid_seg),
 			  lv->vg->name, lv->name);
 		return 0;
 	} else if (!strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
@@ -1790,7 +1790,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 		return_0;
 
 	log_debug("Attempting to remove missing devices from %s LV, %s",
-		  seg->segtype->ops->name(seg), lv->name);
+		  lvseg_name(seg), lv->name);
 
 	/*
 	 * FIXME: Make sure # of compromised components will not affect RAID
@@ -1870,7 +1870,7 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 		   (failed_components > raid_seg->segtype->parity_devs)) {
 		log_verbose("More than %u components from %s %s have failed.",
 			    raid_seg->segtype->parity_devs,
-			    raid_seg->segtype->ops->name(raid_seg),
+			    lvseg_name(raid_seg),
 			    display_lvname(lv));
 		return 0;	/* Insufficient redundancy to activate */
 	}
diff --git a/lib/report/report.c b/lib/report/report.c
index e85c349..445f603 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -366,7 +366,7 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
 	char *name;
 
 	if (!(name = lvseg_segtype_dup(mem, seg))) {
-		log_error("Failed to get segtype.");
+		log_error("Failed to get segtype name.");
 		return 0;
 	}
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 114065c..6cb6f15 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -355,7 +355,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 			 vg_is_clustered(lv->vg) ? "clustered " : "",
 			 (seg->log_lv) ? "disk-logged " :
 			 seg_is_raid(seg) ? "" : "core-logged ",
-			 seg->segtype->ops->name(seg), lv->name);
+			 lvseg_name(seg), lv->name);
 
 	/*
 	 * If this mirror has a core log (i.e. !seg->log_lv),
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ad4a6c0..e976880 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1850,7 +1850,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (arg_count(cmd, mirrors_ARG) &&
 	    !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",
-			  seg->segtype->ops->name(seg));
+			  lvseg_name(seg));
 		return 0;
 	}
 
@@ -1860,7 +1860,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype)) {
 		log_error("Unable to convert %s/%s from %s to %s",
 			  lv->vg->name, lv->name,
-			  seg->segtype->ops->name(seg), lp->segtype->name);
+			  lvseg_name(seg), lp->segtype->name);
 		return 0;
 	}
 
@@ -2672,7 +2672,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	    lv_is_thin_pool_data(lv) ||
 	    lv_is_thin_pool_metadata(lv)) {
 		log_error("Can't use %s %s as external origin.",
-			  first_seg(lv)->segtype->name,
+			  lvseg_name(first_seg(lv)),
 			  display_lvname(lv));
 		return 0;
 	}
@@ -3294,8 +3294,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			if (arg_count(cmd, use_policies_ARG))
 				return ECMD_PROCESSED; /* nothing to be done here */
 			log_error("Can't repair LV \"%s\" of segtype %s.",
-				  lv->name,
-				  first_seg(lv)->segtype->ops->name(first_seg(lv)));
+				  lv->name, lvseg_name(first_seg(lv)));
 			return ECMD_FAILED;
 		}
 	}


