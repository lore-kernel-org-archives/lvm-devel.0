From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:42 +0000 (UTC)
Subject: master - pool: delay conversion prompt
Message-ID: <20140702084842.136E261054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bdf4719e8327a74262e47adfe78ad81a26ff4c0
Commit:        7bdf4719e8327a74262e47adfe78ad81a26ff4c0
Parent:        3af761ba167236a2d66f8687ade5db6311498d06
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 1 11:06:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:39 2014 +0200

pool: delay conversion prompt

First validate as much params as possible before prompting user
about conversion to data and metadata LV.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   91 +++++++++++++++++++++++++++++------------------------
 2 files changed, 51 insertions(+), 41 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8934d6f..dfbb4e3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Postpone thin pool lvconvert prompts (2.02.107).
   Require --yes option to skip prompt to lvconvert thin pool chunksize.
   Support lvremove -ff to remove thin volumes from broken thin pools.
   Require --yes to skip raid repair prompt.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index be2c916..ca58a1f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2680,7 +2680,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 	}
 
-	data_lv = pool_lv;
 	if (lv_is_thin_type(pool_lv) && !lp->pool_metadata_lv_name) {
 		log_error("Can't use thin logical volume %s/%s for thin pool data.",
 			  pool_lv->vg->name, pool_lv->name);
@@ -2707,17 +2706,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				  pool_lv->vg->name, pool_lv->name);
 			return 0;
 		}
-	} else {
-		log_warn("WARNING: Converting \"%s/%s\" logical volume to pool's data volume.",
-			 pool_lv->vg->name, pool_lv->name);
-		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-
-		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y/n]: ",
-				  pool_lv->vg->name, pool_lv->name) == 'n') {
-			log_error("Conversion aborted.");
-			return 0;
-		}
 	}
 
 	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
@@ -2782,26 +2770,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		/* Swap normal LV with pool's metadata LV ? */
 		if (lv_is_thin_pool(pool_lv)) {
 			if (!deactivate_lv(cmd, metadata_lv)) {
-				log_error("Aborting. Failed to deactivate thin metadata lv.");
-				return 0;
-			}
-			if (!lp->yes &&
-			    yes_no_prompt("Do you want to swap metadata of %s/%s pool with "
-					  "volume %s/%s? [y/n]: ",
-					  pool_lv->vg->name, pool_lv->name,
-					  pool_lv->vg->name, metadata_lv->name) == 'n') {
-				log_error("Conversion aborted.");
+				log_error("Aborting. Failed to deactivate LV %s/%s.",
+					  metadata_lv->vg->name, metadata_lv->name);
 				return 0;
 			}
+
 			seg = first_seg(pool_lv);
-			/* Swap names between old and new metadata LV */
-			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
-				return_0;
-			old_name = metadata_lv->name;
-			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
-				return_0;
-			if (!lv_rename_update(cmd, pool_metadata_lv, old_name, 0))
-				return_0;
 
 			if (!arg_count(cmd, chunksize_ARG))
 				lp->chunk_size = seg->chunk_size;
@@ -2825,6 +2799,25 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					 display_size(cmd, lp->chunk_size),
 					 pool_lv->vg->name, pool_lv->name);
 			}
+
+			if (!lp->yes &&
+			    yes_no_prompt("Do you want to swap metadata of %s/%s pool with "
+					  "volume %s/%s? [y/n]: ",
+					  pool_lv->vg->name, pool_lv->name,
+					  metadata_lv->vg->name, metadata_lv->name) == 'n') {
+				log_error("Conversion aborted.");
+				return 0;
+			}
+
+			/* Swap names between old and new metadata LV */
+			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
+				return_0;
+			old_name = metadata_lv->name;
+			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
+				return_0;
+			if (!lv_rename_update(cmd, pool_metadata_lv, old_name, 0))
+				return_0;
+
 			if (!arg_count(cmd, discards_ARG))
 				lp->discards = seg->discards;
 			if (!arg_count(cmd, zero_ARG))
@@ -2834,18 +2827,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 
 		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to deactivate thin metadata lv.");
-			return 0;
-		}
-
-		log_warn("WARNING: Converting \"%s/%s\" logical volume to pool's metadata volume.",
-			 metadata_lv->vg->name, metadata_lv->name);
-		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-
-		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y/n]: ",
-				  metadata_lv->vg->name, metadata_lv->name) == 'n') {
-			log_error("Conversion aborted.");
+			log_error("Aborting. Failed to deactivate \"%s/%s\".",
+				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}
 
@@ -2867,9 +2850,21 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				  display_size(cmd, min_metadata_size));
 			return 0;
 		}
+
 		if (!_lvconvert_update_pool_params(pool_lv, lp))
 			return_0;
 
+		log_warn("WARNING: Converting logical volume %s/%s to pool's metadata volume.",
+			 metadata_lv->vg->name, metadata_lv->name);
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+
+		if (!lp->yes &&
+		    yes_no_prompt("Do you really want to convert %s/%s? [y/n]: ",
+				  metadata_lv->vg->name, metadata_lv->name) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
+		}
+
 		metadata_lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(cmd, metadata_lv)) {
 			log_error("Aborting. Failed to activate metadata lv.");
@@ -2892,6 +2887,20 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 					lp->pvh, lp->poolmetadataspare))
 		return_0;
 
+	if (!lv_is_thin_pool(pool_lv)) {
+		log_warn("WARNING: Converting logical volume %s/%s to pool's data volume.",
+			 pool_lv->vg->name, pool_lv->name);
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+
+		if (!lp->yes &&
+		    yes_no_prompt("Do you really want to convert %s/%s? [y/n]: ",
+				  pool_lv->vg->name, pool_lv->name) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
+		}
+	}
+
+	data_lv = pool_lv;
 	old_name = data_lv->name; /* Use for pool name */
 	/*
 	 * Since we wish to have underlaying devs to match _[ct]data


