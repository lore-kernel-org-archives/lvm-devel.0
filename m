From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:27:59 +0000 (UTC)
Subject: master - configure: report whether to build lvmlockd
Message-ID: <20151109092759.1C361601B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=459b3db61e14a9ac28fc9fd4d029accd6dee6330
Commit:        459b3db61e14a9ac28fc9fd4d029accd6dee6330
Parent:        af6adec7cc1e4229a88cc9d7951a51d0d22c5032
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 2 20:04:50 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 09:58:27 2015 +0100

configure: report whether to build lvmlockd

Report configured status for build with lvmlockd.
---
 WHATS_NEW    |    1 +
 configure    |   24 ++++++++----------------
 configure.in |   16 ++++------------
 3 files changed, 13 insertions(+), 28 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5e89eca..a30786a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Correct configure messages when enabling/disabling lvmlockd.
 
 Version 2.02.134 - 9th November 2015
 ====================================
diff --git a/configure b/configure
index 31dc750..c566466 100755
--- a/configure
+++ b/configure
@@ -3130,7 +3130,6 @@ case "$host_os" in
 		DEVMAPPER=yes
 		LVMETAD=no
 		LVMPOLLD=no
-		LVMLOCKD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
 		ODIRECT=yes
@@ -11368,6 +11367,8 @@ $as_echo "$LVMPOLLD" >&6; }
 BUILD_LVMPOLLD=$LVMPOLLD
 
 ################################################################################
+BUILD_LVMLOCKD=no
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lockdsanlock" >&5
 $as_echo_n "checking whether to build lockdsanlock... " >&6; }
 # Check whether --enable-lockd-sanlock was given.
@@ -11382,13 +11383,6 @@ BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
 if test "$BUILD_LOCKDSANLOCK" = yes; then
 
-$as_echo "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
-
-fi
-
-################################################################################
-if test "$BUILD_LOCKDSANLOCK" = yes; then
-
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
 $as_echo_n "checking for LOCKD_SANLOCK... " >&6; }
@@ -11459,6 +11453,9 @@ else
 $as_echo "yes" >&6; }
 	HAVE_LOCKD_SANLOCK=yes
 fi
+
+$as_echo "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
+
 	BUILD_LVMLOCKD=yes
 fi
 
@@ -11477,13 +11474,6 @@ BUILD_LOCKDDLM=$LOCKDDLM
 
 if test "$BUILD_LOCKDDLM" = yes; then
 
-$as_echo "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
-
-fi
-
-################################################################################
-if test "$BUILD_LOCKDDLM" = yes; then
-
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
 $as_echo_n "checking for LOCKD_DLM... " >&6; }
@@ -11554,11 +11544,13 @@ else
 $as_echo "yes" >&6; }
 	HAVE_LOCKD_DLM=yes
 fi
+
+$as_echo "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
+
 	BUILD_LVMLOCKD=yes
 fi
 
 ################################################################################
-
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
 $as_echo_n "checking whether to build lvmlockd... " >&6; }
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
diff --git a/configure.in b/configure.in
index c240b4b..68bd341 100644
--- a/configure.in
+++ b/configure.in
@@ -39,7 +39,6 @@ case "$host_os" in
 		DEVMAPPER=yes
 		LVMETAD=no
 		LVMPOLLD=no
-		LVMLOCKD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
 		ODIRECT=yes
@@ -1145,6 +1144,8 @@ AC_MSG_RESULT($LVMPOLLD)
 BUILD_LVMPOLLD=$LVMPOLLD
 
 ################################################################################
+BUILD_LVMLOCKD=no
+
 dnl -- Build lockdsanlock
 AC_MSG_CHECKING(whether to build lockdsanlock)
 AC_ARG_ENABLE(lockd-sanlock,
@@ -1155,14 +1156,10 @@ AC_MSG_RESULT($LOCKDSANLOCK)
 
 BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
-if test "$BUILD_LOCKDSANLOCK" = yes; then
-	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
-fi
-
-################################################################################
 dnl -- Look for sanlock libraries
 if test "$BUILD_LOCKDSANLOCK" = yes; then
 	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client, [HAVE_LOCKD_SANLOCK=yes], $bailout)
+	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
 	BUILD_LVMLOCKD=yes
 fi
 
@@ -1177,20 +1174,15 @@ AC_MSG_RESULT($LOCKDDLM)
 
 BUILD_LOCKDDLM=$LOCKDDLM
 
-if test "$BUILD_LOCKDDLM" = yes; then
-	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
-fi
-
-################################################################################
 dnl -- Look for dlm libraries
 if test "$BUILD_LOCKDDLM" = yes; then
 	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
+	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
 	BUILD_LVMLOCKD=yes
 fi
 
 ################################################################################
 dnl -- Build lvmlockd
-
 AC_MSG_CHECKING(whether to build lvmlockd)
 AC_MSG_RESULT($BUILD_LVMLOCKD)
 


