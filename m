From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:30 +0200
Subject: [PATCH 09/15] clvmd: improve libdlm check
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <8176cab28b75f6ffce17896d1cbcc1e404bba7cb.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add sanity checks for libdlm.

Propagate the build info in a more consisten way.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 81379c0... ac3c009... M	configure.in
:100644 100644 2c9915c... 5e35522... M	daemons/clvmd/Makefile.in
 configure.in              |   11 +++++++++++
 daemons/clvmd/Makefile.in |   10 ++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/configure.in b/configure.in
index 81379c0..ac3c009 100644
--- a/configure.in
+++ b/configure.in
@@ -447,6 +447,15 @@ if test x$CHECKCPG = xyes; then
 	PKG_CHECK_MODULES(CPG, libcpg)
 fi
 
+dnl -- Check dlm library.
+if test x$CHECKDLM = xyes; then
+	PKG_CHECK_MODULES(DLM, libdlm, [],
+		[AC_CHECK_HEADERS(libdlm.h,,AC_MSG_ERROR(bailing out))
+		check_lib_no_libs dlm dlm_lock -lpthread
+		AC_MSG_RESULT([no pkg for libdlm library, using -ldlm -lpthread])
+		DLM_LIBS="-ldlm -lpthread"])
+fi
+
 ################################################################################
 dnl -- Build cluster log daemon
 AC_MSG_CHECKING(whether to build cluster log daemon)
@@ -926,6 +935,8 @@ AC_SUBST(CPG_LIBS)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
+AC_SUBST(DLM_CFLAGS)
+AC_SUBST(DLM_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DM_COMPAT)
 AC_SUBST(DM_DEVICE_GID)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 2c9915c..5e35522 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -21,6 +21,8 @@ CONFDB_LIBS = @CONFDB_LIBS@
 CONFDB_CFLAGS = @CONFDB_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
+DLM_LIBS = @DLM_LIBS@
+DLM_CFLAGS = @DLM_CFLAGS@
 GULM_LIBS = @GULM_LIBS@
 GULM_CFLAGS = @GULM_CFLAGS@
 QUORUM_LIBS = @QUORUM_LIBS@
@@ -68,8 +70,8 @@ endif
 
 ifeq ("$(CMAN)", "yes")
 	SOURCES += clvmd-cman.c
-	LMLIBS += $(CONFDB_LIBS) -ldlm -lcman
-	CFLAGS += $(CONFDB_CFLAGS)
+	LMLIBS += $(CONFDB_LIBS) $(DLM_LIBS) -lcman
+	CFLAGS += $(CONFDB_CFLAGS) $(DLM_CFLAGS)
 	DEFS += -DUSE_CMAN
 endif
 
@@ -82,8 +84,8 @@ endif
 
 ifeq ("$(COROSYNC)", "yes")
 	SOURCES += clvmd-corosync.c
-	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(QUORUM_LIBS) -ldlm
-	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(QUORUM_CFLAGS)
+	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
+	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
 	DEFS += -DUSE_COROSYNC
 endif
 
-- 
1.5.4.3


