From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 15 May 2015 19:04:16 +0000 (UTC)
Subject: master - config: remove UNDEFINED from thin_pool_discards and thin_pool_zero
Message-ID: <20150515190416.C372960F6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=850606e9fa4f462adce3699172f6b4af6c29b86b
Commit:        850606e9fa4f462adce3699172f6b4af6c29b86b
Parent:        77fa958c1e019cccebf30a92edfec07970e9f927
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 15 14:01:23 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 15 14:03:53 2015 -0500

config: remove UNDEFINED from thin_pool_discards and thin_pool_zero

Replace UNDEFINED with COMMENTED for these two since
undefined seems to break things.
---
 lib/config/config_settings.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 4e1c126..d7404ac 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -483,11 +483,11 @@ cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", alloc
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metdata and data will always use different PVs.\n")
 
-cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
+cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
 	"Thin pool data chunks are zeroed before they are first used.\n"
 	"Zeroing with a larger thin pool chunk size reduces performance.\n")
 
-cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL, 0, NULL,
+cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL, 0, NULL,
 	"The discards behaviour of thin pool volumes.\n"
 	"Possible options are: ignore, nopassdown, passdown.\n")
 


