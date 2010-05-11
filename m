From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:57:08 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in daemons/dmeven ...
Message-ID: <20100511085708.13103.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:57:04

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	daemons/dmeventd: Makefile.in 
	libdm          : Makefile.in 
	liblvm         : Makefile.in 

Log message:
	Add pkgconfigdir for placement of .pc files
	
	Use easily overideable make install pkgconfigdir variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1554&r2=1.1555
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2010/05/11 08:54:11	1.1554
+++ LVM2/WHATS_NEW	2010/05/11 08:57:02	1.1555
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Add pkgconfigdir Makefile variable for make install override.
   Switch usage of Libs.private: to Requires.private: in devmapper.pc, lvm2app.pc.
   Use field Requires.private: for devmapper-event.pc.
   Add devmapper library to linked libdevmapper-event.so.
--- LVM2/make.tmpl.in	2010/05/11 08:43:18	1.96
+++ LVM2/make.tmpl.in	2010/05/11 08:57:02	1.97
@@ -63,6 +63,7 @@
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
+pkgconfigdir = $(usrlibdir)/pkgconfig
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
--- LVM2/daemons/dmeventd/Makefile.in	2010/05/11 08:38:10	1.42
+++ LVM2/daemons/dmeventd/Makefile.in	2010/05/11 08:57:02	1.43
@@ -81,7 +81,7 @@
 	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_pkgconfig: libdevmapper-event.pc
-	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/devmapper-event.pc
+	$(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper-event.pc
 
 install_lib_dynamic: install_lib_shared
 
--- LVM2/libdm/Makefile.in	2010/04/09 21:42:51	1.54
+++ LVM2/libdm/Makefile.in	2010/05/11 08:57:03	1.55
@@ -85,7 +85,7 @@
 install_ioctl: install_lib_shared
 
 install_pkgconfig: libdevmapper.pc
-	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/devmapper.pc
+	$(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper.pc
 
 install_ioctl_static: $(LIB_STATIC)
 	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
--- LVM2/liblvm/Makefile.in	2010/04/09 21:42:51	1.22
+++ LVM2/liblvm/Makefile.in	2010/05/11 08:57:03	1.23
@@ -65,7 +65,7 @@
 	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 install_pkgconfig: $(LIB_NAME).pc
-	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/lvm2app.pc
+	$(INSTALL_DATA) -D $< $(pkgconfigdir)/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \


