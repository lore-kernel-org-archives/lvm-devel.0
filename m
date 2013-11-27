From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 14:52:29 +0000 (UTC)
Subject: master - conf: add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing
Message-ID: <20131127145229.9E40861046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b7e543cae5be52e1dcd79c7f6876acc89138cf1
Commit:        5b7e543cae5be52e1dcd79c7f6876acc89138cf1
Parent:        03c941a4caf411f21045670e205ccdd975be27c7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 12:54:48 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 15:48:06 2013 +0100

conf: add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing

This setting controls whether signature wiping on newly created logical
volumes will follow the state of zeroing (-Z/--zero option).
---
 WHATS_NEW                    |    1 +
 conf/default.profile.in      |    1 +
 conf/example.conf.in         |    9 +++++++++
 lib/config/config_settings.h |    1 +
 4 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7718b6f..af489d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing to lvm.conf.
   Do not fail the whole autoactivation if the VG refresh done before fails.
   Do not connect to lvmetad on vg/lvchange --sysinit -aay and socket absent.
   Use lv_check_not_in_use() when testing device in use before merging.
diff --git a/conf/default.profile.in b/conf/default.profile.in
index 29049ef..5a481de 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -9,6 +9,7 @@
 # Refer to 'man lvm.conf' for further information about profiles and file layout.
 
 allocation {
+	wipe_signatures_on_new_logical_volumes_when_zeroing = 1
 	thin_pool_chunk_size_policy = "generic"
 	thin_pool_chunk_size = 64
 	thin_pool_discards = "passdown"
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 03e1c45..0ac53ef 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -272,6 +272,15 @@ allocation {
     # algorithm.
     maximise_cling = 1
 
+    # Whether do wipe any signatures found on newly created Logical Volumes
+    # automatically in addition to zeroing of the first KB on the LV
+    # (-Z/--zero y option) when running the LVM command without specifying
+    # the -W/--wipesignatures option. If -W/--wipesignatures command line
+    # option is specified, it always takes precedence over this setting.
+    # Default is to wipe signatures when zeroing.
+    #
+    wipe_signatures_on_new_logical_volumes_when_zeroing = 1
+
     # Set to 1 to guarantee that mirror logs will always be placed on 
     # different PVs from the mirror images.  This was the default
     # until version 2.02.85.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7fdf763..7a7e8e5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -104,6 +104,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL)
 cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL)
+cfg(allocation_wipe_signatures_on_new_logical_volumes_when_zeroing_CFG, "wipe_signatures_on_new_logical_volumes_when_zeroing", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)


