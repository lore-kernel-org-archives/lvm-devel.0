From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2009 14:04:38 -0000
Subject: LVM2 daemons/dmeventd/Makefile.in libdm/Makefi ...
Message-ID: <20090408140438.23134.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-04-08 14:04:36

Modified files:
	daemons/dmeventd: Makefile.in 
	libdm          : Makefile.in 
	liblvm         : Makefile.in 
	.              : WHATS_NEW 

Log message:
	Do not create some dm and lvm static librarie when they are not requested
	by configure option
	Add dependency for static dmeventd library

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1079&r2=1.1080

--- LVM2/daemons/dmeventd/Makefile.in	2008/11/04 17:25:32	1.23
+++ LVM2/daemons/dmeventd/Makefile.in	2009/04/08 14:04:35	1.24
@@ -17,7 +17,9 @@
 
 SOURCES = libdevmapper-event.c
 
+ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = libdevmapper-event.a
+endif
 LIB_VERSION = $(LIB_VERSION_DM)
 
 ifeq ("@LIB_SUFFIX@","dylib")
@@ -37,7 +39,7 @@
 include $(top_srcdir)/make.tmpl
 
 all: dmeventd
-device-mapper: dmeventd
+device-mapper: dmeventd $(LIB_STATIC)
 
 LDFLAGS += -ldl -ldevmapper -lpthread
 CLDFLAGS += -ldl -ldevmapper -lpthread
--- LVM2/libdm/Makefile.in	2009/03/16 20:00:10	1.44
+++ LVM2/libdm/Makefile.in	2009/04/08 14:04:35	1.45
@@ -34,7 +34,9 @@
 
 INCLUDES = -I$(interface) -I.
 
+ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
+endif
 
 ifeq ("@LIB_SUFFIX@","dylib")
   LIB_SHARED = $(interface)/libdevmapper.dylib
--- LVM2/liblvm/Makefile.in	2009/03/08 18:10:39	1.4
+++ LVM2/liblvm/Makefile.in	2009/04/08 14:04:35	1.5
@@ -23,7 +23,9 @@
 LIB_VERSION = $(LIB_VERSION_LVM)
 VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
 
+ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(LIB_NAME).a
+endif
 LIB_SHARED = $(LIB_NAME).so
 
 CLEAN_TARGETS += liblvm.cflow
--- LVM2/WHATS_NEW	2009/04/08 12:53:20	1.1079
+++ LVM2/WHATS_NEW	2009/04/08 14:04:35	1.1080
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Avoid creating some static libraries without static_link
   Enable use of cached metadata for pvs and pvdisplay commands.
   Add missing 'device-mapper' internal subdir build dependency.
   Fix memory leak in mirror allocation code.


