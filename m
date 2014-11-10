From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:23 +0000 (UTC)
Subject: master - cleanup: API get/set fixes
Message-ID: <20141110210623.6B40A60D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e0c926d56f93880f4b7a7813cec7c3a774a8280
Commit:        2e0c926d56f93880f4b7a7813cec7c3a774a8280
Parent:        8d7340b7a191376b94c45503f9c5cbee5f337e85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 01:28:38 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

cleanup: API get/set fixes

---
 lib/metadata/lv.c                |    2 +-
 lib/metadata/metadata-exported.h |    4 ++--
 lib/metadata/mirror.c            |    4 ++--
 lib/metadata/thin_manip.c        |    4 ++--
 lib/report/report.c              |    2 +-
 lib/thin/thin.c                  |    2 +-
 tools/lvconvert.c                |    2 +-
 tools/lvcreate.c                 |    2 +-
 tools/lvmcmdline.c               |    4 ++--
 9 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 016f299..4ee751c 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -130,7 +130,7 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return dm_pool_strdup(mem, get_cachepool_cachemode_name(seg));
+	return dm_pool_strdup(mem, get_cache_pool_cachemode_name(seg));
 }
 
 #ifdef DMEVENTD
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 713b3b6..9afce35 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -763,8 +763,8 @@ int update_thin_pool_params(const struct segment_type *segtype,
 			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, int *zero);
-int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
+int set_pool_discards(thin_discards_t *discards, const char *str);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   const char *name, uint32_t read_ahead,
 					   uint32_t stripes, uint32_t stripe_size,
@@ -1011,8 +1011,8 @@ int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      int (*is_removable)(struct logical_volume *, void *),
 		      void *removable_baton, uint64_t status_mask);
-int get_mirror_log_count(const char *mirrorlog, int *log_count);
 const char *get_mirror_log_name(int log_count);
+int set_mirror_log_count(int *log_count, const char *mirrorlog);
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index a943ac4..ba3ff6b 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2273,7 +2273,7 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute__((unused)),
 	return remove_mirrors_from_segments(lv, new_mirrors, status_mask);
 }
 
-int get_mirror_log_count(const char *mirrorlog, int *log_count)
+int set_mirror_log_count(int *log_count, const char *mirrorlog)
 {
 	if (!strcmp("core", mirrorlog))
 		*log_count = MIRROR_LOG_CORE;
@@ -2297,6 +2297,6 @@ const char *get_mirror_log_name(int log_count)
 	case MIRROR_LOG_MIRRORED: return "mirrored";
 	default:
 		log_error(INTERNAL_ERROR "Unknown mirror log count %d.", log_count);
-		return "unknown";
+		return NULL;
 	}
 }
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 50354cc..b4aec73 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -436,7 +436,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 			log_error(INTERNAL_ERROR "Could not find configuration.");
 			return 0;
 		}
-		if (!get_pool_discards(str, discards))
+		if (!set_pool_discards(discards, str))
 			return_0;
 	}
 
@@ -512,7 +512,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 	return 1;
 }
 
-int get_pool_discards(const char *str, thin_discards_t *discards)
+int set_pool_discards(thin_discards_t *discards, const char *str)
 {
 	if (!strcasecmp(str, "passdown"))
 		*discards = THIN_DISCARDS_PASSDOWN;
diff --git a/lib/report/report.c b/lib/report/report.c
index 4f505e7..262b376 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -784,7 +784,7 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 		seg = first_seg(seg->pool_lv);
 
 	if (seg_is_cache_pool(seg)) {
-		cachemode_str = get_cachepool_cachemode_name(seg);
+		cachemode_str = get_cache_pool_cachemode_name(seg);
 		return dm_report_field_string(rh, field, &cachemode_str);
 	}
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index f921bef..f27f240 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -115,7 +115,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 
 	if (!discards_str)
 		seg->discards = THIN_DISCARDS_IGNORE;
-	else if (!get_pool_discards(discards_str, &seg->discards))
+	else if (!set_pool_discards(&seg->discards, discards_str))
 		return SEG_LOG_ERROR("Discards option unsupported for");
 
 	if (dm_config_has_node(sn, "low_water_mark") &&
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fcec8e1..8b09ee6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -267,7 +267,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 		if (!cachemode)
 			cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
 
-		if (!get_cache_mode(cachemode, &lp->feature_flags))
+		if (!set_cache_pool_feature(&lp->feature_flags, cachemode))
 			return_0;
 	} else {
 		if (arg_from_list_is_set(cmd, "is valid only with cache pools",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index cf2a07c..af00fee 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -567,7 +567,7 @@ static int _read_cache_params(struct cmd_context *cmd,
 	if (!(cachemode = arg_str_value(cmd, cachemode_ARG, NULL)))
 		cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
 
-	if (!get_cache_mode(cachemode, &lp->feature_flags))
+	if (!set_cache_pool_feature(&lp->feature_flags, cachemode))
 		return_0;
 
 	return 1;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1d3e993..ce45eb4 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -319,7 +319,7 @@ int discards_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_val
 {
 	thin_discards_t discards;
 
-	if (!get_pool_discards(av->value, &discards))
+	if (!set_pool_discards(&discards, av->value))
 		return_0;
 
 	av->i_value = discards;
@@ -332,7 +332,7 @@ int mirrorlog_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_va
 {
 	int log_count;
 
-	if (!get_mirror_log_count(av->value, &log_count))
+	if (!set_mirror_log_count(&log_count, av->value))
 		return_0;
 
 	av->i_value = log_count;


