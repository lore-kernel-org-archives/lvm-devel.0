From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:33 +0200
Subject: [PATCH 12/15] clvmd: improve openais build
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <cef92c73e872a0cbeda0f7accdedc62fc08b0529.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add sanity checks for libSaLck.

Propagate the build info in a more consisten way.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 5211add... df8c6e9... M	configure.in
:100644 100644 3baa4b9... a79952c... M	daemons/clvmd/Makefile.in
 configure.in              |    8 ++++++++
 daemons/clvmd/Makefile.in |    6 ++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index 5211add..df8c6e9 100644
--- a/configure.in
+++ b/configure.in
@@ -430,6 +430,12 @@ if test x$BUILDCOROSYNC = xyes; then
 	CHECKDLM=yes
 fi
 
+dnl -- Look for openais libraries if required.
+if test x$BUILDOPENAIS = xyes; then
+	PKG_CHECK_MODULES(SALCK, libSaLck)
+	CHECKCPG=yes
+fi
+
 dnl -- Below are checks for libraries common to more than one build.
 
 dnl -- Check confdb library.
@@ -991,6 +997,8 @@ AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(SALCK_CFLAGS)
+AC_SUBST(SALCK_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 3baa4b9..a79952c 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -29,6 +29,8 @@ GULM_LIBS = @GULM_LIBS@
 GULM_CFLAGS = @GULM_CFLAGS@
 QUORUM_LIBS = @QUORUM_LIBS@
 QUORUM_CFLAGS = @QUORUM_CFLAGS@
+SALCK_LIBS = @SALCK_LIBS@
+SALCK_CFLAGS = @SALCK_CFLAGS@
 
 SOURCES = \
 	clvmd-command.c  \
@@ -79,8 +81,8 @@ endif
 
 ifeq ("$(OPENAIS)", "yes")
 	SOURCES += clvmd-openais.c
-	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) -lSaLck
-	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS)
+	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(SALCK_LIBS)
+	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(SALCK_CFLAGS)
 	DEFS += -DUSE_OPENAIS
 endif
 
-- 
1.5.4.3


