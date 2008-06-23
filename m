From: meyering@sourceware.org <meyering@sourceware.org>
Date: 23 Jun 2008 09:23:49 -0000
Subject: LVM2 WHATS_NEW configure.in
Message-ID: <20080623092349.6604.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-23 09:23:48

Modified files:
	.              : WHATS_NEW configure.in 

Log message:
	avoid link failure when configuring without --enable-readline
	
	* configure.in: Define READLINE_SUPPORT not when processing
	--enable-readline or --disable-readline, but rather only after
	determining that readline support is desired and the readline
	library is available/usable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.908&r2=1.909
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2008/06/20 12:46:21	1.908
+++ LVM2/WHATS_NEW	2008/06/23 09:23:48	1.909
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Avoid link failure when configuring without --enable-readline.
   Make clvmd return immediately if other nodes are down in an openais cluster.
   Make clvmd return immediately if other nodes are down in a gulm cluster.
   Improve/Fix read ahead 'auto' calculation for stripe_size
--- LVM2/configure.in	2008/06/13 14:37:17	1.69
+++ LVM2/configure.in	2008/06/23 09:23:48	1.70
@@ -270,14 +270,11 @@
 ################################################################################
 dnl -- Enable readline
 AC_MSG_CHECKING(whether to enable readline)
-AC_ARG_ENABLE(readline, [  --enable-readline       Enable readline support],
-READLINE=$enableval, READLINE=no)
+AC_ARG_ENABLE([readline],
+  [  --enable-readline       Enable readline support],
+  [READLINE=$enableval], [READLINE=no])
 AC_MSG_RESULT($READLINE)
 
-if test x$READLINE = xyes; then
-	AC_DEFINE([READLINE_SUPPORT], 1, [Define to 1 to include the LVM readline shell.])
-fi
-
 ################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
@@ -501,7 +498,11 @@
 package as well (which may be called readline-devel or something similar).
 )
 	)
-	AC_CHECK_FUNC(rl_completion_matches, AC_DEFINE([HAVE_RL_COMPLETION_MATCHES], 1, [Define to 1 if rl_completion_matches() is available.]))
+	AC_CHECK_FUNC([rl_completion_matches],
+	  AC_DEFINE([HAVE_RL_COMPLETION_MATCHES], 1,
+	  [Define to 1 if rl_completion_matches() is available.]))
+	AC_DEFINE([READLINE_SUPPORT], 1,
+	  [Define to 1 to include the LVM readline shell.])
 fi
 
 ################################################################################


