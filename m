From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 07:14:07 -0400
Subject: master - build: update ./configure and configure.h.in
Message-ID: <201805011114.w41BE790014269@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61153d90e55309cd6bca9c8d1a1e7a7421464663
Commit:        61153d90e55309cd6bca9c8d1a1e7a7421464663
Parent:        f564e78d98747266c7add85906309f773de42061
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 12:12:07 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 12:12:07 2018 +0100

build: update ./configure and configure.h.in

Fallout from Dave's removal of format1 and pool.
---
 configure              |   93 +-----------------------------------------------
 include/configure.h.in |   14 -------
 2 files changed, 1 insertions(+), 106 deletions(-)

diff --git a/configure b/configure
index f2e946e..844e628 100755
--- a/configure
+++ b/configure
@@ -676,7 +676,6 @@ PYTHON_BINDINGS
 PYTHON3
 PTHREAD_LIBS
 M_LIBS
-POOL
 PKGCONFIG
 ODIRECT
 OCFDIR
@@ -691,8 +690,6 @@ LVM_MINOR
 LVM_MAJOR
 LVM_LIBAPI
 LVM_VERSION
-LVM1_FALLBACK
-LVM1
 LIB_SUFFIX
 LDDEPS
 JOBS
@@ -720,7 +717,6 @@ DEFAULT_RAID10_SEGTYPE
 DEFAULT_PROFILE_SUBDIR
 DEFAULT_PID_DIR
 DEFAULT_MIRROR_SEGTYPE
-DEFAULT_FALLBACK_TO_LVM1
 DEFAULT_LOCK_DIR
 DEFAULT_DM_RUN_DIR
 DEFAULT_DATA_ALIGNMENT
@@ -913,9 +909,6 @@ with_device_gid
 with_device_mode
 with_device_nodes_on
 with_default_name_mangling
-enable_lvm1_fallback
-with_lvm1
-with_pool
 with_cluster
 with_snapshots
 with_mirrors
@@ -1682,8 +1675,6 @@ Optional Features:
                           speeds up one-time build.
   --enable-static_link    use this to link the tools to their libraries
                           statically (default is dynamic linking
-  --enable-lvm1_fallback  use this to fall back and use LVM1 binaries if
-                          device-mapper is missing from the kernel
   --disable-thin_check_needs_check
                           required if thin_check version is < 0.3.0
   --disable-cache_check_needs_check
@@ -1750,10 +1741,6 @@ Optional Packages:
                           create nodes on resume or create [ON=resume]
   --with-default-name-mangling=MANGLING
                           default name mangling: auto/none/hex [auto]
-  --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
-                          [internal]
-  --with-pool=TYPE        GFS pool read-only support: internal/shared/none
-                          [internal]
   --with-cluster=TYPE     cluster LVM locking support: internal/shared/none
                           [internal]
   --with-snapshots=TYPE   snapshot support: internal/shared/none [internal]
@@ -8388,78 +8375,6 @@ _ACEOF
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable lvm1 fallback" >&5
-$as_echo_n "checking whether to enable lvm1 fallback... " >&6; }
-# Check whether --enable-lvm1_fallback was given.
-if test "${enable_lvm1_fallback+set}" = set; then :
-  enableval=$enable_lvm1_fallback; LVM1_FALLBACK=$enableval
-else
-  LVM1_FALLBACK=no
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVM1_FALLBACK" >&5
-$as_echo "$LVM1_FALLBACK" >&6; }
-
-if test "$LVM1_FALLBACK" = yes; then
-	DEFAULT_FALLBACK_TO_LVM1=1
-
-$as_echo "#define LVM1_FALLBACK 1" >>confdefs.h
-
-else
-	DEFAULT_FALLBACK_TO_LVM1=0
-fi
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_FALLBACK_TO_LVM1 $DEFAULT_FALLBACK_TO_LVM1
-_ACEOF
-
-
-################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include support for lvm1 metadata" >&5
-$as_echo_n "checking whether to include support for lvm1 metadata... " >&6; }
-
-# Check whether --with-lvm1 was given.
-if test "${with_lvm1+set}" = set; then :
-  withval=$with_lvm1; LVM1=$withval
-else
-  LVM1=internal
-fi
-
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVM1" >&5
-$as_echo "$LVM1" >&6; }
-
-case "$LVM1" in
-  none|shared) ;;
-  internal)
-$as_echo "#define LVM1_INTERNAL 1" >>confdefs.h
- ;;
-  *) as_fn_error $? "--with-lvm1 parameter invalid" "$LINENO" 5 ;;
-esac
-
-################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include support for GFS pool metadata" >&5
-$as_echo_n "checking whether to include support for GFS pool metadata... " >&6; }
-
-# Check whether --with-pool was given.
-if test "${with_pool+set}" = set; then :
-  withval=$with_pool; POOL=$withval
-else
-  POOL=internal
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $POOL" >&5
-$as_echo "$POOL" >&6; }
-
-case "$POOL" in
-  none|shared) ;;
-  internal)
-$as_echo "#define POOL_INTERNAL 1" >>confdefs.h
- ;;
-  *) as_fn_error $? "--with-pool parameter invalid" "$LINENO" 5
-esac
-
-################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include support for cluster locking" >&5
 $as_echo_n "checking whether to include support for cluster locking... " >&6; }
 
@@ -15667,12 +15582,8 @@ _ACEOF
 
 
 
-
-
-
-
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile l
 ibdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monito
 ring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/li
 blvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_syst
 emd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16396,8 +16307,6 @@ do
     "conf/metadata_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/metadata_profile_template.profile" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
-    "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
-    "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "include/lvm-version.h") CONFIG_FILES="$CONFIG_FILES include/lvm-version.h" ;;
     "libdaemon/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/Makefile" ;;
diff --git a/include/configure.h.in b/include/configure.h.in
index 89f7a22..66cc27c 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -72,10 +72,6 @@
 /* Default system configuration directory. */
 #undef DEFAULT_ETC_DIR
 
-/* Fall back to LVM1 by default if device-mapper is missing from the kernel.
-   */
-#undef DEFAULT_FALLBACK_TO_LVM1
-
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 
@@ -617,13 +613,6 @@
    slash. */
 #undef LSTAT_FOLLOWS_SLASHED_SYMLINK
 
-/* Define to 1 if 'lvm' should fall back to using LVM1 binaries if
-   device-mapper is missing from the kernel */
-#undef LVM1_FALLBACK
-
-/* Define to 1 to include built-in support for LVM1 metadata. */
-#undef LVM1_INTERNAL
-
 /* Path to lvmetad pidfile. */
 #undef LVMETAD_PIDFILE
 
@@ -686,9 +675,6 @@
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 
-/* Define to 1 to include built-in support for GFS pool metadata. */
-#undef POOL_INTERNAL
-
 /* Define to 1 to include built-in support for raid. */
 #undef RAID_INTERNAL
 


