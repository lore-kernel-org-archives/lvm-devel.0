From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 12:10:42 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in ./ ...
Message-ID: <20100304121042.20736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 12:10:41

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 
	daemons/dmeventd: Makefile.in 

Log message:
	Use DL_LIBS, remove -ldl from global LIBS and link -ldl only when needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1452&r2=1.1453
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/03/04 12:08:26	1.1452
+++ LVM2/WHATS_NEW	2010/03/04 12:10:40	1.1453
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Define and use internal makefile variable DL_LIBS.
   Update check for selinux libraries and link them only when needed.
   Define and use internal makefile variable SELINUX_LIBS and STATIC_LIBS.
   Remove -rdynamic from static builds.
--- LVM2/configure	2010/03/04 12:08:26	1.119
+++ LVM2/configure	2010/03/04 12:10:40	1.120
@@ -685,6 +685,7 @@
 DM_DEVICE_GID
 DM_COMPAT
 DMEVENTD
+DL_LIBS
 DEVMAPPER
 DEBUG
 COPTIMISE_FLAG
@@ -12681,23 +12682,21 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_dl_dlopen" >&5
 $as_echo "$ac_cv_lib_dl_dlopen" >&6; }
 if test "x$ac_cv_lib_dl_dlopen" = x""yes; then
-  HAVE_LIBDL=yes
-else
-  HAVE_LIBDL=no
-fi
-
 
-if [ "x$HAVE_LIBDL" = xyes ]; then
 
 cat >>confdefs.h <<\_ACEOF
 #define HAVE_LIBDL 1
 _ACEOF
 
-	LIBS="-ldl $LIBS"
+	DL_LIBS="-ldl"
+	HAVE_LIBDL=yes
 else
+
+	DL_LIBS=
 	HAVE_LIBDL=no
 fi
 
+
 ################################################################################
 if [ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
       -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
@@ -15561,6 +15560,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2010/03/04 12:08:27	1.129
+++ LVM2/configure.in	2010/03/04 12:10:40	1.130
@@ -789,14 +789,12 @@
 
 ################################################################################
 dnl -- Check for dlopen
-AC_CHECK_LIB(dl, dlopen, HAVE_LIBDL=yes, HAVE_LIBDL=no)
-
-if [[ "x$HAVE_LIBDL" = xyes ]]; then
+AC_CHECK_LIB(dl, dlopen, [
 	AC_DEFINE([HAVE_LIBDL], 1, [Define to 1 if dynamic libraries are available.])
-	LIBS="-ldl $LIBS"
-else
-	HAVE_LIBDL=no
-fi
+	DL_LIBS="-ldl"
+	HAVE_LIBDL=yes ], [
+	DL_LIBS=
+	HAVE_LIBDL=no ])
 
 ################################################################################
 dnl -- Check for shared/static conflicts
@@ -1074,6 +1072,7 @@
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
+AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DM_COMPAT)
 AC_SUBST(DM_DEVICE_GID)
--- LVM2/make.tmpl.in	2010/03/04 12:08:27	1.81
+++ LVM2/make.tmpl.in	2010/03/04 12:10:40	1.82
@@ -38,7 +38,8 @@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal
+LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS)
+DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/04 12:08:27	1.35
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/04 12:10:41	1.36
@@ -53,7 +53,6 @@
 all: device-mapper
 device-mapper: $(TARGETS)
 
-LIBS += -ldl
 LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
 
 $(VERSIONED_SHLIB): $(LIB_SHARED)
@@ -62,11 +61,11 @@
 
 dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
-	$(LVMLIBS) $(LIBS) -rdynamic
+	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
+	dmeventd.o $(DL_LIBS) $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig


