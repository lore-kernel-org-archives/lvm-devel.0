From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 07:10:53 -0500
Subject: master - configure: update
Message-ID: <201811301210.wAUCArVU014578@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46f946145c7cf7b56b6414055fd6f50c0bbef702
Commit:        46f946145c7cf7b56b6414055fd6f50c0bbef702
Parent:        41afe8c5cc7cde890a031ccac1cff0bf9d72220d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 13:02:42 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 30 13:03:09 2018 +0100

configure: update

---
 configure |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/configure b/configure
index 496741f..efd438c 100755
--- a/configure
+++ b/configure
@@ -728,7 +728,6 @@ DEFAULT_PID_DIR
 DEFAULT_MIRROR_SEGTYPE
 DEFAULT_LOCK_DIR
 DEFAULT_DM_RUN_DIR
-DEFAULT_DATA_ALIGNMENT
 DEFAULT_CACHE_SUBDIR
 DEFAULT_BACKUP_SUBDIR
 DEFAULT_ARCHIVE_SUBDIR
@@ -974,7 +973,6 @@ with_default_archive_subdir
 with_default_backup_subdir
 with_default_cache_subdir
 with_default_locking_dir
-with_default_data_alignment
 with_interface
 '
       ac_precious_vars='build_alias
@@ -1754,8 +1752,6 @@ Optional Packages:
                           default metadata cache subdir [cache]
   --with-default-locking-dir=DIR
                           default locking directory [autodetect_lock_dir/lvm]
-  --with-default-data-alignment=NUM
-                          set the default data alignment in MiB [1]
   --with-interface=IFACE  choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
@@ -13591,21 +13587,6 @@ _ACEOF
 
 
 ################################################################################
-
-# Check whether --with-default-data-alignment was given.
-if test "${with_default_data_alignment+set}" = set; then :
-  withval=$with_default_data_alignment; DEFAULT_DATA_ALIGNMENT=$withval
-else
-  DEFAULT_DATA_ALIGNMENT=1
-fi
-
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_DATA_ALIGNMENT $DEFAULT_DATA_ALIGNMENT
-_ACEOF
-
-
-################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for kernel interface choice" >&5
 $as_echo_n "checking for kernel interface choice... " >&6; }
 
@@ -13797,9 +13778,8 @@ _ACEOF
 
 
 
-
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/blkdeactiva
 te.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvmlockd.service scripts/lvmlocks.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/lvm2-pvscan
 .service scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvmlockd.service scripts/lvmlocks.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14531,6 +14511,7 @@ do
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
+    "scripts/lvm2-pvscan.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2-pvscan.service" ;;
     "scripts/blkdeactivate.sh") CONFIG_FILES="$CONFIG_FILES scripts/blkdeactivate.sh" ;;
     "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;


