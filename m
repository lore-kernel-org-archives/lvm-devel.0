From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 18 Oct 2021 17:19:30 +0000 (GMT)
Subject: main - configure.ac: remove unused part
Message-ID: <20211018171930.742803858404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b104ddb5539f998389afa3394cbc81d9410b390
Commit:        1b104ddb5539f998389afa3394cbc81d9410b390
Parent:        a172a02a9a980d084d5729cc8483bdddad0100f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 16 22:08:50 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 18 19:17:27 2021 +0200

configure.ac: remove unused part

As we are not using 'enable-compat' for anything, remove this section.
Also remove duplicated check for blkid.
Move setting of some AC_ARG_ENABLE defaults into the macro so it's always
defined.
---
 configure.ac | 29 ++++++-----------------------
 1 file changed, 6 insertions(+), 23 deletions(-)

diff --git a/configure.ac b/configure.ac
index 2f821edae..6cdf1a7e6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -38,10 +38,6 @@ case "$host_os" in
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		BUILD_LVMPOLLD=no
-		LOCKDSANLOCK=no
-		LOCKDDLM=no
-		LOCKDDLM_CONTROL=no
-		LOCKDIDM=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -946,7 +942,7 @@ AC_MSG_CHECKING(whether to build lvmpolld)
 AC_ARG_ENABLE(lvmpolld,
 	      AS_HELP_STRING([--enable-lvmpolld],
 			     [enable the LVM Polling Daemon]),
-	      LVMPOLLD=$enableval)
+	      LVMPOLLD=$enableval, LVMPOLLD=no)
 test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
 AC_MSG_RESULT($BUILD_LVMPOLLD)
 
@@ -958,7 +954,7 @@ AC_MSG_CHECKING(whether to build lvmlockdsanlock)
 AC_ARG_ENABLE(lvmlockd-sanlock,
 	      AS_HELP_STRING([--enable-lvmlockd-sanlock],
 			     [enable the LVM lock daemon using sanlock]),
-	      LOCKDSANLOCK=$enableval)
+	      LOCKDSANLOCK=$enableval, LOCKDSANLOCK=no)
 AC_MSG_RESULT($LOCKDSANLOCK)
 
 BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
@@ -976,7 +972,7 @@ AC_MSG_CHECKING(whether to build lvmlockddlm)
 AC_ARG_ENABLE(lvmlockd-dlm,
 	      AS_HELP_STRING([--enable-lvmlockd-dlm],
 			     [enable the LVM lock daemon using dlm]),
-	      LOCKDDLM=$enableval)
+	      LOCKDDLM=$enableval, LOCKDDLM=no)
 AC_MSG_RESULT($LOCKDDLM)
 
 BUILD_LOCKDDLM=$LOCKDDLM
@@ -994,7 +990,7 @@ AC_MSG_CHECKING(whether to build lvmlockddlmcontrol)
 AC_ARG_ENABLE(lvmlockd-dlmcontrol,
 	      AS_HELP_STRING([--enable-lvmlockd-dlmcontrol],
 			     [enable lvmlockd remote refresh using libdlmcontrol]),
-	      LOCKDDLM_CONTROL=$enableval)
+	      LOCKDDLM_CONTROL=$enableval, LOCKDDLM_CONTROL=no)
 AC_MSG_RESULT($LOCKDDLM_CONTROL)
 
 BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
@@ -1012,7 +1008,7 @@ AC_MSG_CHECKING(whether to build lvmlockdidm)
 AC_ARG_ENABLE(lvmlockd-idm,
 	      AS_HELP_STRING([--enable-lvmlockd-idm],
 			     [enable the LVM lock daemon using idm]),
-	      LOCKDIDM=$enableval)
+	      LOCKDIDM=$enableval, LOCKDIDM=no)
 AC_MSG_RESULT($LOCKDIDM)
 
 BUILD_LOCKDIDM=$LOCKDIDM
@@ -1020,7 +1016,7 @@ BUILD_LOCKDIDM=$LOCKDIDM
 dnl -- Look for Seagate IDM libraries
 if test "$BUILD_LOCKDIDM" = yes; then
 	PKG_CHECK_MODULES(LOCKD_IDM, libseagate_ilm >= 0.1.0, [HAVE_LOCKD_IDM=yes], $bailout)
-	PKG_CHECK_MODULES(BLKID, blkid >= 2.24, [HAVE_LOCKD_IDM=yes], $bailout)
+	PKG_CHECK_EXISTS(blkid >= 2.24, [HAVE_LOCKD_IDM=yes], $bailout)
 	AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
 	BUILD_LVMLOCKD=yes
 fi
@@ -1251,19 +1247,6 @@ if test "$UDEV_RULE" != no ; then
 	AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
 fi
 
-################################################################################
-dnl -- Compatibility mode
-AC_ARG_ENABLE(compat,
-	      AS_HELP_STRING([--enable-compat],
-			     [enable support for old device-mapper versions]),
-	      DM_COMPAT=$enableval, DM_COMPAT=no)
-
-AS_IF([test "$DM_COMPAT" = yes],
-      [AC_DEFINE([DM_COMPAT], 1, [Define to enable compat protocol])
-      AC_MSG_ERROR([--enable-compat is not currently supported.
-Since device-mapper version 1.02.66, only one version (4) of the device-mapper
-ioctl protocol is supported.])])
-
 ################################################################################
 dnl -- Compatible units suffix mode
 AC_ARG_ENABLE(units-compat,


