From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:16 +0200
Subject: [PATCH 09/11] debian: libs cleanup
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <92cd1d679dfcdf03bc47ab18a5540b3b62550580.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

patch with several changes on how libs are found and used
(selinux and readline)

patch is not clean or ready for submission

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 06759b6... ad871fd... M	configure.in
:100644 100644 207c0e2... 2a14ba6... M	daemons/dmeventd/Makefile.in
:100644 100644 4273eeb... f20ad5d... M	lib/misc/configure.h.in
:100644 100644 6dd25ff... 191e2ae... M	libdm/Makefile.in
:100644 100644 6d12920... 5464188... M	make.tmpl.in
:100644 100644 5702f4f... 4f8be22... M	tools/Makefile.in
 configure.in                 |   57 +++++------------------------------------
 daemons/dmeventd/Makefile.in |    2 +-
 lib/misc/configure.h.in      |   14 +++-------
 libdm/Makefile.in            |    4 +-
 make.tmpl.in                 |    5 +--
 tools/Makefile.in            |   14 +++++-----
 6 files changed, 23 insertions(+), 73 deletions(-)

diff --git a/configure.in b/configure.in
index 06759b6..ad871fd 100644
--- a/configure.in
+++ b/configure.in
@@ -34,7 +34,6 @@ case "$host_os" in
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LDDEPS="$LDDEPS .export.sym"
-		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		ODIRECT=yes
@@ -779,24 +778,6 @@ if [[ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ]];
 fi;
 
 ################################################################################
-dnl -- Check for termcap (Shamelessly copied from parted 1.4.17)
-if test x$READLINE != xno; then
-	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
-	  [tg_found=yes], [tg_found=no])
-	test x$READLINE:$tg_found = xyes:no &&
-	  AC_MSG_ERROR(
-termcap could not be found which is required for the
---enable-readline option (which is enabled by default).  Either disable readline
-support with --disable-readline or download and install termcap from:
-	ftp.gnu.org/gnu/termcap
-Note: if you are using precompiled packages you will also need the development
-  package as well (which may be called termcap-devel or something similar).
-Note: (n)curses also seems to work as a substitute for termcap.  This was
-  not found either - but you could try installing that as well.
-)
-fi
-
-################################################################################
 dnl -- Check for dlopen
 AC_CHECK_LIB(dl, dlopen, HAVE_LIBDL=yes, HAVE_LIBDL=no)
 
@@ -827,35 +808,9 @@ AC_MSG_RESULT($SELINUX)
 ################################################################################
 dnl -- Check for selinux
 if test x$SELINUX = xyes; then
-	AC_CHECK_LIB(sepol, sepol_check_context, HAVE_SEPOL=yes, HAVE_SEPOL=no)
-
-	if test x$HAVE_SEPOL = xyes; then
-		AC_DEFINE([HAVE_SEPOL], 1,
-		  [Define to 1 if sepol_check_context is available.])
-		SELINUX_LIBS="-lsepol $SELINUX_LIBS"
-	fi
-
-	AC_CHECK_LIB(selinux, is_selinux_enabled, HAVE_SELINUX=yes, HAVE_SELINUX=no)
-
-	if test x$HAVE_SELINUX = xyes; then
-		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
-		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
-	else
-		AC_MSG_WARN(Disabling selinux)
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
+	AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
+	LIBS_SELINUX="$(pkg-config --libs libselinux)"
+	LIBS_SELINUX_STATIC="$(pkg-config --libs --static libselinux)"
 fi
 
 ################################################################################
@@ -866,7 +821,7 @@ AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getop
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
 if test x$READLINE != xno; then
 	rl_found=yes
-	AC_CHECK_LIB([readline], [readline], , [rl_found=no])
+	AC_CHECK_LIB([readline], [readline], [LIBS_READLINE="-lreadline $LIBS_READLINE"], [rl_found=no])
 	test x$READLINE:$rl_found = xyes:no &&
 	  AC_MSG_ERROR(
 GNU Readline could not be found which is required for the
@@ -1078,6 +1033,9 @@ AC_SUBST(INTL_PACKAGE)
 AC_SUBST(JOBS)
 AC_SUBST(LDDEPS)
 AC_SUBST(LIBS)
+AC_SUBST(LIBS_READLINE)
+AC_SUBST(LIBS_SELINUX)
+AC_SUBST(LIBS_SELINUX_STATIC)
 AC_SUBST(LIB_SUFFIX)
 AC_SUBST(LOCALEDIR)
 AC_SUBST(LVM1)
@@ -1105,7 +1063,6 @@ AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_RULES)
-AC_SUBST([LIB_PTHREAD])
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 207c0e2..2a14ba6 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -46,7 +46,7 @@ LIBS += -ldl -ldevmapper -lpthread
 
 dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmeventd.o \
-	-L. -ldevmapper-event $(LIBS) -rdynamic
+	-L. -ldevmapper-event
 
 .PHONY: install_dynamic install_static install_include \
 	install_pkgconfig install_dmeventd
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 4273eeb..f20ad5d 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -120,9 +120,6 @@
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 
-/* Define to 1 if you have the `readline' library (-lreadline). */
-#undef HAVE_LIBREADLINE
-
 /* Define to 1 if you have the <limits.h> header file. */
 #undef HAVE_LIMITS_H
 
@@ -185,9 +182,6 @@
 /* Define to 1 if you have the <readline/readline.h> header file. */
 #undef HAVE_READLINE_READLINE_H
 
-/* Define to 1 to include support for realtime clock. */
-#undef HAVE_REALTIME
-
 /* Define to 1 if you have the `rl_completion_matches' function. */
 #undef HAVE_RL_COMPLETION_MATCHES
 
@@ -206,9 +200,6 @@
 /* Define to 1 if you have the <selinux/selinux.h> header file. */
 #undef HAVE_SELINUX_SELINUX_H
 
-/* Define to 1 if sepol_check_context is available. */
-#undef HAVE_SEPOL
-
 /* Define to 1 if you have the `setlocale' function. */
 #undef HAVE_SETLOCALE
 
@@ -273,7 +264,7 @@
 /* Define to 1 if you have the `strtoul' function. */
 #undef HAVE_STRTOUL
 
-/* Define to 1 if `st_rdev' is member of `struct stat'. */
+/* Define to 1 if `struct stat' is a member of `st_rdev'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
 /* Define to 1 if you have the <syslog.h> header file. */
@@ -410,6 +401,9 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
+/* Define to the home page for this package. */
+#undef PACKAGE_URL
+
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 6dd25ff..191e2ae 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -35,9 +35,7 @@ SOURCES =\
 
 INCLUDES = -I$(srcdir)/$(interface) -I$(srcdir)
 
-ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
-endif
 
 ifeq ("@LIB_SUFFIX@","dylib")
   LIB_SHARED = $(interface)/libdevmapper.dylib
@@ -47,6 +45,8 @@ endif
 VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 LIB_VERSION = $(LIB_VERSION_DM)
 
+LDFLAGS += @LIBS_SELINUX@
+
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 6d12920..5464188 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -105,7 +105,6 @@ endif
 #DEFS += -DBOUNDS_CHECK
 
 #CFLAGS += -pg
-#LDFLAGS += -pg
 
 STRIP=
 #STRIP = -s
@@ -209,13 +208,13 @@ $(TARGETS): $(OBJECTS)
 ifeq ("@LIB_SUFFIX@","so")
 $(LIB_SHARED): $(OBJECTS) $(LDDEPS)
 	$(CC) -shared -Wl,-soname,$(notdir $@).$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+	$(CFLAGS) $(LDFLAGS) $(CLDFLAGS) $(OBJECTS) -o $@
 endif
 
 ifeq ("@LIB_SUFFIX@","dylib")
 $(LIB_SHARED): $(OBJECTS) $(LDDEPS)
 	$(CC) -dynamiclib -dylib_current_version,$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+	$(CFLAGS) $(LDFLAGS) $(CLDFLAGS) $(OBJECTS) -o $@
 endif
 
 %.so: %.a
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 5702f4f..4f8be22 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -17,8 +17,6 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-LIB_PTHREAD = @LIB_PTHREAD@
-
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
@@ -105,6 +103,9 @@ endif
 
 LVMLIBS += -ldevmapper
 
+LDFLAGS_DMSETUP_STATIC = @LIBS_SELINUX_STATIC@
+LDFLAGS_LVM = @LIBS_READLINE@
+
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
 include ../make.tmpl
@@ -113,22 +114,21 @@ device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmsetup.o \
-	      -L$(top_builddir)/libdm -ldevmapper $(LIBS) $(LIB_PTHREAD)
+	      -L$(top_builddir)/libdm -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmsetup.o -static \
-	      -L$(interfacedir) -ldevmapper $(LIBS) \
-	      $(LIB_PTHREAD)
+	      -L$(interfacedir) -ldevmapper $(LIBS) $(LDFLAGS_DMSETUP_STATIC)
 
 all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		$(LDFLAGS) $(LVMLIBS) $(LIBS) $(LDFLAGS_LVM) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm-static.o -static \
-		-L$(interfacedir) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+		-L$(interfacedir) $(LVMLIBS) $(LIBS) -rdynamic
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@
-- 
1.5.4.3


