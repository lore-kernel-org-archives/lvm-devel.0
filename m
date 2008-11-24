From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Nov 2008 13:33:20 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20081124133320.15162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-24 13:33:19

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Add tinfo to termcap search path for pld-linux.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.999&r2=1.1000
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2008/11/21 13:48:00	1.999
+++ LVM2/WHATS_NEW	2008/11/24 13:33:16	1.1000
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Add tinfo to termcap search path for pld-linux.
   Fix startup race in clvmd.
   Generate Red Hat clvmd startup script at configuration time with correct paths.
   Fix clvmd & dmeventd builds after tree restructuring.
--- LVM2/configure	2008/11/19 19:34:32	1.86
+++ LVM2/configure	2008/11/24 13:33:18	1.87
@@ -9137,7 +9137,7 @@
   return 0;
 }
 _ACEOF
-for ac_lib in '' ncurses curses termcap termlib; do
+for ac_lib in '' tinfo ncurses curses termcap termlib; do
   if test -z "$ac_lib"; then
     ac_res="none required"
   else
--- LVM2/configure.in	2008/11/19 19:33:25	1.90
+++ LVM2/configure.in	2008/11/24 13:33:19	1.91
@@ -472,7 +472,7 @@
 ################################################################################
 dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
-	AC_SEARCH_LIBS([tgetent], [ncurses curses termcap termlib],
+	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
 	  [tg_found=yes], [tg_found=no])
 	test x$READLINE:$tg_found = xyes:no &&
 	  AC_MSG_ERROR(


