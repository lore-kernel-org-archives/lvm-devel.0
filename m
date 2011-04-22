From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Apr 2011 12:13:06 -0000
Subject: LVM2 configure
Message-ID: <20110422121306.22146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-22 12:13:06

Modified files:
	.              : configure 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/configure	2011/02/04 22:17:54	1.146
+++ LVM2/configure	2011/04/22 12:13:05	1.147
@@ -607,7 +607,6 @@
 UDEV_SYNC
 UDEV_RULES
 UDEV_PC
-UDEV_LIBS
 TESTING
 STATIC_LINK
 STATICDIR
@@ -675,6 +674,8 @@
 MSGFMT
 LVM2CMD_LIB
 LVM2APP_LIB
+UDEV_LIBS
+UDEV_CFLAGS
 VALGRIND
 RUBY19
 GENPNG
@@ -875,7 +876,9 @@
 DLM_CFLAGS
 DLM_LIBS
 SACKPT_CFLAGS
-SACKPT_LIBS'
+SACKPT_LIBS
+UDEV_CFLAGS
+UDEV_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1628,6 +1631,8 @@
   SACKPT_CFLAGS
               C compiler flags for SACKPT, overriding pkg-config
   SACKPT_LIBS linker flags for SACKPT, overriding pkg-config
+  UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
+  UDEV_LIBS   linker flags for UDEV, overriding pkg-config
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -8762,48 +8767,97 @@
 $as_echo "$UDEV_SYNC" >&6; }
 
 if test x$UDEV_SYNC = xyes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for udev_queue_get_udev_is_active in -ludev" >&5
-$as_echo_n "checking for udev_queue_get_udev_is_active in -ludev... " >&6; }
-if test "${ac_cv_lib_udev_udev_queue_get_udev_is_active+set}" = set; then :
-  $as_echo_n "(cached) " >&6
-else
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-ludev  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char udev_queue_get_udev_is_active ();
-int
-main ()
-{
-return udev_queue_get_udev_is_active ();
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_lib_udev_udev_queue_get_udev_is_active=yes
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
+$as_echo_n "checking for UDEV... " >&6; }
+
+if test -n "$UDEV_CFLAGS"; then
+    pkg_cv_UDEV_CFLAGS="$UDEV_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 143\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libudev >= 143") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_UDEV_CFLAGS=`$PKG_CONFIG --cflags "libudev >= 143" 2>/dev/null`
 else
-  ac_cv_lib_udev_udev_queue_get_udev_is_active=no
+  pkg_failed=yes
 fi
-rm -f core conftest.err conftest.$ac_objext \
-    conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
+ else
+    pkg_failed=untried
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_udev_udev_queue_get_udev_is_active" >&5
-$as_echo "$ac_cv_lib_udev_udev_queue_get_udev_is_active" >&6; }
-if test "x$ac_cv_lib_udev_udev_queue_get_udev_is_active" = x""yes; then :
-  UDEV_PC="libudev"; UDEV_LIBS="-ludev"
+if test -n "$UDEV_LIBS"; then
+    pkg_cv_UDEV_LIBS="$UDEV_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 143\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libudev >= 143") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_UDEV_LIBS=`$PKG_CONFIG --libs "libudev >= 143" 2>/dev/null`
 else
-  as_fn_error $? "bailing out... libudev library is required" "$LINENO" 5
+  pkg_failed=yes
 fi
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
+	        UDEV_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libudev >= 143" 2>&1`
+        else
+	        UDEV_PKG_ERRORS=`$PKG_CONFIG --print-errors "libudev >= 143" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$UDEV_PKG_ERRORS" >&5
+
+	as_fn_error $? "Package requirements (libudev >= 143) were not met:
+
+$UDEV_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables UDEV_CFLAGS
+and UDEV_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
 
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables UDEV_CFLAGS
+and UDEV_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
+
+else
+	UDEV_CFLAGS=$pkg_cv_UDEV_CFLAGS
+	UDEV_LIBS=$pkg_cv_UDEV_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	UDEV_PC="libudev"
+fi
 
 $as_echo "#define UDEV_SYNC_SUPPORT 1" >>confdefs.h
 


