From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Mar 2014 14:57:29 +0000 (UTC)
Subject: master - config: accept empty values for global/thin_disabled_features
Message-ID: <20140312145729.D71EE60D86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf42119b22731c97e8169ee8526ff6bda4a3d7bf
Commit:        bf42119b22731c97e8169ee8526ff6bda4a3d7bf
Parent:        b995f06abfcd03cb4d7a3c7ebc01bd416abdc0a8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 12 15:53:20 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 12 15:53:20 2014 +0100

config: accept empty values for global/thin_disabled_features

Let's do this the other way round - this makes more logic than commit b995f06.
So let's allow empty values for global/thin_disabled_features where
such an empty value now means "none of this features are disabled".
---
 WHATS_NEW                    |    1 +
 lib/config/config_settings.h |    2 +-
 lib/thin/thin.c              |    5 +----
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 21413aa..c625e5d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Don't print an error and accept empty value for global/thin_disabled_features.
   Update API for internal function build_dm_uuid().
   Do not try to check empty pool with scheduled messages.
   Fix return value in pool_has_message() when quering for any message.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e2a5c0c..f033660 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -176,7 +176,7 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL)
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), NULL)
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTIONS, vsn(2, 2, 96), NULL)
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL)
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL)
 cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), NULL)
 cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), NULL)
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL)
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 494fa92..ff4eafd 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -676,11 +676,8 @@ static int _thin_target_present(struct cmd_context *cmd,
 						continue;
 					}
 					str = cv->v.str;
-					if (!*str) {
-						log_error("Ignoring empty string in config file %s.",
-							  _lvmconf);
+					if (!*str)
 						continue;
-					}
 					for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
 						if (strcasecmp(str, _features[i].feature) == 0)
 							_feature_mask |= _features[i].thin_feature;


