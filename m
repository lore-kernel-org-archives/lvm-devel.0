From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:18:30 +0200
Subject: [PATCH 1/9] Udev integration: Configure and Makefile changes for udev patches
Message-ID: <4A1A8C96.40201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm sending a whole patchset again for sure, because some of the
patches are updated...

I've added these configuration options:

--disable-wait-for-udev 
(disables the wait, no semaphores, the macro to check is
WAITFORUDEV_SUPPORT, default is enabled)

--with-udev-prefix=DIR
(sets the prefix for the location where the rules will be installed,
this is basically [udev_prefix]/lib/udev/rules.d, where
udev_prefix=${exec_prefix} by default -- this is useful if someone
uses his own compilation of udevd where this is defined exactly like
this, so the location could be 'synchronized' this way)

When the wait-for-udev is enabled, the check for sys/ipc.h and sys/sem.h
is used as well.

Peter

Patches for configure.in, Makefile.in, make.tmpl.in and configure.h.in:


configure.in stuff:
===================

diff --git a/configure.in b/configure.in
index eb6278d..7062112 100644
--- a/configure.in
+++ b/configure.in
@@ -43,6 +43,7 @@ case "$host_os" in
 		REALTIME=yes
 		CLUSTER=internal
 		FSADM=yes
+		WAITFORUDEV=yes
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
@@ -58,6 +59,7 @@ case "$host_os" in
 		REALTIME=no
 		CLUSTER=none
 		FSADM=no
+		WAITFORUDEV=yes
 		;;
 esac
 
@@ -403,6 +405,17 @@ if test x$DEVMAPPER = xyes; then
 fi
 
 ################################################################################
+dnl -- Disable wait-for-udev
+AC_MSG_CHECKING(whether to enable wait-for-udev)
+AC_ARG_ENABLE(wait_for_udev, [  --disable-wait-for-udev Disable wait for completion of udev rules],
+WAITFORUDEV=$enableval)
+AC_MSG_RESULT($WAITFORUDEV)
+
+if test x$WAITFORUDEV = xyes; then
+	AC_DEFINE([WAITFORUDEV_SUPPORT], 1, [Define to 1 to enable wait for completion of udev rules.])
+fi
+
+################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device-mapper versions],
   DM_COMPAT=$enableval, DM_COMPAT=no)
@@ -666,6 +679,11 @@ AC_ARG_WITH(usrsbindir,
 	    [ usrsbindir='${prefix}/sbin' ])
 
 ################################################################################
+AC_ARG_WITH(udev_prefix,
+	    [  --with-udev-prefix=DIR  Add prefix to installation path for udev rules],
+            [ udev_prefix="$withval"],
+            [ udev_prefix='${exec_prefix}' ])
+################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,AC_MSG_ERROR(bailing out))
@@ -696,6 +714,10 @@ if test x$HAVE_SELINUX = xyes; then
 	AC_CHECK_HEADERS(selinux/selinux.h,,AC_MSG_ERROR(bailing out))
 fi
 
+if test x$WAITFORUDEV = xyes; then
+	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,AC_MSG_ERROR(bailing out))
+fi
+
 ################################################################################
 AC_PATH_PROG(MODPROBE_CMD, modprobe)
 
@@ -822,6 +844,7 @@ AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
 AC_SUBST(kernelvsn)
 AC_SUBST(tmpdir)
+AC_SUBST(udev_prefix)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
 
@@ -857,6 +880,7 @@ scripts/Makefile
 test/Makefile
 test/api/Makefile
 tools/Makefile
+udev/Makefile
 ])
 AC_OUTPUT


Makefile.in stuff:
==================

diff --git a/Makefile.in b/Makefile.in
index fa1ba80..a4e3e18 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -16,7 +16,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-SUBDIRS = doc include man scripts
+SUBDIRS = doc include man scripts udev
 
 ifeq ("@INTL@", "yes")
   SUBDIRS += po


make.tmpl.in stuff:
===================

diff --git a/make.tmpl.in b/make.tmpl.in
index fa3b884..30cd6bf 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -50,6 +50,7 @@ infodir = $(DESTDIR)@infodir@
 mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
+udevdir = $(DESTDIR)@udev_prefix@/lib/udev/rules.d
 
 interface = @interface@
 interfacedir = $(top_srcdir)/libdm/$(interface)


configure.h.in stuff:
=====================

diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index ccab9f5..3175dc4 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -268,6 +268,9 @@
 /* Define to 1 if you have the <sys/ioctl.h> header file. */
 #undef HAVE_SYS_IOCTL_H
 
+/* Define to 1 if you have the <sys/ipc.h> header file. */
+#undef HAVE_SYS_IPC_H
+
 /* Define to 1 if you have the <sys/mman.h> header file. */
 #undef HAVE_SYS_MMAN_H
 
@@ -287,6 +290,9 @@
 /* Define to 1 if you have the <sys/select.h> header file. */
 #undef HAVE_SYS_SELECT_H
 
+/* Define to 1 if you have the <sys/sem.h> header file. */
+#undef HAVE_SYS_SEM_H
+
 /* Define to 1 if you have the <sys/socket.h> header file. */
 #undef HAVE_SYS_SOCKET_H
 
@@ -417,6 +423,9 @@
 /* Define to 1 if your <sys/time.h> declares `struct tm'. */
 #undef TM_IN_SYS_TIME
 
+/* Define to 1 to enable wait for completion of udev rules. */
+#undef WAITFORUDEV_SUPPORT
+
 /* Define to empty if `const' does not conform to ANSI C. */
 #undef const
 


