From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2010 01:10:48 -0000
Subject: LVM2 ./make.tmpl.in daemons/dmeventd/Makefile. ...
Message-ID: <20100119011048.6469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-19 01:10:47

Modified files:
	.              : make.tmpl.in 
	daemons/dmeventd: Makefile.in 
	libdm/misc     : dm-log-userspace.h 
	tools          : Makefile.in 

Log message:
	more build fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-log-userspace.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/make.tmpl.in	2009/10/09 15:55:31	1.73
+++ LVM2/make.tmpl.in	2010/01/19 01:10:46	1.74
@@ -54,7 +54,7 @@
 udevdir = $(DESTDIR)@udevdir@
 
 interface = @interface@
-interfacedir = $(top_srcdir)/libdm/$(interface)
+interfacebuilddir = $(top_builddir)/libdm/$(interface)
 
 # setup misc variables
 # define the ownership variables for the binaries and man pages
--- LVM2/daemons/dmeventd/Makefile.in	2009/11/13 12:48:01	1.30
+++ LVM2/daemons/dmeventd/Makefile.in	2010/01/19 01:10:47	1.31
@@ -64,8 +64,8 @@
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
 	$(LVMLIBS) $(LIBS) -rdynamic
 
-dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacedir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacedir) -o $@ \
+dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
 	dmeventd.o $(LVMLIBS) $(LIBS) -rdynamic
 
 ifeq ("@PKGCONFIG@", "yes")
--- LVM2/libdm/misc/dm-log-userspace.h	2009/08/13 20:51:41	1.1
+++ LVM2/libdm/misc/dm-log-userspace.h	2010/01/19 01:10:47	1.2
@@ -7,7 +7,7 @@
 #ifndef __DM_LOG_USERSPACE_H__
 #define __DM_LOG_USERSPACE_H__
 
-#include <linux/dm-ioctl.h> /* For DM_UUID_LEN */
+#include "dm-ioctl.h" /* For DM_UUID_LEN */
 
 /*
  * The device-mapper userspace log module consists of a kernel component and
--- LVM2/tools/Makefile.in	2009/10/13 01:31:10	1.102
+++ LVM2/tools/Makefile.in	2010/01/19 01:10:47	1.103
@@ -115,8 +115,8 @@
 	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/libdm \
 	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
 
-dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacedir) \
+dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
 	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
 
 all: device-mapper
@@ -125,8 +125,8 @@
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
-lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacedir) -o $@ \
+lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
 	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) \
 	      -rdynamic
 


