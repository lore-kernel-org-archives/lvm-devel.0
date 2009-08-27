From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:32 +0200
Subject: [PATCH 11/15] clvmd: improve corosync build
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <8afd34775b03937e044dbfa9d0f6933b5e67f65b.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use common library check infrastructure.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 2b35462... 5211add... M	configure.in
 configure.in |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/configure.in b/configure.in
index 2b35462..5211add 100644
--- a/configure.in
+++ b/configure.in
@@ -414,17 +414,20 @@ if test x$BUILDCMAN = xyes; then
 	CHECKDLM=yes
 fi
 
+dnl -- Look for corosync that's required also for openais build
+dnl -- only enough recent version of corosync ship pkg-config files.
+dnl -- We can safely rely on that to detect the correct bits.
+if test x$BUILDCOROSYNC = xyes || \
+   test x$BUILDOPENAIS = xyes; then
+	PKG_CHECK_MODULES(COROSYNC, corosync)
+	CHECKCONFDB=yes
+fi
+
 dnl -- Look for corosync libraries if required.
-if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
-	PKG_CHECK_MODULES(QUORUM, libquorum, [],
-		[AC_MSG_RESULT([no pkg for quorum library, using -lquorum]);
-		QUORUM_LIBS="-lquorum"])
-	PKG_CHECK_MODULES(CONFDB, libconfdb, [],
-		[AC_MSG_RESULT([no pkg for confdb library, using -lconfdb]);
-		CONFDB_LIBS="-lconfdb"])
-	PKG_CHECK_MODULES(CPG, libcpg, [],
-		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
-		CPG_LIBS="-lcpg"])
+if test x$BUILDCOROSYNC = xyes; then
+	PKG_CHECK_MODULES(QUORUM, libquorum)
+	CHECKCPG=yes
+	CHECKDLM=yes
 fi
 
 dnl -- Below are checks for libraries common to more than one build.
-- 
1.5.4.3


