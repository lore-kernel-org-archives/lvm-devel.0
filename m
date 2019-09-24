From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:55:51 -0400
Subject: master - lvconvert: separate splitcache and uncache functions
Message-ID: <201909242055.x8OKtpVL015806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44640043628425e09122aa3775fd40a5b13c0fd0
Commit:        44640043628425e09122aa3775fd40a5b13c0fd0
Parent:        e35cf0f623ba591c12a1a2eaed126d47bf11103c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 11:28:30 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 13:55:21 2019 -0500

lvconvert: separate splitcache and uncache functions

Reorg code so there are separate functions for splitcache
and uncache for both cachepool and cachevol.  Should be no
functional change.
---
 tools/lvconvert.c |  121 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 75 insertions(+), 46 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5d1267a..352a588 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1836,7 +1836,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	return 1;
 }
 
-static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
+static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *lv_fast)
 {
@@ -1847,51 +1847,66 @@ static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
 	if (!archive(lv->vg))
 		return_0;
 
-	if (lv_is_cache_vol(cache_seg->pool_lv)) {
-		log_debug("Detaching cachevol %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
+	log_debug("Detaching cachevol %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
 
-		/*
-		 * Detaching a writeback cache generally requires flushing;
-		 * doing otherwise can mean data loss/corruption.
-		 * If the cache devices are missing, the cache can't be
-		 * flushed, so require the user to use a force option to
-		 * detach the cache in this case.
-		 */
-		if ((cache_mode != CACHE_MODE_WRITETHROUGH) && lv_is_partial(lv_fast)) {
-			if (!arg_count(cmd, force_ARG)) {
-				log_warn("WARNING: writeback cache on %s is not complete and cannot be flushed.", display_lvname(lv_fast));
-				log_warn("WARNING: cannot detach writeback cache from %s without --force.", display_lvname(lv));
-				log_error("Conversion aborted.");
-				return 0;
-			}
-
-			log_warn("WARNING: Data may be lost by detaching writeback cache without flushing.");
+	/*
+	 * Detaching a writeback cache generally requires flushing;
+	 * doing otherwise can mean data loss/corruption.
+	 * If the cache devices are missing, the cache can't be
+	 * flushed, so require the user to use a force option to
+	 * detach the cache in this case.
+	 */
+	if ((cache_mode != CACHE_MODE_WRITETHROUGH) && lv_is_partial(lv_fast)) {
+		if (!arg_count(cmd, force_ARG)) {
+			log_warn("WARNING: writeback cache on %s is not complete and cannot be flushed.", display_lvname(lv_fast));
+			log_warn("WARNING: cannot detach writeback cache from %s without --force.", display_lvname(lv));
+			log_error("Conversion aborted.");
+			return 0;
+		}
 
-			if (!arg_count(cmd, yes_ARG) &&
-			    yes_no_prompt("Detach writeback cache %s from %s without flushing data?",
-				          display_lvname(lv_fast),
-				          display_lvname(lv)) == 'n') {
-				log_error("Conversion aborted.");
-				return 0;
-			}
+		log_warn("WARNING: Data may be lost by detaching writeback cache without flushing.");
 
-			noflush = 1;
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Detach writeback cache %s from %s without flushing data?",
+				  display_lvname(lv_fast), display_lvname(lv)) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
 		}
+
+		noflush = 1;
+	}
 				
-		if (!lv_detach_cache_vol(lv, noflush))
-			return_0;
-	} else {
-		log_debug("Detaching cachepool %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
+	if (!lv_detach_cache_vol(lv, noflush))
+		return_0;
 
-		if (vg_missing_pv_count(lv->vg)) {
-			log_error("Cannot split cache pool while PVs are missing, see --uncache to delete cache pool.");
-			return 0;
-		}
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
 
-		if (!lv_cache_remove(lv))
-			return_0;
+	backup(lv->vg);
+
+	log_print_unless_silent("Logical volume %s is not cached and %s is unused.",
+				display_lvname(lv), display_lvname(lv_fast));
+
+	return 1;
+}
+
+static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *lv_fast)
+{
+	if (!archive(lv->vg))
+		return_0;
+
+	log_debug("Detaching cachepool %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
+
+	if (vg_missing_pv_count(lv->vg)) {
+		log_error("Cannot split cache pool while PVs are missing, see --uncache to delete cache pool.");
+		return 0;
 	}
 
+	if (!lv_cache_remove(lv))
+		return_0;
+
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
@@ -1903,7 +1918,16 @@ static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _lvconvert_split_and_remove_cache(struct cmd_context *cmd,
+static int _lvconvert_split_and_remove_cachevol(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *lv_fast)
+{
+	log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
+	log_error("The cache %s may then be removed with lvremove.", display_lvname(lv_fast));
+	return 0;
+}
+
+static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *cachepool_lv)
 {
@@ -4701,19 +4725,24 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 
 		ret = _lvconvert_detach_writecache(cmd, lv_main, lv_fast);
 
-	} else if (lv_is_cache(lv_main)) {
-		if ((cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) &&
-		    lv_is_cache_vol(lv_fast)) {
-			log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
-			log_error("The cache %s may then be removed with lvremove.", display_lvname(lv_fast));
-			return 0;
+	} else if (lv_is_cache(lv_main) && lv_is_cache_vol(lv_fast)) {
+		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD)
+			ret = _lvconvert_split_and_remove_cachevol(cmd, lv_main, lv_fast);
+
+		else if (cmd->command->command_enum == lvconvert_split_and_keep_cache_CMD)
+			ret = _lvconvert_split_and_keep_cachevol(cmd, lv_main, lv_fast);
+
+		else  {
+			log_error(INTERNAL_ERROR "Unknown cache split command.");
+			ret = 0;
 		}
 
+	} else if (lv_is_cache(lv_main) && lv_is_cache_pool(lv_fast)) {
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD)
-			ret = _lvconvert_split_and_remove_cache(cmd, lv_main, lv_fast);
+			ret = _lvconvert_split_and_remove_cachepool(cmd, lv_main, lv_fast);
 
 		else if (cmd->command->command_enum == lvconvert_split_and_keep_cache_CMD)
-			ret = _lvconvert_split_and_keep_cache(cmd, lv_main, lv_fast);
+			ret = _lvconvert_split_and_keep_cachepool(cmd, lv_main, lv_fast);
 
 		else  {
 			log_error(INTERNAL_ERROR "Unknown cache split command.");


