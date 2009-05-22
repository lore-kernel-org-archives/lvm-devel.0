From: agk@sourceware.org <agk@sourceware.org>
Date: 22 May 2009 14:45:01 -0000
Subject: LVM2 ./Makefile.in ./VERSION ./WHATS_NEW ./con ...
Message-ID: <20090522144501.13295.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-22 14:45:00

Modified files:
	.              : Makefile.in VERSION WHATS_NEW configure 
	                 configure.in 
	liblvm         : Makefile.in 
	test/api       : Makefile.in 

Log message:
	Rename liblvm.so to liblvm2app.so and use configure --enable-applib.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1122&r2=1.1123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/Makefile.in	2009/03/16 18:28:04	1.32
+++ LVM2/Makefile.in	2009/05/22 14:44:59	1.33
@@ -22,7 +22,11 @@
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm liblvm
+SUBDIRS += lib tools daemons libdm
+
+ifeq ("@APPLIB@", "yes")
+  SUBDIRS += liblvm
+endif
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
@@ -46,7 +50,7 @@
 lib: libdm
 liblvm: lib
 daemons: lib tools
-tools: lib device-mapper liblvm
+tools: lib device-mapper
 po: tools daemons
 
 libdm.device-mapper: include.device-mapper
--- LVM2/VERSION	2009/05/21 03:04:52	1.194
+++ LVM2/VERSION	2009/05/22 14:44:59	1.195
@@ -1 +1 @@
-2.02.46-cvs (2009-05-21)
+2.02.47-cvs (2009-05-22)
--- LVM2/WHATS_NEW	2009/05/21 11:11:30	1.1122
+++ LVM2/WHATS_NEW	2009/05/22 14:44:59	1.1123
@@ -1,5 +1,6 @@
-Version 2.02.47 - 21st May 2009
+Version 2.02.47 - 22nd May 2009
 ===============================
+  Rename liblvm.so to liblvm2app.so and use configure --enable-applib.
   Reinstate version in liblvm2cmd.so soname. (2.02.44)
 
 Version 2.02.46 - 21st May 2009
--- LVM2/configure	2009/04/24 21:44:15	1.93
+++ LVM2/configure	2009/05/22 14:44:59	1.94
@@ -690,9 +690,11 @@
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 BUILD_DMEVENTD
+APPLIB
 MODPROBE_CMD
 MSGFMT
 LVM2CMD_LIB
+LVM2APP_LIB
 GENHTML
 LCOV
 CPG_LIBS
@@ -800,6 +802,7 @@
 enable_compat
 enable_ioctl
 enable_o_direct
+enable_applib
 enable_cmdlib
 enable_pkgconfig
 enable_fsadm
@@ -1467,6 +1470,7 @@
   --enable-compat         Enable support for old device-mapper versions
   --disable-driver        Disable calls to device-mapper in the kernel
   --disable-o_direct      Disable O_DIRECT
+  --enable-applib         Build application library
   --enable-cmdlib         Build shared command library
   --enable-pkgconfig      Install pkgconfig support
   --enable-fsadm          Enable fsadm
@@ -9707,6 +9711,23 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to build liblvm2app.so application library" >&5
+$as_echo_n "checking whether to build liblvm2app.so application library... " >&6; }
+# Check whether --enable-applib was given.
+if test "${enable_applib+set}" = set; then
+  enableval=$enable_applib; APPLIB=$enableval
+else
+  APPLIB=no
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $APPLIB" >&5
+$as_echo "$APPLIB" >&6; }
+
+test x$APPLIB = xyes \
+  && LVM2APP_LIB=-llvm2app \
+  || LVM2APP_LIB=
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to compile liblvm2cmd.so" >&5
 $as_echo_n "checking whether to compile liblvm2cmd.so... " >&6; }
 # Check whether --enable-cmdlib was given.
@@ -12659,6 +12680,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
--- LVM2/configure.in	2009/04/24 21:44:15	1.98
+++ LVM2/configure.in	2009/05/22 14:44:59	1.99
@@ -424,6 +424,18 @@
 fi
 
 ################################################################################
+dnl -- Enable liblvm2app.so
+AC_MSG_CHECKING(whether to build liblvm2app.so application library)
+AC_ARG_ENABLE(applib,
+  [  --enable-applib         Build application library],
+  APPLIB=$enableval, APPLIB=no)
+AC_MSG_RESULT($APPLIB)
+AC_SUBST([LVM2APP_LIB])
+test x$APPLIB = xyes \
+  && LVM2APP_LIB=-llvm2app \
+  || LVM2APP_LIB=
+
+################################################################################
 dnl -- Enable cmdlib
 AC_MSG_CHECKING(whether to compile liblvm2cmd.so)
 AC_ARG_ENABLE(cmdlib, [  --enable-cmdlib         Build shared command library],
@@ -747,6 +759,7 @@
 LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
 
 ################################################################################
+AC_SUBST(APPLIB)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
--- LVM2/liblvm/Makefile.in	2009/04/08 14:04:35	1.5
+++ LVM2/liblvm/Makefile.in	2009/05/22 14:45:00	1.6
@@ -19,7 +19,7 @@
 SOURCES =\
 	lvm_base.c
 
-LIB_NAME = liblvm
+LIB_NAME = liblvm2app
 LIB_VERSION = $(LIB_VERSION_LVM)
 VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
 
--- LVM2/test/api/Makefile.in	2009/04/28 19:08:25	1.5
+++ LVM2/test/api/Makefile.in	2009/05/22 14:45:00	1.6
@@ -25,7 +25,7 @@
 
 TARGETS = test
 
-LVMLIBS = -llvm -ldevmapper
+LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
@@ -35,6 +35,6 @@
 LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 CLDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 
-test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm.so $(top_srcdir)/libdm/libdevmapper.so
+test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
 	$(CC) -o test $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
 


