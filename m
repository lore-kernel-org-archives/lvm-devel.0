From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Apr 2015 21:04:44 +0000 (UTC)
Subject: master - config: thin_repair_options and cache_repair_options are undefined
Message-ID: <20150421210444.0AE0E610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e035162a13d9ed6036b1bd8cdacbfa7ba1fd748
Commit:        2e035162a13d9ed6036b1bd8cdacbfa7ba1fd748
Parent:        3b15f79bf02d5276fa352cdb87fa0a80a34c1465
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 21 16:01:15 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 16:03:54 2015 -0500

config: thin_repair_options and cache_repair_options are undefined

By default these are empty strings, so the config settings
should be flagged as undefined, so they will be commented
out of the generated config.  Otherwise, the lines:

thin_repair_options=""
cache_repair_options=""

in the dump output cause a warning when processed since
lvm doesn't want an empty string.

Also regenerate lvm.conf.in.
---
 conf/example.conf.in         |    6 ++++--
 lib/config/config_settings.h |    4 ++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 48090cf..eedefb5 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -867,7 +867,8 @@ global {
 
 	# Configuration option global/thin_repair_options.
 	# String of options passed to the thin_repair command.
-	thin_repair_options=""
+	# This configuration option does not have a default value defined.
+#	thin_repair_options=""
 
 	# Configuration option global/thin_disabled_features.
 	# Features to not use in the thin driver.
@@ -913,7 +914,8 @@ global {
 
 	# Configuration option global/cache_repair_options.
 	# String of options passed to the cache_repair command.
-	cache_repair_options=""
+	# This configuration option does not have a default value defined.
+#	cache_repair_options=""
 
 	# Configuration option global/system_id_source.
 	# The method LVM uses to set the local system ID.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 78304ed..1a0ebf7 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -820,7 +820,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"With thin_check version 3.2 or newer you should add\n"
 	"--clear-needs-check-flag.\n")
 
-cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL,
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL,
 	"String of options passed to the thin_repair command.\n")
 
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL,
@@ -860,7 +860,7 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTIONS, vsn(2, 2, 108), NULL,
 	"String of options passed to the cache_check command.\n")
 
-cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL,
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL,
 	"String of options passed to the cache_repair command.\n")
 
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL,


