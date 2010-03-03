From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:59 +0100
Subject: [PATCH 13/15] Move "-ldl" from LIBS to DL_LIBS
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <85bf6883b639e88b01841c7326ac3a713cbc0eb1.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce DL_LIBS substituted variable and move -ldl from global
LIBS to local DL_LIBS. Link this library only when needed.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in                 |   13 ++++++-------
 daemons/dmeventd/Makefile.in |    5 ++---
 make.tmpl.in                 |    3 ++-
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/configure.in b/configure.in
index b985c98..f632420 100644
--- a/configure.in
+++ b/configure.in
@@ -789,14 +789,12 @@ fi;
 
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
@@ -1074,6 +1072,7 @@ AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
+AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DM_COMPAT)
 AC_SUBST(DM_DEVICE_GID)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index df223ef..dc48f0d 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -53,7 +53,6 @@ include $(top_builddir)/make.tmpl
 all: device-mapper
 device-mapper: $(TARGETS)
 
-LIBS += -ldl
 LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
 
 $(VERSIONED_SHLIB): $(LIB_SHARED)
@@ -62,11 +61,11 @@ $(VERSIONED_SHLIB): $(LIB_SHARED)
 
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
diff --git a/make.tmpl.in b/make.tmpl.in
index 15ee915..48f145d 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -38,7 +38,8 @@ CLDFLAGS += @CLDFLAGS@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal
+LVMINTERNAL_LIBS = -llvm-internal $(DL_LIBS)
+DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
-- 
1.7.0


