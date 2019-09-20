From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 11:00:51 -0400
Subject: master - lvconvert: detaching cachevol with missing PVs
Message-ID: <201909201500.x8KF0pcO018872@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d3bced5eab1244939958422446e0dfb5b6b79d4
Commit:        5d3bced5eab1244939958422446e0dfb5b6b79d4
Parent:        b46dce0badb221b1417231e7bbf2d7d898a5a8c1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 17 16:32:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 09:59:37 2019 -0500

lvconvert: detaching cachevol with missing PVs

. For dm-cache in writethrough, always allow splitcache,
  whether the cache is missing PVs or not.

. For dm-cache in writeback, if the cache is missing PVs,
  allow splitcache with force and yes.

. For dm-writecache, if the cache is missing PVs,
  allow splitcache with force and yes.
---
 lib/metadata/cache_manip.c       |    8 ++--
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 tools/lvconvert.c                |   84 ++++++++++++++++++++++++++++++-------
 4 files changed, 74 insertions(+), 22 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 7ea2c0e..65589f7 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -655,7 +655,7 @@ static int _lv_detach_cache_vol_while_active(struct cmd_context *cmd, struct log
 	return 1;
 }
 
-static int _lv_detach_cache_vol_while_inactive(struct cmd_context *cmd, struct logical_volume *cache_lv)
+static int _lv_detach_cache_vol_while_inactive(struct cmd_context *cmd, struct logical_volume *cache_lv, int noflush)
 {
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
@@ -673,7 +673,7 @@ static int _lv_detach_cache_vol_while_inactive(struct cmd_context *cmd, struct l
 	 * With these modes there is no flush needed so we can immediately
 	 * detach without temporarily activating the LV to flush it.
 	 */
-	if ((cache_mode == CACHE_MODE_WRITETHROUGH) || (cache_mode == CACHE_MODE_PASSTHROUGH))
+	if ((cache_mode == CACHE_MODE_WRITETHROUGH) || (cache_mode == CACHE_MODE_PASSTHROUGH) || noflush)
 		goto detach;
 
 	/*
@@ -727,7 +727,7 @@ static int _lv_detach_cache_vol_while_inactive(struct cmd_context *cmd, struct l
 	return 1;
 }
 
-int lv_detach_cache_vol(struct logical_volume *cache_lv)
+int lv_detach_cache_vol(struct logical_volume *cache_lv, int noflush)
 {
 	struct cmd_context *cmd = cache_lv->vg->cmd;
 
@@ -739,7 +739,7 @@ int lv_detach_cache_vol(struct logical_volume *cache_lv)
 	if (lv_is_active(cache_lv))
 		return _lv_detach_cache_vol_while_active(cmd, cache_lv);
 	else
-		return _lv_detach_cache_vol_while_inactive(cmd, cache_lv);
+		return _lv_detach_cache_vol_while_inactive(cmd, cache_lv, noflush);
 }
 
 /*
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6451368..107074a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6256,7 +6256,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
-		if (!lv_detach_cache_vol(lv)) {
+		if (!lv_detach_cache_vol(lv, 0)) {
 			log_error("Failed to detach cache from %s", display_lvname(lv));
 			return 0;
 		}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a910aa3..1c10390 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1276,7 +1276,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 				       struct logical_volume *origin_lv);
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
-int lv_detach_cache_vol(struct logical_volume *cache_lv);
+int lv_detach_cache_vol(struct logical_volume *cache_lv, int noflush);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d64ab22..77aad9d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1841,16 +1841,53 @@ static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
 				   struct logical_volume *lv_fast)
 {
 	struct lv_segment *cache_seg = first_seg(lv);
-
-	log_debug("Detaching cache %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
+	int cache_mode = cache_seg->cache_mode;
+	int noflush = 0;
 
 	if (!archive(lv->vg))
 		return_0;
 
 	if (lv_is_cache_vol(cache_seg->pool_lv)) {
-		if (!lv_detach_cache_vol(lv))
+		log_debug("Detaching cachevol %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
+
+		/*
+		 * Detaching a writeback cache generally requires flushing;
+		 * doing otherwise can mean data loss/corruption.
+		 * If the cache devices are missing, the cache can't be
+		 * flushed, so require the user to use a force option to
+		 * detach the cache in this case.
+		 */
+		if ((cache_mode != CACHE_MODE_WRITETHROUGH) && lv_is_partial(lv_fast)) {
+			if (!arg_count(cmd, force_ARG)) {
+				log_warn("WARNING: writeback cache on %s is not complete and cannot be flushed.", display_lvname(lv_fast));
+				log_warn("WARNING: cannot detach writeback cache from %s without --force.", display_lvname(lv));
+				log_error("Conversion aborted.");
+				return 0;
+			}
+
+			log_warn("WARNING: Data may be lost by detaching writeback cache without flushing.");
+
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Detach writeback cache %s from %s without flushing data?",
+				          display_lvname(lv_fast),
+				          display_lvname(lv)) == 'n') {
+				log_error("Conversion aborted.");
+				return 0;
+			}
+
+			noflush = 1;
+		}
+				
+		if (!lv_detach_cache_vol(lv, noflush))
 			return_0;
 	} else {
+		log_debug("Detaching cachepool %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
+
+		if (vg_missing_pv_count(lv->vg)) {
+			log_error("Cannot split cache pool while PVs are missing, see --uncache to delete cache pool.");
+			return 0;
+		}
+
 		if (!lv_cache_remove(lv))
 			return_0;
 	}
@@ -1860,7 +1897,7 @@ static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
 
 	backup(lv->vg);
 
-	log_print_unless_silent("Logical volume %s is not cached and cache pool %s is unused.",
+	log_print_unless_silent("Logical volume %s is not cached and %s is unused.",
 				display_lvname(lv), display_lvname(lv_fast));
 
 	return 1;
@@ -1895,7 +1932,7 @@ static int _lvconvert_split_and_remove_cache(struct cmd_context *cmd,
 		if (first_seg(seg->pool_lv)->cache_mode != CACHE_MODE_WRITETHROUGH) {
 			if (!arg_count(cmd, force_ARG)) {
 				log_error("Conversion aborted.");
-				log_error("Cannot uncache writethrough cache volume %s without --force.",
+				log_error("Cannot uncache writeback cache volume %s without --force.",
 					  display_lvname(lv));
 				return 0;
 			}
@@ -4607,7 +4644,7 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast);
 
-static int _lvconvert_split_cache_vol(struct cmd_context *cmd,
+static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
 					 struct processing_handle *handle)
 {
@@ -4635,6 +4672,7 @@ static int _lvconvert_split_cache_vol(struct cmd_context *cmd,
 	} else if (lv_is_thin_pool(lv)) {
 		lv_main = seg_lv(first_seg(lv), 0); /* cached _tdata */
 		lv_fast = first_seg(lv_main)->pool_lv;
+
 	} else if (lv_is_vdo_pool(lv)) {
 		lv_main = seg_lv(first_seg(lv), 0); /* cached _vdata */
 		lv_fast = first_seg(lv_main)->pool_lv;
@@ -4694,13 +4732,11 @@ static int _lvconvert_split_cache_vol(struct cmd_context *cmd,
 
 int lvconvert_split_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
-		cmd->handles_missing_pvs = 1;
-		cmd->partial_activation = 1;
-	}
+	cmd->handles_missing_pvs = 1;
+	cmd->partial_activation = 1;
 
 	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_split_cache_vol);
+			       NULL, NULL, &_lvconvert_split_cache_single);
 }
 
 static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -5246,11 +5282,6 @@ fail:
 	return 0;
 }
 
-/*
- * TODO: add a new option that will skip activating and flushing the
- * writecache and move directly to detaching.
- */
-
 static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast)
@@ -5269,6 +5300,26 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	if (!archive(lv->vg))
 		return_0;
 
+	if (lv_is_partial(lv_fast)) {
+		if (!arg_count(cmd, force_ARG)) {
+			log_warn("WARNING: writecache on %s is not complete and cannot be flushed.", display_lvname(lv_fast));
+			log_warn("WARNING: cannot detach writecache from %s without --force.", display_lvname(lv));
+			log_error("Conversion aborted.");
+			return 0;
+		}
+
+		log_warn("WARNING: Data may be lost by detaching writecache without flushing.");
+
+		if (!arg_count(cmd, yes_ARG) &&
+		     yes_no_prompt("Detach writecache %s from %s without flushing data?",
+				   display_lvname(lv_fast), display_lvname(lv)) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
+		}
+
+		goto detach;
+	}
+
 	/*
 	 * Activate LV internally since the LV needs to be active to flush.
 	 * LV_TEMPORARY should keep the LV from being exposed to the user
@@ -5315,6 +5366,7 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 
 	lv->status &= ~LV_TEMPORARY;
 
+ detach:
 	if (!_lv_writecache_detach(cmd, lv, lv_fast)) {
 		log_error("Failed to detach writecache from %s", display_lvname(lv));
 		return 0;


