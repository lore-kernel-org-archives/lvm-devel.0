From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Dec 2011 17:24:38 -0000
Subject: LVM2 configure
Message-ID: <20111211172438.22619.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-11 17:24:37

Modified files:
	.              : configure 

Log message:
	Autoreconf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/configure	2011/11/21 10:40:21	1.161
+++ LVM2/configure	2011/12/11 17:24:37	1.162
@@ -683,6 +683,8 @@
 LVM2APP_LIB
 UDEV_LIBS
 UDEV_CFLAGS
+CUNIT_LIBS
+CUNIT_CFLAGS
 GENPNG
 GENHTML
 LCOV
@@ -877,6 +879,8 @@
 DLM_LIBS
 SACKPT_CFLAGS
 SACKPT_LIBS
+CUNIT_CFLAGS
+CUNIT_LIBS
 UDEV_CFLAGS
 UDEV_LIBS'
 
@@ -1631,6 +1635,9 @@
   SACKPT_CFLAGS
               C compiler flags for SACKPT, overriding pkg-config
   SACKPT_LIBS linker flags for SACKPT, overriding pkg-config
+  CUNIT_CFLAGS
+              C compiler flags for CUNIT, overriding pkg-config
+  CUNIT_LIBS  linker flags for CUNIT, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
 
@@ -8425,17 +8432,97 @@
 $as_echo "$TESTING" >&6; }
 
 if test "$TESTING" = yes; then
-	ac_fn_c_check_header_mongrel "$LINENO" "CUnit/Basic.h" "ac_cv_header_CUnit_Basic_h" "$ac_includes_default"
-if test "x$ac_cv_header_CUnit_Basic_h" = x""yes; then :
-  have_cunit=yes
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for CUNIT" >&5
+$as_echo_n "checking for CUNIT... " >&6; }
+
+if test -n "$CUNIT_CFLAGS"; then
+    pkg_cv_CUNIT_CFLAGS="$CUNIT_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"cunit >= 2.0\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "cunit >= 2.0") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_CUNIT_CFLAGS=`$PKG_CONFIG --cflags "cunit >= 2.0" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CUNIT_LIBS"; then
+    pkg_cv_CUNIT_LIBS="$CUNIT_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"cunit >= 2.0\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "cunit >= 2.0") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_CUNIT_LIBS=`$PKG_CONFIG --libs "cunit >= 2.0" 2>/dev/null`
 else
-  have_cunit=no
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
 fi
 
 
-	if test "$have_cunit" = "no"; then
-		as_fn_error $? "CUnit is required for unit testing" "$LINENO" 5
-	fi
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
+	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "cunit >= 2.0" 2>&1`
+        else
+	        CUNIT_PKG_ERRORS=`$PKG_CONFIG --print-errors "cunit >= 2.0" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CUNIT_PKG_ERRORS" >&5
+
+	as_fn_error $? "Package requirements (cunit >= 2.0) were not met:
+
+$CUNIT_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables CUNIT_CFLAGS
+and CUNIT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
+
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables CUNIT_CFLAGS
+and CUNIT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
+
+else
+	CUNIT_CFLAGS=$pkg_cv_CUNIT_CFLAGS
+	CUNIT_LIBS=$pkg_cv_CUNIT_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+
+fi
 fi
 
 ################################################################################
@@ -10141,6 +10228,8 @@
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts!
 /Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 


