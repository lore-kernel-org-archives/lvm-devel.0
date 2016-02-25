From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:23 +0000 (UTC)
Subject: master - lvconvert: use more display_lvname
Message-ID: <20160225223623.D40FA60AA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec8a75a321fa96fd0fff6bf68e00599288c21ec4
Commit:        ec8a75a321fa96fd0fff6bf68e00599288c21ec4
Parent:        86a651854f136b780d30e43a58c2390fa0d05e97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 15:01:12 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:25 2016 +0100

lvconvert: use more display_lvname

---
 tools/lvconvert.c |   48 +++++++++++++++++++++++++++---------------------
 1 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7fba48d..10ee775 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1446,7 +1446,7 @@ int mirror_remove_missing(struct cmd_context *cmd,
 		return_0;
 
 	if (force && _failed_mirrors_count(lv) == (int)lv_mirror_count(lv)) {
-		log_error("No usable images left in %s.", lv->name);
+		log_error("No usable images left in %s.", display_lvname(lv));
 		return lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0);
         }
 
@@ -1503,7 +1503,8 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	lv_check_transient(lv); /* TODO check this in lib for all commands? */
 
 	if (!(lv->status & PARTIAL_LV)) {
-		log_print_unless_silent("%s is consistent. Nothing to repair.", lv->name);
+		log_print_unless_silent("Volume %s is consistent. Nothing to repair.",
+					display_lvname(lv));
 		return 1;
 	}
 
@@ -1558,11 +1559,13 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	}
 
 	if (replace_mimages && lv_mirror_count(lv) != original_mimages)
-		log_warn("WARNING: Failed to replace %d of %d images in volume %s",
-			 original_mimages - lv_mirror_count(lv), original_mimages, lv->name);
+		log_warn("WARNING: Failed to replace %d of %d images in volume %s.",
+			 original_mimages - lv_mirror_count(lv), original_mimages,
+			 display_lvname(lv));
 	if (replace_logs && _get_log_count(lv) != original_logs)
-		log_warn("WARNING: Failed to replace %d of %d logs in volume %s",
-			 original_logs - _get_log_count(lv), original_logs, lv->name);
+		log_warn("WARNING: Failed to replace %d of %d logs in volume %s.",
+			 original_logs - _get_log_count(lv), original_logs,
+			 display_lvname(lv));
 
 	/* if (!arg_count(cmd, use_policies_ARG) && (lp->mirrors != old_mimage_count
 						  || log_count != old_log_count))
@@ -1577,18 +1580,18 @@ static int _lvconvert_validate_thin(struct logical_volume *lv,
 	if (!lv_is_thin_pool(lv) && !lv_is_thin_volume(lv))
 		return 1;
 
-	log_error("Converting thin%s segment type for \"%s/%s\" to %s is not supported.",
+	log_error("Converting thin%s segment type for %s to %s is not supported.",
 		  lv_is_thin_pool(lv) ? " pool" : "",
-		  lv->vg->name, lv->name, lp->segtype->name);
+		  display_lvname(lv), lp->segtype->name);
 
 	if (lv_is_thin_volume(lv))
 		return 0;
 
 	/* Give advice for thin pool conversion */
-	log_error("For pool data volume conversion use \"%s/%s\".",
-		  lv->vg->name, seg_lv(first_seg(lv), 0)->name);
-	log_error("For pool metadata volume conversion use \"%s/%s\".",
-		  lv->vg->name, first_seg(lv)->metadata_lv->name);
+	log_error("For pool data volume conversion use %s.",
+		  display_lvname(seg_lv(first_seg(lv), 0)));
+	log_error("For pool metadata volume conversion use %s.",
+		  display_lvname(first_seg(lv)->metadata_lv));
 	return 0;
 }
 
@@ -3217,18 +3220,19 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct dm_list *failed_pvs;
 
 	if (lv_is_locked(lv)) {
-		log_error("Cannot convert locked LV %s", lv->name);
+		log_error("Cannot convert locked LV %s.", display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_cow(lv) && !lp->merge && !lp->splitsnapshot) {
-		log_error("Can't convert snapshot logical volume \"%s\"",
-			  lv->name);
+		log_error("Cannot convert snapshot logical volume %s.",
+			  display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_pvmove(lv)) {
-		log_error("Unable to convert pvmove LV %s", lv->name);
+		log_error("Unable to convert pvmove LV %s.",
+			  display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
@@ -3287,8 +3291,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!lv_is_mirrored(lv) && !lv_is_raid(lv)) {
 			if (arg_count(cmd, usepolicies_ARG))
 				return ECMD_PROCESSED; /* nothing to be done here */
-			log_error("Can't repair LV \"%s\" of segtype %s.",
-				  lv->name, lvseg_name(first_seg(lv)));
+			log_error("Cannot repair logical volume %s of segtype %s.",
+				  display_lvname(lv), lvseg_name(first_seg(lv)));
 			return ECMD_FAILED;
 		}
 	}
@@ -3298,7 +3302,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, splitmirrors_ARG) && lv_is_cache_type(lv)
 	    && (origin = seg_lv(first_seg(lv), 0)) && lv_is_cache_origin(origin)) {
 		log_warn("WARNING: Selected operation does not work with cache-type LVs.");
-		log_warn("Proceeding using the cache origin LV %s instead", origin->name);
+		log_warn("WARNING: Proceeding using the cache origin volume %s instead.",
+			 display_lvname(origin));
 		lv = origin;
 	}
 
@@ -3319,7 +3324,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->merge) {
 		if ((lv_is_thin_volume(lv) && !_lvconvert_merge_thin_snapshot(cmd, lv, lp)) ||
 		    (!lv_is_thin_volume(lv) && !_lvconvert_merge_old_snapshot(cmd, lv, lp))) {
-			log_print_unless_silent("Unable to merge LV \"%s\" into its origin.", lv->name);
+			log_print_unless_silent("Unable to merge volume %s into its origin.",
+						display_lvname(lv));
 			return ECMD_FAILED;
 		}
 	} else if (lp->snapshot) {


