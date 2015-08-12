From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:40:49 +0000 (UTC)
Subject: master - cache: add cache_policy cache_settings
Message-ID: <20150812124049.8FC7561086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=036d90bba6c1ac76195302bc5c7f2f5ce8ad89b4
Commit:        036d90bba6c1ac76195302bc5c7f2f5ce8ad89b4
Parent:        664a9f4830925cc3f51934dc09f9e2f3963c0de2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 20 11:44:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:16 2015 +0200

cache: add cache_policy cache_settings

Add new profilable configurables:

allocation/cache_policy
allocation/cache_settings

and mark allocation/cache_pool_chunk_size as profilable as well.

Obsolete allocation/cache_pool_cachemode and
introduce new allocation/cache_mode instead.

Rename DEFAULT_CACHE_POOL_POLICY to DEFAULT_CACHE_POLICY.
---
 WHATS_NEW                    |    1 +
 lib/cache_segtype/cache.c    |    2 +-
 lib/config/config.c          |    5 +++++
 lib/config/config.h          |    2 ++
 lib/config/config_settings.h |   24 +++++++++++++++++++++---
 lib/config/defaults.h        |    4 ++--
 tools/toollib.c              |    2 +-
 7 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d28e06c..9c8a103 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Add cmd profilable allocation/cache_policy,cache_settings,cache_mode.
   Require cache_check 0.5.4 for use of --clear-needs-check-flag.
   Fix lvmetad udev rules to not override SYSTEMD_WANTS, add the service instead.
 
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ad356a9..18c0168 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -79,7 +79,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
 	} else {
 		/* Cannot use 'just' default, so pick one */
-		seg->policy_name = DEFAULT_CACHE_POOL_POLICY; /* FIXME make configurable */
+		seg->policy_name = DEFAULT_CACHE_POLICY; /* FIXME make configurable */
 		/* FIXME maybe here should be always 'mq' */
 		log_warn("WARNING: cache_policy undefined, using default \"%s\" policy.",
 			 seg->policy_name);
diff --git a/lib/config/config.c b/lib/config/config.c
index eb8880e..436efff 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -2415,3 +2415,8 @@ int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, st
 {
 	return DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
 }
+
+const char *get_default_allocation_cache_policy_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	return DEFAULT_CACHE_POLICY;
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index 7520fc0..fb39e6e 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -296,5 +296,7 @@ int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, str
 #define get_default_unconfigured_allocation_thin_pool_chunk_size_CFG NULL
 int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile);
 #define get_default_unconfigured_allocation_cache_pool_chunk_size_CFG NULL
+const char *get_default_allocation_cache_policy_CFG(struct cmd_context *cmd, struct profile *profile);
+#define get_default_unconfigured_allocation_cache_policy_CFG NULL
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 5209531..deb17ef 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -462,15 +462,33 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
-cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL, 0, NULL,
-	"The default cache mode used for new cache pools.\n"
+cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 113), NULL, vsn(2, 2, 128),
+	"This has been replaced by the allocation/cache_mode setting.\n",
+	"Cache mode.\n")
+
+cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 128), NULL, 0, NULL,
+	"The default cache mode used for new cache.\n"
 	"Possible options are: writethrough, writeback.\n"
 	"writethrough - Data blocks are immediately written from\n"
 	"the cache to disk.\n"
 	"writeback - Data blocks are written from the cache back\n"
 	"to disk after some delay to improve performance.\n")
 
-cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
+cfg_runtime(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, vsn(2, 2, 127), 0, NULL,
+	"The default cache policy used for new cache volume.\n"
+	"Generally available policies are: mq, smq.\n"
+	"mq  - Multiqueue policy with 88 bytes per block\n"
+	"smq - Stochastic multique with 25 bytes per block (kernel >= 4.2).\n")
+
+cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 127), 0, NULL,
+	"Individual settings for policies.\n"
+	"See the help for individual policies for more info.\n")
+
+cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_settings_CFG_SECTION, CFG_NAME_VARIABLE | CFG_SECTION_NO_CHECK | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 127), 0, NULL,
+	"Replace this subsection name with a policy name.\n"
+	"Multiple subsections for different policies can be created.\n")
+
+cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
 	"The minimal chunk size (in kiB) for cache pool volumes.\n"
 	"Using a chunk_size that is too large can result in wasteful\n"
 	"use of the cache, where small reads and writes can cause\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5ee9b1c..f84eb19 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -117,8 +117,8 @@
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_CACHE_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
-#define DEFAULT_CACHE_POOL_CACHEMODE "writethrough"
-#define DEFAULT_CACHE_POOL_POLICY "mq"
+#define DEFAULT_CACHE_POLICY "mq"
+#define DEFAULT_CACHE_MODE "writethrough"
 
 #define DEFAULT_UMASK 0077
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 5d5e4d6..0d401e4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1408,7 +1408,7 @@ int get_cache_policy_params(struct cmd_context *cmd, const char **name,
 	struct dm_config_node *cn;
 	int ok = 0;
 
-	*name = arg_str_value(cmd, cachepolicy_ARG, DEFAULT_CACHE_POOL_POLICY);
+	*name = arg_str_value(cmd, cachepolicy_ARG, DEFAULT_CACHE_POLICY);
 
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))


