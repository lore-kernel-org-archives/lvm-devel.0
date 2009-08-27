From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:28 +0200
Subject: [PATCH 07/15] clvmd: improve libconfdb check
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <edca8a3633bca49523f72978ae15f642d64e923e.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add sanity checks for libconfdb.

Propagate the build info in a more consisten way.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 cc4697d... a38173d... M	configure.in
:100644 100644 f643644... e00c733... M	daemons/clvmd/Makefile.in
 configure.in              |   26 ++++++++++++++++++++++++++
 daemons/clvmd/Makefile.in |   10 ++++++----
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/configure.in b/configure.in
index cc4697d..a38173d 100644
--- a/configure.in
+++ b/configure.in
@@ -416,6 +416,32 @@ if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 		CPG_LIBS="-lcpg"])
 fi
 
+dnl -- Below are checks for libraries common to more than one build.
+
+dnl -- Check confdb library.
+dnl -- mandatory for corosync build.
+dnl -- optional for openais/cman build.
+
+if test x$CHECKCONFDB = xyes; then
+	PKG_CHECK_MODULES(CONFDB, libconfdb,,
+			  [HAVE_PKG_CONFDB=no])
+
+	if test x$BUILDCOROSYNC = xyes && \
+	   test x$HAVE_PKG_CONFDB = xno; then
+		AC_MSG_ERROR([bailing out... confdb library is required])
+	fi
+
+	AC_CHECK_HEADERS(corosync/confdb.h,
+		[HAVE_CONFDB_H=yes],
+		[HAVE_CONFDB_H=no])
+
+	if test x$HAVE_PKG_CONFDB = xno && \
+	   test x$HAVE_CONFDB_H = xyes; then
+		AC_MSG_RESULT([no pkg for confdb library, using -lconfdb])
+		CONFDB_LIBS="-lconfdb"
+	fi
+fi
+
 ################################################################################
 dnl -- Build cluster log daemon
 AC_MSG_CHECKING(whether to build cluster log daemon)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index f643644..e00c733 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -68,20 +68,22 @@ endif
 
 ifeq ("$(CMAN)", "yes")
 	SOURCES += clvmd-cman.c
-	LMLIBS += -ldlm -lcman
+	LMLIBS += $(CONFDB_LIBS) -ldlm -lcman
+	CFLAGS += $(CONFDB_CFLAGS)
 	DEFS += -DUSE_CMAN
 endif
 
 ifeq ("$(OPENAIS)", "yes")
 	SOURCES += clvmd-openais.c
-	LMLIBS += -lSaLck -lcpg
+	LMLIBS += $(CONFDB_LIBS) -lSaLck -lcpg
+	CFLAGS += $(CONFDB_CFLAGS)
 	DEFS += -DUSE_OPENAIS
 endif
 
 ifeq ("$(COROSYNC)", "yes")
 	SOURCES += clvmd-corosync.c
-	LMLIBS += $(QUORUM_LIBS) $(CONFDB_LIBS) $(CPG_LIBS) -ldlm
-	CFLAGS += $(QUORUM_CFLAGS) $(CONFDB_CFLAGS) $(CPG_CFLAGS)
+	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(QUORUM_LIBS) -ldlm
+	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(QUORUM_CFLAGS)
 	DEFS += -DUSE_COROSYNC
 endif
 
-- 
1.5.4.3


