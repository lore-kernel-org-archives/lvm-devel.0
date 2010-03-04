From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 11:09:10 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20100304110910.11595.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 11:09:09

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	As fsadm is installed by default - it's a common practice to rather
	print help text in '--disable' form for such case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1447&r2=1.1448
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/WHATS_NEW	2010/03/04 09:56:01	1.1447
+++ LVM2/WHATS_NEW	2010/03/04 11:09:08	1.1448
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Help for configure prints --disable-fsadm.
   Use consistently $() instead of ${} for all Makefile variables.
   Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.
   Use $(top_builddir) for inclusion of make.tmpl in Makefiles.
--- LVM2/configure	2010/01/21 22:15:45	1.115
+++ LVM2/configure	2010/03/04 11:09:08	1.116
@@ -1524,7 +1524,7 @@
   --enable-applib         Build application library
   --enable-cmdlib         Build shared command library
   --enable-pkgconfig      Install pkgconfig support
-  --enable-fsadm          Enable fsadm
+  --disable-fsadm         Disable fsadm
   --enable-dmeventd       Enable the device-mapper event daemon
   --disable-selinux       Disable selinux support
   --enable-nls            Enable Native Language Support
--- LVM2/configure.in	2010/03/04 09:46:38	1.125
+++ LVM2/configure.in	2010/03/04 11:09:09	1.126
@@ -737,8 +737,8 @@
 ################################################################################
 dnl -- Enable fsadm
 AC_MSG_CHECKING(whether to install fsadm)
-AC_ARG_ENABLE(fsadm, [  --enable-fsadm          Enable fsadm],
-FSADM=$enableval)
+AC_ARG_ENABLE(fsadm, [AC_HELP_STRING([--disable-fsadm], [Disable fsadm])],
+	FSADM=$enableval)
 AC_MSG_RESULT($FSADM)
 
 ################################################################################


