From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 09:48:19 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20100304094819.20054.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 09:48:19

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Use datarootdir and fix warning during configure process:
	config.status: WARNING:  'make.tmpl.in' seems to ignore the --datarootdir setting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1443&r2=1.1444
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2010/03/04 09:46:38	1.1443
+++ LVM2/WHATS_NEW	2010/03/04 09:48:19	1.1444
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Fix autoconf warning about ignored datarootdir.
   Increase AC_PREREQ version to 2.61 (for AC_PROC_SED, AC_PROG_MKDIR_P).
   Handle a misaligned device that reports a -1 alignment_offset.
   Extend core allocation code in preparation for mirrored log areas.
--- LVM2/make.tmpl.in	2010/01/22 13:20:32	1.75
+++ LVM2/make.tmpl.in	2010/03/04 09:48:19	1.76
@@ -47,6 +47,7 @@
 usrlibdir = $(DESTDIR)@usrlibdir@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
+datarootdir = $(DESTDIR)@datarootdir@
 infodir = $(DESTDIR)@infodir@
 mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@


