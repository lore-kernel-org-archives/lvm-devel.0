From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Jul 2016 14:39:13 +0000 (UTC)
Subject: master - config: keep new setting commented out
Message-ID: <20160728143913.1E1F560C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=edb5d12463b60b22ba6683cd9e2fd12b07f09fcf
Commit:        edb5d12463b60b22ba6683cd9e2fd12b07f09fcf
Parent:        43f455589377cb5e3b21434a58226a7365fe1d6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 28 15:08:11 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 28 15:08:11 2016 +0200

config: keep new setting commented out

---
 conf/example.conf.in         |    3 ++-
 lib/config/config_settings.h |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 1dcbf52..4ac09e2 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -381,7 +381,8 @@ allocation {
 	# Stripe across all PVs when RAID stripes are not specified.
 	# If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10
 	# when the command does not specify the number of stripes to use.
-	raid_stripe_all_devices = 0
+	# This configuration option has an automatic default value.
+	# raid_stripe_all_devices = 0
 
 	# Configuration option allocation/cache_pool_metadata_require_separate_pvs.
 	# Cache pool metadata and data will always use different PVs.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8b9932e..1e4b689 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -461,7 +461,7 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 	"Mirror logs and images will always use different PVs.\n"
 	"The default setting changed in version 2.02.85.\n")
 
-cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES, vsn(2, 2, 162), NULL, 0, NULL,
+cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES, vsn(2, 2, 162), NULL, 0, NULL,
 	"Stripe across all PVs when RAID stripes are not specified.\n"
 	"If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10\n"
 	"when the command does not specify the number of stripes to use.\n")


