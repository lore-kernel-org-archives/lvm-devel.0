From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:06:09 -0000
Subject: LVM2 configure.in
Message-ID: <20081031220609.7006.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:06:09

Modified files:
	.              : configure.in 

Log message:
	first attempt at merging configure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/configure.in	2008/10/08 12:50:13	1.80
+++ LVM2/configure.in	2008/10/31 22:06:09	1.81
@@ -41,7 +41,7 @@
 		SELINUX=yes
 		REALTIME=yes
 		CLUSTER=internal
-		FSADM=no
+		FSADM=yes
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
@@ -160,6 +160,15 @@
 fi
 
 ################################################################################
+dnl -- Setup device mode
+AC_MSG_CHECKING(device node mode)
+
+AC_ARG_WITH(device-mode,
+  [  --with-device-mode=MODE Set the mode used for new device nodes [[MODE=0600]] ],
+  [ DM_DEVICE_MODE="$withval" ], [ DM_DEVICE_MODE="0600" ] )
+AC_MSG_RESULT($DM_DEVICE_MODE)
+
+################################################################################
 dnl -- LVM1 tool fallback option
 AC_MSG_CHECKING(whether to enable lvm1 fallback)
 AC_ARG_ENABLE(lvm1_fallback, [  --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
@@ -344,15 +353,25 @@
 ################################################################################
 dnl -- Disable devmapper
 AC_MSG_CHECKING(whether to use device-mapper)
-AC_ARG_ENABLE(devmapper, [  --disable-devmapper     Disable device-mapper interaction],
+AC_ARG_ENABLE(devmapper, [  --disable-devmapper     Disable LVM2 device-mapper interaction],
 DEVMAPPER=$enableval)
 AC_MSG_RESULT($DEVMAPPER)
 
 if test x$DEVMAPPER = xyes; then
-	AC_DEFINE([DEVMAPPER_SUPPORT], 1, [Define to 1 to enable device-mapper interaction.])
+	AC_DEFINE([DEVMAPPER_SUPPORT], 1, [Define to 1 to enable LVM2 device-mapper interaction.])
 fi
 
 ################################################################################
+dnl -- Compatibility mode
+AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device-mapper versions],
+  DM_COMPAT=$enableval, DM_COMPAT=no)
+
+################################################################################
+dnl -- Disable ioctl
+AC_ARG_ENABLE(ioctl,   [  --disable-driver        Disable calls to device-mapper in the kernel],
+  DM_IOCTLS=$enableval)
+
+################################################################################
 dnl -- Disable O_DIRECT
 AC_MSG_CHECKING(whether to enable O_DIRECT)
 AC_ARG_ENABLE(o_direct, [  --disable-o_direct      Disable O_DIRECT],
@@ -374,6 +393,10 @@
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
+################################################################################
+dnl -- Enable pkg-config
+AC_ARG_ENABLE(pkgconfig,   [  --enable-pkgconfig      Install pkgconfig support],
+  PKGCONFIG=$enableval, PKGCONFIG=no)
 
 ################################################################################
 dnl -- Enable fsadm
@@ -389,6 +412,8 @@
 DMEVENTD=$enableval)
 AC_MSG_RESULT($DMEVENTD)
 
+BUILD_DMEVENTD=$DMEVENTD
+
 dnl -- dmeventd currently requires internal mirror support
 if test x$DMEVENTD = xyes; then
    if test x$MIRRORS != xinternal; then
@@ -406,6 +431,20 @@
 if test x$DMEVENTD = xyes; then
 	AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
 fi
+
+################################################################################
+dnl -- getline included in recent libc
+
+AC_CHECK_LIB(c, getline, AC_DEFINE([HAVE_GETLINE], 1,
+  [Define to 1 if getline is available.]))
+
+################################################################################
+dnl -- canonicalize_file_name included in recent libc
+
+AC_CHECK_LIB(c, canonicalize_file_name,
+  AC_DEFINE([HAVE_CANONICALIZE_FILE_NAME], 1,
+    [Define to 1 if canonicalize_file_name is available.]))
+
 ################################################################################
 dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
 if [[ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ]];
@@ -546,6 +585,7 @@
 AC_MSG_RESULT($INTL)
 
 if test x$INTL = xyes; then
+# FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
 	AC_PATH_PROG(MSGFMT, msgfmt)
 	if [[ "x$MSGFMT" == x ]];
@@ -633,6 +673,45 @@
 fi
 
 ################################################################################
+dnl -- dmeventd pidfile and executable path
+AH_TEMPLATE(DMEVENTD_PIDFILE, [Path to dmeventd pidfile.])
+if test "$BUILD_DMEVENTD" = yes; then
+	AC_ARG_WITH(dmeventd-pidfile,
+		    [  --with-dmeventd-pidfile=PATH    dmeventd pidfile [[/var/run/dmeventd.pid]] ],
+		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE,"$withval") ],
+		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE,"/var/run/dmeventd.pid") ])
+fi
+
+AH_TEMPLATE(DMEVENTD_PATH, [Path to dmeventd binary.])
+if test "$BUILD_DMEVENTD" = yes; then
+        dmeventd_prefix="$exec_prefix"
+        if test "x$dmeventd_prefix" = "xNONE"; then
+                dmeventd_prefix="$prefix"
+        fi
+        if test "x$dmeventd_prefix" = "xNONE"; then
+                dmeventd_prefix=""
+        fi
+	AC_ARG_WITH(dmeventd-path,
+		    [  --with-dmeventd-path=PATH       dmeventd path [[${exec_prefix}/sbin/dmeventd]] ],
+		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$withval") ],
+		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$dmeventd_prefix/sbin/dmeventd") ])
+fi
+
+################################################################################
+dnl -- which kernel interface to use (ioctl only)
+AC_MSG_CHECKING(for kernel interface choice)
+AC_ARG_WITH(interface,
+  [  --with-interface=IFACE  Choose kernel interface (ioctl) [[ioctl]] ],
+  [ interface="$withval" ],
+  [ interface=ioctl ])
+if [[ "x$interface" != xioctl ]];
+then
+  AC_MSG_ERROR(--with-interface=ioctl required. fs no longer supported.)
+fi
+AC_MSG_RESULT($interface)
+
+################################################################################
+DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################
@@ -650,7 +729,6 @@
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DMDIR)
-# FIXME: rename to LVM_USE_DMEVENTD
 AC_SUBST(DMEVENTD)
 AC_SUBST(DM_COMPAT)
 AC_SUBST(DM_DEVICE_GID)
@@ -672,7 +750,6 @@
 AC_SUBST(LOCALEDIR)
 AC_SUBST(LVM1)
 AC_SUBST(LVM1_FALLBACK)
-# FIXME: rename to LVM_CONF_DIR
 AC_SUBST(CONFDIR)
 AC_SUBST(LVM_VERSION)
 AC_SUBST(MIRRORS)
@@ -684,6 +761,11 @@
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST([LIB_PTHREAD])
+AC_SUBST(interface)
+AC_SUBST(kerneldir)
+AC_SUBST(missingkernel)
+AC_SUBST(kernelvsn)
+AC_SUBST(tmpdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
 
@@ -693,23 +775,26 @@
 AC_CONFIG_FILES([
 Makefile
 make.tmpl
-include/Makefile
-lib/Makefile
-man/Makefile
-po/Makefile
-dmeventd/Makefile
 daemons/Makefile
 daemons/clvmd/Makefile
-dmeventd/mirror/Makefile
-dmeventd/snapshot/Makefile
+daemons/dmeventd/Makefile
+daemons/dmeventd/libdevmapper-event.pc
+daemons/dmeventd/plugins/mirror/Makefile
+daemons/dmeventd/plugins/snapshot/Makefile
 doc/Makefile
+include/Makefile
+lib/Makefile
 lib/format1/Makefile
 lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
 lib/snapshot/Makefile
-test/Makefile
+libdm/Makefile
+libdm/libdevmapper.pc
+man/Makefile
+po/Makefile
 scripts/Makefile
+test/Makefile
 tools/Makefile
 tools/version.h
 ])
@@ -718,11 +803,3 @@
 if test x$ODIRECT != xyes; then
   AC_MSG_WARN(Warning: O_DIRECT disabled: low-memory pvmove may lock up)
 fi
-
-if test x$FSADM == xyes; then
-  AC_MSG_WARN(fsadm support is untested)
-fi
-
-if test x$DMEVENTD == xyes; then
-  AC_MSG_WARN(dmeventd support is untested)
-fi


