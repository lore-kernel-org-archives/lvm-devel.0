From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jan 2007 22:07:21 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20070109220721.21366.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-09 22:07:20

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Remove 3 redundant AC_MSG_RESULTs from configure.in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.529&r2=1.530
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2007/01/09 21:12:40	1.529
+++ LVM2/WHATS_NEW	2007/01/09 22:07:20	1.530
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Remove 3 redundant AC_MSG_RESULTs from configure.in.
   Free memory in _raw_read_mda_header() error paths.
   Fix ambiguous vgsplit error message for split LV.
   Fix lvextend man page typo.
--- LVM2/configure	2007/01/09 20:31:08	1.56
+++ LVM2/configure	2007/01/09 22:07:20	1.57
@@ -8268,8 +8268,6 @@
 
 ################################################################################
 if test x$SELINUX = xyes; then
-	echo "$as_me:$LINENO: checking for sepol_check_context function" >&5
-echo $ECHO_N "checking for sepol_check_context function... $ECHO_C" >&6
 	echo "$as_me:$LINENO: checking for sepol_check_context in -lsepol" >&5
 echo $ECHO_N "checking for sepol_check_context in -lsepol... $ECHO_C" >&6
 if test "${ac_cv_lib_sepol_sepol_check_context+set}" = set; then
@@ -8340,15 +8338,11 @@
   HAVE_SEPOL=no
 fi
 
-	echo "$as_me:$LINENO: result: $HAVE_SEPOL" >&5
-echo "${ECHO_T}$HAVE_SEPOL" >&6
 
 	if test x$HAVE_SEPOL = xyes; then
 		LIBS="-lsepol $LIBS"
 	fi
 
-	echo "$as_me:$LINENO: checking for is_selinux_enabled function" >&5
-echo $ECHO_N "checking for is_selinux_enabled function... $ECHO_C" >&6
 	echo "$as_me:$LINENO: checking for is_selinux_enabled in -lselinux" >&5
 echo $ECHO_N "checking for is_selinux_enabled in -lselinux... $ECHO_C" >&6
 if test "${ac_cv_lib_selinux_is_selinux_enabled+set}" = set; then
@@ -8419,8 +8413,6 @@
   HAVE_SELINUX=no
 fi
 
-	echo "$as_me:$LINENO: result: $HAVE_SELINUX" >&5
-echo "${ECHO_T}$HAVE_SELINUX" >&6
 
 	if test x$HAVE_SELINUX = xyes; then
 
@@ -8437,8 +8429,6 @@
 
 ################################################################################
 if test x$REALTIME = xyes; then
-	echo "$as_me:$LINENO: checking for clock_gettime function" >&5
-echo $ECHO_N "checking for clock_gettime function... $ECHO_C" >&6
 	echo "$as_me:$LINENO: checking for clock_gettime in -lrt" >&5
 echo $ECHO_N "checking for clock_gettime in -lrt... $ECHO_C" >&6
 if test "${ac_cv_lib_rt_clock_gettime+set}" = set; then
@@ -8509,8 +8499,6 @@
   HAVE_REALTIME=no
 fi
 
-	echo "$as_me:$LINENO: result: $HAVE_REALTIME" >&5
-echo "${ECHO_T}$HAVE_REALTIME" >&6
 
 	if test x$HAVE_REALTIME = xyes; then
 
--- LVM2/configure.in	2007/01/09 20:31:08	1.55
+++ LVM2/configure.in	2007/01/09 22:07:20	1.56
@@ -438,17 +438,13 @@
 ################################################################################
 dnl -- Check for selinux
 if test x$SELINUX = xyes; then
-	AC_MSG_CHECKING(for sepol_check_context function)
 	AC_CHECK_LIB(sepol, sepol_check_context, HAVE_SEPOL=yes, HAVE_SEPOL=no)
-	AC_MSG_RESULT($HAVE_SEPOL)
 
 	if test x$HAVE_SEPOL = xyes; then
 		LIBS="-lsepol $LIBS"
 	fi
 
-	AC_MSG_CHECKING(for is_selinux_enabled function)
 	AC_CHECK_LIB(selinux, is_selinux_enabled, HAVE_SELINUX=yes, HAVE_SELINUX=no)
-	AC_MSG_RESULT($HAVE_SELINUX)
 
 	if test x$HAVE_SELINUX = xyes; then
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
@@ -461,9 +457,7 @@
 ################################################################################
 dnl -- Check for realtime clock support
 if test x$REALTIME = xyes; then
-	AC_MSG_CHECKING(for clock_gettime function)
 	AC_CHECK_LIB(rt, clock_gettime, HAVE_REALTIME=yes, HAVE_REALTIME=no)
-	AC_MSG_RESULT($HAVE_REALTIME)
 
 	if test x$HAVE_REALTIME = xyes; then
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])


