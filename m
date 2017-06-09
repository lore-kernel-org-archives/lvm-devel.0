From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 16:56:40 -0400
Subject: master - configure: improve reporting about readline
Message-ID: <201706092056.v59KueWX018633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ef20d2168176f598d13e0b7bcc658b976813d5c
Commit:        5ef20d2168176f598d13e0b7bcc658b976813d5c
Parent:        358eee15f30778bc20c2723532bffdf1d8176684
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 22:40:27 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 22:40:27 2017 +0200

configure: improve reporting about readline

Report real 'readline' supporting state instead of 'maybe'.
Really check for 'readline' headers.
---
 configure    |   11 ++++++-----
 configure.in |    5 +++--
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/configure b/configure
index 9d0d97c..2a591aa 100755
--- a/configure
+++ b/configure
@@ -9623,8 +9623,6 @@ _ACEOF
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
-$as_echo_n "checking whether to enable readline... " >&6; }
 # Check whether --enable-readline was given.
 if test "${enable_readline+set}" = set; then :
   enableval=$enable_readline; READLINE=$enableval
@@ -9632,8 +9630,6 @@ else
   READLINE=maybe
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $READLINE" >&5
-$as_echo "$READLINE" >&6; }
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable realtime support" >&5
@@ -14444,7 +14440,8 @@ if test "x$ac_cv_lib_readline_readline" = xyes; then :
 
 $as_echo "#define READLINE_SUPPORT 1" >>confdefs.h
 
-				LIBS=$lvm_saved_libs
+				READLINE=yes
+		LIBS=$lvm_saved_libs
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for rl_line_buffer in -lreadline" >&5
 $as_echo_n "checking for rl_line_buffer in -lreadline... " >&6; }
 if ${ac_cv_lib_readline_rl_line_buffer+:} false; then :
@@ -14764,6 +14761,10 @@ fi
 done
 
 fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
+$as_echo_n "checking whether to enable readline... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $READLINE" >&5
+$as_echo "$READLINE" >&6; }
 
 if test "$BUILD_CMIRRORD" = yes; then
 	for ac_func in atexit
diff --git a/configure.in b/configure.in
index 0ca6b43..ae5baa5 100644
--- a/configure.in
+++ b/configure.in
@@ -674,11 +674,9 @@ AC_DEFINE_UNQUOTED([CACHE_RESTORE_CMD], ["$CACHE_RESTORE_CMD"],
 
 ################################################################################
 dnl -- Disable readline
-AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
 	      AC_HELP_STRING([--disable-readline], [disable readline support]),
 	      READLINE=$enableval, READLINE=maybe)
-AC_MSG_RESULT($READLINE)
 
 ################################################################################
 dnl -- Disable realtime clock support
@@ -1721,6 +1719,7 @@ Note: (n)curses also seems to work as a substitute for termcap.  This was
 		AC_DEFINE([READLINE_SUPPORT], 1,
 			[Define to 1 to include the LVM readline shell.])
 		dnl -- Try only with -lreadline and check for different symbol
+		READLINE=yes
 		LIBS=$lvm_saved_libs
 		AC_CHECK_LIB([readline], [rl_line_buffer],
 			[ READLINE_LIBS="-lreadline" ], [
@@ -1827,6 +1826,8 @@ dnl -- Ensure additional headers required
 if test "$READLINE" = yes; then
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,hard_bailout)
 fi
+AC_MSG_CHECKING(whether to enable readline)
+AC_MSG_RESULT($READLINE)
 
 if test "$BUILD_CMIRRORD" = yes; then
 	AC_CHECK_FUNCS(atexit,,hard_bailout)


