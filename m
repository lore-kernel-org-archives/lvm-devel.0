From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 31 Jan 2014 23:11:32 +0000 (UTC)
Subject: master - misc: Fix copy+paste error
Message-ID: <20140131231132.0617C60CDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=131383963ff7cc9b101b9a80a8e495473ccec4cf
Commit:        131383963ff7cc9b101b9a80a8e495473ccec4cf
Parent:        4aa8a14fc25e088ff49b6960ce99633b1a6978b3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Jan 31 17:09:47 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Jan 31 17:09:47 2014 -0600

misc: Fix copy+paste error

'cache_pool_metadata_require_separate_pvs' was added in version 2.02.106
not 2.02.89.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2c6953b..e9ae494 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -107,7 +107,7 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
-cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
+cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)


