From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 12:03:55 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/Makefile.in ...
Message-ID: <20100304120355.18158.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 12:03:54

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: Makefile.in 
	tools          : Makefile.in 

Log message:
	Removes -rdynamic from linking of lvm.static and dmeventd.static.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1450&r2=1.1451
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2010/03/04 11:21:05	1.1450
+++ LVM2/WHATS_NEW	2010/03/04 12:03:54	1.1451
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Remove -rdynamic from static builds.
   Update check for pthread library and link it only when needed.
   Define and use internal makefile variable PTHREAD_LIBS.
   Update check for readline library and link it only when needed.
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/04 11:21:05	1.33
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/04 12:03:54	1.34
@@ -66,7 +66,7 @@
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(LVMLIBS) $(LIBS) -rdynamic
+	dmeventd.o $(LVMLIBS) $(LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
--- LVM2/tools/Makefile.in	2010/03/04 11:21:06	1.108
+++ LVM2/tools/Makefile.in	2010/03/04 12:03:54	1.109
@@ -125,8 +125,7 @@
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) \
-	      -rdynamic
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@


