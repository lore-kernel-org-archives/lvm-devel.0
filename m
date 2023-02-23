From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:56 +0000 (GMT)
Subject: main - configure.ac: fail configure for missing libraries
Message-ID: <20230223154856.D81903858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=255e8c8eaa0ca76de9ce8da0ebc78e8e0c9a4482
Commit:        255e8c8eaa0ca76de9ce8da0ebc78e8e0c9a4482
Parent:        ad66600e480d49c22372231c0a56ea3bf5a9b842
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 20 23:57:56 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

configure.ac: fail configure for missing libraries

When user enables lockd libraris, code needs to fail, when then are
missing. Also when notify-dbus support if enabled, and libsystemd is
missing, abort configuration.
---
 configure.ac | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/configure.ac b/configure.ac
index 06184be62..71006d895 100644
--- a/configure.ac
+++ b/configure.ac
@@ -913,7 +913,7 @@ AC_MSG_RESULT([$BUILD_LOCKDSANLOCK])
 
 dnl -- Look for sanlock libraries
 AS_IF([test "$BUILD_LOCKDSANLOCK" = "yes"], [
-	PKG_CHECK_MODULES(LIBSANLOCKCLIENT, libsanlock_client >= 3.3.0, [BUILD_LVMLOCKD="yes"], $bailout)
+	PKG_CHECK_MODULES(LIBSANLOCKCLIENT, libsanlock_client >= 3.3.0, [BUILD_LVMLOCKD="yes"])
 	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
 ])
 
@@ -928,7 +928,7 @@ AC_MSG_RESULT([$BUILD_LOCKDDLM])
 
 dnl -- Look for dlm libraries
 AS_IF([test "$BUILD_LOCKDDLM" = "yes"], [
-	PKG_CHECK_MODULES(LIBDLM, libdlm_lt, [BUILD_LVMLOCKD="yes"], $bailout)
+	PKG_CHECK_MODULES(LIBDLM, libdlm_lt, [BUILD_LVMLOCKD="yes"])
 	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
 	AS_CASE(["$LIBDLM_LIBS"],
 		[*lpthread*], [
@@ -948,7 +948,7 @@ AC_MSG_RESULT([$BUILD_LOCKDDLM_CONTROL])
 
 dnl -- Look for libdlmcontrol libraries
 AS_IF([test "$BUILD_LOCKDDLM_CONTROL" = "yes"], [
-	PKG_CHECK_MODULES(LIBDLMCONTROL, [libdlmcontrol >= 3.2], [BUILD_LVMLOCKD="yes"], $bailout)
+	PKG_CHECK_MODULES(LIBDLMCONTROL, [libdlmcontrol >= 3.2], [BUILD_LVMLOCKD="yes"])
 	AC_DEFINE([LOCKDDLM_CONTROL_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm control option.])
 ])
 
@@ -964,7 +964,7 @@ AC_MSG_RESULT([$BUILD_LOCKDIDM])
 dnl -- Look for Seagate IDM libraries
 AS_IF([test "$BUILD_LOCKDIDM" = "yes"], [
 	PKG_CHECK_EXISTS(blkid >= 2.24, [
-		PKG_CHECK_MODULES(LIBSEAGATEILM, [libseagate_ilm >= 0.1.0], [BUILD_LVMLOCKD="yes"], $bailout)
+		PKG_CHECK_MODULES(LIBSEAGATEILM, [libseagate_ilm >= 0.1.0], [BUILD_LVMLOCKD="yes"])
 		AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
 		AS_IF([test -z "$LIBSEAGATEILM_LIBS"], [LIBSEAGATEILM_LIBS="-lseagate_ilm"])
 	], $bailout)
@@ -1093,7 +1093,7 @@ AS_IF([test "$APP_MACHINEID_SUPPORT" = "yes"],
 
 dnl -- Look for libsystemd libraries if needed
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"], [
-	PKG_CHECK_MODULES(LIBSYSTEMD, [libsystemd], [], $bailout)
+	PKG_CHECK_MODULES(LIBSYSTEMD, [libsystemd])
 ])
 
 ################################################################################

