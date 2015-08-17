From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 17 Aug 2015 16:30:03 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150817163003.047B560B42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be1db6b6c17226894233f7d9629117b0cd554b88
Commit:        be1db6b6c17226894233f7d9629117b0cd554b88
Parent:        4227b2ebb453410f00c0780d2d3a86b4dac4da24
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 17 17:20:14 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 17 17:20:14 2015 +0100

pre-release

---
 VERSION                             |    2 +-
 VERSION_DM                          |    2 +-
 WHATS_NEW                           |    2 +-
 WHATS_NEW_DM                        |    2 +-
 lib/config/config_settings.h        |    4 ++--
 libdm/.exported_symbols.DM_1_02_104 |    1 -
 libdm/.exported_symbols.DM_1_02_105 |    1 +
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index c2c0786..1f01f85 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.128(2)-git (2015-08-10)
+2.02.128(2)-git (2015-08-17)
diff --git a/VERSION_DM b/VERSION_DM
index 3f8be7a..c8c6485 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.105-git (2015-08-10)
+1.02.105-git (2015-08-17)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8e6ca10..a65fd7b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.128 - 
+Version 2.02.128 - 17th August 2015
 ===================================
   Allocation setting cache_pool_cachemode is replaced by cache_mode.
   Don't attempt to close config file that couldn't be opened.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 870ffb2..32b333b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.105 - 
+Version 1.02.105 - 17th August 2015
 ===================================
   Fix 'dmstats list -o all' segfault.
   Separate dmstats statistics fields from region information fields.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 399f748..789e2e2 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -485,7 +485,7 @@ cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_
 	"Individual settings for policies.\n"
 	"See the help for individual policies for more info.\n")
 
-cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_settings_CFG_SECTION, CFG_NAME_VARIABLE | CFG_SECTION_NO_CHECK | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 127), 0, NULL,
+cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_settings_CFG_SECTION, CFG_NAME_VARIABLE | CFG_SECTION_NO_CHECK | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
 	"Replace this subsection name with a policy name.\n"
 	"Multiple subsections for different policies can be created.\n")
 
@@ -910,7 +910,7 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 	"Example:\n"
 	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n")
 
-cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 126), NULL, 0, NULL,
+cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 128), NULL, 0, NULL,
 	"Features to not use in the cache driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 411ab2a..712fcf2 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -72,7 +72,6 @@ dm_task_get_ioctl_timestamp
 dm_task_set_record_timestamp
 dm_timestamp_alloc
 dm_timestamp_compare
-dm_timestamp_copy
 dm_timestamp_delta
 dm_timestamp_destroy
 dm_timestamp_get
diff --git a/libdm/.exported_symbols.DM_1_02_105 b/libdm/.exported_symbols.DM_1_02_105
index 4707164..b1556fa 100644
--- a/libdm/.exported_symbols.DM_1_02_105
+++ b/libdm/.exported_symbols.DM_1_02_105
@@ -1,3 +1,4 @@
 dm_report_is_empty
 dm_stats_get_area_offset
 dm_stats_get_current_area_offset
+dm_timestamp_copy


