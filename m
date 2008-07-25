From: meyering@sourceware.org <meyering@sourceware.org>
Date: 25 Jul 2008 08:00:20 -0000
Subject: LVM2 configure.in
Message-ID: <20080725080020.31919.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-07-25 08:00:20

Modified files:
	.              : configure.in 

Log message:
	Avoid compiler warnings (provoked by new configure.in bug) on RHEL5.
	
	Do not override the default action of AC_CHECK_LIB([readline],...
	(i.e., leave the ACTION-IF-FOUND parameter blank) so that the
	subsequent check for rl_completion_matches can use -lreadline.
	
	Also, replace AC_CHECK_FUNC+AC_DEFINE with an equivalent AC_CHECK_FUNCS call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/configure.in	2008/07/24 14:54:06	1.76
+++ LVM2/configure.in	2008/07/25 08:00:18	1.77
@@ -516,7 +516,8 @@
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
-	AC_CHECK_LIB([readline], [readline], [rl_found=yes], [rl_found=no])
+	rl_found=yes
+	AC_CHECK_LIB([readline], [readline], , [rl_found=no])
 	test x$READLINE:$rl_found = xyes:no &&
 	  AC_MSG_ERROR(
 GNU Readline could not be found which is required for the
@@ -527,9 +528,7 @@
 package as well (which may be called readline-devel or something similar).
 )
 	if test $rl_found = yes; then
-		AC_CHECK_FUNC([rl_completion_matches],
-		  AC_DEFINE([HAVE_RL_COMPLETION_MATCHES], 1,
-		  [Define to 1 if rl_completion_matches() is available.]))
+		AC_CHECK_FUNCS([rl_completion_matches])
 		AC_DEFINE([READLINE_SUPPORT], 1,
 		  [Define to 1 to include the LVM readline shell.])
 	fi


