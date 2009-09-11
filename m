From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 11 Sep 2009 08:26:37 +0200
Subject: [PATCH 1/3] cmirror: cleanup build
In-Reply-To: <1252650399-8983-1-git-send-email-fdinitto@redhat.com>
References: <1252650399-8983-1-git-send-email-fdinitto@redhat.com>
Message-ID: <b60d40b95f31b6abbb44d0bc7e6dcc2b8aa4c0e9.1252650265.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

configure.in:
- Move pkg-config init check into a standalone function.
- Share pkg_config_init between clvmd and cmirror build.
- Enable pkg-config check for libSaCkpt.
- Check for libcpg only if it hasn?t been done before.
- Propagate vars consistently.

daemons/cmirrord/Makefile.in:
- Propagate vars consistently.
- Drop CFLAGS from linking.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 cc461cf... d0ab503... M	configure.in
:100644 100644 ce13d02... add4d55... M	daemons/cmirrord/Makefile.in
 configure.in                 |   43 ++++++++++++++++++++++++++---------------
 daemons/cmirrord/Makefile.in |   12 ++++++++--
 2 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/configure.in b/configure.in
index cc461cf..d0ab503 100644
--- a/configure.in
+++ b/configure.in
@@ -322,6 +322,17 @@ REALTIME=$enableval)
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
+dnl -- Init pkg-config with dummy invokation:
+dnl -- this is required because PKG_CHECK_MODULES macro is expanded
+dnl -- to initialize the pkg-config environment only at the first invokation,
+dnl -- that would be conditional in this configure.in.
+pkg_config_init() {
+	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
+		[AC_MSG_RESULT([pkg-config initialized])])
+	PKGCONFIG_INIT=1
+}
+
+################################################################################
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
@@ -345,6 +356,12 @@ if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
 	CLUSTER=internal
 fi
 
+dnl -- init pkgconfig if required
+if  test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
+	pkg_config_init
+fi
+
+
 dnl -- define build types
 if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
 	BUILDGULM=yes
@@ -367,15 +384,6 @@ if test x$BUILDGULM = xyes; then
 	fi
 fi
 
-dnl -- Init pkg-config with dummy invokation:
-dnl -- this is required because PKG_CHECK_MODULES macro is expanded
-dnl -- to initialize the pkg-config environment only at the first invokation,
-dnl -- that would be conditional in this configure.in.
-if  test x$CLVMD != xnone; then
-	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
-		[AC_MSG_RESULT([pkg-config initialized])])
-fi
-
 dnl -- define a soft bailout if we are autodetecting
 soft_bailout() {
 	NOTFOUND=1
@@ -574,13 +582,14 @@ fi
 ################################################################################
 dnl -- Look for corosync libraries if required.
 if [[ "x$BUILD_CMIRRORD" = xyes ]]; then
-#
-#       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
-#       FIXME: Merge this with the new clvmd logic
-#
-	PKG_CHECK_MODULES(CPG, libcpg, [],
-		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
-		CPG_LIBS="-lcpg"])
+	dnl -- init pkgconfig if required
+	if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+	PKG_CHECK_MODULES(SACKPT, libSaCkpt)
+	if test x$HAVE_CPG != xyes; then
+		PKG_CHECK_MODULES(CPG, libcpg)
+	fi
 fi
 
 ################################################################################
@@ -1087,6 +1096,8 @@ AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(SACKPT_CFLAGS)
+AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
 AC_SUBST(SNAPSHOTS)
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index ce13d02..add4d55 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -15,17 +15,23 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
+CPG_LIBS = @CPG_LIBS@
+CPG_CFLAGS = @CPG_CFLAGS@
+SACKPT_LIBS = @SACKPT_LIBS@
+SACKPT_CFLAGS = @SACKPT_CFLAGS@
+
 SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
 
 TARGETS = cmirrord
 
 include $(top_srcdir)/make.tmpl
 
-LDFLAGS += -L$(usrlibdir)/openais
-LIBS += -lcpg -lSaCkpt -ldevmapper
+LIBS += -ldevmapper
+LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
+CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
 cmirrord: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
-	$(CC) -o cmirrord $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
+	$(CC) -o cmirrord $(OBJECTS) $(LDFLAGS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
-- 
1.5.4.3


