From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Mar 2014 08:50:03 +0000 (UTC)
Subject: master - config: make global/lvdisplay_shows_full_device_path profilable
Message-ID: <20140318085003.41A0A6113C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21b3c983fddac7e1365b4929dc02ddf04cf817bc
Commit:        21b3c983fddac7e1365b4929dc02ddf04cf817bc
Parent:        3a6bc7fc65ea57e84fb8705cb24f024b2d8302ed
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 18 09:49:53 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 18 09:49:53 2014 +0100

config: make global/lvdisplay_shows_full_device_path profilable

---
 WHATS_NEW                    |    1 +
 conf/default.profile.in      |    1 +
 lib/config/config_settings.h |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index de5dc0d..a20331b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Make global/lvdisplay_shows_full_device_path lvm.conf setting profilable.
   Make global/{units|si_unit_consistency|suffix} lvm.conf setting profilable.
   Validate minimal chunk size for snapshot COW volume in lvconvert.
   Disallow lvconvert of origin to snapshot COW volume.
diff --git a/conf/default.profile.in b/conf/default.profile.in
index 72396e5..527edb2 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -24,6 +24,7 @@ global {
 	units="h"
 	si_unit_consistency=1
 	suffix=1
+	lvdisplay_shows_full_device_path=0
 }
 
 report {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 72f99d5..6fcf1a7 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -172,7 +172,7 @@ cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_co
 cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL)
 cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), NULL)
 cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), NULL)
-cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL)
+cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL)
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL)
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), NULL)
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTIONS, vsn(2, 2, 96), NULL)


