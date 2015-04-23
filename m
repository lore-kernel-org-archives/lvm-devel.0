From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 23 Apr 2015 15:38:31 +0000 (UTC)
Subject: master - config: fix check_options array
Message-ID: <20150423153831.8D41E616D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95da21cc18d87ba7ae921b54abe5f622d12abb31
Commit:        95da21cc18d87ba7ae921b54abe5f622d12abb31
Parent:        a8bdfbe959a641da21d3baf27046deb8d2eaddb2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 23 10:35:34 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 23 10:35:34 2015 -0500

config: fix check_options array

The code used it as both a single string, and as
an array of strings in different places.  Fix it
so that it's an array of strings everywhere.
---
 lib/activate/dev_manager.c   |    4 ++--
 lib/config/config_settings.h |    4 ++--
 lib/config/defaults.h        |    8 +++++---
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dcb2c5d..1171f4c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1965,14 +1965,14 @@ static int _pool_register_callback(struct dev_manager *dm,
 		data->skip_zero = 1;
 		data->exec = global_thin_check_executable_CFG;
 		data->opts = global_thin_check_options_CFG;
-		data->defaults = DEFAULT_THIN_CHECK_OPTIONS;
+		data->defaults = DEFAULT_THIN_CHECK_OPTION1 " " DEFAULT_THIN_CHECK_OPTION2;
 		data->global = "thin";
 	} else if (lv_is_cache(lv)) { /* cache pool */
 		data->pool_lv = first_seg(lv)->pool_lv;
 		data->skip_zero = dm->activation;
 		data->exec = global_cache_check_executable_CFG;
 		data->opts = global_cache_check_options_CFG;
-		data->defaults = DEFAULT_CACHE_CHECK_OPTIONS;
+		data->defaults = DEFAULT_CACHE_CHECK_OPTION1;
 		data->global = "cache";
 	} else {
 		log_error(INTERNAL_ERROR "Registering unsupported pool callback.");
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6db9cda..742fa19 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -812,7 +812,7 @@ cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECT
 	"Also see thin_repair_options.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTIONS, vsn(2, 2, 96), NULL,
+cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL,
 	"String of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
@@ -857,7 +857,7 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 	"Also see cache_repair_options.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTIONS, vsn(2, 2, 108), NULL,
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL,
 	"String of options passed to the cache_check command.\n")
 
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 8339c1a..b745662 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -76,9 +76,11 @@
 #endif
 
 #ifdef THIN_CHECK_NEEDS_CHECK
-#  define DEFAULT_THIN_CHECK_OPTIONS "-q --clear-needs-check-flag"
+#  define DEFAULT_THIN_CHECK_OPTION1 "-q"
+#  define DEFAULT_THIN_CHECK_OPTION2 "--clear-needs-check-flag"
 #else
-#  define DEFAULT_THIN_CHECK_OPTIONS "-q"
+#  define DEFAULT_THIN_CHECK_OPTION1 "-q"
+#  define DEFAULT_THIN_CHECK_OPTION2 ""
 #endif
 
 #define DEFAULT_THIN_REPAIR_OPTIONS ""
@@ -93,7 +95,7 @@
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
 
-#define DEFAULT_CACHE_CHECK_OPTIONS "-q"
+#define DEFAULT_CACHE_CHECK_OPTION1 "-q"
 #define DEFAULT_CACHE_REPAIR_OPTIONS ""
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */


