From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:58 +0100
Subject: [PATCH 12/15] SELinux configure update
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <47c10957b5fe0c3939d0c61652b68a27c1c351e7.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch add substituted variables SELINUX_LIBS and STATIC_LIBS.

Here we have little trouble for static builds - there is the dependency
on SELinux libraries which are not bundled automagicaly to 'ar'
library files. So statically compiled binaries that links with
libdevmapper needs to explicitly link $(STATIC_LIBS)
(until better solution is found).
Also it looks like some static builds of selinux have dependencies
on runtime glibc libraries.

Modifies SELinux detection to use 3rd & 4th parameter for Success/Fail.
Also removes detection of pthread from this check as we know which
version of libdevmapper we are going to link with lvm after merge.

Move SELinux header check to the SELinux test code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in                 |   38 ++++++++------------------------------
 daemons/dmeventd/Makefile.in |    2 +-
 libdm/Makefile.in            |    2 ++
 make.tmpl.in                 |    3 +++
 tools/Makefile.in            |    4 ++--
 5 files changed, 16 insertions(+), 33 deletions(-)

diff --git a/configure.in b/configure.in
index 42e4235..b985c98 100644
--- a/configure.in
+++ b/configure.in
@@ -824,35 +824,18 @@ AC_MSG_RESULT($SELINUX)
 ################################################################################
 dnl -- Check for selinux
 if test x$SELINUX = xyes; then
-	AC_CHECK_LIB(sepol, sepol_check_context, HAVE_SEPOL=yes, HAVE_SEPOL=no)
+	AC_CHECK_LIB([sepol], [sepol_check_context], [
+		AC_DEFINE([HAVE_SEPOL], 1, [Define to 1 if sepol_check_context is available.])
+		SELINUX_LIBS="-lsepol"])
 
-	if test x$HAVE_SEPOL = xyes; then
-		AC_DEFINE([HAVE_SEPOL], 1,
-		  [Define to 1 if sepol_check_context is available.])
-		SELINUX_LIBS="-lsepol $SELINUX_LIBS"
-	fi
-
-	AC_CHECK_LIB(selinux, is_selinux_enabled, HAVE_SELINUX=yes, HAVE_SELINUX=no)
-
-	if test x$HAVE_SELINUX = xyes; then
+	AC_CHECK_LIB([selinux], [is_selinux_enabled], [
+		AC_CHECK_HEADERS([selinux/selinux.h],, hard_bailout)
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
 		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
-	else
+		HAVE_SELINUX=yes ], [
 		AC_MSG_WARN(Disabling selinux)
-	fi
-	LIBS="$SELINUX_LIBS $LIBS"
-
-	# With --enable-static_link and selinux enabled, linking
-	# fails on at least Debian unstable due to unsatisfied references
-	# to pthread_mutex_lock and _unlock.  See if we need -lpthread.
-	if test "$STATIC_LINK-$HAVE_SELINUX" = yes-yes; then
-		lvm_saved_libs=$LIBS
-		LIBS="$LIBS -static"
-		AC_SEARCH_LIBS([pthread_mutex_lock], [pthread],
-		  [test "$ac_cv_search_pthread_mutex_lock" = "none required" ||
-				LIB_PTHREAD=-lpthread])
-		LIBS=$lvm_saved_libs
-	fi
+		SELINUX_LIBS=
+		HAVE_SELINUX=no ])
 fi
 
 ################################################################################
@@ -997,10 +980,6 @@ if test x$INTL = xyes; then
 	AC_CHECK_HEADERS(libintl.h,,AC_MSG_ERROR(bailing out))
 fi
 
-if test x$HAVE_SELINUX = xyes; then
-	AC_CHECK_HEADERS(selinux/selinux.h,,AC_MSG_ERROR(bailing out))
-fi
-
 if test x$UDEV_SYNC = xyes; then
 	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,AC_MSG_ERROR(bailing out))
 fi
@@ -1109,7 +1088,6 @@ AC_SUBST(GULM_CFLAGS)
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
-AC_SUBST(HAVE_SELINUX)
 AC_SUBST(INTL)
 AC_SUBST(INTL_PACKAGE)
 AC_SUBST(JOBS)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 84514f0..df223ef 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -66,7 +66,7 @@ dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(LVMLIBS) $(LIBS)
+	dmeventd.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 6ff3bff..7ea0604 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -52,6 +52,8 @@ include $(top_builddir)/make.tmpl
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
+LIBS += $(SELINUX_LIBS)
+
 device-mapper: all
 
 .PHONY: install_dynamic install_static install_include \
diff --git a/make.tmpl.in b/make.tmpl.in
index 9def16d..15ee915 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -30,6 +30,8 @@ SED = @SED@
 CFLOW_CMD = @CFLOW_CMD@
 
 LIBS = @LIBS@
+# Extra libraries always linked with static binaries
+STATIC_LIBS = $(SELINUX_LIBS)
 DEFS += @DEFS@
 CFLAGS += @CFLAGS@
 CLDFLAGS += @CLDFLAGS@
@@ -39,6 +41,7 @@ LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
+SELINUX_LIBS = @SELINUX_LIBS@
 
 # Setup directory variables
 prefix = @prefix@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index b3b0b29..c7cd1d5 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -115,7 +115,7 @@ dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-	      -o $@ dmsetup.o -ldevmapper $(LIBS)
+	      -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)
 
 all: device-mapper
 
@@ -125,7 +125,7 @@ lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS)
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@
-- 
1.7.0


