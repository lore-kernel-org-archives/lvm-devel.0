From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 10:00:04 -0400
Subject: master - build: Remove unused Makefiles from configure.ac
Message-ID: <201804301400.w3UE04Ed002137@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9384b2b5c59e9bca8c2054f76b62155a64c51c38
Commit:        9384b2b5c59e9bca8c2054f76b62155a64c51c38
Parent:        2bc896f2a3a0023a4f45f10da3d0a22295a633ee
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 14:58:45 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 14:58:45 2018 +0100

build: Remove unused Makefiles from configure.ac

Should have been in earlier patch.
---
 configure    |    7 +------
 configure.ac |    5 -----
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/configure b/configure
index 4cd950a..dc372c3 100755
--- a/configure
+++ b/configure
@@ -15689,7 +15689,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache
 _segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/
 lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile l
 ibdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monito
 ring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16416,12 +16416,7 @@ do
     "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
-    "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "include/lvm-version.h") CONFIG_FILES="$CONFIG_FILES include/lvm-version.h" ;;
-    "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
-    "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
-    "lib/thin/Makefile") CONFIG_FILES="$CONFIG_FILES lib/thin/Makefile" ;;
-    "lib/cache_segtype/Makefile") CONFIG_FILES="$CONFIG_FILES lib/cache_segtype/Makefile" ;;
     "libdaemon/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/Makefile" ;;
     "libdaemon/client/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/client/Makefile" ;;
     "libdaemon/server/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/server/Makefile" ;;
diff --git a/configure.ac b/configure.ac
index a7fcd18..edc40c7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -2199,12 +2199,7 @@ lib/Makefile
 lib/format1/Makefile
 lib/format_pool/Makefile
 lib/locking/Makefile
-lib/mirror/Makefile
 include/lvm-version.h
-lib/raid/Makefile
-lib/snapshot/Makefile
-lib/thin/Makefile
-lib/cache_segtype/Makefile
 libdaemon/Makefile
 libdaemon/client/Makefile
 libdaemon/server/Makefile


