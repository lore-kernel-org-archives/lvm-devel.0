From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:00:54 -0000
Subject: LVM2 WHATS_NEW configure.in make.tmpl.in
Message-ID: <20110110130054.2132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:00:53

Modified files:
	.              : WHATS_NEW configure.in make.tmpl.in 

Log message:
	Improve OCF dir support
	
	Add --with-ocfdir configurable option.
	Fix superfluous /usr in ocf_scriptdir instalation path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1864&r2=1.1865
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW	2011/01/07 16:27:05	1.1864
+++ LVM2/WHATS_NEW	2011/01/10 13:00:53	1.1865
@@ -1,5 +1,7 @@
 Version 2.02.80 - 
 ====================================
+  Fix superfluous /usr in ocf_scriptdir instalation path.
+  Add --with-ocfdir configurable option.
   Add aclocal.m4 (for pkgconfig).
   Fix memory leak in filter creation error path.
   Add missing tests in _setup_task().
--- LVM2/configure.in	2010/12/13 10:43:56	1.158
+++ LVM2/configure.in	2011/01/10 13:00:53	1.159
@@ -368,6 +368,10 @@
 			     [enable Open Cluster Framework (OCF) compliant resource agents]),
 	      OCF=$enableval, OCF=no)
 AC_MSG_RESULT($OCF)
+AC_ARG_WITH(ocfdir,
+	    AC_HELP_STRING([--with-ocfdir=DIR],
+			   [install OCF files in DIR [[PREFIX/lib/ocf/resource.d/lvm2]]]),
+	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
 ################################################################################
 dnl -- Init pkg-config with dummy invokation:
@@ -1328,6 +1332,7 @@
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(OCF)
+AC_SUBST(OCFDIR)
 AC_SUBST(REPLICATORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(PKGCONFIG)
--- LVM2/make.tmpl.in	2010/11/05 16:18:38	1.114
+++ LVM2/make.tmpl.in	2011/01/10 13:00:53	1.115
@@ -65,7 +65,7 @@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
-ocf_scriptdir = $(DESTDIR)@prefix@/usr/lib/ocf/resource.d/lvm2
+ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)


