From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:42 +0000 (GMT)
Subject: main - configure.ac: more cleanup
Message-ID: <20230213133142.E23E638493CA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e55e5c60a1b6067d7a46f881d78b2ab7d1431eb
Commit:        1e55e5c60a1b6067d7a46f881d78b2ab7d1431eb
Parent:        f46610e9b0a75ce9610c146a317cfc6dfe1ac6f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 00:07:01 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 14:30:47 2023 +0100

configure.ac: more cleanup

Some variable simplification,
correct messages with PATH_SBIN.
---
 configure.ac | 52 ++++++++++++++++++++++------------------------------
 1 file changed, 22 insertions(+), 30 deletions(-)

diff --git a/configure.ac b/configure.ac
index 079bbd07f..e8dc7a92c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2022 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2023 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -403,7 +403,7 @@ AS_CASE(["$THIN"],
 	AS_IF([test "$THIN_CHECK_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_CHECK_CMD"], [
-			AC_MSG_WARN([thin_check not found in path $PATH])
+			AC_MSG_WARN([thin_check not found in path $PATH_SBIN])
 			THIN_CHECK_CMD="/usr/sbin/thin_check"
 			THIN_CONFIGURE_WARN="y"
 		])
@@ -427,7 +427,7 @@ AS_CASE(["$THIN"],
 	AS_IF([test "$THIN_DUMP_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_DUMP_CMD"], [
-			AC_MSG_WARN(["thin_dump not found in path $PATH"])
+			AC_MSG_WARN(["thin_dump not found in path $PATH_SBIN"])
 			THIN_DUMP_CMD="/usr/sbin/thin_dump"
 			THIN_CONFIGURE_WARN="y"
 		])
@@ -436,7 +436,7 @@ AS_CASE(["$THIN"],
 	AS_IF([test "$THIN_REPAIR_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_REPAIR_CMD"], [
-			AC_MSG_WARN(["thin_repair not found in path $PATH"])
+			AC_MSG_WARN(["thin_repair not found in path $PATH_SBIN"])
 			THIN_REPAIR_CMD="/usr/sbin/thin_repair"
 			THIN_CONFIGURE_WARN="y"
 		])
@@ -445,7 +445,7 @@ AS_CASE(["$THIN"],
 	AS_IF([test "$THIN_RESTORE_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_RESTORE_CMD"], [
-			AC_MSG_WARN(["thin_restore not found in path $PATH"])
+			AC_MSG_WARN(["thin_restore not found in path $PATH_SBIN"])
 			THIN_RESTORE_CMD="/usr/sbin/thin_restore"
 			THIN_CONFIGURE_WARN="y"
 		])
@@ -515,7 +515,7 @@ AS_CASE(["$CACHE"],
 	AS_IF([test "$CACHE_CHECK_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_CHECK_CMD"], [
-			AC_MSG_WARN([cache_check not found in path $PATH])
+			AC_MSG_WARN([cache_check not found in path $PATH_SBIN])
 			CACHE_CHECK_CMD="/usr/sbin/cache_check"
 			CACHE_CONFIGURE_WARN="y"
 		])
@@ -550,7 +550,7 @@ AS_CASE(["$CACHE"],
 	AS_IF([test "$CACHE_DUMP_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_DUMP_CMD"], [
-			AC_MSG_WARN(["cache_dump not found in path $PATH"])
+			AC_MSG_WARN(["cache_dump not found in path $PATH_SBIN"])
 			CACHE_DUMP_CMD="/usr/sbin/cache_dump"
 			CACHE_CONFIGURE_WARN="y"
 		])
@@ -559,7 +559,7 @@ AS_CASE(["$CACHE"],
 	AS_IF([test "$CACHE_REPAIR_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_REPAIR_CMD, cache_repair, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_REPAIR_CMD"], [
-			AC_MSG_WARN(["cache_repair not found in path $PATH"])
+			AC_MSG_WARN(["cache_repair not found in path $PATH_SBIN"])
 			CACHE_REPAIR_CMD="/usr/sbin/cache_repair"
 			CACHE_CONFIGURE_WARN="y"
 		])
@@ -568,7 +568,7 @@ AS_CASE(["$CACHE"],
 	AS_IF([test "$CACHE_RESTORE_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_RESTORE_CMD, cache_restore, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_RESTORE_CMD"], [
-			AC_MSG_WARN(["cache_restore not found in path $PATH"])
+			AC_MSG_WARN(["cache_restore not found in path $PATH_SBIN"])
 			CACHE_RESTORE_CMD="/usr/sbin/cache_restore"
 			CACHE_CONFIGURE_WARN="y"
 		])
@@ -908,14 +908,12 @@ AC_MSG_CHECKING([whether to build lvmlockdsanlock])
 AC_ARG_ENABLE(lvmlockd-sanlock,
 	      AS_HELP_STRING([--enable-lvmlockd-sanlock],
 			     [enable the LVM lock daemon using sanlock]),
-	      LOCKDSANLOCK=$enableval, LOCKDSANLOCK="no")
-AC_MSG_RESULT([$LOCKDSANLOCK])
-
-BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
+	      BUILD_LOCKDSANLOCK=$enableval, BUILD_LOCKDSANLOCK="no")
+AC_MSG_RESULT([$BUILD_LOCKDSANLOCK])
 
 dnl -- Look for sanlock libraries
 AS_IF([test "$BUILD_LOCKDSANLOCK" = "yes"], [
-	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client >= 3.3.0, [HAVE_LOCKD_SANLOCK=yes], $bailout)
+	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client >= 3.3.0, [HAVE_LOCKD_SANLOCK="yes"], $bailout)
 	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
 	BUILD_LVMLOCKD=yes
 ])
@@ -926,14 +924,12 @@ AC_MSG_CHECKING([whether to build lvmlockddlm])
 AC_ARG_ENABLE(lvmlockd-dlm,
 	      AS_HELP_STRING([--enable-lvmlockd-dlm],
 			     [enable the LVM lock daemon using dlm]),
-	      LOCKDDLM=$enableval, LOCKDDLM="no")
-AC_MSG_RESULT([$LOCKDDLM])
-
-BUILD_LOCKDDLM=$LOCKDDLM
+	      BUILD_LOCKDDLM=$enableval, BUILD_LOCKDDLM="no")
+AC_MSG_RESULT([$BUILD_LOCKDDLM])
 
 dnl -- Look for dlm libraries
 AS_IF([test "$BUILD_LOCKDDLM" = "yes"], [
-	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
+	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM="yes"], $bailout)
 	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
 	BUILD_LVMLOCKD=yes
 ])
@@ -944,10 +940,8 @@ AC_MSG_CHECKING([whether to build lvmlockddlmcontrol])
 AC_ARG_ENABLE(lvmlockd-dlmcontrol,
 	      AS_HELP_STRING([--enable-lvmlockd-dlmcontrol],
 			     [enable lvmlockd remote refresh using libdlmcontrol]),
-	      LOCKDDLM_CONTROL=$enableval, LOCKDDLM_CONTROL="no")
-AC_MSG_RESULT([$LOCKDDLM_CONTROL])
-
-BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
+	      BUILD_LOCKDDLM_CONTROL=$enableval, BUILD_LOCKDDLM_CONTROL="no")
+AC_MSG_RESULT([$BUILD_LOCKDDLM_CONTROL])
 
 dnl -- Look for libdlmcontrol libraries
 AS_IF([test "$BUILD_LOCKDDLM_CONTROL" = "yes"], [
@@ -962,10 +956,8 @@ AC_MSG_CHECKING([whether to build lvmlockdidm])
 AC_ARG_ENABLE(lvmlockd-idm,
 	      AS_HELP_STRING([--enable-lvmlockd-idm],
 			     [enable the LVM lock daemon using idm]),
-	      LOCKDIDM=$enableval, LOCKDIDM="no")
-AC_MSG_RESULT([$LOCKDIDM])
-
-BUILD_LOCKDIDM=$LOCKDIDM
+	      BUILD_LOCKDIDM=$enableval, BUILD_LOCKDIDM="no")
+AC_MSG_RESULT([$BUILD_LOCKDIDM])
 
 dnl -- Look for Seagate IDM libraries
 AS_IF([test "$BUILD_LOCKDIDM" = "yes"], [
@@ -1080,10 +1072,10 @@ AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
 
 ################################################################################
 dnl -- Build appmachineid when header file sd-id128.h is present
-PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe], [APP_MACHINEID_SUPPORT=no])
+PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT="maybe"], [APP_MACHINEID_SUPPORT="no"])
 AC_CHECK_HEADER([systemd/sd-id128.h],
 		[AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"], [APP_MACHINEID_SUPPORT="yes"])],
-		[APP_MACHINEID_SUPPORT=no])
+		[APP_MACHINEID_SUPPORT="no"])
 AC_MSG_CHECKING([whether to support systemd appmachineid])
 AC_ARG_ENABLE(app-machineid,
 	      AS_HELP_STRING([--disable-app-machineid],
@@ -1508,7 +1500,7 @@ Note: (n)curses also seems to work as a substitute for termcap.  This was
 		AC_DEFINE([READLINE_SUPPORT], 1,
 			[Define to 1 to include the LVM readline shell.])
 		dnl -- Try only with -lreadline and check for different symbol
-		READLINE=yes
+		READLINE="yes"
 		LIBS=$lvm_saved_libs
 		AC_CHECK_LIB([readline], [rl_line_buffer],
 			[ READLINE_LIBS="-lreadline" ], [

