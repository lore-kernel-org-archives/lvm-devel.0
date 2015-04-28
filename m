From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 28 Apr 2015 15:10:51 +0000 (UTC)
Subject: master - config: improve the description of options lists
Message-ID: <20150428151051.A6BB760F51@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cc37275cebdc590f58bbd4e91110fe4d38801ce
Commit:        6cc37275cebdc590f58bbd4e91110fe4d38801ce
Parent:        ae0014e2dfd84b2348c7c8dd57f83159c79fda85
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 28 10:06:23 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 28 10:06:23 2015 -0500

config: improve the description of options lists

Describe
thin_check_options, thin_repair_options,
cache_check_option, scache_repair_options

as a "list of options", rather than a "string of options"
because a single string, e.g. "-q --clear-needs-check-flag"
does not work, and needs to be entered as a list,
e.g. ["-q", "--clear-needs-check-flag"]
---
 lib/config/config_settings.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 76b040b..e97ada5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -813,7 +813,7 @@ cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECT
 	"(For thin tools, see thin_check_executable.)\n")
 
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL,
-	"String of options passed to the thin_check command.\n"
+	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
 	"ignorable errors and fix them later.\n"
@@ -821,7 +821,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"--clear-needs-check-flag.\n")
 
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL,
-	"String of options passed to the thin_repair command.\n")
+	"List of options passed to the thin_repair command.\n")
 
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL,
 	"Features to not use in the thin driver.\n"
@@ -858,10 +858,10 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 	"(For cache tools, see cache_check_executable.)\n")
 
 cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL,
-	"String of options passed to the cache_check command.\n")
+	"List of options passed to the cache_check command.\n")
 
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL,
-	"String of options passed to the cache_repair command.\n")
+	"List of options passed to the cache_repair command.\n")
 
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL,
 	"The method LVM uses to set the local system ID.\n"


