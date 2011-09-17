From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Sep 2011 14:50:24 -0000
Subject: LVM2/daemons Makefile.in lvmetad/Makefile.in
Message-ID: <20110917145024.20030.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-17 14:50:23

Modified files:
	daemons        : Makefile.in 
	daemons/lvmetad: Makefile.in 

Log message:
	Build fixes for lvmetad
	
	Should now be giving better build order and install lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/Makefile.in	2011/09/02 14:49:00	1.19
+++ LVM2/daemons/Makefile.in	2011/09/17 14:50:22	1.20
@@ -16,8 +16,11 @@
 top_builddir = @top_builddir@
 
 ifeq ("@BUILD_LVMETAD@", "yes")
-LIB_STATIC=libdaemon.a
+  SUBDIRS += lvmetad
+
+LIB_STATIC = libdaemon.a
 SOURCES = common/daemon-shared.c common/daemon-server.c common/daemon-client.c
+lvmetad.device-mapper: $(LIB_STATIC)
 endif
 
 .PHONY: dmeventd clvmd cmirrord lvmetad
@@ -30,12 +33,6 @@
   SUBDIRS += cmirrord
 endif
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += lvmetad
-# FIXME: build dependency order needs rule fixing, using hack
-all: libdaemon.a
-endif
-
 ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
 ifneq ("$(CFLOW_CMD)", "")
--- LVM2/daemons/lvmetad/Makefile.in	2011/08/31 11:31:58	1.1
+++ LVM2/daemons/lvmetad/Makefile.in	2011/09/17 14:50:23	1.2
@@ -19,11 +19,9 @@
 
 TARGETS = lvmetad lvmetad-testclient
 
-.PHONY: install_lib_dynamic install_lib_static install_include \
-	install_pkgconfig install_dmeventd_dynamic install_dmeventd_static \
-	install_lib install_dmeventd
+.PHONY: install_lvmetad
 
-INCLUDES += -I$(top_srcdir)/daemons/common/
+INCLUDES += -I$(top_srcdir)/daemons/common
 INSTALL_LVMETAD_TARGETS = install_lvmetad
 CLEAN_TARGETS = lvmetad lvmetad-testclient
 
@@ -52,7 +50,8 @@
 #-include $(top_builddir)/daemons/dmeventd/plugins/mirror/$(LIB_NAME)-lvm2mirror.cflow
 #endif
 
-install_lvmetad: $(INSTALL_DMEVENTD_TARGETS)
+install_lvmetad: lvmetad
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install: install_lvmetad
 


