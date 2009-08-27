From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:31 +0200
Subject: [PATCH 10/15] clvmd: improve cman build
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <bc1a4df1b6b85543f98b8fc23d2fa72d50230701.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add sanity checks for libcman.

Propagate the build info in a more consisten way.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 ac3c009... 2b35462... M	configure.in
:100644 100644 5e35522... 3baa4b9... M	daemons/clvmd/Makefile.in
 configure.in              |   13 +++++++++++++
 daemons/clvmd/Makefile.in |    6 ++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index ac3c009..2b35462 100644
--- a/configure.in
+++ b/configure.in
@@ -403,6 +403,17 @@ if test x$BUILDGULM = xyes; then
 		GULM_LIBS="-lgulm"])
 fi
 
+dnl -- Look for cman libraries if required.
+if test x$BUILDCMAN = xyes; then
+	PKG_CHECK_MODULES(CMAN, libcman, [],
+		[AC_CHECK_HEADERS(libcman.h,,AC_MSG_ERROR(bailing out))
+		check_lib_no_libs cman cman_init
+		AC_MSG_RESULT([no pkg for libcman library, using -lcman])
+		CMAN_LIBS="-lcman"])
+	CHECKCONFDB=yes
+	CHECKDLM=yes
+fi
+
 dnl -- Look for corosync libraries if required.
 if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
@@ -925,6 +936,8 @@ AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
 AC_SUBST(CLOGD)
+AC_SUBST(CMAN_CFLAGS)
+AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMDLIB)
 AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 5e35522..3baa4b9 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -17,6 +17,8 @@ VPATH = @srcdir@
 
 CCS_LIBS = @CCS_LIBS@
 CCS_CFLAGS = @CCS_CFLAGS@
+CMAN_LIBS = @CMAN_LIBS@
+CMAN_CFLAGS = @CMAN_CFLAGS@
 CONFDB_LIBS = @CONFDB_LIBS@
 CONFDB_CFLAGS = @CONFDB_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
@@ -70,8 +72,8 @@ endif
 
 ifeq ("$(CMAN)", "yes")
 	SOURCES += clvmd-cman.c
-	LMLIBS += $(CONFDB_LIBS) $(DLM_LIBS) -lcman
-	CFLAGS += $(CONFDB_CFLAGS) $(DLM_CFLAGS)
+	LMLIBS += $(CMAN_LIBS) $(CONFDB_LIBS) $(DLM_LIBS)
+	CFLAGS += $(CMAN_CFLAGS) $(CONFDB_CFLAGS) $(DLM_CFLAGS)
 	DEFS += -DUSE_CMAN
 endif
 
-- 
1.5.4.3


