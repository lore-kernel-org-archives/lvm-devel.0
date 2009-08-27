From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:29 +0200
Subject: [PATCH 08/15] clvmd: improve libcpg check.
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <d279584c3ab97c2e35a2c15a2283a911dd09cb08.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add sanity checks for libcpg.

Propagate the build info in a more consisten way.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 a38173d... 81379c0... M	configure.in
:100644 100644 e00c733... 2c9915c... M	daemons/clvmd/Makefile.in
 configure.in              |    5 +++++
 daemons/clvmd/Makefile.in |    4 ++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index a38173d..81379c0 100644
--- a/configure.in
+++ b/configure.in
@@ -442,6 +442,11 @@ if test x$CHECKCONFDB = xyes; then
 	fi
 fi
 
+dnl -- Check cpg library.
+if test x$CHECKCPG = xyes; then
+	PKG_CHECK_MODULES(CPG, libcpg)
+fi
+
 ################################################################################
 dnl -- Build cluster log daemon
 AC_MSG_CHECKING(whether to build cluster log daemon)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index e00c733..2c9915c 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -75,8 +75,8 @@ endif
 
 ifeq ("$(OPENAIS)", "yes")
 	SOURCES += clvmd-openais.c
-	LMLIBS += $(CONFDB_LIBS) -lSaLck -lcpg
-	CFLAGS += $(CONFDB_CFLAGS)
+	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) -lSaLck
+	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS)
 	DEFS += -DUSE_OPENAIS
 endif
 
-- 
1.5.4.3


