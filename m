From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 21 May 2009 11:03:27 -0400
Subject: [PATCH] Add configure option to build liblvm - do not build by default.
Message-ID: <1242918207-12356-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 Makefile.in  |    8 ++++++--
 configure.in |   13 +++++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index d9c93d0..055e1b9 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -22,7 +22,11 @@ ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm liblvm
+SUBDIRS += lib tools daemons libdm
+
+ifeq ("@LIBLVM@", "yes")
+  SUBDIRS += liblvm
+endif
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
@@ -46,7 +50,7 @@ libdm: include
 lib: libdm
 liblvm: lib
 daemons: lib tools
-tools: lib device-mapper liblvm
+tools: lib device-mapper
 po: tools daemons
 
 libdm.device-mapper: include.device-mapper
diff --git a/configure.in b/configure.in
index aa3faa2..3304ed6 100644
--- a/configure.in
+++ b/configure.in
@@ -322,6 +322,18 @@ REALTIME=$enableval)
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
+dnl -- Build liblvm external library
+AC_MSG_CHECKING(whether to build liblvm external library)
+AC_ARG_WITH(liblvm,
+  [  --with-liblvm=BUILD     Build liblvm: yes/no [[BUILD=no]] ],
+  [ LIBLVM="$withval" ],
+  [ LIBLVM="no" ])
+if test x$LIBLVM = xyes; then
+	LIBLVM=yes
+fi
+AC_MSG_RESULT($LIBLVM)
+
+################################################################################
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
@@ -783,6 +795,7 @@ AC_SUBST(INTL_PACKAGE)
 AC_SUBST(JOBS)
 AC_SUBST(LDDEPS)
 AC_SUBST(LIBS)
+AC_SUBST(LIBLVM)
 AC_SUBST(LIB_SUFFIX)
 AC_SUBST(LOCALEDIR)
 AC_SUBST(LVM1)
-- 
1.6.0.6


