From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:00:47 -0000
Subject: LVM2 ./WHATS_NEW doc/Makefile.in libdm/Makefil ...
Message-ID: <20100803130047.29679.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:00:46

Modified files:
	.              : WHATS_NEW 
	doc            : Makefile.in 
	libdm          : Makefile.in 
	liblvm         : Makefile.in 
	tools          : Makefile.in 

Log message:
	Clean generated files .exported_symbols_generated, example.conf for distclean.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1688&r2=1.1689
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2010/08/02 21:07:40	1.1688
+++ LVM2/WHATS_NEW	2010/08/03 13:00:45	1.1689
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Clean generated files .exported_symbols_generated, example.conf for distclean.
   Handle failure of all mirrored log devices and all but one mirror leg. 
   Disallow 'mirrored' log type for cluster mirrors.
   Do not use VPATH in include/Makefile.
--- LVM2/doc/Makefile.in	2010/05/20 11:45:57	1.10
+++ LVM2/doc/Makefile.in	2010/08/03 13:00:45	1.11
@@ -27,3 +27,5 @@
 	fi
 
 install: install_lvm2
+
+DISTCLEAN_TARGETS += $(CONFSRC)
--- LVM2/libdm/Makefile.in	2010/06/25 18:17:39	1.56
+++ LVM2/libdm/Makefile.in	2010/08/03 13:00:46	1.57
@@ -94,4 +94,4 @@
 	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 CLEAN_TARGETS += ioctl/libdevmapper.a
-DISTCLEAN_TARGETS += libdevmapper.pc
+DISTCLEAN_TARGETS += libdevmapper.pc .exported_symbols_generated
--- LVM2/liblvm/Makefile.in	2010/06/25 18:17:39	1.25
+++ LVM2/liblvm/Makefile.in	2010/08/03 13:00:46	1.26
@@ -78,4 +78,4 @@
 
 cflow: liblvm.cflow
 
-DISTCLEAN_TARGETS += $(LIB_NAME).pc
+DISTCLEAN_TARGETS += $(LIB_NAME).pc .exported_symbols_generated
--- LVM2/tools/Makefile.in	2010/06/25 18:23:10	1.120
+++ LVM2/tools/Makefile.in	2010/08/03 13:00:46	1.121
@@ -202,3 +202,5 @@
 install_lvm2: $(INSTALL_LVM_TARGETS)
 
 install: install_lvm2 install_device-mapper
+
+DISTCLEAN_TARGETS += .exported_symbols_generated


