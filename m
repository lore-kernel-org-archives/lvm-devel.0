From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 08:12:16 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20211015081216.41C9C385780D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf87b8354d07dbddc520e8b61543128e2b2f1924
Commit:        bf87b8354d07dbddc520e8b61543128e2b2f1924
Parent:        9d87549f8096759a70ce91119ebc71e8fdde0294
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 10:08:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 10:11:34 2021 +0200

configure: update

---
 configure | 161 ++++++++++++++++++++++++--------------------------------------
 1 file changed, 63 insertions(+), 98 deletions(-)

diff --git a/configure b/configure
index 808029a79..642cb4f6b 100755
--- a/configure
+++ b/configure
@@ -8780,7 +8780,7 @@ $as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
 			THIN_CONFIGURE_WARN=y
 		fi
 	fi
-	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+	if test "$THIN_CHECK_NEEDS_CHECK" = yes && test "$THIN_CONFIGURE_WARN" != y ; then
 		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
 		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
 		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
@@ -9328,7 +9328,7 @@ $as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 			CACHE_CONFIGURE_WARN=y
 		fi
 	fi
-	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+	if test "$CACHE_CHECK_NEEDS_CHECK" = yes && test "$CACHE_CONFIGURE_WARN" != y ; then
 		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
 		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
@@ -11567,13 +11567,34 @@ fi
 
 fi
 
-SYSTEMD_MIN_VERSION=
+SYSTEMD_MIN_VERSION=0
+pkg_config_init
+if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  SYSTEMD_MIN_VERSION=205
+fi
+
 ################################################################################
+if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  SYSTEMD_MIN_VERSION=221
+fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
 $as_echo_n "checking whether to build notifydbus... " >&6; }
 # Check whether --enable-notify-dbus was given.
 if test "${enable_notify_dbus+set}" = set; then :
-  enableval=$enable_notify_dbus; NOTIFYDBUS_SUPPORT=$enableval
+  enableval=$enable_notify_dbus; if test "$enableval" = yes && test "$SYSTEMD_MIN_VERSION" -lt 221; then :
+  as_fn_error $? "Enabling notify-dbus requires systemd >= 221" "$LINENO" 5
+fi
+	      NOTIFYDBUS_SUPPORT=$enableval
 else
   NOTIFYDBUS_SUPPORT=no
 fi
@@ -11585,13 +11606,19 @@ if test "$NOTIFYDBUS_SUPPORT" = yes; then :
 
 $as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 
-      SYSTEMD_MIN_VERSION=221
 fi
 
 ################################################################################
+if test "$SYSTEMD_MIN_VERSION" -ge 221; then :
+  SYSTEMD_JOURNAL_SUPPORT=maybe
+else
+  SYSTEMD_JOURNAL_SUPPORT=no
+fi
 ac_fn_c_check_header_mongrel "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_journal_h" = xyes; then :
+  if test "$SYSTEMD_JOURNAL_SUPPORT" != no; then :
   SYSTEMD_JOURNAL_SUPPORT=yes
+fi
 else
   SYSTEMD_JOURNAL_SUPPORT=no
 fi
@@ -11602,7 +11629,7 @@ $as_echo_n "checking whether to log to systemd journal... " >&6; }
 # Check whether --enable-systemd-journal was given.
 if test "${enable_systemd_journal+set}" = set; then :
   enableval=$enable_systemd_journal; if test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no; then :
-  as_fn_error $? "Enabling systemd journaling requires systemd/sd-journal.h." "$LINENO" 5
+  as_fn_error $? "Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221." "$LINENO" 5
 fi
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval
 fi
@@ -11614,24 +11641,35 @@ if test "$SYSTEMD_JOURNAL_SUPPORT" = yes; then :
 
 $as_echo "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
 
-      SYSTEMD_MIN_VERSION=221
 fi
 
 ################################################################################
+if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe
+else
+  APP_MACHINEID_SUPPORT=no
+fi
 ac_fn_c_check_header_mongrel "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_id128_h" = xyes; then :
+  if test "$APP_MACHINEID_SUPPORT" != no; then :
   APP_MACHINEID_SUPPORT=yes
+fi
 else
   APP_MACHINEID_SUPPORT=no
 fi
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build appmachineid" >&5
-$as_echo_n "checking whether to build appmachineid... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to support systemd appmachineid" >&5
+$as_echo_n "checking whether to support systemd appmachineid... " >&6; }
 # Check whether --enable-app-machineid was given.
 if test "${enable_app_machineid+set}" = set; then :
   enableval=$enable_app_machineid; if test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no; then :
-  as_fn_error $? "Enabling app machineid requires systemd/sd-id128.h." "$LINENO" 5
+  as_fn_error $? "Enabling app machineid requires systemd/sd-id128.h and systemd >= 234." "$LINENO" 5
 fi
 	      APP_MACHINEID_SUPPORT=$enableval
 fi
@@ -11643,10 +11681,9 @@ if test "$APP_MACHINEID_SUPPORT" = yes; then :
 
 $as_echo "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
 
-      SYSTEMD_MIN_VERSION=234
 fi
 
-if test -n "$SYSTEMD_MIN_VERSION"; then :
+if test "$NOTIFYDBUS_SUPPORT" = yes || test "$SYSTEMD_JOURNAL_SUPPORT" = yes || test "$APP_MACHINEID_SUPPORT" = yes  ; then :
 
       pkg_config_init
 
@@ -11658,12 +11695,12 @@ if test -n "$SYSTEMD_CFLAGS"; then
     pkg_cv_SYSTEMD_CFLAGS="$SYSTEMD_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= \"\$SYSTEMD_MIN_VERSION\"\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= "$SYSTEMD_MIN_VERSION"") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd >= "$SYSTEMD_MIN_VERSION"" 2>/dev/null`
+  pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -11675,12 +11712,12 @@ if test -n "$SYSTEMD_LIBS"; then
     pkg_cv_SYSTEMD_LIBS="$SYSTEMD_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= \"\$SYSTEMD_MIN_VERSION\"\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= "$SYSTEMD_MIN_VERSION"") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd >= "$SYSTEMD_MIN_VERSION"" 2>/dev/null`
+  pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -11701,9 +11738,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= "$SYSTEMD_MIN_VERSION"" 2>&1`
+	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd" 2>&1`
         else
-	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= "$SYSTEMD_MIN_VERSION"" 2>&1`
+	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$SYSTEMD_PKG_ERRORS" >&5
@@ -11718,9 +11755,8 @@ else
 	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	SYSTEMD_LIBS="-lsystemd"
 fi
-      SYSTEMD_LIBS="-lsystemd"
 fi
 
 ################################################################################
@@ -11842,85 +11878,14 @@ fi
 
 
 if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
-	pkg_config_init
-
-pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
-$as_echo_n "checking for SYSTEMD... " >&6; }
-
-if test -n "$SYSTEMD_CFLAGS"; then
-    pkg_cv_SYSTEMD_CFLAGS="$SYSTEMD_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd >= 205" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$SYSTEMD_LIBS"; then
-    pkg_cv_SYSTEMD_LIBS="$SYSTEMD_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd >= 205" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
+	if test "$SYSTEMD_MIN_VERSION" -ge 205; then :
+  UDEV_SYSTEMD_BACKGROUND_JOBS=yes
 else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-
-
-
-if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
+  if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then :
+  UDEV_SYSTEMD_BACKGROUND_JOBS=no
 else
-        _pkg_short_errors_supported=no
+  as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
 fi
-        if test $_pkg_short_errors_supported = yes; then
-	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= 205" 2>&1`
-        else
-	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= 205" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$SYSTEMD_PKG_ERRORS" >&5
-
-	if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
-				UDEV_SYSTEMD_BACKGROUND_JOBS=no
-			   else
-				as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
-			   fi
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
-				UDEV_SYSTEMD_BACKGROUND_JOBS=no
-			   else
-				as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
-			   fi
-else
-	SYSTEMD_CFLAGS=$pkg_cv_SYSTEMD_CFLAGS
-	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-	UDEV_SYSTEMD_BACKGROUND_JOBS=yes
 fi
 fi
 


