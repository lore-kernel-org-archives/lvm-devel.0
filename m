From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:27:43 -0400
Subject: master - build: update configure
Message-ID: <201806112027.w5BKRh5G029974@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a307ce33c515268763c714275bd4a85bf9fd0fa
Commit:        2a307ce33c515268763c714275bd4a85bf9fd0fa
Parent:        b48e10d9e6fd33ea26ce5296be44a986f49352a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 22:15:05 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:25:42 2018 +0200

build: update configure

---
 configure |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index 953539f..323ab4a 100755
--- a/configure
+++ b/configure
@@ -11527,7 +11527,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3  python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3  python3.2 python3.1 python3.0  python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1  python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -13611,7 +13611,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile python/Makefile python/setup
 .py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/api/python_lvm_unit.py tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/blkdeactivate.sh scr
 ipts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14343,8 +14343,6 @@ do
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
-    "python/Makefile") CONFIG_FILES="$CONFIG_FILES python/Makefile" ;;
-    "python/setup.py") CONFIG_FILES="$CONFIG_FILES python/setup.py" ;;
     "scripts/blkdeactivate.sh") CONFIG_FILES="$CONFIG_FILES scripts/blkdeactivate.sh" ;;
     "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
@@ -14369,8 +14367,6 @@ do
     "scripts/lvmdump.sh") CONFIG_FILES="$CONFIG_FILES scripts/lvmdump.sh" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
-    "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
-    "test/api/python_lvm_unit.py") CONFIG_FILES="$CONFIG_FILES test/api/python_lvm_unit.py" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
 


