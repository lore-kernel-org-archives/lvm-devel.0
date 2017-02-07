From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  7 Feb 2017 18:05:27 +0000 (UTC)
Subject: master - lvconvert: add support to change RAID region size (fixup)
Message-ID: <20170207180527.6BF2660ED6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79f31008fa10cc4893b6f98ad3e0de188aa5e7b0
Commit:        79f31008fa10cc4893b6f98ad3e0de188aa5e7b0
Parent:        69fe8729f3d60b0c9b9a0b2db6b36e38c00b9127
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 7 19:01:02 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 7 19:05:01 2017 +0100

lvconvert: add support to change RAID region size (fixup)

Commit cfb6ef654d3d1f1dd02569a1d5bd2fc252ae2494 introduced
support to change RAID region size.

Fix:
- don't change region_size until after prompting the user
- use log_print_unless_silent() instead of log_warn()
- avoid superfluous sigint() calls which are already
  covered in yes_no_prompt()
- typo

Related: rhbz1392947
---
 lib/metadata/raid_manip.c |   33 ++++++++++++++-------------------
 1 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f55d3d8..ae779fe 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2913,8 +2913,6 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
 			  display_lvname(lv), SEG_TYPE_NAME_MIRROR);
 		return 0;
 	}
-	if (sigint_caught())
-		return_0;
 
 	/* Archive metadata */
 	if (!archive(lv->vg))
@@ -3128,8 +3126,6 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 			  display_lvname(lv), new_segtype->name);
 		return 0;
 	}
-	if (sigint_caught())
-		return_0;
 
 	/* Archive metadata */
 	if (!archive(lv->vg))
@@ -3889,14 +3885,14 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, uin
 	if (!region_size)
 		return_0;
 
-	/* CLI validation prvides the check but be caucious... */
+	/* CLI validation provides the check but be caucious... */
 	if (seg_is_any_raid0(seg))
 		return_0;
 
 	if (region_size == seg->region_size) {
-		log_warn("Region size wouldn't change on %s LV %s.",
-			  lvseg_name(seg), display_lvname(lv));
-		return 0;
+		log_print_unless_silent("Region size wouldn't change on %s LV %s.",
+					lvseg_name(seg), display_lvname(lv));
+		return 1;
 	}
 
 	if (region_size * 8 > lv->size) {
@@ -3906,7 +3902,7 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, uin
 	}
 
 	if (region_size < seg->stripe_size) {
-		log_error("Region size for LV %s is smaller than stripe size.",
+		log_error("Requested region size for LV %s is smaller than stripe size.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -3918,8 +3914,16 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, uin
 	}
 
 	old_region_size = seg->region_size;
+	seg_region_size_str = display_size(lv->vg->cmd, region_size);
+
+	if (!yes && yes_no_prompt("Do you really want to change the region_size %s of LV %s to %s? [y/n]: ",
+				  display_size(lv->vg->cmd, old_region_size),
+				  display_lvname(lv), seg_region_size_str) == 'n') {
+		log_error("Logical volume %s NOT converted", display_lvname(lv));
+		return 0;
+	}
+
 	seg->region_size = region_size;
-	seg_region_size_str = display_size(lv->vg->cmd, seg->region_size);
 	_check_and_adjust_region_size(lv);
 
 	if (seg->region_size == old_region_size) {
@@ -3928,15 +3932,6 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, uin
 		return 1;
 	}
 
-	if (!yes && yes_no_prompt("Do you really want to change the region_size %s of LV %s to %s? [y/n]: ",
-				  display_size(lv->vg->cmd, old_region_size),
-				  display_lvname(lv), seg_region_size_str) == 'n') {
-		log_error("Logical volume %s NOT converted", display_lvname(lv));
-		return 0;
-	}
-	if (sigint_caught())
-		return_0;
-
 	/* Check for new region size causing bitmap to still fit metadata image LV */
 	if (seg->meta_areas && seg_metatype(seg, 0) == AREA_LV && seg_metalv(seg, 0)->le_count <
 	    _raid_rmeta_extents(lv->vg->cmd, lv->le_count, seg->region_size, lv->vg->extent_size)) {


