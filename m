From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Jul 2016 17:38:41 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160728173841.9B36160C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f47e79a88ff73182825b7b07c29b4775c4698c4
Commit:        6f47e79a88ff73182825b7b07c29b4775c4698c4
Parent:        a579ba2ac27d9651165e7e997a5ff855dc83c170
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 28 18:35:32 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 28 18:36:45 2016 +0100

pre-release

---
 VERSION                      |    2 +-
 VERSION_DM                   |    2 +-
 WHATS_NEW                    |    7 ++++++-
 WHATS_NEW_DM                 |    2 +-
 conf/example.conf.in         |    1 +
 lib/config/config_settings.h |    3 ++-
 tools/lvcreate.c             |    5 +++++
 7 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/VERSION b/VERSION
index 297fa86..297b796 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.162(2)-git (2016-07-15)
+2.02.162(2)-git (2016-07-28)
diff --git a/VERSION_DM b/VERSION_DM
index 79d0cc5..f59b94f 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.132-git (2016-07-15)
+1.02.132-git (2016-07-28)
diff --git a/WHATS_NEW b/WHATS_NEW
index 25d3b83..409a8ab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.162 - 
+Version 2.02.162 - 28th July 2016
 =================================
+  Extend vg_validate also to check raid configurations thoroughly.
   Support lvconvert -Zn also when doing full cache pool conversion.
   Suppress not zeroing warn when converting to thin LV for non-zeroing tpool.
   Fix automatic updates of PV extension headers to newest version.
@@ -7,7 +8,11 @@ Version 2.02.162 -
   Add note about lastlog built-in command to lvm man page.
   Fix unrecognised segtype flag message.
   lvconvert not clears cache pool metadata ONLY with -Zn.
+  Add allocation/raid_stripe_all_devices to reinstate previous behaviour.
+  Create raid stripes across fixed small numbers of PVs instead of all PVs.
   Enabled lvconvert --uncache to work with partial VG.
+  Disallow lvconvert --replace with raid0* LVs.
+  Fix some lvmetad changed VG metadata notifications that sent uncommitted data.
 
 Version 2.02.161 - 15th July 2016
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 00f897a..c8ee4ae 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.132 - 
+Version 1.02.132 - 28th July 2016
 =================================
   Fix json reporting to escape '"' character that may appear in reported string.
 
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4ac09e2..b98a19f 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -381,6 +381,7 @@ allocation {
 	# Stripe across all PVs when RAID stripes are not specified.
 	# If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10
 	# when the command does not specify the number of stripes to use.
+	# This was the default behaviour until release 2.02.162.
 	# This configuration option has an automatic default value.
 	# raid_stripe_all_devices = 0
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1e4b689..9c46667 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -464,7 +464,8 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES, vsn(2, 2, 162), NULL, 0, NULL,
 	"Stripe across all PVs when RAID stripes are not specified.\n"
 	"If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10\n"
-	"when the command does not specify the number of stripes to use.\n")
+	"when the command does not specify the number of stripes to use.\n"
+	"This was the default behaviour until release 2.02.162.\n")
 
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 1ed39e2..5e3ddbb 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -572,6 +572,11 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/*
+	 * FIXME This is working around a bug in get_stripe_params() where 
+	 * stripes is incorrectly assumed to be 1 when it is not supplied
+	 * leading to the actual value of stripesize getting lost.
+	 */
 	if (arg_is_set(cmd, stripesize_ARG))
 		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 


