From: David Teigland <teigland@sourceware.org>
Date: Wed, 7 Aug 2019 12:36:26 -0400
Subject: master - Revert "config: cache_policy should be cfg_runtime"
Message-ID: <201908071636.x77GaQmj020685@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bec3088f85a9a2d0b6a355aea1adc67fab8de6e9
Commit:        bec3088f85a9a2d0b6a355aea1adc67fab8de6e9
Parent:        29eee32ac2fb3879eea04a8499219106411b4a37
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 7 11:35:45 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 7 11:35:45 2019 -0500

Revert "config: cache_policy should be cfg_runtime"

This reverts commit 29eee32ac2fb3879eea04a8499219106411b4a37.

Some other changes are needed to make this runtime.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7034759..2bb72ba 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -596,7 +596,7 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILA
 	"#\n"
 	"This setting replaces allocation/cache_pool_cachemode.\n")
 
-cfg_runtime(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
+cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache policy used for new cache volume.\n"
 	"Since kernel 4.2 the default policy is smq (Stochastic multiqueue),\n"
 	"otherwise the older mq (Multiqueue) policy is selected.\n")


