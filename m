From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 00:29:12 -0000
Subject: LVM2/daemons Makefile.in lvmetad/Makefile.in
Message-ID: <20110919002912.12809.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 00:29:12

Modified files:
	daemons        : Makefile.in 
	daemons/lvmetad: Makefile.in 

Log message:
	Few more updates to lvmetad build deps
	
	It seem lvmetad deps must be expressed after the include.
	Also adding lvmetad deps to device-mapper target in daemons dir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/daemons/Makefile.in	2011/09/17 14:50:22	1.20
+++ LVM2/daemons/Makefile.in	2011/09/19 00:29:11	1.21
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -20,13 +20,12 @@
 
 LIB_STATIC = libdaemon.a
 SOURCES = common/daemon-shared.c common/daemon-server.c common/daemon-client.c
-lvmetad.device-mapper: $(LIB_STATIC)
 endif
 
 .PHONY: dmeventd clvmd cmirrord lvmetad
 
 ifneq ("@CLVMD@", "none")
-  SUBDIRS = clvmd
+  SUBDIRS += clvmd
 endif
 
 ifeq ("@BUILD_CMIRRORD@", "yes")
@@ -49,3 +48,9 @@
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
 endif
+
+ifeq ("@BUILD_LVMETAD@", "yes")
+device-mapper: lvmetad.device-mapper
+lvmetad.device-mapper: $(LIB_STATIC)
+endif
+
--- LVM2/daemons/lvmetad/Makefile.in	2011/09/17 14:50:23	1.2
+++ LVM2/daemons/lvmetad/Makefile.in	2011/09/19 00:29:12	1.3
@@ -31,10 +31,9 @@
 
 include $(top_builddir)/make.tmpl
 
-all: device-mapper
 device-mapper: $(TARGETS)
 
-LIBS += -ldevmapper -ldaemon -lpthread
+LIBS += -ldevmapper -ldaemon $(PTHREAD_LIBS)
 
 lvmetad: lvmetad-core.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/daemons -o $@ lvmetad-core.o \


