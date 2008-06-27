From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jun 2008 19:57:28 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20080627195728.1376.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-27 19:57:27

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Enable readline by default if available.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.922&r2=1.923
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2008/06/27 19:24:17	1.922
+++ LVM2/WHATS_NEW	2008/06/27 19:57:27	1.923
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Enable readline by default if available.
   Update autoconf to 2008-01-16.
   Add $DISTCLEAN_DIRS to make.tmpl.in.
   Create coverage reports with --enable-profiling and make lcov or lcov-dated.
--- LVM2/configure	2008/06/27 19:24:17	1.72
+++ LVM2/configure	2008/06/27 19:57:27	1.73
@@ -1317,7 +1317,7 @@
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
   --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
-  --enable-readline       Enable readline support
+  --disable-readline      Disable readline support
   --disable-realtime      Disable realtime clock support
   --enable-debug          Enable debugging
   --enable-profiling      Gather gcov profiling data
@@ -8509,7 +8509,7 @@
 if test "${enable_readline+set}" = set; then
   enableval=$enable_readline; READLINE=$enableval
 else
-  READLINE=no
+  READLINE=yes
 fi
 
 { echo "$as_me:$LINENO: result: $READLINE" >&5
--- LVM2/configure.in	2008/06/27 19:24:17	1.73
+++ LVM2/configure.in	2008/06/27 19:57:27	1.74
@@ -269,11 +269,11 @@
 fi
 
 ################################################################################
-dnl -- Enable readline
+dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
-  [  --enable-readline       Enable readline support],
-  [READLINE=$enableval], [READLINE=no])
+  [  --disable-readline      Disable readline support],
+  [READLINE=$enableval], [READLINE=yes])
 AC_MSG_RESULT($READLINE)
 
 ################################################################################


