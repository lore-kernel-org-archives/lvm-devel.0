From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Apr 2010 13:58:12 -0000
Subject: LVM2 scripts/relpath.awk ./configure.in ./make ...
Message-ID: <20100430135812.5148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-30 13:58:11

Modified files:
	scripts        : relpath.awk 
	.              : configure.in make.tmpl.in 

Log message:
	change awk path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/relpath.awk.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/scripts/relpath.awk	2010/04/15 15:06:27	1.1
+++ LVM2/scripts/relpath.awk	2010/04/30 13:58:08	1.2
@@ -1,4 +1,4 @@
-#!/usr/bin/awk -f
+#!/bin/awk -f
 #
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
--- LVM2/configure.in	2010/04/09 21:42:48	1.135
+++ LVM2/configure.in	2010/04/30 13:58:10	1.136
@@ -1048,6 +1048,7 @@
 
 ################################################################################
 AC_SUBST(APPLIB)
+AC_SUBST(AWK)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CCS_CFLAGS)
--- LVM2/make.tmpl.in	2010/04/15 15:12:20	1.92
+++ LVM2/make.tmpl.in	2010/04/30 13:58:10	1.93
@@ -28,6 +28,7 @@
 LN_S = @LN_S@
 SED = @SED@
 CFLOW_CMD = @CFLOW_CMD@
+AWK = @AWK@
 
 LIBS = @LIBS@
 # Extra libraries always linked with static binaries
@@ -63,7 +64,7 @@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
-  awk -f $(top_srcdir)/scripts/relpath.awk)
+  $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
@@ -142,13 +143,13 @@
 LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
 
 LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
-		     awk -F '.' '{printf "%s.%s",$$1,$$2}')
+		     $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}')
 
 LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
-		    awk -F '.' '{printf "%s.%s",$$1,$$2}')
+		    $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}')
 
 LIB_VERSION_APP := $(shell cat $(top_srcdir)/VERSION | \
-		     awk -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
+		     $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
 
 INCLUDES += -I. -I$(top_builddir)/include
 


