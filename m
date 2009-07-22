From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jul 2009 21:09:15 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20090722210915.8844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-22 21:09:14

Modified files:
	.              : WHATS_NEW configure configure.in 
	liblvm         : Makefile.in 
Added files:
	liblvm         : liblvm2app.pc 

Log message:
	Add liblvm2app Makefile installation targets.
	Add liblvm pkgconfig file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1197&r2=1.1198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/liblvm2app.pc.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2009/07/22 20:12:14	1.1197
+++ LVM2/WHATS_NEW	2009/07/22 21:09:13	1.1198
@@ -1,5 +1,7 @@
 Version 2.02.50 - 
 ================================
+  Add liblvm2app Makefile installation targets.
+  Add liblvm pkgconfig file.
   Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.
   Add an API version number, LVM_LIBAPI, to the VERSION string for liblvm.
   Pass a pointer to struct cmd_context to init_multiple_segtypes
--- LVM2/configure	2009/07/22 20:01:28	1.95
+++ LVM2/configure	2009/07/22 21:09:13	1.96
@@ -12685,7 +12685,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13305,6 +13305,7 @@
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
+    "liblvm/liblvm2app.pc") CONFIG_FILES="$CONFIG_FILES liblvm/liblvm2app.pc" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
--- LVM2/configure.in	2009/07/22 20:01:29	1.100
+++ LVM2/configure.in	2009/07/22 21:09:14	1.101
@@ -852,6 +852,7 @@
 libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile
+liblvm/liblvm2app.pc
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
/cvs/lvm2/LVM2/liblvm/liblvm2app.pc,v  -->  standard output
revision 1.1
--- LVM2/liblvm/liblvm2app.pc
+++ -	2009-07-22 21:09:14.960422000 +0000
@@ -0,0 +1,11 @@
+prefix=/usr
+exec_prefix=
+libdir=${exec_prefix}/lib
+includedir=${prefix}/include
+
+Name: lvm2app
+Description: lvm2 application library
+Version: 2.1
+Cflags: -I${includedir} 
+Libs: -L${libdir} -llvm2app
+Libs.private: -ldevmapper
--- LVM2/liblvm/Makefile.in	2009/07/22 20:29:56	1.9
+++ LVM2/liblvm/Makefile.in	2009/07/22 21:09:14	1.10
@@ -25,9 +25,14 @@
 VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_APP)
 
 ifeq ("@STATIC_LINK@", "yes")
-LIB_STATIC = $(LIB_NAME).a
+  LIB_STATIC = $(LIB_NAME).a
+endif
+
+ifeq ("@LIB_SUFFIX@","dylib")
+  LIB_SHARED = $(LIB_NAME).dylib
+else
+  LIB_SHARED = $(LIB_NAME).so
 endif
-LIB_SHARED = $(LIB_NAME).so
 
 CLEAN_TARGETS += liblvm.cflow
 
@@ -35,10 +40,43 @@
 
 LIBS += -ldevmapper -llvm-internal
 
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): %.$(LIB_SUFFIX)
+$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_APP): %.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
 
+.PHONY: install_dynamic install_static install_include install_pkgconfig \
+	distclean_lib distclean
+
+INSTALL_TYPE = install_dynamic
+
+ifeq ("@STATIC_LINK@", "yes")
+  INSTALL_TYPE += install_static
+endif
+
+ifeq ("@PKGCONFIG@", "yes")
+  INSTALL_TYPE += install_pkgconfig
+endif
+
+install: $(INSTALL_TYPE) install_include
+
+install_include:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm.h $(includedir)/lvm.h
+
+install_dynamic: $(LIB_SHARED)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+		$(libdir)/$(LIB_SHARED).$(LIB_VERSION_APP)
+	$(LN_S) -f $(LIB_SHARED).$(LIB_VERSION_APP) \
+		$(libdir)/$(LIB_SHARED)
+
+install_static: $(LIB_STATIC)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+		$(libdir)/$(LIB_STATIC).$(LIB_VERSION_APP)
+	$(LN_S) -f $(LIB_STATIC).$(LIB_VERSION_APP) $(libdir)/$(LIB_STATIC)
+
+install_pkgconfig:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
+		$(usrlibdir)/pkgconfig/$(LIB_NAME).pc
+
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
 		 echo $(SOURCES) | \
@@ -46,3 +84,10 @@
 		 ) > $@
 
 cflow: liblvm.cflow
+
+CLEAN_TARGETS += $(LIB_NAME).$(LIB_SUFFIX)
+
+distclean_lib:
+	$(RM) $(LIB_NAME).pc
+
+distclean: distclean_lib


