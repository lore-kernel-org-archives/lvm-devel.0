From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:27:52 +0000 (UTC)
Subject: master - configure: corrected ioctl option
Message-ID: <20140430082752.DC97B60EB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad77fb50bd568718b12336ca0f0c81e3730b6237
Commit:        ad77fb50bd568718b12336ca0f0c81e3730b6237
Parent:        517b0026481d29d31524e472efbdc99e945c9c12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 12:44:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:28 2014 +0200

configure: corrected ioctl option

The correct name for disable ioctl option is --disable-ioctl
(--disable-driver never worked)
Also sort scripts generated files alphabetically.
---
 configure    |   16 ++++++++--------
 configure.in |   16 ++++++++--------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/configure b/configure
index bc8abd9..de93e77 100755
--- a/configure
+++ b/configure
@@ -1610,7 +1610,7 @@ Optional Features:
   --enable-compat         enable support for old device-mapper versions
   --enable-units-compat   enable output compatibility with old versions that
                           that do not use KiB-style unit suffixes
-  --disable-driver        disable calls to device-mapper in the kernel
+  --disable-ioctl         disable ioctl calls to device-mapper in the kernel
   --disable-o_direct      disable O_DIRECT
   --enable-applib         build application library
   --enable-cmdlib         build shared command library
@@ -11542,7 +11542,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12281,20 +12281,20 @@ do
     "scripts/blkdeactivate.sh") CONFIG_FILES="$CONFIG_FILES scripts/blkdeactivate.sh" ;;
     "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
+    "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
+    "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
+    "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
+    "scripts/dm_event_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.socket" ;;
     "scripts/lvm2_cluster_activation_red_hat.sh") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_red_hat.sh" ;;
     "scripts/lvm2_cluster_activation_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_systemd_red_hat.service" ;;
-    "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/lvm2_clvmd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_clvmd_systemd_red_hat.service" ;;
-    "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_cmirrord_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cmirrord_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
-    "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
-    "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat at .service" ;;
+    "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
-    "scripts/dm_event_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.socket" ;;
-    "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
+    "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat at .service" ;;
     "scripts/lvm2_tmpfiles_red_hat.conf") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_tmpfiles_red_hat.conf" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
diff --git a/configure.in b/configure.in
index 3a6dc15..e3ddde1 100644
--- a/configure.in
+++ b/configure.in
@@ -1126,8 +1126,8 @@ fi
 ################################################################################
 dnl -- Disable ioctl
 AC_ARG_ENABLE(ioctl,
-	      AC_HELP_STRING([--disable-driver],
-			     [disable calls to device-mapper in the kernel]),
+	      AC_HELP_STRING([--disable-ioctl],
+			     [disable ioctl calls to device-mapper in the kernel]),
 	      DM_IOCTLS=$enableval)
 
 ################################################################################
@@ -1813,20 +1813,20 @@ python/setup.py
 scripts/blkdeactivate.sh
 scripts/blk_availability_init_red_hat
 scripts/blk_availability_systemd_red_hat.service
+scripts/clvmd_init_red_hat
+scripts/cmirrord_init_red_hat
+scripts/dm_event_systemd_red_hat.service
+scripts/dm_event_systemd_red_hat.socket
 scripts/lvm2_cluster_activation_red_hat.sh
 scripts/lvm2_cluster_activation_systemd_red_hat.service
-scripts/clvmd_init_red_hat
 scripts/lvm2_clvmd_systemd_red_hat.service
-scripts/cmirrord_init_red_hat
 scripts/lvm2_cmirrord_systemd_red_hat.service
 scripts/lvm2_lvmetad_init_red_hat
-scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmetad_systemd_red_hat.service
-scripts/lvm2_pvscan_systemd_red_hat at .service
+scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_monitoring_init_red_hat
-scripts/dm_event_systemd_red_hat.socket
-scripts/dm_event_systemd_red_hat.service
 scripts/lvm2_monitoring_systemd_red_hat.service
+scripts/lvm2_pvscan_systemd_red_hat@.service
 scripts/lvm2_tmpfiles_red_hat.conf
 scripts/Makefile
 test/Makefile


