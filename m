From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  5 Sep 2012 16:39:28 +0000 (UTC)
Subject: master - cleanup: Use segtype->ops->name() instead of segtype->name where applicable
Message-ID: <20120905163928.28DFAA0DA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3eb3a76875ccf8c544c991bc52b6b3061bf8f58
Commit:        c3eb3a76875ccf8c544c991bc52b6b3061bf8f58
Parent:        1b01a2f65a27b95717fa7b6d912271e330782873
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 5 11:35:54 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 5 11:35:54 2012 -0500

cleanup:  Use segtype->ops->name() instead of segtype->name where applicable

When printing a message for the user and the lv_segment pointer is available,
use segtype->ops->name() instead of segtype->name.  This gives a better
user-readable name for the segment.  This is especially true for the
'striped' segment type, which prints "linear" if there is an area_count of
one.
---
 lib/metadata/merge.c      |    3 ++-
 lib/metadata/raid_manip.c |   11 ++++++-----
 tools/lvconvert.c         |    4 ++--
 tools/lvresize.c          |    2 +-
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index cc906d1..f7c05a2 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -429,7 +429,8 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 	if (!seg_can_split(seg)) {
 		log_error("Unable to split the %s segment at LE %" PRIu32
-			  " in LV %s", seg->segtype->name, le, lv->name);
+			  " in LV %s", seg->segtype->ops->name(seg),
+			  le, lv->name);
 		return 0;
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1188891..c786a7d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -252,7 +252,7 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	if (!seg_is_mirrored(seg)) {
 		log_error(INTERNAL_ERROR
 			  "Unable to remove RAID layer from segment type %s",
-			  seg->segtype->name);
+			  seg->segtype->ops->name(seg));
 		return 0;
 	}
 
@@ -658,7 +658,7 @@ static int _raid_add_images(struct logical_volume *lv,
 		dm_list_add(&meta_lvs, &lvl->list);
 	} else if (!seg_is_raid(seg)) {
 		log_error("Unable to add RAID images to %s of segment type %s",
-			  lv->name, seg->segtype->name);
+			  lv->name, seg->segtype->ops->name(seg));
 		return 0;
 	}
 
@@ -1126,7 +1126,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 
 	if (!seg_is_mirrored(first_seg(lv))) {
 		log_error("Unable to split logical volume of segment type, %s",
-			  first_seg(lv)->segtype->name);
+			  first_seg(lv)->segtype->ops->name(first_seg(lv)));
 		return 0;
 	}
 
@@ -1561,7 +1561,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 
 	log_error("Converting the segment type for %s/%s from %s to %s"
 		  " is not yet supported.", lv->vg->name, lv->name,
-		  seg->segtype->name, new_segtype->name);
+		  seg->segtype->ops->name(seg), new_segtype->name);
 	return 0;
 }
 
@@ -1617,7 +1617,8 @@ int lv_raid_replace(struct logical_volume *lv,
 		   (match_count > raid_seg->segtype->parity_devs)) {
 		log_error("Unable to replace more than %u PVs from (%s) %s/%s",
 			  raid_seg->segtype->parity_devs,
-			  raid_seg->segtype->name, lv->vg->name, lv->name);
+			  raid_seg->segtype->ops->name(raid_seg),
+			  lv->vg->name, lv->name);
 		return 0;
 	} else if (!strcmp(raid_seg->segtype->name, "raid10")) {
 		uint32_t i, rebuilds_per_group = 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ddda2f1..7b284f0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1577,14 +1577,14 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 	if (arg_count(cmd, mirrors_ARG) &&
 	    !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",
-			  seg->segtype->name);
+			  seg->segtype->ops->name(seg));
 		return 0;
 	}
 
 	if (!is_valid_raid_conversion(seg->segtype, lp->segtype)) {
 		log_error("Unable to convert %s/%s from %s to %s",
 			  lv->vg->name, lv->name,
-			  seg->segtype->name, lp->segtype->name);
+			  seg->segtype->ops->name(seg), lp->segtype->name);
 		return 0;
 	}
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 5052bfb..18e5917 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -630,7 +630,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			lp->stripes = seg_stripes;
 		else if (seg_is_raid(first_seg(lv)) &&
 			 (lp->stripes != seg_stripes)) {
-			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->name);
+			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->ops->name(first_seg(lv)));
 			return ECMD_FAILED;
 		}
 


