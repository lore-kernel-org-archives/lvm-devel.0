From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:55 +0000 (GMT)
Subject: main - configure.ac: update dlm check
Message-ID: <20230223154855.B7C6A3858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad66600e480d49c22372231c0a56ea3bf5a9b842
Commit:        ad66600e480d49c22372231c0a56ea3bf5a9b842
Parent:        d91bc6904dce256b06687217ec66caba15b33a7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 20 21:01:31 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

configure.ac: update dlm check

Check for pkg-config --libs libdlm_lt  and test if the returned value
contains word 'pthread' - if so, it's likely a buggy result from
incorrect config file and use directly  -ldlm_lt for this case.
---
 configure.ac                 | 8 +++++++-
 daemons/lvmlockd/Makefile.in | 3 +--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 86f4941d8..06184be62 100644
--- a/configure.ac
+++ b/configure.ac
@@ -928,8 +928,13 @@ AC_MSG_RESULT([$BUILD_LOCKDDLM])
 
 dnl -- Look for dlm libraries
 AS_IF([test "$BUILD_LOCKDDLM" = "yes"], [
-	PKG_CHECK_MODULES(LIBDLM, libdlm, [BUILD_LVMLOCKD="yes"], $bailout)
+	PKG_CHECK_MODULES(LIBDLM, libdlm_lt, [BUILD_LVMLOCKD="yes"], $bailout)
 	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
+	AS_CASE(["$LIBDLM_LIBS"],
+		[*lpthread*], [
+			dnl -- pkg-congig for libdlm_lt may give us libdlm with libpthread
+			AC_MSG_RESULT([replacing pkg-config --libs libdlm_lt "$LIBDLM_LIBS" with... -ldlm_lt])
+			LIBDLM_LIBS="${LIBDLM_LIBS%%ldlm*}ldlm_lt"])
 ])
 
 ################################################################################
@@ -961,6 +966,7 @@ AS_IF([test "$BUILD_LOCKDIDM" = "yes"], [
 	PKG_CHECK_EXISTS(blkid >= 2.24, [
 		PKG_CHECK_MODULES(LIBSEAGATEILM, [libseagate_ilm >= 0.1.0], [BUILD_LVMLOCKD="yes"], $bailout)
 		AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
+		AS_IF([test -z "$LIBSEAGATEILM_LIBS"], [LIBSEAGATEILM_LIBS="-lseagate_ilm"])
 	], $bailout)
 ])
 
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 24191c439..6d81d72fb 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -37,8 +37,7 @@ endif
 
 ifeq ("@BUILD_LOCKDIDM@", "yes")
   SOURCES += lvmlockd-idm.c
-#  LOCK_LIBS += $(LIBSEAGATEILM_LIBS) $(BLKID_LIBS)
-  LOCK_LIBS += -lseagate_ilm $(BLKID_LIBS)
+  LOCK_LIBS += $(LIBSEAGATEILM_LIBS) $(BLKID_LIBS)
 endif
 
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))

