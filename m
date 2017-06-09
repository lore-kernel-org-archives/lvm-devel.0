From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 07:04:58 -0400
Subject: master - configure: report yes or no for wiping and system
Message-ID: <201706091104.v59B4wRj003850@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5017284709102834c21bed408e54fccde8523d51
Commit:        5017284709102834c21bed408e54fccde8523d51
Parent:        b3ef051e0637ac7f72ab245342e5a29394071c24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 12:56:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 13:02:18 2017 +0200

configure: report yes or no for wiping and system

Avoid reporting 'checking result' as maybe - it should
clearly tell 'yes' or 'no'.

Just shuffle printed message to the place, where we
already know the 'maybe' answer.

So instead of printing 'unclear':

checking whether to enable libblkid detection of signatures when wiping... maybe
checking for BLKID... yes
checking whether to use udev-systemd protocol for jobs in background... maybe
checking for SYSTEMD... yes

show this:

checking for BLKID... yes
checking whether to enable libblkid detection of signatures when wiping... yes
checking for SYSTEMD... yes
checking whether to use udev-systemd protocol for jobs in background... yes
---
 configure    |   35 ++++++++++++++++-------------------
 configure.in |   28 ++++++++++++----------------
 2 files changed, 28 insertions(+), 35 deletions(-)

diff --git a/configure b/configure
index ffef9b9..28b0488 100755
--- a/configure
+++ b/configure
@@ -12223,8 +12223,6 @@ fi
 
 ################################################################################
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
-$as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
 # Check whether --enable-blkid_wiping was given.
 if test "${enable_blkid_wiping+set}" = set; then :
   enableval=$enable_blkid_wiping; BLKID_WIPING=$enableval
@@ -12232,9 +12230,8 @@ else
   BLKID_WIPING=maybe
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
-$as_echo "$BLKID_WIPING" >&6; }
 
+DEFAULT_USE_BLKID_WIPING=0
 if test "$BLKID_WIPING" != no; then
 	pkg_config_init
 
@@ -12314,20 +12311,19 @@ else
 	BLKID_LIBS=$pkg_cv_BLKID_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-	test "$BLKID_WIPING" = maybe && BLKID_WIPING=yes
-fi
-	if test "$BLKID_WIPING" = yes; then
-		BLKID_PC="blkid"
-		DEFAULT_USE_BLKID_WIPING=1
+	 BLKID_WIPING=yes
+			    BLKID_PC="blkid"
+			    DEFAULT_USE_BLKID_WIPING=1
 
 $as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
-	else
-		DEFAULT_USE_BLKID_WIPING=0
-	fi
-else
-	DEFAULT_USE_BLKID_WIPING=0
+
 fi
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
+$as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
+$as_echo "$BLKID_WIPING" >&6; }
 
 cat >>confdefs.h <<_ACEOF
 #define DEFAULT_USE_BLKID_WIPING $DEFAULT_USE_BLKID_WIPING
@@ -12335,8 +12331,6 @@ _ACEOF
 
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
-$as_echo_n "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
 # Check whether --enable-udev-systemd-background-jobs was given.
 if test "${enable_udev_systemd_background_jobs+set}" = set; then :
   enableval=$enable_udev_systemd_background_jobs; UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval
@@ -12344,8 +12338,6 @@ else
   UDEV_SYSTEMD_BACKGROUND_JOBS=maybe
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
-$as_echo "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
 
 if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
 	pkg_config_init
@@ -12426,10 +12418,15 @@ else
 	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-	test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes
+	UDEV_SYSTEMD_BACKGROUND_JOBS=yes
 fi
 fi
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
+$as_echo_n "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
+$as_echo "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
 $as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
diff --git a/configure.in b/configure.in
index 2ff4f99..8603a12 100644
--- a/configure.in
+++ b/configure.in
@@ -1310,50 +1310,43 @@ fi
 ################################################################################
 
 dnl -- Enable blkid wiping functionality
-AC_MSG_CHECKING(whether to enable libblkid detection of signatures when wiping)
 AC_ARG_ENABLE(blkid_wiping,
 	      AC_HELP_STRING([--disable-blkid_wiping],
 			     [disable libblkid detection of signatures when wiping and use native code instead]),
 	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
-AC_MSG_RESULT($BLKID_WIPING)
 
+DEFAULT_USE_BLKID_WIPING=0
 if test "$BLKID_WIPING" != no; then
 	pkg_config_init
 	PKG_CHECK_MODULES(BLKID, blkid >= 2.24,
-			  [test "$BLKID_WIPING" = maybe && BLKID_WIPING=yes],
-			  [if test "$BLKID_WIPING" = maybe; then
+			  [ BLKID_WIPING=yes
+			    BLKID_PC="blkid"
+			    DEFAULT_USE_BLKID_WIPING=1
+			    AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
+			  ], [if test "$BLKID_WIPING" = maybe; then
 				BLKID_WIPING=no
 			   else
 			        AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
 			   fi])
-	if test "$BLKID_WIPING" = yes; then
-		BLKID_PC="blkid"
-		DEFAULT_USE_BLKID_WIPING=1
-		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
-	else
-		DEFAULT_USE_BLKID_WIPING=0
-	fi
-else
-	DEFAULT_USE_BLKID_WIPING=0
 fi
+AC_MSG_CHECKING([whether to enable libblkid detection of signatures when wiping])
+AC_MSG_RESULT($BLKID_WIPING)
 AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
 		   [Use blkid wiping by default.])
 
 ################################################################################
 dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
 dnl -- Requires systemd version 205 at least (including support for systemd-run)
-AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
 AC_ARG_ENABLE(udev-systemd-background-jobs,
 	      AC_HELP_STRING([--disable-udev-systemd-background-jobs],
 			     [disable udev-systemd protocol to instantiate a service for background job]),
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval,
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=maybe)
-AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
 
 if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
 	pkg_config_init
 	PKG_CHECK_MODULES(SYSTEMD, systemd >= 205,
-			  [test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
+			  [UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
 			  [if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
 				UDEV_SYSTEMD_BACKGROUND_JOBS=no
 			   else
@@ -1361,6 +1354,9 @@ if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
 			   fi])
 fi
 
+AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
+AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
+
 ################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)


