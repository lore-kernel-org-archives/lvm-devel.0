From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 10:24:24 -0400
Subject: master - build: Update configure
Message-ID: <201807241424.w6OEOOfT016058@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ff18f51b9d004075b7185218afa6e7a74a88277
Commit:        5ff18f51b9d004075b7185218afa6e7a74a88277
Parent:        279f3bfdc00883a9ff3ea11fd7c6cc5455a58519
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 16:17:42 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 16:17:42 2018 +0200

build: Update configure

---
 configure |   80 ++----------------------------------------------------------
 1 files changed, 3 insertions(+), 77 deletions(-)

diff --git a/configure b/configure
index a96de76..4ad2d4d 100755
--- a/configure
+++ b/configure
@@ -638,7 +638,6 @@ interface
 CMIRRORD_PIDFILE
 LVMLOCKD_PIDFILE
 LVMPOLLD_PIDFILE
-LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
 VDO_LIB
@@ -718,7 +717,6 @@ DLM_CFLAGS
 DEVMAPPER
 DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
-DEFAULT_USE_LVMETAD
 DEFAULT_USE_BLKID_WIPING
 DEFAULT_SYS_LOCK_DIR
 DEFAULT_SYS_DIR
@@ -749,7 +747,6 @@ BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
 BUILD_LVMLOCKD
 BUILD_LVMPOLLD
-BUILD_LVMETAD
 BUILD_LVMDBUSD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
@@ -932,14 +929,11 @@ with_optimisation
 enable_profiling
 enable_valgrind_pool
 enable_devmapper
-enable_lvmetad
 enable_lvmpolld
 enable_lvmlockd_sanlock
 enable_lvmlockd_dlm
 enable_use_lvmlockd
 with_lvmlockd_pidfile
-enable_use_lvmetad
-with_lvmetad_pidfile
 enable_use_lvmpolld
 with_lvmpolld_pidfile
 enable_dmfilemapd
@@ -1646,13 +1640,11 @@ Optional Features:
   --enable-profiling      gather gcov profiling data
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
-  --enable-lvmetad        enable the LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
   --enable-lvmlockd-sanlock
                           enable the LVM lock daemon using sanlock
   --enable-lvmlockd-dlm   enable the LVM lock daemon using dlm
   --disable-use-lvmlockd  disable usage of LVM lock daemon
-  --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
   --enable-dmfilemapd     enable the dmstats filemap daemon
   --enable-notify-dbus    enable LVM notification using dbus
@@ -1729,8 +1721,6 @@ Optional Packages:
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-lvmlockd-pidfile=PATH
                           lvmlockd pidfile [PID_DIR/lvmlockd.pid]
-  --with-lvmetad-pidfile=PATH
-                          lvmetad pidfile [PID_DIR/lvmetad.pid]
   --with-lvmpolld-pidfile=PATH
                           lvmpolld pidfile [PID_DIR/lvmpolld.pid]
   --with-localedir=DIR    locale-dependent data [DATAROOTDIR/locale]
@@ -3086,7 +3076,6 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
-		BUILD_LVMETAD=no
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
@@ -10739,18 +10728,6 @@ $as_echo "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build LVMetaD" >&5
-$as_echo_n "checking whether to build LVMetaD... " >&6; }
-# Check whether --enable-lvmetad was given.
-if test "${enable_lvmetad+set}" = set; then :
-  enableval=$enable_lvmetad; LVMETAD=$enableval
-fi
-
-test -n "$LVMETAD" && BUILD_LVMETAD=$LVMETAD
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMETAD" >&5
-$as_echo "$BUILD_LVMETAD" >&6; }
-
-################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
 $as_echo_n "checking whether to build lvmpolld... " >&6; }
 # Check whether --enable-lvmpolld was given.
@@ -10956,17 +10933,10 @@ if test "$BUILD_LVMLOCKD" = yes; then
 	if test "$LVMPOLLD" = no; then :
   as_fn_error $? "cannot build lvmlockd with --disable-lvmpolld." "$LINENO" 5
 fi
-	if test "$LVMETAD" = no; then :
-  as_fn_error $? "cannot build lvmlockd with --disable-lvmetad." "$LINENO" 5
-fi
 	if test "$BUILD_LVMPOLLD" = no; then :
   BUILD_LVMPOLLD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmpolld - required by lvmlockd." >&5
 $as_echo "$as_me: WARNING: Enabling lvmpolld - required by lvmlockd." >&2;}
 fi
-	if test "$BUILD_LVMETAD" = no; then :
-  BUILD_LVMETAD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmetad - required by lvmlockd." >&5
-$as_echo "$as_me: WARNING: Enabling lvmetad - required by lvmlockd." >&2;}
-fi
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmlockd" >&5
 $as_echo_n "checking defaults for use_lvmlockd... " >&6; }
 	# Check whether --enable-use_lvmlockd was given.
@@ -11008,48 +10978,6 @@ _ACEOF
 
 
 ################################################################################
-if test "$BUILD_LVMETAD" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmetad" >&5
-$as_echo_n "checking defaults for use_lvmetad... " >&6; }
-	# Check whether --enable-use_lvmetad was given.
-if test "${enable_use_lvmetad+set}" = set; then :
-  enableval=$enable_use_lvmetad; case ${enableval} in
-		       yes) DEFAULT_USE_LVMETAD=1 ;;
-		       *) DEFAULT_USE_LVMETAD=0 ;;
-		       esac
-else
-  DEFAULT_USE_LVMETAD=1
-fi
-
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMETAD" >&5
-$as_echo "$DEFAULT_USE_LVMETAD" >&6; }
-
-$as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
-
-
-
-# Check whether --with-lvmetad-pidfile was given.
-if test "${with_lvmetad_pidfile+set}" = set; then :
-  withval=$with_lvmetad_pidfile; LVMETAD_PIDFILE=$withval
-else
-  LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid"
-fi
-
-
-cat >>confdefs.h <<_ACEOF
-#define LVMETAD_PIDFILE "$LVMETAD_PIDFILE"
-_ACEOF
-
-else
-	DEFAULT_USE_LVMETAD=0
-fi
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_LVMETAD $DEFAULT_USE_LVMETAD
-_ACEOF
-
-
-################################################################################
 if test "$BUILD_LVMPOLLD" = yes; then
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmpolld" >&5
 $as_echo_n "checking defaults for use_lvmpolld... " >&6; }
@@ -13838,8 +13766,10 @@ _ACEOF
 
 
 
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Mak
 efile scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/blkdeactiva
 te.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14553,7 +14483,6 @@ do
     "daemons/lvmdbusd/lvmdb.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvmdb.py" ;;
     "daemons/lvmdbusd/lvm_shell_proxy.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvm_shell_proxy.py" ;;
     "daemons/lvmdbusd/path.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/path.py" ;;
-    "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
     "daemons/lvmlockd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmlockd/Makefile" ;;
     "conf/Makefile") CONFIG_FILES="$CONFIG_FILES conf/Makefile" ;;
@@ -14581,9 +14510,6 @@ do
     "scripts/dm_event_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.socket" ;;
     "scripts/lvm2_cmirrord_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cmirrord_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmdbusd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmdbusd_systemd_red_hat.service" ;;
-    "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
-    "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
-    "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmpolld_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_init_red_hat" ;;
     "scripts/lvm2_lvmpolld_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmpolld_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.socket" ;;


