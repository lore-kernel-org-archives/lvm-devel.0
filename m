From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 14 Sep 2018 08:08:10 -0400
Subject: master - build: Update configure
Message-ID: <201809141208.w8EC8ALl003958@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c00af776a27875ee5ffbf3ab2d3b73495ce8c52
Commit:        0c00af776a27875ee5ffbf3ab2d3b73495ce8c52
Parent:        ccb08dfa1d6828c494882030ef181d7fdf38cb0b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 14 13:53:29 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Sep 14 13:53:29 2018 +0200

build: Update configure

---
 configure              |    6 +++---
 include/configure.h.in |    9 ---------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/configure b/configure
index d6ddbc2..3e1d5d7 100755
--- a/configure
+++ b/configure
@@ -13769,7 +13769,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/blkdeactiva
 te.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/blkdeactiva
 te.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvmlockd.service scripts/lvmlocks.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14513,10 +14513,10 @@ do
     "scripts/lvm2_lvmpolld_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_init_red_hat" ;;
     "scripts/lvm2_lvmpolld_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmpolld_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.socket" ;;
-    "scripts/lvm2_lvmlockd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmlockd_systemd_red_hat.service" ;;
+    "scripts/lvmlockd.service") CONFIG_FILES="$CONFIG_FILES scripts/lvmlockd.service" ;;
+    "scripts/lvmlocks.service") CONFIG_FILES="$CONFIG_FILES scripts/lvmlocks.service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
-    "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat@.service" ;;
     "scripts/lvm2_tmpfiles_red_hat.conf") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_tmpfiles_red_hat.conf" ;;
     "scripts/lvmdump.sh") CONFIG_FILES="$CONFIG_FILES scripts/lvmdump.sh" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
diff --git a/include/configure.h.in b/include/configure.h.in
index f68b092..3721844 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -90,9 +90,6 @@
 /* Use blkid wiping by default. */
 #undef DEFAULT_USE_BLKID_WIPING
 
-/* Use lvmetad by default. */
-#undef DEFAULT_USE_LVMETAD
-
 /* Use lvmlockd by default. */
 #undef DEFAULT_USE_LVMLOCKD
 
@@ -550,12 +547,6 @@
 /* Path to lvmconfig binary. */
 #undef LVMCONFIG_PATH
 
-/* Path to lvmetad pidfile. */
-#undef LVMETAD_PIDFILE
-
-/* Define to 1 to include code that uses lvmetad. */
-#undef LVMETAD_SUPPORT
-
 /* Path to lvmlockd pidfile. */
 #undef LVMLOCKD_PIDFILE
 


