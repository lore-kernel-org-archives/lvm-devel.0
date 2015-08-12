From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 12 Aug 2015 20:36:01 +0000 (UTC)
Subject: master - config: description updates
Message-ID: <20150812203601.507E960F6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=829384f46dedee8646cc6b098ef98463658c51d6
Commit:        829384f46dedee8646cc6b098ef98463658c51d6
Parent:        e96041e18fa5f8f0ccb50d31ee0b1c9fb6c5db21
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 12 12:51:35 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 12 15:35:45 2015 -0500

config: description updates

Make the first line of every description a complete one
line sentence for the benefit of lvmconfig --withsummary.
---
 lib/config/config_settings.h |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 54a50ab..b687c57 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -122,8 +122,7 @@ cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0), 0
 	"How LVM uses block devices.\n")
 
 cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77), 0, NULL,
-	"How LVM selects free space for Logical Volumes and default\n"
-	"properties applied to new Logical Volumes of various types.\n")
+	"How LVM selects space and applies properties to LVs.\n")
 
 cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"How LVM log information is reported.\n")
@@ -811,11 +810,11 @@ cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECT
 	"The '--type snapshot|thin' option overrides this setting.\n")
 
 cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL, 0, NULL,
+	"Enable this to reinstate the previous lvdisplay name format.\n"
 	"The default format for displaying LV names in lvdisplay was changed\n"
 	"in version 2.02.89 to show the LV name and path separately.\n"
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
-	"was never a valid path in the /dev filesystem.\n"
-	"Enable this option to reinstate the previous format.\n")
+	"was never a valid path in the /dev filesystem.\n")
 
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), "@DEFAULT_USE_LVMETAD@", 0, NULL,
 	"Use lvmetad to cache metadata and reduce disk scanning.\n"
@@ -1264,7 +1263,7 @@ cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE
 	"The '--ignoremonitoring' option overrides this setting.\n")
 
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL, 0, NULL,
-	"Check pvmove or lvconvert progress at this interval (seconds)\n"
+	"Check pvmove or lvconvert progress at this interval (seconds).\n"
 	"When pvmove or lvconvert must wait for the kernel to finish\n"
 	"synchronising or merging data, they check and report progress\n"
 	"at intervals of this number of seconds.\n"


