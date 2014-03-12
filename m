From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Mar 2014 14:20:34 +0000 (UTC)
Subject: master - config: mark global/thin_disabled_features as having no default value
Message-ID: <20140312142034.4DB5861038@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b995f06abfcd03cb4d7a3c7ebc01bd416abdc0a8
Commit:        b995f06abfcd03cb4d7a3c7ebc01bd416abdc0a8
Parent:        a2c64e21fd1c32205eb2aff554459a5a6db0aac4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 12 15:17:52 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 12 15:17:52 2014 +0100

config: mark global/thin_disabled_features as having no default value

The global/thin_disabled_features should be marked as having no default
value. Otherwise the output from 'lvm dumpconfig --type default' would
have 'thin_disabled_features=""' which will produce an error message
'Ignoring empty string in config file ...' if such output is feed
back to lvm.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e631de6..e2a5c0c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -176,7 +176,7 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL)
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), NULL)
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTIONS, vsn(2, 2, 96), NULL)
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL)
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL)
 cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), NULL)
 cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), NULL)
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL)


