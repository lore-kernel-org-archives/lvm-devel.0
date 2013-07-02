From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:33:04 +0000 (UTC)
Subject: master - thin: make selected thinp settings profilable
Message-ID: <20130702133304.AD79260DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24a84549a88a6c937091b894d1f0babe10aed17d
Commit:        24a84549a88a6c937091b894d1f0babe10aed17d
Parent:        6f0427cc56b1ef3ca63ba20b0ac8c0764d38632a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 27 11:22:02 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:11 2013 +0200

thin: make selected thinp settings profilable

These settins are customizable by profiles:

	allocation/thin_pool_zero
	allocation/thin_pool_discards
	allocation/thin_pool_chunk_size
	activation/thin_pool_autoextend_threshold
	activation/thin_pool_autoextend_percent
---
 lib/config/config_settings.h |   14 +++++++-------
 lib/metadata/thin_manip.c    |    3 ++-
 tools/lvconvert.c            |   14 +++++++-------
 tools/lvcreate.c             |    2 +-
 tools/lvresize.c             |    6 ++++--
 tools/toollib.c              |   10 ++++++----
 tools/toollib.h              |    4 +++-
 7 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a8d02be..d9112f5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -56,12 +56,12 @@ cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), NULL)
 
 cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99), "Configuration handling.")
 cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
-cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, 0, vsn(2, 2, 77), NULL)
+cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77), NULL)
 cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
-cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
+cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
 cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
 cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
 cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3), NULL)
@@ -101,9 +101,9 @@ cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTIO
 cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
-cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
-cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
-cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_THIN_POOL_CHUNK_SIZE, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_CHUNK_SIZE, vsn(2, 2, 99), NULL)
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
 cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL)
@@ -179,8 +179,8 @@ cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activatio
 cfg(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 57), NULL)
 cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL)
 cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL)
-cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL)
-cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL)
+cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL)
+cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL)
 cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL)
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL)
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 9fccc6f..4ff647a 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -335,7 +335,8 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	percent_t percent;
 	int threshold = PERCENT_1 *
-		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG, NULL);
+		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG,
+				     lv_config_profile(pool_seg->lv));
 
 	/* Data */
 	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ffdc3f4..542c71d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -385,13 +385,6 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (!get_pool_params(cmd, &lp->passed_args,
-				     &lp->chunk_size,
-				     &lp->discards,
-				     &lp->poolmetadata_size,
-				     &lp->zero))
-			return_0;
-
 		if (arg_count(cmd, poolmetadata_ARG)) {
 			if (arg_count(cmd, poolmetadatasize_ARG)) {
 				log_error("--poolmetadatasize is invalid with --poolmetadata.");
@@ -2415,6 +2408,13 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	if (!lv)
 		goto_out;
 
+	if (arg_count(cmd, thinpool_ARG) &&
+	    !get_pool_params(cmd, lv_config_profile(lv),
+			     &lp->passed_args, &lp->chunk_size,
+			     &lp->discards, &lp->poolmetadata_size,
+			     &lp->zero))
+		goto_out;
+
 	/*
 	 * lp->pvh holds the list of PVs available for allocation or removal
 	 */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index dcd05d0..698d72f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -859,7 +859,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_thin_pool &&
-	     !get_pool_params(cmd, &lp->passed_args,
+	     !get_pool_params(cmd, NULL, &lp->passed_args,
 			      &lp->chunk_size, &lp->discards,
 			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
diff --git a/tools/lvresize.c b/tools/lvresize.c
index bd29bc6..47cb6aa 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -306,9 +306,11 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 
 	if (lv_is_thin_pool(lv)) {
 		policy_threshold =
-			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG, NULL) * PERCENT_1;
+			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
+					     lv_config_profile(lv)) * PERCENT_1;
 		policy_amount =
-			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG, NULL);
+			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG,
+					     lv_config_profile(lv));
 		if (!policy_amount && policy_threshold < PERCENT_100)
                         return 0;
 	} else {
diff --git a/tools/toollib.c b/tools/toollib.c
index 7f57604..46eb864 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1537,7 +1537,9 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 	return 1;
 }
 
-int get_pool_params(struct cmd_context *cmd, int *passed_args,
+int get_pool_params(struct cmd_context *cmd,
+		    struct profile *profile,
+		    int *passed_args,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
@@ -1551,7 +1553,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 		log_very_verbose("Setting pool zeroing: %u", *zero);
 	} else
-		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, NULL);
+		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile);
 
 	if (arg_count(cmd, discards_ARG)) {
 		*passed_args |= PASS_ARG_DISCARDS;
@@ -1559,7 +1561,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		log_very_verbose("Setting pool discards: %s",
 				 get_pool_discards_name(*discards));
 	} else {
-		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, NULL);
+		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
 		if (!get_pool_discards(dstr, discards))
 			return_0;
 	}
@@ -1575,7 +1577,7 @@ int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
 	} else
-		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL) * 2;
+		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2;
 
 	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
diff --git a/tools/toollib.h b/tools/toollib.h
index d2fd9ac..32884db 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -114,7 +114,9 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode);
 
-int get_pool_params(struct cmd_context *cmd, int *passed_args,
+int get_pool_params(struct cmd_context *cmd,
+		    struct profile *profile,
+		    int *passed_args,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,


