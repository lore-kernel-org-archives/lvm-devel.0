From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Dec 2013 09:37:13 +0000 (UTC)
Subject: master - config: shorten new sig wiping option string
Message-ID: <20131209093713.26EE7610F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16eab3ec08e72bb3fb58dd2af4bfec786315919a
Commit:        16eab3ec08e72bb3fb58dd2af4bfec786315919a
Parent:        2b3adf4eea7cba080ff907012715aac66bf807a3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 9 09:35:47 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 9 09:35:47 2013 +0000

config: shorten new sig wiping option string

Rename wipe_signatures_on_new_logical_volumes_when_zeroing  to
wipe_signatures_when_zeroing_new_lvs.
---
 WHATS_NEW                               |    2 +-
 conf/example.conf.in                    |   14 +++++++-------
 lib/config/config_settings.h            |    2 +-
 man/lvcreate.8.in                       |    2 +-
 test/lib/aux.sh                         |    2 +-
 test/shell/lvcreate-signature-wiping.sh |    4 ++--
 tools/lvcreate.c                        |    4 ++--
 7 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 72a61e3..633f4d8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -23,7 +23,7 @@ Version 2.02.105 -
   Enable blkid_wiping by default if the blkid library is present.
   Add configure --disable-blkid_wiping to disable libblkid signature detection.
   Add -W/--wipesignatures lvcreate option to support wiping on new LVs.
-  Add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing to lvm.conf.
+  Add allocation/wipe_signatures_when_zeroing_new_lvs to lvm.conf.
   Do not fail the whole autoactivation if the VG refresh done before fails.
   Do not connect to lvmetad on vg/lvchange --sysinit -aay and socket absent.
   Use lv_check_not_in_use() when testing device in use before merging.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index b7ad3d1..dcbc0b3 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -287,14 +287,14 @@ allocation {
     # to be recognized, it can take more time to complete the signature scan.
     use_blkid_wiping = 1
 
-    # Whether do wipe any signatures found on newly created Logical Volumes
-    # automatically in addition to zeroing of the first KB on the LV
-    # (-Z/--zero y option) when running the LVM command without specifying
-    # the -W/--wipesignatures option. If -W/--wipesignatures command line
-    # option is specified, it always takes precedence over this setting.
-    # Default is to wipe signatures when zeroing.
+    # Set to 1 when use_blkid_wiping is enabled to wipe any signatures found on
+    # newly-created Logical Volumes automatically in addition to zeroing of the
+    # first KB on the LV (controlled by the -Z/--zero y option).
+    # The command line option -W/--wipesignatures n takes precedence over this
+    # setting.
+    # The default is to wipe signatures when zeroing.
     #
-    wipe_signatures_on_new_logical_volumes_when_zeroing = 1
+    wipe_signatures_when_zeroing_new_lvs = 1
 
     # Set to 1 to guarantee that mirror logs will always be placed on 
     # different PVs from the mirror images.  This was the default
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 929e907..0e0e469 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -105,7 +105,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL)
 cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL)
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
-cfg(allocation_wipe_signatures_on_new_logical_volumes_when_zeroing_CFG, "wipe_signatures_on_new_logical_volumes_when_zeroing", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
+cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index a34c4ae..08cc15c 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -405,7 +405,7 @@ device sizes (GiB), thin provisioning should be used for this case.
 Controls wiping of detected signatures on newly created Logical Volume.
 If this option is not specified, then by default signature wiping is done
 each time the zeroing (\fB\-Z\fP/\fB\-\-zero\fP) is done. This default behaviour
-can be controlled by \fBallocation/wipe_signatures_on_new_logical_volumes_when_zeroing\fP
+can be controlled by \fBallocation/wipe_signatures_when_zeroing_new_lvs\fP
 setting found in \fBlvm.conf\fP(5).
 .br
 If blkid wiping is used (\fBallocation/use_blkid_wiping setting\fP in \fBlvm.conf\fP(5))
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d1ae524..2256fce 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -563,7 +563,7 @@ activation/polling_interval = 0
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50
 activation/monitoring = 0
-allocation/wipe_signatures_on_new_logical_volumes_when_zeroing = 0
+allocation/wipe_signatures_when_zeroing_new_lvs = 0
 EOF
 	}
 
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 617fed1..5618780 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -27,7 +27,7 @@ lvremove -f $vg/$lv1
 
 wiping_msg="Wiping swap signature"
 
-aux lvmconf "allocation/wipe_signatures_on_new_logical_volumes_when_zeroing = 0"
+aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 0"
 
 lvcreate -y -Zn -l1 -n $lv1 $vg | not grep "$wiping_msg"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
@@ -59,7 +59,7 @@ blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
 lvremove -f $vg/$lv1
 
 
-aux lvmconf "allocation/wipe_signatures_on_new_logical_volumes_when_zeroing = 1"
+aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 1"
 
 lvcreate -y -Zn -l1 -n $lv1 $vg | not grep "$wiping_msg"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 1fe5130..d0ca7bc 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -883,10 +883,10 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	} else {
 		/*
 		 * If -W/--wipesignatures is not given on command line,
-		 * look at the allocation/wipe_signatures_on_new_logical_volumes_when_zeroing
+		 * look at the allocation/wipe_signatures_when_zeroing_new_lvs
 		 * to decide what should be done exactly.
 		 */
-		if (find_config_tree_bool(cmd, allocation_wipe_signatures_on_new_logical_volumes_when_zeroing_CFG, NULL))
+		if (find_config_tree_bool(cmd, allocation_wipe_signatures_when_zeroing_new_lvs_CFG, NULL))
 			lp->wipe_signatures = lp->zero;
 		else
 			lp->wipe_signatures = 0;


