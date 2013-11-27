From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 14:52:37 +0000 (UTC)
Subject: master - conf: add allocation/use_blkid_wiping
Message-ID: <20131127145237.E935661046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab2f858af7a72448b6c015a5984c73f5cdaf3664
Commit:        ab2f858af7a72448b6c015a5984c73f5cdaf3664
Parent:        9bfc0be493192958f5dbffea4eb7dda968062261
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 13:52:15 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 15:49:14 2013 +0100

conf: add allocation/use_blkid_wiping

Add allocation/use_blkid_wiping setting to lvm.conf to select between
LVM2 native code to detect signatures to wipe or blkid library code.
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   15 +++++++++++++++
 lib/config/config_settings.h |    1 +
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9823cd1..55b17c0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add allocation/use_blkid_wiping to lvm.conf to enable blkid wiping.
   Add configure --enable-blkid_wiping to use libblkid to detect signatures.
   Add -W/--wipesignatures lvcreate option to support wiping on new LVs.
   Add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing to lvm.conf.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0ac53ef..b7ad3d1 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -272,6 +272,21 @@ allocation {
     # algorithm.
     maximise_cling = 1
 
+    # Whether to use blkid library instead of native LVM2 code to detect
+    # any existing signatures while creating new Physical Volumes and
+    # Logical Volumes. LVM2 needs to be compiled with blkid wiping support
+    # for this setting to take effect.
+    #
+    # LVM2 native detection code is currently able to recognize these signatures:
+    #   - MD device signature
+    #   - swap signature
+    #   - LUKS signature
+    # To see the list of signatures recognized by blkid, check the output
+    # of 'blkid -k' command. The blkid can recognize more signatures than
+    # LVM2 native detection code, but due to this higher number of signatures
+    # to be recognized, it can take more time to complete the signature scan.
+    use_blkid_wiping = 1
+
     # Whether do wipe any signatures found on newly created Logical Volumes
     # automatically in addition to zeroing of the first KB on the LV
     # (-Z/--zero y option) when running the LVM command without specifying
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7a7e8e5..929e907 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -104,6 +104,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL)
 cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL)
+cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_wipe_signatures_on_new_logical_volumes_when_zeroing_CFG, "wipe_signatures_on_new_logical_volumes_when_zeroing", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)


