From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:25 +0200
Subject: [PATCH 04/15] configure.in: Add dummy pkg-config initialization
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <f6a597a08ebf6b29dee443d5443a25a36423109f.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

PKG_CHECK_MODULES macro is expanded to initialize the pkg-config
environment only at the first invokation.
In our configure.in all PKG_CHECK_MODULES are/will be conditionals.

This change will make sure to init the enviroment properly and
only if required.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 a6d90e7... e9a1206... M	configure.in
 configure.in |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index a6d90e7..e9a1206 100644
--- a/configure.in
+++ b/configure.in
@@ -366,6 +366,15 @@ if test x$BUILDGULM = xyes; then
 	fi
 fi
 
+dnl -- Init pkg-config with dummy invokation:
+dnl -- this is required because PKG_CHECK_MODULES macro is expanded
+dnl -- to initialize the pkg-config environment only at the first invokation,
+dnl -- that would be conditional in this configure.in.
+if  test x$CLVMD != xnone; then
+	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
+		[AC_MSG_RESULT([pkg-config initialized])])
+fi
+
 dnl -- Look for corosync libraries if required.
 if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
-- 
1.5.4.3


