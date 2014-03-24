From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Mar 2014 15:34:27 +0000 (UTC)
Subject: master - config: define default value for global/thin_disabled_features as NULL instead
Message-ID: <20140324153427.4CAB360B61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9446978e642c8f580386aa0279910553ab540fad
Commit:        9446978e642c8f580386aa0279910553ab540fad
Parent:        4e47c34ffc6f1c7750b21074b733cf6356002c11
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 24 16:31:27 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 24 16:31:27 2014 +0100

config: define default value for global/thin_disabled_features as NULL instead

Before:
  thin_disabled_features = ""
Now:
  thin_disabled_features = []

Which is a more correct and consistent way of specifying void array
though parses can handle both forms.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6fcf1a7..dce77b9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -176,7 +176,7 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL)
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), NULL)
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTIONS, vsn(2, 2, 96), NULL)
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL)
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL)
 cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), NULL)
 cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), NULL)
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL)


