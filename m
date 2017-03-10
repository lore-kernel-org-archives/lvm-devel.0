From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:02 -0500
Subject: master - cache: introduce allocation/cache_metadata_format
Message-ID: <201703101837.v2AIb2hC028751@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a394f410d571d8c8ef7c9f87df781df0f7988bd
Commit:        4a394f410d571d8c8ef7c9f87df781df0f7988bd
Parent:        bb20fac4ab65454dd4cabc90426546c25254d927
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 26 20:19:07 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: introduce allocation/cache_metadata_format

Add new profilable configation setting to let user select
which metadata format of a created cache pool he wish to use.

By default the 'best' available format is autodetected at runtime,
but user may enforce format 1 or 2 ATM.

Code also detects availability for metadata2 supporting cache target.

In case of troubles user may easily Disable usage of this feature
by placing 'metadata2' into global/cache_disabled_features list.
---
 WHATS_NEW                        |    1 +
 conf/example.conf.in             |   20 ++++++++++++++++----
 lib/cache_segtype/cache.c        |   11 +++++++++++
 lib/config/config_settings.h     |   13 +++++++++++--
 lib/config/defaults.h            |    1 +
 lib/metadata/metadata-exported.h |    7 +++++++
 lib/metadata/segtype.h           |    1 +
 7 files changed, 48 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ef3ec3f..d1efed0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Add allocation/cache_metadata_format profilable setttings.
   Use function cache_set_params() for both lvcreate and lvconvert.
   Skip rounding on cache chunk size boudary when create cache LV.
   Improve cache_set_params support for chunk_size selection.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 5e238e4..614ce53 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -403,9 +403,20 @@ allocation {
 	# This configuration option has an automatic default value.
 	# cache_mode = "writethrough"
 
+	# Configuration option allocation/cache_metadata_format.
+	# Sets default metadata format for new cache.
+	# 
+	# Accepted values:
+	#   0  Automatically detected best available format
+	#   1  Original format
+	#   2  Improved 2nd. generation format
+	# 
+	# This configuration option has an automatic default value.
+	# cache_metadata_format = 0
+
 	# Configuration option allocation/cache_policy.
 	# The default cache policy used for new cache volume.
-	# Since kernel 4.2 the default policy is smq (Stochastic multique),
+	# Since kernel 4.2 the default policy is smq (Stochastic multiqueue),
 	# otherwise the older mq (Multiqueue) policy is selected.
 	# This configuration option does not have a default value defined.
 
@@ -1013,7 +1024,7 @@ global {
 	# Configuration option global/cache_disabled_features.
 	# Features to not use in the cache driver.
 	# This can be helpful for testing, or to avoid using a feature that is
-	# causing problems. Features include: policy_mq, policy_smq.
+	# causing problems. Features include: policy_mq, policy_smq, metadata2.
 	# 
 	# Example
 	# cache_disabled_features = [ "policy_smq" ]
@@ -1277,8 +1288,9 @@ activation {
 
 	# Configuration option activation/raid_region_size.
 	# Size in KiB of each raid or mirror synchronization region.
-	# For raid or mirror segment types, this is the amount of data that is
-	# copied at once when initializing, or moved at once by pvmove.
+	# The clean/dirty state of data is tracked for each region.
+	# The value is rounded down to a power of two if necessary, and
+	# is ignored if it is not a multiple of the machine memory page size.
 	raid_region_size = 512
 
 	# Configuration option activation/error_when_full.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ffa5d37..c378eda 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -213,6 +213,7 @@ static int _target_present(struct cmd_context *cmd,
 		const char *aliasing;
 	} _features[] = {
 		/* Assumption: cache >=1.9 always aliases MQ policy */
+		{ 1, 10, CACHE_FEATURE_METADATA2, 0, "metadata2" },
 		{ 1, 9, CACHE_FEATURE_POLICY_SMQ, CACHE_FEATURE_POLICY_MQ, "policy_smq", "cache-smq",
 		" and aliases cache-mq" },
 		{ 1, 8, CACHE_FEATURE_POLICY_SMQ, 0, "policy_smq", "cache-smq" },
@@ -250,6 +251,16 @@ static int _target_present(struct cmd_context *cmd,
 		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i) {
 			if (_attrs & _features[i].cache_feature)
 				continue; /* already present */
+
+			if (!_features[i].module[0]) {
+				if ((maj > _features[i].maj) ||
+				    (maj == _features[i].maj && min >= _features[i].min)) {
+					log_debug_activation("Cache supports %s.",
+							     _features[i].feature);
+					_attrs |= _features[i].cache_feature;
+				}
+				continue;
+			}
 			if (((maj > _features[i].maj) ||
 			     (maj == _features[i].maj && min >= _features[i].min)) &&
 			    module_present(cmd, _features[i].module)) {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6a01a97..b701722 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -480,6 +480,15 @@ cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_
 	"This has been replaced by the allocation/cache_mode setting.\n",
 	"Cache mode.\n")
 
+cfg(allocation_cache_metadata_format_CFG, "cache_metadata_format", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_CACHE_METADATA_FORMAT, vsn(2, 2, 169), NULL, 0, NULL,
+	"Sets default metadata format for new cache.\n"
+	"#\n"
+	"Accepted values:\n"
+	"  0  Automatically detected best available format\n"
+	"  1  Original format\n"
+	"  2  Improved 2nd. generation format\n"
+	"#\n")
+
 cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache mode used for new cache.\n"
 	"#\n"
@@ -494,7 +503,7 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILA
 
 cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache policy used for new cache volume.\n"
-	"Since kernel 4.2 the default policy is smq (Stochastic multique),\n"
+	"Since kernel 4.2 the default policy is smq (Stochastic multiqueue),\n"
 	"otherwise the older mq (Multiqueue) policy is selected.\n")
 
 cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
@@ -992,7 +1001,7 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 128), NULL, 0, NULL,
 	"Features to not use in the cache driver.\n"
 	"This can be helpful for testing, or to avoid using a feature that is\n"
-	"causing problems. Features include: policy_mq, policy_smq.\n"
+	"causing problems. Features include: policy_mq, policy_smq, metadata2.\n"
 	"#\n"
 	"Example\n"
 	"cache_disabled_features = [ \"policy_smq\" ]\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5554c9c..2340636 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -132,6 +132,7 @@
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_CACHE_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_CACHE_POLICY "mq"
+#define DEFAULT_CACHE_METADATA_FORMAT CACHE_METADATA_FORMAT_UNSELECTED /* Autodetect */
 #define DEFAULT_CACHE_MODE "writethrough"
 
 #define DEFAULT_UMASK 0077
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3486902..5c84bdf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -294,6 +294,13 @@ typedef enum {
 	CACHE_MODE_PASSTHROUGH,
 } cache_mode_t;
 
+/* ATM used for cache only */
+typedef enum {
+	CACHE_METADATA_FORMAT_UNSELECTED = 0,  /* On input means 'auto' */
+	CACHE_METADATA_FORMAT_1,
+	CACHE_METADATA_FORMAT_2,
+} cache_metadata_format_t;
+
 typedef enum {
 	LOCK_TYPE_INVALID = -1,
 	LOCK_TYPE_NONE = 0,
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index a7a3857..f99d3ad 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -315,6 +315,7 @@ int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
 
 #define CACHE_FEATURE_POLICY_MQ			(1U << 0)
 #define CACHE_FEATURE_POLICY_SMQ		(1U << 1)
+#define CACHE_FEATURE_METADATA2			(1U << 2)
 
 #define SNAPSHOT_FEATURE_FIXED_LEAK		(1U << 0) /* version 1.12 */
 


