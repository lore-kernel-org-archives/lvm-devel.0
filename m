From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:50 +0000 (GMT)
Subject: main - configure.ac: use standardized LIBS and CFLAGS
Message-ID: <20230216231050.BDA913858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c23d09bbcea15d5c639b8347bdf30106dee12660
Commit:        c23d09bbcea15d5c639b8347bdf30106dee12660
Parent:        d106ac04ab340d170dc5460e023df73e63bb98ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:28:08 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

configure.ac: use standardized LIBS and CFLAGS

Convert lvmlockd to use configure _LIBS and _CFLAGS for
discovered libraries.

TODO: ATM we ignore discovered libdlm and use libdlm_lt instead.
Also libseagate_ilm is hard to find unicorn for testing.
---
 configure.ac                 | 17 +++++++----------
 daemons/lvmlockd/Makefile.in | 11 +++++++----
 make.tmpl.in                 |  8 ++++++++
 3 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/configure.ac b/configure.ac
index 17d90bc85..78663b5bf 100644
--- a/configure.ac
+++ b/configure.ac
@@ -913,9 +913,8 @@ AC_MSG_RESULT([$BUILD_LOCKDSANLOCK])
 
 dnl -- Look for sanlock libraries
 AS_IF([test "$BUILD_LOCKDSANLOCK" = "yes"], [
-	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client >= 3.3.0, [HAVE_LOCKD_SANLOCK="yes"], $bailout)
+	PKG_CHECK_MODULES(LIBSANLOCKCLIENT, libsanlock_client >= 3.3.0, [BUILD_LVMLOCKD="yes"], $bailout)
 	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
-	BUILD_LVMLOCKD=yes
 ])
 
 ################################################################################
@@ -929,9 +928,8 @@ AC_MSG_RESULT([$BUILD_LOCKDDLM])
 
 dnl -- Look for dlm libraries
 AS_IF([test "$BUILD_LOCKDDLM" = "yes"], [
-	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM="yes"], $bailout)
+	PKG_CHECK_MODULES(LIBDLM, libdlm, [BUILD_LVMLOCKD="yes"], $bailout)
 	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
-	BUILD_LVMLOCKD=yes
 ])
 
 ################################################################################
@@ -945,9 +943,8 @@ AC_MSG_RESULT([$BUILD_LOCKDDLM_CONTROL])
 
 dnl -- Look for libdlmcontrol libraries
 AS_IF([test "$BUILD_LOCKDDLM_CONTROL" = "yes"], [
-	PKG_CHECK_MODULES(LOCKD_DLM_CONTROL, libdlmcontrol >= 3.2, [HAVE_LOCKD_DLM_CONTROL=yes], $bailout)
+	PKG_CHECK_MODULES(LIBDLMCONTROL, [libdlmcontrol >= 3.2], [BUILD_LVMLOCKD="yes"], $bailout)
 	AC_DEFINE([LOCKDDLM_CONTROL_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm control option.])
-	BUILD_LVMLOCKD=yes
 ])
 
 ################################################################################
@@ -961,10 +958,10 @@ AC_MSG_RESULT([$BUILD_LOCKDIDM])
 
 dnl -- Look for Seagate IDM libraries
 AS_IF([test "$BUILD_LOCKDIDM" = "yes"], [
-	PKG_CHECK_MODULES(LOCKD_IDM, libseagate_ilm >= 0.1.0, [HAVE_LOCKD_IDM=yes], $bailout)
-	PKG_CHECK_EXISTS(blkid >= 2.24, [HAVE_LOCKD_IDM="yes"], $bailout)
-	AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
-	BUILD_LVMLOCKD=yes
+	PKG_CHECK_EXISTS(blkid >= 2.24, [
+		PKG_CHECK_MODULES(LIBSEAGATEILM, [libseagate_ilm >= 0.1.0], [BUILD_LVMLOCKD="yes"], $bailout)
+		AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
+	], $bailout)
 ])
 
 ################################################################################
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index dd35d5411..aff4c0123 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -19,18 +19,21 @@ SOURCES = lvmlockd-core.c
 
 ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
   SOURCES += lvmlockd-sanlock.c
-  LOCK_LIBS += -lsanlock_client
+  CFLAGS += $(LIBSANLOCKCLIENT_CFLAGS)
+  LOCK_LIBS += $(LIBSANLOCKCLIENT_LIBS)
 endif
 
 ifeq ("@BUILD_LOCKDDLM@", "yes")
   SOURCES += lvmlockd-dlm.c
-  LOCK_LIBS += -ldlm_lt
-  LOCK_LIBS += -ldlmcontrol
+  CFLAGS += $(LIBDLM) $(LIBDLMCONTROL_CFLAGS)
+#  LOCK_LIBS += $(LIBDLM_LIBS) $(LIBDLMCONTROL_LIBS)
+  LOCK_LIBS += -ldlm_lt $(LIBDLMCONTROL_LIBS)
 endif
 
 ifeq ("@BUILD_LOCKDIDM@", "yes")
   SOURCES += lvmlockd-idm.c
-  LOCK_LIBS += -lseagate_ilm -lblkid
+#  LOCK_LIBS += $(LIBSEAGATEILM_LIBS) $(BLKID_LIBS)
+  LOCK_LIBS += -lseagate_ilm $(BLKID_LIBS)
 endif
 
 SOURCES2 = lvmlockctl.c
diff --git a/make.tmpl.in b/make.tmpl.in
index a1fae368d..b73176f5a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -82,6 +82,14 @@ CPG_CFLAGS = @CPG_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
 EDITLINE_CFLAGS = @EDITLINE_CFLAGS@
 EDITLINE_LIBS = @EDITLINE_LIBS@
+LIBDLM_CFLAGS = @LIBDLM_CFLAGS@
+LIBDLM_LIBS = @LIBDLM_LIBS@
+LIBDLMCONTROL_CFLAGS = @LIBDLMCONTROL_CFLAGS@
+LIBDLMCONTROL_LIBS = @LIBDLMCONTROL_LIBS@
+LIBSANLOCKCLIENT_CFLAGS = @LIBSANLOCKCLIENT_CFLAGS@
+LIBSANLOCKCLIENT_LIBS = @LIBSANLOCKCLIENT_LIBS@
+LIBSEAGATEILM_CFLAGS = @LIBSEAGATEILM_CFLAGS@
+LIBSEAGATEILM_LIBS = @LIBSEAGATEILM_LIBS@
 LIBSYSTEMD_CFLAGS = @LIBSYSTEMD_CFLAGS@
 LIBSYSTEMD_LIBS = @LIBSYSTEMD_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@

