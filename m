From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 11:12:43 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in daemons/clvmd/ ...
Message-ID: <20100304111243.12464.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 11:12:40

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	daemons/clvmd  : Makefile.in 
	liblvm         : Makefile.in 
	tools          : Makefile.in 

Log message:
	Introduce LVMINTERNAL_LIBS
	
	Keep dependency libraries for liblvm-internal in one place.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1448&r2=1.1449
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/WHATS_NEW	2010/03/04 11:09:08	1.1448
+++ LVM2/WHATS_NEW	2010/03/04 11:12:39	1.1449
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Define and use internal makefile variable LVMINTERNAL_LIBS.
   Help for configure prints --disable-fsadm.
   Use consistently $() instead of ${} for all Makefile variables.
   Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.
--- LVM2/make.tmpl.in	2010/03/04 09:53:08	1.77
+++ LVM2/make.tmpl.in	2010/03/04 11:12:39	1.78
@@ -36,6 +36,7 @@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
+LVMINTERNAL_LIBS = -llvm-internal
 
 # Setup directory variables
 prefix = @prefix@
--- LVM2/daemons/clvmd/Makefile.in	2010/03/04 09:51:37	1.33
+++ LVM2/daemons/clvmd/Makefile.in	2010/03/04 11:12:39	1.34
@@ -75,7 +75,7 @@
 TARGETS = \
 	clvmd
 
-LVMLIBS = -llvm-internal -lpthread
+LVMLIBS = $(LVMINTERNAL_LIBS) -lpthread
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
--- LVM2/liblvm/Makefile.in	2010/03/04 09:51:40	1.19
+++ LVM2/liblvm/Makefile.in	2010/03/04 11:12:40	1.20
@@ -42,7 +42,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper -llvm-internal
+LIBS += $(LVMINTERNAL_LIBS) -ldevmapper
 
 ifeq ("@DMEVENTD@", "yes")
   LIBS += -ldevmapper-event
--- LVM2/tools/Makefile.in	2010/03/04 09:53:08	1.105
+++ LVM2/tools/Makefile.in	2010/03/04 11:12:40	1.106
@@ -86,7 +86,7 @@
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = -llvm-internal
+LVMLIBS = $(LVMINTERNAL_LIBS)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \


