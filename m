From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 08:12:15 +0000 (GMT)
Subject: main - configure.ac: enhance systemd testing
Message-ID: <20211015081215.1D91E3857801@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d87549f8096759a70ce91119ebc71e8fdde0294
Commit:        9d87549f8096759a70ce91119ebc71e8fdde0294
Parent:        2e2d67378007ee850792396f933900e71f0ea80d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 09:55:08 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 10:09:21 2021 +0200

configure.ac: enhance systemd testing

Enhance logic for checking supported systemd version,
while doing only a single check for systemd package.
For version checking use  PKG_CHECK_EXISTS() macro.

Also use one pkg check for blkid.

Avoid checking version for thin/cache_check when tools are not present
on system.
---
 configure.ac | 57 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 26 deletions(-)

diff --git a/configure.ac b/configure.ac
index ea56aa838..0069e5d36 100644
--- a/configure.ac
+++ b/configure.ac
@@ -430,7 +430,7 @@ case "$THIN" in
 			THIN_CONFIGURE_WARN=y
 		fi
 	fi
-	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+	if test "$THIN_CHECK_NEEDS_CHECK" = yes && test "$THIN_CONFIGURE_WARN" != y ; then
 		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
 		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
 		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
@@ -543,7 +543,7 @@ case "$CACHE" in
 			CACHE_CONFIGURE_WARN=y
 		fi
 	fi
-	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+	if test "$CACHE_CHECK_NEEDS_CHECK" = yes && test "$CACHE_CONFIGURE_WARN" != y ; then
 		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
 		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
@@ -1098,57 +1098,65 @@ if test "$BUILD_DMFILEMAPD" = yes; then
    AC_CHECK_HEADER([linux/fiemap.h], , [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
 fi
 
-SYSTEMD_MIN_VERSION=
+SYSTEMD_MIN_VERSION=0
+pkg_config_init
+PKG_CHECK_EXISTS(systemd >= 205, [SYSTEMD_MIN_VERSION=205], [])
+
 ################################################################################
 dnl -- Build notifydbus
+PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221], [])
 AC_MSG_CHECKING(whether to build notifydbus)
 AC_ARG_ENABLE(notify-dbus,
 	      AS_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
+	      AS_IF([test "$enableval" = yes && test "$SYSTEMD_MIN_VERSION" -lt 221],
+		    AC_MSG_ERROR([Enabling notify-dbus requires systemd >= 221]))
 	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT=no)
 AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
 
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes],
-      AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.])
-      SYSTEMD_MIN_VERSION=221)
+      AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.]))
 
 ################################################################################
 dnl -- Build with systemd journaling when the header file is present
-AC_CHECK_HEADER([systemd/sd-journal.h], [SYSTEMD_JOURNAL_SUPPORT=yes], [SYSTEMD_JOURNAL_SUPPORT=no])
+AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 221], [SYSTEMD_JOURNAL_SUPPORT=maybe], [SYSTEMD_JOURNAL_SUPPORT=no])
+AC_CHECK_HEADER([systemd/sd-journal.h],
+		[AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != no], [SYSTEMD_JOURNAL_SUPPORT=yes])],
+                [SYSTEMD_JOURNAL_SUPPORT=no])
 AC_MSG_CHECKING(whether to log to systemd journal)
 AC_ARG_ENABLE(systemd-journal,
 	      AS_HELP_STRING([--disable-systemd-journal],
 			     [disable LVM systemd journaling]),
 	      AS_IF([test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no],
-		    [AC_MSG_ERROR([Enabling systemd journaling requires systemd/sd-journal.h.])])
+		    AC_MSG_ERROR([Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221.]))
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval, [])
 AC_MSG_RESULT($SYSTEMD_JOURNAL_SUPPORT)
 
 AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = yes],
-      AC_DEFINE([SYSTEMD_JOURNAL_SUPPORT], 1, [Define to 1 to include code that uses systemd journal.])
-      SYSTEMD_MIN_VERSION=221)
+      AC_DEFINE([SYSTEMD_JOURNAL_SUPPORT], 1, [Define to 1 to include code that uses systemd journal.]))
 
 ################################################################################
 dnl -- Build appmachineid when header file sd-id128.h is present
-AC_CHECK_HEADER([systemd/sd-id128.h], [APP_MACHINEID_SUPPORT=yes], [APP_MACHINEID_SUPPORT=no])
-AC_MSG_CHECKING(whether to build appmachineid)
+PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe], [APP_MACHINEID_SUPPORT=no])
+AC_CHECK_HEADER([systemd/sd-id128.h],
+		[AS_IF([test "$APP_MACHINEID_SUPPORT" != no], [APP_MACHINEID_SUPPORT=yes])],
+		[APP_MACHINEID_SUPPORT=no])
+AC_MSG_CHECKING(whether to support systemd appmachineid)
 AC_ARG_ENABLE(app-machineid,
 	      AC_HELP_STRING([--disable-app-machineid],
 			     [disable LVM system ID using app-specific machine-id]),
 	      AS_IF([test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no],
-		    [AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h.])])
+		    AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h and systemd >= 234.]))
 	      APP_MACHINEID_SUPPORT=$enableval, [])
 AC_MSG_RESULT($APP_MACHINEID_SUPPORT)
 
 AS_IF([test "$APP_MACHINEID_SUPPORT" = yes],
-      AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.])
-      SYSTEMD_MIN_VERSION=234)
+      AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.]))
 
-dnl -- Look for libsystemd libraries
-AS_IF([test -n "$SYSTEMD_MIN_VERSION"],[
+dnl -- Look for libsystemd libraries if needed
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes || test "$SYSTEMD_JOURNAL_SUPPORT" = yes || test "$APP_MACHINEID_SUPPORT" = yes ] ,[
       pkg_config_init
-      PKG_CHECK_MODULES(SYSTEMD, systemd >= "$SYSTEMD_MIN_VERSION", [], $bailout)
-      SYSTEMD_LIBS="-lsystemd"])
+      PKG_CHECK_MODULES(SYSTEMD, [systemd], [SYSTEMD_LIBS="-lsystemd"], $bailout) ])
 
 ################################################################################
 
@@ -1187,14 +1195,11 @@ AC_ARG_ENABLE(udev-systemd-background-jobs,
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=maybe)
 
 if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
-	pkg_config_init
-	PKG_CHECK_MODULES(SYSTEMD, systemd >= 205,
-			  [UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
-			  [if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
-				UDEV_SYSTEMD_BACKGROUND_JOBS=no
-			   else
-				AC_MSG_ERROR([bailing out... systemd >= 205 is required])
-			   fi])
+	AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 205],
+	      UDEV_SYSTEMD_BACKGROUND_JOBS=yes,
+	      AS_IF([test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe],
+		     [UDEV_SYSTEMD_BACKGROUND_JOBS=no],
+		     [AC_MSG_ERROR([bailing out... systemd >= 205 is required])]))
 fi
 
 AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)


