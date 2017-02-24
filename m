From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:32 +0000 (UTC)
Subject: master - lvconvert: allow regionsize on upconvert from linear
Message-ID: <20170224063232.5A3C460AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2574d3257ad41cad8dcbad3332774172e86f05da
Commit:        2574d3257ad41cad8dcbad3332774172e86f05da
Parent:        64a2fad5d6c65e81269251408dff10854f0ace7e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 05:00:55 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: allow regionsize on upconvert from linear

Allow to provide regionsize with "lvconvert -m1 -R N " on
upconverts from linear and on N -> M raid1 leg conversions.

Resolves: rhbz1394427
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   13 ++++++++++---
 tools/lvconvert.c                |    2 +-
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 11fb247..376fee9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1213,6 +1213,7 @@ int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count,
+			       uint32_t new_region_size,
 			       struct dm_list *allocate_pvs);
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e21e6cc..ab0bfab 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2866,11 +2866,11 @@ static int _raid_extract_images(struct logical_volume *lv,
 					  display_lvname(lv),
 					  display_lvname(seg_lv(seg, s)));
 
-				log_error("Try removing the PV list and rerun"
+				log_error("Try removing the PV list and rerun."
 					  " the command.");
 				return 0;
 			}
-			log_debug("LVs with error segments to be removed: %s %s.",
+			log_debug("LVs with error segments to be removed: %s %s",
 				  display_lvname(seg_metalv(seg, s)),
 				  display_lvname(seg_lv(seg, s)));
 		} else {
@@ -3013,8 +3013,15 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_c
 }
 
 int lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
-			       struct dm_list *allocate_pvs)
+			       const uint32_t new_region_size, struct dm_list *allocate_pvs)
 {
+	struct lv_segment *seg = first_seg(lv);
+
+	if (new_region_size) {
+		seg->region_size = new_region_size;
+		_check_and_adjust_region_size(lv);
+	}
+
 	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL, 1, 0);
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index abec04a..0db10cb 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1359,7 +1359,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
-			if (!lv_raid_change_image_count(lv, image_count, /* lp->region_size, */ lp->pvh))
+			if (!lv_raid_change_image_count(lv, image_count, lp->region_size, lp->pvh))
 				return_0;
 
 			log_print_unless_silent("Logical volume %s successfully converted.",


