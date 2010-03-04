From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 09:56:03 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/lvm2 ...
Message-ID: <20100304095603.24301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 09:56:02

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	man            : Makefile.in 

Log message:
	Use consistently $() instead of ${} for all Makefile variables,
	thought both usage forms are correct.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1446&r2=1.1447
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2010/03/04 09:53:08	1.1446
+++ LVM2/WHATS_NEW	2010/03/04 09:56:01	1.1447
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Use consistently $() instead of ${} for all Makefile variables.
   Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.
   Use $(top_builddir) for inclusion of make.tmpl in Makefiles.
   Fix autoconf warning about ignored datarootdir.
--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/01/21 22:15:46	1.1
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/03/04 09:56:01	1.2
@@ -16,7 +16,7 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-CLDFLAGS += -L${top_builddir}/tools
+CLDFLAGS += -L$(top_builddir)/tools
 
 SOURCES = dmeventd_lvm.c
 
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/02/02 14:09:18	1.14
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/03/04 09:56:01	1.15
@@ -17,8 +17,8 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-INCLUDES += -I${top_srcdir}/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L${top_builddir}/tools -L${top_builddir}/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_mirror.c
 
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/02/02 14:09:18	1.10
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/03/04 09:56:01	1.11
@@ -17,8 +17,8 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-INCLUDES += -I${top_srcdir}/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L${top_builddir}/tools -L${top_builddir}/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_snapshot.c
 
--- LVM2/man/Makefile.in	2010/03/04 09:51:40	1.31
+++ LVM2/man/Makefile.in	2010/03/04 09:56:01	1.32
@@ -43,8 +43,8 @@
 endif
 
 MAN8DM=dmsetup.8
-MAN5DIR=${mandir}/man5
-MAN8DIR=${mandir}/man8
+MAN5DIR=$(mandir)/man5
+MAN8DIR=$(mandir)/man8
 
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
 


