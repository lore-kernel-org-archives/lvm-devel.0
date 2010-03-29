From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:07:02 -0000
Subject: LVM2/daemons/dmeventd Makefile.in
Message-ID: <20100329140702.16895.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:07:01

Modified files:
	daemons/dmeventd: Makefile.in 

Log message:
	Add $(LIB_STATIC) to TARGETS so it's cleaned in the same way
	as other libraries in project.
	Add dmeventd.gcda dmeventd.gcno to CLEAN_TARGETS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/daemons/dmeventd/Makefile.in	2010/03/04 12:10:41	1.36
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/29 14:07:01	1.37
@@ -26,9 +26,10 @@
 INSTALL_DMEVENTD_TARGETS = install_dmeventd_dynamic
 INSTALL_LIB_TARGETS = install_lib_dynamic
 
+LIB_NAME = libdevmapper-event
 ifeq ("@STATIC_LINK@", "yes")
-  LIB_STATIC = libdevmapper-event.a
-  TARGETS += dmeventd.static
+  LIB_STATIC = $(LIB_NAME).a
+  TARGETS += $(LIB_STATIC) dmeventd.static
   INSTALL_DMEVENTD_TARGETS += install_dmeventd_static
   INSTALL_LIB_TARGETS += install_lib_static
 endif
@@ -36,13 +37,13 @@
 LIB_VERSION = $(LIB_VERSION_DM)
 
 ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = libdevmapper-event.dylib
+  LIB_SHARED = $(LIB_NAME).dylib
 else
-  LIB_SHARED = libdevmapper-event.so
+  LIB_SHARED = $(LIB_NAME).so
   VERSIONED_SHLIB = $(LIB_SHARED).$(LIB_VERSION)
 endif
 
-CLEAN_TARGETS = dmeventd.o dmeventd.static
+CLEAN_TARGETS = dmeventd.o dmeventd.static dmeventd.gcda dmeventd.gcno
 
 ifneq ($(MAKECMDGOALS),device-mapper)
   SUBDIRS+=plugins


