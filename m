From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 14 Jul 2015 08:17:04 +0000 (UTC)
Subject: master - config: {thin, cache}_{check, repair}_options are never undefined
Message-ID: <20150714081704.17085601D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac3143c0936d00a0a1f4a865192040d3791afd66
Commit:        ac3143c0936d00a0a1f4a865192040d3791afd66
Parent:        d41bab402805c8813bb8eb0b18f3da97bb79fdf7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 14 10:03:19 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 14 10:13:41 2015 +0200

config: {thin,cache}_{check,repair}_options are never undefined

Require global/{thin,cache}_{check,repair}_options to be always defined.
If not defined directly by user in the configuration and if there's no
concrete default option to use, make "" (empty string) the default one -
it's then clearly visible in the "lvmconfig --type default" (and
generated lvm.conf) and also it makes its handling in the code more
straightforward so we don't need to handle undefined values.

This means, if there are no default values for these settings defined,
we end up with this generated now:
  {thin,cache}_{check,repair}_options = [ "" ]

So the value is never undefined and if it is, it's an error.

(The cache_repair_options is actually not used in the code at the moment,
but once the code using this setting is in, it will follow the same logic
as used for thin_repair_options.)
---
 conf/example.conf.in         |    4 ++--
 lib/activate/dev_manager.c   |    6 ++++--
 lib/config/config_settings.h |    8 ++++----
 lib/config/defaults.h        |    8 ++++----
 tools/lvconvert.c            |    6 ++++--
 5 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 3207955..3900ad4 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -876,7 +876,7 @@ global {
 
 	# Configuration option global/thin_repair_options.
 	# List of options passed to the thin_repair command.
-	# This configuration option does not have a default value defined.
+	# thin_repair_options = [ "" ]
 
 	# Configuration option global/thin_disabled_features.
 	# Features to not use in the thin driver.
@@ -924,7 +924,7 @@ global {
 
 	# Configuration option global/cache_repair_options.
 	# List of options passed to the cache_repair command.
-	# This configuration option does not have a default value defined.
+	# cache_repair_options = [ "" ]
 
 	# Configuration option global/system_id_source.
 	# The method LVM uses to set the local system ID.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 0e29bcd..101cd36 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1939,8 +1939,10 @@ static int _pool_callback(struct dm_tree_node *node,
 	if (!*argv[0])
 		return 1; /* Checking disabled */
 
-	if (!(cn = find_config_tree_array(mlv->vg->cmd, data->opts, NULL)))
-		return_0;
+	if (!(cn = find_config_tree_array(mlv->vg->cmd, data->opts, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for pool check options.");
+		return 0;
+	}
 
 	for (cv = cn->v; cv && args < 16; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 44f1e04..ce03b36 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -869,7 +869,7 @@ cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECT
 	"Also see thin_repair_options.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_THIN_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
+cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
@@ -877,7 +877,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"With thin_check version 3.2 or newer you should add\n"
 	"--clear-needs-check-flag.\n")
 
-cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_THIN_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
@@ -916,10 +916,10 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 	"Also see cache_repair_options.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_CACHE_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_check command.\n")
 
-cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index c568340..5ee9b1c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -88,8 +88,8 @@
 #  define DEFAULT_THIN_CHECK_OPTIONS_CONFIG "#S" DEFAULT_THIN_CHECK_OPTION1
 #endif
 
-#define DEFAULT_THIN_REPAIR_OPTIONS ""
-#define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG NULL
+#define DEFAULT_THIN_REPAIR_OPTION1 ""
+#define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_THIN_REPAIR_OPTION1
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
@@ -111,8 +111,8 @@
 #  define DEFAULT_CACHE_CHECK_OPTIONS_CONFIG "#S" DEFAULT_CACHE_CHECK_OPTION1
 #endif
 
-#define DEFAULT_CACHE_REPAIR_OPTIONS ""
-#define DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG NULL
+#define DEFAULT_CACHE_REPAIR_OPTION1 ""
+#define DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_CACHE_REPAIR_OPTION1
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1461f4a..e824e8c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2351,8 +2351,10 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!(cn = find_config_tree_array(cmd, global_thin_repair_options_CFG, NULL)))
-		return_0;
+	if (!(cn = find_config_tree_array(cmd, global_thin_repair_options_CFG, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for global/thin_repair_options");
+		return 0;
+	}
 
 	for (cv = cn->v; cv && args < 16; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {


