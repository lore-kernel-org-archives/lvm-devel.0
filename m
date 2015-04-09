From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Apr 2015 21:36:16 +0000 (UTC)
Subject: master - config: comments update
Message-ID: <20150409213616.599F360C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4eaa399b54fb3cd7d30fd919666723159d9a04b5
Commit:        4eaa399b54fb3cd7d30fd919666723159d9a04b5
Parent:        303c5ba803cbfe81b1bc92cc2b2e9aa0970b21d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 9 16:35:20 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 9 16:35:20 2015 -0500

config: comments update

missing \n
---
 lib/config/config_settings.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d76ed0f..b55b39b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -72,11 +72,11 @@
 cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), NULL)
 
 cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99),
-	"This section allows you to set the way the configuration settings are handled.")
+	"This section allows you to set the way the configuration settings are handled.\n")
 
 cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0),
 	"This section allows you to configure which block devices should\n"
-	"be used by the LVM system.")
+	"be used by the LVM system.\n")
 
 cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77),
 	"This section allows you to configure the way in which LVM selects\n"
@@ -115,17 +115,17 @@ cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2,
 	"configuration key not being found is issued in verbose mode only).\n")
 
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99),
-	"If enabled, any configuration mismatch aborts the LVM process.")
+	"If enabled, any configuration mismatch aborts the LVM process.\n")
 
 cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99),
-	"Directory where LVM looks for configuration profiles.")
+	"Directory where LVM looks for configuration profiles.\n")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0),
 	"Where do you want your volume groups to appear ?")
 
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0),
 	"An array of directories that contain the device nodes you wish\n"
-	"to use with LVM.")
+	"to use with LVM.\n")
 
 cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL)
 
@@ -229,7 +229,7 @@ cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE
 	"file is removed.\n")
 
 cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19),
-	"A prefix used before the .cache file name.")
+	"A prefix used before the .cache file name.\n")
 
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0),
 	"Enable/disable writing the cache file.\n")


