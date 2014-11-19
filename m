From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 19 Nov 2014 12:50:16 +0000 (UTC)
Subject: master - configure: make configure --enable-udev-systemd-background-jobs only for systemd >= 205
Message-ID: <20141119125016.9BE0260E2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74ed1ba9f99aaf16906d53c28ad604eaa7a21419
Commit:        74ed1ba9f99aaf16906d53c28ad604eaa7a21419
Parent:        422d1ac8d244e1d7c5e122c54efe0ad67ce98d04
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 19 13:47:09 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 19 13:47:18 2014 +0100

configure: make configure --enable-udev-systemd-background-jobs only for systemd >= 205

systemd-run is available in systemd>=205. Also, this fix prevents
systemd-specific udev rules in 69-dm-lvm-metad.rules to appear in
case systemd environment is not available - make configure to check
this automatically and use these systemd specific rules only if it
is applicable.
---
 WHATS_NEW    |    1 +
 aclocal.m4   |    2 +-
 configure    |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 configure.in |   15 +++++++++-
 4 files changed, 108 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 33546ac..3ccb8dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Default to configure --enable-udev-systemd-background-jobs for systemd>=205.
   Fix ignore_vg() to properly react on various vg_read errors (2.02.112).
   Failed recovery returns FAILED_RECOVERY status flag for vg_read().
   Exit with non-zero status code when pvck encounters a problem.
diff --git a/aclocal.m4 b/aclocal.m4
index 2325191..6f752f2 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,4 +1,4 @@
-# generated automatically by aclocal 1.14.1 -*- Autoconf -*-
+# generated automatically by aclocal 1.13.4 -*- Autoconf -*-
 
 # Copyright (C) 1996-2013 Free Software Foundation, Inc.
 
diff --git a/configure b/configure
index 28651ac..a2a094c 100755
--- a/configure
+++ b/configure
@@ -736,6 +736,8 @@ LVM2CMD_LIB
 LVM2APP_LIB
 UDEV_LIBS
 UDEV_CFLAGS
+SYSTEMD_LIBS
+SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
 VALGRIND_POOL
@@ -984,6 +986,8 @@ VALGRIND_CFLAGS
 VALGRIND_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
+SYSTEMD_CFLAGS
+SYSTEMD_LIBS
 UDEV_CFLAGS
 UDEV_LIBS'
 
@@ -1791,6 +1795,10 @@ Some influential environment variables:
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
+  SYSTEMD_CFLAGS
+              C compiler flags for SYSTEMD, overriding pkg-config
+  SYSTEMD_LIBS
+              linker flags for SYSTEMD, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
 
@@ -10601,12 +10609,95 @@ $as_echo_n "checking whether to use udev-systemd protocol for jobs in background
 if test "${enable_udev_systemd_background_jobs+set}" = set; then :
   enableval=$enable_udev_systemd_background_jobs; UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval
 else
-  UDEV_SYSTEMD_BACKGROUND_JOBS=yes
+  UDEV_SYSTEMD_BACKGROUND_JOBS=maybe
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
 $as_echo "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
 
+if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
+	pkg_config_init
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
+$as_echo_n "checking for SYSTEMD... " >&6; }
+
+if test -n "$SYSTEMD_CFLAGS"; then
+    pkg_cv_SYSTEMD_CFLAGS="$SYSTEMD_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd >= 205" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$SYSTEMD_LIBS"; then
+    pkg_cv_SYSTEMD_LIBS="$SYSTEMD_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd >= 205" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= 205" 2>&1`
+        else
+	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= 205" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$SYSTEMD_PKG_ERRORS" >&5
+
+	if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
+				UDEV_SYSTEMD_BACKGROUND_JOBS=no
+			   else
+				as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
+			   fi
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
+				UDEV_SYSTEMD_BACKGROUND_JOBS=no
+			   else
+				as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
+			   fi
+else
+	SYSTEMD_CFLAGS=$pkg_cv_SYSTEMD_CFLAGS
+	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	test "UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes
+fi
+fi
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
 $as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
diff --git a/configure.in b/configure.in
index 9e10dc3..d4e367d 100644
--- a/configure.in
+++ b/configure.in
@@ -1092,13 +1092,26 @@ fi
 
 ################################################################################
 dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
+dnl -- Requires systemd version 205 at least (including support for systemd-run)
 AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
 AC_ARG_ENABLE(udev-systemd-background-jobs,
 	      AC_HELP_STRING([--disable-udev-systemd-background-jobs],
 			     [disable udev-systemd protocol to instantiate a service for background job]),
-	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval, UDEV_SYSTEMD_BACKGROUND_JOBS=yes)
+	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval,
+	      UDEV_SYSTEMD_BACKGROUND_JOBS=maybe)
 AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
 
+if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
+	pkg_config_init
+	PKG_CHECK_MODULES(SYSTEMD, systemd >= 205,
+			  [test "UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
+			  [if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
+				UDEV_SYSTEMD_BACKGROUND_JOBS=no
+			   else
+				AC_MSG_ERROR([bailing out... systemd >= 205 is required])
+			   fi])
+fi
+
 ################################################################################
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)


