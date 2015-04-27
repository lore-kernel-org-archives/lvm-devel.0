From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 27 Apr 2015 19:16:05 +0000 (UTC)
Subject: master - config: fix a couple mistakes with defaults
Message-ID: <20150427191605.83D45600E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfb0174fed25cb6a27a5ff3554b5c442d2defcc9
Commit:        cfb0174fed25cb6a27a5ff3554b5c442d2defcc9
Parent:        a7d28639eb4a2cd5adbf5b14b07702ba4d84593c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 27 13:17:15 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 27 13:54:45 2015 -0500

config: fix a couple mistakes with defaults

for archive, archive_dir, and cache
---
 lib/config/config_settings.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 742fa19..dcbc332 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -222,7 +222,7 @@ cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_D
 	"Devices rejected by global_filter are not opened by LVM.\n")
 
 cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), NULL,
-	"This has been replaced by the devices/cache_dir setting.\n")
+	"The path can be set using the devices/cache_dir setting.\n")
 
 cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@",
 	"Directory in which to store the device cache file.\n"
@@ -537,11 +537,11 @@ cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE
 	"Location of the metadata backup files.\n"
 	"Remember to back up this directory regularly!\n")
 
-cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@",
+cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), NULL,
 	"Maintain an archive of old metadata configurations.\n"
 	"Think very hard before turning this off.\n")
 
-cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), NULL,
+cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@",
 	"Location of the metdata archive files.\n"
 	"Remember to back up this directory regularly!\n")
 


