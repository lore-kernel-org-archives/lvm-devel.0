From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2008 15:55:30 -0000
Subject: LVM2 ./Makefile.in ./make.tmpl.in daemons/Make ...
Message-ID: <20081104155530.4789.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-04 15:55:28

Modified files:
	.              : Makefile.in make.tmpl.in 
	daemons        : Makefile.in 
	daemons/dmeventd: Makefile.in 
Removed files:
	dmeventd       : Makefile.in 
	dmeventd/mirror: .exported_symbols Makefile.in dmeventd_mirror.c 
	dmeventd/snapshot: .exported_symbols Makefile.in 
	                   dmeventd_snapshot.c 

Log message:
	dmeventd

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.20&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.3&r2=NONE

--- LVM2/Makefile.in	2008/11/03 23:01:21	1.27
+++ LVM2/Makefile.in	2008/11/04 15:55:26	1.28
@@ -43,13 +43,13 @@
 libdm: include
 lib: libdm
 daemons: lib
-tools: lib
+tools: lib device-mapper
 po: tools daemons
 
 libdm.device-mapper: include.device-mapper
 daemons.device-mapper: libdm.device-mapper
 tools.device-mapper: libdm.device-mapper
-device-mapper: tools.device-mapper daemons.device-mapper
+device-mapper: tools.device-mapper daemons.device-mapper man.device-mapper
 
 ifeq ("@INTL@", "yes")
 lib.pofile: include.pofile
--- LVM2/make.tmpl.in	2008/11/04 14:57:05	1.61
+++ LVM2/make.tmpl.in	2008/11/04 15:55:26	1.62
@@ -86,6 +86,11 @@
 LDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
 CLDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
 
+ifeq ("@DMEVENTD@", "yes")
+  LDFLAGS += -L$(top_srcdir)/daemons/dmeventd
+  CLDFLAGS += -L$(top_srcdir)/daemons/dmeventd
+endif
+
 ifeq ("@DM_COMPAT@", "yes")
   DEFS += -DDM_COMPAT
 endif
--- LVM2/daemons/Makefile.in	2008/11/03 23:01:21	1.5
+++ LVM2/daemons/Makefile.in	2008/11/04 15:55:26	1.6
@@ -15,6 +15,8 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
+.PHONY: dmeventd clvmd
+
 ifneq ("@CLVMD@", "none")
   SUBDIRS = clvmd
 endif
@@ -23,7 +25,6 @@
   SUBDIRS += dmeventd
 endif
 
-device-mapper: dmeventd
-
 include $(top_srcdir)/make.tmpl
 
+device-mapper: dmeventd.device-mapper
--- LVM2/daemons/dmeventd/Makefile.in	2008/11/03 23:01:21	1.21
+++ LVM2/daemons/dmeventd/Makefile.in	2008/11/04 15:55:27	1.22
@@ -37,6 +37,7 @@
 include $(top_srcdir)/make.tmpl
 
 all: dmeventd
+device-mapper: dmeventd
 
 LDFLAGS += -ldl -ldevmapper -lpthread
 CLDFLAGS += -ldl -ldevmapper -lpthread


