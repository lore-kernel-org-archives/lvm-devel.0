From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:21:10 +0000 (UTC)
Subject: master - config: runtime default for allocation/thin_pool_chunk_size
Message-ID: <20140306112110.523B06114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d27868e94fb953c7e61da1e0d356f816e4567933
Commit:        d27868e94fb953c7e61da1e0d356f816e4567933
Parent:        932e75e89fcbce3c41a1875a707df5fd7ecdc5e6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 4 11:10:59 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:26:02 2014 +0100

config: runtime default for allocation/thin_pool_chunk_size

The allocation/thin_pool_chunk_size is a bit more complex. It's default
value is evaluated in runtime based on selected thin_pool_chunk_size_policy.
But the value is just a starting point. The calculation then continues
with dependency on the properties of the devices used. Which means for
such a default value, we know only the starting value.
---
 lib/config/config.c          |   19 +++++++++++++++++++
 lib/config/config.h          |    1 +
 lib/config/config_settings.h |    2 +-
 lib/metadata/lv_manip.c      |    5 +----
 lib/metadata/thin_manip.c    |   31 +++++++++----------------------
 5 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index b8c67d0..3cc091c 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1692,3 +1692,22 @@ const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_cont
 {
 	return find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG, profile);
 }
+
+int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	const char *str;
+	uint32_t chunk_size;
+
+	str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
+
+	if (!strcasecmp(str, "generic"))
+		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE;
+	else if (!strcasecmp(str, "performance"))
+		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE;
+	else {
+		log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
+		return 0;
+	}
+
+	return (int) chunk_size;
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index 4d762fe..7d7d4b2 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -236,5 +236,6 @@ const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct pr
 const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_context *cmd, struct profile *profile);
+int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile);
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 04f2498..6231b79 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -125,7 +125,7 @@ cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL)
-cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, 0, vsn(2, 2, 99), NULL)
+cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), NULL)
 
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 57ce2d9..51342a3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5771,10 +5771,7 @@ static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *l
 
 		min_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
 		max_chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
-		if (lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
-			default_chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2;
-		else
-			default_chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE*2;
+		default_chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, NULL) * 2;
 	} else if (seg_is_cache_pool(lp)) {
 		if (find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, NULL))
 			goto out;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b28f5a0..2e49019 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -366,26 +366,6 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return 1;
 }
 
-static int _get_pool_chunk_size_calc(const char *str,
-				     int *chunk_size_calc_method,
-				     uint32_t *chunk_size)
-{
-	if (!strcasecmp(str, "generic")) {
-		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
-		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
-	}
-	else if (!strcasecmp(str, "performance")) {
-		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE;
-		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2;
-	}
-	else {
-		log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
-		return 0;
-	}
-
-	return 1;
-}
-
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
 				  int passed_args, int *chunk_size_calc_method,
 				  uint32_t *chunk_size, thin_discards_t *discards,
@@ -396,8 +376,15 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
 			str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
-			if (!_get_pool_chunk_size_calc(str, chunk_size_calc_method, chunk_size))
-				return_0;
+			if (!strcasecmp(str, "generic"))
+				*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
+			else if (!strcasecmp(str, "performance"))
+				*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE;
+			else {
+				log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
+				return 0;
+			}
+			*chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, profile) * 2;
 		}
 	}
 


