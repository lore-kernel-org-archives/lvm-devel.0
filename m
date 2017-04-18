From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 18 Apr 2017 15:40:49 -0400
Subject: master - configure: Fix notify-dbus and dmfilemapd options.
Message-ID: <201704181940.v3IJenBp015579@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=658d524d26f2cff9bde31142ecab6d17fd2c54dd
Commit:        658d524d26f2cff9bde31142ecab6d17fd2c54dd
Parent:        2d9097e9ca2c07cff1870349bd15e30e151e709e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 18 20:37:53 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 18 20:37:53 2017 +0100

configure: Fix notify-dbus and dmfilemapd options.

---
 WHATS_NEW       |    3 +-
 WHATS_NEW_DM    |    1 +
 configure       |   62 ++++++++++++++++++++++++++----------------------------
 configure.in    |   23 ++++++++------------
 man/Makefile.in |    2 +-
 5 files changed, 43 insertions(+), 48 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 39ad2af..5a13744 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.171 - 
 ==================================
-  Change configure option names from enable-lockd to enable-lvmlockd.
+  Fix configure --enable-notify-dbus status message.
+  Change configure option name prefix from --enable-lockd to --enable-lvmlockd.
   lvcreate - raise mirror/raid default regionsize to 2MiB
   Add missing configurable prefix to configuration file installation directory.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e6f7729..c88516d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.140 - 
 ==================================
+  Add missing configure --enable-dmfilemapd status message and fix --disable.
 
 Version 1.02.139 - 13th April 2017
 ==================================
diff --git a/configure b/configure
index 4b83118..ffef9b9 100755
--- a/configure
+++ b/configure
@@ -703,7 +703,6 @@ FSADM_PATH
 FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
-DMFILEMAPD
 DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
@@ -738,7 +737,6 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
-BUILD_NOTIFYDBUS
 BUILD_DMFILEMAPD
 BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
@@ -955,8 +953,8 @@ enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
 enable_lvmpolld
-enable_lockd_sanlock
-enable_lockd_dlm
+enable_lvmlockd_sanlock
+enable_lvmlockd_dlm
 enable_use_lvmlockd
 with_lvmlockd_pidfile
 enable_use_lvmetad
@@ -1693,8 +1691,9 @@ Optional Features:
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
-  --enable-lockd-sanlock  enable the LVM lock daemon using sanlock
-  --enable-lockd-dlm      enable the LVM lock daemon using dlm
+  --enable-lvmlockd-sanlock
+                          enable the LVM lock daemon using sanlock
+  --enable-lvmlockd-dlm   enable the LVM lock daemon using dlm
   --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
@@ -11774,11 +11773,11 @@ $as_echo "$BUILD_LVMPOLLD" >&6; }
 ################################################################################
 BUILD_LVMLOCKD=no
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lockdsanlock" >&5
-$as_echo_n "checking whether to build lockdsanlock... " >&6; }
-# Check whether --enable-lockd-sanlock was given.
-if test "${enable_lockd_sanlock+set}" = set; then :
-  enableval=$enable_lockd_sanlock; LOCKDSANLOCK=$enableval
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockdsanlock" >&5
+$as_echo_n "checking whether to build lvmlockdsanlock... " >&6; }
+# Check whether --enable-lvmlockd-sanlock was given.
+if test "${enable_lvmlockd_sanlock+set}" = set; then :
+  enableval=$enable_lvmlockd_sanlock; LOCKDSANLOCK=$enableval
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
@@ -11865,11 +11864,11 @@ $as_echo "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lockddlm" >&5
-$as_echo_n "checking whether to build lockddlm... " >&6; }
-# Check whether --enable-lockd-dlm was given.
-if test "${enable_lockd_dlm+set}" = set; then :
-  enableval=$enable_lockd_dlm; LOCKDDLM=$enableval
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockddlm" >&5
+$as_echo_n "checking whether to build lvmlockddlm... " >&6; }
+# Check whether --enable-lvmlockd-dlm was given.
+if test "${enable_lvmlockd_dlm+set}" = set; then :
+  enableval=$enable_lvmlockd_dlm; LOCKDDLM=$enableval
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
@@ -12105,17 +12104,18 @@ _ACEOF
 $as_echo_n "checking whether to build dmfilemapd... " >&6; }
 # Check whether --enable-dmfilemapd was given.
 if test "${enable_dmfilemapd+set}" = set; then :
-  enableval=$enable_dmfilemapd; DMFILEMAPD=$enableval
+  enableval=$enable_dmfilemapd; BUILD_DMFILEMAPD=$enableval
+else
+  BUILD_DMFILEMAPD=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DMFILEMAPD" >&5
-$as_echo "$DMFILEMAPD" >&6; }
-BUILD_DMFILEMAPD=$DMFILEMAPD
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMFILEMAPD" >&5
+$as_echo "$BUILD_DMFILEMAPD" >&6; }
 
-$as_echo "#define DMFILEMAPD 1" >>confdefs.h
+$as_echo "#define DMFILEMAPD \$BUILD_DMFILEMAPD" >>confdefs.h
 
 
-if test "$DMFILEMAPD" = yes; then
+if test "$BUILD_DMFILEMAPD" = yes; then
    ac_fn_c_check_header_mongrel "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
 if test "x$ac_cv_header_linux_fiemap_h" = xyes; then :
 
@@ -12131,15 +12131,15 @@ fi
 $as_echo_n "checking whether to build notifydbus... " >&6; }
 # Check whether --enable-notify-dbus was given.
 if test "${enable_notify_dbus+set}" = set; then :
-  enableval=$enable_notify_dbus; NOTIFYDBUS=$enableval
+  enableval=$enable_notify_dbus; NOTIFYDBUS_SUPPORT=$enableval
+else
+  NOTIFYDBUS_SUPPORT=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS" >&5
-$as_echo "$NOTIFYDBUS" >&6; }
-
-BUILD_NOTIFYDBUS=$NOTIFYDBUS
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
+$as_echo "$NOTIFYDBUS_SUPPORT" >&6; }
 
-if test "$BUILD_NOTIFYDBUS" = yes; then
+if test "$NOTIFYDBUS_SUPPORT" = yes; then
 
 $as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 
@@ -12147,7 +12147,7 @@ $as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-if test "$BUILD_NOTIFYDBUS" = yes; then
+if test "$NOTIFYDBUS_SUPPORT" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for NOTIFY_DBUS" >&5
@@ -15175,7 +15175,7 @@ done
 
 fi
 
-if test "$DMFILEMAPD" = yes; then
+if test "$BUILD_DMFILEMAPD" = yes; then
 	for ac_header in sys/inotify.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "sys/inotify.h" "ac_cv_header_sys_inotify_h" "$ac_includes_default"
@@ -15669,8 +15669,6 @@ _ACEOF
 
 
 
-
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon
 /client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/
 lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 33cff4f..2ff4f99 100644
--- a/configure.in
+++ b/configure.in
@@ -1278,13 +1278,12 @@ dnl -- Check dmfilemapd
 AC_MSG_CHECKING(whether to build dmfilemapd)
 AC_ARG_ENABLE(dmfilemapd, AC_HELP_STRING([--enable-dmfilemapd],
 					 [enable the dmstats filemap daemon]),
-	      DMFILEMAPD=$enableval)
-AC_MSG_RESULT($DMFILEMAPD)
-BUILD_DMFILEMAPD=$DMFILEMAPD
-AC_DEFINE([DMFILEMAPD], 1, [Define to 1 to enable the device-mapper filemap daemon.])
+	      BUILD_DMFILEMAPD=$enableval, BUILD_DMFILEMAPD=no)
+AC_MSG_RESULT($BUILD_DMFILEMAPD)
+AC_DEFINE([DMFILEMAPD], $BUILD_DMFILEMAPD, [Define to 1 to enable the device-mapper filemap daemon.])
 
 dnl -- dmfilemapd requires FIEMAP
-if test "$DMFILEMAPD" = yes; then
+if test "$BUILD_DMFILEMAPD" = yes; then
    AC_CHECK_HEADER([linux/fiemap.h], , [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
 fi
 
@@ -1294,19 +1293,17 @@ AC_MSG_CHECKING(whether to build notifydbus)
 AC_ARG_ENABLE(notify-dbus,
 	      AC_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
-	      NOTIFYDBUS=$enableval)
-AC_MSG_RESULT($NOTIFYDBUS)
+	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT=no)
+AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
 
-BUILD_NOTIFYDBUS=$NOTIFYDBUS
-
-if test "$BUILD_NOTIFYDBUS" = yes; then
+if test "$NOTIFYDBUS_SUPPORT" = yes; then
 	AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.])
 	LIBS="-lsystemd $LIBS"
 fi
 
 ################################################################################
 dnl -- Look for dbus libraries
-if test "$BUILD_NOTIFYDBUS" = yes; then
+if test "$NOTIFYDBUS_SUPPORT" = yes; then
 	PKG_CHECK_MODULES(NOTIFY_DBUS, systemd >= 221, [HAVE_NOTIFY_DBUS=yes], $bailout)
 fi
 
@@ -1872,7 +1869,7 @@ if test "$UDEV_SYNC" = yes; then
 	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,hard_bailout)
 fi
 
-if test "$DMFILEMAPD" = yes; then
+if test "$BUILD_DMFILEMAPD" = yes; then
 	AC_CHECK_HEADERS([sys/inotify.h],,hard_bailout)
 fi
 
@@ -2022,7 +2019,6 @@ AC_SUBST(BUILD_LVMLOCKD)
 AC_SUBST(BUILD_LOCKDSANLOCK)
 AC_SUBST(BUILD_LOCKDDLM)
 AC_SUBST(BUILD_DMFILEMAPD)
-AC_SUBST(BUILD_NOTIFYDBUS)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
@@ -2071,7 +2067,6 @@ AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DMEVENTD_PATH)
-AC_SUBST(DMFILEMAPD)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
diff --git a/man/Makefile.in b/man/Makefile.in
index 25b1c95..d0efb5d 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -89,7 +89,7 @@ else
     MAN8DM+=$(DMEVENTDMAN)
   endif
 
-  ifeq ("@DMFILEMAPD@", "yes")
+  ifeq ("@BUILD_DMFILEMAPD@", "yes")
     MAN8DM+=$(DMFILEMAPDMAN)
   endif
 


