From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 May 2017 10:57:28 -0400
Subject: master - config: keep description lines under 80
Message-ID: <201705121457.v4CEvSVX025367@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dfc58c637b4e7fe48c28c73cd53eb62611b9309a
Commit:        dfc58c637b4e7fe48c28c73cd53eb62611b9309a
Parent:        2583732165b72d616dc1c08cb7e9bc74fb5a6e6d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 12 09:55:16 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 12 09:55:16 2017 -0500

config: keep description lines under 80

As far as possible, it's nice to keep the config
description lines from going over 80 columns.
---
 lib/config/config_settings.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3b0eebb..40b64ab 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -469,8 +469,9 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 
 cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES, vsn(2, 2, 162), NULL, 0, NULL,
 	"Stripe across all PVs when RAID stripes are not specified.\n"
-	"If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10\n"
-	"when the command does not specify the number of stripes to use.\n"
+	"If enabled, all PVs in the VG or on the command line are used for\n"
+	"raid0/4/5/6/10 when the command does not specify the number of\n"
+	"stripes to use.\n"
 	"This was the default behaviour until release 2.02.162.\n")
 
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
@@ -934,7 +935,7 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"devices/global_filter.\n")
 
 cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMETAD_UPDATE_WAIT_TIME, vsn(2, 2, 151), NULL, 0, NULL,
-	"The number of seconds a command will wait for lvmetad update to finish.\n"
+	"Number of seconds a command will wait for lvmetad update to finish.\n"
 	"After waiting for this period, a command will not use lvmetad, and\n"
 	"will revert to disk scanning.\n")
 


