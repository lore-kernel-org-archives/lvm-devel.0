From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:49:00 +0000 (GMT)
Subject: main - configure.ac: use pkg-config to detect static libs
Message-ID: <20230223154900.46E5F385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8868041d871a35c132c1d31af9c7e6342fab51c
Commit:        c8868041d871a35c132c1d31af9c7e6342fab51c
Parent:        2b7fa40aacfe3765ea14c476789de4bf7bd5efe6
Author:        Robin H. Johnson <robbat2@gentoo.org>
AuthorDate:    Sun May 9 11:00:22 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

configure.ac: use pkg-config to detect static libs

Add some Gentoo based patches for better support of static linking.
This are not tested nor supported by upstream developers.
Usage requires presence of several libraries in their static form
which is however not commonly available.

Selinux modified by zkabelac to still work on older sofrware which
did not provided libselinux.pc at a time - see keep the old check
present and use pkg-config only when possible.
---
 configure.ac       | 15 +++++++++++++--
 libdm/make.tmpl.in |  5 ++++-
 make.tmpl.in       |  5 ++++-
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index ec36f10ab..eed25d4db 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1134,6 +1134,7 @@ AS_IF([test "$BLKID_WIPING" != "no"], [
 		BLKID_WIPING="yes"
 		BLKID_PC="blkid"
 		DEFAULT_USE_BLKID_WIPING=1
+		BLKID_STATIC_LIBS=$("$PKG_CONFIG" --static --libs blkid)
 		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
 	], [
 		AS_IF([test "$BLKID_WIPING" = "maybe"], [
@@ -1159,6 +1160,7 @@ AC_MSG_RESULT([$UDEV_SYNC])
 
 AS_IF([test "$UDEV_SYNC" = "yes"], [
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
+	UDEV_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libudev)
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 
 	AC_CHECK_LIB(udev, udev_device_get_is_initialized, AC_DEFINE([HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED], 1,
@@ -1376,17 +1378,23 @@ dnl -- Check for selinux
 AS_IF([test "$SELINUX" = "yes"], [
 	AC_CHECK_LIB([sepol], [sepol_check_context], [
 		AC_DEFINE([HAVE_SEPOL], 1, [Define to 1 if sepol_check_context is available.])
-		SELINUX_LIBS="-lsepol"])
+		SEPOL_LIBS="-lsepol"])
+
+	PKG_CHECK_EXISTS([libselinux],
+			 [PKG_CHECK_MODULES([SELINUX], [libselinux],
+					    [SELINUX_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libselinux)])])
 
 	AC_CHECK_LIB([selinux], [is_selinux_enabled], [
 		AC_CHECK_HEADERS([selinux/selinux.h],, hard_bailout)
 		AC_CHECK_HEADERS([selinux/label.h])
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
-		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
+		SELINUX_LIBS=${SELINUX_LIBS:--lselinux}
+		SELINUX_STATIC_LIBS=${SELINUX_STATIC_LIBS:-$SELINUX_LIBS $SEPOL_LIBS}
 		SELINUX_PC="libselinux"
 		HAVE_SELINUX=yes ], [
 		AC_MSG_WARN(Disabling selinux)
 		SELINUX_LIBS=
+		SELINUX_STATIC_LIBS=
 		SELINUX_PC=
 		HAVE_SELINUX=no ])
 ])
@@ -1792,6 +1800,7 @@ AC_ARG_VAR([READLINE_LIBS], [linker flags for readline])
 AC_SUBST(AWK)
 AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(BLKID_PC)
+AC_SUBST(BLKID_STATIC_LIBS)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_DMFILEMAPD)
@@ -1882,6 +1891,7 @@ AC_SUBST(RT_LIBS)
 AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
+AC_SUBST(SELINUX_STATIC_LIBS)
 AC_SUBST(SILENT_RULES)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
@@ -1899,6 +1909,7 @@ AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
+AC_SUBST(UDEV_STATIC_LIBS)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(USE_TRACKING)
 AC_SUBST(USRSBINDIR)
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 3d032f1b0..cc28e73cb 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -54,7 +54,7 @@ RM = rm -f
 
 LIBS += @LIBS@ $(PTHREAD_LIBS) $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(PTHREAD_LIBS)
+STATIC_LIBS = $(PTHREAD_LIBS) $(SELINUX_STATIC_LIBS) $(UDEV_STATIC_LIBS) $(BLKID_STATIC_LIBS) $(RT_LIBS) $(M_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
@@ -72,10 +72,13 @@ PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 EDITLINE_LIBS = @EDITLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
+SELINUX_STATIC_LIBS = @SELINUX_STATIC_LIBS@
 UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
+UDEV_STATIC_LIBS = @UDEV_STATIC_LIBS@
 BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
+BLKID_STATIC_LIBS = @BLKID_STATIC_LIBS@
 LIBSYSTEMD_LIBS = @LIBSYSTEMD_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
 
diff --git a/make.tmpl.in b/make.tmpl.in
index df4c5850d..6025c166c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -59,7 +59,7 @@ PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 LIBS += @LIBS@ $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
 LVMLIBS = $(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(LIBSYSTEMD_LIBS) $(BLKID_LIBS) $(AIO_LIBS) $(LIBS)
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(PTHREAD_LIBS) $(SELINUX_STATIC_LIBS) $(UDEV_STATIC_LIBS) $(BLKID_STATIC_LIBS)
+STATIC_LIBS = $(PTHREAD_LIBS) $(SELINUX_STATIC_LIBS) $(UDEV_STATIC_LIBS) $(BLKID_STATIC_LIBS) $(M_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
@@ -78,6 +78,7 @@ AIO_CFLAGS = @AIO_CFLAGS@
 AIO_LIBS = @AIO_LIBS@
 BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
+BLKID_STATIC_LIBS = @BLKID_STATIC_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
 EDITLINE_CFLAGS = @EDITLINE_CFLAGS@
@@ -96,8 +97,10 @@ PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_CFLAGS = @READLINE_CFLAGS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
+SELINUX_STATIC_LIBS = @SELINUX_STATIC_LIBS@
 UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
+UDEV_STATIC_LIBS = @UDEV_STATIC_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
 VALGRIND_LIBS = @VALGRIND_LIBS@
 

