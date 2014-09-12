From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:45:12 +0000 (UTC)
Subject: master - cleanup: better error messages
Message-ID: <20140912124512.6FE4F60C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e57143abd49682a90a96a95514b781289bf43f4
Commit:        3e57143abd49682a90a96a95514b781289bf43f4
Parent:        08914ed7c1df18dc2a16c6f896ae388ac5e7c299
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 23:32:37 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:30 2014 +0200

cleanup: better error messages

---
 lib/metadata/raid_manip.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 58bc09b..92ea177 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -874,15 +874,17 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 				 * must come first.
 				 */
 				log_error("%s has components with error targets"
-					  " that must be removed first: %s",
-					  lv->name, seg_lv(seg, s)->name);
+					  " that must be removed first: %s.",
+					  display_lvname(lv),
+					  display_lvname(seg_lv(seg, s)));
 
 				log_error("Try removing the PV list and rerun"
 					  " the command.");
 				return 0;
 			}
 			log_debug("LVs with error segments to be removed: %s %s",
-				  seg_metalv(seg, s)->name, seg_lv(seg, s)->name);
+				  display_lvname(seg_metalv(seg, s)),
+				  display_lvname(seg_lv(seg, s)));
 		} else {
 			/* Conditions for second pass */
 			if (!target_pvs || !lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
@@ -1264,8 +1266,8 @@ int lv_raid_merge(struct logical_volume *image_lv)
 		return_0;
 
 	if (!(p = strstr(lv_name, "_rimage_"))) {
-		log_error("Unable to merge non-mirror image %s/%s",
-			  vg->name, image_lv->name);
+		log_error("Unable to merge non-mirror image %s.",
+			  display_lvname(image_lv));
 		return 0;
 	}
 	*p = '\0'; /* lv_name is now that of top-level RAID */
@@ -1277,8 +1279,8 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	}
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name))) {
-		log_error("Unable to find containing RAID array for %s/%s",
-			  vg->name, image_lv->name);
+		log_error("Unable to find containing RAID array for %s.",
+			  display_lvname(image_lv));
 		return 0;
 	}
 
@@ -1292,13 +1294,14 @@ int lv_raid_merge(struct logical_volume *image_lv)
 		return_0;
 
 	if (!deactivate_lv(vg->cmd, meta_lv)) {
-		log_error("Failed to deactivate %s", meta_lv->name);
+		log_error("Failed to deactivate %s before merging.",
+			  display_lvname(meta_lv));
 		return 0;
 	}
 
 	if (!deactivate_lv(vg->cmd, image_lv)) {
-		log_error("Failed to deactivate %s/%s before merging",
-			  vg->name, image_lv->name);
+		log_error("Failed to deactivate %s before merging.",
+			  display_lvname(image_lv));
 		return 0;
 	}
 	lv_set_hidden(image_lv);
@@ -1796,15 +1799,13 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 		log_debug("Replacing %s and %s segments with error target",
 			  seg_lv(seg, s)->name, seg_metalv(seg, s)->name);
 		if (!replace_lv_with_error_segment(seg_lv(seg, s))) {
-			log_error("Failed to replace %s/%s's extents"
-				  " with error target", lv->vg->name,
-				  seg_lv(seg, s)->name);
+			log_error("Failed to replace %s's extents with error target.",
+				  display_lvname(seg_lv(seg, s)));
 			return 0;
 		}
 		if (!replace_lv_with_error_segment(seg_metalv(seg, s))) {
-			log_error("Failed to replace %s/%s's extents"
-				  " with error target", lv->vg->name,
-				  seg_metalv(seg, s)->name);
+			log_error("Failed to replace %s's extents with error target.",
+				  display_lvname(seg_metalv(seg, s)));
 			return 0;
 		}
 	}


