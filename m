From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2009 14:08:24 -0000
Subject: LVM2 tools/Makefile.in ./make.tmpl.in ./WHATS_NEW
Message-ID: <20090408140824.1188.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-04-08 14:08:23

Modified files:
	tools          : Makefile.in 
	.              : make.tmpl.in WHATS_NEW 

Log message:
	Avoid referencing files from DESTDIR during build process

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1080&r2=1.1081

--- LVM2/tools/Makefile.in	2009/03/16 20:00:11	1.93
+++ LVM2/tools/Makefile.in	2009/04/08 14:08:05	1.94
@@ -103,11 +103,11 @@
 
 dmsetup: dmsetup.o $(top_srcdir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \
-	      -L$(top_srcdir)/libdm -L$(DESTDIR)/lib -ldevmapper $(LIBS)
+	      -L$(top_srcdir)/libdm -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) -static \
-	      -L$(interfacedir) -L$(DESTDIR)/lib -ldevmapper $(LIBS) \
+	      -L$(interfacedir) -ldevmapper $(LIBS) \
 	      $(LIB_PTHREAD)
 
 all: device-mapper
--- LVM2/make.tmpl.in	2009/04/07 22:53:48	1.65
+++ LVM2/make.tmpl.in	2009/04/08 14:08:18	1.66
@@ -118,10 +118,6 @@
 
 INCLUDES += -I. -I$(top_srcdir)/include
 
-ifdef DESTDIR
-  INCLUDES += -I$(DESTDIR)/usr/include
-endif
-
 INC_LNS = $(top_srcdir)/include/.symlinks_created
 
 DEPS = $(top_srcdir)/make.tmpl $(top_srcdir)/VERSION Makefile $(INC_LNS)
--- LVM2/WHATS_NEW	2009/04/08 14:04:35	1.1080
+++ LVM2/WHATS_NEW	2009/04/08 14:08:23	1.1081
@@ -1,6 +1,7 @@
 Version 2.02.46 - 
 ================================
-  Avoid creating some static libraries without static_link
+  Avoid referencing files from DESTDIR during build process.
+  Avoid creating some static libraries without static_link.
   Enable use of cached metadata for pvs and pvdisplay commands.
   Add missing 'device-mapper' internal subdir build dependency.
   Fix memory leak in mirror allocation code.


