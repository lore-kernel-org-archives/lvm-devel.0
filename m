From: meyering@sourceware.org <meyering@sourceware.org>
Date: 24 Jul 2008 14:54:06 -0000
Subject: LVM2 WHATS_NEW configure.in
Message-ID: <20080724145406.5922.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-07-24 14:54:06

Modified files:
	.              : WHATS_NEW configure.in 

Log message:
	Don't make configure fail when readline library is not available.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.934&r2=1.935
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2008/07/23 19:46:33	1.934
+++ LVM2/WHATS_NEW	2008/07/24 14:54:06	1.935
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  configure no longer fails when the readline library is not available
   Remove dead code, is_lvm_partition() - no functional change.
   Refactor pvcreate to divide parameter parsing & validation from create logic.
   Check for label_write() failure in _text_pv_write().
--- LVM2/configure.in	2008/07/09 09:59:42	1.75
+++ LVM2/configure.in	2008/07/24 14:54:06	1.76
@@ -273,7 +273,7 @@
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
   [  --disable-readline      Disable readline support],
-  [READLINE=$enableval], [READLINE=yes])
+  [READLINE=$enableval], [READLINE=maybe])
 AC_MSG_RESULT($READLINE)
 
 ################################################################################
@@ -410,9 +410,11 @@
 
 ################################################################################
 dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
-if test x$READLINE = xyes; then
-	AC_SEARCH_LIBS(tgetent, ncurses curses termcap termlib, ,
-		AC_MSG_ERROR(
+if test x$READLINE != xno; then
+	AC_SEARCH_LIBS([tgetent], [ncurses curses termcap termlib],
+	  [tg_found=yes], [tg_found=no])
+	test x$READLINE:$tg_found = xyes:no &&
+	  AC_MSG_ERROR(
 termcap could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install termcap from:
@@ -422,7 +424,6 @@
 Note: (n)curses also seems to work as a substitute for termcap.  This was
   not found either - but you could try installing that as well.
 )
-	)
 fi
 
 ################################################################################
@@ -514,9 +515,10 @@
 
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
-if test x$READLINE = xyes; then
-	AC_CHECK_LIB(readline, readline, ,
-		AC_MSG_ERROR(
+if test x$READLINE != xno; then
+	AC_CHECK_LIB([readline], [readline], [rl_found=yes], [rl_found=no])
+	test x$READLINE:$rl_found = xyes:no &&
+	  AC_MSG_ERROR(
 GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
@@ -524,12 +526,13 @@
 Note: if you are using precompiled packages you will also need the development
 package as well (which may be called readline-devel or something similar).
 )
-	)
-	AC_CHECK_FUNC([rl_completion_matches],
-	  AC_DEFINE([HAVE_RL_COMPLETION_MATCHES], 1,
-	  [Define to 1 if rl_completion_matches() is available.]))
-	AC_DEFINE([READLINE_SUPPORT], 1,
-	  [Define to 1 to include the LVM readline shell.])
+	if test $rl_found = yes; then
+		AC_CHECK_FUNC([rl_completion_matches],
+		  AC_DEFINE([HAVE_RL_COMPLETION_MATCHES], 1,
+		  [Define to 1 if rl_completion_matches() is available.]))
+		AC_DEFINE([READLINE_SUPPORT], 1,
+		  [Define to 1 to include the LVM readline shell.])
+	fi
 fi
 
 ################################################################################


