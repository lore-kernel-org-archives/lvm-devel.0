From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 15 May 2015 19:27:31 +0000 (UTC)
Subject: master - config: remove UNDEFINED from cache_pool_cachemode
Message-ID: <20150515192731.2F8A260E60@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=463c86008ba9cbadedc42b022bd5e5247b774513
Commit:        463c86008ba9cbadedc42b022bd5e5247b774513
Parent:        850606e9fa4f462adce3699172f6b4af6c29b86b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 15 14:24:23 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 15 14:24:23 2015 -0500

config: remove UNDEFINED from cache_pool_cachemode

Replace UNDEFINED with COMMENTED because the code
requires a value to be returned from the config.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d7404ac..a06b3e6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -460,7 +460,7 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
-cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL, 0, NULL,
+cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL, 0, NULL,
 	"The default cache mode used for new cache pools.\n"
 	"Possible options are: writethrough, writeback.\n"
 	"writethrough - Data blocks are immediately written from\n"


