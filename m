From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:47 +0000 (UTC)
Subject: master - config: allow empty values for {thin, cache}_{check, repair}_options
Message-ID: <20150624092747.DEC8760DF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c725648f6c3c5709c0a6823900c716d67a31818d
Commit:        c725648f6c3c5709c0a6823900c716d67a31818d
Parent:        20e336f21c242e7a98d11d9dc03941512c0ab69a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 15:35:24 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:13:38 2015 +0200

config: allow empty values for {thin,cache}_{check,repair}_options

It's not an error to define empty values for
{thin,cache}_{check,repair}_options - such empty value means no
options are passed when these external commands are called.
---
 lib/config/config_settings.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 092e86d..e5edf6d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -855,7 +855,7 @@ cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECT
 	"Also see thin_repair_options.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, DEFAULT_THIN_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
+cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_THIN_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
@@ -863,7 +863,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"With thin_check version 3.2 or newer you should add\n"
 	"--clear-needs-check-flag.\n")
 
-cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_THIN_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
@@ -900,10 +900,10 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 	"Also see cache_repair_options.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_CACHE_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_check command.\n")
 
-cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | (DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED), CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,


