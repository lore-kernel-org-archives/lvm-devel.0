From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:33 +0000 (GMT)
Subject: main - configure.ac: print locking dir
Message-ID: <20230406114733.0C12A3858C30@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f2c48a10e6085d483d560277b9d582835582ec4
Commit:        0f2c48a10e6085d483d560277b9d582835582ec4
Parent:        51117b579350e2e44e3dae72642010a18b8506b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 28 23:13:00 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 11:06:04 2023 +0200

configure.ac: print locking dir

Correcting output results from configure script when
printing locking dir.

Shuffle dmfilemapd close to dmeventd option and tracing.

Couple indent changes.
---
 configure.ac | 92 +++++++++++++++++++++++++++---------------------------------
 1 file changed, 42 insertions(+), 50 deletions(-)

diff --git a/configure.ac b/configure.ac
index eed25d4db..efe5176db 100644
--- a/configure.ac
+++ b/configure.ac
@@ -964,14 +964,15 @@ dnl -- Build lvmlockd
 AC_MSG_CHECKING([whether to build lvmlockd])
 AC_MSG_RESULT([$BUILD_LVMLOCKD])
 
+DEFAULT_USE_LVMLOCKD=0
 AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
 	AS_IF([test "$LVMPOLLD" = "no"], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmpolld.])])
 	AS_IF([test "$BUILD_LVMPOLLD" = "no"], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
-		[AS_HELP_STRING([--disable-use-lvmlockd], [disable usage of LVM lock daemon])],
-		[AS_IF([test "$enableval" = "yes"], [DEFAULT_USE_LVMLOCKD=1], [DEFAULT_USE_LVMLOCKD=0])],
-		[DEFAULT_USE_LVMLOCKD=1])
+		      [AS_HELP_STRING([--disable-use-lvmlockd], [disable usage of LVM lock daemon])],
+		      [use_lvmlockd=$enableval],[use_lvmlockd="yes"])
+	AS_IF([test "$use_lvmlockd" = "yes"], [DEFAULT_USE_LVMLOCKD=1])
 	AC_MSG_RESULT([$DEFAULT_USE_LVMLOCKD])
 	AC_DEFINE([LVMLOCKD_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd.])
 
@@ -982,20 +983,19 @@ AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
 		    LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid")
 	AC_DEFINE_UNQUOTED(LVMLOCKD_PIDFILE, ["$LVMLOCKD_PIDFILE"],
 			   [Path to lvmlockd pidfile.])
-], [
-	DEFAULT_USE_LVMLOCKD=0
 ])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMLOCKD, [$DEFAULT_USE_LVMLOCKD],
 		   [Use lvmlockd by default.])
 
 ################################################################################
 dnl -- Check lvmpolld
+DEFAULT_USE_LVMPOLLD=0
 AS_IF([test "$BUILD_LVMPOLLD" = "yes"], [
 	AC_MSG_CHECKING([defaults for use_lvmpolld])
 	AC_ARG_ENABLE(use_lvmpolld,
-		[AS_HELP_STRING([--disable-use-lvmpolld], [disable usage of LVM Poll Daemon])],
-		[AS_IF([test "$enableval" = "yes"], [DEFAULT_USE_LVMPOLLD=1], [DEFAULT_USE_LVMPOLLD=0])],
-		[DEFAULT_USE_LVMPOLLD=1])
+		      [AS_HELP_STRING([--disable-use-lvmpolld], [disable usage of LVM Poll Daemon])],
+		      [use_lvmpolld=$enableval], [use_lvmpolld="yes"])
+	AS_IF([test "$use_lvmpolld" = "yes"], [DEFAULT_USE_LVMPOLLD=1])
 	AC_MSG_RESULT([$DEFAULT_USE_LVMPOLLD])
 	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
 
@@ -1006,39 +1006,24 @@ AS_IF([test "$BUILD_LVMPOLLD" = "yes"], [
 		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
 	AC_DEFINE_UNQUOTED(LVMPOLLD_PIDFILE, ["$LVMPOLLD_PIDFILE"],
 			   [Path to lvmpolld pidfile.])
-], [
-	DEFAULT_USE_LVMPOLLD=0
 ])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 		   [Use lvmpolld by default.])
 
-################################################################################
-dnl -- Check dmfilemapd
-AC_MSG_CHECKING([whether to build dmfilemapd])
-AC_ARG_ENABLE(dmfilemapd, AS_HELP_STRING([--enable-dmfilemapd],
-					 [enable the dmstats filemap daemon]),
-	      BUILD_DMFILEMAPD=$enableval, BUILD_DMFILEMAPD="no")
-AC_MSG_RESULT([$BUILD_DMFILEMAPD])
-AC_DEFINE([DMFILEMAPD], $BUILD_DMFILEMAPD, [Define to 1 to enable the device-mapper filemap daemon.])
-
-dnl -- dmfilemapd requires FIEMAP
-AS_IF([test "$BUILD_DMFILEMAPD" = "yes"], [
-   AC_CHECK_HEADER([linux/fiemap.h], , [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
-])
 
 SYSTEMD_MIN_VERSION=0
-PKG_CHECK_EXISTS(systemd >= 205, [SYSTEMD_MIN_VERSION=205], [])
+PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221])
+PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234])
 
 ################################################################################
 dnl -- Build notifydbus
-PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221], [])
 AC_MSG_CHECKING([whether to build notifydbus])
 AC_ARG_ENABLE(notify-dbus,
 	      AS_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
-	      AS_IF([test "$enableval" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221],
-		    AC_MSG_ERROR([Enabling notify-dbus requires systemd >= 221]))
 	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT="no")
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221],
+      [AC_MSG_ERROR([Enabling notify-dbus requires systemd >= 221])])
 AC_MSG_RESULT([$NOTIFYDBUS_SUPPORT])
 
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes"],
@@ -1064,7 +1049,7 @@ AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
 
 ################################################################################
 dnl -- Build appmachineid when header file sd-id128.h is present
-PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT="maybe"], [APP_MACHINEID_SUPPORT="no"])
+AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 234], [APP_MACHINEID_SUPPORT="maybe"], [APP_MACHINEID_SUPPORT="no"])
 AC_CHECK_HEADER([systemd/sd-id128.h],
 		[AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"], [APP_MACHINEID_SUPPORT="yes"])],
 		[APP_MACHINEID_SUPPORT="no"])
@@ -1091,12 +1076,10 @@ AC_ARG_WITH(systemd-run,
 	    AS_HELP_STRING([--with-systemd-run=PATH],
 			   [systemd-run tool: [autodetect]]),
 			   SYSTEMD_RUN_CMD=$withval, SYSTEMD_RUN_CMD="autodetect")
-
-AS_IF([test "$SYSTEMD_RUN_CMD" = "autodetect"],
-      [AC_PATH_TOOL(SYSTEMD_RUN_CMD, systemd-run)
-       AS_IF([test -z "$SYSTEMD_RUN_CMD"], [SYSTEMD_RUN_CMD="/usr/bin/systemd-run"])],
-      [AC_MSG_CHECKING([for defined systemd-run])
-       AC_MSG_RESULT([$SYSTEMD_RUN_CMD])])
+AS_IF([test "$SYSTEMD_RUN_CMD" = "autodetect"], [AC_PATH_TOOL(SYSTEMD_RUN_CMD, systemd-run)])
+AC_MSG_CHECKING([for app running udev background service])
+AS_IF([test -z "$SYSTEMD_RUN_CMD"], [SYSTEMD_RUN_CMD="/usr/bin/systemd-run"])
+AC_MSG_RESULT([$SYSTEMD_RUN_CMD])
 
 ################################################################################
 
@@ -1329,11 +1312,25 @@ AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
    AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
 ])
 
+################################################################################
+dnl -- Check dmfilemapd
+AC_MSG_CHECKING([whether to build dmfilemapd])
+AC_ARG_ENABLE(dmfilemapd, AS_HELP_STRING([--enable-dmfilemapd],
+					 [enable the dmstats filemap daemon]),
+	      BUILD_DMFILEMAPD=$enableval, BUILD_DMFILEMAPD="no")
+AC_MSG_RESULT([$BUILD_DMFILEMAPD])
+
+dnl -- dmfilemapd requires FIEMAP
+AS_IF([test "$BUILD_DMFILEMAPD" = "yes"],
+      [AC_CHECK_HEADER([linux/fiemap.h], [],    
+		      ,[AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
+       AC_DEFINE([DMFILEMAPD], 1, [Define to 1 to enable the device-mapper filemap daemon.])])
+
 ################################################################################
 dnl -- getline included in recent libc
 
-AC_CHECK_LIB(c, getline, AC_DEFINE([HAVE_GETLINE], 1,
-  [Define to 1 if getline is available.]))
+AC_CHECK_LIB(c, getline,
+	     [AC_DEFINE([HAVE_GETLINE], 1, [Define to 1 if getline is available.])])
 
 ################################################################################
 dnl -- canonicalize_file_name included in recent libc
@@ -1586,17 +1583,13 @@ AC_ARG_WITH(systemdsystemunitdir,
 	    AS_HELP_STRING([--with-systemdsystemunitdir=DIR],
 			   [systemd service files in DIR]))
 
-AS_IF([test -z "$with_systemdsystemunitdir"], [
-	PKG_CHECK_VAR([systemdsystemunitdir], [systemd], [systemdsystemunitdir], [], [
-		systemdsystemunitdir='${exec_prefix}/lib/systemd/system'
-	])
-], [
-	systemdsystemunitdir="$with_systemdsystemunitdir"
-])
+AS_IF([test -z "$with_systemdsystemunitdir"],
+      [PKG_CHECK_VAR([systemdsystemunitdir], [systemd], [systemdsystemunitdir], [],
+		     [systemdsystemunitdir='${exec_prefix}/lib/systemd/system'])],
+      [systemdsystemunitdir="$with_systemdsystemunitdir"])
 
-PKG_CHECK_VAR([systemdutildir], [systemd], [systemdutildir], [], [
-	systemdutildir='${exec_prefix}/lib/systemd'
-])
+PKG_CHECK_VAR([systemdutildir], [systemd], [systemdutildir], [],
+	      [systemdutildir='${exec_prefix}/lib/systemd'])
 
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
@@ -1744,13 +1737,12 @@ DEFAULT_SYS_LOCK_DIR="$RUN_DIR/lock"
 test -d "$DEFAULT_SYS_LOCK_DIR" || DEFAULT_SYS_LOCK_DIR="/var/lock"
 
 # Support configurable locking subdir for lvm
+AC_MSG_CHECKING([for default lock directory])
 AC_ARG_WITH(default-locking-dir,
 	    AS_HELP_STRING([--with-default-locking-dir=DIR],
 			   [default locking directory [autodetect_lock_dir/lvm]]),
-	    DEFAULT_LOCK_DIR=$withval,
-	    [AC_MSG_CHECKING([for default lock directory])
-	     DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
-	     AC_MSG_RESULT([$DEFAULT_LOCK_DIR])])
+	    [DEFAULT_LOCK_DIR=$withval], [DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"])
+AC_MSG_RESULT([$DEFAULT_LOCK_DIR])
 AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 		   [Name of default locking directory.])
 

