From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:27 +0200
Subject: [PATCH 06/15] clvmd: improve gulm build
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <c295a9de0fdd948276aa3292c8424cceca7fb488.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add sanity checks for libccs and libgulm.

Propagate the build info in a more consisten way.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 40974db... cc4697d... M	configure.in
:100644 100644 6054ded... f643644... M	daemons/clvmd/Makefile.in
 configure.in              |   18 ++++++++++++++++++
 daemons/clvmd/Makefile.in |   11 ++++++++---
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/configure.in b/configure.in
index 40974db..cc4697d 100644
--- a/configure.in
+++ b/configure.in
@@ -389,6 +389,20 @@ check_lib_no_libs() {
 	LIBS=$ac_check_lib_save_LIBS
 }
 
+dnl -- Look for gulm libraries if required.
+if test x$BUILDGULM = xyes; then
+	PKG_CHECK_MODULES(CCS, libccs, [],
+		[AC_CHECK_HEADERS(ccs.h,,AC_MSG_ERROR(bailing out))
+		check_lib_no_libs ccs ccs_connect
+		AC_MSG_RESULT([no pkg for libccs library, using -lccs])
+		CCS_LIBS="-lccs"])
+	PKG_CHECK_MODULES(GULM, libgulm, [],
+		[AC_CHECK_HEADERS(libgulm.h,,AC_MSG_ERROR(bailing out))
+		check_lib_no_libs gulm lg_core_login
+		AC_MSG_RESULT([no pkg for libgulm library, using -lgulm])
+		GULM_LIBS="-lgulm"])
+fi
+
 dnl -- Look for corosync libraries if required.
 if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
@@ -861,6 +875,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 ################################################################################
 AC_SUBST(APPLIB)
 AC_SUBST(BUILD_DMEVENTD)
+AC_SUBST(CCS_CFLAGS)
+AC_SUBST(CCS_LIBS)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
 AC_SUBST(CLDFLAGS)
@@ -889,6 +905,8 @@ AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
 AC_SUBST(GROUP)
+AC_SUBST(GULM_CFLAGS)
+AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(HAVE_SELINUX)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 6054ded..f643644 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -15,12 +15,16 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-QUORUM_LIBS = @QUORUM_LIBS@
-QUORUM_CFLAGS = @QUORUM_CFLAGS@
+CCS_LIBS = @CCS_LIBS@
+CCS_CFLAGS = @CCS_CFLAGS@
 CONFDB_LIBS = @CONFDB_LIBS@
 CONFDB_CFLAGS = @CONFDB_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
+GULM_LIBS = @GULM_LIBS@
+GULM_CFLAGS = @GULM_CFLAGS@
+QUORUM_LIBS = @QUORUM_LIBS@
+QUORUM_CFLAGS = @QUORUM_CFLAGS@
 
 SOURCES = \
 	clvmd-command.c  \
@@ -57,7 +61,8 @@ endif
 
 ifeq ("$(GULM)", "yes")
 	SOURCES += clvmd-gulm.c tcp-comms.c
-	LMLIBS += -lccs -lgulm
+	LMLIBS += $(CCS_LIBS) $(GULM_LIBS)
+	CFLAGS += $(CCS_CFLAGS) $(GULM_CFLAGS)
 	DEFS += -DUSE_GULM
 endif
 
-- 
1.5.4.3


